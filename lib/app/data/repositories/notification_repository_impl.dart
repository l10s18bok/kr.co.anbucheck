import 'dart:convert';

import 'package:anbucheck/app/data/datasources/local/nickname_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/notification_remote_datasource.dart';
import 'package:anbucheck/app/domain/entities/notification_entity.dart';
import 'package:anbucheck/app/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource _remoteDs;
  final NicknameLocalDatasource _nicknameDs;

  NotificationRepositoryImpl(this._remoteDs, this._nicknameDs);

  @override
  Future<void> deleteAll() => _remoteDs.deleteAll();

  @override
  Future<List<NotificationEntity>> getAll() async {
    final rows = await _remoteDs.getAll();
    final nicknames = await _nicknameDs.getAll();

    return rows.map((row) {
      final inviteCode = row['invite_code'] as String?;
      final nickname = nicknames[inviteCode ?? ''];

      // message_params: JSON 문자열 또는 Map
      Map<String, dynamic>? params;
      final rawParams = row['message_params'];
      if (rawParams is String && rawParams.isNotEmpty) {
        try {
          params = Map<String, dynamic>.from(jsonDecode(rawParams) as Map);
        } catch (_) {}
      } else if (rawParams is Map) {
        params = Map<String, dynamic>.from(rawParams);
      }

      return NotificationEntity(
        id: row['id'] as int?,
        title: row['title'] as String,
        body: row['body'] as String,
        level: AlertLevel.values.firstWhere(
          (e) => e.name == (row['alert_level'] as String? ?? 'info'),
          orElse: () => AlertLevel.info,
        ),
        inviteCode: inviteCode,
        nickname: nickname,
        receivedAt: DateTime.parse(row['created_at'] as String).toLocal(),
        messageKey: row['message_key'] as String?,
        messageParams: params,
      );
    }).toList();
  }
}
