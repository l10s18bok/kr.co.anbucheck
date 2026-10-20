import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/widgets/glass_dialog.dart';

/// 스낵바 의미 톤. 텍스트·아이콘 색만 분기한다(면은 글래스, 모드 대응).
enum SnackType {
  /// 기본 톤 — 단순 안내·중립 메시지 (기존 동작 유지).
  neutral,

  /// 정보 톤 — 성공·정상 결과 안내 (예: "구독이 복원되었습니다").
  info,

  /// 에러 톤 — 실패·문제 발생 안내 (예: "결제에 실패했습니다").
  error,
}

class AppSnackbar {
  // 다이얼로그와 같은 글래스 면(반투명 + 블러). 면·글자색은 모드를 따른다(2026-10-20 사용자 결정 —
  // 이전의 "모드와 무관한 고정 톤" 규칙을 다이얼로그와 같은 모드 대응으로 바꿨다).
  static Color get _bg => AppColors.isDark
      ? const Color(0xFF24262B).withValues(alpha: 0.78)
      : Colors.white.withValues(alpha: 0.78);
  static const _duration = Duration(seconds: 3);

  static final _shadows = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.16),
      blurRadius: 40,
      offset: const Offset(0, 16),
    ),
  ];

  static Color _fgFor(SnackType type) {
    final dark = AppColors.isDark;
    return switch (type) {
      SnackType.neutral => dark ? Colors.white : const Color(0xFF1A1C1C),
      SnackType.info => dark ? const Color(0xFF64B5F6) : const Color(0xFF1565C0),
      SnackType.error => dark ? const Color(0xFFFF8A80) : const Color(0xFFB71C1C),
    };
  }

  static IconData? _iconFor(SnackType type) => switch (type) {
        SnackType.neutral => null,
        SnackType.info => Icons.info_outline_rounded,
        SnackType.error => Icons.error_outline_rounded,
      };

  // ── 스낵바가 떠 있는 동안 화면 전체에 깔리는 글래스 배경(블러 + 깨진 유리) ──
  // 모달이 아니라 터치는 그대로 통과한다(IgnorePointer). 스낵바보다 먼저 삽입해야 스낵바가 위에 그려진다.
  static OverlayEntry? _scrim;
  static final ValueNotifier<bool> _scrimOn = ValueNotifier<bool>(false);
  static int _scrimToken = 0;

  static void _showScrim(Duration duration) {
    // 스낵바 자신이 들어가는 오버레이(GetX 내비게이터의 것)에 넣는다 — 같은 곳이라야 순서가 보장된다.
    final overlay = Get.key.currentState?.overlay;
    if (overlay == null) return;
    _scrimToken++;
    if (_scrim == null) {
      _scrim = OverlayEntry(
        builder: (_) => IgnorePointer(
          child: ValueListenableBuilder<bool>(
            valueListenable: _scrimOn,
            builder: (_, on, _) => AnimatedOpacity(
              opacity: on ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: const GlassBackdrop(child: SizedBox.shrink()),
            ),
          ),
        ),
      );
      overlay.insert(_scrim!);
    }
    _scrimOn.value = true;
    // 스낵바가 큐에 밀리거나 취소돼 닫힘 신호가 안 와도 배경이 남지 않게 하는 안전장치.
    final token = _scrimToken;
    Future<void>.delayed(duration + const Duration(seconds: 2), () {
      if (token == _scrimToken) _hideScrim();
    });
  }

  static void _hideScrim() {
    _scrimOn.value = false;
    final token = ++_scrimToken;
    Future<void>.delayed(const Duration(milliseconds: 320), () {
      if (token == _scrimToken && !_scrimOn.value) {
        _scrim?.remove();
        _scrim = null;
      }
    });
  }

  static void _onStatus(SnackbarStatus? status) {
    if (status == SnackbarStatus.CLOSING || status == SnackbarStatus.CLOSED) {
      _hideScrim();
    }
  }

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
    _showScrim(duration);
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
      snackbarStatus: _onStatus,
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
    _showScrim(duration);
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
      snackbarStatus: _onStatus,
    );
  }
}
