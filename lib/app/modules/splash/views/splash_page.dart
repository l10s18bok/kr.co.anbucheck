import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/modules/splash/controllers/splash_controller.dart';

/// 스플래시 페이지
/// 연한 민트/세이지 배경, 하트 시그널 Lottie 애니메이션, 브랜드 텍스트
class SplashPage extends GetWidget<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9), // 연한 민트 상단
              Color(0xFFF1F8F2), // 더 밝은 민트 하단
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              // 하트 시그널 Lottie 애니메이션
              Lottie.asset(
                'assets/lottie/splash_heart_signal.json',
                width: 280.w,
                height: 124.w,
                fit: BoxFit.contain,
                repeat: false,
              ),
              SizedBox(height: 32.h),

              // 브랜드명
              Text(
                'app_brand'.tr,
                style: AppTextTheme.headlineLarge(
                  color: const Color(0xFF1A1C1C),
                ),
              ),
              SizedBox(height: 12.h),

              // 부제
              Text(
                'app_tagline'.tr,
                style: AppTextTheme.bodyMedium(
                  color: const Color(0xFF3F4948),
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // 하단 서비스 설명
              Text(
                'app_service_desc'.tr,
                style: AppTextTheme.bodySmall(
                  color: const Color(0xFF6F7978),
                ),
              ),
              SizedBox(height: 16.h),

              // 로딩 인디케이터 (3개 점 — 0.5초마다 활성 점 이동)
              const _LoadingDots(),
              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }
}

/// 3개 점이 0.5초 단위로 활성 상태가 순차 이동하는 로딩 인디케이터
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> {
  int _activeIndex = 0;
  late final Stream<int> _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Stream.periodic(
      const Duration(milliseconds: 500),
      (count) => count % 3,
    );
    _ticker.listen((index) {
      if (mounted) setState(() => _activeIndex = index);
    });
  }

  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0xFF00685E);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = i == _activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: baseColor.withValues(alpha: isActive ? 1.0 : 0.25),
          ),
        );
      }),
    );
  }
}
