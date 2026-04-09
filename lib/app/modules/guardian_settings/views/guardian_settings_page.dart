import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/core/widgets/heartbeat_schedule_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:anbucheck/app/core/utils/constants.dart';
import 'package:anbucheck/app/core/utils/back_press_handler.dart';
import 'package:anbucheck/app/core/services/theme_service.dart';
import 'package:anbucheck/app/modules/guardian_settings/controllers/guardian_settings_controller.dart';
import 'package:anbucheck/app/core/widgets/guardian_bottom_nav.dart';

/// 보호자 설정 페이지 — v2: G+S 통합 카드 포함
class GuardianSettingsPage extends GetWidget<GuardianSettingsController> {
  const GuardianSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) BackPressHandler.onBackPressed();
      },
      child: Obx(() {
      Get.find<ThemeService>().isDarkMode.value;
      return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.settings_rounded, size: 22.w, color: AppColors.onSurface),
            SizedBox(width: 8.w),
            Flexible(child: Text('settings_title'.tr, style: AppTextTheme.headlineSmall(), overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          // 다크모드 토글 (AppBar 오른쪽)
          Obx(() {
            final themeSvc = Get.find<ThemeService>();
            final isDark = themeSvc.isDarkMode.value;
            return IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 24.w,
                color: AppColors.onSurfaceVariant,
              ),
              onPressed: themeSvc.toggle,
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: controller.isAlsoSubject.value ? AppSpacing.sm : AppSpacing.lg),

                // ── G+S: 활성화 버튼 또는 통합 카드 ──
                if (!controller.isAlsoSubject.value)
                  _buildEnableButton()
                else
                  _buildSubjectCard(),
                SizedBox(height: AppSpacing.lg),

                // 연결 관리 카드 (G+S 활성 시 히든)
                if (!controller.isAlsoSubject.value) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.people_alt_rounded,
                                size: 22.w, color: AppColors.onSurfaceVariant),
                            SizedBox(width: AppSpacing.md),
                            Text('settings_connection_management'.tr,
                                style: AppTextTheme.bodyLarge(
                                    fw: FontWeight.w600)),
                          ],
                        ),
                        SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('settings_managed_subjects'.tr,
                                style: AppTextTheme.bodyMedium(
                                    color: AppColors.textSecondary)),
                            Text(
                                  'settings_managed_subjects_count'.trParams({'current': controller.subjects.length.toString(), 'max': controller.maxSubjects.value.toString()}),
                                  style: AppTextTheme.headlineSmall(
                                    color: const Color(0xFF4355B9),
                                    fw: FontWeight.w700,
                                  ),
                                ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.sp6),
                ],

                // 구독 및 서비스 섹션
                Text('settings_subscription_service'.tr,
                    style: AppTextTheme.labelMedium(
                        color: AppColors.textTertiary, fw: FontWeight.w600)),
                SizedBox(height: AppSpacing.md),

                // 구독 카드
                _buildSubscriptionCard(),
                SizedBox(height: AppSpacing.lg),

                // 알림 설정
                GestureDetector(
                  onTap: controller.goToNotificationSettings,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notifications_rounded,
                            size: 22.w, color: AppColors.onSurfaceVariant),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text('settings_notification'.tr,
                              style: AppTextTheme.bodyLarge(
                                  fw: FontWeight.w600)),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            size: 22.w, color: AppColors.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.sp6),

                // 약관 섹션
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description_outlined,
                              size: 20.w, color: AppColors.onSurfaceVariant),
                          SizedBox(width: AppSpacing.md),
                          Text('settings_terms_section'.tr,
                              style: AppTextTheme.bodyLarge(
                                  fw: FontWeight.w600)),
                        ],
                      ),
                      SizedBox(height: AppSpacing.lg),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse(AppConstants.privacyPolicyUrl), mode: LaunchMode.externalApplication),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('settings_privacy_policy'.tr,
                                style: AppTextTheme.bodyMedium(
                                    color: AppColors.textSecondary)),
                            Icon(Icons.open_in_new_rounded,
                                size: 18.w, color: AppColors.onSurfaceVariant),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse(AppConstants.termsOfServiceUrl), mode: LaunchMode.externalApplication),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('settings_terms'.tr,
                                style: AppTextTheme.bodyMedium(
                                    color: AppColors.textSecondary)),
                            Icon(Icons.open_in_new_rounded,
                                size: 18.w, color: AppColors.onSurfaceVariant),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.sp8),

                // 하단: 앱 버전 + 브랜드
                Center(
                  child: Column(
                    children: [
                      Obx(() => Text(
                        'settings_app_version'.trParams({'version': controller.appVersion.value}),
                        style: AppTextTheme.labelSmall(
                            color: AppColors.textTertiary))),
                      SizedBox(height: 2.h),
                      Text('app_guardian_title'.tr,
                          style: AppTextTheme.labelSmall(
                              color: AppColors.textTertiary,
                              fw: FontWeight.w500)),
                      SizedBox(height: AppSpacing.md),
                      Text('ANBU GUARD NETWORK',
                          style: AppTextTheme.labelSmall(
                              color: AppColors.textTertiary,
                              fw: FontWeight.w600)),
                      SizedBox(height: 4.h),
                      Text('© 2024 TNS Inc.',
                          style: AppTextTheme.labelSmall(
                              color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.sp6),
              ],
            )),
      ),
      bottomNavigationBar: const GuardianBottomNav(currentIndex: 3),
    );
    }),
    );
  }

  // ── [나도 안부 보호 받기] 활성화 버튼 ──

  Widget _buildEnableButton() {
    return Obx(() {
      final enabling = controller.isEnabling.value;
      return GestureDetector(
        onTap: enabling ? null : () => _showEnableConfirm(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFF4355B9).withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (enabling)
                SizedBox(
                  width: 22.w, height: 22.w,
                  child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4355B9)),
                )
              else
                Icon(Icons.shield_rounded, size: 22.w, color: const Color(0xFF4355B9)),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  'gs_enable_button'.tr,
                  style: AppTextTheme.bodyLarge(
                    color: const Color(0xFF4355B9),
                    fw: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showEnableConfirm() {
    Get.dialog(
      AlertDialog(
        title: Text('gs_enable_dialog_title'.tr,
            style: AppTextTheme.headlineSmall(fw: FontWeight.w700)),
        content: Text('gs_enable_dialog_body'.tr,
            style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948))),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('common_cancel'.tr,
                style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948))),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.enableSubjectFeature();
            },
            child: Text('gs_enable_confirm'.tr,
                style: AppTextTheme.bodyMedium(
                    color: const Color(0xFF4355B9), fw: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── G+S 통합 카드 (활성화 상태) ──

  Widget _buildSubjectCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          // 헤더: 해제 + SAFETY SHARE CODE + 복사/공유
          Row(
            children: [
              GestureDetector(
                onTap: _showDisableConfirm,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.exit_to_app_rounded, size: 20.w, color: AppColors.error),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'SAFETY SHARE CODE',
                  style: AppTextTheme.labelMedium(
                    color: AppColors.textTertiary,
                    fw: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: controller.copyInviteCode,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.copy_rounded, size: 20.w, color: AppColors.onSurfaceVariant),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: controller.shareInviteCode,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.share_rounded, size: 20.w, color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // 초대 코드
          Obx(() => Text(
            controller.inviteCode.isNotEmpty ? controller.inviteCode.value : '---  ----',
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
              color: controller.inviteCode.isNotEmpty
                  ? (Get.find<ThemeService>().isDarkMode.value
                      ? Colors.white
                      : const Color(0xFF4355B9))
                  : AppColors.textTertiary,
              letterSpacing: 2,
            ),
          )),
          SizedBox(height: AppSpacing.lg),

          // 상태 카드
          _buildStatusRow(),
          SizedBox(height: AppSpacing.lg),

          // 수동 보고 버튼
          _buildReportButton(),
          SizedBox(height: AppSpacing.md),

          // 시각 변경
          Obx(() => HeartbeatScheduleTile(
            heartbeatTime: controller.heartbeatTime.value,
            onTap: controller.showTimePickerDialog,
            color: const Color(0xFF4355B9),
            timeColor: Get.find<ThemeService>().isDarkMode.value ? Colors.white : null,
            backgroundColor: Get.find<ThemeService>().isDarkMode.value
                ? const Color(0xFF1A237E).withValues(alpha: 0.3)
                : const Color(0xFFE8EAF6),
          )),
          SizedBox(height: AppSpacing.md),

          // 긴급 도움 요청
          _buildEmergencyButton(),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    return Obx(() {
      final state = controller.checkCardState;
      final iconData = state == 'reported'
          ? Icons.check_rounded
          : state == 'waiting'
              ? Icons.hourglass_top_rounded
              : Icons.schedule_rounded;
      final dark = Get.find<ThemeService>().isDarkMode.value;
      final iconBg = state == 'reported'
          ? (dark ? const Color(0xFF303F9F) : const Color(0xFF4355B9))
          : state == 'waiting'
              ? (dark ? const Color(0xFFFF6D00) : const Color(0xFFE65100))
              : (dark ? const Color(0xFF6A1B9A) : AppColors.surfaceContainerHigh);
      final iconColor = state == 'reported' || state == 'waiting'
          ? Colors.white
          : (dark ? Colors.white : AppColors.onSurfaceVariant);
      final textColor = dark
          ? const Color(0xFFFFD54F)
          : (state == 'waiting' ? const Color(0xFFE65100) : const Color(0xFF4355B9));

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: dark
              ? const Color(0xFF1A237E).withValues(alpha: 0.2)
              : const Color(0xFFE8EAF6).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w, height: 40.w,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(iconData, size: 24.w, color: iconColor),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(controller.checkCardTitle,
                      style: AppTextTheme.bodySmall(color: AppColors.textSecondary)),
                  SizedBox(height: 2.h),
                  Text(controller.checkCardBody,
                      style: AppTextTheme.bodyLarge(color: textColor, fw: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildReportButton() {
    return Obx(() {
      final sending = controller.isReporting.value;
      return GestureDetector(
        onTap: sending ? null : controller.reportNow,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: sending
                  ? [const Color(0xFF5C6BC0), const Color(0xFF5C6BC0)]
                  : [const Color(0xFF4355B9), const Color(0xFF5C6BC0)],
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (sending)
                SizedBox(
                  width: 20.w, height: 20.w,
                  child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              else
                Icon(Icons.verified_user_rounded, size: 20.w, color: Colors.white),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  sending ? 'subject_home_report_loading'.tr : 'subject_home_report_button'.tr,
                  style: AppTextTheme.bodyLarge(color: Colors.white, fw: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmergencyButton() {
    return Obx(() {
      final sending = controller.isSendingEmergency.value;
      return GestureDetector(
        onTap: sending ? null : () => _showEmergencyConfirm(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: sending ? const Color(0xFFFFCDD2) : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: sending ? const Color(0xFFE57373) : const Color(0xFFB71C1C),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (sending)
                SizedBox(
                  width: 20.w, height: 20.w,
                  child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB71C1C)),
                )
              else
                Icon(Icons.volunteer_activism_rounded, size: 20.w, color: const Color(0xFFB71C1C)),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  sending ? 'subject_home_emergency_loading'.tr : 'subject_home_emergency_button'.tr,
                  style: AppTextTheme.bodyLarge(
                    color: const Color(0xFFB71C1C),
                    fw: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
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
        title: Text('subject_home_emergency_confirm_title'.tr,
            style: AppTextTheme.headlineSmall(
                fw: FontWeight.w700, color: const Color(0xFFB71C1C))),
        content: Text('subject_home_emergency_confirm_body'.tr,
            style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948))),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('common_cancel'.tr,
                style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948))),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.sendEmergency();
            },
            child: Text('subject_home_emergency_confirm_send'.tr,
                style: AppTextTheme.bodyMedium(
                    color: const Color(0xFFB71C1C), fw: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showDisableConfirm() {
    Get.dialog(
      AlertDialog(
        title: Text('gs_disable_dialog_title'.tr,
            style: AppTextTheme.headlineSmall(fw: FontWeight.w700)),
        content: Text('gs_disable_dialog_body'.tr,
            style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948))),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('common_cancel'.tr,
                style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948))),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.disableSubjectFeature();
            },
            child: Text('gs_disable_confirm'.tr,
                style: AppTextTheme.bodyMedium(color: AppColors.error, fw: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── 구독 카드 ──

  Widget _buildSubscriptionCard() {
    return Obx(() {
      final plan = controller.subscriptionPlan.value;
      final isPremium = plan == 'yearly';
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.sp4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPremium
                ? [const Color(0xFF4355B9), const Color(0xFF5C6BC0)]
                : [const Color(0xFF607D8B), const Color(0xFF90A4AE)],
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                    isPremium
                        ? Icons.verified_rounded
                        : Icons.card_giftcard_rounded,
                    size: 18.w, color: Colors.white70),
                SizedBox(width: 6.w),
                Text('settings_current_membership'.tr,
                    style: AppTextTheme.labelSmall(
                        color: Colors.white70, fw: FontWeight.w600)),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Text(
                isPremium ? 'settings_premium'.tr : 'settings_free_trial'.tr,
                style: AppTextTheme.headlineMedium(
                    color: Colors.white, fw: FontWeight.w700)),
            SizedBox(height: AppSpacing.lg),
            if (isPremium)
              _PremiumButton(
                label: 'settings_manage_subscription'.tr,
                filled: false,
                onTap: () => launchUrl(
                  Uri.parse(GetPlatform.isIOS
                      ? 'https://apps.apple.com/account/subscriptions'
                      : 'https://play.google.com/store/account/subscriptions'),
                  mode: LaunchMode.externalApplication,
                ),
              )
            else
              _PremiumButton(
                label: 'guardian_subscribe'.tr,
                filled: true,
                onTap: () {
                  Get.snackbar('common_notice'.tr, 'guardian_payment_preparing'.tr,
                      snackPosition: SnackPosition.BOTTOM);
                },
              ),
          ],
        ),
      );
    });
  }
}

class _PremiumButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _PremiumButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.transparent,
          border: filled ? null : Border.all(color: Colors.white54),
          borderRadius: BorderRadius.circular(24.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextTheme.bodyMedium(
            color: filled ? const Color(0xFF4355B9) : Colors.white,
            fw: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
