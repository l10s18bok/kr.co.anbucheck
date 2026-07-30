import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';

/// 안부 확인 상태 카드 — 보고 완료 / 보고 예정 / 보고 대기 중
/// state: 'reported' | 'pending' | 'waiting'
///
/// **정보 카드**이므로 버튼 언어(진한 솔리드 채움)를 절대 쓰지 않는다.
/// 흰 배경 + 좌측 4px 상태 액센트 바 + 원형 아이콘 배지로 구성해
/// "읽는 것"임을 드러낸다. 이전에는 연녹색 톤 박스였는데 같은 톤을 쓰던
/// 시각 변경 버튼과 구분되지 않아 흰 카드로 분리했다.
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
    final iconData = switch (state) {
      'reported' => Icons.check_rounded,
      'waiting' => Icons.hourglass_top_rounded,
      _ => Icons.schedule_rounded,
    };
    // 좌측 바·본문 텍스트 — 상태별 색으로 구분한다.
    final accent = switch (state) {
      'reported' =>
        isDark ? const Color(0xFF4DB6AC) : const Color(0xFF00685E),
      'waiting' =>
        isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
      _ => AppColors.textSecondary,
    };
    // 아이콘과 그 배지만 별도 색 — 상태와 무관하게 항상 무채색.
    // (좌측 바가 상태를 알려주므로 아이콘까지 상태별로 나눌 필요가 없다)
    // 순수 검정(#000000)은 디자인 시스템에서 금지 — onSurface(#1A1C1C)를 쓰며
    // 다크모드에서는 자동으로 밝은 색으로 뒤집힌다.
    final iconAccent = AppColors.onSurface;
    final radius = BorderRadius.circular(12.r);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: double.infinity,
        color: AppColors.surfaceContainerLowest,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 좌측 상태 액센트 바 (보호자 경고 카드와 동일한 표현 규칙)
              Container(width: 5.w, color: accent),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        // 액션 버튼의 **아이콘**(24)만 한 지름 — 버튼 배지(40)와
                        // 같은 크기로 두면 정보 카드가 액션과 같은 무게로 읽힌다.
                        // 카드 높이는 텍스트 2줄(≈44)이 정하므로 이 값과 무관.
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          // 핑크보다 한 단계 옅은 블러시 — 아이콘(무채색)과 대비는
                          // 유지하면서 카드 안에서 튀지 않는 수준.
                          // 테두리는 두지 않는다(버튼 전용 표식).
                          color: isDark
                              ? const Color(0xFFB71C1C).withValues(alpha: 0.22)
                              : const Color(0xFFFDECEC),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(iconData, size: 16.w, color: iconAccent),
                      ),
                      SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTextTheme.bodySmall(
                                  color: AppColors.textTertiary),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              body,
                              style: AppTextTheme.headlineSmall(
                                  color: accent, fw: FontWeight.w700),
                            ),
                          ],
                        ),
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
