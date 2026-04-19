import 'package:get/get.dart';

import 'package:anbucheck/app/modules/guardian_emergency_map/controllers/guardian_emergency_map_controller.dart';

class GuardianEmergencyMapBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GuardianEmergencyMapController>(
      () => GuardianEmergencyMapController(),
    );
  }
}
