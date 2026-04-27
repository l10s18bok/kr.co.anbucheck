import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:anbucheck/app/core/utils/notification_text_cache.dart';

/// iOS 전용 오늘의 안부 확인 메시지 로컬 알림 (iOS G+S 전용)
///
/// iOS는 BGTaskScheduler를 사용하지 않으므로, heartbeat 예약 시각에 정확히
/// 오늘의 안부 확인 메시지 로컬 알림을 표시하여 사용자에게 앱 실행을 유도한다.
/// 알림 탭 → 앱 포그라운드 전환 → 홈 화면 자동 전송 로직이 heartbeat를 전송.
/// Android는 WorkManager periodic이 안전망 역할을 하므로 로컬 알림 불필요.
class LocalAlarmService {
  static const _alarmId = 0x416C6172; // 'Alar' hex — iOS 정기 알림용 고정 ID
  static const _sendFailedId = 0x53466169; // 'SFai' hex — Android 전송 실패 알림용 고정 ID
  static const alarmPayload = 'gs_deadman';
  static const sendFailedPayload = 'send_failed';

  static FlutterLocalNotificationsPlugin? _plugin;

  static const _androidChannelId = 'anbu_alerts';

  /// FcmService 초기화 후 반드시 호출 — 초기화된 플러그인 인스턴스 공유
  static void setPlugin(FlutterLocalNotificationsPlugin plugin) {
    _plugin = plugin;
  }

  /// 플러그인이 미초기화 상태일 때 (백그라운드 isolate) 직접 초기화
  static Future<void> _ensureInitialized() async {
    if (_plugin != null) return;
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
    );
    _plugin = plugin;
    debugPrint('[LocalAlarm] 플러그인 자체 초기화 완료 (백그라운드 isolate)');
  }

  /// heartbeat 예약 시각에 정확히 오늘의 안부 확인 메시지 로컬 알림 예약 (iOS 전용)
  /// iOS G+S: BGTaskScheduler 없이 이 알림이 유일한 예약 트리거
  /// [forceNextDay] heartbeat 전송 성공 후 호출 시 true — 오늘 알림 방지, 내일로 강제
  static Future<void> schedule(int heartbeatHour, int heartbeatMinute, {bool forceNextDay = false}) async {
    if (Platform.isAndroid) return;
    await _ensureInitialized();
    await _cancelInternal();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year, now.month, now.day,
      heartbeatHour, heartbeatMinute,
    );
    // heartbeat 성공 후에는 내일로 강제, 그 외에는 오늘 시각이 지났으면 내일로
    if (forceNextDay || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    debugPrint('[LocalAlarm] 예약 시도: ${scheduled.toString()} (heartbeat $heartbeatHour:${heartbeatMinute.toString().padLeft(2, '0')})');

    // 백그라운드 isolate에서는 GetX .tr 사용 불가 → SharedPreferences 캐시 사용
    final title = await NotificationTextCache.get(
        'local_alarm_title', fallback: '💗 Wellness check needed');
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
      matchDateTimeComponents: DateTimeComponents.time,
      payload: alarmPayload,
    );
    debugPrint('[LocalAlarm] 예약 완료: ${scheduled.toString()}');
  }

  /// 로컬 안전망 알림 취소 (iOS 전용)
  static Future<void> cancel() async {
    if (Platform.isAndroid) return;
    await _cancelInternal();
  }

  /// heartbeat 전송이 retry 3회 모두 실패해 pending 큐에 적재됐을 때 호출 (Android 전용).
  /// 네트워크 끊김 등으로 사용자가 인지해야 할 상황을 정보성 알림으로 전달.
  /// 인터넷 복구 시 자동 재전송되므로 사용자에게 강한 액션을 요구하지 않는다.
  static Future<void> notifySendFailed() async {
    if (Platform.isIOS) return;
    await _ensureInitialized();

    final title = await NotificationTextCache.get(
        'notification_send_failed_title',
        fallback: '📶 Check your internet connection');
    final body = await NotificationTextCache.get(
        'notification_send_failed_body',
        fallback: 'Open the app to resend your wellness check.');
    final channelName = await NotificationTextCache.get(
        'noti_channel_name', fallback: 'Anbu Alerts');

    await _plugin!.show(
      _sendFailedId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: sendFailedPayload,
    );
    debugPrint('[LocalAlarm] 전송 실패 알림 표시');
  }

  /// 전송 실패 알림 제거 (Android 전용).
  /// heartbeat 전송 성공(예: 사용자가 알림 탭 → 앱 진입 → 자동 재전송) 직후 호출하여
  /// 잔존 알림이 사용자 혼동을 일으키지 않도록 한다.
  static Future<void> cancelSendFailed() async {
    if (Platform.isIOS) return;
    await _ensureInitialized();
    await _plugin!.cancel(_sendFailedId);
  }

  /// 내부 취소 (schedule 내에서도 호출)
  static Future<void> _cancelInternal() async {
    await _ensureInitialized();
    await _plugin!.cancel(_alarmId);
  }
}
