import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/modules/guardian_past_notifications/controllers/guardian_past_notifications_controller.dart';

/// 지난 알림 전체 목록 페이지 (최신순, 10개씩 페이지네이션)
class GuardianPastNotificationsPage
    extends GetWidget<GuardianPastNotificationsController> {
  const GuardianPastNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.onSurface, size: 20.w),
          onPressed: () => Get.back(),
        ),
        title: Text('지난 알림', style: AppTextTheme.headlineSmall()),
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = controller.displayedItems;

        if (items.isEmpty) {
          return Center(
            child: Text(
              '지난 알림이 없습니다',
              style: AppTextTheme.bodyMedium(color: AppColors.textTertiary),
            ),
          );
        }

        return ListView.builder(
          controller: controller.scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalMargin,
            vertical: AppSpacing.lg,
          ),
          itemCount: items.length + (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == items.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return _PastNotificationTile(item: items[index]);
          },
        );
      }),
    );
  }
}

// ─── 지난 알림 타일 ────────────────────────────────────────────────────────────

class _PastNotificationTile extends StatelessWidget {
  final NotificationEntity item;

  const _PastNotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              _icon,
              size: 18.w,
              color: _iconColor,
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.displayName} - ${item.body}',
                    style: AppTextTheme.bodyMedium(
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              _formatDate(item.receivedAt),
              style: AppTextTheme.labelSmall(
                  color: AppColors.textTertiary, fw: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}';
  }

  Color get _iconColor => switch (item.level) {
        AlertLevel.urgent => const Color(0xFFE53935),
        AlertLevel.warning => const Color(0xFFFF9800),
        AlertLevel.caution => const Color(0xFFFFC107),
        AlertLevel.info => const Color(0xFF4355B9),
      };

  IconData get _icon => switch (item.level) {
        AlertLevel.urgent => Icons.error_rounded,
        AlertLevel.warning => Icons.warning_amber_rounded,
        AlertLevel.caution => Icons.info_rounded,
        AlertLevel.info => Icons.notifications_rounded,
      };
}
