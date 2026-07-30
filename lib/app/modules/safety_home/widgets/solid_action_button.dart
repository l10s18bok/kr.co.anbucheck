import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';

/// 안전 홈의 "동작(버튼)" 언어를 담당하는 공통 솔리드 버튼.
///
/// 정보 카드(흰 배경·평면·탭 불가)와 한눈에 구분되도록 **항상 진한 색으로 꽉 채우고
/// 흰 텍스트**를 쓰며, 채움보다 한 단계 어두운 **테두리**를 더해 눌리는 요소임을
/// 이중으로 표시한다.
///
/// ⚠️ 테두리는 **버튼 전용 표식**이다. 디자인 시스템의 "1px 실선 경계 금지" 규칙에
/// 대한 의도적 예외로, 정보 카드(`CheckStateCard`·히어로 카드)에는 절대 테두리를
/// 넣지 않는다 — 양쪽에 다 넣으면 이 구분 장치가 무의미해진다.
///
/// 비활성(연결된 보호자 없음/전송 중)일 때는 그라데이션을 걷어내고 회색 톤으로
/// 떨어뜨려 "지금은 눌리지 않음"을 색으로 알린다.
class SolidActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;

  /// 활성 상태 배경 그라데이션 (좌→우)
  final List<Color> gradient;

  /// 활성 상태 테두리 색 — 채움보다 한 단계 어두운 동일 색상 계열을 넘긴다.
  /// 테두리는 **버튼에만** 쓰는 표식이며, 정보 카드는 테두리 없이 둔다.
  final Color borderColor;

  /// 그라데이션 방향 — 기본은 좌상→우하(히어로 카드와 동일).
  /// 글자가 놓이는 쪽을 진하게 두려면 방향을 바꿔 대비를 확보한다.
  final AlignmentGeometry? gradientBegin;
  final AlignmentGeometry? gradientEnd;

  /// 라벨·설명 글자색 — 기본은 흰색(진한 채움 위).
  /// 톤 배경처럼 밝은 채움을 쓸 때는 진한 강조색을 넘긴다.
  final Color? foregroundColor;

  /// 아이콘 배지 채움색 — 기본은 반투명 흰색.
  /// 긴급 버튼처럼 아이콘을 강조색으로 띄우고 싶을 때 흰색을 넘긴다.
  final Color? iconBackgroundColor;

  /// 아이콘·스피너 색 — 기본은 흰색.
  final Color? iconColor;

  /// 라벨 최대 줄 수 — 기본 2줄.
  ///
  /// 번역문 길이는 언어마다 4배까지 차이 난다(한국어 13자 vs 프랑스어 33자).
  /// 1줄로 묶으면 프랑스어 `Modifier l'heure de c…`처럼 목적어가 통째로 잘려
  /// 무엇을 하는 버튼인지 알 수 없게 된다. 짧은 언어는 어차피 1줄이라 무영향.
  final int labelMaxLines;

  /// 설명 문구 최대 줄 수 — 기본 2줄. 위와 같은 이유.
  final int descriptionMaxLines;

  /// 진행 중 — 아이콘 자리에 스피너 표시 + 탭 차단
  final bool isBusy;
  final bool enabled;
  final VoidCallback onPressed;

  /// 3개 액션(안전 보고 / 안부 시간 변경 / 긴급 요청)의 높이를 맞추기 위한 기준값.
  /// [ScheduleRowButton]도 이 값을 참조하므로 여기만 바꾸면 셋이 함께 움직인다.
  static double get minHeight => 68.h;

  /// 아이콘 배지 지름 — 위와 같은 이유로 공유한다.
  ///
  /// 행 높이는 배지가 아니라 텍스트 2줄(18sp + 12sp ≈ 44)이 결정하므로, 이 값을
  /// 그보다 작게 줄여도 3개 버튼 높이는 그대로 유지된다.
  static double get badgeSize => 40.w;

  /// 아이콘 좌우 여백 — 버튼 안쪽 가로 패딩과 배지~텍스트 간격에 함께 쓴다.
  /// 좁힐수록 텍스트 가용 폭이 늘어 긴 번역문의 말줄임이 줄어든다.
  static double get iconGap => AppSpacing.md;

  /// 버튼 라벨 스타일 — 3개 버튼이 동일한 크기·굵기를 쓰도록 한 곳에서 정의한다.
  static TextStyle labelStyle(Color color) =>
      AppTextTheme.headlineSmall(color: color, fw: FontWeight.w700);

  /// 버튼 보조 설명 스타일.
  static TextStyle descriptionStyle(Color color) =>
      AppTextTheme.bodySmall(color: color, fw: FontWeight.w600);

  /// Teal 톤 채움색 — 안전 보고 버튼과 안부 시간 변경 행이 공유한다.
  /// 두 곳에 hex를 복사하면 한쪽만 바뀌어 어긋나므로 여기서만 정의한다.
  static Color tonalFill(bool isDark) =>
      isDark ? const Color(0xFF0A3A2A) : const Color(0xFFE0F2F1);

  /// Teal 톤 채움 위에 올라가는 글자·아이콘·테두리 강조색.
  static Color tonalAccent(bool isDark) =>
      isDark ? const Color(0xFF80CBC4) : const Color(0xFF00685E);

  /// Teal 톤 채움 위의 아이콘 배지 색.
  static Color tonalBadge(bool isDark) => isDark
      ? tonalAccent(isDark).withValues(alpha: 0.2)
      : AppColors.surfaceContainerLowest;

  const SolidActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.gradient,
    required this.borderColor,
    this.gradientBegin,
    this.gradientEnd,
    this.foregroundColor,
    this.iconBackgroundColor,
    this.iconColor,
    this.labelMaxLines = 2,
    this.descriptionMaxLines = 2,
    required this.isBusy,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !enabled || isBusy;
    final radius = BorderRadius.circular(12.r);
    final foreground = disabled
        ? AppColors.textTertiary
        : (foregroundColor ?? Colors.white);
    // 비활성일 때는 강조 지정을 무시하고 회색 톤으로 통일한다.
    final badgeFill = disabled
        ? Colors.transparent
        : (iconBackgroundColor ?? Colors.white.withValues(alpha: 0.18));
    final badgeForeground =
        disabled ? AppColors.textTertiary : (iconColor ?? Colors.white);

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: disabled
              ? null
              : LinearGradient(
                  colors: gradient,
                  // 기본은 히어로 카드와 같은 대각선(좌상→우하) — 좌우 방향보다
                  // 이동 거리가 길어 색 변화가 눈에 들어온다.
                  // 단색 채움(톤 버튼)은 영향 없음.
                  begin: gradientBegin ?? Alignment.topLeft,
                  end: gradientEnd ?? Alignment.bottomRight,
                ),
          color: disabled ? AppColors.surfaceContainerHigh : null,
          borderRadius: radius,
          border: Border.all(
            color: disabled ? AppColors.outlineVariant : borderColor,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: disabled ? null : onPressed,
          child: Container(
            // 디자인 시스템 최소 버튼 높이(64px) 보장
            constraints: BoxConstraints(minHeight: minHeight),
            padding: EdgeInsets.symmetric(
              vertical: 14.h,
              horizontal: iconGap,
            ),
            child: Row(
              children: [
                Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    color: badgeFill,
                    shape: BoxShape.circle,
                  ),
                  child: isBusy
                      ? Padding(
                          padding: EdgeInsets.all(11.w),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: badgeForeground,
                          ),
                        )
                      : Icon(icon, size: 24.w, color: badgeForeground),
                ),
                SizedBox(width: iconGap),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: labelStyle(foreground),
                        maxLines: labelMaxLines,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        description,
                        style: descriptionStyle(
                          foreground.withValues(alpha: 0.85),
                        ),
                        maxLines: descriptionMaxLines,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
