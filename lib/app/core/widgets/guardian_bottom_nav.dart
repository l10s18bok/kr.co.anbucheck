import 'package:anbucheck/app/core/utils/app_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/widgets/split_shell.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 보호자 모드 공통 하단 네비게이션 바
class GuardianBottomNav extends StatelessWidget {
  const GuardianBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  static const _radius = 20.0;

  @override
  Widget build(BuildContext context) {
    // 분할 화면의 오른쪽 pane 안 페이지는 탭바를 그리지 않는다(왼쪽 대시보드의 탭바를 공유).
    if (PaneScope.of(context)) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_radius.r),
          topRight: Radius.circular(_radius.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_radius.r),
          topRight: Radius.circular(_radius.r),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surfaceContainerLowest,
          selectedItemColor: AppColors.onSurface,
          unselectedItemColor: AppColors.outlineVariant,
          elevation: 0,
          selectedFontSize: 12.sp,
          unselectedFontSize: 12.sp,
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.home_rounded), label: 'nav_home'.tr),
            BottomNavigationBarItem(
                icon: const Icon(Icons.link_rounded), label: 'nav_connection'.tr),
            BottomNavigationBarItem(
                icon: const Icon(Icons.notifications_rounded), label: 'nav_notification'.tr),
            BottomNavigationBarItem(
                icon: const Icon(Icons.settings_rounded), label: 'nav_settings'.tr),
          ],
          onTap: (index) {
            if (index == currentIndex) return;
            switch (index) {
              case 0:
                AppNav.offNamed(AppRoutes.guardianDashboard);
              case 1:
                AppNav.offNamed(AppRoutes.guardianConnectionManagement);
              case 2:
                AppNav.offNamed(AppRoutes.guardianNotifications);
              case 3:
                AppNav.offNamed(AppRoutes.guardianSettings);
            }
          },
        ),
      ),
    );
  }
}
