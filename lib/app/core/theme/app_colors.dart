import 'package:flutter/material.dart';

/// Anbu 디자인 시스템 컬러
/// 대상자 모드(Teal) / 보호자 모드(Indigo) 듀얼 모드 지원
abstract class AppColors {
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
  // Surface 계층 (Tonal Layering)
  // ──────────────────────────────────────────
  static const Color surface = Color(0xFFF9F9F9);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFEDEDED);
  static const Color surfaceContainerHigh = Color(0xFFE6E6E6);
  static const Color surfaceContainerHighest = Color(0xFFE0E0E0);

  // ──────────────────────────────────────────
  // 텍스트 (순수 검정 #000000 금지)
  // ──────────────────────────────────────────
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color onSurfaceVariant = Color(0xFF3F4948);
  static const Color textPrimary = Color(0xFF1A1C1C);
  static const Color textSecondary = Color(0xFF3F4948);
  static const Color textTertiary = Color(0xFF757575);

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
  // 아웃라인 / 구분선
  // ──────────────────────────────────────────
  static const Color outline = Color(0xFF6F7978);
  static const Color outlineVariant = Color(0xFFBEC9C7);

  // Glassmorphism용
  static const Color glassSurface = Color(0xCCF9F9F9); // surface 80%
}
