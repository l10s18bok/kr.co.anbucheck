import 'dart:io';

/// AdMob 광고 설정
class AdConfig {
  AdConfig._();

  /// 실 게재용 배너 Ad Unit ID (AdMob 계정 pub-5477604587043205의 실제 광고 단위).
  /// Google 공식 테스트 ID(pub-3940256099942544)가 아니므로 그대로 출시에 사용한다.
  /// 개발/QA 기기는 AdMob 콘솔의 '기기 테스트'에 등록해야 한다 — 미등록 기기로
  /// 반복 요청하면 AdMob이 무효 트래픽으로 판단해 해당 기기에 광고 게재를 제한한다.
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5477604587043205/7683733292';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-5477604587043205/4691467398';
    }
    throw UnsupportedError('지원하지 않는 플랫폼입니다');
  }
}
