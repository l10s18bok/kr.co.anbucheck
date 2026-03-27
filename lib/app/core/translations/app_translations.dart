import 'package:get/get.dart';
import 'package:anbucheck/app/core/translations/ko_kr.dart';
import 'package:anbucheck/app/core/translations/en_us.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ko_KR': KoKr.translations,
        'en_US': EnUs.translations,
      };
}
