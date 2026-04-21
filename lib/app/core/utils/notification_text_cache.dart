import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 백그라운드 isolate용 알림 문자열 캐시
///
/// WorkManager/BGTask 콜백에서는 GetX `.tr`이 동작하지 않으므로,
/// 포그라운드에서 미리 번역 문자열을 SharedPreferences에 캐시한다.
class NotificationTextCache {
  static const _prefix = 'noti_text_';

  /// 캐시할 키 목록 (번역 키 → SharedPreferences 키)
  static const _keys = [
    'local_alarm_title',
    'local_alarm_body',
    'wellbeing_check_title',
    'wellbeing_check_body',
    'noti_channel_name',
    'notification_send_failed_title',
    'notification_send_failed_body',
  ];

  /// 포그라운드에서 호출 — 현재 locale 기준 번역 문자열을 캐시
  static Future<void> cacheAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _keys) {
      final translated = key.tr;
      // .tr 실패 시 (키 그대로 반환) 캐시하지 않음
      if (translated != key) {
        await prefs.setString('$_prefix$key', translated);
      }
    }
  }

  /// 백그라운드 isolate에서 호출 — 캐시된 번역 문자열 반환
  /// 캐시가 없으면 [fallback] 반환
  static Future<String> get(String key, {String fallback = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix$key') ?? fallback;
  }
}
