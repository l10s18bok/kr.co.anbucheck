import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:anbucheck/app/core/utils/notification_text_cache.dart';

/// 로컬 반복 알림 안전망 (Android/iOS 공통)
///
/// Silent Push 미수신 시 heartbeat 시각 + 30분에 매일 반복 알림을 표시한다.
/// Silent Push 수신 성공 시마다 취소 후 다음날 동일 시각으로 재예약한다.
class LocalAlarmService {
  static const _alarmId = 0x416C6172; // 'Alar' hex — 중복 방지 고정 ID
  static const alarmPayload = 'local_safety_alarm';

  static FlutterLocalNotificationsPlugin? _plugin;

  static const _androidChannelId = 'anbu_alerts';

  /// FcmService 초기화 후 반드시 호출 — 초기화된 플러그인 인스턴스 공유
  static void setPlugin(FlutterLocalNotificationsPlugin plugin) {
    _plugin = plugin;
  }

  /// 로컬 안전망 알림 예약
  /// heartbeat 시각 + 30분, 매일 반복
  /// 이미 예약된 알림이 있으면 먼저 취소 후 재등록
  /// 플러그인이 미초기화 상태일 때 (백그라운드 isolate) 직접 초기화
  static Future<void> _ensureInitialized() async {
    if (_plugin != null) return;
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    _plugin = plugin;
    debugPrint('[LocalAlarm] 플러그인 자체 초기화 완료 (백그라운드 isolate)');
  }

  /// 예약시각 + 30분에 로컬 안전망 알림 예약
  /// [forceNextDay] heartbeat 전송 성공 후 호출 시 true — 오늘 알림 방지, 내일로 강제
  static Future<void> schedule(int heartbeatHour, int heartbeatMinute, {bool forceNextDay = false}) async {
    await _ensureInitialized();
    await cancel();

    final totalMinutes = heartbeatHour * 60 + heartbeatMinute + 30;
    final alarmHour = (totalMinutes ~/ 60) % 24;
    final alarmMinute = totalMinutes % 60;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year, now.month, now.day,
      alarmHour, alarmMinute,
    );
    // heartbeat 성공 후에는 내일로 강제, 그 외에는 오늘 시각이 지났으면 내일로
    if (forceNextDay || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    debugPrint('[LocalAlarm] 예약 시도: ${scheduled.toString()} (heartbeat $heartbeatHour:${heartbeatMinute.toString().padLeft(2, '0')} + 30분)');

    // 백그라운드 isolate에서는 GetX .tr 사용 불가 → SharedPreferences 캐시 사용
    final title = await NotificationTextCache.get(
        'local_alarm_title', fallback: '📱 Wellness check needed');
    final body = await NotificationTextCache.get(
        'local_alarm_body', fallback: 'Please tap this notification.');
    final channelName = await NotificationTextCache.get(
        'noti_channel_name', fallback: 'Anbu Alerts');

    await _plugin!.zonedSchedule(
      _alarmId,
      title,
      body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: alarmPayload,
    );
    debugPrint('[LocalAlarm] 예약 완료: ${scheduled.toString()}');
  }

  /// 로컬 안전망 알림 취소
  static Future<void> cancel() async {
    await _ensureInitialized();
    await _plugin!.cancel(_alarmId);
  }
}
