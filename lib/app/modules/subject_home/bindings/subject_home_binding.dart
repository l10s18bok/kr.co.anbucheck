import 'package:get/get.dart';
import 'package:anbucheck/app/modules/subject_home/controllers/subject_home_controller.dart';

class SubjectHomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubjectHomeController>(
      () => SubjectHomeController(),
    );
  }
}
