import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `DateTime` → `YYYY-MM-DD` (로컬 날짜)
String formatYmd(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

/// (hour, minute) → `HH:MM`
String formatHm(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

/// SharedPreferences를 디스크와 동기화 후 반환
/// iOS 백그라운드 복귀 시 캐시 불일치 방지
Future<SharedPreferences> getReloadedPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  return prefs;
}

/// "HH:mm" (24시간제) → "오전/오후 H:mm" (12시간제) 변환
String formatTo12Hour(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length != 2) return hhmm;

  final hour = int.tryParse(parts[0]);
  final minute = parts[1];
  if (hour == null) return hhmm;

  final period = hour < 12 ? 'common_am'.tr : 'common_pm'.tr;
  final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  return '$period $displayHour:$minute';
}
