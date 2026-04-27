import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/core/utils/extensions.dart';
import 'package:anbucheck/app/core/mixins/heartbeat_schedule_mixin.dart';
import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/data/datasources/local/heartbeat_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/heartbeat_lock_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/emergency_remote_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/user_remote_datasource.dart';
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

  /// 위치 권한(긴급 요청 첨부용) 거부 여부 — 긴급 버튼 아래 경고 텍스트가 구독
  final locationPermissionDenied = false.obs;

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

  /// 오늘 heartbeat 보고 완료 여부
  bool get isReportedToday {
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

  /// 오늘 예약시각이 현재로부터 [_missedRecoveryWindow]보다 오래 전에 지났는지.
  /// 자동 복구 전송은 "방금 놓친 heartbeat"에 한정한다. 새벽 예약 실수나
  /// 장기간 앱 미실행처럼 10h+ 전에 지난 예약을 지금 전송하는 것은 실제 안부
  /// 신호로서 의미가 약하고, 서버 기준 이미 미수신 경고가 발송됐을 가능성이 높아
  /// 오히려 혼란을 준다. 서버 경고 발송 시점이 예약시각 +2h이므로 3h로 설정.
  static const _missedRecoveryWindow = Duration(hours: 3);

  bool get isScheduleTooOld {
    final now = DateTime.now();
    final scheduled = DateTime(
        now.year, now.month, now.day, heartbeatHour.value, heartbeatMinute.value);
    if (scheduled.isAfter(now)) return false;
    return now.difference(scheduled) > _missedRecoveryWindow;
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
    HeartbeatService.warmUpStepSubscription();
    _loadStatus().then((_) => _checkAndSendHeartbeat());
    _checkNotificationPermission();
    refreshLocationPermissionStatus();
    _initBattery();
    _initConnectivity();
    _checkHibernationSetting();
  }

  static const _hibernationChannel = MethodChannel('anbucheck/hibernation');

  /// Android "사용하지 않는 앱 일시 정지" 안내
  /// 앱이 auto-revoke whitelist에 등록되어 있으면(=사용자가 토글 OFF) 안내 생략.
  /// 등록되지 않은 경우에만 앱 실행 때마다 계속 안내한다.
  Future<void> _checkHibernationSetting() async {
    if (!Platform.isAndroid) return;

    try {
      final whitelisted = await _hibernationChannel
          .invokeMethod<bool>('isAutoRevokeWhitelisted');
      if (whitelisted == true) return;
    } catch (_) {
      return;
    }

    await Get.dialog<void>(
      AlertDialog(
        title: _buildHibernationTitle(),
        content: Text('permission_hibernation_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('common_later'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: Text('permission_hibernation_go_to_settings'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// 제목에서 "사용하지 않는 앱 일시 정지"(로케일별 highlight 문구) 부분만 강조 색상 적용
  Widget _buildHibernationTitle() {
    final title = 'permission_hibernation_title'.tr;
    final highlight = 'permission_hibernation_highlight'.tr;
    final idx = title.indexOf(highlight);
    if (idx < 0) return Text(title);
    const highlightStyle = TextStyle(
      color: Color(0xFFB71C1C),
      fontWeight: FontWeight.w700,
    );
    return Text.rich(
      TextSpan(
        children: [
          if (idx > 0) TextSpan(text: title.substring(0, idx)),
          TextSpan(text: highlight, style: highlightStyle),
          if (idx + highlight.length < title.length)
            TextSpan(text: title.substring(idx + highlight.length)),
        ],
      ),
    );
  }

  /// 앱 포그라운드 복귀 시 heartbeat 상태 갱신 + 자동 전송
  @override
  void onResumed() {
    super.onResumed();
    // 앱 설정에서 위치 권한을 허용하고 복귀한 경우 즉시 경고 위젯 숨기기
    refreshLocationPermissionStatus();
    // SharedPreferences reload → 스케줄 로드 → heartbeat 상태 갱신 순서 보장
    loadScheduleFromLocal()
        .then((_) => _reloadHeartbeatState())
        .then((_) => _checkAndSendHeartbeat());
  }

  Future<void> _reloadHeartbeatState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    _lastHeartbeatDate.value = await _tokenDs.getLastHeartbeatDate() ?? '';
    _lastHeartbeatTime.value = await _tokenDs.getLastHeartbeatTime() ?? '';
  }

  /// 예약시각 경과 + 오늘 미전송이면 heartbeat 자동 전송
  /// iOS G+S는 시각 조건 없이 "당일 미전송"만 확인
  Future<void> _checkAndSendHeartbeat() async {
    if (isReportedToday) return;
    if (Platform.isAndroid && isScheduleInFuture) return;
    if (Platform.isAndroid && isScheduleTooOld) return;
    await _clearStaleScheduledKey();
    // 포그라운드 진입은 화면을 켜고 잠금을 풀어 앱을 연 결과이므로
    // interactive=true가 확정 증거 — 명시 전달.
    await HeartbeatService().execute(manual: false, isInteractiveAtTrigger: true);
    await _reloadHeartbeatState();
  }

  /// WorkManager Worker가 lastScheduledKey를 선점 save한 뒤 Samsung OneUI
  /// Doze/OEM 절전으로 중도 종료되면, lastHeartbeatDate는 비어있고
  /// lastScheduledKey만 남아 2차 안전망(앱 복귀 자동 전송)이 dedup 가드에
  /// 막혀 영구히 차단된다. 포그라운드 진입 시 "오늘 미전송인데 오늘자 키가
  /// 박혀 있는" stale 상태를 감지해 정리한다.
  Future<void> _clearStaleScheduledKey() async {
    final lastKey = await _tokenDs.getLastScheduledKey();
    if (lastKey == null || lastKey.isEmpty) return;
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (lastKey.startsWith(today)) {
      debugPrint('[SubjectHome] stale lastScheduledKey 정리 ($lastKey)');
      await _tokenDs.clearLastScheduledKey();
    }
  }

  /// 오늘의 안부 확인 메시지 로컬 알림 탭으로 이미 스택에 있는 경우 FcmService에서 호출
  Future<void> refreshAndSend() async {
    await loadScheduleFromLocal();
    await _reloadHeartbeatState();
    await _checkAndSendHeartbeat();
  }

  /// Pull-to-refresh: 서버 스케줄/구독/보호자 수 재동기화 + heartbeat 상태 갱신
  Future<void> pullToRefresh() async {
    await _loadStatus();
    await _checkAndSendHeartbeat();
  }

  Future<void> _loadStatus() async {
    // Worker isolate가 방금 저장한 lastHeartbeatDate/ScheduledKey가 메인 isolate
    // 캐시에 반영되지 않은 상태로 _checkAndSendHeartbeat가 돌면 isReportedToday
    // 판정이 stale해져 간헐적 중복 전송이 발생한다. 읽기 전에 prefs를 디스크와
    // 동기화해 race를 차단한다.
    await getReloadedPrefs();
    _inviteCode.value = await _tokenDs.getInviteCode() ?? '';
    _userId.value = await _tokenDs.getUserId() ?? 0;
    _lastHeartbeatDate.value = await _tokenDs.getLastHeartbeatDate() ?? '';
    _lastHeartbeatTime.value = await _tokenDs.getLastHeartbeatTime() ?? '';

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
      final hour = data['heartbeat_hour'] as int? ?? 18;
      final minute = data['heartbeat_minute'] as int? ?? 0;
      final subscriptionActive = data['subscription_active'] as bool? ?? true;
      await _tokenDs.saveSubscriptionActive(subscriptionActive);
      _guardianConnected.value = subscriptionActive;
      _guardianCount.value = data['guardian_count'] as int? ?? 0;

      await _tokenDs.saveHeartbeatSchedule(hour, minute);
      applySchedule(hour, minute);
      if (Platform.isAndroid) {
        await HeartbeatWorkerService.schedule(hour, minute);
      }
      // LocalAlarm 재예약은 HeartbeatService가 전송 성공/실패 시 전담 — 여기서는 중복 호출 금지
    } catch (_) {
      // 실패 시 로컬 저장값 유지
    }
  }

  /// 알림 권한 상태 확인
  Future<void> _checkNotificationPermission() async {
    _notificationGranted.value =
        await Permission.notification.status.isGranted;
  }

  /// 위치 권한 상태 확인 — 긴급 버튼 아래 경고 텍스트가 구독
  Future<void> refreshLocationPermissionStatus() async {
    try {
      final status = await Permission.locationWhenInUse.status;
      locationPermissionDenied.value = !status.isGranted;
    } catch (_) {
      // 권한 체크 실패 시 경고를 띄우지 않는다
    }
  }

  /// 경고 텍스트 탭 시 위치 권한 재요청
  /// 일반 거부면 재요청, 영구 거부면 설정 이동 다이얼로그
  Future<void> requestLocationPermissionAgain() async {
    try {
      final status = await Permission.locationWhenInUse.status;
      if (status.isPermanentlyDenied || status.isRestricted) {
        final goToSettings = await Get.dialog<bool>(
          AlertDialog(
            title: Text('location_permission_settings_title'.tr,
                style: AppTextTheme.headlineSmall(fw: FontWeight.w700, color: const Color(0xFF1A1C1C))),
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
      } else {
        await Permission.locationWhenInUse.request();
      }
    } finally {
      await refreshLocationPermissionStatus();
    }
  }

  /// 배터리 상태 초기화 및 실시간 감시
  Future<void> _initBattery() async {
    try {
      _batteryLevel.value = await _battery.batteryLevel;
      _batteryState.value = await _battery.batteryState;
    } catch (_) {
      // 시뮬레이터/에뮬레이터 등 배터리 정보 미제공 환경 대응
    }

    _battery.onBatteryStateChanged.listen((state) async {
      _batteryState.value = state;
      try {
        _batteryLevel.value = await _battery.batteryLevel;
      } catch (_) {}
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
    await _reloadHeartbeatState();
  }

  /// 고유 코드 클립보드 복사
  void copyInviteCode() {
    Clipboard.setData(ClipboardData(text: _inviteCode.value));
    AppSnackbar.message('subject_home_code_copied'.tr);
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
  /// 하루 1회 제한 — 동일 날짜 재시도 시 안내 메시지 표시 후 차단
  Future<void> reportNow() async {
    if (_isReporting.value) return;

    final today = formatYmd(DateTime.now());
    final lastManualDate = await _tokenDs.getLastManualReportDate();
    if (lastManualDate == today) {
      AppSnackbar.message('subject_home_manual_report_limit_reached'.tr);
      return;
    }

    _isReporting.value = true;
    try {
      await HeartbeatService().execute(manual: true, isInteractiveAtTrigger: true);
      await _tokenDs.saveLastManualReportDate(today);
      await _reloadHeartbeatState();
      AppSnackbar.message('subject_home_manual_report_sent'.tr);
    } finally {
      _isReporting.value = false;
    }
  }

  /// 긴급 도움 요청 전송 중 상태
  final _isSendingEmergency = false.obs;
  bool get isSendingEmergency => _isSendingEmergency.value;

  /// 긴급 도움 요청: urgent alert 즉시 생성 + 보호자 전원에게 긴급 Push 발송
  /// 위치는 사용자 동의 기반으로 1회 수집하여 첨부하되, 권한 거부/GPS 실패/타임아웃
  /// 어떤 경우에도 긴급 API 호출 자체는 반드시 실행된다.
  Future<void> sendEmergency() async {
    if (_isSendingEmergency.value) return;
    _isSendingEmergency.value = true;
    try {
      final deviceToken = await _tokenDs.getDeviceToken();
      final deviceId = await _tokenDs.getDeviceId();
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
      _isSendingEmergency.value = false;
    }
  }


  // ── 앱 버전 ────────────────────────────────────────
  final appVersion = ''.obs;

  Future<void> loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = '${info.version} (${info.buildNumber})';
  }

  // ── S → G+S 전환 ──────────────────────────────────
  /// 대상자 모드 사용자가 보호자 기능을 추가로 활성화.
  /// 서버 role을 guardian으로 전환 + 3개월 무료 체험 구독 생성.
  /// invite_code와 heartbeat 예약은 그대로 유지되므로 기존 S 기능은 끊김 없이
  /// 지속되고, 이후엔 기존 G+S 사용자와 동일한 경로로 동작한다.
  Future<void> switchToGuardian() async {
    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceToken == null) return;
    try {
      final result = await UserRemoteDatasource().switchToGuardian(deviceToken);
      await _tokenDs.saveUserRole('guardian');
      await _tokenDs.saveIsAlsoSubject(true);
      final sub = result['subscription'];
      if (sub is Map && sub['is_active'] == true) {
        await _tokenDs.saveSubscriptionActive(true);
      }
      Get.offAllNamed(AppRoutes.guardianDashboard);
    } catch (e) {
      AppSnackbar.show('common_error'.tr, 's_to_gs_switch_failed'.tr,
          position: SnackPosition.TOP);
    }
  }

  // ── 탈퇴 ──────────────────────────────────────────
  /// 로컬 DB 전반을 클리어해 재가입 시 이전 계정 잔존 데이터가 새 계정에
  /// 오염을 일으키지 않도록 한다 (걸음수 delta 왜곡, pending heartbeat 오전송 등).
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
    if (Platform.isAndroid) {
      await HeartbeatWorkerService.cancel();
    }
    await LocalAlarmService.cancel();
    await _tokenDs.clear();
    await HeartbeatLocalDatasource().clearPending();
    await HeartbeatLockDatasource().clearAll();

    Get.offAllNamed(AppRoutes.modeSelect);
  }
}
