import 'package:flutter/material.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';

/// Anbu 테마 시스템
/// - 대상자 모드(Teal): seniorTheme
/// - 보호자 모드(Indigo): guardianTheme
/// - No-Line Rule: divider 투명 처리
/// - Tonal Layering: surface 계층으로 깊이 표현
abstract class AppTheme {
  /// 대상자 모드 테마 (Teal)
  static ThemeData get seniorTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: AppColors.seniorPrimary,
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: const ColorScheme.light(
          primary: AppColors.seniorPrimary,
          primaryContainer: AppColors.seniorPrimaryContainer,
          onPrimary: AppColors.seniorOnPrimary,
          primaryFixed: AppColors.seniorPrimaryFixed,
          secondary: AppColors.seniorPrimaryContainer,
          error: AppColors.error,
          errorContainer: AppColors.errorContainer,
          onErrorContainer: AppColors.onErrorContainer,
          surface: AppColors.surface,
          surfaceContainerLow: AppColors.surfaceContainerLow,
          surfaceContainerLowest: AppColors.surfaceContainerLowest,
          surfaceContainer: AppColors.surfaceContainer,
          surfaceContainerHigh: AppColors.surfaceContainerHigh,
          surfaceContainerHighest: AppColors.surfaceContainerHighest,
          onSurface: AppColors.onSurface,
          onSurfaceVariant: AppColors.onSurfaceVariant,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        // No-Line Rule: divider 투명 처리
        dividerColor: Colors.transparent,
        dividerTheme: const DividerThemeData(color: Colors.transparent),
        // 버튼: rounded-xl, 최소 64px 높이
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.seniorPrimary,
            foregroundColor: AppColors.seniorOnPrimary,
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.seniorPrimary,
            foregroundColor: AppColors.seniorOnPrimary,
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.seniorPrimary,
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            side: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.15),
            ),
          ),
        ),
        // 카드: Tonal Layering
        cardTheme: CardThemeData(
          color: AppColors.surfaceContainerLowest,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
        ),
        // 입력 필드: filled 스타일
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.seniorPrimary,
              width: 2,
            ),
          ),
        ),
      );

  /// 보호자 모드 테마 (Indigo)
  static ThemeData get guardianTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: AppColors.guardianPrimary,
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: const ColorScheme.light(
          primary: AppColors.guardianPrimary,
          primaryContainer: AppColors.guardianPrimaryContainer,
          onPrimary: AppColors.guardianOnPrimary,
          primaryFixed: AppColors.guardianPrimaryFixed,
          secondary: AppColors.guardianPrimaryContainer,
          error: AppColors.error,
          errorContainer: AppColors.errorContainer,
          onErrorContainer: AppColors.onErrorContainer,
          surface: AppColors.surface,
          surfaceContainerLow: AppColors.surfaceContainerLow,
          surfaceContainerLowest: AppColors.surfaceContainerLowest,
          surfaceContainer: AppColors.surfaceContainer,
          surfaceContainerHigh: AppColors.surfaceContainerHigh,
          surfaceContainerHighest: AppColors.surfaceContainerHighest,
          onSurface: AppColors.onSurface,
          onSurfaceVariant: AppColors.onSurfaceVariant,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        dividerColor: Colors.transparent,
        dividerTheme: const DividerThemeData(color: Colors.transparent),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.guardianPrimary,
            foregroundColor: AppColors.guardianOnPrimary,
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.guardianPrimary,
            foregroundColor: AppColors.guardianOnPrimary,
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.guardianPrimary,
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            side: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.15),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceContainerLowest,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.guardianPrimary,
              width: 2,
            ),
          ),
        ),
      );

  /// 기존 호환용 (앱 초기 로딩 시 기본 테마)
  static ThemeData get lightTheme => seniorTheme;
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: AppColors.seniorPrimary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.seniorPrimary,
          secondary: AppColors.seniorPrimaryContainer,
          error: AppColors.error,
        ),
      );
}
