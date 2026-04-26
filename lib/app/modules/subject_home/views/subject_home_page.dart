import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/core/widgets/heartbeat_schedule_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:anbucheck/app/core/widgets/banner_ad_widget.dart';
import 'package:anbucheck/app/core/utils/back_press_handler.dart';
import 'package:anbucheck/app/core/utils/constants.dart';
import 'package:anbucheck/app/core/services/theme_service.dart';
import 'package:anbucheck/app/modules/subject_home/controllers/subject_home_controller.dart';

/// 대상자 홈 페이지 — 시안 _9 기준
/// AppBar(메뉴, 프로필) + 안전코드 + 상태카드 + Bento그리드 + 액션버튼 + 광고배너
class SubjectHomePage extends GetWidget<SubjectHomeController> {
  const SubjectHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    controller.loadAppVersion();
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) BackPressHandler.onBackPressed();
      },
      child: Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.surface,
      drawer: _buildDrawer(scaffoldKey),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.onSurface, size: 24.w),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text('app_name'.tr, style: AppTextTheme.headlineSmall()),
        actions: [
          Obx(() {
            if (controller.guardianCount == 0) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () => AppSnackbar.message(
                'subject_home_guardian_count'.trParams({'count': '${controller.guardianCount}'}),
              ),
              child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: const Color(0xFFE0F2F1),
                    child: Icon(Icons.person, size: 20.w, color: const Color(0xFF00685E)),
                  ),
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
            );
          }),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
        onRefresh: controller.pullToRefresh,
        color: const Color(0xFF00685E),
        child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.vxs),

            // 안전 코드 공유 안내
            Text(
              'subject_home_share_title'.tr,
              style: AppTextTheme.headlineMedium(
                color: Get.find<ThemeService>().isDarkMode.value
                    ? const Color(0xFF80CBC4)
                    : const Color(0xFF00685E),
              ),
            ),
            SizedBox(height: AppSpacing.vsm),

            // Safety Share Code 카드
            _buildSafetyCodeCard(),
            SizedBox(height: AppSpacing.vlg),

            // 마지막 안부 확인 상태 카드
            _buildLastCheckCard(),
            SizedBox(height: AppSpacing.vlg),

            // 지금 바로 안전 보고하기 버튼
            _buildReportButton(),
            SizedBox(height: AppSpacing.vlg),

            // 안부 확인 시각 변경 버튼
            Obx(
              () => HeartbeatScheduleTile(
                heartbeatTime: controller.heartbeatTime.value,
                onTap: controller.showTimePickerDialog,
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
            SizedBox(height: AppSpacing.vlg),

            // 긴급 도움 요청 버튼
            _buildEmergencyButton(),
            _buildLocationPermissionWarning(),
            SizedBox(height: AppSpacing.vlg),

            // 광고 배너
            const BannerAdWidget(),
            SizedBox(height: AppSpacing.vlg),
          ],
        ),
      ),
      ),
      ),
    ),
    );
  }

  /// Safety Share Code 카드
  Widget _buildSafetyCodeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          AppSpacing.sp4, AppSpacing.sp4, AppSpacing.sp4, AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Obx(
        () => Column(
          children: [
            // SAFETY SHARE CODE 헤더 + 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'SAFETY SHARE CODE',
                    style: AppTextTheme.labelMedium(
                      color: AppColors.textTertiary,
                      fw: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
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
            // 초대 코드 (가운데 정렬)
            Text(
              controller.inviteCode.isNotEmpty ? controller.inviteCode : '---  ----',
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

  /// 안부 확인 상태 카드 (보고 완료 / 보고 예정 / 보고 대기 중 동적 표시)
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
          : (state == 'waiting' ? const Color(0xFFE65100) : const Color(0xFF00685E));

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Get.find<ThemeService>().isDarkMode.value
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
                    style: AppTextTheme.bodyMedium(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    controller.checkCardBody,
                    style: AppTextTheme.headlineSmall(color: textColor, fw: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 긴급 도움 요청 버튼
  Widget _buildEmergencyButton() {
    return Obx(() {
      final sending = controller.isSendingEmergency;
      final disabled = controller.guardianCount == 0;
      return GestureDetector(
        onTap: (sending || disabled) ? null : () => _showEmergencyConfirm(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
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
                    Icon(Icons.volunteer_activism_rounded, size: 24.w, color: const Color(0xFFB71C1C)),
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

  /// 위치 권한 거부 시 긴급 버튼 아래 경고 텍스트.
  /// 탭 시 컨트롤러가 재요청 또는 설정 이동을 수행한다.
  Widget _buildLocationPermissionWarning() {
    return Obx(() {
      if (!controller.locationPermissionDenied.value) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: EdgeInsets.only(top: AppSpacing.md),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: controller.requestLocationPermissionAgain,
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
                      'location_permission_warning'.tr,
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

  /// 긴급 도움 요청 확인 다이얼로그
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

  /// 지금 바로 안전 보고하기 버튼
  Widget _buildReportButton() {
    return Obx(() {
      final sending = controller.isReporting;
      final disabled = controller.guardianCount == 0;
      return GestureDetector(
        onTap: (sending || disabled) ? null : controller.reportNow,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
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
                      child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  else
                    Icon(Icons.verified_user_rounded, size: 24.w, color: Colors.white),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      sending ? 'subject_home_report_loading'.tr : 'subject_home_report_button'.tr,
                      style: AppTextTheme.headlineSmall(color: Colors.white, fw: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                'subject_home_report_desc'.tr,
                style: AppTextTheme.bodySmall(color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Navigation Drawer
  Widget _buildDrawer(GlobalKey<ScaffoldState> scaffoldKey) {
    final screenHeight = MediaQuery.of(Get.context!).size.height;

    return Drawer(
      backgroundColor: AppColors.surface.withValues(alpha: 0.92),
      child: Row(
        children: [
          Expanded(
            child: SafeArea(
        child: Column(
          children: [
            // 헤더 영역 (화면 1/3)
            Container(
              height: screenHeight / 3,
              width: double.infinity,
              color: Get.find<ThemeService>().isDarkMode.value
                  ? AppColors.surface
                  : const Color(0xFFB2DFDB),
              child: Stack(
                children: [
                  // 닫기 버튼 (우상단 끝)
                  Positioned(
                    top: 4.h,
                    right: 4.w,
                    child: GestureDetector(
                      onTap: () => scaffoldKey.currentState?.closeDrawer(),
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Icon(Icons.close_rounded, size: 28.w, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ),
                  // 센터 콘텐츠
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 48.r,
                          backgroundColor: Get.find<ThemeService>().isDarkMode.value
                              ? const Color(0xFF00695C)
                              : const Color(0xFF80CBC4),
                          child: Icon(Icons.person, size: 56.w, color: Colors.white),
                        ),
                        SizedBox(height: AppSpacing.md),
                        Obx(() => Text(
                          controller.inviteCode.isNotEmpty
                              ? controller.inviteCode
                              : '---  ----',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w800,
                            color: controller.inviteCode.isNotEmpty
                                ? (Get.find<ThemeService>().isDarkMode.value
                                    ? Colors.white
                                    : const Color(0xFF00685E))
                                : AppColors.textTertiary,
                            letterSpacing: 1.5,
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.surfaceContainerHigh, height: 1),

            // 다크모드 전환
            Obx(() {
              final themeSvc = Get.find<ThemeService>();
              final isDark = themeSvc.isDarkMode.value;
              return ListTile(
                leading: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  size: 22.w,
                  color: AppColors.onSurfaceVariant,
                ),
                title: Text(
                  isDark ? 'drawer_light_mode'.tr : 'drawer_dark_mode'.tr,
                  style: AppTextTheme.bodyLarge(),
                ),
                onTap: () {
                  scaffoldKey.currentState?.closeDrawer();
                  Future.delayed(const Duration(milliseconds: 300), themeSvc.toggle);
                },
              );
            }),

            Divider(color: AppColors.surfaceContainerHigh, height: 1),

            // 가족 안부 관리 기능 추가 (S → G+S 전환)
            ListTile(
              leading: Icon(Icons.family_restroom_rounded,
                  size: 22.w, color: const Color(0xFF4355B9)),
              title: Text('drawer_enable_guardian'.tr,
                  style: AppTextTheme.bodyLarge(color: const Color(0xFF4355B9))),
              onTap: () {
                scaffoldKey.currentState?.closeDrawer();
                Future.delayed(const Duration(milliseconds: 300),
                    () => _showSwitchToGuardianConfirm());
              },
            ),

            Divider(color: AppColors.surfaceContainerHigh, height: 1),

            // 법적 문서 링크
            ListTile(
              leading: Icon(Icons.description_outlined, size: 22.w, color: AppColors.onSurfaceVariant),
              title: Text('drawer_privacy_policy'.tr, style: AppTextTheme.bodyLarge()),
              trailing: Icon(Icons.open_in_new_rounded, size: 18.w, color: AppColors.onSurfaceVariant),
              onTap: () => launchUrl(Uri.parse(AppConstants.privacyPolicyUrl), mode: LaunchMode.externalApplication),
            ),
            ListTile(
              leading: Icon(Icons.gavel_rounded, size: 22.w, color: AppColors.onSurfaceVariant),
              title: Text('drawer_terms'.tr, style: AppTextTheme.bodyLarge()),
              trailing: Icon(Icons.open_in_new_rounded, size: 18.w, color: AppColors.onSurfaceVariant),
              onTap: () => launchUrl(Uri.parse(AppConstants.termsOfServiceUrl), mode: LaunchMode.externalApplication),
            ),

            const Spacer(),

            const Divider(height: 1),

            // 탈퇴 메뉴 (하단)
            ListTile(
              leading: Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22.w),
              title: Text('drawer_withdraw'.tr, style: AppTextTheme.bodyLarge(color: Colors.redAccent)),
              onTap: () => _showDeleteConfirm(scaffoldKey),
            ),

            // 앱 버전
            Padding(
              padding: EdgeInsets.only(
                  bottom: AppSpacing.lg, top: AppSpacing.sm,
                  right: AppSpacing.horizontalMargin),
              child: Align(
                alignment: Alignment.centerRight,
                child: Obx(() => Text(
                  'v${controller.appVersion.value}',
                  style: AppTextTheme.bodySmall(color: AppColors.textTertiary),
                )),
              ),
            ),
          ],
        ),
      ),
          ),
          Container(
            width: 1,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  /// S → G+S 전환 안내 다이얼로그
  void _showSwitchToGuardianConfirm() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text('s_to_gs_dialog_title'.tr,
                  style: AppTextTheme.headlineSmall(
                      fw: FontWeight.w700,
                      color: const Color(0xFF1A1C1C))),
            ),
            GestureDetector(
              onTap: () => Get.back(),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(Icons.close_rounded,
                    size: 24.w, color: const Color(0xFF3F4948)),
              ),
            ),
          ],
        ),
        content: Text('s_to_gs_dialog_body'.tr,
            style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948))),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              controller.switchToGuardian();
            },
            child: Text('s_to_gs_dialog_confirm'.tr,
                style: AppTextTheme.bodyMedium(color: const Color(0xFF4355B9))),
          ),
        ],
      ),
    );
  }

  /// 탈퇴 확인 다이얼로그
  void _showDeleteConfirm(GlobalKey<ScaffoldState> scaffoldKey) {
    scaffoldKey.currentState?.closeDrawer();
    Get.dialog(
      AlertDialog(
        title: Text('drawer_withdraw'.tr, style: AppTextTheme.headlineSmall(
            fw: FontWeight.w700, color: const Color(0xFF1A1C1C))),
        content: Text('drawer_withdraw_message'.tr,
            style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948))),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('common_cancel'.tr, style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948))),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAccount();
            },
            child: Text('drawer_withdraw'.tr, style: AppTextTheme.bodyMedium(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
