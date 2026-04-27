import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';

/// 지금 바로 안전 보고하기 버튼 (수동 heartbeat 전송)
class ManualReportButton extends StatelessWidget {
  final bool isReporting;
  final bool enabled;
  final VoidCallback onPressed;

  const ManualReportButton({
    super.key,
    required this.isReporting,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !enabled || isReporting;
    return GestureDetector(
      onTap: disabled ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: disabled
                ? [const Color(0xFF4A7C78), const Color(0xFF4A7C78)]
                : [const Color(0xFF00685E), const Color(0xFF008377)],
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isReporting)
                  SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                else
                  Icon(Icons.verified_user_rounded,
                      size: 24.w, color: Colors.white),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    isReporting
                        ? 'subject_home_report_loading'.tr
                        : 'subject_home_report_button'.tr,
                    style: AppTextTheme.headlineSmall(
                        color: Colors.white, fw: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              'subject_home_report_desc'.tr,
              style: AppTextTheme.bodySmall(
                  color: Colors.white.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
