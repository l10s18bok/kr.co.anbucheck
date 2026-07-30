import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/modules/safety_home/widgets/solid_action_button.dart';

/// 긴급 도움 요청 버튼 — 보호자 전원에게 즉시 urgent Push 발송
///
/// 긴급 등급 색(#B71C1C) 솔리드 + 딥 레드 테두리로 한눈에 "누르는 것"임을 알린다.
/// 이전에는 연한 배경에 테두리만 있어 상태 카드와 잘 구분되지 않았다.
/// 오탭은 전송 전 확인 다이얼로그가 막는다.
class EmergencyButton extends StatelessWidget {
  final bool isSending;
  final bool enabled;
  final VoidCallback onPressed;

  /// 설명 최대 줄 수 — 기본 2줄.
  /// 긴 번역문이 단어 중간에서 끊기지 않도록 안전 홈·온보딩 모두 2줄을 쓴다.
  final int descriptionMaxLines;

  const EmergencyButton({
    super.key,
    required this.isSending,
    required this.enabled,
    required this.onPressed,
    this.descriptionMaxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SolidActionButton(
      icon: Icons.volunteer_activism_rounded,
      label: isSending
          ? 'subject_home_emergency_loading'.tr
          : 'subject_home_emergency_button'.tr,
      description: 'subject_home_emergency_desc'.tr,
      // 좌하(진함) → 우상(연함) 대각선.
      //
      // 방향을 이렇게 잡은 이유: 12sp 설명 문구가 버튼 **좌하단**에 놓이므로,
      // 가장 진한 영역이 그 위로 오면 작은 글씨 대비가 확보된다(#6E2020에서 11:1).
      // 덕분에 연한 쪽을 #AC5C5C → #C07878까지 밝힐 수 있었다 — 가장 밝은 우상단
      // 모서리에는 글자가 없고, 라벨(18sp bold)은 large text 기준 3:1을 넘긴다.
      gradient: const [Color(0xFF6E2020), Color(0xFFC07878)],
      gradientBegin: Alignment.bottomLeft,
      gradientEnd: Alignment.topRight,
      borderColor: const Color(0xFF571818),
      // 아이콘 배지만 흰색으로 뒤집어 아이콘 자체를 붉은색으로 강조한다.
      // (라벨은 붉은 배경 위 붉은 글씨가 되어 읽히지 않으므로 흰색 유지)
      iconBackgroundColor: Colors.white,
      iconColor: const Color(0xFF8F3030),
      descriptionMaxLines: descriptionMaxLines,
      isBusy: isSending,
      enabled: enabled,
      onPressed: onPressed,
    );
  }
}
