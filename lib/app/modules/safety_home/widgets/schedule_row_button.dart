import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/modules/safety_home/widgets/solid_action_button.dart';

/// 안부 확인 시각 변경 — safety_home 전용 설정 행 버튼.
///
/// 주 동작(안전 보고)·긴급 동작과 달리 부차적인 설정이므로 솔리드로 채우지 않고
/// Teal 톤 배경을 쓰되, **가로 배치 + 우측 화살표(chevron)**로 "탭하면 다음이 열림"을
/// 드러내 정보 카드와 구분한다.
///
/// 공용 위젯 [HeartbeatScheduleTile]을 쓰지 않는 이유: 그 위젯은 보호자 알림설정의
/// DND 시작/종료 타일로 반쪽 너비 2개가 나란히 배치되어 세로 레이아웃이 필수다.
/// 여기서 가로 행으로 바꾸면 그 화면이 깨지므로 화면 전용 위젯으로 분리했다.
class ScheduleRowButton extends StatelessWidget {
  final String heartbeatTime;
  final bool enabled;
  final bool isDark;
  final VoidCallback onTap;

  const ScheduleRowButton({
    super.key,
    required this.heartbeatTime,
    required this.enabled,
    required this.isDark,
    required this.onTap,
  });

  String get _label => Platform.isIOS
      ? 'heartbeat_schedule_change_title_ios'.tr
      : 'heartbeat_schedule_change'.tr;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.r);
    // 안전 보고 버튼과 동일한 톤 팔레트를 공유한다(단일 소스).
    final accent = enabled
        ? SolidActionButton.tonalAccent(isDark)
        : AppColors.textTertiary;
    final background = enabled
        ? SolidActionButton.tonalFill(isDark)
        : AppColors.surfaceContainerHigh;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: background,
          borderRadius: radius,
          // 테두리는 버튼임을 알리는 표식 — 정보 카드에는 쓰지 않는다.
          border: Border.all(
            color: enabled
                ? accent.withValues(alpha: 0.45)
                : AppColors.outlineVariant,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: enabled ? onTap : null,
          child: Container(
            // 높이·아이콘 배지·글자 크기를 SolidActionButton과 공유해
            // 3개 액션 버튼이 항상 같은 크기로 보이게 한다.
            constraints: BoxConstraints(
              minHeight: SolidActionButton.minHeight,
            ),
            padding: EdgeInsets.symmetric(
              vertical: 14.h,
              horizontal: AppSpacing.lg,
            ),
            child: Row(
              children: [
                Container(
                  width: SolidActionButton.badgeSize,
                  height: SolidActionButton.badgeSize,
                  decoration: BoxDecoration(
                    color: SolidActionButton.tonalBadge(isDark),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    size: 24.w,
                    color: accent,
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _label,
                        style: SolidActionButton.labelStyle(accent),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'heartbeat_daily_time'.trParams({
                          'time': heartbeatTime,
                        }),
                        style: SolidActionButton.descriptionStyle(
                          accent.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 24.w,
                  color: accent.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
