import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

    // iOS: 정시 `gs_deadman` 일일 알림을 **더 이상 예약하지 않는다.**
    //
    // 그 알림은 "매일 안부를 보내라"는 주 트리거였고, 사용자가 **탭해야** 전송됐다.
    // 이제는 서버가 예약시각 정각에 보내는 트리거 푸시를 Notification Service
    // Extension이 받아 **탭 없이** 전송하므로 그 역할이 사라졌다.
    //
    // 대신 로컬 알림은 **오프라인 전용 최후 보루**로 역할이 바뀐다:
    //   망 있음 → 푸시 도착 → 확장이 전송하고 그날치 폴백 알림을 pending에서 제거
    //   망 없음 → 푸시 자체가 안 옴 → 살아남은 폴백 알림이 "인터넷 연결 확인"으로 발화
    //
    // ⚠️ iOS 로컬 알림은 "망이 없을 때만 뜨게" 만들 수 없다 — 앱이 죽어 있어 조건을
    // 판단할 주체가 없기 때문이다. 그래서 조건을 뒤집어 무조건 심어두고 확장이 지운다.
    // (확장이 다른 프로세스가 심은 pending을 제거할 수 있음은 실측으로 확인됐다 —
    //  .claude/rules/ios_nse_field_notes.md)
    //
    // 재무장 구현은 앱·확장이 공유하는 네이티브 HeartbeatStore에 있다. Dart로 옮기면
    // 확장이 쓰는 규칙과 두 벌이 되어 조용히 어긋난다.
    await _cancelInternal(); // 업그레이드 기기에 남은 gs_deadman 잔존 알림 정리
    try {
      await _iosNotificationChannel.invokeMethod<void>('armOfflineFallback', {
        'hour': heartbeatHour,
        'minute': heartbeatMinute,
      });
      debugPrint('[LocalAlarm] iOS 오프라인 폴백 재무장: $heartbeatHour:${heartbeatMinute.toString().padLeft(2, '0')} +15분, 7일 롤링');
    } catch (e) {
      debugPrint('[LocalAlarm] iOS 오프라인 폴백 재무장 실패: $e');
    }
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
  /// `subject_safety_net` 안전망 알림을 트레이에서 제거한다.
  ///
  /// heartbeat 전송 성공(`_onHeartbeatSent`) 시 호출된다.
  ///
  /// `screen_state` 네이티브 채널의 `cancelNotificationsByTag`를 통해
  /// OS가 실제로 표시 중인 알림의 (tag, id) 쌍을 직접 조회 후 취소한다.
  /// — Firebase가 background에서 표시한 알림이든, 앱 포그라운드 중
  ///   flutter_local_notifications로 표시한 알림이든 id 가정 없이 모두 제거된다.
  /// — `screen_state` 채널은 WorkManager 백그라운드 isolate에서도 동작이
  ///   검증된 경로다 (isInteractive와 동일 메커니즘).
  static const _screenStateChannel = MethodChannel('kr.co.anbucheck/screen_state');

  static Future<void> cancelSubjectSafetyNet() async {
    if (Platform.isIOS) return;
    try {
      final matched = await _screenStateChannel.invokeMethod<int>(
        'cancelNotificationsByTag',
        {'tag': 'anbu_safety_net'},
      );
      debugPrint('[LocalAlarm] cancelSubjectSafetyNet: activeNotifications 매칭=$matched');
    } catch (e) {
      debugPrint('[LocalAlarm] cancelSubjectSafetyNet 실패: $e');
    }
  }

  /// iOS 표시 중인 알림 정리 채널 (AppDelegate에서 등록).
  static const _iosNotificationChannel =
      MethodChannel('kr.co.anbucheck/notifications');

  /// **표시 중인(delivered) 알림만** 트레이에서 일괄 제거한다.
  /// 앱이 포그라운드로 진입할 때(콜드 스타트 / 백그라운드 복귀) 호출 —
  /// 사용자가 알림 하나만 탭해도 나머지 푸시·로컬 알림이 쌓여 있지 않게 한다.
  /// 보호자 경고는 서버 기반 in-app 알림 목록(`GET /notifications`)에 당일 내내
  /// 남으므로 트레이를 비워도 정보 손실이 없다.
  ///
  /// ⚠️ **불변 규칙 — 예약(pending)은 절대 건드리지 않는다.**
  ///   - `FlutterLocalNotificationsPlugin.cancelAll()`을 쓰지 말 것.
  ///     이 API는 표시 중인 알림과 **예약된 알림을 함께** 제거한다.
  ///   - iOS 일일 안전망 알림([schedule], `matchDateTimeComponents.time`)은
  ///     pending 반복 요청으로 살아 있어야 매일 발화하며 iOS G+S의 PRIMARY
  ///     heartbeat 트리거다. 이를 지우면 iOS 안부 전송이 조용히 중단된다.
  ///   - 무료체험 종료 알림([scheduleTrialEnded])도 pending 단발 예약이라 동일.
  ///   따라서 Android는 `NotificationManager.cancelAll()`(posted 전용),
  ///   iOS는 `removeAllDeliveredNotifications()`만 네이티브로 호출한다.
  ///
  /// [cancelSubjectSafetyNet]/[cancelSendFailed]를 대체하지 않는다 —
  /// 그쪽은 WorkManager 백그라운드 isolate(앱 미포그라운드)에서 호출되는 경로다.
  static Future<void> clearDeliveredNotifications() async {
    try {
      if (Platform.isAndroid) {
        await _screenStateChannel
            .invokeMethod<void>('clearDeliveredNotifications');
      } else {
        await _iosNotificationChannel.invokeMethod<void>('clearDelivered');
      }
      debugPrint('[LocalAlarm] 표시 중인 알림 일괄 제거');
    } catch (e) {
      debugPrint('[LocalAlarm] clearDeliveredNotifications 실패: $e');
    }
  }

  /// 내부 취소 (schedule 내에서도 호출)
  static Future<void> _cancelInternal() async {
    await _ensureInitialized();
    await _plugin!.cancel(_alarmId);
  }
}
