import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/mixins/heartbeat_schedule_mixin.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/notification_settings_remote_datasource.dart';

/// 보호자 알림 설정 컨트롤러
/// PRD: 등급별 알림 토글, 방해금지모드, heartbeat 시각 변경
class GuardianNotificationSettingsController extends BaseController
    with HeartbeatScheduleMixin {
  final _tokenDs = TokenLocalDatasource();
  final _remoteDs = NotificationSettingsRemoteDatasource();

  final allNotifications = true.obs;
  final urgentEnabled = true.obs;
  final warningEnabled = true.obs;
  final cautionEnabled = true.obs;
  final infoEnabled = true.obs;
  final dndEnabled = false.obs;

  // 방해금지모드 시간 (기본: 22:00 ~ 07:00)
  final dndStartTime = '오후 10:00'.obs;
  final dndEndTime = '오전 07:00'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final token = await _tokenDs.getDeviceToken();
    if (token == null) return;
    try {
      final data = await _remoteDs.getSettings(token);
      allNotifications.value = data['all_enabled'] as bool? ?? true;
      urgentEnabled.value = data['urgent_enabled'] as bool? ?? true;
      warningEnabled.value = data['warning_enabled'] as bool? ?? true;
      cautionEnabled.value = data['caution_enabled'] as bool? ?? true;
      infoEnabled.value = data['info_enabled'] as bool? ?? true;
      dndEnabled.value = data['dnd_enabled'] as bool? ?? false;
      final start = data['dnd_start'] as String?;
      final end = data['dnd_end'] as String?;
      if (start != null) dndStartTime.value = _hhmm24ToDisplay(start);
      if (end != null) dndEndTime.value = _hhmm24ToDisplay(end);
    } catch (_) {
      // 네트워크 실패 시 기본값 유지
    }
  }

  Future<void> _saveSettings() async {
    final token = await _tokenDs.getDeviceToken();
    if (token == null) return;
    try {
      await _remoteDs.updateSettings(token, {
        'all_enabled': allNotifications.value,
        'urgent_enabled': urgentEnabled.value,
        'warning_enabled': warningEnabled.value,
        'caution_enabled': cautionEnabled.value,
        'info_enabled': infoEnabled.value,
        'dnd_enabled': dndEnabled.value,
        'dnd_start': dndEnabled.value ? _displayToHhmm24(dndStartTime.value) : null,
        'dnd_end': dndEnabled.value ? _displayToHhmm24(dndEndTime.value) : null,
      });
    } catch (_) {
      // 네트워크 실패 시 무시
    }
  }

  /// "오후 10:00" → "22:00"
  String _displayToHhmm24(String display) {
    final isPm = display.contains('오후');
    final timePart = display.replaceAll(RegExp(r'[오전오후\s]'), '');
    final parts = timePart.split(':');
    var hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// "22:00" → "오후 10:00"
  String _hhmm24ToDisplay(String hhmm) {
    final parts = hhmm.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$period ${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  void toggleAll(bool value) {
    allNotifications.value = value;
    urgentEnabled.value = value;
    warningEnabled.value = value;
    cautionEnabled.value = value;
    infoEnabled.value = value;
    _saveSettings();
  }

  void toggleUrgent(bool v) { urgentEnabled.value = v; _saveSettings(); }
  void toggleWarning(bool v) { warningEnabled.value = v; _saveSettings(); }
  void toggleCaution(bool v) { cautionEnabled.value = v; _saveSettings(); }
  void toggleInfo(bool v) { infoEnabled.value = v; _saveSettings(); }
  void toggleDnd(bool v) { dndEnabled.value = v; _saveSettings(); }

  Future<void> showDndStartPicker() async {
    await _showTimePicker(dndStartTime);
  }

  Future<void> showDndEndPicker() async {
    await _showTimePicker(dndEndTime);
  }

  Future<void> _showTimePicker(RxString target) async {
    if (Platform.isIOS) {
      await _showCupertinoPicker(target);
    } else {
      await _showMaterialPicker(target);
    }
  }

  (int, int) _parseTimeString(String text) {
    final isPm = text.contains('오후');
    final timePart = text.replaceAll(RegExp(r'[오전오후\s]'), '');
    final parts = timePart.split(':');
    var hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return (hour, minute);
  }

  String _formatTime(int hour, int minute) {
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$period ${displayHour.toString().padLeft(2, '0')}:$m';
  }

  Future<void> _showMaterialPicker(RxString target) async {
    final (hour, minute) = _parseTimeString(target.value);
    final picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );
    if (picked != null) {
      target.value = _formatTime(picked.hour, picked.minute);
      dndEnabled.value = false; // 시각 변경 시 스위치 OFF
    }
  }

  Future<void> _showCupertinoPicker(RxString target) async {
    final (hour, minute) = _parseTimeString(target.value);
    final initialDate = DateTime(2024, 1, 1, hour, minute);
    var selectedTime = initialDate;

    await showCupertinoModalPopup(
      context: Get.context!,
      builder: (context) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('취소'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('확인'),
                    onPressed: () {
                      target.value =
                          _formatTime(selectedTime.hour, selectedTime.minute);
                      dndEnabled.value = false; // 시각 변경 시 스위치 OFF
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: initialDate,
                onDateTimeChanged: (dt) => selectedTime = dt,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
