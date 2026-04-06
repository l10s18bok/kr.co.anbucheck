/// 알림 등급
enum AlertLevel { urgent, warning, caution, info, health }

/// 보호자 알림 엔티티 — 순수 Dart
class NotificationEntity {
  final int? id;
  final String title;
  final String body;
  final AlertLevel level;
  final String? inviteCode;
  final String? nickname;
  final DateTime receivedAt;
  final String? messageKey;
  final Map<String, dynamic>? messageParams;

  const NotificationEntity({
    this.id,
    required this.title,
    required this.body,
    required this.level,
    this.inviteCode,
    this.nickname,
    required this.receivedAt,
    this.messageKey,
    this.messageParams,
  });

  /// 화면에 표시할 대상자 이름 (별칭 우선, 없으면 초대코드)
  String get displayName => nickname ?? inviteCode ?? '알 수 없음';

  /// 배터리 관련 알림 여부 (아이콘/색상 분기용)
  bool get isBatteryRelated =>
      messageKey == 'battery_low' || messageKey == 'battery_dead';
}
