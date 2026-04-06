import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/modules/mode_select/controllers/mode_select_controller.dart';

/// 모드 선택 페이지
/// 스크롤 없이 한 화면에 제목 + 두 카드 + 하단 안내 배치
class ModeSelectPage extends GetWidget<ModeSelectController> {
  const ModeSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('app_brand'.tr, style: AppTextTheme.headlineSmall()),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.xs),

              // 제목
              Text('mode_select_title'.tr, style: AppTextTheme.displaySmall()),
              SizedBox(height: AppSpacing.sm),
              Text(
                'mode_select_subtitle'.tr,
                style: AppTextTheme.bodyMedium(color: AppColors.textTertiary),
              ),

              SizedBox(height: AppSpacing.md),

              // 대상자 모드 카드 (Teal)
              Expanded(
                child: _ModeCard(
                  gradientColors: const [Color(0xFFE0F2F1), Color(0xFFC8E6C9)],
                  illustrationPath: 'assets/illustrations/select_dependent.svg',
                  title: 'mode_subject_title'.tr,
                  buttonLabel: 'mode_subject_button'.tr,
                  buttonColor: const Color(0xFF00685E),
                  onTap: controller.selectSubjectMode,
                ),
              ),
              SizedBox(height: AppSpacing.sp6),

              // 보호자 모드 카드 (Indigo)
              Expanded(
                child: _ModeCard(
                  gradientColors: const [Color(0xFFE8EAF6), Color(0xFFDDE1FF)],
                  illustrationPath: 'assets/illustrations/select_guardian.svg',
                  title: 'mode_guardian_title'.tr,
                  buttonLabel: 'mode_guardian_button'.tr,
                  buttonColor: const Color(0xFF4355B9),
                  onTap: controller.selectGuardianMode,
                ),
              ),

              SizedBox(height: AppSpacing.lg),

              // 하단 안내
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sp4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 14.w, color: AppColors.textTertiary),
                      SizedBox(width: 4.w),
                      Text('mode_select_notice'.tr, style: AppTextTheme.bodySmall()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final List<Color> gradientColors;
  final String illustrationPath;
  final String title;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onTap;

  const _ModeCard({
    required this.gradientColors,
    required this.illustrationPath,
    required this.title,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // 상단: 일러스트
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: SvgPicture.asset(
                  illustrationPath,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // 하단: 제목 + 버튼 (세로 배치)
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTextTheme.headlineSmall(color: AppColors.onSurface),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        buttonLabel,
                        style: AppTextTheme.bodyMedium(color: buttonColor),
                      ),
                    ),
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
