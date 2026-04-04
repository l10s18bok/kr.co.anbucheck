import 'package:get/get.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 보호자 대시보드 컨트롤러
/// PRD 7.6: 대상자 목록, 상태 모니터링, 알림 레벨 표시
class GuardianDashboardController extends BaseController {
  final subjects = <SubjectStatus>[].obs;

  /// 현재 카드 슬라이드 인덱스
  final currentCardIndex = 0.obs;

  /// 전화 후 앱 복귀 시 강조할 대상자 코드
  final highlightedInviteCode = RxnString();

  /// 구독 활성 여부
  final isSubscriptionActive = true.obs;

  final _svc = Get.find<GuardianSubjectService>();
  final _tokenDs = TokenLocalDatasource();

  @override
  void onInit() {
    super.onInit();
    // subjects 데이터 변경 시 자동 반영 (FCM 수신 후 서비스 갱신 포함)
    ever(_svc.subjects, (_) => _mapSubjects());
    _loadSubjects();
    _loadSubscriptionStatus();
  }

  /// 앱이 포그라운드로 복귀 — 강제 갱신
  @override
  void onResumed() {
    super.onResumed();
    _loadSubjects(force: true);
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    isSubscriptionActive.value = await _tokenDs.getSubscriptionActive();
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
      Get.snackbar('오류', '보호 대상자 목록을 불러오지 못했습니다.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading = false;
    }
  }

  /// _svc.subjects → subjects 매핑 (ever 콜백 및 직접 호출 공용)
  void _mapSubjects() {
    subjects.value = _svc.subjects.map((s) => SubjectStatus(
          guardianId: s.guardianId,
          inviteCode: s.inviteCode,
          alias: s.alias,
          alertLevel: s.status,
          lastCheck: _formatLastSeen(s.lastSeen),
          daysInactive: s.alertDaysInactive,
          batteryLevel: s.batteryLevel,
        )).toList();
  }

  String _formatLastSeen(String? lastSeen) {
    if (lastSeen == null) return '확인 기록 없음';
    final dt = DateTime.tryParse(lastSeen);
    if (dt == null) return '확인 기록 없음';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '마지막 확인: 방금 전';
    if (diff.inHours < 1) return '마지막 확인: ${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '마지막 확인: ${diff.inHours}시간 전';
    return '마지막 확인: ${diff.inDays}일 전';
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
      Get.snackbar('오류', '경고 해제에 실패했습니다.',
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
    if (isNormal) return '활동량: 안정적임';
    if (!isNormal) return '안전 확인이 필요합니다';
    return '';
  }
}
