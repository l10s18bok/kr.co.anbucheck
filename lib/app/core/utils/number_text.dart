import 'package:get/get.dart';

/// 숫자가 들어가는 번역 문구 도우미.
///
/// - 천 단위 구분자는 언어마다 다르다(en 3,412 / de 3.412 / fr 3 412). 서버
///   `i18n/messages.py`의 `_THOUSANDS_SEP`와 같은 표를 쓴다 — 푸시와 알림 목록이
///   같은 숫자를 다르게 찍지 않게 하기 위함이다.
/// - 단수형이 다른 언어는 `<키>_one`을 따로 둔다. ru·pl·ar는 숫자에 따라 격이
///   셋 이상으로 바뀌어 단수/복수 두 형태로 해결되지 않으므로, 두 키 모두
///   "라벨: 숫자" 문장으로 번역해 둔다. 그래서 `_one` 키는 **20개 언어 모두에**
///   있어야 한다 — 없으면 GetX가 fallback 언어(영어)의 문장을 꺼낸다.
class NumberText {
  NumberText._();

  static const _dotLangs = {'de', 'es', 'it', 'nl', 'pt', 'tr', 'id', 'vi'};
  static const _spaceLangs = {'fr', 'ru', 'pl', 'sv'};

  /// 정수를 현재 언어의 천 단위 구분자로 표기한다.
  static String format(int n) {
    final lang = Get.locale?.languageCode ?? 'en';
    final sep = _dotLangs.contains(lang)
        ? '.'
        : _spaceLangs.contains(lang)
            ? ' '
            : ',';
    final digits = n.abs().toString();
    final buf = StringBuffer(n < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(sep);
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  /// 서버가 ko 형식("1,234")으로 저장한 숫자 문자열을 정수로 되돌린다.
  static int? parse(Object? raw) {
    if (raw is int) return raw;
    final digits = raw?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  /// [n]이 1이면 `<key>_one`을 쓴다. [param] 자리에는 언어별로 포맷한 숫자가 들어간다.
  static String tr(String key, String param, int n,
      [Map<String, String> extra = const {}]) {
    final k = n == 1 ? '${key}_one' : key;
    return k.trParams({...extra, param: format(n)});
  }

  /// 아랍어 복수형(CLDR)으로 번역 키를 고른다 — 1 `_one` / 2 `_two` / 3~10 기본 키 /
  /// 11~99 `_many` / 그 외(100 이상) `_other`. `_other`가 없는 키(분·시간)는 n이 100을
  /// 넘지 않으므로 호출부가 쓰지 않는다.
  static String trAr(String key, String param, int n) {
    final r = n % 100;
    final suffix = n == 1
        ? '_one'
        : n == 2
            ? '_two'
            : (r >= 3 && r <= 10)
                ? ''
                : (r >= 11)
                    ? '_many'
                    : '_other';
    return '$key$suffix'.trParams({param: format(n)});
  }

  /// "N분/시간/일 전" 문장 — 아랍어만 복수형 선택, 나머지 언어는 [tr](일수) 또는 기존 키 그대로.
  static bool get isArabic => Get.locale?.languageCode == 'ar';
}
