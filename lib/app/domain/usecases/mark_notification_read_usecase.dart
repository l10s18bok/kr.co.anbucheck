import 'package:anbucheck/app/domain/repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  Future<void> call(int id) => _repository.markAsRead(id);
}
