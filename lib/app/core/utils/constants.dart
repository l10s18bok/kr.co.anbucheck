import 'package:get/get.dart';

abstract class AppConstants {
  static const String appName = 'app';

  // SharedPreferences Keys
  static const String keyToken = 'token';
  static const String keyLocale = 'locale';

  // 법적 문서 URL (GitHub Pages → 추후 자체 도메인으로 교체)
  static const String legalBaseUrl = 'https://l10s18bok.github.io/anbu-legal';

  /// 지원 locale → URL 경로 매핑 (20개 언어)
  static const Map<String, String> _legalLocalePaths = {
    'ko': 'ko',
    'en': 'en',
    'ja': 'ja',
    'zh': 'zh-CN', // zh_CN → zh-CN
    'de': 'de',
    'fr': 'fr',
    'es': 'es',
    'it': 'it',
    'nl': 'nl',
    'pt': 'pt-BR', // pt_BR → pt-BR
    'ru': 'ru',
    'ar': 'ar',
    'tr': 'tr',
    'pl': 'pl',
    'vi': 'vi',
    'th': 'th',
    'sv': 'sv',
    'hi': 'hi',
    'id': 'id',
  };

  /// 기기 locale에 맞는 법적 문서 경로 반환 (미지원 → en fallback)
  static String _legalLocale() {
    final locale = Get.locale;
    if (locale == null) return 'en';

    // zh_TW 특수 처리
    if (locale.languageCode == 'zh' && locale.countryCode == 'TW') {
      return 'zh-TW';
    }

    return _legalLocalePaths[locale.languageCode] ?? 'en';
  }

  static String get privacyPolicyUrl =>
      '$legalBaseUrl/${_legalLocale()}/privacy-policy.html';

  static String get termsOfServiceUrl =>
      '$legalBaseUrl/${_legalLocale()}/terms-of-service.html';
}
