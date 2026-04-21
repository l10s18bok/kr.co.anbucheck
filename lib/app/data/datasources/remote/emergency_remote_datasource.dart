import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';
import 'package:anbucheck/app/core/utils/extensions.dart';

/// 긴급 도움 요청 시 첨부되는 사용자 위치.
/// 권한 거부/GPS 실패/타임아웃 어떤 경우에도 긴급 API 호출은 실행되며, 위치는 옵션이다.
class EmergencyLocation {
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final DateTime? capturedAt;

  const EmergencyLocation({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    this.capturedAt,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
        if (capturedAt != null) 'captured_at': capturedAt!.toIso8601String(),
      };
}

/// 긴급 요청 전송 직전 1회성으로 현재 위치를 획득한다.
/// SubjectHome·GuardianSafetyCode 양쪽 긴급 버튼에서 공통으로 사용한다.
///
/// 2단계 폴백:
/// 1) `getLastKnownPosition` — 다른 앱이 최근 GPS를 썼으면 수 ms 내 반환
/// 2) `getCurrentPosition` — medium 정확도 + 10초 타임아웃. high는 GPS only라
///    실내/콜드 스타트에서 timeout 빈발, medium은 GPS+Wi-Fi+셀룰러 병용.
///
/// 권한 거부·서비스 비활성·GPS 실패·타임아웃 어떤 예외에서도 null을 반환하며,
/// 절대 throw 하지 않는다 (긴급 요청 자체의 성공과 독립적으로 동작).
Future<EmergencyLocation?> captureEmergencyLocation() async {
  try {
    final status = await Permission.locationWhenInUse.request();
    '[긴급] 권한 요청 결과: $status'.printLog();
    if (!status.isGranted) return null;

    final serviceOn = await Geolocator.isLocationServiceEnabled();
    '[긴급] 위치 서비스 ON 여부: $serviceOn'.printLog();
    if (!serviceOn) return null;

    Position? pos;
    try {
      pos = await Geolocator.getLastKnownPosition();
      if (pos != null) {
        '[긴급] lastKnown 획득: ${pos.latitude}, ${pos.longitude}'.printLog();
      }
    } catch (e) {
      '[긴급] lastKnown 실패: $e'.printLog();
    }

    if (pos == null) {
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 10),
          ),
        );
        '[긴급] getCurrent 획득: ${pos.latitude}, ${pos.longitude}'.printLog();
      } catch (e) {
        '[긴급] getCurrent 실패: $e'.printLog();
        return null;
      }
    }

    return EmergencyLocation(
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracyMeters: pos.accuracy,
      capturedAt: DateTime.now(),
    );
  } catch (e) {
    '[긴급] 위치 획득 전체 예외: $e'.printLog();
    return null;
  }
}

/// POST /api/v1/emergency
class EmergencyRemoteDatasource {
  final Map<String, String> _auth;

  EmergencyRemoteDatasource(String deviceToken)
      : _auth = {'Authorization': 'Bearer $deviceToken'};

  Future<void> send(String deviceId, {EmergencyLocation? location}) async {
    final body = <String, dynamic>{'device_id': deviceId};
    if (location != null) {
      body['location'] = location.toJson();
    }

    final result = await ApiClientFactory.instance.post<Map<String, dynamic>>(
      ApiEndpoints.emergency,
      body,
      headers: _auth,
    );

    if (!result.isOk) {
      throw Exception('긴급 알림 전송 실패 (${result.statusCode})');
    }
  }
}
