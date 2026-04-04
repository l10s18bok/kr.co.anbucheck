import 'dart:io';

/// AdMob 광고 설정
/// 출시 전 실제 Ad Unit ID로 교체 필요
class AdConfig {
  AdConfig._();

  /// 테스트용 배너 Ad Unit ID (Google 공식 제공)
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError('지원하지 않는 플랫폼입니다');
  }
}
