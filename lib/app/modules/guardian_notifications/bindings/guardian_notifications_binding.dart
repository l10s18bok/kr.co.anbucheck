import 'package:get/get.dart';
import 'package:anbucheck/app/data/datasources/local/nickname_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/notification_local_datasource.dart';
import 'package:anbucheck/app/data/repositories/notification_repository_impl.dart';
import 'package:anbucheck/app/domain/repositories/notification_repository.dart';
import 'package:anbucheck/app/domain/usecases/cleanup_notifications_usecase.dart';
import 'package:anbucheck/app/domain/usecases/get_notifications_usecase.dart';
import 'package:anbucheck/app/domain/usecases/mark_notification_read_usecase.dart';
import 'package:anbucheck/app/domain/usecases/reset_all_notifications_read_usecase.dart';
import 'package:anbucheck/app/modules/guardian_notifications/controllers/guardian_notifications_controller.dart';

class GuardianNotificationsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationLocalDatasource());
    Get.lazyPut(() => NicknameLocalDatasource());
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepositoryImpl(Get.find(), Get.find()),
    );
    Get.lazyPut(() => GetNotificationsUseCase(Get.find()));
    Get.lazyPut(() => CleanupNotificationsUseCase(Get.find()));
    Get.lazyPut(() => MarkNotificationReadUseCase(Get.find()));
    Get.lazyPut(() => ResetAllNotificationsReadUseCase(Get.find()));
    Get.lazyPut(() => GuardianNotificationsController(
          Get.find(),
          Get.find(),
          Get.find(),
          Get.find(),
        ));
  }
}
