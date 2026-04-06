import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:anbucheck/app/modules/onboarding/views/onboarding_illustration.dart';

/// 온보딩 페이지
/// 4스텝 감정 흐름: 공감 → 해결 → 신뢰 → 연결
class OnboardingPage extends GetWidget<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 페이지 콘텐츠 (일러스트 상단 60% + 텍스트 하단)
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: OnboardingController.totalPages,
                itemBuilder: (context, index) => _OnboardingStep(
                  step: index,
                  title: 'onboarding_title_${index + 1}'.tr,
                  description: 'onboarding_desc_${index + 1}'.tr,
                ),
              ),
            ),

            // 하단 영역 (인디케이터 + 버튼)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontalMargin,
              ),
              child: Column(
                children: [
                  // 페이지 인디케이터
                  Obx(() => _PageIndicator(
                        currentPage: controller.currentPage,
                        totalPages: OnboardingController.totalPages,
                      )),
                  SizedBox(height: AppSpacing.sp6),

                  // 메인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: Obx(() {
                      final isLastPage = controller.currentPage ==
                          OnboardingController.totalPages - 1;
                      return ElevatedButton(
                        onPressed: controller.nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.seniorPrimary,
                          foregroundColor: AppColors.seniorOnPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isLastPage ? 'common_start'.tr : 'common_next'.tr,
                          style: AppTextTheme.labelLarge(
                            color: AppColors.seniorOnPrimary,
                          ),
                        ),
                      );
                    }),
                  ),
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

/// 온보딩 각 스텝
/// 상단 60%: 일러스트 / 하단 40%: 텍스트
class _OnboardingStep extends StatelessWidget {
  final int step;
  final String title;
  final String description;

  const _OnboardingStep({
    required this.step,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
      child: Column(
        children: [
          // 상단 일러스트 영역 (60%)
          Expanded(
            flex: 6,
            child: Center(
              child: OnboardingIllustration(step: step),
            ),
          ),

          // 하단 텍스트 영역 (40%)
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.lg),
                Text(
                  title,
                  style: AppTextTheme.headlineLarge(),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  description,
                  style: AppTextTheme.bodyLarge(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 페이지 인디케이터 (애니메이션 적용)
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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: isActive ? 28.w : 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.seniorPrimary
                : AppColors.seniorPrimary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}
