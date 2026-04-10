import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// FCM 백그라운드 메시지 핸들러 (top-level 함수 필수)
/// heartbeat 트리거는 WorkManager/BGTaskScheduler로 전환 — FCM은 보호자 알림만 처리
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] 백그라운드 메시지 수신: ${message.data['type']}');
}

/// 로컬 알림 탭 핸들러 (top-level 함수 필수)
@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(NotificationResponse response) {
  final payload = response.payload;
  if (payload == null) return;
  _handleNotificationTap(payload);
}

/// 알림 탭 시 라우팅
/// 데드맨 알림: 앱 포그라운드 전환만 → 홈 화면에서 미전송 체크 + 자동 전송
/// suspicious 알림: 사용자 생존 응답 — manual=true heartbeat 즉시 재전송
void _handleNotificationTap(String type) {
  switch (type) {
    case 'alert':
    case 'alert_urgent':
    case 'alert_warning':
    case 'alert_caution':
    case 'alert_emergency':
      Get.toNamed(AppRoutes.guardianNotifications);
      break;
    case 'alert_resolved':
    case 'alert_cleared':
    case 'auto_report':
    case 'manual_report':
    case 'alert_info':
      Get.toNamed(AppRoutes.guardianDashboard);
      break;
    case 'heartbeat':
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
  /// Android 알림 채널
  // TODO: i18n — 채널명은 앱 초기화 시점에 생성되므로 .tr이 동작하지 않을 수 있음
  static const _androidChannel = AndroidNotificationChannel(
    'anbu_alerts',
    '안부 알림', // local_notification_channel
    description: '안부 확인 서비스 알림', // local_notification_channel_desc
    importance: Importance.high,
  );

  /// FCM 토큰
  final _token = Rxn<String>();
  String? get token => _token.value;

  /// iOS APNs 권한 요청 + FCM 토큰 재발급
  /// PermissionController에서 알림 권한 허용 후 호출
  Future<void> requestIosPermission() async {
    if (!Platform.isIOS) return;
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await _getToken();
    } catch (e) {
      debugPrint('[FCM] iOS 권한 요청 실패: $e');
    }
  }

  /// 초기화
  Future<FcmService> init() async {
    // 로컬 알림 초기화
    await _initLocalNotifications();

    // FCM 토큰 발급
    // iOS: 권한이 이미 허용된 경우 토큰 발급 시도 (미허용이면 조용히 실패)
    //      최초 권한 요청은 PermissionPage → requestIosPermission()에서 처리
    await _getToken();

    // 토큰 갱신 리스너
    _messaging.onTokenRefresh.listen((newToken) {
      _token.value = newToken;
      _sendTokenToServer(newToken);
    });

    // iOS 포그라운드 알림 표시 설정
    try {
      await _messaging
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          )
          .timeout(const Duration(seconds: 3));
    } catch (_) {}

    // 포그라운드 메시지 수신
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 백그라운드에서 알림 탭하여 앱 열기
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 앱 종료 상태에서 알림 탭하여 앱 열기
    // addPostFrameCallback으로 GetX 라우터가 준비된 후 처리
    try {
      final initialMessage = await _messaging
          .getInitialMessage()
          .timeout(const Duration(seconds: 3));
      if (initialMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleMessageOpenedApp(initialMessage);
        });
      }
    } catch (_) {}

    // 앱 종료 상태에서 로컬 알림 탭하여 앱 열기
    try {
      final launchDetails =
          await _localNotifications.getNotificationAppLaunchDetails();
      if (launchDetails != null &&
          launchDetails.didNotificationLaunchApp &&
          launchDetails.notificationResponse != null) {
        final payload = launchDetails.notificationResponse!.payload;
        if (payload != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleNotificationTap(payload);
          });
        }
      }
    } catch (_) {}

    return this;
  }

  /// 로컬 알림 플러그인 초기화
  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // iOS: 로컬 안전망 알림용 플러그인 공유
    LocalAlarmService.setPlugin(_localNotifications);

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

    final notification = message.notification;
    if (notification == null) return;

    // 시스템 알림 표시
    _localNotifications.show(
      message.hashCode,
      notification.title ?? 'app_name'.tr,
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

    _refreshSubjectsIfNeeded(message.data['type']);
  }

  /// 알림 탭하여 앱 열기 처리
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('[FCM] 알림 탭: ${message.data}');
    final type = message.data['type'] ?? '';
    _handleNotificationTap(type);
  }

  /// 보호자 알림 수신 시 GuardianSubjectService 강제 갱신
  /// → ever()로 등록된 GuardianDashboardController가 자동 반응
  void _refreshSubjectsIfNeeded(String? type) {
    const guardianTypes = {
      'auto_report', 'manual_report', 'alert_resolved', 'alert_cleared',
      'alert_info', 'alert_caution', 'alert_warning', 'alert_urgent',
      'alert_emergency',
    };
    if (!guardianTypes.contains(type)) return;
    try {
      Get.find<GuardianSubjectService>().refresh();
    } catch (_) {}
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
