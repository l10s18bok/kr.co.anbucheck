import 'package:get/get.dart';
import 'package:anbucheck/app/modules/guardian_add_subject/controllers/guardian_add_subject_controller.dart';

class GuardianAddSubjectBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GuardianAddSubjectController>(
      () => GuardianAddSubjectController(),
    );
  }
}
