import 'package:anbucheck/app/data/datasources/local/nickname_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/local/notification_local_datasource.dart';
import 'package:anbucheck/app/data/models/notification_model.dart';
import 'package:anbucheck/app/domain/entities/notification_entity.dart';
import 'package:anbucheck/app/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDatasource _localDs;
  final NicknameLocalDatasource _nicknameDs;

  NotificationRepositoryImpl(this._localDs, this._nicknameDs);

  @override
  Future<List<NotificationEntity>> getAll() async {
    final rows = await _localDs.getAll();
    final nicknames = await _nicknameDs.getAll();
    return rows.map((row) {
      final model = NotificationModel.fromMap(row);
      final nickname = nicknames[model.inviteCode ?? ''];
      return model.toEntity(nickname: nickname);
    }).toList();
  }

  @override
  Future<void> save(NotificationEntity entity) async {
    final model = NotificationModel.fromEntity(entity);
    await _localDs.insert(model.toMap());
  }

  @override
  Future<void> markAsRead(int id) => _localDs.markAsRead(id);

  @override
  Future<void> resetAllRead() => _localDs.resetAllRead();

  @override
  Future<void> cleanup() => _localDs.cleanup();

  @override
  Future<void> seedIfEmpty() async {
    await _nicknameDs.save('K7M-4PXR', '어머니');
    await _nicknameDs.save('ABC-1234', '아버지');
    await _localDs.seedIfEmpty();
  }
}
