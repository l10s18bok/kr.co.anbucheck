import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';
import 'package:anbucheck/app/core/services/fcm_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/core/services/stability_service.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/data/datasources/local/heartbeat_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/heartbeat_lock_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/user_remote_datasource.dart';
import 'package:anbucheck/app/modules/safety_home/controllers/safety_home_base_controller.dart';
import 'package:anbucheck/app/modules/safety_home/controllers/safety_home_role.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 대상자 모드(S) 안전 홈 컨트롤러
///
/// `lastHeartbeatDate/Time`을 자기 Rx로 단독 소유하고, 포그라운드 진입 시
/// `_checkAndSendHeartbeat`로 미전송 heartbeat를 자동 재전송한다.
/// Drawer·탈퇴·S→G+S 전환·휴면 다이얼로그·앱 버전 표시 등 S 전용 기능을 담는다.
class SubjectHomeController extends SafetyHomeBaseController {
  @override
  HomeRole get role => HomeRole.subject;

  // S는 lastHeartbeatDate/Time을 자기 Rx로 단독 소유
  final _lastHeartbeatDate = ''.obs;
  final _lastHeartbeatTime = ''.obs;

  @override
  String get lastHeartbeatDate => _lastHeartbeatDate.value;

  @override
  String get lastHeartbeatTime => _lastHeartbeatTime.value;

  @override
  bool get isReportedToday {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _lastHeartbeatDate.value == today;
  }

  // ── 라이프사이클 hook ─────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _checkHibernationSetting();
  }

  @override
  Future<void> onAfterLoad() async {
    await _checkAndSendHeartbeat();
    await FcmService.consumeSafetyNetDialogIfPending(
        delivered: isReportedToday);
  }

  @override
  Future<void> onResumedRoleSpecific() async {
    await _reloadHeartbeatState();
    await _checkAndSendHeartbeat();
    await FcmService.consumeSafetyNetDialogIfPending(
        delivered: isReportedToday);
  }

  @override
  Future<void> onHeartbeatSent() => _reloadHeartbeatState();

  // ── S 전용 — heartbeat 자동 재전송 ───────────────────────────────

  Future<void> _reloadHeartbeatState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    _lastHeartbeatDate.value = await tokenDs.getLastHeartbeatDate() ?? '';
    _lastHeartbeatTime.value = await tokenDs.getLastHeartbeatTime() ?? '';
  }

  /// 예약시각 경과 + 오늘 미전송이면 heartbeat 자동 전송 (자정 전까지 무조건).
  /// iOS S 모드는 정책상 비활성이지만 코드 호환을 위해 Android 가드만 적용.
  ///
  /// 자정 경계만이 의미 단위 — 자정 넘어가면 `isReportedToday`가 false로 유지되더라도
  /// `isScheduleInFuture`(다음 예약시각 이전)에 막혀 자연스럽게 다음 날로 넘어간다.
  /// 예약시각 +2h 후에 보내도 서버가 미수신 경고를 즉시 해소하므로 보호자 stale 상태
  /// 방지에도 유리. 늦게 보낸 heartbeat 성공 시 `_onHeartbeatSent`가 WorkManager를
  /// 내일자로 재등록해 정시 사이클이 곧바로 정상화된다.
  ///
  /// **첫 설치(전송 이력 없음) 우회**: `lastHeartbeatDate`가 비어있으면 `isScheduleInFuture`
  /// 가드까지 건너뛰고 즉시 전송한다. 이는 동시에 세 가지를 한 번에 해결한다:
  /// (1) Google Fit Local Recording 구독 생성(걸음수 측정 시작) — 21:00 이후
  /// 설치 시 다음날까지 D0 데이터 0이 되는 문제 해소,
  /// (2) 서버 last_seen baseline — 등록 직후~예약시각까지의 공백 제거,
  /// (3) 등록→heartbeat 파이프라인(token/network/권한) 즉시 검증.
  Future<void> _checkAndSendHeartbeat() async {
    if (isReportedToday) return;
    final hasEverSent = lastHeartbeatDate.isNotEmpty;
    if (hasEverSent) {
      if (Platform.isAndroid && isScheduleInFuture) return;
    }
    await _clearStaleScheduledKey();
    // 포그라운드 진입은 화면을 켜고 잠금을 풀어 앱을 연 결과이므로
    // interactive=true가 확정 증거 — 명시 전달.
    await HeartbeatService()
        .execute(manual: false, isInteractiveAtTrigger: true);
    await _reloadHeartbeatState();
  }

  /// WorkManager Worker가 lastScheduledKey를 선점 save한 뒤 Samsung OneUI
  /// Doze/OEM 절전으로 중도 종료되면, lastHeartbeatDate는 비어있고
  /// lastScheduledKey만 남아 2차 안전망(앱 복귀 자동 전송)이 dedup 가드에
  /// 막혀 영구히 차단된다. 포그라운드 진입 시 "오늘 미전송인데 오늘자 키가
  /// 박혀 있는" stale 상태를 감지해 정리한다.
  Future<void> _clearStaleScheduledKey() async {
    final lastKey = await tokenDs.getLastScheduledKey();
    if (lastKey == null || lastKey.isEmpty) return;
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (lastKey.startsWith(today)) {
      debugPrint('[SubjectHome] stale lastScheduledKey 정리 ($lastKey)');
      await tokenDs.clearLastScheduledKey();
    }
  }

  /// 오늘의 안부 확인 메시지 로컬 알림 탭 등으로 이미 스택에 있는 경우 외부에서 호출
  Future<void> refreshAndSend() async {
    await loadScheduleFromLocal();
    await _reloadHeartbeatState();
    await _checkAndSendHeartbeat();
    await FcmService.consumeSafetyNetDialogIfPending(
        delivered: isReportedToday);
  }

  // ── Android 휴면(Auto-Revoke) 안내 다이얼로그 ─────────────────────

  static const _hibernationChannel =
      MethodChannel('anbucheck/hibernation');

  /// 앱이 auto-revoke whitelist에 등록되어 있으면 안내 생략.
  /// 등록되지 않은 경우에만 앱 실행 때마다 계속 안내한다.
  Future<void> _checkHibernationSetting() async {
    if (!Platform.isAndroid) return;

    try {
      final whitelisted = await _hibernationChannel
          .invokeMethod<bool>('isAutoRevokeWhitelisted');
      if (whitelisted == true) return;
    } catch (_) {
      return;
    }

    await Get.dialog<void>(
      AlertDialog(
        title: _buildHibernationTitle(),
        content: Text('permission_hibernation_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('common_later'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await Get.find<StabilityService>().openAutoRevokeSettings();
            },
            child: Text('permission_hibernation_go_to_settings'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// 제목에서 "사용하지 않는 앱 일시 정지"(로케일별 highlight 문구) 부분만 강조 색상 적용
  Widget _buildHibernationTitle() {
    final title = 'permission_hibernation_title'.tr;
    final highlight = 'permission_hibernation_highlight'.tr;
    final idx = title.indexOf(highlight);
    if (idx < 0) return Text(title);
    const highlightStyle = TextStyle(
      color: Color(0xFFB71C1C),
      fontWeight: FontWeight.w700,
    );
    return Text.rich(
      TextSpan(
        children: [
          if (idx > 0) TextSpan(text: title.substring(0, idx)),
          TextSpan(text: highlight, style: highlightStyle),
          if (idx + highlight.length < title.length)
            TextSpan(text: title.substring(idx + highlight.length)),
        ],
      ),
    );
  }

  // ── 앱 버전 (S Drawer 표시용) ─────────────────────────────────────

  final appVersion = ''.obs;

  Future<void> loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = '${info.version} (${info.buildNumber})';
  }

  // ── S → G+S 전환 ──────────────────────────────────────────────────

  /// 대상자 모드 사용자가 보호자 기능을 추가로 활성화.
  /// 서버 role을 guardian으로 전환 + 3개월 무료 체험 구독 생성.
  /// invite_code와 heartbeat 예약은 그대로 유지되므로 기존 S 기능은 끊김 없이
  /// 지속되고, 이후엔 기존 G+S 사용자와 동일한 경로로 동작한다.
  Future<void> switchToGuardian() async {
    final deviceToken = await tokenDs.getDeviceToken();
    if (deviceToken == null) return;
    try {
      final result =
          await UserRemoteDatasource().switchToGuardian(deviceToken);
      await tokenDs.saveUserRole('guardian');
      await tokenDs.saveIsAlsoSubject(true);
      final sub = result['subscription'];
      if (sub is Map && sub['is_active'] == true) {
        await tokenDs.saveSubscriptionActive(true);
      }
      Get.offAllNamed(AppRoutes.guardianDashboard);
    } catch (_) {
      AppSnackbar.show('common_error'.tr, 's_to_gs_switch_failed'.tr,
          position: SnackPosition.TOP);
    }
  }

  // ── 탈퇴 ──────────────────────────────────────────────────────────

  /// 로컬 DB 전반을 클리어해 재가입 시 이전 계정 잔존 데이터가 새 계정에
  /// 오염을 일으키지 않도록 한다 (걸음수 delta 왜곡, pending heartbeat 오전송 등).
  Future<void> deleteAccount() async {
    final deviceToken = await tokenDs.getDeviceToken();
    if (deviceToken != null) {
      try {
        await ApiClientFactory.instance.delete(
          ApiEndpoints.usersMe,
          headers: {'Authorization': 'Bearer $deviceToken'},
        );
      } catch (_) {}
    }
    // **순서 중요 (race 차단)**: clear를 cancel보다 먼저.
    // 워커 isolate가 _rescheduleNextDay에서 SharedPreferences를 reload할 때 role=null을
    // 보고 skip하도록 한다. 반대 순서면 worker가 role='subject'로 읽고 schedule을
    // 재등록하는 race가 생긴다.
    await tokenDs.clear();
    if (Platform.isAndroid) {
      await HeartbeatWorkerService.cancel();
    }
    await LocalAlarmService.cancel();
    await HeartbeatLocalDatasource().clearPending();
    await HeartbeatLockDatasource().clearAll();

    Get.offAllNamed(AppRoutes.modeSelect);
  }
}
