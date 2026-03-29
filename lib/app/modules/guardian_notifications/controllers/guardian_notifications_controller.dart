import 'package:get/get.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/domain/entities/notification_entity.dart';
import 'package:anbucheck/app/domain/usecases/get_notifications_usecase.dart';

export 'package:anbucheck/app/domain/entities/notification_entity.dart'
    show NotificationEntity, AlertLevel;

/// 보호자 알림 목록 컨트롤러 — 당일 서버 알림만 표시
class GuardianNotificationsController extends BaseController {
  final GetNotificationsUseCase _getNotifications;

  GuardianNotificationsController(this._getNotifications);

  final notifications = <NotificationEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      final list = await _getNotifications();
      notifications.value = list;
    } catch (e) {
      notifications.value = [];
    }
  }
}
