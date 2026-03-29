import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/mixins/heartbeat_schedule_mixin.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
import 'package:anbucheck/app/core/utils/phone_utils.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';

/// 대상자 홈 컨트롤러
/// PRD 7.4: 고유 코드 표시, heartbeat 상태, 시각 변경
class SubjectHomeController extends BaseController with HeartbeatScheduleMixin {
  final _inviteCode = ''.obs;
  String get inviteCode => _inviteCode.value;

  final _userId = 0.obs;
  int get userId => _userId.value;

  final _notificationGranted = false.obs;
  bool get notificationGranted => _notificationGranted.value;

  /// 마지막 heartbeat 전송 날짜 (yyyy-MM-dd), 없으면 빈 문자열
  final _lastHeartbeatDate = ''.obs;

  /// 마지막 heartbeat 실제 전송 시각 (HH:mm), 없으면 빈 문자열
  final _lastHeartbeatTime = ''.obs;

  /// 금일 heartbeat 보고 완료 여부
  bool get isReportedToday {
    if (_lastHeartbeatDate.value.isEmpty) return false;
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _lastHeartbeatDate.value == today;
  }

  /// 예정 시각이 현재 시각보다 미래인지 여부
  bool get isScheduleInFuture {
    final now = DateTime.now();
    final scheduled = DateTime(
        now.year, now.month, now.day, heartbeatHour.value, heartbeatMinute.value);
    return scheduled.isAfter(now);
  }

  /// 카드 상태 (reported / pending / waiting)
  /// - reported : 금일 보고 완료 + 예정 시각 지남
  /// - pending  : 예정 시각 아직 안 됨
  /// - waiting  : 예정 시각 지났으나 미수신 (WorkManager 지연 등)
  String get checkCardState {
    if (isReportedToday && !isScheduleInFuture) return 'reported';
    if (isScheduleInFuture) return 'pending';
    return 'waiting';
  }

  String get checkCardTitle {
    switch (checkCardState) {
      case 'reported': return '마지막 안부 확인';
      case 'pending':  return '안부보고 예정시각';
      case 'waiting':  return '안부 확인 중';
      default:         return '안부보고 예정시각';
    }
  }

  String get checkCardBody {
    switch (checkCardState) {
      case 'reported':
        final raw = _lastHeartbeatTime.value.isNotEmpty
            ? _lastHeartbeatTime.value
            : heartbeatTime.value;
        final displayTime = formatTo12Hour(raw);
        return '$displayTime 정상 보고됨';
      case 'pending':  return '${heartbeatTime.value} 보고 예정';
      case 'waiting':  return '${heartbeatTime.value} 보고 대기 중';
      default:         return '${heartbeatTime.value} 보고 예정';
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
    if (_batteryState.value == BatteryState.charging) return '충전 중';
    if (_batteryState.value == BatteryState.full) return '완충';
    if (_batteryLevel.value < 30) return '충전 필요';
    return '정상';
  }

  // 네트워크 상태
  final _connectivity = Connectivity();
  final _isConnected = false.obs;
  bool get isConnected => _isConnected.value;

  String get connectivityText => _isConnected.value ? '연결됨' : '연결 없음';

  final _tokenDs = TokenLocalDatasource();

  @override
  void onInit() {
    super.onInit();
    _loadStatus();
    _checkNotificationPermission();
    _initBattery();
    _initConnectivity();
  }

  /// 앱 포그라운드 복귀 시 로컬 상태 + 서버 스케줄 재동기화
  @override
  void onResumed() {
    super.onResumed();
    _reloadLocalState();
    _syncScheduleFromServer();
  }

  Future<void> _reloadLocalState() async {
    _lastHeartbeatDate.value = await _tokenDs.getLastHeartbeatDate() ?? '';
    _lastHeartbeatTime.value = await _tokenDs.getLastHeartbeatTime() ?? '';
  }

  /// FCM heartbeat_trigger 수신 후 UI 갱신용 (FcmService에서 호출)
  Future<void> reloadHeartbeatState() => _reloadLocalState();

  Future<void> _loadStatus() async {
    _inviteCode.value = await _tokenDs.getInviteCode() ?? '';
    _userId.value = await _tokenDs.getUserId() ?? 0;
    _lastHeartbeatDate.value = await _tokenDs.getLastHeartbeatDate() ?? '';
    _lastHeartbeatTime.value = await _tokenDs.getLastHeartbeatTime() ?? '';

    // 로컬 저장값으로 먼저 표시 후 서버에서 최신 스케줄 동기화
    await loadScheduleFromLocal();
    await _syncScheduleFromServer();
  }

  /// 서버에서 heartbeat 스케줄 조회 후 로컬 동기화
  Future<void> _syncScheduleFromServer() async {
    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceToken == null) return;
    try {
      final data = await DeviceRemoteDatasource().getMyDevice(deviceToken);
      final hour = data['heartbeat_hour'] as int? ?? 9;
      final minute = data['heartbeat_minute'] as int? ?? 30;
      await _tokenDs.saveHeartbeatSchedule(hour, minute);
      applySchedule(hour, minute);
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
  }

  /// 고유 코드 클립보드 복사
  void copyInviteCode() {
    Clipboard.setData(ClipboardData(text: _inviteCode.value));
    Get.snackbar('', 'subject_home_code_copied'.tr,
        snackPosition: SnackPosition.BOTTOM);
  }

  /// 고유 코드 SNS 공유
  void shareInviteCode() {
    SharePlus.instance.share(
      ShareParams(
        text: '안부(Anbu) 앱에서 제 안부를 확인해 주세요!\n초대 코드: ${_inviteCode.value}',
        subject: '안부 앱 초대 코드',
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
}
