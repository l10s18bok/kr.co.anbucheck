import 'package:anbucheck/app/domain/repositories/notification_repository.dart';

class DeleteAllNotificationsUseCase {
  final NotificationRepository _repository;

  DeleteAllNotificationsUseCase(this._repository);

  Future<void> call() => _repository.deleteAll();
}
