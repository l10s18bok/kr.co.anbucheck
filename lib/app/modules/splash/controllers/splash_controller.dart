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
import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/services/fcm_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/version_remote_datasource.dart';
import 'package:anbucheck/app/core/utils/notification_text_cache.dart';
import 'package:anbucheck/app/routes/app_pages.dart';
import 'package:anbucheck/firebase_options.dart';

/// Splash 컨트롤러
/// 흐름: 네이티브 스플래시 제거 → 서비스 초기화 → 버전 체크 → 홈 or 모드 선택
class SplashController extends BaseController {
  final _tokenDs = TokenLocalDatasource();
  final _versionDs = VersionRemoteDatasource();

  /// 앱 현재 버전 (pubspec.yaml과 일치하도록 유지)
  static const String _appVersion = '1.0.0';

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
        Get.offNamed(AppRoutes.subjectHome);
      } else {
        Get.offNamed(AppRoutes.guardianDashboard);
      }
    } else {
      Get.offNamed(AppRoutes.modeSelect);
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

    // WorkManager 초기화
    await HeartbeatWorkerService.init();

    // FCM 서비스 초기화
    await Get.putAsync(() => FcmService().init());

    // 로컬 알림 번역 문자열 캐시 (백그라운드 isolate용)
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

    // 선택적 업데이트 안내 (건너뛰기 가능)
    if (latestVersion != _appVersion) {
      _showOptionalUpdateSnackbar(latestVersion);
    }
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

  void _showOptionalUpdateSnackbar(String version) {
    Get.snackbar(
      'update_available_title'.tr,
      'update_available_message'.trParams({'version': version}),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: Text('common_later'.tr),
      ),
    );
  }
}
