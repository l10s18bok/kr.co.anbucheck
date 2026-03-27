import 'dart:developer';

import 'package:get/utils.dart';

abstract class ApiErrors implements Exception {
  final String message = '';
  ApiErrors({String? name}) {
    log(message, name: name ?? '');
  }
}

class UnknownError extends ApiErrors {
  @override
  String get message => '알수없는 에러'.tr;
  UnknownError() : super(name: '알수없는 에러'.tr);
}

class TimeoutError extends ApiErrors {
  @override
  String get message => '타임아웃 에러'.tr;
  TimeoutError() : super(name: '타임아웃 에러'.tr);
}

class NoConnectionError extends ApiErrors {
  @override
  String get message => '연결 에러'.tr;
  NoConnectionError() : super(name: '연결 에러'.tr);
}

class UnauthorizedError extends ApiErrors {
  @override
  String get message => '비승인 사용자'.tr;
  UnauthorizedError() : super(name: '비승인 사용자'.tr);
}

class ServerResError extends ApiErrors {
  @override
  // ignore: overridden_fields
  final String message;
  ServerResError(this.message) : super(name: 'ServerResError');
}
