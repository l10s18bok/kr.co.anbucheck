import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/core/widgets/add_subject_button.dart';
import 'package:anbucheck/app/core/widgets/heartbeat_schedule_tile.dart';
import 'package:anbucheck/app/modules/guardian_connection_management/controllers/guardian_connection_management_controller.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 보호자 연결 관리 페이지 — 시안 _4 기준
class GuardianConnectionManagementPage extends GetWidget<GuardianConnectionManagementController> {
  const GuardianConnectionManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('연결관리', style: AppTextTheme.headlineSmall()),
      ),
      body: SingleChildScrollView(
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
                          TextSpan(text: '관리 보호 대상자 수 ', style: AppTextTheme.headlineMedium()),
                          TextSpan(
                            text: '${controller.subjects.length} / ${controller.maxSubjects}명',
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
              Text('연결된 보호 대상자', style: AppTextTheme.headlineSmall(fw: FontWeight.w600)),
              SizedBox(height: AppSpacing.lg),

              // 대상자 리스트
              ...List.generate(controller.subjects.length, (index) {
                final subject = controller.subjects[index];
                return _SubjectListTile(
                  alias: subject.alias,
                  code: subject.code,
                  heartbeatHour: subject.heartbeatHour,
                  heartbeatMinute: subject.heartbeatMinute,
                  hasDevice: subject.deviceId != null,
                  onSaveAlias: (newAlias) => controller.saveAlias(index, newAlias),
                  onScheduleChange: (hour, minute) =>
                      controller.updateSchedule(index, hour, minute),
                  onDelete: () => controller.deleteSubject(index),
                );
              }),

              SizedBox(height: AppSpacing.lg),

              // 새로운 대상자 추가
              AddSubjectButton(onTap: controller.goToAddSubject),
              SizedBox(height: AppSpacing.sp6),

              // 하단 안내 박스
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18.w, color: const Color(0xFFFF9800)),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '연결 해제 시 해당 보호 대상자의 데이터는 삭제됩니다.'
                        '재연결 시 이전의 기록을 복구할 수 없으며,\n'
                        '보호 대상자 코드를 다시 입력해야 합니다.',
                        style: AppTextTheme.bodySmall(color: const Color(0xFFE65100)),
                      ),
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
    return BottomNavigationBar(
      currentIndex: 1,
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
            break; // 현재 페이지
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

class _SubjectListTile extends StatelessWidget {
  final String alias;
  final String code;
  final int heartbeatHour;
  final int heartbeatMinute;
  final bool hasDevice;
  final Future<void> Function(String newAlias) onSaveAlias;
  final Future<void> Function(int hour, int minute) onScheduleChange;
  final VoidCallback onDelete;

  const _SubjectListTile({
    required this.alias,
    required this.code,
    required this.heartbeatHour,
    required this.heartbeatMinute,
    required this.hasDevice,
    required this.onSaveAlias,
    required this.onScheduleChange,
    required this.onDelete,
  });

  String get _timeLabel {
    final period = heartbeatHour < 12 ? '오전' : '오후';
    final h = heartbeatHour == 0 ? 12 : (heartbeatHour > 12 ? heartbeatHour - 12 : heartbeatHour);
    final m = heartbeatMinute.toString().padLeft(2, '0');
    return '매일 $period ${h.toString().padLeft(2, '0')}:$m';
  }

  void _openEditDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _EditSubjectDialog(
        alias: alias,
        heartbeatHour: heartbeatHour,
        heartbeatMinute: heartbeatMinute,
        hasDevice: hasDevice,
        onSaveAlias: onSaveAlias,
        onScheduleChange: onScheduleChange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14.r),
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
    );
  }
}

class _EditSubjectDialog extends StatefulWidget {
  final String alias;
  final int heartbeatHour;
  final int heartbeatMinute;
  final bool hasDevice;
  final Future<void> Function(String) onSaveAlias;
  final Future<void> Function(int hour, int minute) onScheduleChange;

  const _EditSubjectDialog({
    required this.alias,
    required this.heartbeatHour,
    required this.heartbeatMinute,
    required this.hasDevice,
    required this.onSaveAlias,
    required this.onScheduleChange,
  });

  @override
  State<_EditSubjectDialog> createState() => _EditSubjectDialogState();
}

class _EditSubjectDialogState extends State<_EditSubjectDialog> {
  late final TextEditingController _aliasController;
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _aliasController = TextEditingController(text: widget.alias);
    _hour = widget.heartbeatHour;
    _minute = widget.heartbeatMinute;
  }

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  String get _timeLabel {
    final period = _hour < 12 ? '오전' : '오후';
    final h = _hour == 0 ? 12 : (_hour > 12 ? _hour - 12 : _hour);
    final m = _minute.toString().padLeft(2, '0');
    return '$period ${h.toString().padLeft(2, '0')}:$m';
  }

  Future<void> _pickTime() async {
    if (Platform.isIOS) {
      await _showCupertinoPicker();
    } else {
      await _showMaterialPicker();
    }
  }

  Future<void> _showMaterialPicker() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );
    if (picked != null) {
      setState(() {
        _hour = picked.hour;
        _minute = picked.minute;
      });
    }
  }

  Future<void> _showCupertinoPicker() async {
    var selected = DateTime(2024, 1, 1, _hour, _minute);
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(child: const Text('취소'), onPressed: () => Navigator.pop(ctx)),
                  CupertinoButton(
                    child: const Text('확인'),
                    onPressed: () {
                      setState(() {
                        _hour = selected.hour;
                        _minute = selected.minute;
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: selected,
                onDateTimeChanged: (dt) => selected = dt,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final newAlias = _aliasController.text.trim();
    if (newAlias.isNotEmpty && newAlias != widget.alias) {
      await widget.onSaveAlias(newAlias);
    }
    if (widget.hasDevice && (_hour != widget.heartbeatHour || _minute != widget.heartbeatMinute)) {
      await widget.onScheduleChange(_hour, _minute);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('보호 대상자 편집', style: AppTextTheme.headlineSmall()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('별칭', style: AppTextTheme.labelMedium(color: AppColors.textSecondary)),
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
          if (widget.hasDevice) ...[
            SizedBox(height: AppSpacing.lg),
            HeartbeatScheduleTile(
              heartbeatTime: _timeLabel,
              onTap: _pickTime,
              color: const Color(0xFF4355B9),
              backgroundColor: const Color(0xFFEEF0FB),
              label: '안부 확인 시각',
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        TextButton(onPressed: _save, child: const Text('저장')),
      ],
    );
  }
}
