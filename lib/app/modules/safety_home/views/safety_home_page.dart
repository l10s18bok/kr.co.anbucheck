import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:anbucheck/app/core/services/stability_service.dart';
import 'package:anbucheck/app/core/services/theme_service.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/core/utils/back_press_handler.dart';
import 'package:anbucheck/app/core/utils/constants.dart';
import 'package:anbucheck/app/core/widgets/banner_ad_widget.dart';
import 'package:anbucheck/app/core/widgets/heartbeat_schedule_tile.dart';
import 'package:anbucheck/app/modules/safety_home/controllers/safety_home_base_controller.dart';
import 'package:anbucheck/app/modules/safety_home/controllers/safety_home_role.dart';
import 'package:anbucheck/app/modules/safety_home/controllers/subject_home_controller.dart';
import 'package:anbucheck/app/modules/safety_home/widgets/activity_permission_warning.dart';
import 'package:anbucheck/app/modules/safety_home/widgets/battery_optimization_warning.dart';
import 'package:anbucheck/app/modules/safety_home/widgets/check_state_card.dart';
import 'package:anbucheck/app/modules/safety_home/widgets/emergency_button.dart';
import 'package:anbucheck/app/modules/safety_home/widgets/invite_code_share_card.dart';
import 'package:anbucheck/app/modules/safety_home/widgets/location_permission_warning.dart';
import 'package:anbucheck/app/modules/safety_home/widgets/manual_report_button.dart';

/// 안전 홈 페이지 — S 모드와 G+S 모드 통합 페이지
///
/// `controller.role`에 따라 AppBar/Drawer/PopScope/일부 enabled 조건만 분기.
/// 본문 위젯 구성은 양쪽 100% 공통이며, 활동 권한 경고 위젯이 양쪽 모두 적용된다.
class SafetyHomePage extends GetView<SafetyHomeBaseController> {
  const SafetyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSubject = controller.role == HomeRole.subject;

    // S 전용 초기화: 앱 버전 로드 (Drawer 표시용)
    if (isSubject) {
      (controller as SubjectHomeController).loadAppVersion();
    }

    final scaffoldKey = GlobalKey<ScaffoldState>();

    final scaffold = Scaffold(
      key: isSubject ? scaffoldKey : null,
      backgroundColor: AppColors.surface,
      drawer: isSubject ? _buildDrawer(scaffoldKey) : null,
      appBar: _buildAppBar(scaffoldKey, isSubject),
      body: _buildBody(isSubject),
    );

    // S 모드만 PopScope + BackPressHandler 적용
    if (isSubject) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) BackPressHandler.onBackPressed();
        },
        child: scaffold,
      );
    }
    return scaffold;
  }

  // ── AppBar ─────────────────────────────────────────────────────────

  AppBar _buildAppBar(GlobalKey<ScaffoldState> scaffoldKey, bool isSubject) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: isSubject
          ? IconButton(
              icon: Icon(Icons.menu, color: AppColors.onSurface, size: 24.w),
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
            )
          : IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: AppColors.onSurface, size: 20.w),
              onPressed: () => Get.back(),
            ),
      title: Text(
        isSubject ? 'app_name'.tr : 'gs_safety_code_title'.tr,
        style: AppTextTheme.headlineSmall(),
      ),
      actions: [
        Obx(() {
          // 보호자 수 표시 — S/G+S 가시 조건 차이로 분기
          final visible = isSubject
              ? controller.guardianCount.value > 0
              : controller.isGuardianConnected;
          if (!visible) return const SizedBox.shrink();
          return _buildGuardianBadge(isSubject);
        }),
      ],
    );
  }

  Widget _buildGuardianBadge(bool isSubject) {
    final count = controller.guardianCount.value;
    void onTap() => AppSnackbar.message(
          'subject_home_guardian_count'.trParams({'count': '$count'}),
          position: isSubject ? SnackPosition.BOTTOM : SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

    if (isSubject) {
      // S 디자인: CircleAvatar
      return GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: const Color(0xFFE0F2F1),
                child: Icon(Icons.person,
                    size: 20.w, color: const Color(0xFF00685E)),
              ),
              SizedBox(width: 4.w),
              Text(
                'x$count',
                style: AppTextTheme.labelMedium(
                  color: const Color(0xFF00685E),
                  fw: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // G+S 디자인: Material InkWell pill
    return Padding(
      padding: EdgeInsets.only(right: 16.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
                  'x$count',
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
  }

  // ── Body ──────────────────────────────────────────────────────────

  Widget _buildBody(bool isSubject) {
    return SafeArea(
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

              // 헤더 텍스트
              Obx(() => Text(
                    'subject_home_share_title'.tr,
                    style: AppTextTheme.headlineMedium(
                      color: Get.find<ThemeService>().isDarkMode.value
                          ? const Color(0xFF80CBC4)
                          : const Color(0xFF00685E),
                    ),
                  )),
              SizedBox(height: AppSpacing.vsm),

              // 배터리 사용 제한 해제 권장 (S/G+S 공통, Android 전용)
              // 제한 없음 상태이거나 iOS면 SizedBox.shrink로 공간 미사용
              Obx(() => BatteryOptimizationWarning(
                    needsAction:
                        !Get.find<StabilityService>().batteryUnrestricted.value,
                    onTap: controller.openBatteryOptimizationSettings,
                  )),

              // 안전코드 공유 카드
              Obx(() => InviteCodeShareCard(
                    inviteCode: controller.inviteCode,
                    isDark: Get.find<ThemeService>().isDarkMode.value,
                    onCopy: controller.copyInviteCode,
                    onShare: controller.shareInviteCode,
                  )),

              // 활동 권한 거부 경고 (양쪽 공통 — S 누락 위젯이 통합으로 자동 적용)
              Obx(() => ActivityPermissionWarning(
                    denied: controller.activityPermissionDenied.value,
                    onTap: controller.requestActivityPermissionAgain,
                  )),
              SizedBox(height: AppSpacing.vlg),

              // 안부 확인 상태 카드
              Obx(() => CheckStateCard(
                    state: controller.checkCardState,
                    title: controller.checkCardTitle,
                    body: controller.checkCardBody,
                    isDark: Get.find<ThemeService>().isDarkMode.value,
                  )),
              SizedBox(height: AppSpacing.vlg),

              // 안전 보고 버튼 — enabled 조건이 role에 따라 다름
              Obx(() => ManualReportButton(
                    isReporting: controller.isReporting.value,
                    enabled: _isReportEnabled(isSubject),
                    onPressed: controller.reportNow,
                  )),
              SizedBox(height: AppSpacing.vlg),

              // 안부 확인 시각 변경 타일
              Obx(
                () => HeartbeatScheduleTile(
                  heartbeatTime: controller.heartbeatTime.value,
                  // S는 항상 활성, G+S는 isGuardianConnected일 때만
                  onTap: (isSubject || controller.isGuardianConnected)
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
              SizedBox(height: AppSpacing.vlg),

              // 긴급 도움 요청 버튼 — enabled 조건 동일
              Obx(() => EmergencyButton(
                    isSending: controller.isSendingEmergency.value,
                    enabled: _isReportEnabled(isSubject),
                    onPressed: () => _showEmergencyConfirm(),
                  )),

              // 위치 권한 경고 (양쪽 공통)
              Obx(() => LocationPermissionWarning(
                    denied: controller.locationPermissionDenied.value,
                    onTap: controller.requestLocationPermissionAgain,
                  )),
              SizedBox(height: AppSpacing.vlg),

              const BannerAdWidget(),
              SizedBox(height: AppSpacing.vlg),
            ],
          ),
        ),
      ),
    );
  }

  /// 보고/긴급 버튼 활성화 조건
  /// - S: guardianCount > 0 (보호자 1명 이상 연결)
  /// - G+S: isGuardianConnected (구독 활성)
  bool _isReportEnabled(bool isSubject) {
    return isSubject
        ? controller.guardianCount.value > 0
        : controller.isGuardianConnected;
  }

  // ── 다이얼로그 (공통) ──────────────────────────────────────────────

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

  // ── Drawer (S 전용) ───────────────────────────────────────────────

  Widget _buildDrawer(GlobalKey<ScaffoldState> scaffoldKey) {
    final s = controller as SubjectHomeController;
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
                        Positioned(
                          top: 4.h,
                          right: 4.w,
                          child: GestureDetector(
                            onTap: () =>
                                scaffoldKey.currentState?.closeDrawer(),
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Icon(Icons.close_rounded,
                                  size: 28.w,
                                  color: AppColors.onSurfaceVariant),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 48.r,
                                backgroundColor:
                                    Get.find<ThemeService>().isDarkMode.value
                                        ? const Color(0xFF00695C)
                                        : const Color(0xFF80CBC4),
                                child: Icon(Icons.person,
                                    size: 56.w, color: Colors.white),
                              ),
                              SizedBox(height: AppSpacing.md),
                              Obx(() => Text(
                                    s.inviteCode.isNotEmpty
                                        ? s.inviteCode
                                        : '---  ----',
                                    style: TextStyle(
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.w800,
                                      color: s.inviteCode.isNotEmpty
                                          ? (Get.find<ThemeService>()
                                                  .isDarkMode
                                                  .value
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
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        size: 22.w,
                        color: AppColors.onSurfaceVariant,
                      ),
                      title: Text(
                        isDark ? 'drawer_light_mode'.tr : 'drawer_dark_mode'.tr,
                        style: AppTextTheme.bodyLarge(),
                      ),
                      onTap: () {
                        scaffoldKey.currentState?.closeDrawer();
                        Future.delayed(
                            const Duration(milliseconds: 300), themeSvc.toggle);
                      },
                    );
                  }),

                  Divider(color: AppColors.surfaceContainerHigh, height: 1),

                  // S → G+S 전환
                  ListTile(
                    leading: Icon(Icons.family_restroom_rounded,
                        size: 22.w, color: const Color(0xFF4355B9)),
                    title: Text('drawer_enable_guardian'.tr,
                        style: AppTextTheme.bodyLarge(
                            color: const Color(0xFF4355B9))),
                    onTap: () {
                      scaffoldKey.currentState?.closeDrawer();
                      Future.delayed(const Duration(milliseconds: 300),
                          () => _showSwitchToGuardianConfirm(s));
                    },
                  ),

                  Divider(color: AppColors.surfaceContainerHigh, height: 1),

                  // 법적 문서
                  ListTile(
                    leading: Icon(Icons.description_outlined,
                        size: 22.w, color: AppColors.onSurfaceVariant),
                    title: Text('drawer_privacy_policy'.tr,
                        style: AppTextTheme.bodyLarge()),
                    trailing: Icon(Icons.open_in_new_rounded,
                        size: 18.w, color: AppColors.onSurfaceVariant),
                    onTap: () => launchUrl(
                        Uri.parse(AppConstants.privacyPolicyUrl),
                        mode: LaunchMode.externalApplication),
                  ),
                  ListTile(
                    leading: Icon(Icons.gavel_rounded,
                        size: 22.w, color: AppColors.onSurfaceVariant),
                    title: Text('drawer_terms'.tr,
                        style: AppTextTheme.bodyLarge()),
                    trailing: Icon(Icons.open_in_new_rounded,
                        size: 18.w, color: AppColors.onSurfaceVariant),
                    onTap: () => launchUrl(
                        Uri.parse(AppConstants.termsOfServiceUrl),
                        mode: LaunchMode.externalApplication),
                  ),

                  const Spacer(),

                  const Divider(height: 1),

                  // 탈퇴
                  ListTile(
                    leading: Icon(Icons.logout_rounded,
                        color: Colors.redAccent, size: 22.w),
                    title: Text('drawer_withdraw'.tr,
                        style:
                            AppTextTheme.bodyLarge(color: Colors.redAccent)),
                    onTap: () => _showDeleteConfirm(scaffoldKey, s),
                  ),

                  // 앱 버전
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: AppSpacing.lg,
                        top: AppSpacing.sm,
                        right: AppSpacing.horizontalMargin),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Obx(() => Text(
                            'v${s.appVersion.value}',
                            style: AppTextTheme.bodySmall(
                                color: AppColors.textTertiary),
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

  // ── Drawer 내부 다이얼로그 (S 전용) ────────────────────────────────

  void _showSwitchToGuardianConfirm(SubjectHomeController s) {
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
              s.switchToGuardian();
            },
            child: Text('s_to_gs_dialog_confirm'.tr,
                style: AppTextTheme.bodyMedium(
                    color: const Color(0xFF4355B9))),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(
      GlobalKey<ScaffoldState> scaffoldKey, SubjectHomeController s) {
    scaffoldKey.currentState?.closeDrawer();
    Get.dialog(
      AlertDialog(
        title: Text('drawer_withdraw'.tr,
            style: AppTextTheme.headlineSmall(
                fw: FontWeight.w700, color: const Color(0xFF1A1C1C))),
        content: Text('drawer_withdraw_message'.tr,
            style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948))),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('common_cancel'.tr,
                style:
                    AppTextTheme.bodyMedium(color: const Color(0xFF3F4948))),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              s.deleteAccount();
            },
            child: Text('drawer_withdraw'.tr,
                style: AppTextTheme.bodyMedium(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
