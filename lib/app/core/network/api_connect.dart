import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/network/api_client.dart';
import 'package:anbucheck/app/core/network/api_endpoints.dart';
import 'package:anbucheck/app/core/network/api_response.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/core/utils/extensions.dart';
import 'package:anbucheck/app/core/services/fcm_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/core/services/local_alarm_service.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';
import 'package:anbucheck/app/data/datasources/remote/user_remote_datasource.dart';
import 'package:anbucheck/app/modules/safety_home/controllers/safety_home_role.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// GetConnect 기반 ApiClient 구현체 (컴포지션 방식)
class GetConnectClient extends ApiClient {
  final _connect = _InternalGetConnect();

  /// GetConnect Response → 공통 ApiResult 변환
  ApiResult<T> _toApiResult<T>(Response<T> response) {
    return ApiResult<T>(
      statusCode: response.statusCode,
      body: response.body,
      bodyString: response.bodyString,
      isOk: response.isOk,
    );
  }

  @override
  Future<ApiResult<T>> get<T>(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    bool isToken = true,
  }) async {
    final response = await _connect.doGet<T>(
      url,
      headers: headers,
      contentType: contentType,
      query: query,
    );
    return _toApiResult(response);
  }

  @override
  Future<ApiResult<T>> post<T>(
    String url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    bool isToken = true,
  }) async {
    final response = await _connect.doPost<T>(
      url,
      body,
      headers: headers,
      contentType: contentType,
      query: query,
    );
    return _toApiResult(response);
  }

  @override
  Future<ApiResult<T>> put<T>(
    String url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    bool isToken = true,
  }) async {
    final response = await _connect.doPut<T>(
      url,
      body,
      headers: headers,
      contentType: contentType,
      query: query,
    );
    return _toApiResult(response);
  }

  @override
  Future<ApiResult<T>> delete<T>(
    String url, {
    dynamic body,
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    bool isToken = true,
  }) async {
    final response = await _connect.doDelete<T>(
      url,
      body: body,
      headers: headers,
      contentType: contentType,
      query: query,
    );
    return _toApiResult(response);
  }

  @override
  void dispose() {
    _connect.dispose();
  }
}

/// 401 응답 시 자동 재등록 시도 → 실패 시 로컬 초기화 + 모드 선택 화면 이동
/// 중복 호출 방지를 위한 플래그
bool _handlingUnauthorized = false;

Future<void> _handleUnauthorized() async {
  if (_handlingUnauthorized) return;
  _handlingUnauthorized = true;
  try {
    final tokenDs = TokenLocalDatasource();
    final deviceId = await tokenDs.getDeviceId();
    final savedRole = await tokenDs.getUserRole();

    // 로컬에 deviceId + role이 남아 있으면 서버 확인 후 자동 재등록 시도.
    //
    // **두 단계 분리 (중요)**: 이전 구현은 checkDevice + register를 하나의 try로 감싸고
    // 어떤 예외든 catch에서 fallthrough → cancel + clear로 처리했다. 이 경우 사용자가
    // 서버에 멀쩡히 살아있는데도 일시 네트워크 오류로 checkDevice가 throw하면 로컬 wipe +
    // WorkManager 영구 cancel이 발생해 "사용자 앱 안 열면 영원히 미전송" 상태로 빠질 수
    // 있다. 따라서:
    //   (1) checkDevice 자체 throw → 사용자 계정 존재 여부를 알 수 없으므로 cancel/clear
    //       보류, 다음 세션 재시도. 함수 즉시 종료.
    //   (2) checkDevice 응답으로 exists=false → 서버가 명시적으로 계정 없음을 알림 →
    //       fallthrough하여 cancel + clear.
    //   (3) exists=true 분기에서 register가 실패 → fallthrough (이전 동작 유지).
    if (deviceId != null && savedRole != null) {
      Map<String, dynamic>? check;
      try {
        check = await UserRemoteDatasource().checkDevice(deviceId);
      } catch (e) {
        '[401 복구] checkDevice 실패 (네트워크 오류 추정): $e → cancel/clear 보류, 다음 세션 재시도'
            .printLog();
        return;
      }

      if (check['exists'] == true) {
        try {
          final role = check['role'] as String? ?? savedRole;

          // FCM 토큰 (미등록이면 빈 문자열로 진행 — 등록 후 갱신됨)
          String fcmToken = '';
          try {
            fcmToken = Get.find<FcmService>().token ?? '';
          } catch (_) {}

          final platform = Platform.isIOS ? 'ios' : 'android';
          final osVersion = await _getOsVersion();

          final response = await UserRemoteDatasource().register(
            role: role,
            deviceId: deviceId,
            fcmToken: fcmToken,
            platform: platform,
            osVersion: osVersion,
          );

          // 로컬 토큰 갱신
          await tokenDs.saveDeviceToken(response['device_token'] as String);
          await tokenDs.saveUserId(response['user_id'] as int);
          await tokenDs.saveUserRole(role);
          if (role == 'subject' && response['invite_code'] != null) {
            await tokenDs.saveInviteCode(response['invite_code'] as String);
          }

          // 홈 화면으로 이동
          if (role == 'subject') {
            Get.offAllNamed(AppRoutes.safetyHome,
                arguments: {'role': HomeRole.subject});
          } else {
            Get.offAllNamed(AppRoutes.guardianDashboard);
          }
          '[401 복구] 자동 재등록 성공 → $role 홈으로 이동'.printLog();
          return;
        } catch (e) {
          '[401 복구] 재등록 실패: $e → 모드 선택으로 이동'.printLog();
          // fallthrough: cancel + clear
        }
      }
      // exists=false: 서버가 명시적으로 계정 없음 응답 → fallthrough: cancel + clear
    }

    // 재등록 불가 → 기존 로직: 로컬 초기화 + 모드 선택
    // **순서 중요 (race 차단)**: clear를 cancel보다 먼저. 워커 isolate의 _rescheduleNextDay
    // 가 reload 후 role=null을 보고 skip하도록.
    await tokenDs.clear();
    await HeartbeatWorkerService.cancel();
    await LocalAlarmService.cancel();
    Get.offAllNamed(AppRoutes.modeSelect);
    AppSnackbar.show('', '계정 정보가 만료되었습니다. 다시 등록해 주세요.',
        position: SnackPosition.TOP);
  } finally {
    _handlingUnauthorized = false;
  }
}

/// OS 버전 문자열 반환
Future<String> _getOsVersion() async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final android = await deviceInfo.androidInfo;
    return 'Android ${android.version.release}';
  } else if (Platform.isIOS) {
    final ios = await deviceInfo.iosInfo;
    return 'iOS ${ios.systemVersion}';
  }
  return '';
}

/// 내부 GetConnect 래퍼 (시그니처 충돌 방지)
class _InternalGetConnect extends GetConnect {
  dynamic _reqBody;

  _InternalGetConnect() {
    baseUrl = ApiEndpoints.baseUrl;
    timeout = ApiEndpoints.timeout;

    httpClient.addRequestModifier<dynamic>((request) {
      '************** Request **************'.printLog();
      'uri: ${request.url}'.printLog();
      'method: ${request.method}'.printLog();
      'headers:'.printLog();
      request.headers.forEach((key, v) => ' $key: $v'.printLog());
      'Request Body:'.printLog();
      if (_reqBody is Map) {
        _reqBody?.forEach((key, v) => ' $key: $v'.printLog());
      } else {
        _reqBody.toString().split('\n').forEach((l) => l.printLog());
      }
      '*************************************'.printLog();
      return request;
    });

    httpClient.addResponseModifier((request, response) {
      '************** Response **************'.printLog();
      'uri: ${response.request!.url}'.printLog();
      'statusCode: ${response.statusCode}'.printLog();
      'Response Body:'.printLog();
      response.bodyString
          .toString()
          .split('\n')
          .forEach((l) => l.printLog());
      '*************************************'.printLog();

      // 401: 서버에서 계정 삭제됨 → 로컬 초기화 + 모드 선택 화면 이동
      // heartbeat 401은 재등록을 트리거하지 않는다 — pending 큐에 저장하고 다음 주기 재시도
      // users 엔드포인트 자체의 401도 스킵 (재귀 방지)
      if (response.statusCode == 401) {
        final path = response.request?.url.path ?? '';
        if (!path.contains('/heartbeat') && !path.contains('/users')) {
          _handleUnauthorized();
        }
      }

      return response;
    });
  }

  Future<Response<T>> doGet<T>(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
  }) {
    _reqBody = query;
    return get<T>(url,
        headers: headers, contentType: contentType, query: query)
      ..whenComplete(() => _reqBody = null);
  }

  Future<Response<T>> doPost<T>(
    String url,
    dynamic body, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
  }) {
    _reqBody = body;
    return post<T>(url, body,
        headers: headers, contentType: contentType, query: query)
      ..whenComplete(() => _reqBody = null);
  }

  Future<Response<T>> doPut<T>(
    String url,
    dynamic body, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
  }) {
    _reqBody = body;
    return put<T>(url, body,
        headers: headers, contentType: contentType, query: query)
      ..whenComplete(() => _reqBody = null);
  }

  Future<Response<T>> doDelete<T>(
    String url, {
    dynamic body,
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
  }) {
    if (query == null && body != null) {
      _reqBody = body;
      return httpClient.request<T>(
        url,
        'delete',
        body: body,
        headers: headers ?? {},
        contentType: contentType,
      )..whenComplete(() => _reqBody = null);
    }
    _reqBody = query;
    return delete<T>(url,
        headers: headers, contentType: contentType, query: query)
      ..whenComplete(() => _reqBody = null);
  }
}
