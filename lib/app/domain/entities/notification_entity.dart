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

  /// 긴급 도움 요청 알림에 첨부된 위치 (그 외 알림은 모두 null)
  final double? locationLat;
  final double? locationLng;
  final double? locationAccuracy;
  final DateTime? locationCapturedAt;

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
    this.locationLat,
    this.locationLng,
    this.locationAccuracy,
    this.locationCapturedAt,
  });

  /// 화면에 표시할 대상자 이름 (별칭 우선, 없으면 초대코드)
  String get displayName => nickname ?? inviteCode ?? '알 수 없음';

  /// 배터리 관련 알림 여부 (아이콘/색상 분기용)
  bool get isBatteryRelated =>
      messageKey == 'battery_low' || messageKey == 'battery_dead';

  /// 긴급 알림에 위치가 포함되어 있는지 (지도 페이지 이동 조건)
  bool get hasLocation => locationLat != null && locationLng != null;
}
