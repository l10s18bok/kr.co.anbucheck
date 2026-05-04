import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app.dart';
import 'package:anbucheck/app/core/services/theme_service.dart';
import 'package:anbucheck/app/core/services/ad_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_worker_service.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // 첫 frame 전 launch 전이 구간에서 iOS가 UIStatusBarStyleDefault(시스템 다크모드 추종)로
  // 흰 텍스트가 표시되는 케이스 방지 — 기본 라이트 테마 기준 dark icons로 선설정.
  // 이후 app.dart의 AnnotatedRegion이 실제 테마(다크 토글 포함)를 반영해 즉시 갱신.
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  await HeartbeatWorkerService.init();
  Get.put(ThemeService());
  // ATT(App Tracking Transparency) — iOS 14.5+ IDFA 접근. AdMob 초기화 전 처리.
  // 실패/거부 어떤 경우에도 광고는 비개인화로 fallback되며 앱 동작에는 영향 없음.
  if (Platform.isIOS) {
    try {
      await AppTrackingTransparency.requestTrackingAuthorization();
    } catch (_) {}
  }
  await Get.putAsync(() => AdService().init());
  runApp(const App());
}
