import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';

/// 보호자 알림 설정 원격 데이터소스
class NotificationSettingsRemoteDatasource {
  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  /// GET /api/v1/guardian/notification-settings
  Future<Map<String, dynamic>> getSettings(String deviceToken) async {
    final result = await ApiClientFactory.instance.get<dynamic>(
      ApiEndpoints.guardianNotificationSettings,
      headers: _auth(deviceToken),
    );
    if (!result.isOk) {
      throw Exception('알림 설정 조회 실패 (${result.statusCode})');
    }
    return Map<String, dynamic>.from(result.body as Map);
  }

  /// PUT /api/v1/guardian/notification-settings
  Future<void> updateSettings(
    String deviceToken,
    Map<String, dynamic> settings,
  ) async {
    final result = await ApiClientFactory.instance.put<dynamic>(
      ApiEndpoints.guardianNotificationSettings,
      settings,
      headers: _auth(deviceToken),
    );
    if (!result.isOk) {
      throw Exception('알림 설정 저장 실패 (${result.statusCode})');
    }
  }
}
