import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anbucheck/app/core/services/theme_service.dart';
import 'package:anbucheck/app/core/translations/app_translations.dart';
import 'package:anbucheck/app/core/theme/app_theme.dart';
import 'package:anbucheck/app/modules/mode_select/controllers/mode_select_controller.dart';
import 'package:anbucheck/app/modules/mode_select/views/mode_select_page.dart';

import '../helpers/test_helper.dart';

/// 모드 선택 화면 오버플로우 검증
/// 카드 2장이 Expanded 균등 분할을 유지한 채, 언어별 긴 번역/저해상도에서
/// RenderFlex 오버플로우가 발생하지 않는지 20개 언어 × 해상도 조합으로 확인
void main() {
  setupTestBinding();

  const locales = [
    'ko_KR', 'en_US', 'ja_JP', 'zh_CN', 'zh_TW',
    'de_DE', 'fr_FR', 'es_ES', 'it_IT', 'nl_NL',
    'pt_BR', 'ru_RU', 'ar_SA', 'tr_TR', 'pl_PL',
    'vi_VN', 'th_TH', 'sv_SE', 'hi_IN', 'id_ID',
  ];

  // 소형(구형 안드로이드) / 기준(디자인) / 대형 해상도
  const sizes = [
    Size(320, 568),
    Size(360, 640),
    Size(375, 812),
    Size(411, 731),
  ];

  Locale parseLocale(String code) {
    final parts = code.split('_');
    return Locale(parts[0], parts[1]);
  }

  Future<void> pumpModeSelect(WidgetTester tester, Locale locale) async {
    SharedPreferences.setMockInitialValues({});
    Get.put(ThemeService());
    Get.put(ModeSelectController());
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          translations: AppTranslations(),
          locale: locale,
          fallbackLocale: const Locale('en', 'US'),
          theme: AppTheme.lightTheme,
          home: const ModeSelectPage(),
        ),
      ),
    );
    // SVG 비동기 로드 프레임 소화
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  for (final size in sizes) {
    for (final code in locales) {
      testWidgets('오버플로우 없음 — $code @ ${size.width.toInt()}x${size.height.toInt()}',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        addTearDown(tearDownGetX);

        await pumpModeSelect(tester, parseLocale(code));

        // RenderFlex 오버플로우는 FlutterError로 보고됨
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('두 카드 높이 균등 유지 — 가장 긴 언어(de_DE) @ 320x568',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    addTearDown(tearDownGetX);

    await pumpModeSelect(tester, const Locale('de', 'DE'));

    // _ModeCard 루트는 GestureDetector — 페이지 내 카드 2장의 높이 비교
    final cards = find.byWidgetPredicate(
      (w) => w is GestureDetector && w.child is Stack,
    );
    expect(cards, findsNWidgets(2));
    final h1 = tester.getSize(cards.at(0)).height;
    final h2 = tester.getSize(cards.at(1)).height;
    expect((h1 - h2).abs(), lessThan(1.0),
        reason: '텍스트 길이와 무관하게 두 카드는 균등 높이여야 함');
  });
}
