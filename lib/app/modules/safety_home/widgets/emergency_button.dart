import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';

/// 긴급 도움 요청 버튼 — 보호자 전원에게 즉시 urgent Push 발송
class EmergencyButton extends StatelessWidget {
  final bool isSending;
  final bool enabled;
  final VoidCallback onPressed;

  const EmergencyButton({
    super.key,
    required this.isSending,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !enabled || isSending;
    return GestureDetector(
      onTap: disabled ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: disabled
              ? const Color(0xFFFFCDD2)
              : const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: disabled
                ? const Color(0xFFE57373)
                : const Color(0xFFB71C1C),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSending)
                  SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFFB71C1C),
                    ),
                  )
                else
                  Icon(Icons.volunteer_activism_rounded,
                      size: 24.w, color: const Color(0xFFB71C1C)),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    isSending
                        ? 'subject_home_emergency_loading'.tr
                        : 'subject_home_emergency_button'.tr,
                    style: AppTextTheme.headlineSmall(
                      color: const Color(0xFFB71C1C),
                      fw: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              'subject_home_emergency_desc'.tr,
              style: AppTextTheme.bodySmall(
                color: const Color(0xFFB71C1C).withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
