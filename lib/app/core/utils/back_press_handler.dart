import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 홈 화면 뒤로가기 2회 종료 핸들러
class BackPressHandler {
  BackPressHandler._();

  static DateTime? _lastPressed;

  static void onBackPressed() {
    final now = DateTime.now();
    if (_lastPressed != null && now.difference(_lastPressed!) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
    } else {
      _lastPressed = now;
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Image.asset('assets/icon/app_icon.png', width: 20, height: 20),
              const SizedBox(width: 8),
              Text('back_press_exit'.tr,
                  style: const TextStyle(color: Color(0xFF1a1c1c))),
            ],
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
