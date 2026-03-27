import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/modules/onboarding/controllers/onboarding_controller.dart';

/// 대상자 온보딩 페이지
/// PRD 7.3: 3단계 서비스 소개 (자동 전송 / 보호자 안심 / 개인정보 미수집)
class OnboardingPage extends GetWidget<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 페이지 콘텐츠
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: [
                  _OnboardingStep(
                    icon: Icons.schedule_send_rounded,
                    title: 'onboarding_title_1'.tr,
                    description: 'onboarding_desc_1'.tr,
                  ),
                  _OnboardingStep(
                    icon: Icons.shield_rounded,
                    title: 'onboarding_title_2'.tr,
                    description: 'onboarding_desc_2'.tr,
                  ),
                  _OnboardingStep(
                    icon: Icons.lock_rounded,
                    title: 'onboarding_title_3'.tr,
                    description: 'onboarding_desc_3'.tr,
                  ),
                ],
              ),
            ),

            // 페이지 인디케이터
            Obx(() => _PageIndicator(
                  currentPage: controller.currentPage,
                  totalPages: OnboardingController.totalPages,
                )),
            SizedBox(height: AppSpacing.sp6),

            // 하단 버튼
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontalMargin,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.nextPage,
                          child: Text(
                            controller.currentPage <
                                    OnboardingController.totalPages - 1
                                ? '다음'.tr
                                : '시작하기'.tr,
                            style: AppTextTheme.labelLarge(),
                          ),
                        )),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Obx(() => controller.currentPage <
                          OnboardingController.totalPages - 1
                      ? TextButton(
                          onPressed: controller.completeOnboarding,
                          child: Text(
                            '건너뛰기'.tr,
                            style: AppTextTheme.bodyMedium(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),
                  SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: AppColors.seniorPrimary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 56.w,
              color: AppColors.seniorPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sp8),
          Text(
            title,
            style: AppTextTheme.headlineLarge(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            description,
            style: AppTextTheme.bodyLarge(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _PageIndicator({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: isActive ? 24.w : 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.seniorPrimary
                : AppColors.seniorPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}
