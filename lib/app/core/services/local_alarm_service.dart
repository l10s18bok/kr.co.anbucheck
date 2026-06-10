import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:anbucheck/app/core/utils/notification_text_cache.dart';

/// 매일 반복되는 안부 확인 안전망 로컬 알림 — **iOS 전용**.
///
/// **iOS**: heartbeat 예약 시각에 정확히 fire.
/// BGTaskScheduler를 사용하지 않으므로 이 알림 자체가 사용자 → 앱 진입 →
/// heartbeat 전송 트리거 역할 (PRIMARY). heartbeat 전송 성공 시 `_onHeartbeatSent`가
/// `cancel(_alarmId)` + 내일자 재예약을 수행한다(떠 있는 알림이든 예약된 알림이든
/// 동일 ID라 한 번에 제거).
///
/// **Android**: 더 이상 일일 안전망 로컬 알림을 예약하지 않는다 ([schedule]은
/// 기존 알림 cancel 후 즉시 return). 과거 heartbeat+3h + `matchDateTimeComponents.time`
/// 조합이 forceNextDay로 날짜를 내일로 밀어도 "그 시각의 다음 발생=오늘"로 당겨
/// 매일 오발화하던 결정적 버그가 있었다. Android 대상자 안부유도는 **서버 FCM 푸시**
/// (type `subject_safety_net`, 미수신 체크 = 예약시각 +2h)로 이관됐다 — 서버 발송이라
/// OEM이 worker/로컬알람을 죽인 상황(LAST-RESORT 시나리오)에도 도달한다.
///
/// Android의 `send_failed`(retry 3회 실패 즉시 안내)·`trial_ended`(무료체험 종료
/// 1회)·배터리/네트워크 안내 알림은 이 변경과 무관하게 그대로 동작한다.
class LocalAlarmService {
  static const _alarmId = 0x416C6172; // 'Alar' hex — 일일 안전망 알림 ID (플랫폼 공유)
  static const _sendFailedId = 0x53466169; // 'SFai' hex — Android retry 실패 알림 ID
  static const _trialEndedId = 0x5472456E; // 'TrEn' hex — 무료체험 종료 1회 알림 ID

  /// 무료체험 종료 1회성 알림 payload (탭 시 보호자 설정 화면으로 이동 → [구독하기]).
  static const trialEndedPayload = 'trial_ended';

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

  /// 일일 안부 확인 안전망 로컬 알림 등록.
  ///
  /// - **iOS**: heartbeat 예약 시각에 매일 반복 fire (PRIMARY 트리거).
  ///   `matchDateTimeComponents: DateTimeComponents.time` — 한 번 등록하면 OS가
  ///   매일 같은 시각에 자동 발화. 같은 ID로 재등록 시 기존 예약을 덮어쓰므로
  ///   취소 없이 idempotent. **최초 설치·재설치 복원·예약시각 변경 시에만 호출**.
  /// - **Android**: 예약하지 않음 — 기존 알림 cancel 후 즉시 return.
  ///   (서버 FCM 푸시 `subject_safety_net`으로 이관, 클래스 doc 참조)
  static Future<void> schedule(int heartbeatHour, int heartbeatMinute) async {
    await _ensureInitialized();

    // Android: 일일 안부 확인 안전망 로컬 알림을 더 이상 예약하지 않는다.
    //   heartbeat+3h + matchDateTimeComponents.time(매일 반복) 조합이, 전송 성공 후
    //   forceNextDay로 날짜를 내일로 밀어도 플러그인이 "그 시각의 다음 발생=오늘"로
    //   당겨 발화하던 결정적 오발화 버그가 있었다. Android 대상자 안부유도는
    //   서버 FCM 푸시(type 'subject_safety_net', 미수신 체크 = 예약시각 +2h)로 이관됨.
    //   업그레이드 기기 잔존 알림은 이 cancel로 정리된다.
    //   (send_failed·trial_ended·iOS 정시 알림은 무관.)
    if (Platform.isAndroid) {
      await _cancelInternal(); // 업그레이드 기기 잔존 알림 정리
      debugPrint('[LocalAlarm] Android 일일 안전망 알림 미예약 — 서버 푸시(subject_safety_net)로 이관');
      return;
    }

    // iOS: heartbeat 예약 시각 정시에 매일 fire (BGTaskScheduler 미사용 → PRIMARY 트리거).
    //   matchDateTimeComponents.time으로 한 번만 등록하면 OS가 매일 자동 반복.
    //   heartbeat 전송 성공 후 재등록하지 않으며, heartbeat가 예약시각 전에 전송돼도
    //   알림은 정시에 정상 발화한다 — 탭 시 isReportedToday 체크로 중복 전송 차단.
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year, now.month, now.day,
      heartbeatHour, heartbeatMinute,
    );

    // 오늘 시각이 이미 지났으면 내일로 (첫 발화 시각만 결정 — 이후 매일 자동 반복)
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    debugPrint('[LocalAlarm] iOS 예약 시도: ${scheduled.toString()} (heartbeat $heartbeatHour:${heartbeatMinute.toString().padLeft(2, '0')})');

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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: alarmPayload, // iOS 전용 — gs_deadman
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
          // 실패가 지속되면 periodic 폴링이 15분마다 이 알림을 재호출할 수 있다.
          // onlyAlertOnce로 동일 ID 재표시는 소리/헤드업 없이 조용히 갱신만 한다
          // (첫 1회만 알림). cancelSendFailed로 ID 취소 후 재표시되면 다시 1회 알림.
          onlyAlertOnce: true,
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

  /// 무료체험 종료 1회성 로컬 알림 예약 — **최초 설치 보호자 전용**.
  /// 체험 만료 시각([fireAt], 서버 register 응답의 expires_at = 가입 +90일)에 단발로 발화.
  /// 일일 안전망과 달리 `matchDateTimeComponents` 없이 1회만 fire하며, 고유 ID(`_trialEndedId`)라
  /// `cancel(_alarmId)`/`cancelSendFailed` 등 기존 ID 지정 취소에는 영향받지 않는다(전체 취소 코드 없음).
  /// 결제(구독) 성공 또는 탈퇴/모드변경 시 [cancelTrialEnded]로 명시 취소한다.
  /// [title]/[body]는 포그라운드(onboarding)에서 `.tr`로 해석해 전달하므로 캐시가 필요 없다(1회 예약).
  static Future<void> scheduleTrialEnded(
    DateTime fireAt, {
    required String title,
    required String body,
  }) async {
    await _ensureInitialized();
    final scheduled = tz.TZDateTime.from(fireAt, tz.local);
    if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) {
      debugPrint('[LocalAlarm] 체험 종료 알림 스킵 — 이미 지난 시각 $scheduled');
      return;
    }
    final channelName = await NotificationTextCache.get(
        'noti_channel_name', fallback: 'Anbu Alerts');

    await _plugin!.zonedSchedule(
      _trialEndedId,
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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // matchDateTimeComponents 없음 → 1회성 (반복 안 함)
      payload: trialEndedPayload,
    );
    debugPrint('[LocalAlarm] 체험 종료 알림 예약: $scheduled');
  }

  /// 무료체험 종료 1회성 알림 취소 — 구독 성공/탈퇴/모드변경 시 호출.
  static Future<void> cancelTrialEnded() async {
    await _ensureInitialized();
    await _plugin!.cancel(_trialEndedId);
  }

  /// 서버 FCM 푸시 `subject_safety_net` 알림 취소 (Android 전용).
  ///
  /// heartbeat 전송 성공(`_onHeartbeatSent`) 시 호출하여 트레이에 잔존하는
  /// "안부 확인이 필요합니다" 알림을 제거한다.
  ///
  /// 서버는 `subject_safety_net` 발송 시 `tag = "anbu_subject_default"` 로
  /// 고정하므로(data에 subject_user_id/invite_code 없음 → group_id="default"),
  /// getActiveNotifications()로 실제 notification ID를 읽어 취소한다.
  /// 직접 cancel(0, tag:) 하지 않는 이유: FCM이 배정하는 notification ID가
  /// 0이 아닐 수 있어 tag만으로 정확히 매칭되지 않을 수 있기 때문.
  static Future<void> cancelSubjectSafetyNet() async {
    if (Platform.isIOS) return;
    await _ensureInitialized();
    try {
      final active = await _plugin!.getActiveNotifications();
      for (final n in active) {
        if (n.tag == 'anbu_subject_default') {
          await _plugin!.cancel(n.id ?? 0, tag: n.tag);
          debugPrint('[LocalAlarm] subject_safety_net 알림 취소: id=${n.id}');
        }
      }
    } catch (e) {
      debugPrint('[LocalAlarm] cancelSubjectSafetyNet 실패: $e');
    }
  }

  /// 내부 취소 (schedule 내에서도 호출)
  static Future<void> _cancelInternal() async {
    await _ensureInitialized();
    await _plugin!.cancel(_alarmId);
  }
}
