import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/core/widgets/heartbeat_schedule_tile.dart';
import 'package:anbucheck/app/modules/subject_home/controllers/subject_home_controller.dart';

/// 대상자 홈 페이지 — 시안 _9 기준
/// AppBar(메뉴, 프로필) + 안전코드 + 상태카드 + Bento그리드 + 액션버튼 + 광고배너
class SubjectHomePage extends GetWidget<SubjectHomeController> {
  const SubjectHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.onSurface, size: 24.w),
          onPressed: () {},
        ),
        title: Obx(() => Text(
              controller.userId > 0 ? '안부 (${controller.userId})' : '안부',
              style: AppTextTheme.headlineSmall(),
            )),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: CircleAvatar(
              radius: 18.r,
              backgroundColor: AppColors.surfaceContainerHigh,
              child: Icon(Icons.person, size: 20.w, color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.lg),

            // 안전 코드 공유 안내
            Text(
              '나의 안전 코드를 공유해 주세요',
              style: AppTextTheme.headlineMedium(
                color: const Color(0xFF00685E),
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Safety Share Code 카드
            _buildSafetyCodeCard(),
            SizedBox(height: AppSpacing.lg),

            // 마지막 안부 확인 상태 카드
            _buildLastCheckCard(),
            SizedBox(height: AppSpacing.lg),

            // Bento 그리드 (배터리 + 통신)
            _buildBentoGrid(),
            SizedBox(height: AppSpacing.sp6),

            // 지금 바로 안전 보고하기 버튼
            _buildReportButton(),
            SizedBox(height: AppSpacing.lg),

            // 안부 확인 시각 변경 버튼
            Obx(() => HeartbeatScheduleTile(
                  heartbeatTime: controller.heartbeatTime.value,
                  onTap: controller.showTimePickerDialog,
                  color: const Color(0xFF00685E),
                  backgroundColor: const Color(0xFFE0F2F1),
                )),
            SizedBox(height: AppSpacing.sp6),

            // 광고 배너
            _buildAdBanner(),
            SizedBox(height: AppSpacing.sp6),
          ],
        ),
      ),
    );
  }

  /// Safety Share Code 카드
  Widget _buildSafetyCodeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.sp4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Obx(() => Column(
            children: [
              // SAFETY SHARE CODE 헤더 + 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SAFETY SHARE CODE',
                    style: AppTextTheme.labelMedium(
                      color: AppColors.textTertiary,
                      fw: FontWeight.w600,
                    ),
                  ),
                  if (controller.notificationGranted)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: controller.copyInviteCode,
                          child: Container(
                            padding: EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.copy_rounded,
                              size: 20.w,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        GestureDetector(
                          onTap: controller.shareInviteCode,
                          child: Container(
                            padding: EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.share_rounded,
                              size: 20.w,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              // 초대 코드 (가운데 정렬)
              Text(
                controller.notificationGranted
                    ? controller.inviteCode
                    : 'XXX-XXXX',
                style: TextStyle(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w800,
                  color: controller.notificationGranted
                      ? const Color(0xFF00685E)
                      : AppColors.textTertiary,
                  letterSpacing: 2,
                ),
              ),
            ],
          )),
    );
  }

  /// 안부 확인 상태 카드 (보고 완료 / 보고 예정 / 보고 대기 중 동적 표시)
  Widget _buildLastCheckCard() {
    return Obx(() {
      final state = controller.checkCardState;
      final iconData = state == 'reported'
          ? Icons.check_rounded
          : state == 'waiting'
              ? Icons.hourglass_top_rounded
              : Icons.schedule_rounded;
      final iconBg = state == 'reported'
          ? const Color(0xFF00685E)
          : state == 'waiting'
              ? const Color(0xFFE65100)
              : AppColors.surfaceContainerHigh;
      final iconColor = state == 'reported' || state == 'waiting'
          ? Colors.white
          : AppColors.onSurfaceVariant;
      final textColor = state == 'waiting'
          ? const Color(0xFFE65100)
          : const Color(0xFF00685E);

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, size: 28.w, color: iconColor),
            ),
            SizedBox(width: AppSpacing.lg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.checkCardTitle,
                  style: AppTextTheme.bodyMedium(
                      color: AppColors.textSecondary),
                ),
                SizedBox(height: 2.h),
                Text(
                  controller.checkCardBody,
                  style: AppTextTheme.headlineSmall(
                      color: textColor, fw: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Bento 그리드 (배터리 + 통신 상태)
  Widget _buildBentoGrid() {
    return Obx(() {
      final batteryLow = controller.isBatteryLow;
      final batteryColor = batteryLow
          ? const Color(0xFFD32F2F)
          : const Color(0xFF00685E);
      final disconnected = !controller.isConnected;
      final connectColor = disconnected
          ? const Color(0xFFE64A19)
          : const Color(0xFF00685E);

      return Row(
        children: [
          // 배터리 상태
          Expanded(
            child: Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: batteryLow
                    ? const Color(0xFFFFEBEE)
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        _getBatteryIcon(controller.batteryState, controller.batteryLevel),
                        size: 24.w,
                        color: batteryColor,
                      ),
                      Text(
                        '${controller.batteryLevel}%',
                        style: AppTextTheme.headlineSmall(
                          color: batteryColor,
                          fw: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    '배터리 상태',
                    style: AppTextTheme.bodySmall(),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    controller.batteryStateText,
                    style: AppTextTheme.headlineSmall(
                      color: batteryColor,
                      fw: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          // 통신 연결 상태
          Expanded(
            child: Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: disconnected
                    ? const Color(0xFFFBE9E7)
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        controller.isConnected
                            ? Icons.wifi_rounded
                            : Icons.wifi_off_rounded,
                        size: 24.w,
                        color: connectColor,
                      ),
                      Text(
                        controller.connectivityText,
                        style: AppTextTheme.headlineSmall(
                          color: connectColor,
                          fw: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    '통신 연결 상태',
                    style: AppTextTheme.bodySmall(),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    controller.isConnected ? '정상' : '연결 없음',
                    style: AppTextTheme.headlineSmall(
                      color: connectColor,
                      fw: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  /// 지금 바로 안전 보고하기 버튼
  Widget _buildReportButton() {
    return Obx(() {
      final sending = controller.isReporting;
      return GestureDetector(
        onTap: sending ? null : controller.reportNow,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 20.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: sending
                  ? [const Color(0xFF4A7C78), const Color(0xFF4A7C78)]
                  : [const Color(0xFF00685E), const Color(0xFF008377)],
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (sending)
                    SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  else
                    Icon(Icons.verified_user_rounded,
                        size: 24.w, color: Colors.white),
                  SizedBox(width: 8.w),
                  Text(
                    sending ? '안부 보고 중...' : '지금 바로 안전 보고하기',
                    style: AppTextTheme.headlineSmall(
                      color: Colors.white,
                      fw: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                '보호자에게 걱정 말라고 알려주세요',
                style: AppTextTheme.bodySmall(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 배터리 잔량에 따른 아이콘
  IconData _getBatteryIcon(BatteryState state, int level) {
    if (state == BatteryState.charging) return Icons.battery_charging_full_rounded;
    if (level >= 90) return Icons.battery_full_rounded;
    if (level >= 70) return Icons.battery_6_bar_rounded;
    if (level >= 50) return Icons.battery_5_bar_rounded;
    if (level >= 30) return Icons.battery_3_bar_rounded;
    if (level >= 15) return Icons.battery_2_bar_rounded;
    return Icons.battery_alert_rounded;
  }

  /// 광고 배너 영역
  Widget _buildAdBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.image_rounded,
                size: 24.w, color: AppColors.onSurfaceVariant),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADVERTISEMENT',
                  style: AppTextTheme.labelSmall(
                    color: AppColors.textTertiary,
                    fw: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '시니어를 위한 프리미엄 건강 관리 서비스',
                  style: AppTextTheme.bodyMedium(),
                ),
              ],
            ),
          ),
          Icon(Icons.open_in_new_rounded,
              size: 18.w, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }
}
