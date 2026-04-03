import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';

/// 온보딩 일러스트 위젯
/// unDraw 무료 SVG 일러스트 사용 (Teal 테마 적용)
/// Lottie 파일 확보 시 교체 가능하도록 구조화

class OnboardingIllustration extends StatelessWidget {
  final int step;

  const OnboardingIllustration({super.key, required this.step});

  static const _assets = [
    'assets/illustrations/onboarding_empathy.svg', // 가족 (공감)
    'assets/illustrations/onboarding_solution.svg', // 모바일 메시지 (해결)
    'assets/illustrations/onboarding_connection.svg', // 연결 (연결)
    'assets/illustrations/onboarding_trust.svg', // 개인정보 보호 (신뢰)
  ];

  @override
  Widget build(BuildContext context) {
    final assetPath = _assets[step.clamp(0, _assets.length - 1)];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 장식 원 (부드러운 분위기)
          Container(
            width: 260.w,
            height: 260.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.seniorPrimary.withValues(alpha: 0.05),
                  AppColors.seniorPrimary.withValues(alpha: 0.02),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // SVG 일러스트
          SvgPicture.asset(
            assetPath,
            width: 240.w,
            height: 240.w,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
