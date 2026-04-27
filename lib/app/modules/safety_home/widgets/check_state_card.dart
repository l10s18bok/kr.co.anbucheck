import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';

/// 안부 확인 상태 카드 — 보고 완료 / 보고 예정 / 보고 대기 중
/// state: 'reported' | 'pending' | 'waiting'
class CheckStateCard extends StatelessWidget {
  final String state;
  final String title;
  final String body;
  final bool isDark;

  const CheckStateCard({
    super.key,
    required this.state,
    required this.title,
    required this.body,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = state == 'reported'
        ? Icons.check_rounded
        : state == 'waiting'
            ? Icons.hourglass_top_rounded
            : Icons.schedule_rounded;
    final iconBg = state == 'reported'
        ? (isDark ? const Color(0xFF00897B) : const Color(0xFF00685E))
        : state == 'waiting'
            ? (isDark ? const Color(0xFFFF6D00) : const Color(0xFFE65100))
            : (isDark
                ? const Color(0xFF6A1B9A)
                : AppColors.surfaceContainerHigh);
    final iconColor = state == 'reported' || state == 'waiting'
        ? Colors.white
        : (isDark ? Colors.white : AppColors.onSurfaceVariant);
    final textColor = isDark
        ? const Color(0xFFFFD54F)
        : (state == 'waiting'
            ? const Color(0xFFE65100)
            : const Color(0xFF00685E));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark
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
                  title,
                  style: AppTextTheme.bodyMedium(color: AppColors.textSecondary),
                ),
                SizedBox(height: 2.h),
                Text(
                  body,
                  style: AppTextTheme.headlineSmall(
                      color: textColor, fw: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
