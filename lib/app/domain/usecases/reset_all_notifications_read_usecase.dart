import 'package:anbucheck/app/domain/repositories/notification_repository.dart';

class ResetAllNotificationsReadUseCase {
  final NotificationRepository _repository;

  ResetAllNotificationsReadUseCase(this._repository);

  Future<void> call() => _repository.resetAllRead();
}
