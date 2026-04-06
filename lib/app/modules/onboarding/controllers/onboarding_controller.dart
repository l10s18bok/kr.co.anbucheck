import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/services/fcm_service.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/data/datasources/local/nickname_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/user_remote_datasource.dart';
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
  final _nicknameDs = NicknameLocalDatasource();
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
    isLoading = true;
    try {
      final deviceId = await _tokenDs.getOrCreateDeviceId();
      final fcmToken = Get.find<FcmService>().token ?? '';
      final platform = Platform.isIOS ? 'ios' : 'android';

      final response = await _userDs.register(
        role: mode,
        deviceId: deviceId,
        fcmToken: fcmToken,
        platform: platform,
      );

      // 기존 기기에 다른 role로 가입 시도 시 다이얼로그
      final existingRole = response['existing_role'] as String?;
      if (existingRole != null) {
        isLoading = false;
        final roleLabel = existingRole == 'subject'
            ? 'onboarding_role_subject'.tr
            : 'onboarding_role_guardian'.tr;
        final newRoleLabel = mode == 'subject'
            ? 'onboarding_role_subject'.tr
            : 'onboarding_role_guardian'.tr;
        // 'keep' | 'change' | null(취소)
        final choice = await Get.dialog<String>(
          barrierDismissible: false,
          AlertDialog(
            title: Text('onboarding_already_registered_title'.tr),
            content: Text(
              'onboarding_already_registered_message'.trParams({
                'roleLabel': roleLabel,
                'newRoleLabel': newRoleLabel,
              }),
            ),
            actions: [
              TextButton(
                onPressed: () => exit(0),
                child: Text('common_cancel'.tr),
              ),
              TextButton(
                onPressed: () => Get.back(result: 'change'),
                child: Text('onboarding_change_mode'.trParams({
                  'newRoleLabel': newRoleLabel,
                })),
              ),
              TextButton(
                onPressed: () => Get.back(result: 'keep'),
                child: Text('onboarding_continue_mode'.trParams({
                  'roleLabel': roleLabel,
                })),
              ),
            ],
          ),
        );

        if (choice == 'keep') {
          isLoading = true;
          await _saveAndNavigate(response, existingRole);
          return;
        }

        // 변경 → 서버 계정 삭제 후 새 모드로 재등록
        isLoading = true;
        final oldToken = response['device_token'] as String?;
        if (oldToken != null) {
          try {
            await _userDs.deleteMe(oldToken);
          } catch (_) {
            // 204 No Content 파싱 오류 무시 — 삭제는 서버에서 완료됨
          }
        }
        await _tokenDs.clear();
        await _nicknameDs.clearAll();
        await completeOnboarding();
        return;
      }

      await _saveAndNavigate(response, mode);
    } catch (e) {
      Get.snackbar(
        'onboarding_registration_failed_title'.tr,
        'onboarding_registration_failed_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading = false;
    }
  }

  Future<void> _saveAndNavigate(Map<String, dynamic> response, String role) async {
    await _tokenDs.saveDeviceToken(response['device_token'] as String);
    await _tokenDs.saveUserId(response['user_id'] as int);
    await _tokenDs.saveUserRole(role);

    if (role == 'subject' && response['invite_code'] != null) {
      await _tokenDs.saveInviteCode(response['invite_code'] as String);
    }

    if (role == 'subject') {
      // 로컬 안전망 알림 예약 (기본 10:00, 매일 반복)
      final (hour, minute) = await _tokenDs.getHeartbeatSchedule();
      await LocalAlarmService.schedule(hour, minute);
      Get.offNamed(AppRoutes.subjectHome);
    } else {
      Get.offNamed(AppRoutes.guardianDashboard);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
