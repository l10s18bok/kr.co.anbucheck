import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/services/fcm_service.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/device_remote_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/user_remote_datasource.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/modules/safety_home/controllers/safety_home_role.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 온보딩 스텝에서 보여줄 화면 목업 종류 — onboarding_mockups.dart의 위젯과 1:1 대응.
enum OnboardingVisual {
  safetyCode,
  emergencyButton,
  gsSwitch,
  addSubject,
  gsEnable,
  notifications,
}

/// 온보딩 각 스텝의 문구·목업 키 — 실제 앱 화면(안전코드/긴급버튼/대상자연결 등)을
/// 그대로 설명하는 콘텐츠 단위. 대상자/보호자 모드가 일부 스텝을 공유한다
/// (보호자 3·4번째 스텝 = 대상자 1·2번째 스텝과 동일 콘텐츠 재사용).
class OnboardingStepData {
  final String titleKey;
  final String descKey;
  final OnboardingVisual visual;

  const OnboardingStepData({
    required this.titleKey,
    required this.descKey,
    required this.visual,
  });
}

/// 온보딩 컨트롤러 (공통)
/// 서비스 소개 후 사용자 등록(API) → 모드별 홈으로 이동
class OnboardingController extends BaseController {
  final pageController = PageController();
  final _currentPage = 0.obs;
  int get currentPage => _currentPage.value;

  late final String mode;
  late final List<OnboardingStepData> steps;

  int get totalPages => steps.length;

  // 대상자: safety_home에서 자동 생성되는 안전코드를 보호자에게 공유
  static const _safetyCode = OnboardingStepData(
    titleKey: 'onboarding_safety_code_title',
    descKey: 'onboarding_safety_code_desc',
    visual: OnboardingVisual.safetyCode,
  );

  // 대상자: "도움이 필요해요" 긴급 버튼
  static const _emergency = OnboardingStepData(
    titleKey: 'onboarding_emergency_title',
    descKey: 'onboarding_emergency_desc',
    visual: OnboardingVisual.emergencyButton,
  );

  // 대상자: Drawer의 "가족 안부도 관리하기" → S+G 전환
  static const _gsSwitch = OnboardingStepData(
    titleKey: 'onboarding_gs_switch_title',
    descKey: 'onboarding_gs_switch_desc',
    visual: OnboardingVisual.gsSwitch,
  );

  // 보호자: 대상자 추가 화면 (고유 코드 + 별칭 입력)
  static const _addSubject = OnboardingStepData(
    titleKey: 'onboarding_add_subject_title',
    descKey: 'onboarding_add_subject_desc',
    visual: OnboardingVisual.addSubject,
  );

  // 보호자: 설정의 "나도 안부 보호 받기" → G+S 활성화
  static const _gsEnable = OnboardingStepData(
    titleKey: 'onboarding_gs_enable_title',
    descKey: 'onboarding_gs_enable_desc',
    visual: OnboardingVisual.gsEnable,
  );

  // 보호자: 알림 목록 화면 (주의 등급 카드 + 걸음수 활동 정보 카드)
  static const _notifications = OnboardingStepData(
    titleKey: 'onboarding_notifications_title',
    descKey: 'onboarding_notifications_desc',
    visual: OnboardingVisual.notifications,
  );

  static const _subjectSteps = [_safetyCode, _emergency, _gsSwitch];
  static const _guardianSteps = [
    _addSubject,
    _notifications,
    _gsEnable,
    // G+S 활성화 시 대상자와 동일하게 안전코드·긴급 버튼을 쓰게 되므로 재사용
    _safetyCode,
    _emergency,
  ];

  final _tokenDs = TokenLocalDatasource();
  final _userDs = UserRemoteDatasource();

  @override
  void onInit() {
    super.onInit();
    mode = (Get.arguments as Map<String, dynamic>?)?['mode'] ?? 'subject';
    steps = mode == 'guardian' ? _guardianSteps : _subjectSteps;
  }

  void onPageChanged(int page) {
    _currentPage.value = page;
  }

  void nextPage() {
    if (_currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  /// 온보딩 완료 → 서버 사용자 등록 → 로컬 저장 → 홈 이동
  Future<void> completeOnboarding() async {
    // 재진입 가드: [시작하기] 더블탭 시 POST /users가 두 번 발사되어
    // 서버가 device_token을 회전시키면서 첫 토큰이 즉시 무효화되는 이슈 방지
    if (isLoading) return;
    isLoading = true;
    try {
      final deviceId = await _tokenDs.getOrCreateDeviceId();
      final fcmToken = Get.find<FcmService>().token ?? '';
      final platform = Platform.isIOS ? 'ios' : 'android';
      final osVersion = await _getOsVersion();

      // 최초 설치 판별 — register 직전 checkDevice. 서버에 device_id가 없으면 첫 설치.
      // (register 후엔 device가 생성돼 구분 불가하므로 반드시 전에 조회. 재설치는 제외)
      final check = await _userDs.checkDevice(deviceId);
      final isFirstInstall = !((check['exists'] as bool?) ?? false);

      final response = await _userDs.register(
        role: mode,
        deviceId: deviceId,
        fcmToken: fcmToken,
        platform: platform,
        osVersion: osVersion,
      );

      await _saveAndNavigate(response, mode, isFirstInstall: isFirstInstall);
    } catch (e) {
      AppSnackbar.show(
        'onboarding_registration_failed_title'.tr,
        'onboarding_registration_failed_message'.tr,
      );
    } finally {
      isLoading = false;
    }
  }

  Future<void> _saveAndNavigate(Map<String, dynamic> response, String role,
      {bool isFirstInstall = false}) async {
    await _tokenDs.saveDeviceToken(response['device_token'] as String);
    await _tokenDs.saveUserId(response['user_id'] as int);
    await _tokenDs.saveUserRole(role);

    // invite_code가 있으면 저장 (대상자 또는 G+S 재설치 복원)
    if (response['invite_code'] != null) {
      await _tokenDs.saveInviteCode(response['invite_code'] as String);
      if (role == 'guardian') {
        // G+S 복원: 대상자 기능 활성화 (WorkManager/LocalAlarm은 대시보드 진입 시 처리)
        await _tokenDs.saveIsAlsoSubject(true);
      }
    }

    // 등록 완료 후 FCM 토큰 서버 갱신 (등록 시 토큰이 아직 미발급이었을 수 있음)
    try {
      final fcm = Get.find<FcmService>();
      if (fcm.token != null) {
        await DeviceRemoteDatasource().updateFcmToken(
          response['device_token'] as String,
          fcm.token!,
        );
      }
    } catch (_) {}

    if (role == 'subject') {
      Get.offNamed(AppRoutes.safetyHome,
          arguments: {'role': HomeRole.subject});
    } else {
      // 최초 설치 보호자: 무료체험 종료(가입 +90일)에 1회 로컬 알림 예약.
      // POST /users 응답엔 expires_at이 없으므로 서버 FREE_TRIAL_DAYS(90)와 동일하게
      // 로컬에서 계산한다(서버 값과 수 초 내 일치). ⚠️ 서버 FREE_TRIAL_DAYS 변경 시 이 90도 갱신.
      // ScheduledNotificationBootReceiver가 매니페스트에 있어 재부팅에도 복원됨.
      // 구독하면 cancelTrialEnded로 취소. 재설치(isFirstInstall=false)는 예약 안 함.
      // 무료체험은 보호자 전용이라 subject 분기에는 두지 않는다.
      if (isFirstInstall) {
        try {
          await LocalAlarmService.scheduleTrialEnded(
            DateTime.now().add(const Duration(days: 90)),
            title: 'trial_ended_noti_title'.tr,
            body: 'trial_ended_noti_body'.tr,
          );
        } catch (e) {
          debugPrint('[onboarding] 체험 종료 알림 예약 실패(무시): $e');
        }
      }
      Get.offNamed(AppRoutes.guardianDashboard);
    }
  }

  Future<String> _getOsVersion() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return 'Android ${android.version.release}';
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return 'iOS ${ios.systemVersion}';
    }
    return '';
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
