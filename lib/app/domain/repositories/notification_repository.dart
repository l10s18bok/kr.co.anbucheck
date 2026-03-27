import 'package:anbucheck/app/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getAll();
  Future<void> save(NotificationEntity entity);
  Future<void> markAsRead(int id);
  Future<void> resetAllRead();
  Future<void> cleanup();
  Future<void> seedIfEmpty();
}
