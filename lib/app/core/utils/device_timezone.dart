import 'package:flutter_timezone/flutter_timezone.dart';

/// 서버에 보낼 기기 현재 IANA 시간대 — 해외 여행·이주·출장 대응.
///
/// 서버 `devices.timezone`은 원래 가입 때 한 번만 저장됐다. 폰은 **지금 있는 곳의 현지
/// 시각**으로 동작하므로(WorkManager 예약, `scheduled_key`의 날짜·시각) 이동하면 서버와
/// 폰의 "오늘"이 어긋난다. heartbeat와 FCM 토큰 갱신에 이 값을 실어 서버가 따라오게 한다.
/// 서버 규칙은 PRD-BackEnd §4.6 "기기 시간대 동기화", 클라 규칙은 PRD-FrontEnd §2.2.3.
///
/// ⚠️ **OS 조회에 성공한 원본 문자열만 담는다.** 스플래시·워커는 조회에 실패하면
/// `tzlib.local`을 `Asia/Seoul`로 폴백하는데, 그 폴백값을 서버로 보내면 한국 밖 사용자의
/// 올바른 시간대가 서울로 덮인다. 그래서 `tzlib.local.name`을 쓰지 않고 이 값만 쓴다.
/// 조회 실패·미초기화(FCM 백그라운드 isolate 등)면 `null`이고, 그때는 필드를 싣지 않는다
/// — 서버가 저장값을 그대로 쓰는 안전한 방향이다.
///
/// ⚠️ `tzlib.getLocation()`보다 **먼저** 담는다. Dart `timezone` 패키지가 모르는 이름이어도
/// OS가 말한 값은 서버가 따로 검증한다.
class DeviceTimezone {
  DeviceTimezone._();

  /// 이 isolate에서 마지막으로 조회에 성공한 OS 시간대. 없으면 null.
  static String? current;

  /// OS에서 다시 조회해 [current]를 갱신한다. 실패하면 [current]를 그대로 두고 null을 반환한다.
  ///
  /// 포그라운드 복귀 때 쓴다 — 앱이 살아 있는 채 시간대가 바뀌면 [current]가 낡기 때문이다.
  /// ⚠️ `tzlib.setLocalLocation`은 여기서 바꾸지 않는다. 로컬 알림 예약 동작까지 바뀌어
  /// 이번 변경의 범위를 벗어난다.
  static Future<String?> refresh() async {
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      if (name.isEmpty) return null;
      current = name;
      return name;
    } catch (_) {
      return null;
    }
  }
}
