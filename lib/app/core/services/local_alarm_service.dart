import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// 로컬 반복 알림 안전망 (Android/iOS 공통)
///
/// Silent Push 미수신 시 heartbeat 시각 + 10분에 매일 반복 알림을 표시한다.
/// Silent Push 수신 성공 시마다 취소 후 다음날 동일 시각으로 재예약한다.
class LocalAlarmService {
  static const _alarmId = 0x416C6172; // 'Alar' hex — 중복 방지 고정 ID
  static const alarmPayload = 'local_safety_alarm';

  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _androidChannelId = 'anbu_alerts';
  static const _androidChannelName = '안부 알림';

  /// 로컬 안전망 알림 예약
  /// heartbeat 시각 + 10분, 매일 반복
  /// 이미 예약된 알림이 있으면 먼저 취소 후 재등록
  static Future<void> schedule(int heartbeatHour, int heartbeatMinute) async {
    await cancel();

    final totalMinutes = heartbeatHour * 60 + heartbeatMinute + 10;
    final alarmHour = (totalMinutes ~/ 60) % 24;
    final alarmMinute = totalMinutes % 60;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year, now.month, now.day,
      alarmHour, alarmMinute,
    );
    // 오늘 시각이 이미 지났으면 내일로
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _alarmId,
      '📱 안부 확인이 필요합니다',
      '이 메시지 알림을 한 번 터치해 주세요.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시각 반복
      payload: alarmPayload,
    );
  }

  /// 로컬 안전망 알림 취소
  static Future<void> cancel() async {
    await _plugin.cancel(_alarmId);
  }
}
