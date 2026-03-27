import 'package:anbucheck/app/domain/repositories/notification_repository.dart';

class CleanupNotificationsUseCase {
  final NotificationRepository _repository;

  CleanupNotificationsUseCase(this._repository);

  Future<void> call() => _repository.cleanup();
}
