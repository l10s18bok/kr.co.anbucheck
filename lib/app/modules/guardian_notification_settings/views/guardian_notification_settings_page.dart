import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/core/widgets/heartbeat_schedule_tile.dart';
import 'package:anbucheck/app/modules/guardian_notification_settings/controllers/guardian_notification_settings_controller.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 보호자 알림 설정 페이지 — 시안 _2 기준
class GuardianNotificationSettingsPage extends GetWidget<GuardianNotificationSettingsController> {
  const GuardianNotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.onSurface, size: 20.w),
          onPressed: () => Get.back(),
        ),
        title: Text('알림 설정', style: AppTextTheme.headlineSmall()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.lg),

              // 푸시 알림 섹션
              Text(
                '푸시 알림',
                style: AppTextTheme.labelMedium(color: AppColors.textTertiary, fw: FontWeight.w600),
              ),
              SizedBox(height: AppSpacing.md),

              // 전체 알림 받기
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('전체 알림 받기', style: AppTextTheme.bodyLarge(fw: FontWeight.w600)),
                          SizedBox(height: 2.h),
                          Text(
                            '모든 카테고리, 알림을 일괄 활성/비활성합니다.',
                            style: AppTextTheme.bodySmall(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: controller.allNotifications.value,
                      onChanged: controller.toggleAll,
                      activeThumbColor: const Color(0xFF4355B9),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.sp6),

              // 등급별 알림 설정
              Text(
                '등급별 알림 설정',
                style: AppTextTheme.labelMedium(color: AppColors.textTertiary, fw: FontWeight.w600),
              ),
              SizedBox(height: AppSpacing.md),

              // 긴급 알림
              _AlertToggleTile(
                icon: Icons.error_rounded,
                iconColor: const Color(0xFFE53935),
                title: '긴급 알림',
                subtitle: '심각한 비정상 감지 시 즉시 알림',
                value: controller.urgentEnabled.value,
                onChanged: controller.toggleUrgent,
              ),

              // 경고 알림
              _AlertToggleTile(
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFFF9800),
                title: '경고 알림',
                subtitle: '비정상 통계 감지 시 알림',
                value: controller.warningEnabled.value,
                onChanged: controller.toggleWarning,
              ),

              // 주의 알림
              _AlertToggleTile(
                icon: Icons.info_rounded,
                iconColor: const Color(0xFFFFC107),
                title: '주의 알림',
                subtitle: '패턴이나 디바이스 상태 알림',
                value: controller.cautionEnabled.value,
                onChanged: controller.toggleCaution,
              ),

              // 정보 알림
              _AlertToggleTile(
                icon: Icons.notifications_rounded,
                iconColor: const Color(0xFF4355B9),
                title: '정보 알림',
                subtitle: '활동 재개 및 정상 복귀 알림',
                value: controller.infoEnabled.value,
                onChanged: controller.toggleInfo,
              ),

              SizedBox(height: AppSpacing.sp6),

              // 안부 확인 시각
              Text(
                '안부 확인 시각',
                style: AppTextTheme.labelMedium(color: AppColors.textTertiary, fw: FontWeight.w600),
              ),
              SizedBox(height: AppSpacing.md),
              Obx(
                () => HeartbeatScheduleTile(
                  heartbeatTime: controller.heartbeatTime.value,
                  onTap: controller.showTimePickerDialog,
                  color: const Color(0xFF4355B9),
                  backgroundColor: const Color(0xFFC5CAE9),
                ),
              ),
              SizedBox(height: AppSpacing.sp6),

              // 방해금지모드
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.do_not_disturb_on_rounded,
                          size: 22.w,
                          color: AppColors.onSurfaceVariant,
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text('방해금지모드',
                              style: AppTextTheme.bodyLarge(fw: FontWeight.w600)),
                        ),
                        Switch(
                          value: controller.dndEnabled.value,
                          onChanged: controller.toggleDnd,
                          activeThumbColor: const Color(0xFF4355B9),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => HeartbeatScheduleTile(
                                heartbeatTime: controller.dndStartTime.value,
                                onTap: controller.showDndStartPicker,
                                color: const Color(0xFF4355B9),
                                backgroundColor: const Color(0xFFE8EAF6),
                                label: '시작 시각',
                                subLabel: controller.dndStartTime.value,
                              )),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Obx(() => HeartbeatScheduleTile(
                                heartbeatTime: controller.dndEndTime.value,
                                onTap: controller.showDndEndPicker,
                                color: const Color(0xFF4355B9),
                                backgroundColor: const Color(0xFFE8EAF6),
                                label: '종료 시각',
                                subLabel: controller.dndEndTime.value,
                              )),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      '※ 긴급 알림은 방해금지모드 중에도 수신됩니다',
                      style: AppTextTheme.bodySmall(
                          color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.sp6),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final fromIndex = (Get.arguments as int?) ?? 2;
    return BottomNavigationBar(
      currentIndex: fromIndex,
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
        BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: '알림'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: '설정'),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Get.offNamed(AppRoutes.guardianDashboard);
            break;
          case 1:
            Get.offNamed(AppRoutes.guardianConnectionManagement);
            break;
          case 2:
            Get.offNamed(AppRoutes.guardianNotifications);
            break;
          case 3:
            Get.offNamed(AppRoutes.guardianSettings);
            break;
        }
      },
    );
  }
}

class _AlertToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AlertToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20.w, color: iconColor),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextTheme.bodyLarge(fw: FontWeight.w600)),
                  SizedBox(height: 2.h),
                  Text(subtitle, style: AppTextTheme.bodySmall(color: AppColors.textTertiary)),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged, activeThumbColor: const Color(0xFF4355B9)),
          ],
        ),
      ),
    );
  }
}
