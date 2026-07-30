import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:anbucheck/app/modules/onboarding/views/onboarding_mockups.dart';

/// 온보딩 일러스트 위젯
/// 실제 앱 화면(안전코드·긴급버튼·대상자연결 등)을 재현한 정지 목업을 표시.
/// 목업 종류는 OnboardingController.steps가 스텝별로 지정.
class OnboardingIllustration extends StatelessWidget {
  final OnboardingVisual visual;

  const OnboardingIllustration({super.key, required this.visual});

  @override
  Widget build(BuildContext context) {
    final Widget mockup = switch (visual) {
      OnboardingVisual.safetyCode => const SafetyCodeMockup(),
      OnboardingVisual.emergencyButton => const EmergencyButtonMockup(),
      OnboardingVisual.gsSwitch => const GsSwitchMockup(),
      OnboardingVisual.addSubject => const AddSubjectMockup(),
      OnboardingVisual.gsEnable => const GsEnableMockup(),
      OnboardingVisual.notifications => const NotificationsPreviewMockup(),
    };

    // 긴급 버튼 스텝 — 확정 디자인: 컬러 헤일로 + 진입 스케일/페이드 애니메이션.
    if (visual == OnboardingVisual.emergencyButton) {
      return _scaleFadeIn(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 320.w,
              height: 220.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(110.r),
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8E3A3A).withValues(alpha: 0.28),
                    const Color(0xFF8E3A3A).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            mockup,
          ],
        ),
      );
    }

    // 안전코드 스텝 — 확정 디자인: 도형 액센트 + 진입 스케일/페이드 애니메이션.
    if (visual == OnboardingVisual.safetyCode) {
      return _scaleFadeIn(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            mockup,
            Positioned(top: -10.h, left: 8.w, child: _AccentDot(size: 12.w, alpha: 0.5)),
            Positioned(top: 10.h, right: -10.w, child: _AccentDiamond(size: 14.w, alpha: 0.4)),
            Positioned(bottom: -12.h, left: 48.w, child: _AccentDiamond(size: 10.w, alpha: 0.35)),
            Positioned(bottom: -6.h, right: 24.w, child: _AccentDot(size: 8.w, alpha: 0.45)),
          ],
        ),
      );
    }

    // G+S 활성화 스텝 — 확정 디자인: 톤 배경 패널(인디고) + 슬라이드업 페이드 애니메이션.
    if (visual == OnboardingVisual.gsEnable) {
      return _slideUpFadeIn(
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFF4355B9).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: mockup,
        ),
      );
    }

    // S→G+S 전환 스텝(Drawer "가족 안부도 관리하기") — 확정 디자인: 톤 배경 패널(인디고) +
    // 슬라이드업 페이드 애니메이션. G+S 활성화 스텝과 동일한 "메뉴 행" 형태라 같은 처리를 재사용.
    if (visual == OnboardingVisual.gsSwitch) {
      return _slideUpFadeIn(
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFF4355B9).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: mockup,
        ),
      );
    }

    // TODO: 디자인 확인용 — 알림 미리보기 스텝. 톤 배경 패널(인디고)로 테두리를 잡고 그 안에
    // 헤더("알림" 아이콘+타이틀) + 주의 카드 + 걸음수 카드를 배치. 두 카드의 순차 슬라이드다운
    // 애니메이션은 NotificationsPreviewMockup 자체가 소유(주의 카드 먼저, 걸음수 카드가 시간차를
    // 두고 뒤따라 내려옴)하므로 여기서는 별도 진입 애니메이션을 씌우지 않는다.
    // 실제 OS 푸시 알림 배너(캡션 미수신 알림)를 패널 위에 떠 있는 형태로 별도 배치.
    // 확정되면 최종 디자인으로 굳히고 TODO 제거.
    if (visual == OnboardingVisual.notifications) {
      return _wrap(
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: EdgeInsets.only(top: 26.h),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFF4355B9).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: mockup,
            ),
            Positioned(
              top: -18.h,
              child: PushNotificationMockup(
                title: 'notifications_level_caution'.tr,
                body: 'noti_caution_missing_body'.tr,
              ),
            ),
          ],
        ),
      );
    }

    // TODO: 디자인 확인용 — 대상자 추가 스텝은 톤 배경 패널(인디고) 디자인 확정,
    // 애니메이션만 오른쪽에서 왼쪽으로 슬라이드하는 페이드로 교체 시험 중.
    // 확정되면 최종 디자인으로 굳히고 TODO 제거.
    if (visual == OnboardingVisual.addSubject) {
      return _slideLeftFadeIn(
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFF4355B9).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: mockup,
        ),
      );
    }

    return _wrap(mockup);
  }

  Widget _scaleFadeIn({required Widget child}) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(visual),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.7 + (0.3 * value),
            child: animatedChild,
          ),
        );
      },
      child: _wrap(child),
    );
  }

  Widget _slideUpFadeIn({required Widget child}) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(visual),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 40.h * (1 - value)),
            child: animatedChild,
          ),
        );
      },
      child: _wrap(child),
    );
  }

  Widget _slideLeftFadeIn({required Widget child}) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(visual),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(60.w * (1 - value), 0),
            child: animatedChild,
          ),
        );
      },
      child: _wrap(child),
    );
  }

  Widget _wrap(Widget child) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      // 목업 내부 Column이 실제 화면(스크롤 영역, 세로 무제한)과 달리 여기서는
      // Expanded(flex:6)로 세로가 유한하게 제한되어 mainAxisSize.max로 꽉 채워버린다.
      // UnconstrainedBox로 세로 제약만 풀어 콘텐츠 높이만큼만 차지하게 한다.
      child: Center(
        child: UnconstrainedBox(
          constrainedAxis: Axis.horizontal,
          child: child,
        ),
      ),
    );
  }
}

class _AccentDot extends StatelessWidget {
  final double size;
  final double alpha;

  const _AccentDot({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1D6FA5).withValues(alpha: alpha),
      ),
    );
  }
}

class _AccentDiamond extends StatelessWidget {
  final double size;
  final double alpha;

  const _AccentDiamond({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.785398, // 45도
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.r),
          color: const Color(0xFF1D6FA5).withValues(alpha: alpha),
        ),
      ),
    );
  }
}
