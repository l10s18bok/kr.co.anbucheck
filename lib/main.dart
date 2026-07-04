import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app.dart';
import 'package:anbucheck/app/core/services/theme_service.dart';
import 'package:anbucheck/app/core/services/ad_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';
import 'package:anbucheck/app/core/services/stability_service.dart';

void main() async {
  // 릴리스 빌드에서는 debugPrint를 전역 비활성화 — logcat에 상태/스케줄/토큰 일부가
  // 남지 않도록 차단 (민감 로깅은 printLog의 kReleaseMode 가드와 이중 방어).
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // 세로 화면 전용 — 온보딩 등 목업 레이아웃이 가로 회전 시 오버플로우가 발생하고,
  // 이 앱의 대상 사용자(고령자 등)에게도 가로 모드는 필요하지 않다.
  // 네이티브(AndroidManifest screenOrientation, iOS Info.plist)에서도 동일하게 고정.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  // 첫 frame 전 launch 전이 구간에서 iOS가 UIStatusBarStyleDefault(시스템 다크모드 추종)로
  // 흰 텍스트가 표시되는 케이스 방지 — 기본 라이트 테마 기준 dark icons로 선설정.
  // 이후 app.dart의 AnnotatedRegion이 실제 테마(다크 토글 포함)를 반영해 즉시 갱신.
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  await HeartbeatWorkerService.init();
  Get.put(ThemeService());
  Get.put(StabilityService());
  // AdMob 초기화 — Android 전용.
  // iOS는 ATT 권한 흐름이 권한 화면(PermissionController)에서 제어되므로
  // 여기서 초기화하면 ATT 팝업이 Splash 이전에 뜨는 문제가 발생한다.
  // iOS 신규/재설치 사용자: PermissionController.requestPermissions() 에서 ATT → init.
  // iOS 기존 토큰 보유 사용자: SplashController._initialize() 에서 init.
  if (!Platform.isIOS) {
    await Get.putAsync(() => AdService().init(), permanent: true);
  }
  runApp(const App());
}
