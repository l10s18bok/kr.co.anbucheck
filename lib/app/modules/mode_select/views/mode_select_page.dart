import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/modules/mode_select/controllers/mode_select_controller.dart';

/// 모드 선택 페이지
/// 스크롤 없이 한 화면에 제목 + 두 카드 + 하단 안내 배치
class ModeSelectPage extends GetWidget<ModeSelectController> {
  const ModeSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 다크 톤 배경 위 고정 밝은 텍스트 컬러 (테마 무관 — 이 화면 전용)
    const headerTextColor = Color(0xFFF2F3F7);
    const headerSubColor = Color(0xFFA8ADBB);
    // 하단 안내 문구 — 옐로 계열 강조
    const noticeColor = Color(0xFFFFD54F);

    // 가로로 넓은 창(폭이 높이의 1.2배 이상)이면 두 카드를 좌우로 놓는다.
    final size = MediaQuery.sizeOf(context);
    final sideBySide = size.width >= size.height * 1.2;

    // 대상자 모드 카드 (Teal)
    final subjectCard = _ModeCard(
      gradientColors: const [Color(0xFFE0F2F1), Color(0xFFC8E6C9)],
      bandColors: const [Color(0xFF00897B), Color(0xFF00695C)],
      illustrationPath: 'assets/illustrations/select_dependent.svg',
      title: 'mode_subject_title'.tr,
      description: 'mode_subject_desc'.tr,
      buttonLabel: 'mode_subject_button'.tr,
      buttonColor: const Color(0xFF00685E),
      onTap: controller.selectSubjectMode,
      badgeText: 'mode_subject_badge'.tr,
      badgeAtRight: true,
      roomyText: sideBySide,
    );

    // 보호자 모드 카드 (Indigo)
    final guardianCard = _ModeCard(
      gradientColors: const [Color(0xFFE8EAF6), Color(0xFFDDE1FF)],
      bandColors: const [Color(0xFF4355B9), Color(0xFF303F9F)],
      illustrationPath: 'assets/illustrations/select_guardian.svg',
      title: 'mode_guardian_title'.tr,
      description: 'mode_guardian_desc'.tr,
      buttonLabel: 'mode_guardian_button'.tr,
      buttonColor: const Color(0xFF4355B9),
      onTap: controller.selectGuardianMode,
      badgeText: 'mode_guardian_badge'.tr,
      roomyText: sideBySide,
    );

    return Scaffold(
      // 다크 톤 배경 — 검정 그림자가 읽히도록 반 단계 밝힌 미드 인디고
      // (AppBar 영역과 body 그라데이션 상단이 이어지도록 동일 색 사용)
      backgroundColor: const Color(0xFF2E3763),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'app_brand'.tr,
          style: AppTextTheme.headlineSmall(color: headerTextColor),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E3763), Color(0xFF1D2342)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalMargin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.xs),

                // 제목
                Text(
                  'mode_select_title'.tr,
                  style: AppTextTheme.displaySmall(color: headerTextColor),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'mode_select_subtitle'.tr,
                  style: AppTextTheme.bodyMedium(color: headerSubColor),
                ),

                SizedBox(height: AppSpacing.md),

                // 두 카드 — 창이 가로로 넓으면(폴더블 접힘 가로·펼친 가로 등) 좌우로, 아니면 위아래로.
                // 기기 종류가 아니라 창 모양만 본다. 위아래로 쌓으면 세로가 낮은 가로 창(약 500dp)에서
                // 카드 하나가 150dp 안팎이 되어 일러스트가 점처럼 줄어든다.
                if (sideBySide)
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: subjectCard),
                        SizedBox(width: AppSpacing.sp6),
                        Expanded(child: guardianCard),
                      ],
                    ),
                  )
                else ...[
                  Expanded(child: subjectCard),
                  SizedBox(height: AppSpacing.sp6),
                  Expanded(child: guardianCard),
                ],

                SizedBox(height: AppSpacing.lg),

                // 하단 안내
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sp4),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4.w,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14.w,
                          color: noticeColor,
                        ),
                        Text(
                          'mode_select_notice'.tr,
                          style: AppTextTheme.bodySmall(color: noticeColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final List<Color> gradientColors;

  /// 하단 텍스트 밴드 그라데이션 (브랜드 컬러 — 투톤 구성)
  final List<Color> bandColors;
  final String illustrationPath;
  final String title;
  final String description;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onTap;
  final String? badgeText;

  /// 배지를 우측 상단에 배치 (기본은 좌측 상단)
  final bool badgeAtRight;

  /// 텍스트 밴드에 카드 높이의 더 큰 몫을 허용한다(좌우 배치처럼 카드가 낮을 때).
  /// 텍스트가 길어지면 글자를 줄이기 전에 일러스트 영역이 먼저 줄어든다(일러스트는 contain이라
  /// 잘리거나 찌그러지지 않고 작아지기만 한다).
  final bool roomyText;

  const _ModeCard({
    required this.gradientColors,
    required this.bandColors,
    required this.illustrationPath,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onTap,
    this.badgeText,
    this.badgeAtRight = false,
    this.roomyText = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              // 돌출감 드롭 섀도: 아래로 떨어지는 진한 검정 2겹
              // (경계 밀착 그림자 + 멀리 떨어지는 부유 그림자 — 다크 배경 기준 투명도)
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 36,
                  offset: const Offset(0, 18),
                  spreadRadius: 2,
                ),
              ],
            ),
            // 투톤 구성: 상단(밝은 그라데이션 + 일러스트) / 하단(브랜드 컬러 밴드 + 텍스트)
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      // 상단: 일러스트 — 남는 공간을 모두 흡수하며 텍스트 길이에 따라 축소
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: gradientColors,
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.sp6,
                            AppSpacing.md,
                            AppSpacing.sp6,
                            AppSpacing.sm,
                          ),
                          child: SvgPicture.asset(
                            illustrationPath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // 하단: 브랜드 컬러 밴드 — 밴드 배경은 항상 카드 폭을 채우고,
                      // 텍스트 블록만 카드 높이의 일정 비율을 넘으면 비율 축소해
                      // 저해상도·긴 번역에서도 카드 크기(균등 분할)를 침범하지 않음
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: bandColors,
                          ),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight:
                                constraints.maxHeight *
                                (roomyText ? 0.8 : 0.62),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.bottomLeft,
                            child: SizedBox(
                              width: constraints.maxWidth,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  AppSpacing.sp4,
                                  AppSpacing.md,
                                  AppSpacing.sp4,
                                  AppSpacing.md,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 긴 번역은 줄 수 제한 + 말줄임 처리
                                    Text(
                                      title,
                                      maxLines: roomyText ? 3 : 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextTheme.bodyLarge(
                                        color: Colors.white,
                                        fw: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: AppSpacing.xs),
                                    Text(
                                      description,
                                      maxLines: roomyText ? 3 : 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextTheme.bodySmall(
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: AppSpacing.sm),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        buttonLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextTheme.bodyMedium(
                                          color: Colors.white,
                                          fw: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (badgeText != null)
            Positioned(
              top: 12.h,
              left: badgeAtRight ? null : 12.w,
              right: badgeAtRight ? 12.w : null,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: buttonColor.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badgeText!,
                  style: AppTextTheme.bodySmall(
                    color: Colors.white,
                    fw: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
