import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';

/// 배터리 사용 제한 해제 권장 위젯
/// 제한 없음 상태면 [SizedBox.shrink]로 공간을 차지하지 않는다.
/// 탭 시 OS 앱 정보 설정으로 직행 (상세 다이얼로그 없음).
///
/// 활동/위치 권한 경고가 빨간색(에러)인 반면 배터리는 작동 자체는 되지만
/// 지연이 발생하는 권장 사항이므로 노란/주황 계열 톤을 사용한다.
class BatteryOptimizationWarning extends StatelessWidget {
  final bool needsAction;
  final VoidCallback onTap;

  const BatteryOptimizationWarning({
    super.key,
    required this.needsAction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!needsAction) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
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
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFF9A825).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.battery_alert,
                    size: 20.w, color: const Color(0xFFE65100)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'stability_battery_warning_short'.tr,
                    style: AppTextTheme.bodySmall(
                      color: const Color(0xFFB75A00),
                      fw: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right,
                    size: 20.w, color: const Color(0xFFB75A00)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
