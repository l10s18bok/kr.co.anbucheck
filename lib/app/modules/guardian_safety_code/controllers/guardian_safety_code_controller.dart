import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/mixins/heartbeat_schedule_mixin.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/core/utils/phone_utils.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/emergency_remote_datasource.dart';
import 'package:anbucheck/app/modules/guardian_dashboard/controllers/guardian_dashboard_controller.dart';

/// 보호자 G+S 모드 안전코드 화면 컨트롤러
///
/// UI 전용 — invite_code 표시, heartbeat 스케줄/시각 변경, 수동 보고, 긴급 요청만 담당.
/// heartbeat 자동 재전송(미전송 체크)은 [GuardianDashboardController]가 단독 소유하며,
/// 이 컨트롤러는 보고 상태 표시를 Dashboard의 Rx에서 직접 구독한다.
class GuardianSafetyCodeController extends BaseController with HeartbeatScheduleMixin {
  final _inviteCode = ''.obs;
  String get inviteCode => _inviteCode.value;

  final _guardianConnected = false.obs;
  bool get isGuardianConnected => _guardianConnected.value;

  final _guardianCount = 0.obs;
  int get guardianCount => _guardianCount.value;

  /// Dashboard 컨트롤러는 Dashboard/Settings 바인딩에서 permanent:true로 등록되어 있어
  /// 안전코드 페이지 진입 시점에는 반드시 존재한다.
  GuardianDashboardController get _dashboard =>
      Get.find<GuardianDashboardController>();

  bool get isReportedToday => _dashboard.isReportedToday;

  bool get isScheduleInFuture {
    final now = DateTime.now();
    final scheduled = DateTime(
        now.year, now.month, now.day, heartbeatHour.value, heartbeatMinute.value);
    return scheduled.isAfter(now);
  }

  String get checkCardState {
    if (isReportedToday) return 'reported';
    if (isScheduleInFuture) return 'pending';
    return 'waiting';
  }

  String get checkCardTitle {
    switch (checkCardState) {
      case 'reported':
        final date = _dashboard.lastHeartbeatDate;
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
        final raw = _dashboard.lastHeartbeatTime.isNotEmpty
            ? _dashboard.lastHeartbeatTime
            : heartbeatTime.value;
        final displayTime = formatTo12Hour(raw);
        return 'subject_home_check_body_reported'.trParams({'time': displayTime});
      case 'pending':
        return 'subject_home_check_body_scheduled'.trParams({'time': heartbeatTime.value});
      case 'waiting':
        return 'subject_home_check_body_waiting'.trParams({'time': heartbeatTime.value});
      default:
        return 'subject_home_check_body_scheduled'.trParams({'time': heartbeatTime.value});
    }
  }

  final _tokenDs = TokenLocalDatasource();

  /// 설정 페이지에서 진입 시 전달받은 서버 데이터 (중복 API 호출 방지)
  Map<String, dynamic>? get _deviceData {
    final args = Get.arguments;
    if (args is Map && args['deviceData'] is Map) {
      return Map<String, dynamic>.from(args['deviceData'] as Map);
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    _loadStatus();
  }

  @override
  void onResumed() {
    super.onResumed();
    loadScheduleFromLocal();
  }

  Future<void> _loadStatus() async {
    await getReloadedPrefs();
    _inviteCode.value = await _tokenDs.getInviteCode() ?? '';
    _guardianConnected.value = await _tokenDs.getSubscriptionActive();
    await loadScheduleFromLocal();
    await _syncScheduleFromServer();
  }

  /// Pull-to-refresh: arguments 캐시 무시하고 서버에서 강제 동기화
  Future<void> pullToRefresh() async {
    await getReloadedPrefs();
    _inviteCode.value = await _tokenDs.getInviteCode() ?? '';
    _guardianConnected.value = await _tokenDs.getSubscriptionActive();
    await loadScheduleFromLocal();
    await _syncScheduleFromServer(forceRemote: true);
  }

  /// G+S 모드: 설정 페이지에서 이미 받은 데이터 사용 (중복 API 호출 방지)
  /// 오늘의 안부 확인 메시지 로컬 알림 탭 진입 등 캐시 없는 경우만 서버 호출
  Future<void> _syncScheduleFromServer({bool forceRemote = false}) async {
    final cached = forceRemote ? null : _deviceData;
    if (cached != null) {
      final hour = cached['heartbeat_hour'] as int? ?? 9;
      final minute = cached['heartbeat_minute'] as int? ?? 30;
      final subscriptionActive = cached['subscription_active'] as bool? ?? true;
      _guardianConnected.value = subscriptionActive;
      _guardianCount.value = cached['guardian_count'] as int? ?? 0;
      applySchedule(hour, minute);
      return;
    }

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

      await _tokenDs.saveHeartbeatSchedule(hour, minute);
      applySchedule(hour, minute);
      if (GetPlatform.isAndroid) {
        await HeartbeatWorkerService.schedule(hour, minute);
      }
      // LocalAlarm 재예약은 HeartbeatService가 전송 성공/실패 시 전담 — 여기서는 중복 호출 금지
    } catch (_) {
      // 실패 시 로컬 저장값 유지
    }
  }

  void copyInviteCode() {
    Clipboard.setData(ClipboardData(text: _inviteCode.value));
    Get.rawSnackbar(
      message: 'subject_home_code_copied'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void shareInviteCode() {
    SharePlus.instance.share(
      ShareParams(
        text: 'subject_home_share_text'.trParams({'code': _inviteCode.value}),
        subject: 'subject_home_share_subject'.tr,
      ),
    );
  }

  final _isReporting = false.obs;
  bool get isReporting => _isReporting.value;

  /// 안전 보고 버튼: heartbeat 즉시 전송 후 전화 다이얼러 열기
  Future<void> reportNow() async {
    if (_isReporting.value) return;
    _isReporting.value = true;
    try {
      await HeartbeatService().execute(manual: true);
      // Dashboard Rx를 갱신해 카드 표시를 즉시 reported 상태로 전환
      await _dashboard.reloadHeartbeatState();
    } finally {
      _isReporting.value = false;
    }
    await PhoneUtils.pickContactAndCall();
  }

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
}
