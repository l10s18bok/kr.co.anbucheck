import 'dart:developer' as dev;

extension StringExt on String {
  /// 디버그 로그 출력
  void printLog() {
    dev.log(this, name: 'APP');
  }
}

extension NullableStringExt on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
