import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/services/fcm_service.dart';
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
    // iOS: Firebase Messaging의 requestPermission()으로 APNs 권한 + FCM 토큰 발급
    // Android: permission_handler로 OS 알림 권한 요청
    if (Platform.isIOS) {
      await Get.find<FcmService>().requestIosPermission();
    } else {
      final notificationStatus = await Permission.notification.request();
      if (!notificationStatus.isGranted) {
        final retry = await _showPermissionDeniedDialog();
        if (retry) {
          _isRequesting = false;
          openAppSettings();
          return;
        }
      }
    }

    // 2. 대상자 모드 + Android: 활동 인식 권한 요청 (걸음수 감지)
    //    OS 다이얼로그 전 사전 안내 다이얼로그 표시
    if (isSubjectMode && Platform.isAndroid) {
      await _showActivityRecognitionRationaleDialog();
      await Permission.activityRecognition.request();
    }

    // 온보딩으로 이동 (공통)
    _isRequesting = false;
    Get.offNamed(AppRoutes.onboarding, arguments: {'mode': mode});
  }

  /// 신체 활동 권한 요청 전 사전 안내 다이얼로그
  Future<void> _showActivityRecognitionRationaleDialog() async {
    await Get.dialog<void>(
      AlertDialog(
        title: Text('permission_activity_dialog_title'.tr),
        content: Text(
          'permission_activity_dialog_message'.tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('common_confirm'.tr),
          ),
        ],
      ),
    );
  }

  /// 알림 권한 거부 시 다이얼로그
  Future<bool> _showPermissionDeniedDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('permission_notification_required_title'.tr),
        content: Text(
          'permission_notification_required_message'.tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common_later'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('permission_go_to_settings'.tr),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
