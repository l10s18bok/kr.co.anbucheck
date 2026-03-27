import 'package:anbucheck/app/domain/entities/notification_entity.dart';
import 'package:anbucheck/app/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  Future<List<NotificationEntity>> call() => _repository.getAll();
}
