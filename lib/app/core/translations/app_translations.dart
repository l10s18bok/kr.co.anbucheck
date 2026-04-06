import 'package:get/get.dart';
import 'package:anbucheck/app/core/translations/ko_kr.dart';
import 'package:anbucheck/app/core/translations/en_us.dart';
import 'package:anbucheck/app/core/translations/ja_jp.dart';
import 'package:anbucheck/app/core/translations/zh_cn.dart';
import 'package:anbucheck/app/core/translations/zh_tw.dart';
import 'package:anbucheck/app/core/translations/de_de.dart';
import 'package:anbucheck/app/core/translations/fr_fr.dart';
import 'package:anbucheck/app/core/translations/es_es.dart';
import 'package:anbucheck/app/core/translations/it_it.dart';
import 'package:anbucheck/app/core/translations/nl_nl.dart';
import 'package:anbucheck/app/core/translations/pt_br.dart';
import 'package:anbucheck/app/core/translations/ru_ru.dart';
import 'package:anbucheck/app/core/translations/ar_sa.dart';
import 'package:anbucheck/app/core/translations/tr_tr.dart';
import 'package:anbucheck/app/core/translations/pl_pl.dart';
import 'package:anbucheck/app/core/translations/vi_vn.dart';
import 'package:anbucheck/app/core/translations/th_th.dart';
import 'package:anbucheck/app/core/translations/sv_se.dart';
import 'package:anbucheck/app/core/translations/hi_in.dart';
import 'package:anbucheck/app/core/translations/id_id.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ko_KR': KoKr.translations,
        'en_US': EnUs.translations,
        'ja_JP': JaJp.translations,
        'zh_CN': ZhCn.translations,
        'zh_TW': ZhTw.translations,
        'de_DE': DeDe.translations,
        'fr_FR': FrFr.translations,
        'es_ES': EsEs.translations,
        'it_IT': ItIt.translations,
        'nl_NL': NlNl.translations,
        'pt_BR': PtBr.translations,
        'ru_RU': RuRu.translations,
        'ar_SA': ArSa.translations,
        'tr_TR': TrTr.translations,
        'pl_PL': PlPl.translations,
        'vi_VN': ViVn.translations,
        'th_TH': ThTh.translations,
        'sv_SE': SvSe.translations,
        'hi_IN': HiIn.translations,
        'id_ID': IdId.translations,
      };
}
