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
        final roleLabel = existingRole == 'subject' ? '보호 대상자' : '보호자';
        final newRoleLabel = mode == 'subject' ? '보호 대상자' : '보호자';
        // 'keep' | 'change' | null(취소)
        final choice = await Get.dialog<String>(
          barrierDismissible: false,
          AlertDialog(
            title: const Text('이미 등록된 기기'),
            content: Text(
              '이 기기는 이미 $roleLabel 모드로 등록되어 있습니다.\n'
              '$roleLabel 모드로 계속하시겠습니까?\n\n'
              '아니면 $newRoleLabel 모드로 변경하시겠습니까?\n'
              '변경하시면 기존 저장 내용은 모두 삭제됩니다.',
            ),
            actions: [
              TextButton(
                onPressed: () => exit(0),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Get.back(result: 'change'),
                child: Text('$newRoleLabel 모드로 변경'),
              ),
              TextButton(
                onPressed: () => Get.back(result: 'keep'),
                child: Text('$roleLabel 모드로 계속'),
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
          await _userDs.deleteMe(oldToken);
        }
        await _tokenDs.clear();
        await _nicknameDs.clearAll();
        await completeOnboarding();
        return;
      }

      await _saveAndNavigate(response, mode);
    } catch (e) {
      Get.snackbar(
        '등록 실패',
        '서버에 연결할 수 없습니다. 잠시 후 다시 시도해 주세요.',
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
