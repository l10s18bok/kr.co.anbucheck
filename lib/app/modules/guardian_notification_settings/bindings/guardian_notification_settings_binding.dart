import 'package:get/get.dart';
import 'package:anbucheck/app/modules/guardian_notification_settings/controllers/guardian_notification_settings_controller.dart';

class GuardianNotificationSettingsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GuardianNotificationSettingsController>(
      () => GuardianNotificationSettingsController(),
    );
  }
}
