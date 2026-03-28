import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 권한 안내 및 요청 컨트롤러
/// 모드 선택 후 진입, arguments['mode']로 모드 구분
class PermissionController extends BaseController {
  late final String mode;
  bool get isSubjectMode => mode == 'subject';

  @override
  void onInit() {
    super.onInit();
    mode = (Get.arguments as Map<String, dynamic>?)?['mode'] ?? 'subject';
  }

  bool _isRequesting = false;

  /// [확인] 버튼 → OS 권한 팝업 순차 표시 → 다음 화면 이동
  Future<void> requestPermissions() async {
    if (_isRequesting) return;
    _isRequesting = true;

    // 1. 알림 권한 요청
    final notificationStatus = await Permission.notification.request();

    if (!notificationStatus.isGranted) {
      final retry = await _showPermissionDeniedDialog();
      if (retry) {
        openAppSettings();
        return;
      }
    }

    // 2. 대상자 모드 + Android: 활동 인식 권한 요청 (걸음수 감지)
    if (isSubjectMode && Platform.isAndroid) {
      await Permission.activityRecognition.request();
    }

    // 3. 대상자 모드 + Android: 배터리 최적화 제외 요청
    if (isSubjectMode && Platform.isAndroid) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    // 3. 온보딩으로 이동 (공통)
    _isRequesting = false;
    Get.offNamed(AppRoutes.onboarding, arguments: {'mode': mode});
  }

  /// 알림 권한 거부 시 다이얼로그
  Future<bool> _showPermissionDeniedDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('알림 권한이 필요합니다'),
        content: const Text(
          '안부 확인 서비스를 이용하려면 알림 권한이 필요합니다.\n'
          '설정에서 알림 권한을 허용해 주세요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('나중에'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
