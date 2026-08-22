import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';
import 'dart:io';

import 'package:get/get.dart';

/// 기기 관련 원격 저장소
class DeviceRemoteDatasource {
  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  /// 기기 locale 문자열 반환 (예: 'ko_KR', 'en_US').
  String _localeString() {
    final locale = Get.deviceLocale;
    if (locale == null) return 'en_US';
    final lang = locale.languageCode;
    final country = locale.countryCode ?? '';
    return country.isNotEmpty ? '${lang}_$country' : lang;
  }

  /// PUT /api/v1/devices/fcm-token — FCM 토큰 + locale 갱신
  Future<void> updateFcmToken(String deviceToken, String fcmToken) async {
    final result = await ApiClientFactory.instance.put<dynamic>(
      ApiEndpoints.devicesFcmToken,
      {
        'fcm_token': fcmToken,
        'locale': _localeString(),
          // iOS Notification Service Extension 탑재 여부(능력 플래그).
          // 서버는 이 값이 true인 기기에만 예약시각 heartbeat 트리거 푸시를 보낸다.
          // ⚠️ 게이팅은 선택이 아니라 전제조건이다 — 확장이 없는 구버전 iOS 앱은
          // gs_deadman 로컬 알림을 그대로 갖고 있어, 푸시까지 받으면 같은 시각에
          // 알림이 2개 뜬다(대상이 고령 사용자라 그 혼란은 이 앱이 없애려는 문제다).
        'supports_push_heartbeat': Platform.isIOS,
      },
      headers: _auth(deviceToken),
    );
    if (!result.isOk) {
      throw Exception('FCM 토큰 갱신 실패 (${result.statusCode})');
    }
  }

  /// GET /api/v1/devices/me — 내 기기 정보 조회 (heartbeat 시각, last_seen)
  Future<Map<String, dynamic>> getMyDevice(String deviceToken) async {
    final result = await ApiClientFactory.instance.get<dynamic>(
      ApiEndpoints.devicesMe,
      headers: _auth(deviceToken),
    );
    if (!result.isOk) {
      throw Exception('기기 정보 조회 실패 (${result.statusCode})');
    }
    return Map<String, dynamic>.from(result.body as Map);
  }

  /// GET /api/v1/subscription — 보호자 구독 상태 조회 (plan, expires_at, days_remaining)
  Future<Map<String, dynamic>> getSubscription(String deviceToken) async {
    final result = await ApiClientFactory.instance.get<dynamic>(
      ApiEndpoints.subscription,
      headers: _auth(deviceToken),
    );
    if (!result.isOk) {
      throw Exception('구독 정보 조회 실패 (${result.statusCode})');
    }
    return Map<String, dynamic>.from(result.body as Map);
  }

  /// PUT /api/v1/devices/{device_id}/heartbeat-schedule — heartbeat 시각 변경
  /// 서버 PRD는 PATCH이나 PUT으로도 동작하도록 서버에서 처리
  Future<void> updateHeartbeatSchedule(
    String deviceToken,
    String deviceId,
    int hour,
    int minute,
  ) async {
    final result = await ApiClientFactory.instance.put<dynamic>(
      ApiEndpoints.heartbeatSchedule(deviceId),
      {'heartbeat_hour': hour, 'heartbeat_minute': minute},
      headers: _auth(deviceToken),
    );
    if (!result.isOk) {
      throw Exception('heartbeat 시각 변경 실패 (${result.statusCode})');
    }
  }
}
