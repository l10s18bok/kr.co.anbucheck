import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/base/base_controller.dart';
import 'package:anbucheck/app/domain/entities/notification_entity.dart';
import 'package:anbucheck/app/domain/usecases/get_notifications_usecase.dart';

export 'package:anbucheck/app/domain/entities/notification_entity.dart'
    show NotificationEntity, AlertLevel;

/// 지난 알림 전체 목록 컨트롤러 (페이지네이션)
class GuardianPastNotificationsController extends BaseController {
  final GetNotificationsUseCase _getNotifications;

  GuardianPastNotificationsController(this._getNotifications);

  static const int _pageSize = 10;

  final _allPast = <NotificationEntity>[];
  final displayedItems = <NotificationEntity>[].obs;
  final hasMore = false.obs;

  late final ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _load() async {
    isLoading = true;
    final all = await _getNotifications();
    // 오늘이 아닌 것만, 최신순 정렬
    _allPast
      ..clear()
      ..addAll(
        all.where((n) => !n.isToday).toList()
          ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt)),
      );
    _showMore(reset: true);
    isLoading = false;
  }

  void _showMore({bool reset = false}) {
    final current = reset ? 0 : displayedItems.length;
    final next = _allPast.skip(current).take(_pageSize).toList();
    if (reset) {
      displayedItems.value = next;
    } else {
      displayedItems.addAll(next);
    }
    hasMore.value = displayedItems.length < _allPast.length;
  }

  void _onScroll() {
    if (!hasMore.value) return;
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 100) {
      _showMore();
    }
  }
}
