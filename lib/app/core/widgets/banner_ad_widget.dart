import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:anbucheck/app/core/config/ad_config.dart';
import 'package:anbucheck/app/core/services/ad_service.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';

/// 공통 배너 광고 위젯
/// 대상자 홈, 보호자 대시보드에서 사용.
///
/// 프리미엄 구독(plan='yearly' AND is_active=true) 보호자는 광고 표시 안 함
/// (PRD-FrontEnd §1.5 "유료 구독 보호자는 광고 제거"). 결제 후 onVerified 콜백이
/// TokenLocalDatasource 캐시를 갱신하므로, 다음에 페이지 진입(initState)하거나
/// 앱 백그라운드→포그라운드 복귀(resumed) 시점에 광고가 사라짐. 대상자 모드는
/// plan/is_active 캐시가 채워지지 않거나 false → 항상 광고 표시.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget>
    with WidgetsBindingObserver {
  // 한국 광고 fill rate 변동 대응 — 영구 포기 없이 지수 백오프(최대 10분)로
  // 무기한 재시도. 이전에는 5회 한도였으나 NoFill 누적으로 Android 광고가
  // 영구 사라지는 현상이 있어 한도를 제거하고, resume 시점에 백오프를 리셋한다.
  static const int _baseDelaySeconds = 30;
  static const int _maxDelaySeconds = 600;

  final _tokenDs = TokenLocalDatasource();

  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _hideForPremium = false;
  int _retryCount = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPremium();
  }

  /// 프리미엄 구독 보호자는 광고 숨김 (PRD-FrontEnd §1.5).
  /// guardian_settings_page.dart:504의 카드 분기 로직과 동일 기준 사용.
  Future<void> _checkPremium() async {
    final plan = await _tokenDs.getSubscriptionPlan();
    final isActive = await _tokenDs.getSubscriptionActive();
    final isPremium = plan == 'yearly' && isActive;
    if (!mounted) return;
    if (isPremium != _hideForPremium) {
      setState(() => _hideForPremium = isPremium);
      if (isPremium) {
        // 광고 로드 중이면 dispose해 메모리 회수.
        _retryTimer?.cancel();
        _retryTimer = null;
        _bannerAd?.dispose();
        _bannerAd = null;
        _isLoaded = false;
      } else if (_bannerAd == null && _retryTimer == null) {
        // 프리미엄 해제(만료/환불 등) 시 광고 다시 로드.
        _loadAd();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hideForPremium && _bannerAd == null && _retryTimer == null) _loadAd();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 백그라운드 복귀 시 구독 상태 재확인 (결제·만료 직후 광고 즉시 갱신).
    // 광고가 비어있다면 누적된 백오프를 무시하고 즉시 재시도.
    if (state == AppLifecycleState.resumed) {
      _checkPremium();
      if (!_hideForPremium && _bannerAd == null) {
        _retryTimer?.cancel();
        _retryTimer = null;
        _retryCount = 0;
        _loadAd();
      }
    }
  }

  void _loadAd() async {
    // iOS: AdService(MobileAds.initialize) 등록 전에 BannerAd.load()를 호출하면
    // GMA SDK가 ATT 팝업을 트리거한다. 등록될 때까지 2초 간격으로 재시도.
    if (Platform.isIOS && !Get.isRegistered<AdService>()) {
      _retryTimer?.cancel();
      _retryTimer = Timer(const Duration(seconds: 2), () {
        _retryTimer = null;
        if (mounted && _bannerAd == null) _loadAd();
      });
      return;
    }

    // context 값을 async 호출 전에 캡처 (BuildContext across async gap 방지)
    final width = MediaQuery.of(context).size.width.truncate();

    // UMP 동의 확인 — EEA/UK/스위스 사용자가 동의 거부 시 광고 로드 차단.
    // 동의 상태는 사용자 결정이므로 retry하지 않는다.
    if (!await ConsentInformation.instance.canRequestAds()) return;
    if (!mounted) return;

    final adSize = await AdSize.getAnchoredAdaptiveBannerAdSize(Orientation.portrait, width);
    if (adSize == null || !mounted) return;

    _bannerAd = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _isLoaded = true;
            _retryCount = 0;
          });
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            debugPrint(
              '[BannerAd] load failed: code=${error.code} domain=${error.domain} message=${error.message}',
            );
          }
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });
          _scheduleRetry();
        },
      ),
    )..load();
  }

  void _scheduleRetry() {
    final delay = min(
      (_baseDelaySeconds * pow(2, _retryCount)).toInt(),
      _maxDelaySeconds,
    );
    _retryCount++;
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: delay), () {
      _retryTimer = null;
      if (mounted && _bannerAd == null) _loadAd();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hideForPremium || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      child: Center(child: AdWidget(ad: _bannerAd!)),
    );
  }
}
