import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';

/// 안전 코드 표시 + 복사/공유 카드 — S/G+S 공통
class InviteCodeShareCard extends StatelessWidget {
  final String inviteCode;
  final bool isDark;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const InviteCodeShareCard({
    super.key,
    required this.inviteCode,
    required this.isDark,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final hasCode = inviteCode.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          AppSpacing.sp4, AppSpacing.sp4, AppSpacing.sp4, AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'SAFETY SHARE CODE',
                  style: AppTextTheme.labelMedium(
                    color: AppColors.textTertiary,
                    fw: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onCopy,
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 20.w,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  GestureDetector(
                    onTap: onShare,
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.share_rounded,
                        size: 20.w,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            hasCode ? inviteCode : '---  ----',
            style: TextStyle(
              fontSize: 40.sp,
              fontWeight: FontWeight.w800,
              color: hasCode
                  ? (isDark ? Colors.white : const Color(0xFF00685E))
                  : AppColors.textTertiary,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
