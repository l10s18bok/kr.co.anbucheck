import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/modules/mode_select/controllers/mode_select_controller.dart';

/// 모드 선택 페이지 — 시안 _10 기준
/// "누구를 위한 것인가요?", 대상자/보호자 세로 카드
class ModeSelectPage extends GetWidget<ModeSelectController> {
  const ModeSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.onSurface, size: 24.w),
          onPressed: () {},
        ),
        title: Text(
          '안부 (Anbu)',
          style: AppTextTheme.headlineSmall(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.sp6),

              // 제목
              Text(
                '누구를 위한\n것인가요?',
                style: AppTextTheme.displaySmall(),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                '사용자의 목적에 가장 적합한 모드를 선택해\n주세요. 설정된 이후에 다시 변경할 수 있습니다.',
                style: AppTextTheme.bodyMedium(color: AppColors.textTertiary),
              ),
              SizedBox(height: AppSpacing.sp6),

              // 대상자 모드 카드 (Teal)
              _ModeCard(
                gradientColors: const [Color(0xFFE0F2F1), Color(0xFFC8E6C9)],
                iconBackgroundColor: const Color(0xFF00685E),
                icon: Icons.home_rounded,
                title: '나의 안부를 확인받고 싶어\n요',
                buttonLabel: '대상자 모드 시작하기 →',
                buttonColor: const Color(0xFF00685E),
                onTap: controller.selectSubjectMode,
              ),
              SizedBox(height: AppSpacing.lg),

              // 보호자 모드 카드 (Indigo)
              _ModeCard(
                gradientColors: const [Color(0xFFE8EAF6), Color(0xFFDDE1FF)],
                iconBackgroundColor: const Color(0xFF4355B9),
                icon: Icons.visibility_rounded,
                title: '소중한 사람을 지켜보고 싶\n어요',
                buttonLabel: '보호자 모드 시작하기 →',
                buttonColor: const Color(0xFF4355B9),
                onTap: controller.selectGuardianMode,
              ),
              SizedBox(height: AppSpacing.sp8),

              // 하단 안내
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sp6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline,
                          size: 14.w, color: AppColors.textTertiary),
                      SizedBox(width: 4.w),
                      Text(
                        '모드에 따라 화면 구성과 알림 설정이 달라집니다',
                        style: AppTextTheme.bodySmall(),
                      ),
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
  final Color iconBackgroundColor;
  final IconData icon;
  final String title;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onTap;

  const _ModeCard({
    required this.gradientColors,
    required this.iconBackgroundColor,
    required this.icon,
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
        padding: EdgeInsets.all(AppSpacing.sp4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: iconBackgroundColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, size: 24.w, color: iconBackgroundColor),
            ),
            SizedBox(height: AppSpacing.lg),

            // 제목
            Text(
              title,
              style: AppTextTheme.headlineMedium(
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // 시작 버튼
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Text(
                buttonLabel,
                style: AppTextTheme.labelMedium(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
