import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/core/mixins/heartbeat_schedule_mixin.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/utils/phone_utils.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/emergency_remote_datasource.dart';
import 'package:anbucheck/app/modules/guardian_dashboard/controllers/guardian_dashboard_controller.dart';

/// 보호자 G+S 모드 안전코드 화면 컨트롤러
///
/// UI 전용 — invite_code 표시, heartbeat 스케줄/시각 변경, 수동 보고, 긴급 요청만 담당.
/// heartbeat 자동 재전송(미전송 체크)은 [GuardianDashboardController]가 단독 소유하며,
/// 이 컨트롤러는 보고 상태 표시를 Dashboard의 Rx에서 직접 구독한다.
class GuardianSafetyCodeController extends BaseController with HeartbeatScheduleMixin {
  final _inviteCode = ''.obs;
  String get inviteCode => _inviteCode.value;

  final _guardianConnected = false.obs;
  bool get isGuardianConnected => _guardianConnected.value;

  final _guardianCount = 0.obs;
  int get guardianCount => _guardianCount.value;

  /// Dashboard 컨트롤러는 Dashboard/Settings 바인딩에서 permanent:true로 등록되어 있어
  /// 안전코드 페이지 진입 시점에는 반드시 존재한다.
  GuardianDashboardController get _dashboard =>
      Get.find<GuardianDashboardController>();

  bool get isReportedToday => _dashboard.isReportedToday;

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
        final date = _dashboard.lastHeartbeatDate;
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
        final raw = _dashboard.lastHeartbeatTime.isNotEmpty
            ? _dashboard.lastHeartbeatTime
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

  // ── Lazy Permission: 걸음수(신체 활동/모션) 권한 상태 ──
  /// 권한이 거부된 상태인지 여부 — 안전코드 화면 경고 위젯이 구독
  final activityPermissionDenied = false.obs;

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
    _loadStatus();
    refreshActivityPermissionStatus();
    // iOS 재설치/최초 진입 케이스: 권한 상태가 notDetermined면 안전코드 화면
    // 첫 진입 시 자동으로 시스템 팝업을 띄운다. 한 번 거부된 상태(isPermanentlyDenied)
    // 에서는 permission_handler가 request() 호출해도 OS가 팝업을 띄우지 않으므로
    // 실질적으로 notDetermined에서만 동작한다.
    _autoRequestSensorPermissionIOSIfNeeded();
  }

  @override
  void onResumed() {
    super.onResumed();
    loadScheduleFromLocal();
    // 앱 설정에서 권한을 허용하고 복귀한 경우 즉시 경고 위젯 숨기기
    refreshActivityPermissionStatus();
  }

  /// 걸음수 권한 상태 확인 — 안전코드 화면 진입/복귀 시 호출
  /// Android: `Permission.activityRecognition.status` (ACTIVITY_RECOGNITION)
  /// iOS: `Permission.sensors.status` (CMMotionActivityManager, Podfile에
  ///   PERMISSION_SENSORS=1 매크로 활성화 필요)
  ///   ※ Pedometer 스트림은 움직임이 없으면 이벤트를 emit하지 않아 권한 판정에
  ///      부적절 (타임아웃 → 오판정). 시스템 권한 상태를 직접 조회한다.
  Future<void> refreshActivityPermissionStatus() async {
    try {
      final status = Platform.isAndroid
          ? await Permission.activityRecognition.status
          : await Permission.sensors.status;
      activityPermissionDenied.value = !status.isGranted;
    } catch (_) {
      // 권한 체크 실패 시 경고를 띄우지 않는다 — 사용자 혼란 방지
    }
  }

  /// 경고 텍스트 탭 시 권한 재요청
  /// Android: 일반 거부면 재요청, 영구 거부면 설정 이동
  /// iOS: permission_handler가 CMAuthorizationStatus를 다음과 같이 매핑함:
  ///   notDetermined → isDenied, 실제 유저 거부 → isPermanentlyDenied.
  ///   notDetermined일 때는 request()가 내부에서 CMMotionActivityManager.
  ///   queryActivityStartingFromDate:를 호출해 시스템 팝업을 띄우고, 실제 거부
  ///   상태에서는 OS가 팝업을 막으므로 설정 이동만 가능하다.
  Future<void> requestActivityPermissionAgain() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.activityRecognition.status;
        if (status.isPermanentlyDenied) {
          await _showSettingsDialog();
        } else {
          await Permission.activityRecognition.request();
        }
      } else if (Platform.isIOS) {
        final status = await Permission.sensors.status;
        if (status.isPermanentlyDenied || status.isRestricted) {
          // 실제 유저 거부 또는 제한 — 시스템 팝업 불가, 설정 이동만 가능
          await _showSettingsDialog();
        } else if (status.isDenied) {
          // notDetermined — permission_handler가 queryActivity 호출해 시스템 팝업 표시
          await Permission.sensors.request();
        }
      }
    } finally {
      await refreshActivityPermissionStatus();
    }
  }

  /// iOS 자동 권한 요청 — 재설치/최초 진입 케이스에서 notDetermined 상태라면
  /// 안전코드 화면 첫 진입 시 시스템 팝업을 자동으로 띄운다.
  /// 한 번 거부된 상태(isPermanentlyDenied)에서는 OS가 팝업을 막으므로
  /// 아무 동작도 하지 않는다. isGranted인 경우도 호출되지 않는다.
  Future<void> _autoRequestSensorPermissionIOSIfNeeded() async {
    if (!Platform.isIOS) return;
    try {
      final status = await Permission.sensors.status;
      if (status.isDenied) {
        // notDetermined 상태만 해당 — request()가 시스템 팝업 트리거
        await Permission.sensors.request();
        await refreshActivityPermissionStatus();
      }
    } catch (_) {
      // 권한 조회 실패 시 조용히 무시 — 사용자가 경고 텍스트를 탭하면 수동 경로로 동작
    }
  }

  Future<void> _showSettingsDialog() async {
    // 다이얼로그 결과를 먼저 받고 → 완전히 닫힌 후 openAppSettings 호출.
    // 기존 `Get.back(); openAppSettings();` 순서는 openAppSettings 호출 시점에
    // 앱이 백그라운드 전환되며 pop이 반영되지 못해 복귀 시 다이얼로그가 남았음.
    final goToSettings = await Get.dialog<bool>(
      AlertDialog(
        title: Text('gs_activity_permission_settings_title'.tr,
            style: AppTextTheme.headlineSmall(fw: FontWeight.w700)),
        content: Text('gs_activity_permission_settings_body'.tr,
            style: AppTextTheme.bodyMedium()),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('gs_activity_permission_settings_go'.tr),
          ),
        ],
      ),
    );
    if (goToSettings == true) {
      await openAppSettings();
    }
  }

  Future<void> _loadStatus() async {
    await getReloadedPrefs();
    // arguments로 전달받은 invite_code 우선 사용 — Dashboard가 방금 발급받은
    // code를 즉시 반영할 수 있도록 하고, SharedPreferences reload 타이밍 이슈를 우회.
    final cached = _deviceData;
    final cachedCode = cached?['invite_code'] as String?;
    if (cachedCode != null && cachedCode.isNotEmpty) {
      _inviteCode.value = cachedCode;
    } else {
      _inviteCode.value = await _tokenDs.getInviteCode() ?? '';
    }
    _guardianConnected.value = await _tokenDs.getSubscriptionActive();
    await loadScheduleFromLocal();
    await _syncScheduleFromServer();
  }

  /// Pull-to-refresh: arguments 캐시 무시하고 서버에서 강제 동기화
  Future<void> pullToRefresh() async {
    await getReloadedPrefs();
    _inviteCode.value = await _tokenDs.getInviteCode() ?? '';
    _guardianConnected.value = await _tokenDs.getSubscriptionActive();
    await loadScheduleFromLocal();
    await _syncScheduleFromServer(forceRemote: true);
  }

  /// G+S 모드: 설정 페이지에서 이미 받은 데이터 사용 (중복 API 호출 방지)
  /// 오늘의 안부 확인 메시지 로컬 알림 탭 진입 등 캐시 없는 경우만 서버 호출
  Future<void> _syncScheduleFromServer({bool forceRemote = false}) async {
    final cached = forceRemote ? null : _deviceData;
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
      if (GetPlatform.isAndroid) {
        await HeartbeatWorkerService.schedule(hour, minute);
      }
      // LocalAlarm 재예약은 HeartbeatService가 전송 성공/실패 시 전담 — 여기서는 중복 호출 금지
    } catch (_) {
      // 실패 시 로컬 저장값 유지
    }
  }

  void copyInviteCode() {
    Clipboard.setData(ClipboardData(text: _inviteCode.value));
    AppSnackbar.message('subject_home_code_copied'.tr);
  }

  void shareInviteCode() {
    SharePlus.instance.share(
      ShareParams(
        text: 'subject_home_share_text'.trParams({'code': _inviteCode.value}),
        subject: 'subject_home_share_subject'.tr,
      ),
    );
  }

  final _isReporting = false.obs;
  bool get isReporting => _isReporting.value;

  /// 안전 보고 버튼: heartbeat 즉시 전송 후 전화 다이얼러 열기
  /// 하루 1회 제한 — 동일 날짜 재시도 시 안내 메시지 표시 후 차단
  Future<void> reportNow() async {
    if (_isReporting.value) return;

    final today = formatYmd(DateTime.now());
    final lastManualDate = await _tokenDs.getLastManualReportDate();
    if (lastManualDate == today) {
      AppSnackbar.message('subject_home_manual_report_limit_reached'.tr);
      return;
    }

    _isReporting.value = true;
    try {
      await HeartbeatService().execute(manual: true);
      await _tokenDs.saveLastManualReportDate(today);
      // Dashboard Rx를 갱신해 카드 표시를 즉시 reported 상태로 전환
      await _dashboard.reloadHeartbeatState();
    } finally {
      _isReporting.value = false;
    }
    await PhoneUtils.pickContactAndCall();
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
      AppSnackbar.message('subject_home_emergency_sent'.tr);
    } catch (_) {
      AppSnackbar.message('subject_home_emergency_failed'.tr);
    } finally {
      _isSendingEmergency.value = false;
    }
  }
}
