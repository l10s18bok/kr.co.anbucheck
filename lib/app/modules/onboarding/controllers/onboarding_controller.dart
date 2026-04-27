import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/services/fcm_service.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/user_remote_datasource.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/modules/safety_home/controllers/safety_home_role.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 온보딩 컨트롤러 (공통)
/// 서비스 소개 후 사용자 등록(API) → 모드별 홈으로 이동
class OnboardingController extends BaseController {
  final pageController = PageController();
  final _currentPage = 0.obs;
  int get currentPage => _currentPage.value;

  late final String mode;

  static const int totalPages = 4;

  final _tokenDs = TokenLocalDatasource();
  final _userDs = UserRemoteDatasource();

  @override
  void onInit() {
    super.onInit();
    mode = (Get.arguments as Map<String, dynamic>?)?['mode'] ?? 'subject';
  }

  void onPageChanged(int page) {
    _currentPage.value = page;
  }

  void nextPage() {
    if (_currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  /// 온보딩 완료 → 서버 사용자 등록 → 로컬 저장 → 홈 이동
  Future<void> completeOnboarding() async {
    // 재진입 가드: [시작하기] 더블탭 시 POST /users가 두 번 발사되어
    // 서버가 device_token을 회전시키면서 첫 토큰이 즉시 무효화되는 이슈 방지
    if (isLoading) return;
    isLoading = true;
    try {
      final deviceId = await _tokenDs.getOrCreateDeviceId();
      final fcmToken = Get.find<FcmService>().token ?? '';
      final platform = Platform.isIOS ? 'ios' : 'android';
      final osVersion = await _getOsVersion();

      final response = await _userDs.register(
        role: mode,
        deviceId: deviceId,
        fcmToken: fcmToken,
        platform: platform,
        osVersion: osVersion,
      );

      await _saveAndNavigate(response, mode);
    } catch (e) {
      AppSnackbar.show(
        'onboarding_registration_failed_title'.tr,
        'onboarding_registration_failed_message'.tr,
      );
    } finally {
      isLoading = false;
    }
  }

  Future<void> _saveAndNavigate(Map<String, dynamic> response, String role) async {
    await _tokenDs.saveDeviceToken(response['device_token'] as String);
    await _tokenDs.saveUserId(response['user_id'] as int);
    await _tokenDs.saveUserRole(role);

    // invite_code가 있으면 저장 (대상자 또는 G+S 재설치 복원)
    if (response['invite_code'] != null) {
      await _tokenDs.saveInviteCode(response['invite_code'] as String);
      if (role == 'guardian') {
        // G+S 복원: 대상자 기능 활성화 (WorkManager/LocalAlarm은 대시보드 진입 시 처리)
        await _tokenDs.saveIsAlsoSubject(true);
      }
    }

    // 등록 완료 후 FCM 토큰 서버 갱신 (등록 시 토큰이 아직 미발급이었을 수 있음)
    try {
      final fcm = Get.find<FcmService>();
      if (fcm.token != null) {
        await DeviceRemoteDatasource().updateFcmToken(
          response['device_token'] as String,
          fcm.token!,
        );
      }
    } catch (_) {}

    if (role == 'subject') {
      Get.offNamed(AppRoutes.safetyHome,
          arguments: {'role': HomeRole.subject});
    } else {
      Get.offNamed(AppRoutes.guardianDashboard);
    }
  }

  Future<String> _getOsVersion() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return 'Android ${android.version.release}';
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return 'iOS ${ios.systemVersion}';
    }
    return '';
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
