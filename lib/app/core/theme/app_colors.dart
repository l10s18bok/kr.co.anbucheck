import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/services/theme_service.dart';

/// Anbu 디자인 시스템 컬러
/// 대상자 모드(Teal) / 보호자 모드(Indigo) 듀얼 모드 지원
/// Surface·텍스트·아웃라인은 다크모드 자동 전환
abstract class AppColors {
  // ──────────────────────────────────────────
  // 다크모드 판별 — ThemeService.isDarkMode 즉시 반영
  // ──────────────────────────────────────────
  static bool get _isDark => Get.find<ThemeService>().isDarkMode.value;
  static bool get isDark => _isDark;

  // ──────────────────────────────────────────
  // 대상자 모드 (Senior Mode - Teal)
  // ──────────────────────────────────────────
  static const Color seniorPrimary = Color(0xFF00685E);
  static const Color seniorPrimaryContainer = Color(0xFF008377);
  static const Color seniorOnPrimary = Color(0xFFFFFFFF);
  static const Color seniorPrimaryFixed = Color(0xFF70F5E2);

  // ──────────────────────────────────────────
  // 보호자 모드 (Guardian Mode - Indigo)
  // ──────────────────────────────────────────
  static const Color guardianPrimary = Color(0xFF4355B9);
  static const Color guardianPrimaryContainer = Color(0xFF5B6DC7);
  static const Color guardianOnPrimary = Color(0xFFFFFFFF);
  static const Color guardianPrimaryFixed = Color(0xFFDDE1FF);

  // ──────────────────────────────────────────
  // Surface 계층 (Tonal Layering) — 다크모드 자동 전환
  // ──────────────────────────────────────────
  static Color get surface =>
      _isDark ? const Color(0xFF121212) : const Color(0xFFF9F9F9);
  static Color get surfaceContainerLow =>
      _isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF3F3F3);
  static Color get surfaceContainerLowest =>
      _isDark ? const Color(0xFF0E0E0E) : const Color(0xFFFFFFFF);
  static Color get surfaceContainer =>
      _isDark ? const Color(0xFF222222) : const Color(0xFFEDEDED);
  static Color get surfaceContainerHigh =>
      _isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE6E6E6);
  static Color get surfaceContainerHighest =>
      _isDark ? const Color(0xFF363636) : const Color(0xFFE0E0E0);

  // ──────────────────────────────────────────
  // 텍스트 (순수 검정 #000000 금지) — 다크모드 자동 전환
  // ──────────────────────────────────────────
  static Color get onSurface =>
      _isDark ? const Color(0xFFE6E6E6) : const Color(0xFF1A1C1C);
  static Color get onSurfaceVariant =>
      _isDark ? const Color(0xFFB0B0B0) : const Color(0xFF3F4948);
  static Color get textPrimary =>
      _isDark ? const Color(0xFFE6E6E6) : const Color(0xFF1A1C1C);
  static Color get textSecondary =>
      _isDark ? const Color(0xFFB0B0B0) : const Color(0xFF3F4948);
  static Color get textTertiary =>
      _isDark ? const Color(0xFF8A8A8A) : const Color(0xFF757575);

  // ──────────────────────────────────────────
  // 상태 컬러
  // ──────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);
  static const Color success = Color(0xFF4CAF50);
  static const Color successContainer = Color(0xFFC8E6C9);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningContainer = Color(0xFFFFF8E1);

  // 알림 레벨별 컬러
  static const Color alertInfo = Color(0xFF2196F3);
  static const Color alertCaution = Color(0xFFFFC107);
  static const Color alertWarning = Color(0xFFFF9800);
  static const Color alertUrgent = Color(0xFFF44336);

  // ──────────────────────────────────────────
  // 아웃라인 / 구분선 — 다크모드 자동 전환
  // ──────────────────────────────────────────
  static Color get outline =>
      _isDark ? const Color(0xFF5A5A5A) : const Color(0xFF6F7978);
  static Color get outlineVariant =>
      _isDark ? const Color(0xFF3A3A3A) : const Color(0xFFBEC9C7);

  // Glassmorphism용
  static Color get glassSurface =>
      _isDark ? const Color(0xCC121212) : const Color(0xCCF9F9F9);
}
