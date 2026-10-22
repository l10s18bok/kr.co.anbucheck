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
  const BannerAdWidget({super.key, this.fallback, this.onFallbackChanged});

  /// 광고를 보여 줄 수 없을 때(프리미엄 구독 / 동의·권한 거부 / 로드 실패) 같은 자리에 대신
  /// 보여 줄 위젯. null이면 기존처럼 아무것도 그리지 않는다(폰 레이아웃은 변화 없음).
  /// 아직 결과가 정해지지 않은 동안(최대 [_pendingTimeoutSeconds]초)은 깜빡임을 막으려고
  /// 이 위젯도 광고도 그리지 않는다.
  final Widget? fallback;

  /// [fallback]이 실제로 보이는지 바뀔 때 호출(제목 줄의 작은 추가 버튼을 숨기는 등).
  final ValueChanged<bool>? onFallbackChanged;

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

  /// 광고 시도 결과가 정해지지 않아도 이 시간이 지나면 fallback을 보인다(무기한 빈칸 방지).
  static const int _pendingTimeoutSeconds = 8;

  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _hideForPremium = false;

  /// 프리미엄 여부 조회가 끝났는가 — 끝나기 전에는 fallback을 보이지 않는다.
  bool _premiumChecked = false;

  /// 첫 광고 시도가 실패/차단으로 끝났거나 대기 시간이 지났는가.
  bool _attemptFinished = false;
  Timer? _pendingTimer;
  bool _lastFallbackShown = false;

  /// 이 위젯이 실제로 받는 가로 폭(LayoutBuilder). 넓은 화면(≥600dp)에서만 광고 폭 계산에 쓴다.
  /// 분할 화면의 왼쪽 pane처럼 창 폭보다 좁은 자리에 창 폭 크기의 광고를 요청하면
  /// "Ad size will not fit on screen"으로 로드가 실패한다. 폰(<600dp)은 기존처럼 창 폭을 그대로 쓴다.
  double? _availWidth;
  int? _loadedWidth;
  Timer? _retryTimer;

  /// 광고 실패 횟수·다음 요청 허용 시각 — **앱 전체에서 공유**한다(위젯 인스턴스마다 두지 말 것).
  /// 보호자 하단 탭은 이동할 때마다 페이지(와 이 위젯)가 새로 만들어지는데, 대기 횟수를 인스턴스에
  /// 두면 탭을 옮길 때마다 0으로 돌아가 `didChangeDependencies`가 곧바로 광고를 다시 요청한다.
  /// 광고 재고가 없는 기기(저사양 삼성폰 실측)에서는 탭마다 GMA SDK·웹뷰가 다시 뜨며 UI 스레드가
  /// 끊겼다(dumpsys gfxinfo: 끊긴 프레임 47~51%, 로드 실패 로그가 탭 간격 2~4초).
  static int _failStreak = 0;
  static DateTime? _nextAllowedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPremium();
    _pendingTimer = Timer(const Duration(seconds: _pendingTimeoutSeconds), () {
      if (mounted && !_isLoaded && !_attemptFinished) {
        setState(() => _attemptFinished = true);
      }
    });
    // 페이지에 다시 들어올 때 이전 fallback 상태가 남아 있지 않게 초기화.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onFallbackChanged?.call(false);
    });
  }

  /// fallback 표시 여부가 바뀌면 build 밖(프레임 뒤)에서 알린다.
  void _syncFallbackShown(bool shown) {
    if (shown == _lastFallbackShown) return;
    _lastFallbackShown = shown;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onFallbackChanged?.call(shown);
    });
  }

  /// 프리미엄 구독 보호자는 광고 숨김 (PRD-FrontEnd §1.5).
  /// guardian_settings_page.dart:504의 카드 분기 로직과 동일 기준 사용.
  Future<void> _checkPremium() async {
    final plan = await _tokenDs.getSubscriptionPlan();
    final isActive = await _tokenDs.getSubscriptionActive();
    final isPremium = plan == 'yearly' && isActive;
    if (!mounted) return;
    if (!_premiumChecked) setState(() => _premiumChecked = true);
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
        _failStreak = 0;
        _nextAllowedAt = null;
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

    // 직전 실패의 대기 시간이 남아 있으면 지금 요청하지 않고 남은 시간 뒤로 미룬다(탭 이동으로 새로 만들어진
    // 위젯도 같은 대기를 따른다). 재시도 타이머가 걸려 있는 동안 didChangeDependencies는 다시 부르지 않는다.
    final wait = _nextAllowedAt?.difference(DateTime.now());
    if (wait != null && !wait.isNegative && wait > Duration.zero) {
      _retryTimer?.cancel();
      _retryTimer = Timer(wait, () {
        _retryTimer = null;
        if (mounted && _bannerAd == null) _loadAd();
      });
      return;
    }

    // context 값을 async 호출 전에 캡처 (BuildContext across async gap 방지)
    final mq = MediaQuery.of(context).size;
    final wideWindow = mq.width >= 600;
    // 넓은 화면은 레이아웃 폭이 정해질 때까지 기다린다(LayoutBuilder가 확정 후 다시 부른다).
    if (wideWindow && _availWidth == null) return;
    final width = (wideWindow ? _availWidth! : mq.width).truncate();
    _loadedWidth = width;

    // UMP 동의 확인 — EEA/UK/스위스 사용자가 동의 거부 시 광고 로드 차단.
    // 동의 상태는 사용자 결정이므로 retry하지 않는다.
    if (!await ConsentInformation.instance.canRequestAds()) {
      // 동의 거부 — retry하지 않으므로 여기서 시도 종료로 확정(fallback 표시 가능).
      if (mounted) setState(() => _attemptFinished = true);
      return;
    }
    if (!mounted) return;

    final adSize = await AdSize.getAnchoredAdaptiveBannerAdSize(
      wideWindow && mq.width > mq.height ? Orientation.landscape : Orientation.portrait,
      width,
    );
    if (adSize == null || !mounted) {
      if (mounted) setState(() => _attemptFinished = true);
      return;
    }

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
          });
          _failStreak = 0;
          _nextAllowedAt = null;
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            debugPrint(
              '[BannerAd] load failed: code=${error.code} domain=${error.domain} message=${error.message}',
            );
          }
          ad.dispose();
          // 위젯이 이미 없어져도(탭 이동) 실패는 공유 대기에 반영한다.
          _recordFailure();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
            _attemptFinished = true;
          });
          _scheduleRetry();
        },
      ),
    )..load();
  }

  void _recordFailure() {
    final delay = min(
      (_baseDelaySeconds * pow(2, _failStreak)).toInt(),
      _maxDelaySeconds,
    );
    _failStreak++;
    _nextAllowedAt = DateTime.now().add(Duration(seconds: delay));
  }

  void _scheduleRetry() {
    final delay = _nextAllowedAt?.difference(DateTime.now()) ?? Duration.zero;
    _retryTimer?.cancel();
    _retryTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
      _retryTimer = null;
      if (mounted && _bannerAd == null) _loadAd();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _retryTimer?.cancel();
    _pendingTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  /// 넓은 화면에서 내가 받는 폭이 바뀌었으면(펼침·분할 전환) 광고를 새 폭으로 다시 요청한다.
  void _onLayoutWidth(double w) {
    if (MediaQuery.sizeOf(context).width < 600) return;
    _availWidth = w;
    if (_loadedWidth != null && _loadedWidth == w.truncate()) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hideForPremium) return;
      _retryTimer?.cancel();
      _retryTimer = null;
      _bannerAd?.dispose();
      _bannerAd = null;
      _isLoaded = false;
      _loadAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.hasBoundedWidth) _onLayoutWidth(constraints.maxWidth);
      return _buildContent(context);
    });
  }

  Widget _buildContent(BuildContext context) {
    if (_hideForPremium || !_isLoaded || _bannerAd == null) {
      // 프리미엄이거나 광고 시도가 끝났는데 광고가 없으면 fallback. 아직 정해지지 않았으면 빈칸.
      final showFallback = widget.fallback != null &&
          _premiumChecked &&
          (_hideForPremium || _attemptFinished);
      _syncFallbackShown(showFallback);
      return showFallback ? widget.fallback! : const SizedBox.shrink();
    }
    _syncFallbackShown(false);

    return SizedBox(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      child: Center(child: AdWidget(ad: _bannerAd!)),
    );
  }
}
