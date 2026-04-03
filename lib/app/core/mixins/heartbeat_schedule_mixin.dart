import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';

/// Heartbeat 시각 변경 기능 Mixin
/// 대상자/보호자 컨트롤러에서 공통으로 사용
mixin HeartbeatScheduleMixin on GetxController {
  final heartbeatTime = '오전 09:30'.obs;
  final heartbeatHour = 9.obs;
  final heartbeatMinute = 30.obs;

  /// 로컬 저장된 스케줄 로드 (onInit에서 호출)
  Future<void> loadScheduleFromLocal() async {
    final (h, m) = await TokenLocalDatasource().getHeartbeatSchedule();
    applySchedule(h, m);
  }

  /// 시각 값을 UI에 반영 (API 호출 없이 표시만 갱신)
  void applySchedule(int hour, int minute) {
    heartbeatHour.value = hour;
    heartbeatMinute.value = minute;
    _applyToHeartbeatTime(hour, minute);
  }

  Future<void> showTimePickerDialog() async {
    if (Platform.isIOS) {
      await _showCupertinoTimePicker();
    } else {
      await _showMaterialTimePicker();
    }
  }

  (int hour, int minute) _parseTime() {
    final text = heartbeatTime.value;
    final isPm = text.contains('오후');
    final timePart = text.replaceAll(RegExp(r'[오전오후\s]'), '');
    final parts = timePart.split(':');
    var hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return (hour, minute);
  }

  Future<void> _showMaterialTimePicker() async {
    final (hour, minute) = _parseTime();
    final picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );
    if (picked != null) await _updateTime(picked.hour, picked.minute);
  }

  Future<void> _showCupertinoTimePicker() async {
    final (hour, minute) = _parseTime();
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
                    onPressed: () async {
                      Navigator.pop(context);
                      await _updateTime(selectedTime.hour, selectedTime.minute);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: initialDate,
                onDateTimeChanged: (dateTime) {
                  selectedTime = dateTime;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyToHeartbeatTime(int hour, int minute) {
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    heartbeatTime.value = '$period ${displayHour.toString().padLeft(2, '0')}:$m';
  }

  Future<void> _updateTime(int hour, int minute) async {
    await onHeartbeatTimeChanged(hour, minute);
  }

  /// 시각 변경 후 서버 전송 → 성공 시 로컬 저장 + WorkManager/로컬알림 재예약
  Future<void> onHeartbeatTimeChanged(int hour, int minute) async {
    final tokenDs = TokenLocalDatasource();
    try {
      final deviceToken = await tokenDs.getDeviceToken();
      final deviceId = await tokenDs.getDeviceId();
      if (deviceToken == null || deviceId == null) return;
      await DeviceRemoteDatasource()
          .updateHeartbeatSchedule(deviceToken, deviceId, hour, minute);
      await tokenDs.saveHeartbeatSchedule(hour, minute);
      heartbeatHour.value = hour;
      heartbeatMinute.value = minute;
      _applyToHeartbeatTime(hour, minute);
      // WorkManager 재예약 (heartbeat 백그라운드 실행)
      await HeartbeatWorkerService.schedule(hour, minute);
      // 로컬 안전망 알림 재예약 (오늘 이미 전송했으면 내일로)
      final lastDate = await tokenDs.getLastHeartbeatDate();
      final now = DateTime.now();
      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final isNextDay = lastDate == today;
      await LocalAlarmService.schedule(hour, minute, nextDay: isNextDay);
      final period = hour < 12 ? '오전' : '오후';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final timeStr = '$period ${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      final message = isNextDay
          ? '변경된 시각($timeStr)은 내일부터 적용됩니다.'
          : '오늘 $timeStr에 안부 확인이 예약되었습니다.';
      Get.snackbar('', message,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2));
    } catch (e) {
      Get.snackbar('시각 변경 실패', '서버에 반영되지 않았습니다.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2));
    }
  }
}
