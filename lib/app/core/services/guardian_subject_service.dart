import 'package:get/get.dart';
import 'package:anbucheck/app/data/datasources/local/nickname_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/subject_order_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/subject_remote_datasource.dart';

/// 보호자 대상자 목록 공유 서비스
/// Dashboard / ConnectionManagement / Settings 가 공통으로 사용
/// 한 번 로드된 데이터를 공유하여 중복 API 호출 방지
class GuardianSubjectService extends GetxService {
  final _tokenDs = TokenLocalDatasource();
  final _nicknameDs = NicknameLocalDatasource();
  final _orderDs = SubjectOrderLocalDatasource();
  final _subjectDs = SubjectRemoteDatasource();

  /// 보호자가 지정한 invite_code 표시 순서 인덱스 (정렬 키)
  /// 저장된 순서에 없는 신규 대상자는 끝에 배치
  final orderIndex = <String, int>{}.obs;

  final subjects = <SubjectItem>[].obs;
  final maxSubjects = 5.obs;
  final canAddMore = true.obs;
  final isLoading = false.obs;

  DateTime? _lastFetched;
  static const _cacheDuration = Duration(minutes: 2);

  bool get isFresh =>
      _lastFetched != null &&
      DateTime.now().difference(_lastFetched!) < _cacheDuration;

  /// 대상자 목록 로드 (캐시 유효 시 API 미호출)
  Future<void> load({bool force = false}) async {
    if (!force && isFresh) return;

    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceToken == null) return;

    isLoading.value = true;
    try {
      final data = await _subjectDs.getSubjects(deviceToken);
      final nicknames = await _nicknameDs.getAll();
      final savedOrder = await _orderDs.getOrder();

      final loaded = (data['subjects'] as List<dynamic>? ?? [])
          .map((s) => s as Map<String, dynamic>)
          .map((s) {
        final inviteCode = s['invite_code'] as String? ?? '';
        final rawWeekly = (s['weekly_steps'] as List?) ?? const [];
        final weeklySteps = rawWeekly
            .map((e) => e == null ? null : (e as num).toInt())
            .toList();
        return SubjectItem(
          guardianId: s['guardian_id'] as int,
          userId: s['user_id'] as int,
          inviteCode: inviteCode,
          alias: nicknames[inviteCode] ?? inviteCode,
          lastSeen: s['last_seen'] as String?,
          status: s['status'] as String? ?? 'normal',
          alertDaysInactive:
              (s['alert'] as Map<String, dynamic>?)?['days_inactive'] as int? ??
                  0,
          deviceId: s['device_id'] as String?,
          heartbeatHour: s['heartbeat_hour'] as int? ?? 18,
          heartbeatMinute: s['heartbeat_minute'] as int? ?? 0,
          batteryLevel: s['battery_level'] as int?,
          weeklySteps: weeklySteps,
        );
      }).toList();

      // 저장된 순서 적용 — 저장된 invite_code 먼저(저장된 순서대로),
      // 그 외 신규 대상자는 서버 응답 순서대로 뒤에 배치
      final orderRank = <String, int>{
        for (int i = 0; i < savedOrder.length; i++) savedOrder[i]: i,
      };
      loaded.sort((a, b) {
        final ai = orderRank[a.inviteCode];
        final bi = orderRank[b.inviteCode];
        if (ai != null && bi != null) return ai.compareTo(bi);
        if (ai != null) return -1;
        if (bi != null) return 1;
        return 0;
      });

      subjects.value = loaded;
      _rebuildOrderIndex();

      maxSubjects.value = data['max_subjects'] as int? ?? 5;
      canAddMore.value = data['can_add_more'] as bool? ?? true;

      // 구독 상태 동기화 (추가 API 호출 없이 /subjects 응답에서 처리)
      final subscriptionActive = data['subscription_active'] as bool? ?? true;
      await _tokenDs.saveSubscriptionActive(subscriptionActive);

      _lastFetched = DateTime.now();
    } catch (_) {
      // 호출부에서 에러 처리
    } finally {
      isLoading.value = false;
    }
  }

  /// 캐시 무효화 후 강제 갱신
  Future<void> refresh() async {
    _lastFetched = null;
    await load(force: true);
  }

  /// 특정 대상자 별칭 로컬 업데이트
  void updateAlias(String inviteCode, String alias) {
    final idx = subjects.indexWhere((s) => s.inviteCode == inviteCode);
    if (idx == -1) return;
    subjects[idx] = subjects[idx].copyWith(alias: alias);
  }

  /// 보호자가 드래그 앤 드롭으로 지정한 순서를 적용 + 로컬 저장
  /// [orderedInviteCodes]는 표시할 invite_code 전체 목록을 새 순서로 전달
  Future<void> reorder(List<String> orderedInviteCodes) async {
    final byCode = {for (final s in subjects) s.inviteCode: s};
    final reordered = <SubjectItem>[
      for (final code in orderedInviteCodes)
        if (byCode.containsKey(code)) byCode.remove(code)!,
    ];
    // 누락된 항목(이론상 없음)은 끝에 보존
    reordered.addAll(byCode.values);
    // orderIndex를 먼저 갱신해야 subjects.value 할당으로 즉시 발화되는
    // dashboard ever 콜백이 새 인덱스를 읽는다 (GetX의 RxList notify는 동기)
    _rebuildOrderIndex(source: reordered);
    subjects.value = reordered;
    await _orderDs.saveOrder(reordered.map((s) => s.inviteCode).toList());
  }

  void _rebuildOrderIndex({List<SubjectItem>? source}) {
    final list = source ?? subjects;
    orderIndex.value = {
      for (int i = 0; i < list.length; i++) list[i].inviteCode: i,
    };
  }

  /// 특정 대상자 경고 해제 — 서버 API 호출 후 로컬 캐시 갱신
  Future<void> clearAlerts(String inviteCode) async {
    final idx = subjects.indexWhere((s) => s.inviteCode == inviteCode);
    if (idx == -1) return;

    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceToken == null) return;

    await _subjectDs.clearAllAlerts(deviceToken, subjects[idx].userId);

    // 로컬 캐시 즉시 반영 → ever() 콜백 자동 실행
    subjects[idx] = subjects[idx].copyWith(status: 'normal');
    subjects.refresh();
  }

  /// 특정 대상자 제거
  void removeByGuardianId(int guardianId) {
    subjects.removeWhere((s) => s.guardianId == guardianId);
    _rebuildOrderIndex();
    // 저장된 순서에서 사라진 invite_code도 정리
    _orderDs.saveOrder(subjects.map((s) => s.inviteCode).toList());
    _lastFetched = null; // 다음 로드 시 서버 반영
  }

  /// 탈퇴 시 인메모리 캐시 전체 초기화 — permanent 등록이라 컨트롤러 해제
  /// 이후에도 이전 계정 대상자 목록이 남아 새 계정에 보일 수 있는 문제 방지
  void clearCache() {
    subjects.clear();
    maxSubjects.value = 5;
    canAddMore.value = true;
    orderIndex.clear();
    _lastFetched = null;
  }
}

class SubjectItem {
  final int guardianId;
  final int userId;
  final String inviteCode;
  final String alias;
  final String? lastSeen;
  final String status;
  final int alertDaysInactive;
  final String? deviceId;
  final int heartbeatHour;
  final int heartbeatMinute;
  final int? batteryLevel;
  /// 최근 7일 걸음수. index 0 = 6일 전, index 6 = 오늘.
  /// null = 등록 전 날짜 (빈 막대), 0 = heartbeat 없음, >0 = 실제 걸음수.
  final List<int?> weeklySteps;

  const SubjectItem({
    required this.guardianId,
    required this.userId,
    required this.inviteCode,
    required this.alias,
    this.lastSeen,
    required this.status,
    this.alertDaysInactive = 0,
    this.deviceId,
    this.heartbeatHour = 18,
    this.heartbeatMinute = 0,
    this.batteryLevel,
    this.weeklySteps = const [],
  });

  bool get isNormal => status == 'normal';

  SubjectItem copyWith({
    String? alias,
    String? status,
    int? heartbeatHour,
    int? heartbeatMinute,
    List<int?>? weeklySteps,
  }) {
    return SubjectItem(
      guardianId: guardianId,
      userId: userId,
      inviteCode: inviteCode,
      alias: alias ?? this.alias,
      lastSeen: lastSeen,
      status: status ?? this.status,
      alertDaysInactive: alertDaysInactive,
      deviceId: deviceId,
      heartbeatHour: heartbeatHour ?? this.heartbeatHour,
      heartbeatMinute: heartbeatMinute ?? this.heartbeatMinute,
      batteryLevel: batteryLevel,
      weeklySteps: weeklySteps ?? this.weeklySteps,
    );
  }
}
