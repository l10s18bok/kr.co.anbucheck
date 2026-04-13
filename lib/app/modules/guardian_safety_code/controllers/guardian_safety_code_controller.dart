import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/mixins/heartbeat_schedule_mixin.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/emergency_remote_datasource.dart';

/// 보호자 G+S 모드 안전코드 화면 컨트롤러
///
/// 보호자가 대상자 역할을 겸할 때(G+S) 전용 화면. SubjectHome과 UI 요소는 비슷하지만
/// Drawer·탈퇴·모드 선택 복귀 등 대상자 전용 기능은 제외된다.
/// iOS 데드맨 알림 탭 진입 시 onInit/onResumed에서 당일 미전송 heartbeat를 즉시 전송하고
/// 보고 카드(_lastHeartbeatDate/_lastHeartbeatTime)를 Obx로 갱신한다.
class GuardianSafetyCodeController extends BaseController with HeartbeatScheduleMixin {
  final _inviteCode = ''.obs;
  String get inviteCode => _inviteCode.value;

  final _guardianConnected = false.obs;
  bool get isGuardianConnected => _guardianConnected.value;

  final _guardianCount = 0.obs;
  int get guardianCount => _guardianCount.value;

  final _lastHeartbeatDate = ''.obs;
  final _lastHeartbeatTime = ''.obs;

  bool get isReportedToday {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _lastHeartbeatDate.value == today;
  }

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
        final date = _lastHeartbeatDate.value;
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
        final raw = _lastHeartbeatTime.value.isNotEmpty
            ? _lastHeartbeatTime.value
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
    _loadStatus().then((_) => _checkAndSendHeartbeat());
  }

  @override
  void onResumed() {
    super.onResumed();
    loadScheduleFromLocal()
        .then((_) => _reloadHeartbeatState())
        .then((_) => _checkAndSendHeartbeat());
  }

  /// 데드맨 알림 탭으로 이미 스택에 있는 경우 FcmService에서 호출
  Future<void> refreshAndSend() async {
    await loadScheduleFromLocal();
    await _reloadHeartbeatState();
    await _checkAndSendHeartbeat();
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
    await HeartbeatService().execute(manual: false);
    await _reloadHeartbeatState();
  }

  Future<void> _loadStatus() async {
    _inviteCode.value = await _tokenDs.getInviteCode() ?? '';
    _lastHeartbeatDate.value = await _tokenDs.getLastHeartbeatDate() ?? '';
    _lastHeartbeatTime.value = await _tokenDs.getLastHeartbeatTime() ?? '';
    _guardianConnected.value = await _tokenDs.getSubscriptionActive();
    await loadScheduleFromLocal();
    await _syncScheduleFromServer();
  }

  /// G+S 모드: 설정 페이지에서 이미 받은 데이터 사용 (중복 API 호출 방지)
  /// 데드맨 알림 탭 진입 등 캐시 없는 경우만 서버 호출
  Future<void> _syncScheduleFromServer() async {
    final cached = _deviceData;
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
      if (Platform.isAndroid) {
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
