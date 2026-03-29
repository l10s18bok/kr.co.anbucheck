import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/modules/permission/controllers/permission_controller.dart';

/// 권한 안내 페이지
/// 모드 선택 후 진입, 모드별 필요한 권한을 안내
class PermissionPage extends GetWidget<PermissionController> {
  const PermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.sp10),
              Text(
                '앱 사용을 위해\n권한이 필요합니다',
                style: AppTextTheme.displaySmall(),
              ),
              SizedBox(height: AppSpacing.sp8),

              // 알림 권한 카드 (공통)
              _PermissionCard(
                icon: Icons.notifications_rounded,
                title: '알림 권한',
                description: controller.isSubjectMode
                    ? '안부 확인 알림을 받기 위해 필요합니다'
                    : '보호 대상자의 안전 상태 알림을 받기 위해 필요합니다',
              ),

              // 걸음수 / 신체 활동 카드 (대상자 모드 + Android만)
              if (controller.isSubjectMode && Platform.isAndroid) ...[
                SizedBox(height: AppSpacing.lg),
                _PermissionCard(
                  icon: Icons.directions_walk_rounded,
                  title: '신체 활동 권한',
                  description: '걸음수를 감지하여 활동 여부를 확인하는 데 사용됩니다',
                ),
              ],

              // 배터리 최적화 카드 (대상자 모드 + Android만)
              if (controller.isSubjectMode && Platform.isAndroid) ...[
                SizedBox(height: AppSpacing.lg),
                _PermissionCard(
                  icon: Icons.battery_saver_rounded,
                  title: '배터리 최적화 제외',
                  description: '매일 자동 안부 전송을 위해 필요합니다',
                ),
              ],

              const Spacer(),

              // 권한 허용 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.requestPermissions,
                  child: Text(
                    '확인',
                    style: AppTextTheme.labelLarge(),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.sp6),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.sp4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppColors.seniorPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              icon,
              size: 28.w,
              color: AppColors.seniorPrimary,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextTheme.headlineSmall()),
                SizedBox(height: 4.h),
                Text(description, style: AppTextTheme.bodyMedium()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
