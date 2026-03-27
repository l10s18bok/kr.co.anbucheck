import 'package:anbucheck/app/domain/entities/notification_entity.dart';

/// notifications 테이블 매핑 모델
class NotificationModel {
  final int? id;
  final String title;
  final String body;
  final String alertLevel;
  final String? inviteCode;
  final String receivedAt;
  final bool isRead;

  const NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.alertLevel,
    this.inviteCode,
    required this.receivedAt,
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) =>
      NotificationModel(
        id: map['id'] as int?,
        title: map['title'] as String,
        body: map['body'] as String,
        alertLevel: map['alert_level'] as String,
        inviteCode: map['invite_code'] as String?,
        receivedAt: map['received_at'] as String,
        isRead: (map['is_read'] as int? ?? 0) == 1,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'body': body,
        'alert_level': alertLevel,
        'invite_code': inviteCode,
        'received_at': receivedAt,
        'is_read': isRead ? 1 : 0,
      };

  NotificationEntity toEntity({String? nickname}) => NotificationEntity(
        id: id,
        title: title,
        body: body,
        level: AlertLevel.values.firstWhere(
          (e) => e.name == alertLevel,
          orElse: () => AlertLevel.info,
        ),
        inviteCode: inviteCode,
        nickname: nickname,
        receivedAt: DateTime.parse(receivedAt),
        isRead: isRead,
      );

  static NotificationModel fromEntity(NotificationEntity entity) =>
      NotificationModel(
        id: entity.id,
        title: entity.title,
        body: entity.body,
        alertLevel: entity.level.name,
        inviteCode: entity.inviteCode,
        receivedAt: entity.receivedAt.toIso8601String(),
        isRead: entity.isRead,
      );
}
