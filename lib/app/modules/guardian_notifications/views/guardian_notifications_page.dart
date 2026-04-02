import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/modules/guardian_notifications/controllers/guardian_notifications_controller.dart';
import 'package:anbucheck/app/core/utils/back_press_handler.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 보호자 알림 목록 페이지 — 당일 알림만 표시 (서버 API 기반)
class GuardianNotificationsPage
    extends GetWidget<GuardianNotificationsController> {
  const GuardianNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) BackPressHandler.onBackPressed();
      },
      child: Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('알림', style: AppTextTheme.headlineSmall()),
        actions: [
          Obx(() => IconButton(
            icon: Icon(Icons.refresh_rounded,
                color: AppColors.onSurfaceVariant, size: 22.w),
            onPressed: controller.isLoading ? null : controller.load,
          )),
        ],
      ),
      body: Obx(() {
        final items = controller.notifications;

        if (items.isEmpty) {
          return const _EmptyState();
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('오늘',
                      style: AppTextTheme.labelMedium(
                          color: const Color(0xFF4355B9), fw: FontWeight.w600)),
                  Obx(() => GestureDetector(
                    onTap: controller.isLoading ? null : controller.deleteAll,
                    child: Text(
                      '전체 삭제',
                      style: AppTextTheme.labelSmall(
                          color: controller.isLoading
                              ? AppColors.textTertiary.withValues(alpha: 0.4)
                              : AppColors.textTertiary,
                          fw: FontWeight.w500),
                    ),
                  )),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              ...items.map((item) => _NotificationCard(item: item)),
              SizedBox(height: AppSpacing.sp6),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNav(),
    ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 2,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surfaceContainerLowest,
      selectedItemColor: const Color(0xFF4355B9),
      unselectedItemColor: AppColors.onSurfaceVariant,
      elevation: 0,
      selectedFontSize: 12.sp,
      unselectedFontSize: 12.sp,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.link_rounded), label: '연결'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications_rounded), label: '알림'),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded), label: '설정'),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Get.offNamed(AppRoutes.guardianDashboard);
          case 1:
            Get.offNamed(AppRoutes.guardianConnectionManagement);
          case 2:
            break;
          case 3:
            Get.offNamed(AppRoutes.guardianSettings);
        }
      },
    );
  }
}

// ─── 알림 카드 ─────────────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationEntity item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, size: 20.w, color: _iconColor),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _levelLabel,
                        style: AppTextTheme.labelSmall(
                            color: _iconColor, fw: FontWeight.w700),
                      ),
                      if (item.level != AlertLevel.health)
                        Text(
                          _formatTime(item.receivedAt),
                          style: AppTextTheme.labelSmall(
                              color: const Color(0xFF4355B9),
                              fw: FontWeight.w500),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${item.displayName} - ',
                          style: AppTextTheme.bodyMedium(fw: FontWeight.w600),
                        ),
                        TextSpan(
                          text: item.body,
                          style: AppTextTheme.bodyMedium(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final period = dt.hour < 12 ? '오전' : '오후';
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    return '$period $h:$m';
  }

  Color get _backgroundColor {
    final dark = Get.isDarkMode;
    return switch (item.level) {
      AlertLevel.urgent  => dark ? const Color(0xFF4E0000) : const Color(0xFFFFEBEE),
      AlertLevel.warning => dark ? const Color(0xFF4E2000) : const Color(0xFFFFE0B2),
      AlertLevel.caution => dark ? const Color(0xFF2E2E00) : const Color(0xFFFFF9C4),
      AlertLevel.info    => item.title.contains('배터리')
          ? (dark ? const Color(0xFF2A1540) : const Color(0xFFEDE7F6))
          : (dark ? const Color(0xFF1A2540) : const Color(0xFFE3F2FD)),
      AlertLevel.health  => dark ? const Color(0xFF0A3A2A) : const Color(0xFFE8F5E9),
    };
  }

  Color get _iconColor => switch (item.level) {
        AlertLevel.urgent  => const Color(0xFFE53935),
        AlertLevel.warning => const Color(0xFFFF9800),
        AlertLevel.caution => const Color(0xFFFFC107),
        AlertLevel.info    => item.title.contains('배터리')
            ? const Color(0xFF7B1FA2) // 보라
            : const Color(0xFF4355B9),
        AlertLevel.health  => const Color(0xFF43A047),
      };

  IconData get _icon => switch (item.level) {
        AlertLevel.urgent  => Icons.error_rounded,
        AlertLevel.warning => Icons.warning_amber_rounded,
        AlertLevel.caution => Icons.info_rounded,
        AlertLevel.info    => item.title.contains('배터리')
            ? Icons.battery_alert_rounded
            : Icons.notifications_rounded,
        AlertLevel.health  => Icons.directions_walk_rounded,
      };

  String get _levelLabel => switch (item.level) {
        AlertLevel.urgent  => '긴급',
        AlertLevel.warning => '경고',
        AlertLevel.caution => '주의',
        AlertLevel.info    => '정보',
        AlertLevel.health  => '건강',
      };
}

// ─── 빈 상태 ──────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 80.w,
            color: AppColors.textTertiary.withValues(alpha: 0.4),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            '오늘 받은 알림이 없습니다',
            style: AppTextTheme.bodyLarge(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
