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

/// 보호자 설정 페이지 — 시안 _3 기준
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
      // 다크모드 전환 시 즉시 리빌드
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
            Text('설정', style: AppTextTheme.headlineSmall()),
          ],
        ),
        actions: const [],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.lg),

                // 프로필 카드
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24.r,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        child: Icon(Icons.person,
                            size: 28.w, color: AppColors.onSurfaceVariant),
                      ),
                      SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('안부 수호자',
                                style: AppTextTheme.bodyLarge(
                                    fw: FontWeight.w600)),
                            SizedBox(height: 2.h),
                            Obx(() => Text(
                                '앱버전 : v${controller.appVersion.value}',
                                style: AppTextTheme.bodySmall(
                                    color: AppColors.textTertiary))),
                          ],
                        ),
                      ),
                      Obx(() {
                        final themeSvc = Get.find<ThemeService>();
                        final isDark = themeSvc.isDarkMode.value;
                        return GestureDetector(
                          onTap: themeSvc.toggle,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isDark
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                                size: 24.w,
                                color: AppColors.onSurfaceVariant,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                isDark ? '라이트모드' : '다크모드',
                                style: AppTextTheme.labelSmall(
                                  color: AppColors.textTertiary,
                                  fw: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
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
                          Text('연결 관리',
                              style: AppTextTheme.bodyLarge(
                                  fw: FontWeight.w600)),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('관리 보호 대상자 수',
                              style: AppTextTheme.bodyMedium(
                                  color: AppColors.textSecondary)),
                          Obx(() => Text(
                                '${controller.subjects.length} / ${controller.maxSubjects.value}명',
                                style: AppTextTheme.headlineSmall(
                                  color: const Color(0xFF4355B9),
                                  fw: FontWeight.w700,
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.sp6),

                // 구독 및 서비스 섹션
                Text('구독 및 서비스',
                    style: AppTextTheme.labelMedium(
                        color: AppColors.textTertiary, fw: FontWeight.w600)),
                SizedBox(height: AppSpacing.md),

                // 구독 카드
                Obx(() {
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
                          Text('현재 멤버십',
                              style: AppTextTheme.labelSmall(
                                  color: Colors.white70, fw: FontWeight.w600)),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                          isPremium ? '프리미엄 구독 중' : '무료 체험 중',
                          style: AppTextTheme.headlineMedium(
                              color: Colors.white, fw: FontWeight.w700)),
                      SizedBox(height: AppSpacing.lg),
                      if (isPremium)
                        _PremiumButton(
                          label: '구독 관리',
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
                          label: '구독하기',
                          filled: true,
                          onTap: () {
                            // TODO: 인앱 결제 SDK 연동 후 구현
                            Get.snackbar('안내', '결제 기능 준비 중입니다.',
                                snackPosition: SnackPosition.BOTTOM);
                          },
                        ),
                    ],
                  ),
                );
                }),
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
                          child: Text('알림 설정',
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
                          Text('약관',
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
                            Text('개인정보처리방침',
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
                            Text('이용약관',
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

                // 하단 브랜드
                Center(
                  child: Column(
                    children: [
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
            ),
      ),
      bottomNavigationBar: const GuardianBottomNav(currentIndex: 3),
    );
    }),
    );
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
