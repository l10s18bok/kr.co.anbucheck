import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/core/mixins/heartbeat_schedule_mixin.dart';
import 'package:anbucheck/app/core/services/fcm_service.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/core/services/subscription_service.dart';
import 'package:anbucheck/app/data/datasources/local/heartbeat_lock_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/subject_remote_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/user_remote_datasource.dart';
import 'package:anbucheck/app/modules/safety_home/controllers/safety_home_role.dart';
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

  /// 차트 다이얼로그 중복 오픈 방지 가드. 캘린더 아이콘 탭 → 30일 데이터 로드(서버
  /// 호출, 지연 가능) → 다이얼로그 표시 구간 동안 true. 로드 대기 중 다시 탭해 다이얼로그가
  /// 2개 뜨던 문제 차단. UI 바인딩이 아니라 단순 가드라 Rx 불필요.
  bool isChartDialogBusy = false;

  final _subjectDs = SubjectRemoteDatasource();

  /// 전화 후 앱 복귀 시 강조할 대상자 코드
  final highlightedInviteCode = RxnString();

  /// 구독 활성 여부 — 단일 소스 [SubscriptionService]에 위임(중복 Rx 제거).
  /// 만료 시 대상자 카드·걸음수 그래프 로드를 차단하는 게이트로 사용.
  RxBool get isSubscriptionActive => _sub.isActive;

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
  final _sub = Get.find<SubscriptionService>();
  final _tokenDs = TokenLocalDatasource();
  final _userDs = UserRemoteDatasource();

  @override
  void onInit() {
    super.onInit();
    // 서비스에 이미 캐시된 데이터가 있으면 즉시 반영 (타이밍 문제 방지)
    if (_svc.subjects.isNotEmpty) _mapSubjects();
    // subjects 데이터 변경 시 자동 반영 (FCM 수신 후 서비스 갱신 포함)
    ever(_svc.subjects, (_) => _mapSubjects());
    // 구독 활성 전환 시 카드 마스킹 즉시 반영 — 실제값 ↔ (정상/걸음수 0) 재매핑.
    // /subjects는 정상 호출(연결관리와 공유)해 실제값이 캐시에 있으므로, 재구독 시
    // 재매핑만으로 즉시 해제(네트워크 불필요). 30일 차트 캐시는 잠금/해제 경계에서
    // 비워 다음 오픈 시 올바른 값(0 또는 실제)을 받게 한다. **표시 전용 — heartbeat 무관**.
    ever(_sub.isActive, (active) {
      monthlyStepsCache.clear();
      if (active) {
        _loadSubjects(force: true); // 최신 실제값 확보 + 재매핑
      } else {
        _mapSubjects(); // 마스킹 적용 (재조회 불필요)
      }
    });
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
  ///
  /// **Rx race 차단**: `isAlsoSubject` 상태 검사는 Rx 값 대신 SharedPreferences를 직접
  /// 읽는다. onInit에서 `_loadSubjectState`(Rx 설정)와 이 함수가 병렬 실행되며,
  /// `_scheduleHeartbeatIfGS`가 catch 분기로 빠르게 종료되는 케이스에 `_loadSubjectState`
  /// 보다 먼저 끝나면 Rx 값이 아직 초기값(false)이라 첫 heartbeat 전송이 누락되는 race가
  /// 발생할 수 있었음. SharedPreferences는 onboarding의 saveIsAlsoSubject가 이미 완료한
  /// 시점이라 진실의 원천으로 안전.
  Future<void> _initGuardianSubjectMode() async {
    await _scheduleHeartbeatIfGS();
    final isAls = await _tokenDs.getIsAlsoSubject();
    if (!isAls) return;
    await _sendAndConsumeSafetyNetDialog();
  }

  /// onResumed 진입 시: G+S인 경우 로컬 스케줄 재로드 후 heartbeat 미전송 체크
  Future<void> _resumeGuardianSubjectMode() async {
    final isAls = await _tokenDs.getIsAlsoSubject();
    if (!isAls) return;
    await loadScheduleFromLocal();
    await _sendAndConsumeSafetyNetDialog();
  }

  /// FCM이 gs_deadman 로컬 알림 탭 시 호출 (이미 스택에 있을 때)
  Future<void> refreshAndSend() async {
    final isAls = await _tokenDs.getIsAlsoSubject();
    if (!isAls) return;
    await loadScheduleFromLocal();
    await _sendAndConsumeSafetyNetDialog();
  }

  /// 안전망 알림 탭 진입 공통 처리 — 미전송이면 자동 전송한 뒤 안내 다이얼로그를 띄운다.
  /// 탭 이전 전송 여부(alreadyReported/reportedTime)는 탭 시점에 FcmService가
  /// [FcmService.pendingAlreadyReported]/[FcmService.pendingReportedTime]에 미리 캡처해두므로
  /// 여기서 별도 캡처 없이 [consumeSafetyNetDialogIfPending]에서 직접 사용한다.
  Future<void> _sendAndConsumeSafetyNetDialog() async {
    await _reloadHeartbeatState();
    await _checkAndSendHeartbeat();
    await FcmService.consumeSafetyNetDialogIfPending(delivered: isReportedToday);
  }

  /// 로컬 알림 탭 전용 — isReportedToday와 무관하게 무조건 전송.
  /// 사용자가 알림을 탭한 행위 자체가 "오늘 안부 보내기" 명시적 의사 표현이므로
  /// 오늘 이미 전송했더라도 최신 걸음수로 재전송한다.
  ///
  /// 다이얼로그 문구 분기(이미 전송됨 vs 방금 전달됨)는 [FcmService.pendingAlreadyReported]/
  /// [FcmService.pendingReportedTime]으로 탭 시점에 이미 캡처됨 — 재전송이 SharedPreferences를
  /// 덮어쓰기 전 값이 보존되어 정확히 "이미 @priorTime에 전달됨"으로 안내된다.
  Future<void> refreshAndForceSend() async {
    final isAls = await _tokenDs.getIsAlsoSubject();
    if (!isAls) return;
    await loadScheduleFromLocal();
    await HeartbeatService().execute(manual: true, isInteractiveAtTrigger: true);
    await _reloadHeartbeatState();
    await FcmService.consumeSafetyNetDialogIfPending(delivered: isReportedToday);
  }

  /// SafetyCode 등 외부에서 heartbeat 상태 재로드가 필요할 때 호출
  Future<void> reloadHeartbeatState() => _reloadHeartbeatState();

  Future<void> _reloadHeartbeatState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    _lastHeartbeatDate.value = await _tokenDs.getLastHeartbeatDate() ?? '';
    _lastHeartbeatTime.value = await _tokenDs.getLastHeartbeatTime() ?? '';
  }

  /// 예약시각 경과(Android) + 오늘 미전송이면 heartbeat 자동 전송 (자정 전까지 무조건).
  /// iOS G+S는 시각 조건 없이 "당일 미전송"만 확인.
  /// 자정 경계만이 의미 단위 — 자정 넘어가면 `isReportedToday`가 false로 유지되더라도
  /// `isScheduleInFuture`(다음 예약시각 이전)에 막혀 자연스럽게 다음 날로 넘어간다.
  /// 늦은 전송 성공 시 `_onHeartbeatSent`가 WorkManager를 내일자로 재등록한다.
  ///
  /// **첫 설치(전송 이력 없음) 우회**: `lastHeartbeatDate`가 비어있으면 `isScheduleInFuture`
  /// 가드까지 건너뛰고 즉시 전송한다 (SubjectHomeController와 동일 패턴).
  /// G+S 재설치를 자정 직후에 한 케이스에서 `isScheduleInFuture=true`에 막혀 다음 날
  /// 예약시각까지 첫 heartbeat가 누락되는 갭을 차단. Google Fit 구독 생성, 서버 last_seen
  /// baseline, 등록→heartbeat 파이프라인 검증을 한 번에 처리.
  Future<void> _checkAndSendHeartbeat() async {
    if (isReportedToday) return;
    final hasEverSent = lastHeartbeatDate.isNotEmpty;
    if (hasEverSent && Platform.isAndroid && isScheduleInFuture) {
      // 예약시각 이전 — 평소엔 정시까지 대기. 단 전날(이전) 미전송 갭이 있으면
      // 앱을 연 행위가 강한 생존 신호이므로 회복 전송(추가, 정시 슬롯 미소비)을 보낸다.
      if (_isRecoveryPending) {
        await HeartbeatService().execute(recovery: true);
      }
      return;
    }
    await _clearStaleScheduledKey();
    // 포그라운드 진입은 화면을 켜고 잠금을 풀어 앱을 연 결과이므로
    // interactive=true가 확정 증거 — 명시 전달.
    await HeartbeatService().execute(manual: false, isInteractiveAtTrigger: true);
    await _reloadHeartbeatState();
  }

  /// 전날(또는 그 이전) heartbeat 미전송 갭 존재 여부 — 회복 전송 트리거.
  /// lastHeartbeatDate가 오늘도 어제도 아니면 갭. (비어있으면 첫 설치 —
  /// hasEverSent 분기에서 이미 우회되므로 false 반환.)
  bool get _isRecoveryPending {
    final date = lastHeartbeatDate;
    if (date.isEmpty) return false;
    final now = DateTime.now();
    return date != formatYmd(now) &&
        date != formatYmd(now.subtract(const Duration(days: 1)));
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
    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceToken == null) return;
    try {
      final data = await DeviceRemoteDatasource().getMyDevice(deviceToken);
      final hour = data['heartbeat_hour'] as int? ?? 18;
      final minute = data['heartbeat_minute'] as int? ?? 0;
      final subscriptionActive = data['subscription_active'] as bool? ?? true;
      final count = data['guardian_count'] as int? ?? 0;
      await _tokenDs.saveHeartbeatSchedule(hour, minute);
      await _sub.set(subscriptionActive);
      guardianCount.value = count;
      applySchedule(hour, minute);
      if (Platform.isAndroid) {
        await HeartbeatWorkerService.schedule(hour, minute);
      }
      // LocalAlarm 재예약은 HeartbeatService가 전송 성공/실패 시 forceNextDay로 전담 —
      // 여기서 forceNextDay 없이 재호출하면, 이미 오늘 전송돼 _onHeartbeatSent가 내일로
      // 옮겨둔 안전망 알림을 (heartbeat+3h가 오늘 미래면) 다시 오늘로 되돌린다. S 모드
      // (_syncScheduleFromServer)와 동일하게 onInit 재예약은 하지 않는다.
    } catch (_) {
      final (h, m) = await _tokenDs.getHeartbeatSchedule();
      applySchedule(h, m);
      if (Platform.isAndroid) {
        await HeartbeatWorkerService.schedule(h, m);
      }
    }
  }

  /// 대상자 로드. 구독 활성 상태는 [_svc.load]가 /subjects 응답으로
  /// [SubscriptionService.set]을 통해 갱신하므로 별도 동기화가 불필요.
  Future<void> _loadSubjectsAndSubscription({bool force = false}) async {
    await _loadSubjects(force: force);
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
  /// 정렬: 1차 경고 등급순(urgent→warning→caution→info→normal),
  ///       2차 보호자가 연결관리에서 지정한 사용자 순서
  void _mapSubjects() {
    // 구독 만료 시: 리스트(이름)는 그대로 보여주되 **모니터링 시각화만 마스킹**한다 —
    // 모든 카드를 '정상'으로, 걸음수 그래프(7일)를 전부 0으로 표시(경고 등급 변화·활동
    // 노출 차단). /subjects 자체는 정상 호출(연결관리와 공유)하므로 실제값은 캐시에 있고,
    // 재구독 시 _mapSubjects 재실행만으로 즉시 실제값 복원(네트워크 불필요).
    // ※ 실제로 긴급/경고 상태인 대상자도 만료 중엔 '정상'으로 보인다(거짓 안심) —
    //   결제 끊김 시 모니터링을 가리겠다는 의도된 동작(§9.8 참조).
    final locked = !_sub.isActive.value;
    const alertOrder = ['urgent', 'warning', 'caution', 'info', 'normal'];
    final userOrder = _svc.orderIndex;
    subjects.value = _svc.subjects.map((s) => SubjectStatus(
          guardianId: s.guardianId,
          userId: s.userId,
          inviteCode: s.inviteCode,
          alias: s.alias,
          alertLevel: locked ? 'normal' : s.status,
          lastCheck: _formatLastSeen(s.lastSeen),
          daysInactive: locked ? 0 : s.alertDaysInactive,
          batteryLevel: s.batteryLevel,
          weeklySteps: locked ? List<int?>.filled(7, 0) : s.weeklySteps,
        )).toList()
      ..sort((a, b) {
        final ai = alertOrder.indexOf(a.alertLevel);
        final bi = alertOrder.indexOf(b.alertLevel);
        final levelCmp = (ai < 0 ? alertOrder.length : ai)
            .compareTo(bi < 0 ? alertOrder.length : bi);
        if (levelCmp != 0) return levelCmp;
        final auo = userOrder[a.inviteCode] ?? 1 << 30;
        final buo = userOrder[b.inviteCode] ?? 1 << 30;
        return auo.compareTo(buo);
      });
  }

  /// 차트 다이얼로그 오픈 전 30일 데이터 확보.
  /// 캐시 있으면 즉시 true, 없으면 서버 호출 후 캐시. 실패 시 false.
  Future<bool> loadMonthlyStepsIfNeeded(SubjectStatus s) async {
    // 구독 만료 시: 30일 상세 차트도 걸음수 전부 0으로(서버 호출 없이). 7일 그래프
    // 마스킹과 일관. 재구독 시 ever(isActive)가 캐시를 비워 다음 오픈에 실제값 재조회.
    if (!_sub.isActive.value) {
      monthlyStepsCache[s.inviteCode] = List<int?>.filled(30, 0);
      return true;
    }
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
      // Lazy Permission — 걸음수·위치 권한은 G+S 활성화 시점에 요청한다.
      // 순수 보호자는 초기 권한 화면에서 두 권한을 요청받지 않았으므로
      // 이 시점이 사실상 up-front 요청 기회다.
      // 거부 시에도 활성화는 계속 진행하며, 안전코드 화면의 경고 위젯이
      // 재요청을 유도한다. 따라서 결과와 무관하게 삼킨다.
      if (Platform.isAndroid) {
        try {
          await Permission.activityRecognition.request();
        } catch (_) {}
        try {
          await Permission.locationWhenInUse.request();
        } catch (_) {}
      } else if (Platform.isIOS) {
        // iOS: Permission.activityRecognition.request()는 시스템 팝업을 띄우지 않음.
        // Permission.sensors.request()가 내부에서 CMMotionActivityManager를 호출해
        // 최초 1회 모션 권한 시스템 팝업을 띄운다.
        try {
          await Permission.sensors.request();
        } catch (_) {}
        try {
          await Permission.locationWhenInUse.request();
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
      // G+S 활성화는 사용자가 직접 버튼을 탭한 결과이므로 interactive=true 확정.
      try {
        await HeartbeatService().execute(isInteractiveAtTrigger: true);
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

      // **순서 중요 (race 차단)**: save를 cancel보다 먼저.
      // 워커 isolate가 마지막 heartbeat 직후 `_rescheduleNextDay`에서 SharedPreferences를
      // reload할 때 `isAlsoSubject=false`를 보고 skip하도록 한다. 반대 순서면
      // worker가 `isAlsoSubject=true`로 읽고 schedule을 재등록하는 race가 생긴다.
      await _tokenDs.saveIsAlsoSubject(false);
      await _tokenDs.saveLastHeartbeatDate('');
      await _tokenDs.saveLastHeartbeatTime('');

      if (Platform.isAndroid) {
        await HeartbeatWorkerService.cancel();
      }
      await LocalAlarmService.cancel();

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
    Get.toNamed(AppRoutes.safetyHome, arguments: {
      'role': HomeRole.guardianSubject,
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
    // 탈퇴/재설정 — 영속값은 TokenLocalDatasource.clear()가 false로 저장하므로
    // 여기선 Rx만 즉시 반영(다음 계정이 잠금 상태로 시작).
    _sub.isActive.value = false;
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
