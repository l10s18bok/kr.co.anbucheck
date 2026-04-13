import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';

/// Heartbeat 시각 변경 기능 Mixin
/// 대상자/보호자 컨트롤러에서 공통으로 사용
mixin HeartbeatScheduleMixin on GetxController {
  late final heartbeatTime = '${'common_am'.tr} 09:30'.obs;
  final heartbeatHour = 9.obs;
  final heartbeatMinute = 30.obs;

  /// 로컬 저장된 스케줄 로드 (onInit / onResumed에서 호출)
  /// iOS 백그라운드 복귀 시 SharedPreferences 캐시가 디스크와 불일치할 수 있으므로
  /// reload() 후 읽기
  Future<void> loadScheduleFromLocal() async {
    await getReloadedPrefs();
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
    final isPm = text.contains('common_pm'.tr);
    final timePart = text.replaceAll(RegExp('(${'common_am'.tr}|${'common_pm'.tr}|\\s)'), '');
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
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: Text('common_cancel'.tr),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoButton(
                  child: Text('common_confirm'.tr),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _updateTime(selectedTime.hour, selectedTime.minute);
                  },
                ),
              ],
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
    final period = hour < 12 ? 'common_am'.tr : 'common_pm'.tr;
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
      // 예약시각 변경 시 하루 1회 제한 리셋 (재테스트 가능)
      await tokenDs.saveLastHeartbeatDate('');
      await tokenDs.saveLastHeartbeatTime('');
      // Android: WorkManager + 로컬 안전망 재예약
      // iOS G+S: 데드맨 로컬 알림만 재예약 (BGTaskScheduler 사용 안 함)
      if (Platform.isAndroid) {
        await HeartbeatWorkerService.schedule(hour, minute);
      }
      await LocalAlarmService.schedule(hour, minute);
      final message = 'heartbeat_scheduled_today'.trParams({'time': heartbeatTime.value});
      Get.snackbar('', message,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.white,
          colorText: const Color(0xFF1a1c1c));
    } catch (e) {
      Get.snackbar('heartbeat_change_failed_title'.tr, 'heartbeat_change_failed_message'.tr,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.white,
          colorText: const Color(0xFF1a1c1c));
    }
  }
}
