import 'package:get/get.dart';
import 'package:anbucheck/app/modules/onboarding/controllers/onboarding_controller.dart';

class OnboardingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(),
    );
  }
}
