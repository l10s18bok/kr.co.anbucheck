import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_theme.dart';
import 'package:anbucheck/app/core/translations/app_translations.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
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
