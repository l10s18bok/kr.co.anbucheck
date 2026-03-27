import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
import 'package:anbucheck/app/data/datasources/local/notification_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';
import 'package:anbucheck/app/modules/subject_home/controllers/subject_home_controller.dart';
import 'package:anbucheck/app/routes/app_pages.dart';
import 'package:anbucheck/firebase_options.dart';

/// FCM 백그라운드 메시지 핸들러 (top-level 함수 필수)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] 백그라운드 메시지 수신: ${message.messageId}');

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final type = message.data['type'];

  // heartbeat 관련 처리 (대상자 모드 전용)
  if (type == 'heartbeat_trigger' || type == 'schedule_updated') {
    ApiClientFactory.init(type: HttpClientType.getConnect);
    final role = await TokenLocalDatasource().getUserRole();
    if (role != 'subject') return;

    if (type == 'heartbeat_trigger') {
      await HeartbeatService().execute();
    } else {
      final hour = int.tryParse(message.data['hour'] ?? '') ?? 9;
      final minute = int.tryParse(message.data['minute'] ?? '') ?? 30;
      await TokenLocalDatasource().saveHeartbeatSchedule(hour, minute);
      debugPrint('[FCM] heartbeat 스케줄 갱신: $hour:${minute.toString().padLeft(2, '0')}');
    }
    return;
  }

  // 보호자 알림: 탭하지 않아도 로컬 DB에 저장 (Android 백그라운드/종료 상태)
  // iOS는 notification+data 메시지에서 백그라운드 핸들러 호출이 보장되지 않음
  final notification = message.notification;
  if (notification == null) return;

  const skipTypes = {'wellbeing_check'};
  if (skipTypes.contains(type)) return;

  final level = switch (type) {
    'alert_urgent'  => 'urgent',
    'alert_warning' => 'warning',
    'alert_caution' => 'caution',
    _               => 'info', // alert_resolved, auto_report, manual_report, alert_info
  };

  // 백그라운드에서는 FCM data의 invite_code 사용 (없으면 null)
  await NotificationLocalDatasource().insert({
    'title': notification.title ?? '',
    'body': notification.body ?? '',
    'alert_level': level,
    'invite_code': message.data['invite_code'],
    'received_at': DateTime.now().toIso8601String(),
    'is_read': 0,
  });
  debugPrint('[FCM] 백그라운드 알림 저장: $type');
}

/// 로컬 알림 탭 핸들러 (top-level 함수 필수)
@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(NotificationResponse response) {
  final payload = response.payload;
  if (payload == null) return;
  _handleNotificationTap(payload);
}

/// 알림 탭 시 라우팅
void _handleNotificationTap(String type) {
  switch (type) {
    case 'alert':
    case 'alert_urgent':
    case 'alert_warning':
    case 'alert_caution':
      Get.toNamed(AppRoutes.guardianNotifications);
      break;
    case 'alert_resolved':
    case 'auto_report':
    case 'manual_report':
    case 'alert_info':
      Get.toNamed(AppRoutes.guardianDashboard);
      break;
    case 'heartbeat':
      Get.toNamed(AppRoutes.subjectHome);
      break;
    default:
      break;
  }
}

/// FCM 푸시 알림 서비스
/// - 토큰 발급 및 갱신 관리
/// - 포그라운드: flutter_local_notifications로 시스템 알림 표시
/// - 백그라운드/종료: 시스템 알림 자동 표시
/// - 알림 탭 시 라우팅
class FcmService extends GetxService {
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _notificationDs = NotificationLocalDatasource();

  /// Android 알림 채널
  static const _androidChannel = AndroidNotificationChannel(
    'anbu_alerts',
    '안부 알림',
    description: '안부 확인 서비스 알림',
    importance: Importance.high,
  );

  /// FCM 토큰
  final _token = Rxn<String>();
  String? get token => _token.value;

  /// 초기화
  Future<FcmService> init() async {
    // iOS: APNs 권한 요청
    if (Platform.isIOS) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // 로컬 알림 초기화
    await _initLocalNotifications();

    // FCM 토큰 발급
    await _getToken();

    // 토큰 갱신 리스너
    _messaging.onTokenRefresh.listen((newToken) {
      _token.value = newToken;
      _sendTokenToServer(newToken);
    });

    // iOS 포그라운드 알림 표시 설정
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 포그라운드 메시지 수신
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 백그라운드에서 알림 탭하여 앱 열기
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 앱 종료 상태에서 알림 탭하여 앱 열기
    // addPostFrameCallback으로 GetX 라우터가 준비된 후 처리
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleMessageOpenedApp(initialMessage);
      });
    }

    return this;
  }

  /// 로컬 알림 플러그인 초기화
  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Android: 알림 채널 생성
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }
  }

  /// FCM 토큰 가져오기
  Future<void> _getToken() async {
    try {
      final fcmToken = await _messaging.getToken();
      _token.value = fcmToken;
      debugPrint('[FCM] 토큰: $fcmToken');

      if (fcmToken != null) {
        _sendTokenToServer(fcmToken);
      }
    } catch (e) {
      debugPrint('[FCM] 토큰 발급 실패: $e');
    }
  }

  /// 서버에 FCM 토큰 전송 — device_token이 없으면(등록 전) 건너뜀
  Future<void> _sendTokenToServer(String fcmToken) async {
    try {
      final deviceToken = await TokenLocalDatasource().getDeviceToken();
      if (deviceToken == null) return;
      await DeviceRemoteDatasource().updateFcmToken(deviceToken, fcmToken);
      debugPrint('[FCM] 서버 토큰 갱신 완료');
    } catch (e) {
      debugPrint('[FCM] 서버 토큰 갱신 실패: $e');
    }
  }

  /// 포그라운드 메시지 처리
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('[FCM] 포그라운드 메시지: ${message.data['type']}');

    // 포그라운드 heartbeat 트리거 (대상자 모드 전용)
    if (message.data['type'] == 'heartbeat_trigger') {
      final role = await TokenLocalDatasource().getUserRole();
      if (role == 'subject') {
        await HeartbeatService().execute();
        try {
          await Get.find<SubjectHomeController>().reloadHeartbeatState();
        } catch (_) {}
      }
      return;
    }

    // schedule_updated: 로컬 저장 (서버가 다음 FCM Silent Push 발송 시각을 변경)
    if (message.data['type'] == 'schedule_updated') {
      final hour = int.tryParse(message.data['hour'] ?? '') ?? 9;
      final minute = int.tryParse(message.data['minute'] ?? '') ?? 30;
      TokenLocalDatasource().saveHeartbeatSchedule(hour, minute);
      debugPrint('[FCM] heartbeat 스케줄 갱신: $hour:${minute.toString().padLeft(2, '0')}');
      return;
    }

    final notification = message.notification;
    if (notification == null) return;

    // 시스템 알림 표시
    _localNotifications.show(
      message.hashCode,
      notification.title ?? '안부',
      notification.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['type'] ?? '',
    );

    // 알림 이력 로컬 저장 + 대시보드 데이터 갱신
    _saveNotification(message);
    _refreshSubjectsIfNeeded(message.data['type']);
  }

  /// 알림 탭하여 앱 열기 처리
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('[FCM] 알림 탭: ${message.data}');
    final type = message.data['type'] ?? '';
    // 백그라운드에서 탭한 알림도 이력 저장
    _saveNotification(message);
    _handleNotificationTap(type);
  }

  /// 보호자 알림 수신 시 GuardianSubjectService 강제 갱신
  /// → ever()로 등록된 GuardianDashboardController가 자동 반응
  void _refreshSubjectsIfNeeded(String? type) {
    const guardianTypes = {
      'auto_report', 'manual_report', 'alert_resolved',
      'alert_info', 'alert_caution', 'alert_warning', 'alert_urgent',
    };
    if (!guardianTypes.contains(type)) return;
    try {
      Get.find<GuardianSubjectService>().refresh();
    } catch (_) {}
  }

  /// 알림 이력을 로컬 DB에 저장
  /// heartbeat_trigger / schedule_updated / wellbeing_check은 저장 제외
  Future<void> _saveNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final type = message.data['type'] ?? '';
    const skipTypes = {'heartbeat_trigger', 'schedule_updated', 'wellbeing_check'};
    if (skipTypes.contains(type)) return;

    final level = switch (type) {
      'alert_urgent'  => 'urgent',
      'alert_warning' => 'warning',
      'alert_caution' => 'caution',
      _               => 'info', // alert_resolved, auto_report, manual_report, alert_info
    };

    // invite_code: FCM data에 포함된 값을 우선 사용
    // 없는 경우 GuardianSubjectService 캐시에서 subject_user_id로 조회
    String? inviteCode = message.data['invite_code'];
    if (inviteCode == null || inviteCode.isEmpty) {
      final subjectUserIdStr = message.data['subject_user_id'];
      if (subjectUserIdStr != null) {
        final subjectUserId = int.tryParse(subjectUserIdStr);
        if (subjectUserId != null) {
          try {
            final subjectService = Get.find<GuardianSubjectService>();
            inviteCode = subjectService.subjects
                .firstWhereOrNull((s) => s.userId == subjectUserId)
                ?.inviteCode;
          } catch (_) {}
        }
      }
    }

    await _notificationDs.insert({
      'title': notification.title ?? '',
      'body': notification.body ?? '',
      'alert_level': level,
      'invite_code': inviteCode,
      'received_at': DateTime.now().toIso8601String(),
      'is_read': 0,
    });
  }

  /// 특정 토픽 구독 (대상자별 알림 채널)
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('[FCM] 토픽 구독: $topic');
  }

  /// 토픽 구독 해제
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('[FCM] 토픽 구독 해제: $topic');
  }
}
