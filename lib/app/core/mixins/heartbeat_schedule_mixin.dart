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
  /// 예약 시각으로 고를 수 있는 시(hour) 범위. **서버와 반드시 같은 값**
  /// (anbucheck-server/config.py 의 HEARTBEAT_HOUR_MIN/MAX).
  ///
  /// ⚠️ 상한 21시는 UI 취향이 아니라 **서버의 구조적 제약**이다. 서버 미수신 체크
  /// (services/scheduler.py)는 발화 시각을 "그날 로컬 자정 + (예약시각 + 2h)"로
  /// 계산해 매 분 now()와 비교하는데, "그날"이 매 tick마다 now()에서 다시 파생되므로
  /// 22시 이상이면 우변이 항상 미래가 되어 **등호가 영원히 성립하지 않는다.**
  /// 그 대상자는 미수신 판정 자체가 실행되지 않아 안전망 푸시(subject_safety_net)도,
  /// 보호자 caution→warning→urgent 에스컬레이션도 전부 사라진다 — 조용히.
  ///
  /// ⚠️ **하한은 의도적으로 0이다(제한 없음). "새벽은 걸음수가 0이라 오탐"이라는
  /// 이유로 다시 올리지 말 것** — steps_delta가 "오늘 자정~현재" 누적이라, 밤에
  /// 일하고 아침에 잠드는 사람에게는 00:00~07:00이 곧 자기 활동 시간이다.
  /// 그들에게 06:00~08:00은 주간 생활자의 18:00과 같은 자리다.
  ///
  /// 이 가드는 UX용이고 **진짜 방어선은 서버**다(구버전 앱이 계속 PATCH할 수 있으므로).
  static const heartbeatHourMin = 0;

  /// 허용되는 마지막 **시(hour)**. 분은 제한하지 않으므로 실제 선택 가능한 마지막
  /// 시각은 21:59다.
  static const heartbeatHourMax = 21;

  /// 사용자 안내용 경계 표기 — "이 시각 **이전**까지 가능"이라는 배타적 상한이다.
  /// 21:30도 실제로 선택 가능하므로 "오후 9:00까지"로 안내하면 거짓이 된다.
  /// 22:00으로 표기해야 허용 구간(00:00~21:59)과 정확히 일치한다.
  String get heartbeatLimitLabel => formatTimeOfDay(heartbeatHourMax + 1, 0);

  /// 표시 전용 문자열 — 로케일 표기로 포맷된 값이다.
  /// **이 값을 다시 파싱해 시·분을 얻지 말 것.** 시·분은 아래 두 Rx가 정답이다.
  late final heartbeatTime = formatTimeOfDay(18, 0).obs;

  /// 시·분의 단일 진실 소스. `applySchedule`이 모든 경로에서 함께 갱신한다.
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

  /// 피커 초기값 — 표시 문자열을 되파싱하지 않고 int Rx를 그대로 읽는다.
  /// (되파싱은 로케일마다 표기가 달라지는 순간 반드시 깨진다)
  ///
  /// 시(hour)는 허용 범위로 clamp한다 — 구버전 앱에서 22시 이상을 저장해 둔 기기가
  /// 있을 수 있고, iOS `CupertinoDatePicker`는 `initialDateTime`이 `maximumDate`를
  /// 넘으면 **assert로 죽는다**(date_picker.dart의 initialDateTime 단언).
  (int hour, int minute) _currentTime() => (
        heartbeatHour.value.clamp(heartbeatHourMin, heartbeatHourMax),
        heartbeatMinute.value,
      );

  Future<void> _showMaterialTimePicker() async {
    final (hour, minute) = _currentTime();
    final picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      // Material `showTimePicker`에는 선택 범위를 제한하는 파라미터가 없다(입력 모드의
      // 검증자도 private이라 주입 불가). 그래서 다이얼에서는 22시 이후도 고를 수 있고,
      // 실제 차단은 _updateTime의 사후 가드가 한다. 대신 헤더 문구로 **고르기 전에**
      // 상한을 알려 거절당하는 경험 자체를 줄인다.
      helpText: 'heartbeat_picker_help'.trParams({'limit': heartbeatLimitLabel}),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx)
            .copyWith(alwaysUse24HourFormat: timeStyle == TimeStyle.h24),
        child: child!,
      ),
    );
    if (picked != null) await _updateTime(picked.hour, picked.minute);
  }

  Future<void> _showCupertinoTimePicker() async {
    final (hour, minute) = _currentTime();
    final initialDate = DateTime(2026, 1, 1, hour, minute);
    var selectedTime = initialDate;

    await showCupertinoModalPopup(
      context: Get.context!,
      builder: (context) => Container(
        // Android의 helpText에 대응하는 안내 한 줄이 들어가므로 그만큼 높인다
        // (Expanded로 휠이 줄어드는 대신 전체를 키워 휠 높이를 유지).
        height: 336,
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
            // CupertinoDatePicker 자체에는 제목/안내 영역이 없다(Material의 helpText에
            // 해당하는 파라미터가 없음). 이 모달을 직접 조립하고 있으므로 여기에 넣는다.
            // iOS는 범위 밖 시각이 회색으로 보이기만 해서 **왜** 못 고르는지 알 수 없다.
            // 이 한 줄이 그 이유를 설명한다 — Android보다 오히려 더 필요하다.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'heartbeat_picker_help'.trParams({'limit': heartbeatLimitLabel}),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: timeStyle == TimeStyle.h24,
                initialDateTime: initialDate,
                // `.time` 모드에서도 maximumDate가 동작한다 — 단 initialDateTime과
                // **같은 날짜**여야 한다(같은 날이 아니면 시각 제한이 걸리지 않는다).
                // 범위 밖 항목은 회색으로 표시되고, 스크롤이 거기 멈추면 자동으로
                // 되돌아오며, onDateTimeChanged 자체가 호출되지 않는다.
                // 하한은 두지 않으므로 minimumDate는 지정하지 않는다.
                maximumDate: DateTime(
                  initialDate.year,
                  initialDate.month,
                  initialDate.day,
                  heartbeatHourMax,
                  59,
                ),
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
    heartbeatTime.value = formatTimeOfDay(hour, minute);
  }

  Future<void> _updateTime(int hour, int minute) async {
    // 두 피커(Material/Cupertino) 모두 시간대 자체를 제한할 수 없어(time 모드에서는
    // min/max가 먹지 않는다) 선택 후 여기서 거른다. 두 경로가 모두 이 메서드를
    // 통과하므로 여기가 단일 관문이다.
    if (hour < heartbeatHourMin || hour > heartbeatHourMax) {
      AppSnackbar.show(
        'heartbeat_range_limit_title'.tr,
        'heartbeat_range_limit_message'.trParams({'limit': heartbeatLimitLabel}),
      );
      return;
    }
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
      // 다른 읽기 지점(loadStatus/_reloadHeartbeatState)과 동일하게 prefs를 reload한 뒤
      // 읽는다 — 첫 전송 직후 등 SharedPreferences 인메모리 캐시가 디스크와 불일치할 때
      // stale(빈) 값을 읽어 wasReportedToday=false로 오판하던 것을 방지.
      await getReloadedPrefs();
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

    // 2) 예약 트리거 재설정 — best-effort. 실패해도 시각 변경 자체는 성공.
    // Android: WorkManager / iOS G+S: 로컬 알림(BGTask 미사용, 오늘/내일은 schedule이 자동 결정)
    try {
      if (Platform.isAndroid) {
        await HeartbeatWorkerService.schedule(hour, minute);
      }
      await LocalAlarmService.schedule(hour, minute);
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
