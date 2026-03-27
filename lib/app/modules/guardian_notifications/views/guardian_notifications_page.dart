import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/modules/guardian_notifications/controllers/guardian_notifications_controller.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 보호자 알림 목록 페이지
class GuardianNotificationsPage
    extends GetWidget<GuardianNotificationsController> {
  const GuardianNotificationsPage({super.key});

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
        title: Text('알림', style: AppTextTheme.headlineSmall()),
        actions: [
          Obx(() => controller.todayNotifications.isEmpty
              ? const SizedBox.shrink()
              : TextButton(
                  onPressed: controller.markAllAsRead,
                  child: Text(
                    '모두 읽음',
                    style: AppTextTheme.bodyMedium(
                      color: const Color(0xFF4355B9),
                      fw: FontWeight.w600,
                    ),
                  ),
                )),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
        child: Obx(() {
          final today = controller.todayNotifications;
          final past = controller.pastNotifications;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.lg),

              // 새로운 알림 수
              Text(
                '새로운 알림 ${controller.newCount}개',
                style: AppTextTheme.bodyMedium(
                    color: AppColors.textSecondary),
              ),
              SizedBox(height: AppSpacing.lg),

              // 오늘 섹션
              Text('오늘',
                  style: AppTextTheme.labelMedium(
                      color: AppColors.textTertiary, fw: FontWeight.w600)),
              SizedBox(height: AppSpacing.md),

              if (today.isEmpty)
                const _EmptyTile(message: '오늘 받은 알림이 없습니다')
              else
                ...today.map((item) => _NotificationCard(
                      item: item,
                      isRead: item.isRead || controller.isAllRead.value,
                      onTap: () {
                        if (item.id != null) controller.markAsRead(item.id!);
                      },
                    )),

              SizedBox(height: AppSpacing.sp6),

              // 지난 알림 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('지난 알림',
                      style: AppTextTheme.labelMedium(
                          color: AppColors.textTertiary, fw: FontWeight.w600)),
                  if (past.length > 2)
                    GestureDetector(
                      onTap: () => Get.toNamed(
                          AppRoutes.guardianPastNotifications),
                      child: Text(
                        '+ 더보기',
                        style: AppTextTheme.labelSmall(
                          color: const Color(0xFF4355B9),
                          fw: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.md),

              if (past.isEmpty)
                const _EmptyTile(message: '지난 알림이 없습니다')
              else
                ...past.take(2).map((item) => _PastNotificationTile(item: item)),

              SizedBox(height: AppSpacing.sp6),
            ],
          );
        }),
      ),
      bottomNavigationBar: _buildBottomNav(),
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

// ─── 오늘 알림 카드 ────────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationEntity item;
  final bool isRead;
  final VoidCallback? onTap;

  const _NotificationCard({
    required this.item,
    this.isRead = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
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
            // 등급 아이콘 + 읽음 체크
            Column(
              mainAxisSize: MainAxisSize.min,
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
                if (isRead) ...[
                  SizedBox(height: 4.h),
                  Icon(Icons.check_circle_rounded,
                      size: 14.w, color: const Color(0xFF4355B9)),
                ],
              ],
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 등급 라벨 + 수신 시각
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _levelLabel,
                        style: AppTextTheme.labelSmall(
                            color: _iconColor, fw: FontWeight.w700),
                      ),
                      Text(
                        _formatTime(item.receivedAt),
                        style: AppTextTheme.labelSmall(
                            color: const Color(0xFF4355B9),
                            fw: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // 대상자 + 메시지
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${item.displayName} - ',
                          style:
                              AppTextTheme.bodyMedium(fw: FontWeight.w600),
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
    ),
    );
  }

  String _formatTime(DateTime dt) {
    final period = dt.hour < 12 ? '오전' : '오후';
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    return '$period $h:$m';
  }

  Color get _backgroundColor => switch (item.level) {
        AlertLevel.urgent => const Color(0xFFFFEBEE),
        AlertLevel.warning => const Color(0xFFFFF3E0),
        AlertLevel.caution => const Color(0xFFFFFDE7),
        AlertLevel.info => const Color(0xFFE3F2FD),
      };

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

  String get _levelLabel => switch (item.level) {
        AlertLevel.urgent => '긴급',
        AlertLevel.warning => '경고',
        AlertLevel.caution => '주의',
        AlertLevel.info => '정보',
      };
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
            Icon(Icons.check_circle_outline_rounded,
                size: 18.w, color: AppColors.onSurfaceVariant),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                '${item.displayName} - ${item.body}',
                style:
                    AppTextTheme.bodyMedium(color: AppColors.textTertiary),
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
}

// ─── 빈 상태 ──────────────────────────────────────────────────────────────────

class _EmptyTile extends StatelessWidget {
  final String message;

  const _EmptyTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: Text(
          message,
          style: AppTextTheme.bodyMedium(color: AppColors.textTertiary),
        ),
      ),
    );
  }
}
