import 'dart:async';
import 'dart:convert';

import 'package:anbucheck/app/core/network/api_error.dart';
import 'package:anbucheck/app/core/network/api_response.dart';

/// HTTP 클라이언트 공통 인터페이스
/// GetConnect, Dio 등 어떤 구현체든 이 인터페이스를 따른다.
abstract class ApiClient {
  Future<ApiResult<T>> get<T>(
    String url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    bool isToken = true,
  });

  Future<ApiResult<T>> post<T>(
    String url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    bool isToken = true,
  });

  Future<ApiResult<T>> put<T>(
    String url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    bool isToken = true,
  });

  Future<ApiResult<T>> delete<T>(
    String url, {
    dynamic body,
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    bool isToken = true,
  });

  void dispose();
}

/// ApiResult 에러 처리 Extension
extension ApiResultErr<T> on ApiResult<T> {
  T getBody() {
    if (statusCode == null) {
      throw NoConnectionError();
    }
    if (statusCode == 401) {
      throw UnauthorizedError();
    }
    if (statusCode == 400) {
      final res = jsonDecode(bodyString!);
      throw ServerResError(res.toString());
    }
    if (statusCode == 408) {
      throw TimeoutError();
    }
    if (!isOk) {
      throw UnknownError();
    }
    try {
      final res = jsonDecode(bodyString!);
      if (res is Map && res['valid'] != null && !res['valid']) {
        throw ServerResError(res['message']);
      }
      return body as T;
    } on TimeoutException catch (_) {
      throw TimeoutError();
    } catch (_) {
      throw UnknownError();
    }
  }
}
