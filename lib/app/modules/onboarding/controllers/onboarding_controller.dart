import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/services/fcm_service.dart';
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

  static const int totalPages = 3;

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
        final roleLabel = existingRole == 'subject' ? '대상자' : '보호자';
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('이미 등록된 기기'),
            content: Text(
              '이 기기는 이미 $roleLabel 모드로 등록되어 있습니다.\n$roleLabel 모드로 계속하시겠습니까?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('$roleLabel 모드로 계속'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        // 서버의 기존 role로 진행
        await _saveAndNavigate(response, existingRole);
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
