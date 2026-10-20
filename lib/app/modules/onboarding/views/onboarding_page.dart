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
                itemCount: controller.totalPages,
                itemBuilder: (context, index) {
                  final step = controller.steps[index];
                  return _OnboardingStep(
                    visual: step.visual,
                    title: step.titleKey.tr,
                    description: step.descKey.tr,
                  );
                },
              ),
            ),

            // 하단 영역 (인디케이터 + 버튼)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontalMargin,
              ),
              // 넓은 창에서 [다음] 버튼이 화면 끝까지 길어지지 않게 폭 제한(폰은 이보다 좁아 무관).
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  // 페이지 인디케이터
                  Obx(() => _PageIndicator(
                        currentPage: controller.currentPage,
                        totalPages: controller.totalPages,
                      )),
                  SizedBox(height: AppSpacing.vsp6),

                  // 메인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: Obx(() {
                      final isLastPage = controller.currentPage ==
                          controller.totalPages - 1;
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
                  SizedBox(height: AppSpacing.vlg),
                ],
              ),
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
  final OnboardingVisual visual;
  final String title;
  final String description;

  const _OnboardingStep({
    required this.visual,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    // 넓고 낮은 화면(펼친 폴더블 가로 등)은 세로로 쌓으면 일러스트 영역이 너무 낮아 목업이 잘리고
    // 위 여백도 없다 → 좌우로 나눈다(왼쪽 일러스트 · 오른쪽 글). 판단은 창 크기만으로 — 폰은 세로라 해당 없음.
    final size = MediaQuery.sizeOf(context);
    if (size.width >= 600 && size.width > size.height) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
        child: Row(
          children: [
            Expanded(
              // 목업을 폰 세로와 같은 폭(420)으로 그린 뒤 **통째로 축소**해 이 칸에 맞춘다. 칸이 좁거나 낮아도
              // 내부 줄바꿈·비율이 폰과 같게 유지되고(좁은 칸에 그대로 그리면 글이 어색하게 꺾인다),
              // 잘리거나 스크롤할 일이 없다. 위쪽 푸시 배너처럼 목업 밖으로 살짝 나오는 요소를 위해 위 여백을 둔다.
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 28, 0, 12),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: 420,
                      child: OnboardingIllustration(visual: visual),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextTheme.headlineLarge(),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.vlg),
                      Text(
                        description,
                        style: AppTextTheme.bodyLarge(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
      child: Column(
        children: [
          // 상단 일러스트 영역 (60%)
          // 저해상도(짧은 세로 높이) 기기에서 목업(특히 알림 미리보기·대상자 추가처럼
          // 콘텐츠가 큰 스텝)이 이 영역보다 커질 수 있다. OnboardingIllustration 내부의
          // UnconstrainedBox는 세로 제약을 없애 Column이 찌그러지는 문제는 막아주지만
          // 그 대신 영역보다 커진 콘텐츠가 잘리지 않고 그대로 렌더링되어 아래 텍스트 영역과
          // 겹칠 수 있다. SingleChildScrollView로 감싸 넘치면 스크롤되게 해 겹침/잘림을 방지.
          // 다음/시작하기 버튼은 이 Expanded 밖의 별도 고정 영역에 있어 항상 정상 노출된다.
          Expanded(
            flex: 6,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 폭 <600dp인데 폰답지 않게 뭉툭한 창(Duo 접힘 세로 466×678 등, 세로 < 폭×1.7)은 폰 세로 레이아웃을
                // 그대로 쓰면 일러스트 칸이 낮아 목업이 잘리고 글이 어색하게 꺾인다 → 폰 세로 폭(420)으로 그려 칸에
                // 맞게 축소한다. 일반 폰은 이 조건에 해당하지 않아 기존 스크롤 방식 그대로다.
                final mq = MediaQuery.sizeOf(context);
                if (mq.width < 600 && mq.height < mq.width * 1.7) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 28, 0, 12),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          width: 420,
                          child: OnboardingIllustration(visual: visual),
                        ),
                      ),
                    ),
                  );
                }
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  // minHeight를 영역 전체 높이로 강제해, 콘텐츠가 영역보다 작을 땐
                  // 기존과 동일하게 Center가 정중앙 배치를 유지하고, 콘텐츠가 영역보다
                  // 클 때만 스크롤이 발생하도록 한다.
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      // 넓은 창에서 목업이 옆으로 끝없이 늘어나지 않게 폭을 제한한다(폰은 이보다 좁아 무관).
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: OnboardingIllustration(visual: visual),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 하단 텍스트 영역 (40%)
          // 저해상도 기기나 접근성 큰글씨 설정에서 번역 문구가 길어지면 이 영역도
          // 넘칠 수 있어 스크롤 가능하게 감싼다(원래도 top-aligned라 Center 보정 불필요).
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.vlg),
                  Text(
                    title,
                    style: AppTextTheme.headlineLarge(),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.vlg),
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
