import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/services/guardian_subject_service.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 보호자 설정 컨트롤러
/// PRD: 프로필, 연결 관리, 구독, 알림 설정, 앱 정보
class GuardianSettingsController extends BaseController {
  final _svc = Get.find<GuardianSubjectService>();

  /// Obx에서 직접 추적 가능하도록 서비스의 observable 노출
  RxList<SubjectItem> get subjects => _svc.subjects;
  RxInt get maxSubjects => _svc.maxSubjects;

  final appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _svc.load();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = '${info.version} (${info.buildNumber})';
  }

  void goToConnectionManagement() {
    Get.toNamed(AppRoutes.guardianConnectionManagement);
  }

  void goToNotificationSettings() {
    Get.toNamed(AppRoutes.guardianNotificationSettings, arguments: 3);
  }
}
