import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/core/widgets/heartbeat_schedule_tile.dart';
// import 'package:anbucheck/app/core/widgets/banner_ad_widget.dart'; // 스크린샷용 임시 주석
import 'package:anbucheck/app/core/services/theme_service.dart';
import 'package:anbucheck/app/modules/guardian_safety_code/controllers/guardian_safety_code_controller.dart';

/// 보호자 G+S 모드 안전코드 페이지
///
/// 보호자 설정 또는 iOS 오늘의 안부 확인 메시지 로컬 알림 탭으로 진입. SubjectHomePage와 비슷한 카드
/// 구성을 가지지만 Drawer·탈퇴·모드 선택 복귀 등 대상자 전용 메뉴는 제거했다.
/// 뒤로가기 시 이전 라우트(보통 보호자 설정 또는 대시보드)로 복귀한다.
class GuardianSafetyCodePage extends GetWidget<GuardianSafetyCodeController> {
  const GuardianSafetyCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.onSurface, size: 20.w),
          onPressed: () => Get.back(),
        ),
        title: Text('gs_safety_code_title'.tr,
            style: AppTextTheme.headlineSmall()),
        actions: [
          Obx(() {
            if (!controller.isGuardianConnected) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: () {
                    AppSnackbar.message(
                      'subject_home_guardian_count'.trParams(
                          {'count': '${controller.guardianCount}'}),
                      position: SnackPosition.TOP,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person,
                            size: 20.w, color: const Color(0xFF00685E)),
                        SizedBox(width: 4.w),
                        Text(
                          'x${controller.guardianCount}',
                          style: AppTextTheme.labelMedium(
                            color: const Color(0xFF00685E),
                            fw: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.pullToRefresh,
        color: const Color(0xFF00685E),
        child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.lg),
            Text(
              'subject_home_share_title'.tr,
              style: AppTextTheme.headlineMedium(
                color: Get.find<ThemeService>().isDarkMode.value
                    ? const Color(0xFF80CBC4)
                    : const Color(0xFF00685E),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            _buildSafetyCodeCard(),
            _buildActivityPermissionWarning(),
            SizedBox(height: AppSpacing.lg),
            _buildLastCheckCard(),
            SizedBox(height: AppSpacing.lg),
            _buildReportButton(),
            SizedBox(height: AppSpacing.lg),
            Obx(
              () => HeartbeatScheduleTile(
                heartbeatTime: controller.heartbeatTime.value,
                onTap: controller.isGuardianConnected
                    ? controller.showTimePickerDialog
                    : () {},
                color: Get.find<ThemeService>().isDarkMode.value
                    ? const Color(0xFF80CBC4)
                    : const Color(0xFF00685E),
                timeColor: Get.find<ThemeService>().isDarkMode.value
                    ? Colors.white
                    : null,
                backgroundColor: Get.find<ThemeService>().isDarkMode.value
                    ? const Color(0xFF0A3A2A)
                    : const Color(0xFFE0F2F1),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            _buildEmergencyButton(),
            SizedBox(height: AppSpacing.sp6),
            // const BannerAdWidget(), // 스크린샷용 임시 주석
            // SizedBox(height: AppSpacing.sp6),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildSafetyCodeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.sp4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Obx(
        () => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SAFETY SHARE CODE',
                  style: AppTextTheme.labelMedium(
                    color: AppColors.textTertiary,
                    fw: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: controller.copyInviteCode,
                      child: Container(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 20.w,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    GestureDetector(
                      onTap: controller.shareInviteCode,
                      child: Container(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.share_rounded,
                          size: 20.w,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              controller.inviteCode.isNotEmpty
                  ? controller.inviteCode
                  : '---  ----',
              style: TextStyle(
                fontSize: 40.sp,
                fontWeight: FontWeight.w800,
                color: controller.inviteCode.isNotEmpty
                    ? (Get.find<ThemeService>().isDarkMode.value
                        ? Colors.white
                        : const Color(0xFF00685E))
                    : AppColors.textTertiary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastCheckCard() {
    return Obx(() {
      final state = controller.checkCardState;
      final iconData = state == 'reported'
          ? Icons.check_rounded
          : state == 'waiting'
              ? Icons.hourglass_top_rounded
              : Icons.schedule_rounded;
      final dark = Get.find<ThemeService>().isDarkMode.value;
      final iconBg = state == 'reported'
          ? (dark ? const Color(0xFF00897B) : const Color(0xFF00685E))
          : state == 'waiting'
              ? (dark ? const Color(0xFFFF6D00) : const Color(0xFFE65100))
              : (dark ? const Color(0xFF6A1B9A) : AppColors.surfaceContainerHigh);
      final iconColor = state == 'reported' || state == 'waiting'
          ? Colors.white
          : (dark ? Colors.white : AppColors.onSurfaceVariant);
      final textColor = dark
          ? const Color(0xFFFFD54F)
          : (state == 'waiting'
              ? const Color(0xFFE65100)
              : const Color(0xFF00685E));

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: dark
              ? const Color(0xFF0A3A2A).withValues(alpha: 0.7)
              : const Color(0xFFE8F5E9).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(iconData, size: 28.w, color: iconColor),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.checkCardTitle,
                    style:
                        AppTextTheme.bodyMedium(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    controller.checkCardBody,
                    style: AppTextTheme.headlineSmall(
                        color: textColor, fw: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 걸음수 권한 거부 경고 위젯 (Lazy Permission)
  /// 권한 허용 상태면 SizedBox.shrink()로 공간도 차지하지 않음.
  Widget _buildActivityPermissionWarning() {
    return Obx(() {
      if (!controller.activityPermissionDenied.value) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: EdgeInsets.only(top: AppSpacing.md),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: controller.requestActivityPermissionAgain,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 48.h),
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFB71C1C).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 20.w, color: const Color(0xFFB71C1C)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'gs_activity_permission_denied_warning'.tr,
                      style: AppTextTheme.bodySmall(
                        color: const Color(0xFFB71C1C),
                        fw: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildReportButton() {
    return Obx(() {
      final sending = controller.isReporting;
      final disabled = controller.guardianCount == 0;
      return GestureDetector(
        onTap: (sending || disabled) ? null : controller.reportNow,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: (sending || disabled)
                  ? [const Color(0xFF4A7C78), const Color(0xFF4A7C78)]
                  : [const Color(0xFF00685E), const Color(0xFF008377)],
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (sending)
                    SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  else
                    Icon(Icons.verified_user_rounded,
                        size: 24.w, color: Colors.white),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      sending
                          ? 'subject_home_report_loading'.tr
                          : 'subject_home_report_button'.tr,
                      style: AppTextTheme.headlineSmall(
                          color: Colors.white, fw: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                'subject_home_report_desc'.tr,
                style: AppTextTheme.bodySmall(
                    color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmergencyButton() {
    return Obx(() {
      final sending = controller.isSendingEmergency;
      final disabled = !controller.isGuardianConnected;
      return GestureDetector(
        onTap: (sending || disabled) ? null : () => _showEmergencyConfirm(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: (sending || disabled)
                ? const Color(0xFFFFCDD2)
                : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: (sending || disabled)
                  ? const Color(0xFFE57373)
                  : const Color(0xFFB71C1C),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (sending)
                    SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFFB71C1C),
                      ),
                    )
                  else
                    Icon(Icons.volunteer_activism_rounded,
                        size: 24.w, color: const Color(0xFFB71C1C)),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      sending
                          ? 'subject_home_emergency_loading'.tr
                          : 'subject_home_emergency_button'.tr,
                      style: AppTextTheme.headlineSmall(
                        color: const Color(0xFFB71C1C),
                        fw: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                'subject_home_emergency_desc'.tr,
                style: AppTextTheme.bodySmall(
                  color: const Color(0xFFB71C1C).withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showEmergencyConfirm() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'subject_home_emergency_confirm_title'.tr,
          style: AppTextTheme.headlineSmall(
            fw: FontWeight.w700,
            color: const Color(0xFFB71C1C),
          ),
        ),
        content: Text(
          'subject_home_emergency_confirm_body'.tr,
          style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'common_cancel'.tr,
              style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948)),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.sendEmergency();
            },
            child: Text(
              'subject_home_emergency_confirm_send'.tr,
              style: AppTextTheme.bodyMedium(
                color: const Color(0xFFB71C1C),
                fw: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
