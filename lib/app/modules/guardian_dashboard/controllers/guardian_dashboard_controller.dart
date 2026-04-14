import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/mixins/heartbeat_schedule_mixin.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/data/datasources/local/sensor_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/user_remote_datasource.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 보호자 대시보드 컨트롤러
/// PRD 7.6: 대상자 목록, 상태 모니터링, 알림 레벨 표시
/// G+S(보호자 겸 대상자) 라이프사이클(활성화/해제/예약)만 이곳에서 담당하고,
/// heartbeat 자동 재전송 체크는 [GuardianSafetyCodeController]가 단독 소유한다.
class GuardianDashboardController extends BaseController
    with HeartbeatScheduleMixin {
  final subjects = <SubjectStatus>[].obs;

  /// 현재 카드 슬라이드 인덱스
  final currentCardIndex = 0.obs;

  /// 전화 후 앱 복귀 시 강조할 대상자 코드
  final highlightedInviteCode = RxnString();

  /// 구독 활성 여부
  final isSubscriptionActive = true.obs;

  // ── G+S (보호자 겸 대상자) 상태 ──
  final isAlsoSubject = false.obs;
  final inviteCode = ''.obs;
  final guardianCount = 0.obs;
  final isEnabling = false.obs;

  final _svc = Get.find<GuardianSubjectService>();
  final _tokenDs = TokenLocalDatasource();
  final _userDs = UserRemoteDatasource();

  @override
  void onInit() {
    super.onInit();
    // 서비스에 이미 캐시된 데이터가 있으면 즉시 반영 (타이밍 문제 방지)
    if (_svc.subjects.isNotEmpty) _mapSubjects();
    // subjects 데이터 변경 시 자동 반영 (FCM 수신 후 서비스 갱신 포함)
    ever(_svc.subjects, (_) => _mapSubjects());
    _loadSubjectsAndSubscription();
    _loadSubjectState();
    _scheduleHeartbeatIfGS();
  }

  /// 앱이 포그라운드로 복귀 — 대상자 목록 강제 갱신
  /// heartbeat 자동 재전송은 SafetyCode 컨트롤러가 전담 (race 방지)
  @override
  void onResumed() {
    super.onResumed();
    _loadSubjectsAndSubscription(force: true);
  }

  /// G+S(보호자 겸 대상자)인 경우 서버 스케줄 동기화 후 WorkManager + 로컬 안전망 예약
  Future<void> _scheduleHeartbeatIfGS() async {
    final isAls = await _tokenDs.getIsAlsoSubject();
    if (!isAls) return;
    // 배터리 최적화 없이도 정상 동작 확인됨 — 필요 시 주석 해제
    // _checkBatteryOptimization();
    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceToken == null) return;
    try {
      final data = await DeviceRemoteDatasource().getMyDevice(deviceToken);
      final hour = data['heartbeat_hour'] as int? ?? 9;
      final minute = data['heartbeat_minute'] as int? ?? 30;
      await _tokenDs.saveHeartbeatSchedule(hour, minute);
      applySchedule(hour, minute);
      if (Platform.isAndroid) {
        await HeartbeatWorkerService.schedule(hour, minute);
      }
      await LocalAlarmService.schedule(hour, minute);
    } catch (_) {
      final (h, m) = await _tokenDs.getHeartbeatSchedule();
      applySchedule(h, m);
      if (Platform.isAndroid) {
        await HeartbeatWorkerService.schedule(h, m);
      }
      await LocalAlarmService.schedule(h, m);
    }
  }

  /// 배터리 최적화 제외 안내 (Android G+S만, [설정으로 이동] 클릭 시 1회만 표시)
  static const String _kBatteryDialogShownKey = 'battery_dialog_shown';

  // ignore: unused_element
  Future<void> _checkBatteryOptimization() async {
    if (!Platform.isAndroid) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kBatteryDialogShownKey) ?? false) return;

    await Get.dialog<void>(
      AlertDialog(
        title: Text('permission_battery_required_title'.tr),
        content: Text('permission_battery_required_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('common_later'.tr),
          ),
          TextButton(
            onPressed: () async {
              await prefs.setBool(_kBatteryDialogShownKey, true);
              Get.back();
              await openAppSettings();
            },
            child: Text('permission_battery_go_to_settings'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// 대상자 로드 완료 후 구독 상태 읽기 (서비스가 로컬에 저장한 값)
  Future<void> _loadSubjectsAndSubscription({bool force = false}) async {
    await _loadSubjects(force: force);
    await _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    isSubscriptionActive.value = await _tokenDs.getSubscriptionActive();
  }

  /// 로컬에서 G+S 상태 로드 (앱 시작 시)
  Future<void> _loadSubjectState() async {
    final also = await _tokenDs.getIsAlsoSubject();
    isAlsoSubject.value = also;
    if (!also) return;
    inviteCode.value = await _tokenDs.getInviteCode() ?? '';
    await loadScheduleFromLocal();
  }

  /// 전화 버튼 탭 — 해당 대상자를 강조 대상으로 등록
  void onCallTapped(String inviteCode) {
    highlightedInviteCode.value = inviteCode;
  }

  /// 안전확인 완료 시 강조 해제
  void clearHighlight() {
    highlightedInviteCode.value = null;
  }

  Future<void> _loadSubjects({bool force = false}) async {
    isLoading = true;
    try {
      await _svc.load(force: force);
      _mapSubjects();
    } catch (e) {
      Get.snackbar('common_error'.tr, 'guardian_error_load_subjects'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading = false;
    }
  }

  /// _svc.subjects → subjects 매핑 (ever 콜백 및 직접 호출 공용)
  void _mapSubjects() {
    const alertOrder = ['urgent', 'warning', 'caution', 'info', 'normal'];
    subjects.value = _svc.subjects.map((s) => SubjectStatus(
          guardianId: s.guardianId,
          inviteCode: s.inviteCode,
          alias: s.alias,
          alertLevel: s.status,
          lastCheck: _formatLastSeen(s.lastSeen),
          daysInactive: s.alertDaysInactive,
          batteryLevel: s.batteryLevel,
        )).toList()
      ..sort((a, b) {
        final ai = alertOrder.indexOf(a.alertLevel);
        final bi = alertOrder.indexOf(b.alertLevel);
        return (ai < 0 ? alertOrder.length : ai)
            .compareTo(bi < 0 ? alertOrder.length : bi);
      });
  }

  String _formatLastSeen(String? lastSeen) {
    if (lastSeen == null) return 'guardian_no_check_history'.tr;
    final dt = DateTime.tryParse(lastSeen);
    if (dt == null) return 'guardian_no_check_history'.tr;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'guardian_last_check_now'.tr;
    if (diff.inHours < 1) return 'guardian_last_check_minutes'.trParams({'minutes': diff.inMinutes.toString()});
    if (diff.inHours < 24) return 'guardian_last_check_hours'.trParams({'hours': diff.inHours.toString()});
    return 'guardian_last_check_days'.trParams({'days': diff.inDays.toString()});
  }

  /// 대상자 목록에서 가장 높은 알림 등급 반환
  String get highestAlertLevel {
    if (subjects.isEmpty) return 'normal';
    return subjects
        .map((s) => s.alertLevel)
        .reduce((a, b) {
          const order = ['normal', 'info', 'caution', 'warning', 'urgent'];
          return order.indexOf(a) >= order.indexOf(b) ? a : b;
        });
  }

  /// 안전확인 완료 처리 — 서버 경고 클리어 후 로컬 상태 갱신
  Future<void> confirmSafety(String inviteCode) async {
    clearHighlight();
    try {
      await _svc.clearAlerts(inviteCode);
    } catch (_) {
      Get.snackbar('common_error'.tr, 'guardian_error_clear_alerts'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// 새로고침
  @override
  Future<void> refresh() async {
    await _svc.refresh();
    await _loadSubjects();
  }

  /// 대상자 추가 페이지로 이동 — 연결 완료 시 목록 즉시 갱신
  Future<void> goToAddSubject() async {
    final result = await Get.toNamed(AppRoutes.guardianAddSubject);
    if (result == true) {
      await _svc.refresh();
      await _loadSubjects();
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

      // Android: WorkManager + 로컬 안전망 등록
      // iOS G+S: 오늘의 안부 확인 메시지 로컬 알림만 등록 (BGTaskScheduler 사용 안 함)
      if (Platform.isAndroid) {
        await HeartbeatWorkerService.schedule(hour, minute);
      }
      await LocalAlarmService.schedule(hour, minute);

      // 첫 heartbeat 즉시 전송 — 이후 SafetyCode.onInit에서는
      // HeartbeatService 내부 dedup + isReportedToday 체크로 중복 전송 방지
      try {
        await HeartbeatService().execute();
      } catch (_) {}

      Get.snackbar('', 'gs_enabled_message'.tr,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.white,
          colorText: const Color(0xFF1a1c1c));

      goToSafetyCode();
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
      if (deviceToken == null) return;
      await _userDs.disableSubject(deviceToken);

      if (Platform.isAndroid) {
        await HeartbeatWorkerService.cancel();
      }
      await LocalAlarmService.cancel();

      await _tokenDs.saveIsAlsoSubject(false);
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
      Get.snackbar('common_error'.tr, 'gs_disable_failed'.tr,
          snackPosition: SnackPosition.TOP);
    }
  }

  /// 탈퇴 시 heartbeat 예약 정리 — 설정 컨트롤러가 호출
  Future<void> cancelHeartbeatSchedules() async {
    if (!isAlsoSubject.value) return;
    if (Platform.isAndroid) {
      await HeartbeatWorkerService.cancel();
    }
    await LocalAlarmService.cancel();
  }

  /// G+S 활성 상태에서 안전 코드 확인 페이지로 이동
  void goToSafetyCode() {
    Get.toNamed(AppRoutes.guardianSafetyCode, arguments: {
      'deviceData': {
        'heartbeat_hour': heartbeatHour.value,
        'heartbeat_minute': heartbeatMinute.value,
        'subscription_active': isSubscriptionActive.value,
        'guardian_count': guardianCount.value,
      },
    });
  }
}

/// 대상자 상태 모델
class SubjectStatus {
  final int guardianId;
  final String inviteCode;
  final String alias;
  final String alertLevel; // normal, caution, warning, urgent
  final String lastCheck;
  final int daysInactive;
  final int? batteryLevel;

  const SubjectStatus({
    required this.guardianId,
    required this.inviteCode,
    required this.alias,
    required this.alertLevel,
    required this.lastCheck,
    this.daysInactive = 0,
    this.batteryLevel,
  });

  bool get isNormal => alertLevel == 'normal';
  bool get isCaution => alertLevel == 'caution';
  bool get isWarning => alertLevel == 'warning';
  bool get isUrgent => alertLevel == 'urgent';

  String get activityLabel {
    if (isNormal) return 'guardian_activity_stable'.tr;
    if (!isNormal) return 'guardian_safety_needed'.tr;
    return '';
  }
}
