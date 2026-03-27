import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app.dart';
import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/services/fcm_service.dart';
import 'package:anbucheck/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // HTTP 클라이언트 초기화 (FCM 서비스보다 먼저 호출)
  ApiClientFactory.init(type: HttpClientType.getConnect);

  // FCM 백그라운드 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // FCM 서비스 초기화 (ApiClientFactory 이후에 호출)
  await Get.putAsync(() => FcmService().init());

  runApp(const App());
}
