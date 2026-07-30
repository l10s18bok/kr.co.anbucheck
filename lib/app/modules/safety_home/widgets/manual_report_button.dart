import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/modules/safety_home/widgets/solid_action_button.dart';

/// 지금 바로 안전 보고하기 버튼 (수동 heartbeat 전송)
///
/// 아래 "안부 시간 변경" 행과 **같은 Teal 톤 채움**을 쓴다 —
/// 색·강조색·아이콘 배지 모두 [SolidActionButton]의 tonal* 헬퍼에서 가져오므로
/// 한쪽만 바뀌어 어긋나는 일이 없다.
class ManualReportButton extends StatelessWidget {
  final bool isReporting;
  final bool enabled;
  final bool isDark;
  final VoidCallback onPressed;

  const ManualReportButton({
    super.key,
    required this.isReporting,
    required this.enabled,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final fill = SolidActionButton.tonalFill(isDark);
    final accent = SolidActionButton.tonalAccent(isDark);

    return SolidActionButton(
      icon: Icons.verified_user_rounded,
      label: isReporting
          ? 'subject_home_report_loading'.tr
          : 'subject_home_report_button'.tr,
      description: 'subject_home_report_desc'.tr,
      gradient: [fill, fill],
      borderColor: accent.withValues(alpha: 0.45),
      // 설명은 2줄까지 — 긴 번역문이 단어 중간에서 끊기지 않게 한다.
      // 짧은 언어(한국어 등)는 1줄에 들어와 높이가 그대로다.
      descriptionMaxLines: 2,
      foregroundColor: accent,
      iconBackgroundColor: SolidActionButton.tonalBadge(isDark),
      iconColor: accent,
      isBusy: isReporting,
      enabled: enabled,
      onPressed: onPressed,
    );
  }
}
