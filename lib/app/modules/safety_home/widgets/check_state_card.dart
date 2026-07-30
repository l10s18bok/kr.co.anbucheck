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
    final accent = switch (state) {
      'reported' =>
        isDark ? const Color(0xFF4DB6AC) : const Color(0xFF00685E),
      'waiting' =>
        isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
      _ => AppColors.textSecondary,
    };
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
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: isDark ? 0.24 : 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(iconData, size: 26.w, color: accent),
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
