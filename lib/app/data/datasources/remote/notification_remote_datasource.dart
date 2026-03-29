import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';

/// GET /api/v1/notifications — 당일 보호자 알림 목록 조회
class NotificationRemoteDatasource {
  final TokenLocalDatasource _tokenDs;

  NotificationRemoteDatasource(this._tokenDs);

  Future<List<Map<String, dynamic>>> getAll() async {
    final token = await _tokenDs.getDeviceToken();
    if (token == null) return [];

    final result = await ApiClientFactory.instance.get<Map<String, dynamic>>(
      '/api/v1/notifications',
      headers: {'Authorization': 'Bearer $token'},
    );

    if (!result.isOk || result.body == null) {
      throw Exception('알림 목록 조회 실패 (${result.statusCode})');
    }

    final list = result.body!['notifications'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }
}
