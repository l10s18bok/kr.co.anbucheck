import 'package:get/get.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/domain/entities/notification_entity.dart';
import 'package:anbucheck/app/domain/usecases/delete_all_notifications_usecase.dart';
import 'package:anbucheck/app/domain/usecases/get_notifications_usecase.dart';

export 'package:anbucheck/app/domain/entities/notification_entity.dart'
    show NotificationEntity, AlertLevel;

/// 보호자 알림 목록 컨트롤러 — 당일 서버 알림만 표시
class GuardianNotificationsController extends BaseController {
  final GetNotificationsUseCase _getNotifications;
  final DeleteAllNotificationsUseCase _deleteAllNotifications;

  GuardianNotificationsController(
      this._getNotifications, this._deleteAllNotifications);

  final notifications = <NotificationEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (isLoading) return;
    isLoading = true;
    try {
      final list = await _getNotifications();
      if (isClosed) return;
      notifications.value = list
        ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    } catch (e) {
      if (isClosed) return;
      notifications.value = [];
    } finally {
      if (!isClosed) isLoading = false;
    }
  }

  Future<void> deleteAll() async {
    if (isLoading || notifications.isEmpty) return;
    isLoading = true;
    try {
      await _deleteAllNotifications();
      if (isClosed) return;
      notifications.clear();
    } catch (_) {
      if (isClosed) return;
      Get.snackbar('common_error'.tr, 'notifications_delete_failed'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (!isClosed) isLoading = false;
    }
  }
}
