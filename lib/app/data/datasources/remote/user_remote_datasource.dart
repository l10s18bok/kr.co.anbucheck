import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tzlib;

/// 사용자 등록/삭제 원격 저장소
class UserRemoteDatasource {
  /// GET /api/v1/users/check-device — 기존 등록 여부 확인 (순수 조회)
  /// 반환: { "exists": true, "role": "subject" } 또는 { "exists": false }
  Future<Map<String, dynamic>> checkDevice(String deviceId) async {
    final result = await ApiClientFactory.instance.get<dynamic>(
      ApiEndpoints.usersCheckDevice,
      query: {'device_id': deviceId},
    );
    if (!result.isOk) {
      return {'exists': false};
    }
    return Map<String, dynamic>.from(result.body as Map);
  }

  /// DELETE /api/v1/users/me — 계정 및 관련 데이터 전체 삭제 (모드 변경 시)
  Future<void> deleteMe(String deviceToken) async {
    final result = await ApiClientFactory.instance.delete<void>(
      '${ApiEndpoints.users}/me',
      headers: {'Authorization': 'Bearer $deviceToken'},
    );
    // 204 No Content 또는 200~299 모두 성공으로 처리
    final code = result.statusCode;
    if (!result.isOk && code != null && code != 204) {
      throw Exception('계정 삭제 실패 ($code)');
    }
  }

  /// 기기 로컬 IANA timezone 문자열 반환.
  /// main()에서 FlutterTimezone으로 tzlib.local을 설정한 뒤 호출되므로 항상 유효한 IANA 이름 반환.
  String _timezoneString() {
    return tzlib.local.name;
  }

  /// 기기 locale 문자열 반환 (예: 'ko_KR', 'en_US').
  String _localeString() {
    final locale = Get.deviceLocale;
    if (locale == null) return 'en_US';
    final lang = locale.languageCode;
    final country = locale.countryCode ?? '';
    return country.isNotEmpty ? '${lang}_$country' : lang;
  }

  /// POST /api/v1/users/enable-subject — 보호자가 대상자 기능 활성화
  Future<Map<String, dynamic>> enableSubject(String deviceToken) async {
    final result = await ApiClientFactory.instance.post<dynamic>(
      '${ApiEndpoints.users}/enable-subject',
      {},
      headers: {'Authorization': 'Bearer $deviceToken'},
    );
    if (!result.isOk) {
      throw Exception('안부 보호 활성화 실패 (${result.statusCode})');
    }
    return Map<String, dynamic>.from(result.body as Map);
  }

  /// DELETE /api/v1/users/disable-subject — 보호자가 대상자 기능 해제
  Future<void> disableSubject(String deviceToken) async {
    final result = await ApiClientFactory.instance.delete<void>(
      '${ApiEndpoints.users}/disable-subject',
      headers: {'Authorization': 'Bearer $deviceToken'},
    );
    final code = result.statusCode;
    if (!result.isOk && code != null && code != 200) {
      throw Exception('안부 보호 해제 실패 ($code)');
    }
  }

  /// POST /api/v1/users/switch-to-guardian — 대상자가 보호자 기능 추가 (S → G+S)
  /// role을 guardian으로 전환하고 3개월 무료 체험 구독 생성. invite_code와
  /// heartbeat 예약은 서버에서 그대로 유지되므로 S 기능은 끊김 없이 지속된다.
  Future<Map<String, dynamic>> switchToGuardian(String deviceToken) async {
    final result = await ApiClientFactory.instance.post<dynamic>(
      '${ApiEndpoints.users}/switch-to-guardian',
      {},
      headers: {'Authorization': 'Bearer $deviceToken'},
    );
    if (!result.isOk) {
      throw Exception('보호자 기능 활성화 실패 (${result.statusCode})');
    }
    return Map<String, dynamic>.from(result.body as Map);
  }

  /// POST /api/v1/users
  Future<Map<String, dynamic>> register({
    required String role,
    required String deviceId,
    required String fcmToken,
    required String platform,
    String osVersion = '',
  }) async {
    final result = await ApiClientFactory.instance.post<dynamic>(
      ApiEndpoints.users,
      {
        'role': role,
        'device': {
          'device_id': deviceId,
          'fcm_token': fcmToken,
          'platform': platform,
          'os_version': osVersion,
          'timezone': _timezoneString(),
          'locale': _localeString(),
        },
      },
    );
    if (!result.isOk) {
      throw Exception('사용자 등록 실패 (${result.statusCode}): ${result.bodyString}');
    }
    return Map<String, dynamic>.from(result.body as Map);
  }
}
