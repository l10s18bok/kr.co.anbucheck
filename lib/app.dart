import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_theme.dart';
import 'package:anbucheck/app/core/translations/app_translations.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

class App extends StatelessWidget {
  const App({super.key});

  /// 대형 화면(펼친 폴더블·태블릿) 판정 기준 폭. Material 3 window size class의
  /// medium 하한이자 Android가 방향·리사이즈 제한을 무시하기 시작하는 sw600dp와 같다.
  static const double largeScreenBreakpoint = 600;

  /// 기준 설계 폭. 이 값 배수로 designSize를 늘려 .w 배율을 낮춘다.
  static const double _baseDesignWidth = 375;

  @override
  Widget build(BuildContext context) {
    // ScreenUtil은 `.w` 배율을 `창 폭 / designSize.width`로 정하는데, designSize를
    // 375로 고정하면 펼친 폴더블(851dp)에서 가로만 2.27배가 된다. `.h`/`.sp`는
    // `창 높이 / 812`(1.09배)라서 **가로/세로 2.1배 비대칭**이 생기고, 가로 여백만
    // 부풀어 세로가 짓눌린다(펼친 Z 폴드에서 모드 선택 카드의 일러스트가 사라지고
    // 배지가 본문을 덮던 원인).
    //
    // 그래서 대형 화면에서는 designSize.width를 창 폭에 맞춰 키워 배율을 1.1배대로
    // 낮춘다. 일반 폰(<600dp)은 기존 `Size(375, 812)`가 그대로 쓰여 동작이 완전히 동일하다.
    //
    // ⚠️ 하한 클램프(`min(..., 창 폭)`)를 빼지 말 것 — 600dp 태블릿에서 배율이
    // 600/750 = 0.8배가 되어 **폰보다 UI가 작아진다.** 고령 사용자 대상 앱에서
    // 글자가 작아지는 방향은 허용하지 않는다. 클램프가 있으면 최소 1.0배가 보장된다.
    //
    // LayoutBuilder를 쓰는 이유: 접기/펼치기로 창 폭이 바뀔 때 재빌드되어야
    // designSize가 다시 계산된다.
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final designWidth = width >= largeScreenBreakpoint
            ? math.min(_baseDesignWidth * 2, width)
            : _baseDesignWidth;
        return _buildApp(Size(designWidth, 812));
      },
    );
  }

  Widget _buildApp(Size designSize) {
    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (_) => 'app_name'.tr,
          translations: AppTranslations(),
          locale: Get.deviceLocale,
          fallbackLocale: const Locale('en', 'US'),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
          builder: (context, child) {
            // AppBar 없는 화면(Splash/모드선택/권한/온보딩 등)에서도 상태바 텍스트 색을
            // 테마에 맞춰 강제. iOS는 ViewController 기반 statusBarStyle을 쓰는데
            // AppBar가 없으면 Flutter가 갱신을 못 해 launch image 기본값이 유지되며,
            // 실기기 다크모드에서 흰 배경 위 흰 텍스트가 되는 케이스가 있다.
            // AppBar가 있는 화면은 AppBarTheme.systemOverlayStyle이 우선 적용된다.
            // ThemeService.toggle → Get.forceAppUpdate 시 builder 재실행으로 반영.
            final brightness = Theme.of(context).brightness;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
