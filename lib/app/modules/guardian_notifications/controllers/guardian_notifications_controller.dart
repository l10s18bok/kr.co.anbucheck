import 'package:get/get.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/core/services/subscription_service.dart';
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

  final _sub = Get.find<SubscriptionService>();

  /// 구독 활성 ever 워커. lazyPut 컨트롤러라 재방문 시 누적되지 않도록 onClose에서 dispose.
  Worker? _subWorker;

  @override
  void onInit() {
    super.onInit();
    load();
    // 구독 활성 전환 자동 반영 — 재구독 시 즉시 재조회, 만료 시 목록 비움.
    _subWorker = ever(_sub.isActive, (active) {
      if (active) {
        load();
      } else {
        notifications.clear();
      }
    });
  }

  @override
  void onClose() {
    _subWorker?.dispose();
    super.onClose();
  }

  /// 백그라운드 → 포그라운드 복귀 시 목록 재조회.
  /// iOS에서 알림 페이지를 띄운 채 화면이 잠겼다가 잠김화면 알림 탭으로 복귀하는 경우,
  /// 탭 라우팅(_routeToNotifications)이 신뢰성 있게 발화하지 않아 새 알림이 반영되지
  /// 않던 문제 대응 — 홈/대시보드 컨트롤러와 동일하게 resume마다 fresh 로드한다.
  @override
  void onResumed() {
    super.onResumed();
    load();
  }

  Future<void> load() async {
    // 구독 만료 — 알림 목록 통신 차단 + 비움. 재구독 시 ever가 재조회.
    if (!_sub.isActive.value) {
      notifications.clear();
      return;
    }
    if (isLoading) return;
    isLoading = true;
    try {
      final list = await _getNotifications();
      notifications.value = list
        ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    } catch (e) {
      // 실패 시 기존 목록 유지 — 장시간 잠금 해제 직후 네트워크가 준비되지 않아
      // 요청이 실패해도 화면에 표시 중이던 알림이 사라지지 않도록 한다.
      // 처음 로드(목록이 비어있는 초기 상태)면 빈 상태를 그대로 유지.
    } finally {
      isLoading = false;
    }
  }

  Future<void> deleteAll() async {
    if (isLoading || notifications.isEmpty) return;
    isLoading = true;
    try {
      await _deleteAllNotifications();
      notifications.clear();
    } catch (_) {
      AppSnackbar.show('common_error'.tr, 'notifications_delete_failed'.tr);
    } finally {
      isLoading = false;
    }
  }
}
