import 'package:get/get.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/domain/entities/notification_entity.dart';
import 'package:anbucheck/app/domain/usecases/cleanup_notifications_usecase.dart';
import 'package:anbucheck/app/domain/usecases/get_notifications_usecase.dart';
import 'package:anbucheck/app/domain/usecases/mark_notification_read_usecase.dart';
import 'package:anbucheck/app/domain/usecases/reset_all_notifications_read_usecase.dart';


export 'package:anbucheck/app/domain/entities/notification_entity.dart'
    show NotificationEntity, AlertLevel;

/// 보호자 알림 목록 컨트롤러
class GuardianNotificationsController extends BaseController {
  final GetNotificationsUseCase _getNotifications;
  final CleanupNotificationsUseCase _cleanup;
  final MarkNotificationReadUseCase _markAsRead;
  final ResetAllNotificationsReadUseCase _resetAllRead;

  GuardianNotificationsController(
    this._getNotifications,
    this._cleanup,
    this._markAsRead,
    this._resetAllRead,
  );

  final _todayNotifications = <NotificationEntity>[].obs;
  final _pastNotifications = <NotificationEntity>[].obs;
  final isAllRead = false.obs;

  List<NotificationEntity> get todayNotifications => _todayNotifications;
  List<NotificationEntity> get pastNotifications => _pastNotifications;

  int get newCount =>
      _todayNotifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await _cleanup();
    await _load();
  }

  Future<void> _load() async {
    final all = await _getNotifications();
    _todayNotifications.value = all.where((n) => n.isToday).toList();
    _pastNotifications.value = all.where((n) => !n.isToday).toList();
  }

  /// 개별 알림 읽음 처리 — DB 저장 후 목록 갱신
  Future<void> markAsRead(int id) async {
    await _markAsRead(id);
    await _load();
  }

  /// 전체 읽음 토글
  /// - 전체 읽음 상태(isAllRead=true) → 전체 해제 (DB 초기화 + 목록 갱신)
  /// - 그 외(미읽음 or 부분 읽음) → 전체 읽음
  Future<void> markAllAsRead() async {
    if (isAllRead.value) {
      await _resetAllRead();
      await _load();
      isAllRead.value = false;
    } else {
      isAllRead.value = true;
    }
  }
}
