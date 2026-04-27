import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';

/// 위치 권한 거부 경고 위젯 (긴급 첨부용)
/// 권한 허용 상태면 [SizedBox.shrink]로 공간을 차지하지 않는다.
/// 탭 시 컨트롤러가 권한 재요청 또는 설정 이동 다이얼로그를 띄운다.
class LocationPermissionWarning extends StatelessWidget {
  final bool denied;
  final VoidCallback onTap;

  const LocationPermissionWarning({
    super.key,
    required this.denied,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!denied) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 48.h),
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFB71C1C).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 20.w, color: const Color(0xFFB71C1C)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'location_permission_warning'.tr,
                    style: AppTextTheme.bodySmall(
                      color: const Color(0xFFB71C1C),
                      fw: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
