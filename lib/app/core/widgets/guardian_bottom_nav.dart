import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 보호자 모드 공통 하단 네비게이션 바
class GuardianBottomNav extends StatelessWidget {
  const GuardianBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  static const _radius = 20.0;

  @override
  Widget build(BuildContext context) {
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
          selectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : const Color(0xFF1A1C1C),
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.4)
              : const Color(0xFFD5D5D5),
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
                Get.offNamed(AppRoutes.guardianDashboard);
              case 1:
                Get.offNamed(AppRoutes.guardianConnectionManagement);
              case 2:
                Get.offNamed(AppRoutes.guardianNotifications);
              case 3:
                Get.offNamed(AppRoutes.guardianSettings);
            }
          },
        ),
      ),
    );
  }
}
