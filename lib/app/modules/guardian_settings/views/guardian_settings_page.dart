import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
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
                SizedBox(height: AppSpacing.lg),

                // 연결 관리 카드
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

                // 구독 및 서비스 섹션
                Text('settings_subscription_service'.tr,
                    style: AppTextTheme.labelMedium(
                        color: AppColors.textTertiary, fw: FontWeight.w600)),
                SizedBox(height: AppSpacing.md),

                // 구독 카드
                _buildSubscriptionCard(),
                SizedBox(height: AppSpacing.lg),

                // G+S 버튼: 비활성 → 활성화 / 활성 → 안전 코드 확인 페이지 이동
                _buildGsButton(),
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

                // 하단: 앱 버전 + 브랜드 (왼쪽 정렬) + 탈퇴 (우측)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => Text(
                            'settings_app_version'.trParams({'version': controller.appVersion.value}),
                            style: AppTextTheme.labelSmall(
                                color: AppColors.textTertiary))),
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
                    GestureDetector(
                      onTap: () => _showDeleteConfirm(),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: Text(
                          'drawer_withdraw'.tr,
                          style: AppTextTheme.labelSmall(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ],
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

  // ── G+S 버튼 (알림 설정과 동일한 스타일) ──

  Widget _buildGsButton() {
    return Obx(() {
      final isGS = controller.isAlsoSubject.value;
      final enabling = controller.isEnabling.value;
      return GestureDetector(
        onTap: enabling
            ? null
            : isGS
                ? controller.goToSafetyCode
                : () => _showEnableConfirm(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              if (enabling)
                SizedBox(
                  width: 22.w, height: 22.w,
                  child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4355B9)),
                )
              else
                Icon(Icons.shield_rounded, size: 22.w, color: AppColors.onSurfaceVariant),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  isGS ? 'gs_safety_code_button'.tr : 'gs_enable_button'.tr,
                  style: AppTextTheme.bodyLarge(fw: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 22.w, color: AppColors.onSurfaceVariant),
            ],
          ),
        ),
      );
    });
  }

  void _showEnableConfirm() {
    if (Platform.isIOS) {
      _showEnableConfirmIOS();
      return;
    }
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

  /// iOS G+S 전용 활성화 확인 다이얼로그
  /// 강조 경고 카드로 "하루 한 번만 기억" 원칙을 명시 (PRD 4.2)
  void _showEnableConfirmIOS() {
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        title: Text('gs_enable_dialog_title'.tr,
            style: AppTextTheme.headlineSmall(fw: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('gs_enable_dialog_body'.tr,
                  style:
                      AppTextTheme.bodyMedium(color: const Color(0xFF3F4948))),
              SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12.r),
                  border: const Border(
                    left: BorderSide(color: Color(0xFFE65100), width: 4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('gs_enable_dialog_ios_warning_title'.tr,
                        style: AppTextTheme.bodyLarge(
                            fw: FontWeight.w700,
                            color: const Color(0xFFE65100))),
                    SizedBox(height: AppSpacing.sm),
                    Text('gs_enable_dialog_ios_warning_body'.tr,
                        style: AppTextTheme.bodyMedium(
                            color: const Color(0xFF3F4948))),
                  ],
                ),
              ),
            ],
          ),
        ),
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
            child: Text('gs_enable_dialog_ios_confirm'.tr,
                style: AppTextTheme.bodyMedium(
                    color: const Color(0xFFE65100), fw: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── 탈퇴 확인 다이얼로그 ──

  void _showDeleteConfirm() {
    Get.dialog(
      AlertDialog(
        title: Text('drawer_withdraw'.tr,
            style: AppTextTheme.headlineSmall(fw: FontWeight.w700)),
        content: Text('drawer_withdraw_message'.tr,
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
              controller.deleteAccount();
            },
            child: Text('drawer_withdraw'.tr,
                style: AppTextTheme.bodyMedium(color: AppColors.error)),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    isPremium
                        ? 'settings_premium'.tr
                        : 'settings_free_trial'.tr,
                    style: AppTextTheme.headlineMedium(
                        color: Colors.white, fw: FontWeight.w700),
                  ),
                ),
                if (controller.subscriptionDaysRemaining.value >= 0)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h, left: 8.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'settings_days_remaining'.trParams({
                          'days':
                              '${controller.subscriptionDaysRemaining.value}',
                        }),
                        style: AppTextTheme.labelSmall(
                            color: Colors.white, fw: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
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
