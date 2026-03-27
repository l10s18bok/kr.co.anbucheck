/// 알림 등급
enum AlertLevel { urgent, warning, caution, info }

/// 보호자 알림 이력 엔티티 — 순수 Dart
class NotificationEntity {
  final int? id;
  final String title;
  final String body;
  final AlertLevel level;
  final String? inviteCode;
  final String? nickname;
  final DateTime receivedAt;
  final bool isRead;

  const NotificationEntity({
    this.id,
    required this.title,
    required this.body,
    required this.level,
    this.inviteCode,
    this.nickname,
    required this.receivedAt,
    this.isRead = false,
  });

  /// 오늘 수신된 알림 여부
  bool get isToday {
    final now = DateTime.now();
    return receivedAt.year == now.year &&
        receivedAt.month == now.month &&
        receivedAt.day == now.day;
  }

  /// 화면에 표시할 대상자 이름 (별칭 우선, 없으면 초대코드)
  String get displayName => nickname ?? inviteCode ?? '알 수 없음';
}
