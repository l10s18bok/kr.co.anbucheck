import 'package:get/get.dart';
import 'package:anbucheck/app/modules/splash/bindings/splash_binding.dart';
import 'package:anbucheck/app/modules/splash/views/splash_page.dart';
import 'package:anbucheck/app/modules/permission/bindings/permission_binding.dart';
import 'package:anbucheck/app/modules/permission/views/permission_page.dart';
import 'package:anbucheck/app/modules/mode_select/bindings/mode_select_binding.dart';
import 'package:anbucheck/app/modules/mode_select/views/mode_select_page.dart';
import 'package:anbucheck/app/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:anbucheck/app/modules/onboarding/views/onboarding_page.dart';
import 'package:anbucheck/app/modules/subject_home/bindings/subject_home_binding.dart';
import 'package:anbucheck/app/modules/subject_home/views/subject_home_page.dart';
import 'package:anbucheck/app/modules/guardian_dashboard/bindings/guardian_dashboard_binding.dart';
import 'package:anbucheck/app/modules/guardian_dashboard/views/guardian_dashboard_page.dart';
import 'package:anbucheck/app/modules/guardian_add_subject/bindings/guardian_add_subject_binding.dart';
import 'package:anbucheck/app/modules/guardian_add_subject/views/guardian_add_subject_page.dart';
import 'package:anbucheck/app/modules/guardian_notifications/bindings/guardian_notifications_binding.dart';
import 'package:anbucheck/app/modules/guardian_notifications/views/guardian_notifications_page.dart';
import 'package:anbucheck/app/modules/guardian_notification_settings/bindings/guardian_notification_settings_binding.dart';
import 'package:anbucheck/app/modules/guardian_notification_settings/views/guardian_notification_settings_page.dart';
import 'package:anbucheck/app/modules/guardian_settings/bindings/guardian_settings_binding.dart';
import 'package:anbucheck/app/modules/guardian_settings/views/guardian_settings_page.dart';
import 'package:anbucheck/app/modules/guardian_connection_management/bindings/guardian_connection_management_binding.dart';
import 'package:anbucheck/app/modules/guardian_connection_management/views/guardian_connection_management_page.dart';
import 'package:anbucheck/app/modules/guardian_safety_code/bindings/guardian_safety_code_binding.dart';
import 'package:anbucheck/app/modules/guardian_safety_code/views/guardian_safety_code_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
      transition: Transition.noTransition,
      transitionDuration: const Duration(seconds: 0),
    ),
    GetPage(
      name: AppRoutes.permission,
      page: () => const PermissionPage(),
      binding: PermissionBinding(),
    ),
    GetPage(
      name: AppRoutes.modeSelect,
      page: () => const ModeSelectPage(),
      binding: ModeSelectBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.subjectHome,
      page: () => const SubjectHomePage(),
      binding: SubjectHomeBinding(),
    ),
    GetPage(
      name: AppRoutes.guardianDashboard,
      page: () => const GuardianDashboardPage(),
      binding: GuardianDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.guardianAddSubject,
      page: () => const GuardianAddSubjectPage(),
      binding: GuardianAddSubjectBinding(),
    ),
    GetPage(
      name: AppRoutes.guardianNotifications,
      page: () => const GuardianNotificationsPage(),
      binding: GuardianNotificationsBinding(),
    ),
    GetPage(
      name: AppRoutes.guardianNotificationSettings,
      page: () => const GuardianNotificationSettingsPage(),
      binding: GuardianNotificationSettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.guardianSettings,
      page: () => const GuardianSettingsPage(),
      binding: GuardianSettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.guardianConnectionManagement,
      page: () => const GuardianConnectionManagementPage(),
      binding: GuardianConnectionManagementBinding(),
    ),
    GetPage(
      name: AppRoutes.guardianSafetyCode,
      page: () => const GuardianSafetyCodePage(),
      binding: GuardianSafetyCodeBinding(),
    ),
  ];
}
