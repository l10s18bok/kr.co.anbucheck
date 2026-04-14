import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/user_remote_datasource.dart';
import 'package:anbucheck/app/modules/guardian_dashboard/controllers/guardian_dashboard_controller.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 보호자 설정 컨트롤러 — 설정 페이지 UI 전용.
/// heartbeat 전송/예약, G+S 라이프사이클은 [GuardianDashboardController]가 단독 소유한다.
class GuardianSettingsController extends BaseController {
  final _svc = Get.find<GuardianSubjectService>();
  final _tokenDs = TokenLocalDatasource();
  final _userDs = UserRemoteDatasource();

  /// Obx에서 직접 추적 가능하도록 서비스의 observable 노출
  RxList<SubjectItem> get subjects => _svc.subjects;
  RxInt get maxSubjects => _svc.maxSubjects;

  final appVersion = ''.obs;
  final osVersion = ''.obs;
  final isSubscriptionActive = true.obs;
  final subscriptionPlan = ''.obs; // free_trial, yearly, expired
  final subscriptionDaysRemaining = (-1).obs; // -1: 미조회, 0+: 남은 일수

  @override
  void onInit() {
    super.onInit();
    _svc.load();
    _loadAppVersion();
    _loadOsVersion();
    _loadSubscription();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = '${info.version} (${info.buildNumber})';
  }

  Future<void> _loadOsVersion() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      osVersion.value = 'Android ${android.version.release}';
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      osVersion.value = 'iOS ${ios.systemVersion}';
    }
  }

  Future<void> _loadSubscription() async {
    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceToken == null) return;

    try {
      final deviceDs = DeviceRemoteDatasource();
      final data = await deviceDs.getMyDevice(deviceToken);
      final active = data['subscription_active'] as bool? ?? false;
      final plan = data['subscription_plan'] as String? ?? '';
      isSubscriptionActive.value = active;
      subscriptionPlan.value = plan;
      await _tokenDs.saveSubscriptionActive(active);

      // 보호자 구독 남은 일수 조회 (보호자만 엔드포인트 접근 가능)
      try {
        final sub = await deviceDs.getSubscription(deviceToken);
        final days = sub['days_remaining'] as int?;
        if (days != null) subscriptionDaysRemaining.value = days;
      } catch (_) {
        // 대상자이거나 구독 정보 없음 — 무시
      }
    } catch (_) {
      isSubscriptionActive.value = await _tokenDs.getSubscriptionActive();
    }
  }

  // ── 네비게이션 ──

  void goToConnectionManagement() {
    Get.toNamed(AppRoutes.guardianConnectionManagement);
  }

  void goToNotificationSettings() {
    Get.toNamed(AppRoutes.guardianNotificationSettings, arguments: 3);
  }

  /// 계정 탈퇴 — heartbeat 예약 정리는 Dashboard 컨트롤러에 위임
  Future<void> deleteAccount() async {
    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceToken != null) {
      try {
        await _userDs.deleteMe(deviceToken);
      } catch (_) {}
    }

    if (Get.isRegistered<GuardianDashboardController>()) {
      await Get.find<GuardianDashboardController>().cancelHeartbeatSchedules();
    }

    await _tokenDs.clear();
    Get.offAllNamed(AppRoutes.modeSelect);
  }
}
