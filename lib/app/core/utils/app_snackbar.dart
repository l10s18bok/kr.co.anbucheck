import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/widgets/glass_dialog.dart';

/// 스낵바 의미 톤. 텍스트·아이콘 색만 분기하며 배경은 항상 흰색 유지.
enum SnackType {
  /// 기본 톤 — 단순 안내·중립 메시지 (기존 동작 유지).
  neutral,

  /// 정보 톤 — 성공·정상 결과 안내 (예: "구독이 복원되었습니다").
  info,

  /// 에러 톤 — 실패·문제 발생 안내 (예: "결제에 실패했습니다").
  error,
}

class AppSnackbar {
  // 다크/라이트 모드 토글과 독립적으로 동작해야 한다 (시맨틱 컬러 금지).
  // 흰 배경 + 어두운 텍스트 톤은 다크모드에서도 그대로 유지되어야 한다.
  // 다이얼로그와 같은 글래스 면(반투명 + 블러) — 면 색은 모드와 무관하게 밝게 고정하고,
  // 테두리만 모드를 따른다(라이트: 어두운 선 / 다크: 밝은 선).
  static final _bg = Colors.white.withValues(alpha: 0.78);
  static const _fgNeutral = Color(0xFF1A1C1C);
  static const _fgInfo = Color(0xFF1565C0); // PRD 알림 등급 info accentColor
  static const _fgError = Color(0xFFB71C1C); // PRD 알림 등급 urgent accentColor
  static const _duration = Duration(seconds: 3);

  static final _shadows = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.16),
      blurRadius: 40,
      offset: const Offset(0, 16),
    ),
  ];

  static Color _fgFor(SnackType type) => switch (type) {
        SnackType.neutral => _fgNeutral,
        SnackType.info => _fgInfo,
        SnackType.error => _fgError,
      };

  static IconData? _iconFor(SnackType type) => switch (type) {
        SnackType.neutral => null,
        SnackType.info => Icons.info_outline_rounded,
        SnackType.error => Icons.error_outline_rounded,
      };

  static void show(
    String title,
    String message, {
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = _duration,
    TextButton? mainButton,
    SnackType type = SnackType.neutral,
  }) {
    final fg = _fgFor(type);
    final icon = _iconFor(type);
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      duration: duration,
      backgroundColor: _bg,
      colorText: fg,
      barBlur: 24,
      borderColor: GlassColors.border,
      borderWidth: GlassColors.borderWidth,
      boxShadows: _shadows,
      borderRadius: 20,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      mainButton: mainButton,
      icon: icon == null ? null : Icon(icon, color: fg, size: 24),
    );
  }

  static void message(
    String text, {
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = _duration,
    SnackType type = SnackType.neutral,
  }) {
    final fg = _fgFor(type);
    final icon = _iconFor(type);
    Get.rawSnackbar(
      message: text,
      snackPosition: position,
      duration: duration,
      backgroundColor: _bg,
      messageText: Text(text, style: TextStyle(color: fg)),
      barBlur: 24,
      borderColor: GlassColors.border,
      borderWidth: GlassColors.borderWidth,
      boxShadows: _shadows,
      borderRadius: 20,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      icon: icon == null ? null : Icon(icon, color: fg, size: 24),
    );
  }
}
