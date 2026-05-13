import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:anbucheck/app/core/config/ad_config.dart';

/// 공통 배너 광고 위젯
/// 대상자 홈, 보호자 대시보드에서 사용
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

  BannerAd? _bannerAd;
  bool _isLoaded = false;
  int _retryCount = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null && _retryTimer == null) _loadAd();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 백그라운드 복귀 시 광고가 비어있다면 누적된 백오프를 무시하고 즉시 재시도.
    // 사용자가 앱을 다시 연 시점은 새로운 노출 기회이므로 대기시간을 적용하지 않는다.
    if (state == AppLifecycleState.resumed && _bannerAd == null) {
      _retryTimer?.cancel();
      _retryTimer = null;
      _retryCount = 0;
      _loadAd();
    }
  }

  void _loadAd() async {
    final width = MediaQuery.of(context).size.width.truncate();
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
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      child: Center(child: AdWidget(ad: _bannerAd!)),
    );
  }
}
