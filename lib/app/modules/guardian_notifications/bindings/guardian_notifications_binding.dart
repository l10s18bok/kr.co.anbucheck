import 'package:get/get.dart';
import 'package:anbucheck/app/data/datasources/local/nickname_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/notification_remote_datasource.dart';
import 'package:anbucheck/app/data/repositories/notification_repository_impl.dart';
import 'package:anbucheck/app/domain/repositories/notification_repository.dart';
import 'package:anbucheck/app/domain/usecases/delete_all_notifications_usecase.dart';
import 'package:anbucheck/app/domain/usecases/get_notifications_usecase.dart';
import 'package:anbucheck/app/modules/guardian_notifications/controllers/guardian_notifications_controller.dart';

class GuardianNotificationsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TokenLocalDatasource());
    Get.lazyPut(() => NicknameLocalDatasource());
    Get.lazyPut(() => NotificationRemoteDatasource(Get.find()));
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepositoryImpl(Get.find(), Get.find()),
    );
    Get.lazyPut(() => GetNotificationsUseCase(Get.find()));
    Get.lazyPut(() => DeleteAllNotificationsUseCase(Get.find()));
    Get.lazyPut(() => GuardianNotificationsController(Get.find(), Get.find()));
  }
}
