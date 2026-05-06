import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:anbucheck/app/core/utils/notification_text_cache.dart';

/// 매일 반복되는 안부 확인 안전망 로컬 알림.
///
/// **iOS**: heartbeat 예약 시각에 정확히 fire.
/// BGTaskScheduler를 사용하지 않으므로 이 알림 자체가 사용자 → 앱 진입 →
/// heartbeat 전송 트리거 역할 (PRIMARY).
///
/// **Android**: heartbeat 예약 시각 + 3시간에 fire (LAST-RESORT).
/// WorkManager one-off + periodic 15분 + 앱 열기(2차) 안전망이 모두 실패해
/// worker 자체가 cancel된 시나리오까지 커버하는 최후 방어선. 자정을 넘기면
/// 자연 롤오버되어 다음 날 새벽으로 예약된다. 알림 탭은 앱 포그라운드 전환만
/// 트리거하고, holding controller(SafetyHomeBase / GuardianDashboard)의
/// onResumed가 자동 재전송을 처리한다.
///
/// 양 플랫폼 모두 heartbeat 전송 성공 시 `_onHeartbeatSent`가 cancel + 내일자
/// 재예약을 수행한다 — 떠 있는 알림이든 예약된 알림이든 동일 ID이므로
/// `cancel(_alarmId)` 한 번으로 둘 다 제거된다.
class LocalAlarmService {
  static const _alarmId = 0x416C6172; // 'Alar' hex — 일일 안전망 알림 ID (플랫폼 공유)
  static const _sendFailedId = 0x53466169; // 'SFai' hex — Android retry 실패 알림 ID

  /// iOS G+S 오늘의 안부 확인 메시지 알림 payload.
  /// FcmService._handleNotificationTap이 이 값을 보고 G+S 라우팅을 실행.
  static const alarmPayload = 'gs_deadman';

  /// Android 안부 확인 안전망 알림 payload.
  /// 별도 라우팅 없이 앱 포그라운드 전환만 트리거 — 컨트롤러 onResumed가
  /// 자동 전송을 처리한다. (iOS의 `gs_deadman`과 분리해 subject 모드 사용자가
  /// 잘못 G+S 라우팅으로 빠지지 않도록 한다.)
  static const safetyNetPayload = 'safety_net';

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

  /// 일일 안부 확인 안전망 로컬 알림 예약.
  ///
  /// - **iOS**: heartbeat 예약 시각에 정확히 매일 fire (PRIMARY 트리거)
  /// - **Android**: heartbeat 예약 시각 + 3시간에 매일 fire (LAST-RESORT 안전망).
  ///   자정 넘기면 다음 날 새벽으로 자연 롤오버 (예: 22:30 예약 → 다음 날 01:30)
  ///
  /// [forceNextDay] heartbeat 전송 성공 후 호출 시 true — 오늘 알림이 이미
  /// 떠 있더라도 cancel하고 내일자로 강제 재예약. (`cancel(_alarmId)`는
  /// pending + 표시 중인 알림을 모두 제거하므로 stale 알림이 남지 않는다.)
  static Future<void> schedule(int heartbeatHour, int heartbeatMinute, {bool forceNextDay = false}) async {
    await _ensureInitialized();
    await _cancelInternal();

    final now = tz.TZDateTime.now(tz.local);

    // 플랫폼별 fire 시각 결정
    int targetHour;
    int targetMinute;
    int dayOffset;
    String payload;

    if (Platform.isAndroid) {
      // Android: heartbeat 시각 + 3시간 (자정 넘기면 다음 날 새벽으로 자연 롤오버)
      final raw = heartbeatHour + 3;
      targetHour = raw % 24;
      targetMinute = heartbeatMinute;
      dayOffset = (raw >= 24) ? 1 : 0;
      payload = safetyNetPayload;
    } else {
      // iOS: 정확한 heartbeat 시각
      targetHour = heartbeatHour;
      targetMinute = heartbeatMinute;
      dayOffset = 0;
      payload = alarmPayload;
    }

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year, now.month, now.day,
      targetHour, targetMinute,
    ).add(Duration(days: dayOffset));

    // heartbeat 성공 후에는 내일로 강제, 그 외에는 오늘 시각이 지났으면 내일로
    if (forceNextDay || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    debugPrint('[LocalAlarm] 예약 시도: ${scheduled.toString()} (heartbeat $heartbeatHour:${heartbeatMinute.toString().padLeft(2, '0')}, payload=$payload)');

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
      payload: payload,
    );
    debugPrint('[LocalAlarm] 예약 완료: ${scheduled.toString()}');
  }

  /// 일일 안전망 알림 취소 (예약 + 표시 중인 알림 모두 제거).
  /// 양 플랫폼 모두에서 동작 — 401 세션 만료, G+S 비활성화, 모드 전환 등에서 호출.
  static Future<void> cancel() async {
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
