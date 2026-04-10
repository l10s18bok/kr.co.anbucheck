import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/mixins/heartbeat_schedule_mixin.dart';
import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/core/utils/phone_utils.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/emergency_remote_datasource.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 대상자 홈 컨트롤러
/// PRD 7.4: 고유 코드 표시, heartbeat 상태, 시각 변경
class SubjectHomeController extends BaseController with HeartbeatScheduleMixin {
  final _inviteCode = ''.obs;
  String get inviteCode => _inviteCode.value;

  final _userId = 0.obs;
  int get userId => _userId.value;

  final _notificationGranted = false.obs;
  bool get notificationGranted => _notificationGranted.value;

  /// 보호자 연결 여부 (subscription_active를 proxy로 사용)
  final _guardianConnected = false.obs;
  bool get isGuardianConnected => _guardianConnected.value;

  /// 연결된 보호자 수
  final _guardianCount = 1.obs;
  int get guardianCount => _guardianCount.value;

  /// 마지막 heartbeat 전송 날짜 (yyyy-MM-dd), 없으면 빈 문자열
  final _lastHeartbeatDate = ''.obs;

  /// 마지막 heartbeat 실제 전송 시각 (HH:mm), 없으면 빈 문자열
  final _lastHeartbeatTime = ''.obs;

  /// 현재 예약시각에 대해 heartbeat 전송 완료 여부
  final _lastScheduledKey = ''.obs;
  bool get isReportedToday {
    if (_lastScheduledKey.value.isEmpty) return false;
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final key = '${today}_${heartbeatHour.value.toString().padLeft(2, '0')}:${heartbeatMinute.value.toString().padLeft(2, '0')}';
    return _lastScheduledKey.value == key;
  }

  /// 예정 시각이 현재 시각보다 미래인지 여부
  bool get isScheduleInFuture {
    final now = DateTime.now();
    final scheduled = DateTime(
        now.year, now.month, now.day, heartbeatHour.value, heartbeatMinute.value);
    return scheduled.isAfter(now);
  }

  /// 카드 상태 (reported / pending / waiting)
  /// - reported : 금일 보고 완료
  /// - pending  : 예정 시각 아직 안 됨 (미전송)
  /// - waiting  : 예정 시각 지났으나 미수신 (WorkManager 지연 등)
  String get checkCardState {
    if (isReportedToday) return 'reported';
    if (isScheduleInFuture) return 'pending';
    return 'waiting';
  }

  String get checkCardTitle {
    switch (checkCardState) {
      case 'reported':
        final date = _lastHeartbeatDate.value;
        if (date.isNotEmpty) {
          return '${'subject_home_check_title_last'.tr} : $date';
        }
        return 'subject_home_check_title_last'.tr;
      case 'pending':  return 'subject_home_check_title_scheduled'.tr;
      case 'waiting':  return 'subject_home_check_title_checking'.tr;
      default:         return 'subject_home_check_title_scheduled'.tr;
    }
  }

  String get checkCardBody {
    switch (checkCardState) {
      case 'reported':
        final raw = _lastHeartbeatTime.value.isNotEmpty
            ? _lastHeartbeatTime.value
            : heartbeatTime.value;
        final displayTime = formatTo12Hour(raw);
        return 'subject_home_check_body_reported'.trParams({'time': displayTime});
      case 'pending':  return 'subject_home_check_body_scheduled'.trParams({'time': heartbeatTime.value});
      case 'waiting':  return 'subject_home_check_body_waiting'.trParams({'time': heartbeatTime.value});
      default:         return 'subject_home_check_body_scheduled'.trParams({'time': heartbeatTime.value});
    }
  }

  // 배터리 상태
  final _battery = Battery();
  final _batteryLevel = 0.obs;
  int get batteryLevel => _batteryLevel.value;

  final _batteryState = BatteryState.unknown.obs;
  BatteryState get batteryState => _batteryState.value;

  bool get isBatteryLow =>
      _batteryLevel.value < 30 && _batteryState.value != BatteryState.charging;

  String get batteryStateText {
    if (_batteryState.value == BatteryState.charging) return 'subject_home_battery_charging'.tr;
    if (_batteryState.value == BatteryState.full) return 'subject_home_battery_full'.tr;
    if (_batteryLevel.value < 30) return 'subject_home_battery_low'.tr;
    return 'common_normal'.tr;
  }

  // 네트워크 상태
  final _connectivity = Connectivity();
  final _isConnected = false.obs;
  bool get isConnected => _isConnected.value;

  String get connectivityText => _isConnected.value ? 'common_connected'.tr : 'common_disconnected'.tr;

  final _tokenDs = TokenLocalDatasource();

  @override
  void onInit() {
    super.onInit();
    _loadStatus();
    _checkNotificationPermission();
    _initBattery();
    _initConnectivity();
    // 앱 진입 시 ���약시각 경과 + 미전송이면 heartbeat 자동 전송
    _checkAndSendHeartbeat();
  }

  /// 앱 포그라운드 복귀 시 로컬 상태 + 서버 스케줄 재동기화 + heartbeat 자동 전송
  @override
  void onResumed() {
    super.onResumed();
    _reloadLocalState().then((_) {
      _syncScheduleFromServer();
      _checkAndSendHeartbeat();
    });
  }

  Future<void> _reloadLocalState() async {
    // 백그라운드 isolate에서 변경된 값을 메인 isolate에 반영
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    _lastHeartbeatDate.value = await _tokenDs.getLastHeartbeatDate() ?? '';
    _lastHeartbeatTime.value = await _tokenDs.getLastHeartbeatTime() ?? '';
    _lastScheduledKey.value = await _tokenDs.getLastScheduledKey() ?? '';
  }

  /// 예약시각 경과 + 오늘 미전송이면 heartbeat 자동 전송 + UI 갱신
  Future<void> _checkAndSendHeartbeat() async {
    if (isReportedToday) return;
    if (isScheduleInFuture) return;

    // 최초 설치 직후 (한 번도 전송한 적 없음) → 센서 기준값만 저장, 서버 전송 스킵
    final lastDate = await _tokenDs.getLastHeartbeatDate();
    if (lastDate == null || lastDate.isEmpty) {
      await HeartbeatService().saveSensorBaseline();
      return;
    }

    await HeartbeatService().execute(manual: false);
    await _reloadLocalState();
  }

  /// FCM heartbeat_trigger 수신 후 UI 갱신용 (FcmService에서 호출)
  Future<void> reloadHeartbeatState() => _reloadLocalState();

  Future<void> _loadStatus() async {
    _inviteCode.value = await _tokenDs.getInviteCode() ?? '';
    _userId.value = await _tokenDs.getUserId() ?? 0;
    _lastHeartbeatDate.value = await _tokenDs.getLastHeartbeatDate() ?? '';
    _lastHeartbeatTime.value = await _tokenDs.getLastHeartbeatTime() ?? '';
    _lastScheduledKey.value = await _tokenDs.getLastScheduledKey() ?? '';

    _guardianConnected.value = await _tokenDs.getSubscriptionActive();
    // 로컬 저장값으로 먼저 표시 후 서버에서 최신 스케줄 동기화
    await loadScheduleFromLocal();
    await _syncScheduleFromServer();
  }

  /// 서버에서 heartbeat 스케줄 조회 후 로컬과 다를 때만 재예약
  Future<void> _syncScheduleFromServer() async {
    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceToken == null) return;
    try {
      final data = await DeviceRemoteDatasource().getMyDevice(deviceToken);
      final hour = data['heartbeat_hour'] as int? ?? 9;
      final minute = data['heartbeat_minute'] as int? ?? 30;
      final subscriptionActive = data['subscription_active'] as bool? ?? true;
      await _tokenDs.saveSubscriptionActive(subscriptionActive);
      _guardianConnected.value = subscriptionActive;
      _guardianCount.value = data['guardian_count'] as int? ?? 0;

      // 로컬 저장값과 동일하면 재예약 스킵
      final (localH, localM) = await _tokenDs.getHeartbeatSchedule();
      if (localH == hour && localM == minute) {
        applySchedule(hour, minute);
        return;
      }

      await _tokenDs.saveHeartbeatSchedule(hour, minute);
      applySchedule(hour, minute);
      // 서버 기준 시각으로 WorkManager 및 로컬 안전망 알림 재예약
      await HeartbeatWorkerService.schedule(hour, minute);
      await LocalAlarmService.schedule(hour, minute);
    } catch (_) {
      // 실패 시 로컬 저장값 유지
    }
  }

  /// 알림 권한 상태 확인
  Future<void> _checkNotificationPermission() async {
    _notificationGranted.value =
        await Permission.notification.status.isGranted;
  }

  /// 배터리 상태 초기화 및 실시간 감시
  Future<void> _initBattery() async {
    _batteryLevel.value = await _battery.batteryLevel;
    _batteryState.value = await _battery.batteryState;

    _battery.onBatteryStateChanged.listen((state) async {
      _batteryState.value = state;
      _batteryLevel.value = await _battery.batteryLevel;
    });
  }

  /// 네트워크 연결 상태 초기화 및 실시간 감시
  Future<void> _initConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectivity(result);
    _connectivity.onConnectivityChanged.listen(_updateConnectivity);
  }

  void _updateConnectivity(List<ConnectivityResult> results) {
    final wasConnected = _isConnected.value;
    _isConnected.value = results.any((r) => r != ConnectivityResult.none);

    // 오프라인 → 온라인 복구 시 보류 heartbeat 재전송
    if (!wasConnected && _isConnected.value) {
      _sendPendingHeartbeat();
    }
  }

  Future<void> _sendPendingHeartbeat() async {
    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceToken == null) return;
    await HeartbeatService().sendPending(deviceToken);
    await _reloadLocalState();
  }

  /// 고유 코드 클립보드 복사
  void copyInviteCode() {
    Clipboard.setData(ClipboardData(text: _inviteCode.value));
    Get.rawSnackbar(
      message: 'subject_home_code_copied'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// 고유 코드 SNS 공유
  void shareInviteCode() {
    SharePlus.instance.share(
      ShareParams(
        text: 'subject_home_share_text'.trParams({'code': _inviteCode.value}),
        subject: 'subject_home_share_subject'.tr,
      ),
    );
  }

  /// 지금 바로 안전 보고하기 버튼 전송 중 상태
  final _isReporting = false.obs;
  bool get isReporting => _isReporting.value;

  /// 안전 보고 버튼: heartbeat 즉시 전송 후 전화 다이얼러 열기
  Future<void> reportNow() async {
    if (_isReporting.value) return;
    _isReporting.value = true;
    try {
      await HeartbeatService().execute(manual: true);
      // 전송 결과(성공/큐 저장) 반영하여 카드 상태 갱신
      await _reloadLocalState();
    } finally {
      _isReporting.value = false;
    }
    await PhoneUtils.pickContactAndCall();
  }

  /// 연락처 선택 → 전화 걸기 (안전 보고)
  Future<void> openPhoneDialer() async {
    await PhoneUtils.pickContactAndCall();
  }

  /// 긴급 도움 요청 전송 중 상태
  final _isSendingEmergency = false.obs;
  bool get isSendingEmergency => _isSendingEmergency.value;

  /// 긴급 도움 요청: urgent alert 즉시 생성 + 보호자 전원에게 긴급 Push 발송
  Future<void> sendEmergency() async {
    if (_isSendingEmergency.value) return;
    _isSendingEmergency.value = true;
    try {
      final deviceToken = await _tokenDs.getDeviceToken();
      final deviceId = await _tokenDs.getDeviceId();
      if (deviceToken == null || deviceId == null) return;
      await EmergencyRemoteDatasource(deviceToken).send(deviceId);
      Get.rawSnackbar(
        message: 'subject_home_emergency_sent'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.rawSnackbar(
        message: 'subject_home_emergency_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isSendingEmergency.value = false;
    }
  }

  // ── 앱 버전 ────────────────────────────────────────
  final appVersion = ''.obs;

  Future<void> loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = '${info.version} (${info.buildNumber})';
  }

  // ── 탈퇴 ──────────────────────────────────────────
  Future<void> deleteAccount() async {
    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceToken != null) {
      try {
        await ApiClientFactory.instance.delete(
          ApiEndpoints.usersMe,
          headers: {'Authorization': 'Bearer $deviceToken'},
        );
      } catch (_) {}
    }
    await HeartbeatWorkerService.cancel();
    await LocalAlarmService.cancel();
    await _tokenDs.clear();
    Get.offAllNamed(AppRoutes.modeSelect);
  }
}
