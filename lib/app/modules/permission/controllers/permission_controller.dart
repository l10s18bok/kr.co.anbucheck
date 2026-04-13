import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/services/fcm_service.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 권한 안내 및 요청 컨트롤러
/// 모드 선택 후 진입, arguments['mode']로 모드 구분
///
/// Android: 알림 → 신체 활동(ACTIVITY_RECOGNITION) 순차 요청
/// iOS: 알림(APNs) → 모션(NSMotionUsageDescription) 순차 요청
/// — permission_handler의 activityRecognition이 플랫폼별로 자동 매핑됨
class PermissionController extends BaseController {
  late final String mode;
  late final bool isAlsoSubject;
  bool get isSubjectMode => mode == 'subject';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    mode = args?['mode'] ?? 'subject';
    isAlsoSubject = args?['isAlsoSubject'] as bool? ?? false;
  }

  bool _isRequesting = false;

  /// [확인] 버튼 → OS 권한 팝업 순차 표시 → 다음 화면 이동
  Future<void> requestPermissions() async {
    if (_isRequesting) return;
    _isRequesting = true;

    try {
      // 1. 알림 권한
      if (Platform.isIOS) {
        await Get.find<FcmService>().requestIosPermission();
      } else {
        final notificationStatus = await Permission.notification.request();
        if (!notificationStatus.isGranted) {
          final retry = await _showNotificationDeniedDialog();
          if (retry) {
            openAppSettings();
            return;
          }
        }
      }

      // 신체 활동 / 모션 권한 (Android: ACTIVITY_RECOGNITION, iOS: NSMotionUsageDescription)
      if (Platform.isAndroid) {
        await Permission.activityRecognition.request();
      } else {
        // iOS: Permission.activityRecognition.request()는 시스템 팝업을 띄우지 않음.
        // CMPedometer 데이터를 실제로 조회해야 최초 1회 모션 권한 팝업이 표시됨.
        try {
          await Pedometer.stepCountStream.first
              .timeout(const Duration(seconds: 3));
        } catch (_) {
          // 거부/미지원/타임아웃 모두 무시 — 팝업만 띄우는 목적
        }
      }

      Get.offNamed(AppRoutes.onboarding, arguments: {'mode': mode});
    } finally {
      _isRequesting = false;
    }
  }

  /// 알림 권한 거부 시 다이얼로그
  Future<bool> _showNotificationDeniedDialog() async {
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
