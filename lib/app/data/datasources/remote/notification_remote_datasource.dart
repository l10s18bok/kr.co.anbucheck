import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';

/// GET/DELETE /api/v1/notifications — 당일 보호자 알림 목록 조회/삭제
class NotificationRemoteDatasource {
  final TokenLocalDatasource _tokenDs;

  NotificationRemoteDatasource(this._tokenDs);

  Future<List<Map<String, dynamic>>> getAll() async {
    final token = await _tokenDs.getDeviceToken();
    if (token == null) return [];

    final result = await ApiClientFactory.instance.get<Map<String, dynamic>>(
      ApiEndpoints.notifications,
      headers: {
        'Authorization': 'Bearer $token',
        'X-Timezone-Offset': _utcOffsetString(),
      },
    );

    if (!result.isOk || result.body == null) {
      throw Exception('알림 목록 조회 실패 (${result.statusCode})');
    }

    final list = result.body!['notifications'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> deleteAll() async {
    final token = await _tokenDs.getDeviceToken();
    if (token == null) return;

    final result = await ApiClientFactory.instance.delete<dynamic>(
      ApiEndpoints.notificationsDeleteAll,
      headers: {
        'Authorization': 'Bearer $token',
        'X-Timezone-Offset': _utcOffsetString(),
      },
    );

    if (!result.isOk) {
      throw Exception('알림 전체 삭제 실패 (${result.statusCode})');
    }
  }

  String _utcOffsetString() {
    final offset = DateTime.now().timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return '$sign$hours:$minutes';
  }
}
