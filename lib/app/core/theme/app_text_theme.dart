import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';

/// Anbu 타이포그래피 시스템
/// Display/Headlines: Plus Jakarta Sans (고급스러운 느낌)
/// Body/Labels: Lexend (고령자 가독성 최적화)
///
/// 현재는 시스템 폰트 사용, 추후 커스텀 폰트 적용 시 fontFamily 변경
abstract class AppTextTheme {
  // ──────────────────────────────────────────
  // Display (큰 제목, 인사말 등)
  // ──────────────────────────────────────────
  static TextStyle displayLarge({Color? color, FontWeight? fw}) => TextStyle(
        fontSize: 32.sp,
        fontWeight: fw ?? FontWeight.w700,
        color: color ?? AppColors.textPrimary,
        height: 1.25,
      );

  static TextStyle displaySmall({Color? color, FontWeight? fw}) => TextStyle(
        fontSize: 28.sp,
        fontWeight: fw ?? FontWeight.w700,
        color: color ?? AppColors.textPrimary,
        height: 1.29,
      );

  // ──────────────────────────────────────────
  // Headline (섹션 제목)
  // ──────────────────────────────────────────
  static TextStyle headlineLarge({Color? color, FontWeight? fw}) => TextStyle(
        fontSize: 24.sp,
        fontWeight: fw ?? FontWeight.w700,
        color: color ?? AppColors.textPrimary,
        height: 1.33,
      );

  static TextStyle headlineMedium({Color? color, FontWeight? fw}) => TextStyle(
        fontSize: 20.sp,
        fontWeight: fw ?? FontWeight.w600,
        color: color ?? AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle headlineSmall({Color? color, FontWeight? fw}) => TextStyle(
        fontSize: 18.sp,
        fontWeight: fw ?? FontWeight.w600,
        color: color ?? AppColors.textPrimary,
        height: 1.44,
      );

  // ──────────────────────────────────────────
  // Body (본문, 상태 업데이트)
  // ──────────────────────────────────────────
  static TextStyle bodyLarge({Color? color, FontWeight? fw}) => TextStyle(
        fontSize: 16.sp,
        fontWeight: fw ?? FontWeight.w400,
        color: color ?? AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle bodyMedium({Color? color, FontWeight? fw}) => TextStyle(
        fontSize: 14.sp,
        fontWeight: fw ?? FontWeight.w400,
        color: color ?? AppColors.textSecondary,
        height: 1.43,
      );

  static TextStyle bodySmall({Color? color, FontWeight? fw}) => TextStyle(
        fontSize: 12.sp,
        fontWeight: fw ?? FontWeight.w400,
        color: color ?? AppColors.textTertiary,
        height: 1.33,
      );

  // ──────────────────────────────────────────
  // Label (버튼, 캡션)
  // ──────────────────────────────────────────
  static TextStyle labelLarge({Color? color, FontWeight? fw}) => TextStyle(
        fontSize: 16.sp,
        fontWeight: fw ?? FontWeight.w600,
        color: color,
        height: 1.5,
      );

  static TextStyle labelMedium({Color? color, FontWeight? fw}) => TextStyle(
        fontSize: 14.sp,
        fontWeight: fw ?? FontWeight.w500,
        color: color ?? AppColors.textSecondary,
        height: 1.43,
      );

  static TextStyle labelSmall({Color? color, FontWeight? fw}) => TextStyle(
        fontSize: 11.sp,
        fontWeight: fw ?? FontWeight.w500,
        color: color ?? AppColors.textTertiary,
        height: 1.45,
      );
}
