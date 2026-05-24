import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/core/services/iap_service.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/data/datasources/local/heartbeat_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/heartbeat_lock_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/nickname_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/subject_order_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/user_remote_datasource.dart';
import 'package:anbucheck/app/modules/guardian_dashboard/controllers/guardian_dashboard_controller.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 보호자 설정 컨트롤러 — 설정 페이지 UI 전용.
/// heartbeat 전송/예약, G+S 라이프사이클은 [GuardianDashboardController]가 단독 소유한다.
class GuardianSettingsController extends BaseController {
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
  final subscriptionDaysRemaining = (-1).obs; // -1: 미조회, 0+: 남은 일수

  @override
  void onInit() {
    super.onInit();
    _svc.load();
    _loadAppVersion();
    _loadOsVersion();
    _loadSubscription();

    // 인앱 결제 검증 성공 시 구독 상태 즉시 리프레시 (광고 제거·만료 배너 제거 반영).
    // IapService는 Splash에서 permanent로 등록되므로 항상 존재.
    if (Get.isRegistered<IapService>()) {
      final iap = Get.find<IapService>();
      iap.onVerified = (_) => _loadSubscription();

      // 에러/정보 메시지가 채워지면 스낵바 1회 표시 후 비움.
      // View(Obx) 안 addPostFrameCallback + 상태 재설정 패턴은 self-rebuild를
      // 트리거해 fragile하므로 컨트롤러에서 ever 워커로 처리. dispose는 BaseController
      // onClose에서 자동 정리.
      ever<String>(iap.lastError, (msg) {
        if (msg.isEmpty) return;
        AppSnackbar.show('common_notice'.tr, msg.tr, type: SnackType.error);
        iap.lastError.value = '';
      });
      ever<String>(iap.lastInfo, (msg) {
        if (msg.isEmpty) return;
        AppSnackbar.show('common_notice'.tr, msg.tr, type: SnackType.info);
        iap.lastInfo.value = '';
      });
    }
  }

  @override
  void onClose() {
    if (Get.isRegistered<IapService>()) {
      Get.find<IapService>().onVerified = null;
    }
    super.onClose();
  }

  /// UI에서 [구독하기] 버튼 탭 → buy() 호출.
  Future<void> startSubscribe() async {
    if (!Get.isRegistered<IapService>()) return;
    await Get.find<IapService>().buy();
  }

  /// UI에서 [구독 복원] 버튼 탭 → restore() 호출.
  Future<void> restoreSubscription() async {
    if (!Get.isRegistered<IapService>()) return;
    await Get.find<IapService>().restore();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = '${info.version} (${info.buildNumber})';
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

  Future<void> _loadSubscription() async {
    // 1) 로컬 캐시로 즉시 hydrate — 서버 응답 도착 전 카드가 회색 기본값으로
    //    잠깐 표시됐다가 인디고로 바뀌는 깜빡임 방지. SharedPreferences는
    //    수 ms 내 반환되므로 첫 build 이전에 Rx가 최신 plan으로 set됨.
    final cachedActive = await _tokenDs.getSubscriptionActive();
    final cachedPlan = await _tokenDs.getSubscriptionPlan();
    isSubscriptionActive.value = cachedActive;
    if (cachedPlan.isNotEmpty) subscriptionPlan.value = cachedPlan;

    final deviceToken = await _tokenDs.getDeviceToken();
    if (deviceToken == null) return;

    // 2) 백그라운드로 서버 최신 상태 fetch
    try {
      final deviceDs = DeviceRemoteDatasource();
      final data = await deviceDs.getMyDevice(deviceToken);
      final active = data['subscription_active'] as bool? ?? false;
      final plan = data['subscription_plan'] as String? ?? '';
      isSubscriptionActive.value = active;
      subscriptionPlan.value = plan;
      await _tokenDs.saveSubscriptionActive(active);
      await _tokenDs.saveSubscriptionPlan(plan);

      // 3) Dashboard 만료 배너 즉시 동기화 — 탭 전환만으로는 Dashboard의
      //    onResumed/onInit가 트리거되지 않아 isSubscriptionActive가 stale.
      if (Get.isRegistered<GuardianDashboardController>()) {
        await Get.find<GuardianDashboardController>().refreshSubscriptionStatus();
      }

      // 보호자 구독 남은 일수 조회 (보호자만 엔드포인트 접근 가능)
      try {
        final sub = await deviceDs.getSubscription(deviceToken);
        final days = sub['days_remaining'] as int?;
        if (days != null) subscriptionDaysRemaining.value = days;
      } catch (_) {
        // 대상자이거나 구독 정보 없음 — 무시
      }
    } catch (_) {
      // 서버 실패 시 캐시값 유지 (이미 1단계에서 set됨)
    }
  }

  // ── 네비게이션 ──

  void goToConnectionManagement() {
    Get.toNamed(AppRoutes.guardianConnectionManagement);
  }

  void goToNotificationSettings() {
    Get.toNamed(AppRoutes.guardianNotificationSettings, arguments: 3);
  }

  /// 계정 탈퇴 — heartbeat 예약 정리는 Dashboard 컨트롤러에 위임.
  /// 로컬 DB 전반을 클리어해 재가입 시 이전 계정 잔존 데이터가 새 계정에
  /// 오염을 일으키지 않도록 한다 (구독 상태 오표시, 걸음수 delta 왜곡,
  /// pending heartbeat 오전송, 이전 별칭 잔존 등).
  ///
  /// **navigation 보장**: 중간 cleanup 어느 한 단계가 silent throw/hang되면
  /// Get.offAllNamed가 실행되지 않아 사용자가 설정 페이지에 갇히는 사례가
  /// 발생함(예: HeartbeatLockDatasource sqlite 일시 오류, WorkManager cancel
  /// platform exception 등). try/finally + 각 단계 개별 catch로 어떤 실패에도
  /// 모드 선택 화면 진입이 보장되도록 한다. 서버 탈퇴와 로컬 token clear는
  /// 이미 완료된 상태이므로 일부 cleanup이 누락되어도 splash가 재진입 시점에
  /// 자연 복구한다.
  Future<void> deleteAccount() async {
    try {
      final deviceToken = await _tokenDs.getDeviceToken();
      if (deviceToken != null) {
        try {
          await _userDs.deleteMe(deviceToken);
        } catch (_) {}
      }

      // **순서 중요 (race 차단)**: clear를 cancel보다 먼저. 워커 isolate의 _rescheduleNextDay
      // 가 reload 후 role=null을 보고 skip하도록.
      try {
        await _tokenDs.clear();
      } catch (_) {}

      if (Get.isRegistered<GuardianDashboardController>()) {
        try {
          final dashboard = Get.find<GuardianDashboardController>();
          await dashboard.cancelHeartbeatSchedules();
          // permanent 등록이라 offAllNamed 이후에도 인스턴스가 살아있으므로,
          // 재가입 시 이전 G+S Rx 상태(isAlsoSubject=true 등)가 남지 않도록 리셋
          dashboard.resetSubjectState();
        } catch (_) {}
      }

      try { await HeartbeatLocalDatasource().clearPending(); } catch (_) {}
      try { await HeartbeatLockDatasource().clearAll(); } catch (_) {}
      try { await NicknameLocalDatasource().clearAll(); } catch (_) {}
      try { await SubjectOrderLocalDatasource().clearAll(); } catch (_) {}

      // 서비스 인메모리 캐시도 초기화 — permanent 등록이라 컨트롤러 해제되어도 유지됨
      try { _svc.clearCache(); } catch (_) {}
    } finally {
      Get.offAllNamed(AppRoutes.modeSelect);
    }
  }
}
