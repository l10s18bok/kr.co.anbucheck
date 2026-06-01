import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tzlib;
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/utils/notification_text_cache.dart';
import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/services/fcm_service.dart';
import 'package:anbucheck/app/core/services/iap_service.dart';
import 'package:anbucheck/app/core/services/subscription_service.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/version_remote_datasource.dart';
import 'package:anbucheck/app/modules/safety_home/controllers/safety_home_role.dart';
import 'package:anbucheck/app/routes/app_pages.dart';
import 'package:anbucheck/firebase_options.dart';

/// Splash 컨트롤러
/// 흐름: 네이티브 스플래시 제거 → 서비스 초기화 → 버전 체크 → 홈 or 모드 선택
class SplashController extends BaseController {
  final _tokenDs = TokenLocalDatasource();
  final _versionDs = VersionRemoteDatasource();

  /// 앱 현재 버전 (pubspec.yaml과 일치하도록 유지)
  static const String _appVersion = '1.1.0';

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    // 네이티브 스플래시 제거 → Flutter Splash 화면 표시
    FlutterNativeSplash.remove();

    // 서비스 초기화 + 최소 스플래시 시간 보장 (애니메이션 1회 완료)
    await Future.wait([
      _initServices(),
      Future.delayed(const Duration(milliseconds: 2000)),
    ]);

    // 1. 버전 체크 (실패해도 계속 진행)
    final forceUpdate = await _checkVersion();
    if (forceUpdate) return;

    // 2. 기등록 여부 확인 → 해당 홈으로 이동
    final deviceToken = await _tokenDs.getDeviceToken();
    final userRole = await _tokenDs.getUserRole();

    if (deviceToken != null && userRole != null) {
      if (userRole == 'subject') {
        Get.offNamed(AppRoutes.safetyHome,
            arguments: {'role': HomeRole.subject});
      } else {
        Get.offNamed(AppRoutes.guardianDashboard);
        // 로컬 안전망 알림(iOS `gs_deadman` / Android `safety_net`·`send_failed`) 탭으로
        // kill 상태 런치된 경우: dashboard를 base로 두고 safety_home을 그 위에 push
        // (뒤로가기 시 dashboard 복귀). 미전송 heartbeat 재전송 + 안내 다이얼로그는
        // Dashboard 컨트롤러 onResumed가 처리. 포그라운드/백그라운드 경로
        // (_routeToSafetyHome)와 동일하게 safety_home으로 통일한다.
        final pendingTap = FcmService.pendingLaunchNotificationType;
        if (pendingTap == LocalAlarmService.alarmPayload ||
            pendingTap == LocalAlarmService.safetyNetPayload ||
            pendingTap == LocalAlarmService.sendFailedPayload) {
          FcmService.pendingLaunchNotificationType = null;
          Get.toNamed(AppRoutes.safetyHome,
              arguments: {'role': HomeRole.guardianSubject});
        }
        // kill 상태에서 FCM 푸시 알림 탭으로 런치된 경우:
        // dashboard를 base로 두고 알림 목록을 그 위에 push (뒤로가기 시 dashboard 복귀).
        // emergency 포함 모든 FCM 푸시는 알림 목록으로 이동 — 지도 직행 없음
        // (지도는 알림 목록의 [위치 보기] 버튼이 유일 진입점). 포그라운드/백그라운드
        // 경로(_handleNotificationTap)와 동일하게 통일한다.
        final pendingFcm = FcmService.pendingLaunchFcmType;
        if (pendingFcm != null) {
          FcmService.pendingLaunchFcmType = null;

          // 구독 만료/Grace Period(`subscription_*`)는 여기서 라우팅하지 않는다 —
          // kill 런치 시 기본 진입점인 대시보드에 머물러 구독 만료 배너([구독하기])가
          // 그대로 노출된다(기존 동작 유지). 그 외 모든 푸시는 알림 목록으로.
          const guardianAlertTypes = {
            'alert', 'alert_urgent', 'alert_warning', 'alert_caution',
            'alert_emergency', 'alert_resolved', 'alert_cleared',
            'auto_report', 'manual_report', 'alert_info',
          };
          if (guardianAlertTypes.contains(pendingFcm)) {
            Get.toNamed(AppRoutes.guardianNotifications);
          } else if (pendingFcm == 'subject_safety_net') {
            // G+S 대상자 본인 안부유도 푸시(서버, Android)로 kill 런치된 경우 —
            // gs_deadman/safety_net 로컬 알림과 동일하게 dashboard를 base로 두고
            // safety_home을 push. 미전송 heartbeat 재전송 + 안내 다이얼로그는
            // Dashboard 컨트롤러 onResumed가 처리(플래그 set).
            FcmService.pendingSafetyNetDialog = true;
            Get.toNamed(AppRoutes.safetyHome,
                arguments: {'role': HomeRole.guardianSubject});
          }
        }
      }

    } else {
      // iOS는 보호자 전용 — 모드 선택 스킵, 바로 권한 화면으로 이동
      if (Platform.isIOS) {
        Get.offNamed(AppRoutes.permission, arguments: {'mode': 'guardian'});
      } else {
        Get.offNamed(AppRoutes.modeSelect);
      }
    }
  }

  /// 기존 main()에서 수행하던 무거운 초기화를 Splash 화면에서 처리
  Future<void> _initServices() async {
    // timezone 초기화
    tz.initializeTimeZones();
    try {
      final localTzName = await FlutterTimezone.getLocalTimezone();
      tzlib.setLocalLocation(tzlib.getLocation(localTzName));
    } catch (_) {
      tzlib.setLocalLocation(tzlib.getLocation('Asia/Seoul'));
    }

    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // HTTP 클라이언트 초기화
    ApiClientFactory.init(type: HttpClientType.getConnect);

    // FCM 백그라운드 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // WorkManager 초기화 — main()으로 이동 (앱 종료 후에도 콜백 등록 보장)

    // FCM 서비스 초기화
    await Get.putAsync(() => FcmService().init());

    // 인앱 결제 — purchaseStream은 앱 재시작 시 pending 트랜잭션을 재발행하므로
    // 보호자/대상자 모드 분기 이전에 등록해야 사용자가 UI로 진입하기 전에도
    // 콜백이 누락되지 않는다. (대상자 모드면 큐가 비어있어 비용 0)
    await Get.putAsync(() => IapService().init(), permanent: true);

    // 구독 활성 상태 단일 소스 — 보호자 모니터링(대시보드·알림) 게이트.
    // 영속값으로 init하여 만료 사용자가 콜드 스타트 시 곧바로 잠금 상태가 되게 한다.
    await Get.putAsync(() => SubscriptionService().init(), permanent: true);

    // iOS 로컬 알림 텍스트 캐시 (백그라운드 isolate에서 .tr 사용 불가 → 캐시)
    await NotificationTextCache.cacheAll();

  }

  /// 버전 체크 — 강제 업데이트 필요 시 true 반환
  Future<bool> _checkVersion() async {
    final platform = Platform.isIOS ? 'ios' : 'android';
    final data = await _versionDs.checkVersion(platform, _appVersion);
    if (data == null) return false;

    final forceUpdate = data['force_update'] as bool? ?? false;
    final latestVersion = data['latest_version'] as String? ?? _appVersion;
    final storeUrl = data['store_url'] as String? ?? '';

    if (forceUpdate) {
      await _showForceUpdateDialog(latestVersion, storeUrl);
      return true;
    }

    // 선택적 업데이트 안내는 운영 인터페이스가 정해질 때까지 비활성화
    return false;
  }

  Future<void> _showForceUpdateDialog(String version, String storeUrl) async {
    await Get.dialog(
      AlertDialog(
        title: Text('update_required_title'.tr),
        content: Text('update_required_message'.trParams({'version': version})),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: url_launcher로 스토어 이동
            },
            child: Text('update_button'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

}
