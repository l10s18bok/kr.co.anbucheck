import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/core/widgets/heartbeat_schedule_tile.dart';
import 'package:anbucheck/app/modules/guardian_notification_settings/controllers/guardian_notification_settings_controller.dart';
import 'package:anbucheck/app/core/widgets/guardian_bottom_nav.dart';

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

              // 긴급 알림 — 항상 ON, 비활성화
              const _AlertToggleTile(
                icon: Icons.error_rounded,
                iconColor: Color(0xFFE53935),
                title: '긴급 알림',
                subtitle: '긴급 알림은 해제할 수 없습니다',
                value: true,
                enabled: false,
              ),

              // 경고 알림
              _AlertToggleTile(
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFFF9800),
                title: '경고 알림',
                subtitle: '연속 2일 안부 미확인 시 알림',
                value: controller.warningEnabled.value,
                onChanged: controller.toggleWarning,
              ),

              // 주의 알림
              _AlertToggleTile(
                icon: Icons.info_rounded,
                iconColor: const Color(0xFFFFC107),
                title: '주의 알림',
                subtitle: '당일 안부 미확인 시 알림',
                value: controller.cautionEnabled.value,
                onChanged: controller.toggleCaution,
              ),

              // 정보 알림
              _AlertToggleTile(
                icon: Icons.notifications_rounded,
                iconColor: const Color(0xFF4355B9),
                title: '정보 알림',
                subtitle: '걸음수, 배터리 상태 등 일반 알림',
                value: controller.infoEnabled.value,
                onChanged: controller.toggleInfo,
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
                          child: Text('방해금지 시각 설정', style: AppTextTheme.bodyLarge(fw: FontWeight.w600)),
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
                          child: Obx(
                            () => HeartbeatScheduleTile(
                              heartbeatTime: controller.dndStartTime.value,
                              onTap: controller.showDndStartPicker,
                              color: const Color(0xFF4355B9),
                              backgroundColor: const Color(0xFFE8EAF6),
                              label: '시작 시각',
                              subLabel: controller.dndStartTime.value,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Obx(
                            () => HeartbeatScheduleTile(
                              heartbeatTime: controller.dndEndTime.value,
                              onTap: controller.showDndEndPicker,
                              color: const Color(0xFF4355B9),
                              backgroundColor: const Color(0xFFE8EAF6),
                              label: '종료 시각',
                              subLabel: controller.dndEndTime.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      '※ 긴급 알림은 방해금지모드 중에도 수신됩니다',
                      style: AppTextTheme.bodySmall(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.sp6),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GuardianBottomNav(currentIndex: (Get.arguments as int?) ?? 2),
    );
  }

}

class _AlertToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  const _AlertToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 좌측: 아이콘 (상하 통합)
              SizedBox(
                width: 56.w,
                child: Center(
                  child: Icon(icon, size: 24.w, color: iconColor),
                ),
              ),
              // 우측: 타이틀 + 스위치 / 설명
              Expanded(
                child: Column(
                  children: [
                    // 상단: 타이틀 + 스위치
                    Padding(
                      padding: EdgeInsets.only(
                        left: AppSpacing.md,
                        right: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(title, style: AppTextTheme.bodyLarge(fw: FontWeight.w600)),
                          ),
                          Switch(
                            value: value,
                            onChanged: enabled ? onChanged : null,
                            activeThumbColor: const Color(0xFF4355B9),
                          ),
                        ],
                      ),
                    ),
                    // 하단: 설명
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        left: AppSpacing.md,
                        right: AppSpacing.md,
                        top: 4.h,
                        bottom: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(14.r),
                        ),
                      ),
                      child: Text(subtitle, style: AppTextTheme.bodySmall(color: AppColors.textTertiary)),
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
}
