import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/core/widgets/add_subject_button.dart';
import 'package:anbucheck/app/modules/guardian_connection_management/controllers/guardian_connection_management_controller.dart';
import 'package:anbucheck/app/core/utils/back_press_handler.dart';
import 'package:anbucheck/app/core/widgets/guardian_bottom_nav.dart';

/// 보호자 연결 관리 페이지 — 시안 _4 기준
class GuardianConnectionManagementPage extends GetWidget<GuardianConnectionManagementController> {
  const GuardianConnectionManagementPage({super.key});

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
            Icon(Icons.link_rounded, size: 22.w, color: AppColors.onSurface),
            SizedBox(width: 8.w),
            Text('connection_title'.tr, style: AppTextTheme.headlineSmall()),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.lg),

              // 헤더 카드
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guardian Mode',
                      style: AppTextTheme.labelSmall(
                        color: AppColors.textTertiary,
                        fw: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: 'connection_managed_count'.tr, style: AppTextTheme.headlineMedium()),
                          TextSpan(
                            text: 'connection_managed_count_value'.trParams({'current': '${controller.subjects.length}', 'max': '${controller.maxSubjects}'}),
                            style: AppTextTheme.headlineMedium(
                              color: const Color(0xFF4355B9),
                              fw: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // 연결된 대상자 섹션
              Text('connection_connected_subjects'.tr, style: AppTextTheme.headlineSmall(fw: FontWeight.w600)),
              SizedBox(height: AppSpacing.lg),

              // 대상자 리스트 (남은 공간 채움, 내부 스크롤)
              Expanded(
                child: Container(
                  color: AppColors.surfaceContainerLow,
                  child: Scrollbar(
                    controller: controller.listScrollController,
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: controller.listScrollController,
                      padding: EdgeInsets.all(AppSpacing.md),
                      itemCount: controller.subjects.length,
                      itemBuilder: (_, index) {
                        final subject = controller.subjects[index];
                        return _SubjectListTile(
                          alias: subject.alias,
                          code: subject.code,
                          heartbeatHour: subject.heartbeatHour,
                          heartbeatMinute: subject.heartbeatMinute,
                          hasDevice: subject.deviceId != null,
                          onSaveAlias: (newAlias) => controller.saveAlias(index, newAlias),
                          onDelete: () => controller.deleteSubject(index),
                        );
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.lg),

              // 새로운 대상자 추가
              AddSubjectButton(onTap: controller.goToAddSubject),
              SizedBox(height: AppSpacing.md),

              // 하단 안내 박스
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Get.isDarkMode
                      ? const Color(0xFF4E2A00).withValues(alpha: 0.5)
                      : const Color(0xFFFFF3E0).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18.w, color: const Color(0xFFFF9800)),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${'connection_unlink_warning'.tr}'
                        '${'connection_unlink_warning_detail'.tr}',
                        style: AppTextTheme.bodySmall(color: const Color(0xFFE65100)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const GuardianBottomNav(currentIndex: 1),
    ),
    );
  }

}

class _SubjectListTile extends StatelessWidget {
  final String alias;
  final String code;
  final int heartbeatHour;
  final int heartbeatMinute;
  final bool hasDevice;
  final Future<void> Function(String newAlias) onSaveAlias;
  final VoidCallback onDelete;

  const _SubjectListTile({
    required this.alias,
    required this.code,
    required this.heartbeatHour,
    required this.heartbeatMinute,
    required this.hasDevice,
    required this.onSaveAlias,
    required this.onDelete,
  });

  String get _timeLabel {
    final period = heartbeatHour < 12 ? 'common_am'.tr : 'common_pm'.tr;
    final h = heartbeatHour == 0 ? 12 : (heartbeatHour > 12 ? heartbeatHour - 12 : heartbeatHour);
    final m = heartbeatMinute.toString().padLeft(2, '0');
    return '매일 $period ${h.toString().padLeft(2, '0')}:$m';
  }

  void _openEditDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _EditSubjectDialog(
        alias: alias,
        onSaveAlias: onSaveAlias,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        children: [
          // 상단 카드: 대상자 정보
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: hasDevice
                  ? BorderRadius.vertical(top: Radius.circular(14.r))
                  : BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  child: Icon(Icons.person, size: 22.w, color: AppColors.onSurfaceVariant),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alias, style: AppTextTheme.bodyLarge(fw: FontWeight.w600)),
                      SizedBox(height: 2.h),
                      Text(code, style: AppTextTheme.bodySmall(color: AppColors.textTertiary)),
                      if (hasDevice) ...[
                        SizedBox(height: 2.h),
                        Text(
                          _timeLabel,
                          style: AppTextTheme.bodySmall(
                            color: const Color(0xFF4355B9),
                            fw: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _openEditDialog(context),
                  icon: Icon(Icons.edit_rounded, size: 20.w, color: const Color(0xFF4355B9)),
                  constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded, size: 20.w, color: AppColors.error),
                  constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
                ),
              ],
            ),
          ),
          // 하단 카드: 안부 보고시간 안내
          if (hasDevice)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFF4355B9),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(14.r)),
              ),
              child: RichText(
                text: TextSpan(
                  style: AppTextTheme.labelSmall(color: Colors.white70),
                  children: [
                    TextSpan(text: 'connection_heartbeat_report_time'.tr),
                    TextSpan(
                      text: 'connection_subject_label'.tr,
                      style: AppTextTheme.labelSmall(
                        color: Colors.white,
                        fw: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' ${'connection_change_only_in_app'.tr}'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EditSubjectDialog extends StatefulWidget {
  final String alias;
  final Future<void> Function(String) onSaveAlias;

  const _EditSubjectDialog({
    required this.alias,
    required this.onSaveAlias,
  });

  @override
  State<_EditSubjectDialog> createState() => _EditSubjectDialogState();
}

class _EditSubjectDialogState extends State<_EditSubjectDialog> {
  late final TextEditingController _aliasController;

  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController(text: widget.alias);
  }

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newAlias = _aliasController.text.trim();
    if (newAlias.isNotEmpty && newAlias != widget.alias) {
      await widget.onSaveAlias(newAlias);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('connection_edit_title'.tr, style: AppTextTheme.headlineSmall()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('connection_alias_label'.tr, style: AppTextTheme.labelMedium(color: AppColors.textSecondary)),
          SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _aliasController,
            decoration: InputDecoration(
              hintText: widget.alias,
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
            style: AppTextTheme.bodyLarge(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('common_cancel'.tr, style: AppTextTheme.bodyMedium(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: _save,
          child: Text('common_save'.tr, style: AppTextTheme.bodyMedium(color: AppColors.onSurface)),
        ),
      ],
    );
  }
}
