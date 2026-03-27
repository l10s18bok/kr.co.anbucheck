import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';

/// 안부 확인 시각 변경 공통 타일
/// 대상자(Teal) / 보호자(Indigo) 색상만 달리하여 재사용
class HeartbeatScheduleTile extends StatelessWidget {
  final String heartbeatTime;
  final VoidCallback onTap;
  final Color color;
  final Color backgroundColor;
  final String label;
  final String? subLabel;

  const HeartbeatScheduleTile({
    super.key,
    required this.heartbeatTime,
    required this.onTap,
    required this.color,
    required this.backgroundColor,
    this.label = '안부 확인 시각 변경',
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            vertical: 16.h, horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule_rounded, size: 22.w, color: color),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: AppTextTheme.labelLarge(color: color),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              subLabel ?? '매일 $heartbeatTime',
              style: AppTextTheme.bodySmall(
                color: color.withValues(alpha: 0.8),
                fw: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
