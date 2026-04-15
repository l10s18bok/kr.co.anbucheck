import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';
import 'package:anbucheck/app/modules/guardian_dashboard/controllers/guardian_dashboard_controller.dart';
import 'package:anbucheck/app/modules/guardian_notifications/controllers/guardian_notifications_controller.dart';
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
/// 오늘의 안부 확인 메시지 로컬 알림 (iOS 전용): 앱 포그라운드 전환만 → 홈 화면에서 미전송 체크 + 자동 전송
/// 보호자 Push 알림: type에 따라 알림 목록 또는 대시보드로 이동
void _handleNotificationTap(String type) {
  switch (type) {
    case 'alert':
    case 'alert_urgent':
    case 'alert_warning':
    case 'alert_caution':
    case 'alert_emergency':
    case 'alert_resolved':
    case 'alert_cleared':
    case 'auto_report':
    case 'manual_report':
    case 'alert_info':
      // 하단 탭과 동일하게 스택 리셋 — toNamed로 push하면 dashboard 컨트롤러가
      // 배경에 살아있어 이후 탭 전환 시 중복 컨트롤러 충돌로 앱이 멈춘다
      if (Get.currentRoute == AppRoutes.guardianNotifications) {
        // 이미 알림 화면이면 스택 유지하되 목록 갱신
        try {
          Get.find<GuardianNotificationsController>().load();
        } catch (_) {}
      } else {
        Get.offAllNamed(AppRoutes.guardianNotifications);
      }
      break;
    case 'heartbeat':
      break;
    case 'gs_deadman':
      // iOS G+S 오늘의 안부 확인 메시지 로컬 알림 탭 → 보호자 대시보드 위에 안전코드 페이지 push
      // 이미 안전코드 페이지면 스택 유지 + 컨트롤러가 즉시 미전송 heartbeat 재확인
      // kill 상태 런치에서는 스택에 Dashboard가 없을 수 있어 offNamedUntil predicate가
      // 매칭되지 않고 SafetyCode가 root가 되어 뒤로가기 불가 — offAllNamed(dashboard)로
      // 스택을 재구성한 뒤 SafetyCode를 push해 [dashboard, safetyCode] 구조 보장.
      // Dashboard 바인딩은 permanent이므로 재등록되지 않아 컨트롤러 race 없음.
      // Dashboard가 heartbeat 미전송 체크를 단독 소유하므로 route와 무관하게
      // Dashboard 컨트롤러(permanent)에 위임. 이미 안전코드 페이지면 스택 유지.
      try {
        Get.find<GuardianDashboardController>().refreshAndSend();
      } catch (_) {}
      if (Get.currentRoute != AppRoutes.guardianSafetyCode) {
        Get.offAllNamed(AppRoutes.guardianDashboard);
        Get.toNamed(AppRoutes.guardianSafetyCode);
      }
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
  /// kill 상태에서 로컬 알림 탭으로 런치된 경우의 payload 캐시
  /// SplashController가 라우팅 완료 후 소비 — addPostFrameCallback 경로는
  /// Splash의 offNamed와 race를 일으켜 최종 스택에서 safetyCode가 날아감
  static String? pendingLaunchNotificationType;

  /// kill 상태에서 FCM 푸시 알림 탭으로 런치된 경우의 type 캐시
  /// SplashController가 dashboard 라우팅 완료 후 소비 — addPostFrameCallback 경로는
  /// Splash의 2초 delay/버전체크보다 먼저 fire되어 알림 페이지로 갔다가
  /// 뒤늦은 offNamed(dashboard)가 덮어쓰는 bounce 문제가 있음
  static String? pendingLaunchFcmType;

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
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('[FCM] iOS 알림 권한 상태: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // APNs 토큰이 준비될 때까지 대기 (최대 5초)
        String? apnsToken;
        for (int i = 0; i < 10; i++) {
          apnsToken = await _messaging.getAPNSToken();
          if (apnsToken != null) break;
          await Future.delayed(const Duration(milliseconds: 500));
        }
        debugPrint('[FCM] APNs 토큰: ${apnsToken != null ? '${apnsToken.substring(0, 20)}...' : 'null'}');

        if (apnsToken != null) {
          await _getToken();
        } else {
          debugPrint('[FCM] APNs 토큰 미발급 — FCM 토큰 발급 불가');
        }
      } else {
        debugPrint('[FCM] iOS 알림 권한 거부됨');
      }
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

    // iOS: AppDelegate에서 MethodChannel로 전달받아 대시보드 갱신 + 알림 탭 라우팅
    if (Platform.isIOS) {
      const channel = MethodChannel('kr.co.anbucheck/fcm');
      channel.setMethodCallHandler((call) async {
        if (call.method == 'onForegroundMessage') {
          debugPrint('[FCM] iOS 포그라운드 알림 수신 → 대시보드 갱신');
          try {
            Get.find<GuardianSubjectService>().refresh();
          } catch (_) {}
        } else if (call.method == 'onNotificationTap') {
          final type = call.arguments?.toString() ?? '';
          debugPrint('[FCM] iOS 알림 탭: $type');
          _handleNotificationTap(type);
        }
      });
    }

    // 백그라운드에서 알림 탭하여 앱 열기
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 앱 종료 상태에서 FCM 푸시 알림 탭하여 앱 열기
    // addPostFrameCallback 경로는 Splash의 delay/버전체크보다 먼저 fire되어
    // 알림 페이지로 갔다가 뒤늦은 offNamed(dashboard)가 덮어쓰는 bounce가 발생
    // → type만 캐시하고 SplashController가 dashboard 이동 직후 소비
    try {
      final initialMessage = await _messaging
          .getInitialMessage()
          .timeout(const Duration(seconds: 3));
      if (initialMessage != null) {
        final type = initialMessage.data['type']?.toString() ?? '';
        if (type.isNotEmpty) {
          pendingLaunchFcmType = type;
        }
      }
    } catch (_) {}

    // 앱 종료 상태에서 로컬 알림 탭하여 앱 열기
    // addPostFrameCallback 경로는 Splash의 라우팅과 race를 일으켜 최종 스택에서
    // safetyCode가 날아가는 문제가 있어, payload만 캐시하고 SplashController가 소비
    try {
      final launchDetails =
          await _localNotifications.getNotificationAppLaunchDetails();
      if (launchDetails != null &&
          launchDetails.didNotificationLaunchApp &&
          launchDetails.notificationResponse != null) {
        final payload = launchDetails.notificationResponse!.payload;
        if (payload != null && payload.isNotEmpty) {
          pendingLaunchNotificationType = payload;
        }
      }
    } catch (_) {}

    return this;
  }

  /// 로컬 알림 플러그인 초기화
  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // iOS 권한은 firebase_messaging에서 관리 — 여기서 요청하면 delegate 충돌
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
      // iOS: APNs 토큰이 있어야 FCM 토큰 발급 가능
      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        debugPrint('[FCM] APNs 토큰 확인: ${apnsToken != null ? '있음' : 'null'}');
        if (apnsToken == null) {
          debugPrint('[FCM] APNs 토큰 없음 — FCM 토큰 발급 건너뜀');
          return;
        }
      }

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

    // 대상자별 그룹화 키 — subject_user_id 우선, 없으면 invite_code, 둘 다 없으면 'default'
    final groupKey = 'anbu_subject_${message.data['subject_user_id'] ?? message.data['invite_code'] ?? 'default'}';

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
          groupKey: groupKey,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          threadIdentifier: groupKey,
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
