import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/services/ad_service.dart';
import 'package:anbucheck/app/core/services/fcm_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
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
        // iOS 시스템 알림 권한 다이얼로그를 닫은 직후 앱이 active 상태로 완전히
        // 복귀하기 전에 requestTrackingAuthorization()을 호출하면 OS가 ATT 다이얼로그를
        // 억제한다. 짧은 대기로 앱 상태가 안정화된 뒤 요청한다.
        await Future.delayed(const Duration(milliseconds: 600));
        // ATT 권한 요청 (iOS 14.5+) — 알림 권한 직후, 사용자가 앱 목적을 먼저 이해한 뒤.
        // 거부해도 앱·heartbeat는 정상 동작하며 비개인화 광고가 표시됨.
        await AppTrackingTransparency.requestTrackingAuthorization();
        // ATT 결과 무관하게 AdMob 초기화 — GADDelayAppMeasurementInit 플래그로 미뤄둔
        // GMA SDK 초기화를 여기서 완료한다. 신규/재설치 사용자용 단일 초기화 경로.
        if (!Get.isRegistered<AdService>()) {
          await Get.putAsync(() => AdService().init(), permanent: true);
        }
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
        // 권한 승인 직후 Google Fit Local Recording 구독을 가장 이른 시점에 선점.
        // SubjectHome.onInit warmUp만 있으면 온보딩 4페이지 클릭 타임만큼 갭이
        // 발생해 D0(설치 당일) 첫 heartbeat 시점에 누적 데이터가 부족할 수 있다.
        // fire-and-forget — 다음 OS 권한 팝업으로 넘어가는 동안 백그라운드 진행.
        HeartbeatService.warmUpStepSubscription();
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
