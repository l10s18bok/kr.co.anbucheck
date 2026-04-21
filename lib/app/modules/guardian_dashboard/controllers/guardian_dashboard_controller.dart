import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/core/mixins/heartbeat_schedule_mixin.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/data/datasources/local/heartbeat_lock_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/sensor_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/subject_remote_datasource.dart';
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

  /// 30일 걸음수 캐시 (invite_code → 30일 배열). 차트 다이얼로그에서 사용.
  final monthlyStepsCache = <String, List<int?>>{}.obs;

  final _subjectDs = SubjectRemoteDatasource();

  /// 전화 후 앱 복귀 시 강조할 대상자 코드
  final highlightedInviteCode = RxnString();

  /// 구독 활성 여부
  final isSubscriptionActive = true.obs;

  // ── G+S (보호자 겸 대상자) 상태 ──
  final isAlsoSubject = false.obs;
  final inviteCode = ''.obs;
  final guardianCount = 0.obs;
  final isEnabling = false.obs;

  // ── G+S heartbeat 보고 상태 (SafetyCode 카드가 Obx로 구독) ──
  final _lastHeartbeatDate = ''.obs;
  final _lastHeartbeatTime = ''.obs;
  String get lastHeartbeatDate => _lastHeartbeatDate.value;
  String get lastHeartbeatTime => _lastHeartbeatTime.value;

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
    _initGuardianSubjectMode();
  }

  /// 앱이 포그라운드로 복귀 — 대상자 목록 갱신 + G+S heartbeat 재확인
  @override
  void onResumed() {
    super.onResumed();
    _loadSubjectsAndSubscription(force: true);
    _resumeGuardianSubjectMode();
  }

  /// onInit 진입 시: G+S 스케줄 동기화 후 heartbeat 미전송 체크
  /// 순서가 중요 — isScheduleInFuture가 heartbeatHour/Minute를 참조하므로
  /// 스케줄 로드가 반드시 선행되어야 한다.
  Future<void> _initGuardianSubjectMode() async {
    await _scheduleHeartbeatIfGS();
    if (!isAlsoSubject.value) return;
    await _reloadHeartbeatState();
    await _checkAndSendHeartbeat();
  }

  /// onResumed 진입 시: G+S인 경우 로컬 스케줄 재로드 후 heartbeat 미전송 체크
  Future<void> _resumeGuardianSubjectMode() async {
    if (!isAlsoSubject.value) return;
    await loadScheduleFromLocal();
    await _reloadHeartbeatState();
    await _checkAndSendHeartbeat();
  }

  /// FCM이 gs_deadman 로컬 알림 탭 시 호출 (이미 스택에 있을 때)
  Future<void> refreshAndSend() async {
    if (!isAlsoSubject.value) return;
    await loadScheduleFromLocal();
    await _reloadHeartbeatState();
    await _checkAndSendHeartbeat();
  }

  /// SafetyCode 등 외부에서 heartbeat 상태 재로드가 필요할 때 호출
  Future<void> reloadHeartbeatState() => _reloadHeartbeatState();

  Future<void> _reloadHeartbeatState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    _lastHeartbeatDate.value = await _tokenDs.getLastHeartbeatDate() ?? '';
    _lastHeartbeatTime.value = await _tokenDs.getLastHeartbeatTime() ?? '';
  }

  /// 예약시각 경과(Android) + 오늘 미전송이면 heartbeat 자동 전송
  /// iOS G+S는 시각 조건 없이 "당일 미전송"만 확인
  Future<void> _checkAndSendHeartbeat() async {
    if (isReportedToday) return;
    if (Platform.isAndroid && isScheduleInFuture) return;
    await _clearStaleScheduledKey();
    await HeartbeatService().execute(manual: false);
    await _reloadHeartbeatState();
  }

  /// Worker가 Doze/OEM 절전으로 중도 종료되면 lastHeartbeatDate는 비어있고
  /// lastScheduledKey만 남아 2차 안전망(앱 복귀 자동 전송)이 dedup 가드에 막혀
  /// 영구히 차단된다. 포그라운드 진입 시 "오늘 미전송인데 오늘자 키가 박혀 있는"
  /// stale 상태를 감지해 정리한다.
  Future<void> _clearStaleScheduledKey() async {
    final lastKey = await _tokenDs.getLastScheduledKey();
    if (lastKey == null || lastKey.isEmpty) return;
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (lastKey.startsWith(today)) {
      debugPrint('[GuardianDashboard] stale lastScheduledKey 정리 ($lastKey)');
      await _tokenDs.clearLastScheduledKey();
    }
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
      final hour = data['heartbeat_hour'] as int? ?? 18;
      final minute = data['heartbeat_minute'] as int? ?? 0;
      final subscriptionActive = data['subscription_active'] as bool? ?? true;
      final count = data['guardian_count'] as int? ?? 0;
      await _tokenDs.saveHeartbeatSchedule(hour, minute);
      await _tokenDs.saveSubscriptionActive(subscriptionActive);
      isSubscriptionActive.value = subscriptionActive;
      guardianCount.value = count;
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
      AppSnackbar.show('common_error'.tr, 'guardian_error_load_subjects'.tr);
    } finally {
      isLoading = false;
    }
  }

  /// _svc.subjects → subjects 매핑 (ever 콜백 및 직접 호출 공용)
  void _mapSubjects() {
    const alertOrder = ['urgent', 'warning', 'caution', 'info', 'normal'];
    subjects.value = _svc.subjects.map((s) => SubjectStatus(
          guardianId: s.guardianId,
          userId: s.userId,
          inviteCode: s.inviteCode,
          alias: s.alias,
          alertLevel: s.status,
          lastCheck: _formatLastSeen(s.lastSeen),
          daysInactive: s.alertDaysInactive,
          batteryLevel: s.batteryLevel,
          weeklySteps: s.weeklySteps,
        )).toList()
      ..sort((a, b) {
        final ai = alertOrder.indexOf(a.alertLevel);
        final bi = alertOrder.indexOf(b.alertLevel);
        return (ai < 0 ? alertOrder.length : ai)
            .compareTo(bi < 0 ? alertOrder.length : bi);
      });
  }

  /// 차트 다이얼로그 오픈 전 30일 데이터 확보.
  /// 캐시 있으면 즉시 true, 없으면 서버 호출 후 캐시. 실패 시 false.
  Future<bool> loadMonthlyStepsIfNeeded(SubjectStatus s) async {
    if (monthlyStepsCache.containsKey(s.inviteCode)) return true;
    final token = await _tokenDs.getDeviceToken();
    if (token == null) return false;
    try {
      final history =
          await _subjectDs.getStepHistory(token, s.userId, days: 30);
      monthlyStepsCache[s.inviteCode] = history;
      return true;
    } catch (_) {
      AppSnackbar.show(
          'common_error'.tr, 'guardian_error_load_step_history'.tr);
      return false;
    }
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
  Future<void> confirmSafety(String inviteCode, String nickname) async {
    clearHighlight();
    try {
      await _svc.clearAlerts(inviteCode);
      AppSnackbar.show(
        '',
        '$nickname ${'guardian_safety_confirmed'.tr}',
      );
    } catch (_) {
      AppSnackbar.show('common_error'.tr, 'guardian_error_clear_alerts'.tr);
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
    // 재진입 가드: G+S 토글 더블탭 시 enable-subject가 두 번 발사되어
    // 서버가 invite_code를 재발급하면서 첫 응답이 stale해지는 이슈 방지
    if (isEnabling.value) return;
    isEnabling.value = true;
    try {
      // Lazy Permission — 걸음수 권한은 G+S 활성화 시점에만 요청한다.
      // 권한 거부 시에도 활성화는 계속 진행하며, 안전코드 화면의 경고 위젯이
      // 재요청을 유도한다. 따라서 결과와 무관하게 삼키고 통과시킨다.
      if (Platform.isAndroid) {
        try {
          await Permission.activityRecognition.request();
        } catch (_) {}
      } else if (Platform.isIOS) {
        // iOS: Permission.activityRecognition.request()는 시스템 팝업을 띄우지 않음.
        // Permission.sensors.request()가 내부에서 CMMotionActivityManager를 호출해
        // 최초 1회 모션 권한 시스템 팝업을 띄운다.
        try {
          await Permission.sensors.request();
        } catch (_) {}
      }

      final deviceToken = await _tokenDs.getDeviceToken();
      if (deviceToken == null) return;
      final result = await _userDs.enableSubject(deviceToken);
      final code = result['invite_code'] as String;
      final hour = result['heartbeat_hour'] as int? ?? 18;
      final minute = result['heartbeat_minute'] as int? ?? 0;

      // 이전 G+S 세션이 비정상 종료로 남긴 락 잔재가 첫 heartbeat를 차단하지
      // 않도록 활성화 직전에 청소. TTL 30초 자연 해제보다 확실.
      await HeartbeatLockDatasource().clearAll();

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

      // 첫 heartbeat 즉시 전송 — HeartbeatService 내부 dedup으로 중복 전송 방지
      try {
        await HeartbeatService().execute();
      } catch (_) {}
      // 전송 결과를 로컬 Rx에 반영 (SafetyCode 카드가 즉시 보고 상태로 전환)
      await _reloadHeartbeatState();

      AppSnackbar.show('', 'gs_enabled_message'.tr,
          position: SnackPosition.TOP,
          duration: const Duration(seconds: 2));

      goToSafetyCode();
    } catch (e) {
      AppSnackbar.show('common_error'.tr, 'gs_enable_failed'.tr,
          position: SnackPosition.TOP);
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
      // G+S 재활성화 시 이전 락이 남아있으면 첫 heartbeat가 스킵될 수 있음
      await HeartbeatLockDatasource().clearAll();

      isAlsoSubject.value = false;
      inviteCode.value = '';
      guardianCount.value = 0;
      _lastHeartbeatDate.value = '';
      _lastHeartbeatTime.value = '';

      AppSnackbar.show('', 'gs_disabled_message'.tr,
          position: SnackPosition.TOP,
          duration: const Duration(seconds: 2));
    } catch (e) {
      AppSnackbar.show('common_error'.tr, 'gs_disable_failed'.tr,
          position: SnackPosition.TOP);
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

  /// G+S 활성 상태에서 안전 코드 확인 페이지로 이동.
  /// invite_code를 arguments로 함께 전달해 SafetyCode가 SharedPreferences의
  /// reload 타이밍 이슈(iOS 특히)와 무관하게 즉시 화면에 표시할 수 있게 한다.
  void goToSafetyCode() {
    Get.toNamed(AppRoutes.guardianSafetyCode, arguments: {
      'deviceData': {
        'invite_code': inviteCode.value,
        'heartbeat_hour': heartbeatHour.value,
        'heartbeat_minute': heartbeatMinute.value,
        'subscription_active': isSubscriptionActive.value,
        'guardian_count': guardianCount.value,
      },
    });
  }

  /// 탈퇴 시 Dashboard Rx 상태 초기화 — Dashboard는 permanent로 등록되어
  /// Get.offAllNamed(modeSelect) 이후에도 인스턴스가 살아있으므로, 재가입 시
  /// 이전 G+S 상태가 남아있지 않도록 명시적으로 리셋한다.
  /// ([cancelHeartbeatSchedules]는 WorkManager/LocalAlarm 취소만 담당)
  void resetSubjectState() {
    isAlsoSubject.value = false;
    inviteCode.value = '';
    guardianCount.value = 0;
    _lastHeartbeatDate.value = '';
    _lastHeartbeatTime.value = '';
    isSubscriptionActive.value = false;
    subjects.clear();
    highlightedInviteCode.value = null;
  }
}

/// 대상자 상태 모델
class SubjectStatus {
  final int guardianId;
  final int userId;
  final String inviteCode;
  final String alias;
  final String alertLevel; // normal, caution, warning, urgent
  final String lastCheck;
  final int daysInactive;
  final int? batteryLevel;
  /// 최근 7일 걸음수. index 0 = 6일 전, index 6 = 오늘.
  /// null = 등록 전, 0 = heartbeat 없음, >0 = 실제 걸음수.
  final List<int?> weeklySteps;

  const SubjectStatus({
    required this.guardianId,
    required this.userId,
    required this.inviteCode,
    required this.alias,
    required this.alertLevel,
    required this.lastCheck,
    this.daysInactive = 0,
    this.batteryLevel,
    this.weeklySteps = const [],
  });

  bool get isNormal => alertLevel == 'normal';
  bool get isCaution => alertLevel == 'caution';
  bool get isWarning => alertLevel == 'warning';
  bool get isUrgent => alertLevel == 'urgent';

  /// 기본 활동량 라벨 (7일 기준)
  String get activityLabel => activityLabelFor(weeklySteps);

  /// 걸음수 배열(7일 또는 30일)을 받아 활동량 라벨 산출.
  /// · 경고 등급(caution/warning/urgent) → "안전 확인이 필요합니다" (접두어 없음)
  /// · 그 외에는 모두 "활동량 : <판정>" 형태로 반환
  ///   - 유효 샘플 3건 미만 → "데이터 수집 중"
  ///   - 평균 ≥ 6000 → "아주 활동적"
  ///   - 평균 ≥ 3000 → "활동적"
  ///   - 그 외       → "운동 필요"
  String activityLabelFor(List<int?> steps) {
    if (!isNormal) return 'guardian_safety_needed'.tr;
    final prefix = '${'guardian_activity_prefix'.tr} : ';
    final valid = steps.whereType<int>().toList();
    if (valid.length < 3) {
      return '$prefix${'guardian_activity_collecting'.tr}';
    }
    final avg = valid.reduce((a, b) => a + b) / valid.length;
    if (avg >= 6000) return '$prefix${'guardian_activity_very_active'.tr}';
    if (avg >= 3000) return '$prefix${'guardian_activity_active'.tr}';
    return '$prefix${'guardian_activity_needs_exercise'.tr}';
  }
}
