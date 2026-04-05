import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/modules/guardian_notifications/controllers/guardian_notifications_controller.dart';
import 'package:anbucheck/app/core/utils/back_press_handler.dart';
import 'package:anbucheck/app/core/widgets/guardian_bottom_nav.dart';

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
        title: Row(
          children: [
            Icon(Icons.notifications_rounded, size: 22.w, color: AppColors.onSurface),
            SizedBox(width: 8.w),
            Text('알림', style: AppTextTheme.headlineSmall()),
          ],
        ),
        actions: [
          Obx(() => Padding(
            padding: EdgeInsets.only(right: AppSpacing.horizontalMargin - 12.w),
            child: IconButton(
              icon: Icon(Icons.refresh_rounded,
                  color: controller.isLoading
                      ? const Color(0xFF4355B9).withValues(alpha: 0.4)
                      : const Color(0xFF4355B9),
                  size: 24.w),
              onPressed: controller.isLoading ? null : controller.load,
            ),
          )),
        ],
      ),
      body: Stack(
        children: [
          Obx(() {
            final items = controller.notifications;

            if (items.isEmpty && !controller.isLoading) {
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
                      Text('오늘 받은 알림',
                          style: AppTextTheme.labelMedium(
                              color: const Color(0xFF4355B9), fw: FontWeight.w600)),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: controller.isLoading ? null : () => _confirmDeleteAll(context),
                            child: Icon(Icons.delete_outline_rounded,
                                size: 24.w,
                                color: controller.isLoading
                                    ? const Color(0xFFE53935).withValues(alpha: 0.4)
                                    : const Color(0xFFE53935)),
                          ),
                          SizedBox(width: 20.w),
                          GestureDetector(
                            onTap: () => _showAlertLevelGuide(context),
                            child: Icon(Icons.help_outline_rounded,
                                size: 24.w,
                                color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  ...items.map((item) => _NotificationCard(item: item)),
                  SizedBox(height: AppSpacing.sp6),
                ],
              ),
            );
          }),
          Obx(() => controller.isLoading
              ? Container(
                  color: Colors.black.withValues(alpha: 0.1),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4355B9)),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      bottomNavigationBar: const GuardianBottomNav(currentIndex: 2),
    ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('알림 전체 삭제', style: AppTextTheme.headlineSmall()),
        content: Text('오늘 받은 알림을 모두 삭제하시겠습니까?', style: AppTextTheme.bodyMedium()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: AppTextTheme.bodyLarge(color: AppColors.textTertiary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteAll();
            },
            child: Text('삭제', style: AppTextTheme.bodyLarge(color: const Color(0xFFE53935), fw: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showAlertLevelGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('알림 등급 안내', style: AppTextTheme.headlineSmall()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _alertGuideItem(
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF4CAF50),
                title: '정상',
                description: '대상자의 안부가 정상적으로 확인됨',
              ),
              SizedBox(height: AppSpacing.lg),
              _alertGuideItem(
                icon: Icons.info_rounded,
                color: const Color(0xFFFFC107),
                title: '주의',
                description: '다음 중 하나에 해당합니다.\n'
                    '1. 오늘 예정된 안부 확인이 아직 없음\n'
                    '2. 안부는 수신되었으나 폰 사용 흔적이 없음',
              ),
              SizedBox(height: AppSpacing.lg),
              _alertGuideItem(
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFFF9800),
                title: '경고',
                description: '다음 중 하나에 해당합니다.\n'
                    '1. 2일 연속으로 안부 확인이 되지 않음\n'
                    '2. 2일 연속 폰 사용 흔적이 없음',
              ),
              SizedBox(height: AppSpacing.lg),
              _alertGuideItem(
                icon: Icons.error_rounded,
                color: const Color(0xFFE53935),
                title: '긴급',
                description: '장기간 안부 확인이 없거나,\n'
                    '3일 이상 폰 사용이 없음',
              ),
              SizedBox(height: AppSpacing.lg),
              Divider(color: AppColors.outlineVariant),
              SizedBox(height: AppSpacing.md),
              _alertGuideItem(
                icon: Icons.notifications_rounded,
                color: const Color(0xFF4355B9),
                title: '정보',
                description: '걸음수, 배터리 부족 등 참고용 알림\n일반적인 상태 정보 전달',
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                '※ 걸음수 데이터를 수집하지 못한 경우 활동 정보가 표시되지 않을 수 있습니다.',
                style: AppTextTheme.bodySmall(color: AppColors.textTertiary).copyWith(fontSize: 11.sp),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인', style: AppTextTheme.bodyLarge(color: const Color(0xFF4355B9), fw: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _alertGuideItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22.w, color: color),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextTheme.bodyLarge(fw: FontWeight.w600)),
              SizedBox(height: 2.h),
              Text(description, style: AppTextTheme.bodySmall(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
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
