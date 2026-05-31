import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';

/// Heartbeat 시각 변경 기능 Mixin
/// 대상자/보호자 컨트롤러에서 공통으로 사용
mixin HeartbeatScheduleMixin on GetxController {
  late final heartbeatTime = '${'common_pm'.tr} 06:00'.obs;
  final heartbeatHour = 18.obs;
  final heartbeatMinute = 0.obs;

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
    final initialDate = DateTime(2026, 1, 1, hour, minute);
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

  /// 시각 변경 후 서버 전송 → 성공 시 로컬 저장 + 예약 트리거(WorkManager/로컬알림) 재설정.
  ///
  /// 시각 변경의 source of truth는 **서버 저장 + 로컬 저장**이다. 그게 성공하면
  /// 사용자에겐 성공으로 보고한다(예약 재설정/즉시 전송 실패는 best-effort — 로깅만).
  ///
  /// **예약 트리거 정책** (`forceNextDay = 이미오늘전송됨 || 새시각이오늘지남`):
  ///   1) **이미 오늘 전송됨** → 오늘 할 일은 끝 → 모든 트리거 내일로(forceNextDay).
  ///      `lastHeartbeatDate`를 유지해 오늘 재전송을 막는다(다음 사이클 = 내일).
  ///   2) **미전송 + 새 시각이 오늘 이미 지남(과거)** → 사용자가 앱에서 시각을 바꾼 것
  ///      자체가 살아있음 증거이므로 **지금 즉시 heartbeat 전송**(오늘분 기록 → 거짓
  ///      미수신 경고 방지). 안전망 알람은 내일로(forceNextDay) — 변경 직후 오늘
  ///      즉시 발화하던 스퓨리어스 알림 차단. 전송 성공 시 `_onHeartbeatSent`가
  ///      worker/알람을 내일로 재확정(멱등). 전송 실패해도 안전망은 이미 내일 예약됨.
  ///   3) **미전송 + 새 시각이 미래** → 그 시각에 트리거 예약(오늘). Android 안전망
  ///      알람은 설계대로 heartbeat+3h, iOS는 정시.
  Future<void> onHeartbeatTimeChanged(int hour, int minute) async {
    final tokenDs = TokenLocalDatasource();

    // 1) 핵심 — 서버 전송 + 로컬 저장. 여기 실패만 진짜 실패.
    final bool wasReportedToday;
    try {
      final deviceToken = await tokenDs.getDeviceToken();
      final deviceId = await tokenDs.getDeviceId();
      if (deviceToken == null || deviceId == null) return;

      // 시각 변경 시점의 "오늘 이미 전송됨" 여부 — 키 클리어 전에 캡처해야 정확.
      final lastDate = await tokenDs.getLastHeartbeatDate() ?? '';
      wasReportedToday =
          lastDate.isNotEmpty && lastDate == formatYmd(DateTime.now());

      await DeviceRemoteDatasource().updateHeartbeatSchedule(deviceToken, deviceId, hour, minute);
      await tokenDs.saveHeartbeatSchedule(hour, minute);
      heartbeatHour.value = hour;
      heartbeatMinute.value = minute;
      _applyToHeartbeatTime(hour, minute);

      if (!wasReportedToday) {
        // 미전송이면 선점 키를 비워 새 시각에 전송이 가능하게 한다.
        await tokenDs.saveLastHeartbeatDate('');
        await tokenDs.saveLastHeartbeatTime('');
        await tokenDs.saveLastScheduledKey('');
      }
      // 이미 전송됨이면 lastHeartbeatDate를 유지 → 오늘 재전송 안 함, 다음 사이클은 내일.
    } catch (e, st) {
      debugPrint('[heartbeat-time] 시각 변경 실패(서버/로컬 저장): $e\n$st');
      AppSnackbar.show(
        'heartbeat_change_failed_title'.tr,
        'heartbeat_change_failed_message'.tr,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final now = DateTime.now();
    final newTimeToday = DateTime(now.year, now.month, now.day, hour, minute);
    final passedToday = !newTimeToday.isAfter(now);
    final forceNextDay = wasReportedToday || passedToday;

    // 2) 예약 트리거 재설정 — best-effort. 실패해도 시각 변경 자체는 성공.
    //    forceNextDay로 안전망 알람을 결정적으로 예약(전송 실패와 무관하게 정확).
    // Android: WorkManager + 로컬 안전망 알림 / iOS G+S: 로컬 알림(BGTask 미사용)
    try {
      if (Platform.isAndroid) {
        await HeartbeatWorkerService.schedule(hour, minute);
      }
      await LocalAlarmService.schedule(hour, minute, forceNextDay: forceNextDay);
    } catch (e, st) {
      debugPrint('[heartbeat-time] 예약 트리거 재설정 실패(무시 — 시각 변경은 성공): $e\n$st');
    }

    // 3) 미전송 + 과거 시각 → 지금 즉시 전송(오늘분 기록 → 거짓 미수신 경고 방지).
    //    execute()는 _busy + SQLite 락 + lastScheduledKey로 자가 직렬화돼 중복 전송이
    //    구조적으로 차단되므로 역할(S/G+S) 무관하게 직접 호출해도 안전하다.
    //    성공 시 _onHeartbeatSent가 worker/알람을 내일로 재확정(위 forceNextDay와 동일).
    if (!wasReportedToday && passedToday) {
      try {
        await HeartbeatService()
            .execute(manual: false, isInteractiveAtTrigger: true);
        // 전송 성공 시 lastHeartbeatDate가 오늘로 저장된다 → 사용자에게 "안부 전송됨"을
        // 안내(기존 다국어 키 재사용: "보호자에게 안부를 전했습니다."). 네트워크 실패 시엔
        // 보류 큐로 들어가 날짜가 갱신되지 않으므로 아래 시각 변경 메시지로 폴백.
        final after = await tokenDs.getLastHeartbeatDate() ?? '';
        if (after == formatYmd(DateTime.now())) {
          AppSnackbar.show('', 'subject_home_manual_report_sent'.tr);
          return;
        }
      } catch (e, st) {
        debugPrint('[heartbeat-time] 변경 직후 즉시 전송 실패(무시): $e\n$st');
      }
    }

    final message = 'heartbeat_scheduled_today'.trParams({'time': heartbeatTime.value});
    AppSnackbar.show('', message);
  }
}
