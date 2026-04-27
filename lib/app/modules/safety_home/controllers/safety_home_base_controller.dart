import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/mixins/heartbeat_schedule_mixin.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/core/utils/extensions.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/emergency_remote_datasource.dart';
import 'package:anbucheck/app/modules/safety_home/controllers/safety_home_role.dart';

/// 안전 홈 페이지 공통 부모 컨트롤러 (abstract)
///
/// S 모드(`SubjectHomeController`)와 G+S 모드(`GuardianSafetyCodeController`)가 공유하는
/// invite_code 표시·heartbeat 스케줄·권한·배터리·네트워크·수동 보고·긴급 요청 로직을 담는다.
///
/// **책임 비대칭 (중요)**:
/// - S 자식은 `lastHeartbeatDate/Time`을 자기 Rx로 단독 소유
/// - G+S 자식은 `GuardianDashboardController`의 Rx에 위임 (Dashboard가 heartbeat
///   자동 재전송 단독 소유)
///
/// **Template Method 패턴 hook**:
/// - [onAfterLoad] — `onInit`의 `loadStatus()` 후 호출 (S=heartbeat 미전송 체크,
///   G+S=noop)
/// - [onResumedRoleSpecific] — `onResumed`의 스케줄 재로드 후 호출
/// - [onHeartbeatSent] — `reportNow` 성공 후 / 보류 큐 전송 후 상태 재로드 hook
abstract class SafetyHomeBaseController extends BaseController
    with HeartbeatScheduleMixin {
  /// 역할 — 자식이 final로 노출
  HomeRole get role;

  // ── 추상 hook (자식 구현) ──────────────────────────────────────────

  /// `onInit`에서 `loadStatus()` 완료 후 호출.
  /// S=heartbeat 미전송 체크, G+S=noop.
  @protected
  Future<void> onAfterLoad();

  /// `onResumed`에서 스케줄 로컬 재로드 후 호출.
  /// S=heartbeat 미전송 체크, G+S=noop (Dashboard가 단독 소유).
  @protected
  Future<void> onResumedRoleSpecific();

  /// 수동 보고/보류 큐 전송 성공 후 호출 — 상태 재로드 hook.
  /// S=자기 Rx 재로드, G+S=Dashboard.reloadHeartbeatState() 위임.
  /// 호출처에서 try/catch로 감싸 swallow되므로 throw해도 사용자 흐름은 막히지 않음.
  @protected
  Future<void> onHeartbeatSent();

  // ── heartbeat 보고 상태 (자식 구현) ───────────────────────────────────
  // ※ 반응성 주의: G+S 자식은 `Dashboard.lastHeartbeatDate` getter를 그대로 노출하며,
  //   getter 내부의 `.value` 접근이 Obx 의존성을 등록한다. **로컬 변수에 캐시하지 말 것.**
  String get lastHeartbeatDate;
  String get lastHeartbeatTime;
  bool get isReportedToday;

  // ── 공통 Rx ────────────────────────────────────────────────────────

  final _inviteCode = ''.obs;
  String get inviteCode => _inviteCode.value;

  final guardianConnected = false.obs;
  bool get isGuardianConnected => guardianConnected.value;

  final guardianCount = 0.obs;

  final notificationGranted = false.obs;
  final activityPermissionDenied = false.obs;
  final locationPermissionDenied = false.obs;

  final batteryLevel = 0.obs;
  final batteryState = BatteryState.unknown.obs;
  bool get isBatteryLow =>
      batteryLevel.value < 30 && batteryState.value != BatteryState.charging;

  String get batteryStateText {
    if (batteryState.value == BatteryState.charging) {
      return 'subject_home_battery_charging'.tr;
    }
    if (batteryState.value == BatteryState.full) {
      return 'subject_home_battery_full'.tr;
    }
    if (batteryLevel.value < 30) return 'subject_home_battery_low'.tr;
    return 'common_normal'.tr;
  }

  final isConnected = false.obs;
  String get connectivityText =>
      isConnected.value ? 'common_connected'.tr : 'common_disconnected'.tr;

  final isReporting = false.obs;
  final isSendingEmergency = false.obs;

  // ── 의존성 ─────────────────────────────────────────────────────────
  @protected
  final tokenDs = TokenLocalDatasource();
  final _battery = Battery();
  final _connectivity = Connectivity();

  /// arguments['deviceData'] 캐시 — Dashboard 진입 시 중복 API 호출 방지
  Map<String, dynamic>? get _deviceData {
    final args = Get.arguments;
    if (args is Map && args['deviceData'] is Map) {
      return Map<String, dynamic>.from(args['deviceData'] as Map);
    }
    return null;
  }

  // ── 라이프사이클 ─────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    HeartbeatService.warmUpStepSubscription();
    _checkNotificationPermission();
    refreshActivityPermissionStatus();
    refreshLocationPermissionStatus();
    _initBattery();
    _initConnectivity();
    _autoRequestSensorPermissionIOSIfNeeded();
    loadStatus().then((_) => onAfterLoad());
  }

  @override
  void onResumed() {
    super.onResumed();
    refreshActivityPermissionStatus();
    refreshLocationPermissionStatus();
    loadScheduleFromLocal().then((_) => onResumedRoleSpecific());
  }

  // ── 카드 상태 (공통 계산 getter) ─────────────────────────────────────

  bool get isScheduleInFuture {
    final now = DateTime.now();
    final scheduled = DateTime(now.year, now.month, now.day,
        heartbeatHour.value, heartbeatMinute.value);
    return scheduled.isAfter(now);
  }

  /// 'reported' | 'pending' | 'waiting'
  String get checkCardState {
    if (isReportedToday) return 'reported';
    if (isScheduleInFuture) return 'pending';
    return 'waiting';
  }

  String get checkCardTitle {
    switch (checkCardState) {
      case 'reported':
        final date = lastHeartbeatDate;
        if (date.isNotEmpty) {
          return '${'subject_home_check_title_last'.tr} : $date';
        }
        return 'subject_home_check_title_last'.tr;
      case 'pending':
        return 'subject_home_check_title_scheduled'.tr;
      case 'waiting':
        return 'subject_home_check_title_checking'.tr;
      default:
        return 'subject_home_check_title_scheduled'.tr;
    }
  }

  String get checkCardBody {
    switch (checkCardState) {
      case 'reported':
        final raw =
            lastHeartbeatTime.isNotEmpty ? lastHeartbeatTime : heartbeatTime.value;
        final displayTime = formatTo12Hour(raw);
        return 'subject_home_check_body_reported'
            .trParams({'time': displayTime});
      case 'pending':
        return 'subject_home_check_body_scheduled'
            .trParams({'time': heartbeatTime.value});
      case 'waiting':
        return 'subject_home_check_body_waiting'
            .trParams({'time': heartbeatTime.value});
      default:
        return 'subject_home_check_body_scheduled'
            .trParams({'time': heartbeatTime.value});
    }
  }

  // ── 권한 (공통) ─────────────────────────────────────────────────────

  Future<void> _checkNotificationPermission() async {
    notificationGranted.value =
        await Permission.notification.status.isGranted;
  }

  /// 걸음수 권한 상태 확인 — 진입/복귀 시 호출
  /// Android: ACTIVITY_RECOGNITION
  /// iOS: CMMotionActivityManager (Permission.sensors)
  Future<void> refreshActivityPermissionStatus() async {
    try {
      final status = Platform.isAndroid
          ? await Permission.activityRecognition.status
          : await Permission.sensors.status;
      activityPermissionDenied.value = !status.isGranted;
    } catch (_) {
      // 권한 체크 실패 시 경고를 띄우지 않는다 — 사용자 혼란 방지
    }
  }

  /// 경고 텍스트 탭 시 권한 재요청
  Future<void> requestActivityPermissionAgain() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.activityRecognition.status;
        if (status.isPermanentlyDenied) {
          await _showActivitySettingsDialog();
        } else {
          await Permission.activityRecognition.request();
        }
      } else if (Platform.isIOS) {
        final status = await Permission.sensors.status;
        if (status.isPermanentlyDenied || status.isRestricted) {
          await _showActivitySettingsDialog();
        } else if (status.isDenied) {
          await Permission.sensors.request();
        }
      }
    } finally {
      await refreshActivityPermissionStatus();
    }
  }

  Future<void> refreshLocationPermissionStatus() async {
    try {
      final status = await Permission.locationWhenInUse.status;
      locationPermissionDenied.value = !status.isGranted;
    } catch (_) {
      // 권한 체크 실패 시 경고를 띄우지 않는다
    }
  }

  Future<void> requestLocationPermissionAgain() async {
    try {
      final status = await Permission.locationWhenInUse.status;
      if (status.isPermanentlyDenied || status.isRestricted) {
        await _showLocationSettingsDialog();
      } else {
        await Permission.locationWhenInUse.request();
      }
    } finally {
      await refreshLocationPermissionStatus();
    }
  }

  /// iOS 자동 권한 요청 — 재설치/최초 진입 케이스에서 notDetermined 상태라면
  /// 첫 진입 시 시스템 팝업을 자동으로 띄운다.
  Future<void> _autoRequestSensorPermissionIOSIfNeeded() async {
    if (!Platform.isIOS) return;
    try {
      final status = await Permission.sensors.status;
      if (status.isDenied) {
        await Permission.sensors.request();
        await refreshActivityPermissionStatus();
      }
    } catch (_) {}
  }

  Future<void> _showActivitySettingsDialog() async {
    final goToSettings = await Get.dialog<bool>(
      AlertDialog(
        title: Text('gs_activity_permission_settings_title'.tr,
            style: AppTextTheme.headlineSmall(
                fw: FontWeight.w700, color: const Color(0xFF1A1C1C))),
        content: Text('gs_activity_permission_settings_body'.tr,
            style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948))),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('gs_activity_permission_settings_go'.tr),
          ),
        ],
      ),
    );
    if (goToSettings == true) {
      await openAppSettings();
    }
  }

  Future<void> _showLocationSettingsDialog() async {
    final goToSettings = await Get.dialog<bool>(
      AlertDialog(
        title: Text('location_permission_settings_title'.tr,
            style: AppTextTheme.headlineSmall(
                fw: FontWeight.w700, color: const Color(0xFF1A1C1C))),
        content: Text(
            Platform.isIOS
                ? 'location_permission_settings_body_ios'.tr
                : 'location_permission_settings_body_android'.tr,
            style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948))),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('gs_activity_permission_settings_go'.tr),
          ),
        ],
      ),
    );
    if (goToSettings == true) {
      await openAppSettings();
    }
  }

  // ── 배터리 ─────────────────────────────────────────────────────────

  Future<void> _initBattery() async {
    try {
      batteryLevel.value = await _battery.batteryLevel;
      batteryState.value = await _battery.batteryState;
    } catch (_) {
      // 시뮬레이터/에뮬레이터 등 배터리 정보 미제공 환경 대응
    }

    _battery.onBatteryStateChanged.listen((state) async {
      batteryState.value = state;
      try {
        batteryLevel.value = await _battery.batteryLevel;
      } catch (_) {}
    });
  }

  // ── 네트워크 ───────────────────────────────────────────────────────

  Future<void> _initConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectivity(result);
    _connectivity.onConnectivityChanged.listen(_updateConnectivity);
  }

  void _updateConnectivity(List<ConnectivityResult> results) {
    final wasConnected = isConnected.value;
    isConnected.value = results.any((r) => r != ConnectivityResult.none);

    if (!wasConnected && isConnected.value) {
      _sendPendingHeartbeat();
    }
  }

  Future<void> _sendPendingHeartbeat() async {
    final deviceToken = await tokenDs.getDeviceToken();
    if (deviceToken == null) return;
    await HeartbeatService().sendPending(deviceToken);
    try {
      await onHeartbeatSent();
    } catch (_) {
      // 상태 재로드 실패는 swallow — heartbeat 전송 자체는 성공
    }
  }

  // ── 상태 로드 ──────────────────────────────────────────────────────

  Future<void> loadStatus() async {
    await getReloadedPrefs();
    final cached = _deviceData;
    final cachedCode = cached?['invite_code'] as String?;
    if (cachedCode != null && cachedCode.isNotEmpty) {
      _inviteCode.value = cachedCode;
    } else {
      _inviteCode.value = await tokenDs.getInviteCode() ?? '';
    }
    guardianConnected.value = await tokenDs.getSubscriptionActive();
    await loadScheduleFromLocal();
    await _syncScheduleFromServer();
  }

  Future<void> pullToRefresh() async {
    await getReloadedPrefs();
    _inviteCode.value = await tokenDs.getInviteCode() ?? '';
    guardianConnected.value = await tokenDs.getSubscriptionActive();
    await loadScheduleFromLocal();
    await _syncScheduleFromServer(forceRemote: true);
  }

  /// 서버에서 heartbeat 스케줄 + 구독 상태 + 보호자 수 동기화
  /// G+S Dashboard 진입 시 deviceData arguments가 있으면 캐시 사용 (forceRemote=false 기본).
  Future<void> _syncScheduleFromServer({bool forceRemote = false}) async {
    final cached = forceRemote ? null : _deviceData;
    if (cached != null) {
      final hour = cached['heartbeat_hour'] as int? ?? 18;
      final minute = cached['heartbeat_minute'] as int? ?? 0;
      final subscriptionActive = cached['subscription_active'] as bool? ?? true;
      guardianConnected.value = subscriptionActive;
      guardianCount.value = cached['guardian_count'] as int? ?? 0;
      applySchedule(hour, minute);
      return;
    }

    final deviceToken = await tokenDs.getDeviceToken();
    if (deviceToken == null) return;
    try {
      final data = await DeviceRemoteDatasource().getMyDevice(deviceToken);
      final hour = data['heartbeat_hour'] as int? ?? 18;
      final minute = data['heartbeat_minute'] as int? ?? 0;
      final subscriptionActive = data['subscription_active'] as bool? ?? true;
      await tokenDs.saveSubscriptionActive(subscriptionActive);
      guardianConnected.value = subscriptionActive;
      guardianCount.value = data['guardian_count'] as int? ?? 0;

      await tokenDs.saveHeartbeatSchedule(hour, minute);
      applySchedule(hour, minute);
      if (Platform.isAndroid) {
        await HeartbeatWorkerService.schedule(hour, minute);
      }
      // LocalAlarm 재예약은 HeartbeatService가 전송 성공/실패 시 전담 — 여기서 중복 호출 금지
    } catch (_) {
      // 실패 시 로컬 저장값 유지
    }
  }

  // ── 액션 (공통) ─────────────────────────────────────────────────────

  void copyInviteCode() {
    Clipboard.setData(ClipboardData(text: _inviteCode.value));
    AppSnackbar.message('subject_home_code_copied'.tr);
  }

  void shareInviteCode() {
    SharePlus.instance.share(
      ShareParams(
        text: 'subject_home_share_text'.trParams({'code': _inviteCode.value}),
        subject: 'subject_home_share_subject'.tr,
      ),
    );
  }

  /// 안전 보고 버튼: heartbeat 즉시 전송 — Template Method
  /// 하루 1회 제한 — 동일 날짜 재시도 시 안내 메시지 표시 후 차단
  Future<void> reportNow() async {
    if (isReporting.value) return;

    final today = formatYmd(DateTime.now());
    final lastManualDate = await tokenDs.getLastManualReportDate();
    if (lastManualDate == today) {
      AppSnackbar.message('subject_home_manual_report_limit_reached'.tr);
      return;
    }

    isReporting.value = true;
    try {
      await HeartbeatService()
          .execute(manual: true, isInteractiveAtTrigger: true);
      await tokenDs.saveLastManualReportDate(today);
      // hook은 try/catch로 감싸 swallow — heartbeat 자체는 성공했으므로
      // reload 실패가 사용자에게 misleading "전송 실패" 안내를 만들지 않도록 한다.
      try {
        await onHeartbeatSent();
      } catch (_) {}
      AppSnackbar.message('subject_home_manual_report_sent'.tr);
    } finally {
      isReporting.value = false;
    }
  }

  /// 긴급 도움 요청: urgent alert 즉시 생성 + 보호자 전원에게 긴급 Push 발송.
  /// 위치는 사용자 동의 기반으로 1회 수집하여 첨부하되, 권한 거부/GPS 실패/타임아웃
  /// 어떤 경우에도 긴급 API 호출 자체는 반드시 실행된다.
  Future<void> sendEmergency() async {
    if (isSendingEmergency.value) return;
    isSendingEmergency.value = true;
    try {
      final deviceToken = await tokenDs.getDeviceToken();
      final deviceId = await tokenDs.getDeviceId();
      if (deviceToken == null || deviceId == null) return;

      final location = await captureEmergencyLocation();
      '[긴급] API 전송 직전 좌표: ${location == null ? "null" : "${location.latitude}, ${location.longitude} (acc=${location.accuracyMeters})"}'
          .printLog();

      await EmergencyRemoteDatasource(deviceToken)
          .send(deviceId, location: location);

      AppSnackbar.message(
        location != null
            ? 'emergency_sent_with_location'.tr
            : 'emergency_sent_without_location'.tr,
      );
    } catch (_) {
      AppSnackbar.message('subject_home_emergency_failed'.tr);
    } finally {
      isSendingEmergency.value = false;
    }
  }
}
