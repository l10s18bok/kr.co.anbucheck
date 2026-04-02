import 'package:flutter/material.dart';

/// Anbu 테마 시스템
/// - 대상자 모드(Teal): seniorTheme / seniorDarkTheme
/// - 보호자 모드(Indigo): guardianTheme / guardianDarkTheme
/// - No-Line Rule: divider 투명 처리
/// - Tonal Layering: surface 계층으로 깊이 표현
abstract class AppTheme {
  // ──────────────────────────────────────────
  // 라이트 모드 Surface 상수 (const ColorScheme용)
  // ──────────────────────────────────────────
  static const _lightSurface = Color(0xFFF9F9F9);
  static const _lightSurfaceContainerLow = Color(0xFFF3F3F3);
  static const _lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const _lightSurfaceContainer = Color(0xFFEDEDED);
  static const _lightSurfaceContainerHigh = Color(0xFFE6E6E6);
  static const _lightSurfaceContainerHighest = Color(0xFFE0E0E0);
  static const _lightOnSurface = Color(0xFF1A1C1C);
  static const _lightOnSurfaceVariant = Color(0xFF3F4948);
  static const _lightOutline = Color(0xFF6F7978);
  static const _lightOutlineVariant = Color(0xFFBEC9C7);
  static const _error = Color(0xFFBA1A1A);
  static const _errorContainer = Color(0xFFFFDAD6);
  static const _onErrorContainer = Color(0xFF410002);

  // ──────────────────────────────────────────
  // 다크 모드 Surface 상수
  // ──────────────────────────────────────────
  static const _darkSurface = Color(0xFF121212);
  static const _darkSurfaceContainerLow = Color(0xFF1A1A1A);
  static const _darkSurfaceContainerLowest = Color(0xFF0E0E0E);
  static const _darkSurfaceContainer = Color(0xFF222222);
  static const _darkSurfaceContainerHigh = Color(0xFF2C2C2C);
  static const _darkSurfaceContainerHighest = Color(0xFF363636);
  static const _darkOnSurface = Color(0xFFE6E6E6);
  static const _darkOnSurfaceVariant = Color(0xFFB0B0B0);
  static const _darkOutline = Color(0xFF5A5A5A);
  static const _darkOutlineVariant = Color(0xFF3A3A3A);
  static const _darkErrorContainer = Color(0xFF93000A);

  /// 대상자 모드 테마 (Teal)
  static ThemeData get seniorTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF00685E),
        scaffoldBackgroundColor: _lightSurface,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF00685E),
          primaryContainer: Color(0xFF008377),
          onPrimary: Color(0xFFFFFFFF),
          primaryFixed: Color(0xFF70F5E2),
          secondary: Color(0xFF008377),
          error: _error,
          errorContainer: _errorContainer,
          onErrorContainer: _onErrorContainer,
          surface: _lightSurface,
          surfaceContainerLow: _lightSurfaceContainerLow,
          surfaceContainerLowest: _lightSurfaceContainerLowest,
          surfaceContainer: _lightSurfaceContainer,
          surfaceContainerHigh: _lightSurfaceContainerHigh,
          surfaceContainerHighest: _lightSurfaceContainerHighest,
          onSurface: _lightOnSurface,
          onSurfaceVariant: _lightOnSurfaceVariant,
          outline: _lightOutline,
          outlineVariant: _lightOutlineVariant,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: _lightOnSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        dividerColor: Colors.transparent,
        dividerTheme: const DividerThemeData(color: Colors.transparent),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00685E),
            foregroundColor: const Color(0xFFFFFFFF),
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF00685E),
            foregroundColor: const Color(0xFFFFFFFF),
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF00685E),
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            side: BorderSide(color: _lightOutlineVariant.withValues(alpha: 0.15)),
          ),
        ),
        cardTheme: CardThemeData(
          color: _lightSurfaceContainerLowest,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _lightSurfaceContainerHighest,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00685E), width: 2),
          ),
        ),
      );

  /// 보호자 모드 테마 (Indigo)
  static ThemeData get guardianTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF4355B9),
        scaffoldBackgroundColor: _lightSurface,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4355B9),
          primaryContainer: Color(0xFF5B6DC7),
          onPrimary: Color(0xFFFFFFFF),
          primaryFixed: Color(0xFFDDE1FF),
          secondary: Color(0xFF5B6DC7),
          error: _error,
          errorContainer: _errorContainer,
          onErrorContainer: _onErrorContainer,
          surface: _lightSurface,
          surfaceContainerLow: _lightSurfaceContainerLow,
          surfaceContainerLowest: _lightSurfaceContainerLowest,
          surfaceContainer: _lightSurfaceContainer,
          surfaceContainerHigh: _lightSurfaceContainerHigh,
          surfaceContainerHighest: _lightSurfaceContainerHighest,
          onSurface: _lightOnSurface,
          onSurfaceVariant: _lightOnSurfaceVariant,
          outline: _lightOutline,
          outlineVariant: _lightOutlineVariant,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: _lightOnSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        dividerColor: Colors.transparent,
        dividerTheme: const DividerThemeData(color: Colors.transparent),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4355B9),
            foregroundColor: const Color(0xFFFFFFFF),
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF4355B9),
            foregroundColor: const Color(0xFFFFFFFF),
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4355B9),
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            side: BorderSide(color: _lightOutlineVariant.withValues(alpha: 0.15)),
          ),
        ),
        cardTheme: CardThemeData(
          color: _lightSurfaceContainerLowest,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _lightSurfaceContainerHighest,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4355B9), width: 2),
          ),
        ),
      );

  /// 대상자 모드 다크 테마 (Teal)
  static ThemeData get seniorDarkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF70F5E2),
        scaffoldBackgroundColor: _darkSurface,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF70F5E2),
          primaryContainer: Color(0xFF008377),
          onPrimary: Color(0xFF003731),
          primaryFixed: Color(0xFF70F5E2),
          secondary: Color(0xFF008377),
          error: _error,
          errorContainer: _darkErrorContainer,
          onErrorContainer: _errorContainer,
          surface: _darkSurface,
          surfaceContainerLow: _darkSurfaceContainerLow,
          surfaceContainerLowest: _darkSurfaceContainerLowest,
          surfaceContainer: _darkSurfaceContainer,
          surfaceContainerHigh: _darkSurfaceContainerHigh,
          surfaceContainerHighest: _darkSurfaceContainerHighest,
          onSurface: _darkOnSurface,
          onSurfaceVariant: _darkOnSurfaceVariant,
          outline: _darkOutline,
          outlineVariant: _darkOutlineVariant,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: _darkOnSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        dividerColor: Colors.transparent,
        dividerTheme: const DividerThemeData(color: Colors.transparent),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF70F5E2),
            foregroundColor: const Color(0xFF003731),
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF70F5E2),
            foregroundColor: const Color(0xFF003731),
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF70F5E2),
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            side: BorderSide(color: _darkOutlineVariant.withValues(alpha: 0.3)),
          ),
        ),
        cardTheme: CardThemeData(
          color: _darkSurfaceContainerLow,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _darkSurfaceContainerHigh,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF70F5E2), width: 2),
          ),
        ),
      );

  /// 보호자 모드 다크 테마 (Indigo)
  static ThemeData get guardianDarkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFDDE1FF),
        scaffoldBackgroundColor: _darkSurface,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFDDE1FF),
          primaryContainer: Color(0xFF5B6DC7),
          onPrimary: Color(0xFF1B2D82),
          primaryFixed: Color(0xFFDDE1FF),
          secondary: Color(0xFF5B6DC7),
          error: _error,
          errorContainer: _darkErrorContainer,
          onErrorContainer: _errorContainer,
          surface: _darkSurface,
          surfaceContainerLow: _darkSurfaceContainerLow,
          surfaceContainerLowest: _darkSurfaceContainerLowest,
          surfaceContainer: _darkSurfaceContainer,
          surfaceContainerHigh: _darkSurfaceContainerHigh,
          surfaceContainerHighest: _darkSurfaceContainerHighest,
          onSurface: _darkOnSurface,
          onSurfaceVariant: _darkOnSurfaceVariant,
          outline: _darkOutline,
          outlineVariant: _darkOutlineVariant,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: _darkOnSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        dividerColor: Colors.transparent,
        dividerTheme: const DividerThemeData(color: Colors.transparent),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDDE1FF),
            foregroundColor: const Color(0xFF1B2D82),
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFDDE1FF),
            foregroundColor: const Color(0xFF1B2D82),
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFDDE1FF),
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            side: BorderSide(color: _darkOutlineVariant.withValues(alpha: 0.3)),
          ),
        ),
        cardTheme: CardThemeData(
          color: _darkSurfaceContainerLow,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _darkSurfaceContainerHigh,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDE1FF), width: 2),
          ),
        ),
      );

  /// 기존 호환용 (앱 초기 로딩 시 기본 테마)
  static ThemeData get lightTheme => seniorTheme;
  static ThemeData get darkTheme => seniorDarkTheme;
}
