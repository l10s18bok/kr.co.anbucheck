import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/services/fcm_service.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 권한 안내 및 요청 컨트롤러
/// 모드 선택 후 진입, arguments['mode']로 모드 구분
///
/// 권한 요청 정책:
/// - Android 대상자 / Android G+S 복원(isAlsoSubject=true):
///   알림 + 신체 활동 + 위치(긴급 요청용) 권한을 이 화면에서 한 번에 요청.
///   위치 권한은 긴급 버튼 탭 시점에 Lazy로 요청하면 기존 거부 이력 때문에
///   OS 팝업이 억제되는 문제가 있어 사전 요청으로 전환.
/// - Android 순수 보호자: 알림 권한만 요청 (heartbeat 전송·긴급 요청 없음)
/// - iOS (보호자 전용): 알림(APNs) 권한만 요청. 모션 권한은 G+S 활성화 시점에 요청
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

      // 걸음수 권한: Android 대상자 / G+S 복원(isAlsoSubject=true)만 요청.
      // iOS는 G+S 활성화 시점에 CMPedometer 호출로 요청하므로 여기서는 생략.
      if (Platform.isAndroid && (isSubjectMode || isAlsoSubject)) {
        await Permission.activityRecognition.request();
      }

      // 위치 권한(긴급 도움 요청 첨부용): 대상자 기능이 있는 모든 Android 경로에
      // 사전 요청한다. Lazy로 긴급 버튼 탭 시점에 요청하면 기존 거부 이력 때문에
      // OS 팝업이 억제되고 권한 획득이 실패하는 문제가 발생해 사전 요청으로 전환.
      // 거부 시에도 긴급 요청은 위치 없이 전송되므로 기능 자체는 계속 동작.
      if (Platform.isAndroid && (isSubjectMode || isAlsoSubject)) {
        await Permission.locationWhenInUse.request();
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
        backgroundColor: AppColors.surface,
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
