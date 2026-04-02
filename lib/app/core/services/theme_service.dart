import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anbucheck/app/core/theme/app_theme.dart';

/// 다크모드 상태 관리 서비스
/// SharedPreferences로 사용자 설정 영구 저장
class ThemeService extends GetxService {
  static const _key = 'isDarkMode';

  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool(_key) ?? false;
    if (isDarkMode.value) {
      Get.changeTheme(AppTheme.darkTheme);
    }
  }

  Future<void> toggle() async {
    isDarkMode.value = !isDarkMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDarkMode.value);
    Get.changeTheme(
      isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme,
    );
    Get.forceAppUpdate();
  }
}
