import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/notification_settings_remote_datasource.dart';

/// 보호자 알림 설정 컨트롤러
/// - 개별 스위치 ↔ "전체 알림 받기" 양방향 동기화
/// - 화면 닫힐 때 변경 사항이 있으면 1회만 API 호출
class GuardianNotificationSettingsController extends BaseController {
  final _tokenDs = TokenLocalDatasource();
  final _remoteDs = NotificationSettingsRemoteDatasource();

  final allNotifications = true.obs;
  final urgentEnabled = true.obs;
  final warningEnabled = true.obs;
  final cautionEnabled = true.obs;
  final infoEnabled = true.obs;
  final dndEnabled = false.obs;

  // 방해금지모드 시간 (기본: 22:00 ~ 07:00)
  //
  // 시·분을 int로 들고 표시 문자열은 파생시킨다. 과거에는 표시 문자열만 보관하고
  // 서버 전송 시 되파싱했는데(`_displayToHhmm24`), 표기가 로케일마다 다르면
  // 반드시 깨진다 — 실제로 힌디어 기본값 'रात 10:00'은 common_pm('शाम')과
  // 토큰이 달라 int.parse에서 FormatException이 났다.
  final dndStartHour = 22.obs;
  final dndStartMinute = 0.obs;
  final dndEndHour = 7.obs;
  final dndEndMinute = 0.obs;

  /// 표시 전용 파생값 — UI는 이 값을, 서버 전송은 위 int를 쓴다.
  String get dndStartTime => formatTimeOfDay(dndStartHour.value, dndStartMinute.value);
  String get dndEndTime => formatTimeOfDay(dndEndHour.value, dndEndMinute.value);

  /// 서버에서 로드한 초기 설정값 (변경 감지용)
  Map<String, dynamic>? _initialSettings;

  /// 설정이 로드 완료되었는지 여부
  bool _loaded = false;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  @override
  void onClose() {
    _saveIfChanged();
    super.onClose();
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
      _applyHhmm(start, dndStartHour, dndStartMinute);
      _applyHhmm(end, dndEndHour, dndEndMinute);

      // "전체 알림 받기" 초기 동기화: 개별 스위치 하나라도 OFF면 OFF
      _syncAllSwitch();

      // 초기 스냅샷 저장
      _initialSettings = _currentPayload();
      _loaded = true;
    } catch (_) {
      // 네트워크 실패 시 기본값 유지
    }
  }

  /// 현재 설정값을 API 페이로드 형태로 반환
  Map<String, dynamic> _currentPayload() => {
    'all_enabled': allNotifications.value,
    'urgent_enabled': urgentEnabled.value,
    'warning_enabled': warningEnabled.value,
    'caution_enabled': cautionEnabled.value,
    'info_enabled': infoEnabled.value,
    'dnd_enabled': dndEnabled.value,
    // 서버 전송 포맷은 로케일과 무관하게 항상 "HH:mm" 24시간제다.
    'dnd_start': dndEnabled.value
        ? formatHm(dndStartHour.value, dndStartMinute.value)
        : null,
    'dnd_end':
        dndEnabled.value ? formatHm(dndEndHour.value, dndEndMinute.value) : null,
  };

  /// 서버가 준 "HH:mm"을 시·분 Rx에 반영. 값이 없거나 형식이 깨졌으면 기본값 유지.
  void _applyHhmm(String? hhmm, RxInt hourRx, RxInt minuteRx) {
    if (hhmm == null) return;
    final parts = hhmm.split(':');
    if (parts.length != 2) return;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return;
    hourRx.value = h;
    minuteRx.value = m;
  }

  /// 초기 설정과 현재 설정을 비교하여 변경 시에만 저장
  Future<void> _saveIfChanged() async {
    if (!_loaded || _initialSettings == null) return;
    final current = _currentPayload();

    // 변경 사항 없으면 스킵
    bool changed = false;
    for (final key in current.keys) {
      if (current[key] != _initialSettings![key]) {
        changed = true;
        break;
      }
    }
    if (!changed) return;

    final token = await _tokenDs.getDeviceToken();
    if (token == null) return;
    try {
      await _remoteDs.updateSettings(token, current);
    } catch (_) {
      // 네트워크 실패 시 무시
    }
  }

  /// 개별 스위치 상태에서 "전체 알림 받기" 자동 계산
  /// 긴급 알림은 항상 ON이므로 계산에서 제외
  void _syncAllSwitch() {
    allNotifications.value = warningEnabled.value && cautionEnabled.value && infoEnabled.value;
  }

  void toggleAll(bool value) {
    allNotifications.value = value;
    // 긴급 알림은 항상 ON — 전체 토글에서 제외
    warningEnabled.value = value;
    cautionEnabled.value = value;
    infoEnabled.value = value;
  }

  void toggleUrgent(bool v) {
    urgentEnabled.value = v;
    _syncAllSwitch();
  }

  void toggleWarning(bool v) {
    warningEnabled.value = v;
    _syncAllSwitch();
  }

  void toggleCaution(bool v) {
    cautionEnabled.value = v;
    _syncAllSwitch();
  }

  void toggleInfo(bool v) {
    infoEnabled.value = v;
    _syncAllSwitch();
  }

  void toggleDnd(bool v) {
    dndEnabled.value = v;
  }

  Future<void> showDndStartPicker() async {
    await _showTimePicker(dndStartHour, dndStartMinute);
  }

  Future<void> showDndEndPicker() async {
    await _showTimePicker(dndEndHour, dndEndMinute);
  }

  /// 시·분 Rx를 직접 받아 갱신한다 — 표시 문자열은 getter로 파생되므로
  /// 되파싱이 필요 없다.
  Future<void> _showTimePicker(RxInt hourRx, RxInt minuteRx) async {
    if (Platform.isIOS) {
      await _showCupertinoPicker(hourRx, minuteRx);
    } else {
      await _showMaterialPicker(hourRx, minuteRx);
    }
  }

  Future<void> _showMaterialPicker(RxInt hourRx, RxInt minuteRx) async {
    final picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay(hour: hourRx.value, minute: minuteRx.value),
      // 피커 자체도 화면 표기와 같은 제도를 쓰도록 맞춘다.
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx)
            .copyWith(alwaysUse24HourFormat: timeStyle == TimeStyle.h24),
        child: child!,
      ),
    );
    if (picked != null) {
      hourRx.value = picked.hour;
      minuteRx.value = picked.minute;
    }
  }

  Future<void> _showCupertinoPicker(RxInt hourRx, RxInt minuteRx) async {
    final initialDate = DateTime(2026, 1, 1, hourRx.value, minuteRx.value);
    var selectedTime = initialDate;

    await showCupertinoModalPopup(
      context: Get.context!,
      builder: (context) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text(
                      'common_cancel'.tr,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: Text(
                      'common_confirm'.tr,
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                    onPressed: () {
                      hourRx.value = selectedTime.hour;
                      minuteRx.value = selectedTime.minute;
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: timeStyle == TimeStyle.h24,
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
