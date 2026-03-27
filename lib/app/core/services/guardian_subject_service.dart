import 'package:get/get.dart';
import 'package:anbucheck/app/data/datasources/local/nickname_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/subject_remote_datasource.dart';

/// 보호자 대상자 목록 공유 서비스
/// Dashboard / ConnectionManagement / Settings 가 공통으로 사용
/// 한 번 로드된 데이터를 공유하여 중복 API 호출 방지
class GuardianSubjectService extends GetxService {
  final _tokenDs = TokenLocalDatasource();
  final _nicknameDs = NicknameLocalDatasource();
  final _subjectDs = SubjectRemoteDatasource();

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

      subjects.value = (data['subjects'] as List<dynamic>? ?? [])
          .map((s) => s as Map<String, dynamic>)
          .map((s) {
        final inviteCode = s['invite_code'] as String? ?? '';
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
          heartbeatHour: s['heartbeat_hour'] as int? ?? 9,
          heartbeatMinute: s['heartbeat_minute'] as int? ?? 30,
        );
      }).toList();

      maxSubjects.value = data['max_subjects'] as int? ?? 5;
      canAddMore.value = data['can_add_more'] as bool? ?? true;
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

  /// 특정 대상자 heartbeat 시각 로컬 업데이트
  void updateSchedule(String inviteCode, int hour, int minute) {
    final idx = subjects.indexWhere((s) => s.inviteCode == inviteCode);
    if (idx == -1) return;
    subjects[idx] =
        subjects[idx].copyWith(heartbeatHour: hour, heartbeatMinute: minute);
  }

  /// 특정 대상자 제거
  void removeByGuardianId(int guardianId) {
    subjects.removeWhere((s) => s.guardianId == guardianId);
    _lastFetched = null; // 다음 로드 시 서버 반영
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

  const SubjectItem({
    required this.guardianId,
    required this.userId,
    required this.inviteCode,
    required this.alias,
    this.lastSeen,
    required this.status,
    this.alertDaysInactive = 0,
    this.deviceId,
    this.heartbeatHour = 9,
    this.heartbeatMinute = 30,
  });

  bool get isNormal => status == 'normal';

  SubjectItem copyWith({
    String? alias,
    String? status,
    int? heartbeatHour,
    int? heartbeatMinute,
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
    );
  }
}
