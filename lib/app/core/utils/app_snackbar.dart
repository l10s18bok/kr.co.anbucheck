import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static const _bg = Color(0xFFFFFFFF);
  static const _fg = Color(0xFF1a1c1c);
  static const _duration = Duration(seconds: 3);

  static void show(
    String title,
    String message, {
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = _duration,
    TextButton? mainButton,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      duration: duration,
      backgroundColor: _bg,
      colorText: _fg,
      borderRadius: 12,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      mainButton: mainButton,
    );
  }

  static void message(
    String text, {
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = _duration,
  }) {
    Get.rawSnackbar(
      message: text,
      snackPosition: position,
      duration: duration,
      backgroundColor: _bg,
      messageText: Text(text, style: const TextStyle(color: _fg)),
      borderRadius: 12,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
