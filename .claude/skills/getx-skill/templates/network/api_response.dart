/// HTTP 응답을 감싸는 공통 모델
/// GetConnect, Dio 등 구현체에 관계없이 동일한 형태로 반환
class ApiResult<T> {
  final int? statusCode;
  final T? body;
  final String? bodyString;
  final Map<String, String>? headers;
  final bool isOk;

  const ApiResult({
    this.statusCode,
    this.body,
    this.bodyString,
    this.headers,
    this.isOk = false,
  });
}
