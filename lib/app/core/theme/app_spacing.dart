import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Anbu 스페이싱 시스템 (DESIGN.md 기반)
/// spacing.4 ~ spacing.10 단계
abstract class AppSpacing {
  /// spacing.4 = 1.4rem ≈ 22.4px → 컴포넌트 내부 패딩
  static double get sp4 => 22.w;

  /// spacing.5 = 1.7rem ≈ 27.2px → 수평 레이아웃 마진
  static double get sp5 => 27.w;

  /// spacing.6 = 2rem ≈ 32px → 주요 요소 간 기본 간격
  static double get sp6 => 32.w;

  /// spacing.8 = 2.75rem ≈ 44px → 카드 내 콘텐츠 블록 간격, 수직 그룹 간격
  static double get sp8 => 44.w;

  /// spacing.10 = 3.5rem ≈ 56px → 타임라인 아이콘 간격
  static double get sp10 => 56.w;

  /// 수평 페이지 마진 (spacing.5)
  static double get horizontalMargin => sp5;

  /// 수평 간격 (.w 기반 — 패딩·마진·아이콘 간격 등)
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 12.w;
  static double get lg => 16.w;
  static double get xl => 20.w;

  /// 수직 간격 (.h 기반 — SizedBox height, 화면 높이에 비례 스케일)
  static double get vxs => 4.h;
  static double get vsm => 8.h;
  static double get vmd => 12.h;
  static double get vlg => 16.h;
  static double get vxl => 20.h;
}
