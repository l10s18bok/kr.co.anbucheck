import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

extension StringExt on String {
  /// 디버그 로그 출력 — 릴리스 빌드에서는 출력하지 않는다.
  /// 네트워크 인터셉터(헤더/바디)·긴급 위치 등 민감정보가 이 경로로 흐르므로
  /// release에서 토큰·영수증·좌표가 로그에 남지 않도록 차단한다.
  void printLog() {
    if (kReleaseMode) return;
    dev.log(this, name: 'APP');
  }
}

extension NullableStringExt on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
