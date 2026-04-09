import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/mixins/heartbeat_schedule_mixin.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/data/datasources/local/sensor_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/emergency_remote_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/user_remote_datasource.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 보호자 설정 컨트롤러
/// PRD: 프로필, 연결 관리, 구독, 알림 설정, 앱 정보
/// v2: G+S (보호자 겸 대상자) 기능 포함
class GuardianSettingsController extends BaseController
    with HeartbeatScheduleMixin {
  final _svc = Get.find<GuardianSubjectService>();
  final _tokenDs = TokenLocalDatasource();
  final _userDs = UserRemoteDatasource();

  /// Obx에서 직접 추적 가능하도록 서비스의 observable 노출
  RxList<SubjectItem> get subjects => _svc.subjects;
  RxInt get maxSubjects => _svc.maxSubjects;

  final appVersion = ''.obs;
  final osVersion = ''.obs;
  final isSubscriptionActive = true.obs;
  final subscriptionPlan = ''.obs; // free_trial, yearly, expired

  // ── G+S (보호자 겸 대상자) 상태 ──
  final isAlsoSubject = false.obs;
  final inviteCode = ''.obs;
  final guardianCount = 0.obs;
  final lastHeartbeatDate = ''.obs;
  final lastHeartbeatTime = ''.obs;
  final isReporting = false.obs;
  final isSendingEmergency = false.obs;
  final isEnabling = false.obs;

  /// 오늘 heartbeat 보고 완료 여부
  bool get isReportedToday {
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return lastHeartbeatDate.value == today;
  }

  /// 예약시각이 미래인지
  bool get isScheduleInFuture {
    final now = DateTime.now();
    final scheduled = DateTime(now.year, now.month, now.day,
        heartbeatHour.value, heartbeatMinute.value);
    return now.isBefore(scheduled);
  }

  /// 상태 카드 state: 'reported' / 'pending' / 'waiting'
  String get checkCardState {
    if (isReportedToday) return 'reported';
    if (isScheduleInFuture) return 'pending';
    return 'waiting';
  }

  String get checkCardTitle {
    switch (checkCardState) {
      case 'reported':
        final date = lastHeartbeatDate.value;
        if (date.isNotEmpty) {
          return '${'subject_home_check_title_last'.tr} : $date';
        }
        return 'subject_home_check_title_last'.tr;
      case 'pending':
        return 'subject_home_check_title_scheduled'.tr;
      default:
        return 'subject_home_check_title_checking'.tr;
    }
  }

  String get checkCardBody {
    switch (checkCardState) {
      case 'reported':
        final raw = lastHeartbeatTime.value.isNotEmpty
            ? lastHeartbeatTime.value
            : heartbeatTime.value;
        final displayTime = formatTo12Hour(raw);
        return 'subject_home_check_body_reported'.trParams({'time': displayTime});
      case 'pending':
        return 'subject_home_check_body_scheduled'.trParams({'time': heartbeatTime.value});
      default:
        return 'subject_home_check_body_waiting'.trParams({'time': heartbeatTime.value});
    }
  }

  @override
  void onInit() {
    super.onInit();
    _svc.load();
    _loadAppVersion();
    _loadOsVersion();
    _loadSubscription();
    _loadSubjectState();
  }

  /// 앱 포그라운드 복귀 시 heartbeat 상태 갱신 + 자동 전송
  @override
  void onResumed() {
    super.onResumed();
    if (!isAlsoSubject.value) return;
    _reloadHeartbeatState().then((_) => _checkAndSendHeartbeat());
  }

  Future<void> _reloadHeartbeatState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    lastHeartbeatDate.value = await _tokenDs.getLastHeartbeatDate() ?? '';
    lastHeartbeatTime.value = await _tokenDs.getLastHeartbeatTime() ?? '';
  }

  /// 예약시각 경과 + 오늘 미전송이면 heartbeat 자동 전송
  Future<void> _checkAndSendHeartbeat() async {
    if (isReportedToday) return;
    if (isScheduleInFuture) return;
    await HeartbeatService().execute(manual: false);
    await _reloadHeartbeatState();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = '${info.version} (${info.buildNumber})';
  }

  Future<void> _loadSubscription() async {
    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceToken == null) return;

    try {
      final deviceDs = DeviceRemoteDatasource();
      final data = await deviceDs.getMyDevice(deviceToken);
      final active = data['subscription_active'] as bool? ?? false;
      final plan = data['subscription_plan'] as String? ?? '';
      isSubscriptionActive.value = active;
      subscriptionPlan.value = plan;
      await _tokenDs.saveSubscriptionActive(active);

      // G+S 상태 서버 동기화 (양방향)
      final serverAlsoSubject = data['is_also_subject'] as bool? ?? false;
      final serverInviteCode = data['invite_code'] as String?;
      if (serverAlsoSubject && serverInviteCode != null) {
        isAlsoSubject.value = true;
        inviteCode.value = serverInviteCode;
        await _tokenDs.saveIsAlsoSubject(true);
        await _tokenDs.saveInviteCode(serverInviteCode);
        guardianCount.value = data['guardian_count'] as int? ?? 0;
      } else {
        // 서버에서 해제 상태 → 로컬도 동기화
        isAlsoSubject.value = false;
        inviteCode.value = '';
        guardianCount.value = 0;
        await _tokenDs.saveIsAlsoSubject(false);
      }
    } catch (_) {
      isSubscriptionActive.value = await _tokenDs.getSubscriptionActive();
    }
  }

  /// 로컬에서 G+S 상태 로드
  Future<void> _loadSubjectState() async {
    final also = await _tokenDs.getIsAlsoSubject();
    isAlsoSubject.value = also;

    if (also) {
      inviteCode.value = await _tokenDs.getInviteCode() ?? '';
      lastHeartbeatDate.value = await _tokenDs.getLastHeartbeatDate() ?? '';
      lastHeartbeatTime.value = await _tokenDs.getLastHeartbeatTime() ?? '';
      await loadScheduleFromLocal();
    }
  }

  Future<void> _loadOsVersion() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      osVersion.value = 'Android ${android.version.release}';
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      osVersion.value = 'iOS ${ios.systemVersion}';
    }
  }

  // ── G+S 활성화 ──

  Future<void> enableSubjectFeature() async {
    isEnabling.value = true;
    try {
      final deviceToken = await _tokenDs.getDeviceToken();
      if (deviceToken == null) return;
      final result = await _userDs.enableSubject(deviceToken);
      final code = result['invite_code'] as String;
      final hour = result['heartbeat_hour'] as int? ?? 9;
      final minute = result['heartbeat_minute'] as int? ?? 30;

      // 로컬 저장
      await _tokenDs.saveIsAlsoSubject(true);
      await _tokenDs.saveInviteCode(code);
      await _tokenDs.saveHeartbeatSchedule(hour, minute);
      isAlsoSubject.value = true;
      inviteCode.value = code;
      applySchedule(hour, minute);

      // Android: 신체 활동 권한 요청
      if (Platform.isAndroid) {
        await Permission.activityRecognition.request();
      }

      // WorkManager + 로컬 알림 등록
      await HeartbeatWorkerService.schedule(hour, minute);
      await LocalAlarmService.schedule(hour, minute);

      // 첫 heartbeat 즉시 전송
      try {
        await HeartbeatService().execute();
        // execute() 내부에서 로컬 저장하지만, 확실하게 동기화
        lastHeartbeatDate.value = await _tokenDs.getLastHeartbeatDate() ?? '';
        lastHeartbeatTime.value = await _tokenDs.getLastHeartbeatTime() ?? '';
      } catch (_) {}

      Get.snackbar('', 'gs_enabled_message'.tr,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.white,
          colorText: const Color(0xFF1a1c1c));
    } catch (e) {
      Get.snackbar('common_error'.tr, 'gs_enable_failed'.tr,
          snackPosition: SnackPosition.TOP);
    } finally {
      isEnabling.value = false;
    }
  }

  // ── G+S 해제 ──

  Future<void> disableSubjectFeature() async {
    try {
      final deviceToken = await _tokenDs.getDeviceToken();
      debugPrint('[G+S] disableSubjectFeature — deviceToken=${deviceToken != null ? "있음" : "NULL"}');
      if (deviceToken == null) return;
      debugPrint('[G+S] disable-subject API 호출 시작');
      await _userDs.disableSubject(deviceToken);
      debugPrint('[G+S] disable-subject API 호출 성공');

      // WorkManager/알림 취소
      await HeartbeatWorkerService.cancel();
      await LocalAlarmService.cancel();

      // 로컬 데이터 정리
      await _tokenDs.saveIsAlsoSubject(false);
      // 센서 로컬 데이터 제거 (saveSnapshot 키 초기화)
      await SensorLocalDatasource().saveSnapshot(
        accelX: 0, accelY: 0, accelZ: 0,
        gyroX: 0, gyroY: 0, gyroZ: 0,
      );
      await _tokenDs.saveLastHeartbeatDate('');
      await _tokenDs.saveLastHeartbeatTime('');

      isAlsoSubject.value = false;
      inviteCode.value = '';
      guardianCount.value = 0;

      Get.snackbar('', 'gs_disabled_message'.tr,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.white,
          colorText: const Color(0xFF1a1c1c));
    } catch (e) {
      debugPrint('[G+S] disableSubjectFeature 에러: $e');
      Get.snackbar('common_error'.tr, 'gs_disable_failed'.tr,
          snackPosition: SnackPosition.TOP);
    }
  }

  // ── 수동 heartbeat 전송 ──

  Future<void> reportNow() async {
    isReporting.value = true;
    try {
      await HeartbeatService().execute(manual: true);
      final now = DateTime.now();
      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      lastHeartbeatDate.value = today;
      lastHeartbeatTime.value = timeStr;
      Get.snackbar('', 'subject_home_report_success'.tr,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.white,
          colorText: const Color(0xFF1a1c1c));
    } catch (e) {
      Get.snackbar('common_error'.tr, 'subject_home_report_failed'.tr,
          snackPosition: SnackPosition.TOP);
    } finally {
      isReporting.value = false;
    }
  }

  // ── 긴급 도움 요청 ──

  Future<void> sendEmergency() async {
    isSendingEmergency.value = true;
    try {
      final deviceToken = await _tokenDs.getDeviceToken();
      final deviceId = await _tokenDs.getDeviceId();
      if (deviceToken == null || deviceId == null) return;
      await EmergencyRemoteDatasource(deviceToken).send(deviceId);
      Get.snackbar('', 'subject_home_emergency_sent'.tr,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          backgroundColor: const Color(0xFFFFEBEE),
          colorText: const Color(0xFFB71C1C));
    } catch (e) {
      Get.snackbar('common_error'.tr, 'subject_home_emergency_failed'.tr,
          snackPosition: SnackPosition.TOP);
    } finally {
      isSendingEmergency.value = false;
    }
  }

  // ── 초대 코드 복사/공유 ──

  void copyInviteCode() {
    if (inviteCode.value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: inviteCode.value));
    Get.snackbar('', 'subject_home_code_copied'.tr,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.white,
        colorText: const Color(0xFF1a1c1c));
  }

  void shareInviteCode() {
    if (inviteCode.value.isEmpty) return;
    SharePlus.instance.share(
      ShareParams(text: 'subject_home_share_message'.trParams({'code': inviteCode.value})),
    );
  }

  // ── 네비게이션 ──

  void goToConnectionManagement() {
    Get.toNamed(AppRoutes.guardianConnectionManagement);
  }

  void goToNotificationSettings() {
    Get.toNamed(AppRoutes.guardianNotificationSettings, arguments: 3);
  }
}
