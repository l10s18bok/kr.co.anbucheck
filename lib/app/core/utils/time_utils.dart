import 'dart:ui' show PlatformDispatcher;

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

/// 로케일별 시각 표기 방식. 번역 파일의 `common_time_style` 값으로 결정된다.
enum TimeStyle {
  /// 12시간제 + 구분자를 **앞**에 — 한국어/일본어/중국어 ("오후 3:12")
  pre12,

  /// 12시간제 + 구분자를 **뒤**에 — 영어/아랍어 ("3:12 PM")
  post12,

  /// 24시간제 — 그 외 14개 언어 ("15:12")
  h24,
}

/// ⚠️ 로케일별 시각 표기는 **반드시 이 함수들만** 사용한다.
///
/// 과거에는 각 화면이 `'$period $hour:$minute'`를 직접 조립해, 한국어 어순이
/// 20개 언어 전부에 적용됐다. 프랑스어에서 `PM 06:00`처럼 뜻이 통하지 않는
/// 표기가 나온 원인이다(24시간제 문화권 + 어순 반대 + AM/PM 미사용).
///
/// 표시 문자열을 다시 파싱해 시·분을 얻는 코드도 두지 않는다 — 표기 방식이
/// 로케일마다 다른 순간 그 파서는 반드시 깨진다. 시·분은 항상 int로 들고
/// 다니고, 이 함수는 **표시 직전 단방향 변환**에만 쓴다.
///
/// **기기의 24시간제 설정이 언어 설정보다 우선한다.** 두 가지 이유다:
///   1. 지원하지 않는 언어(그리스어·체코어·헝가리어·핀란드어·히브리어 등)는
///      GetX가 `fallbackLocale`인 en_US로 떨어뜨리는데, en_US는 `post12`라
///      **24시간제 국가 사용자에게 `10:00 PM`이 강제**된다. 미지원 언어권은
///      대부분 24시간제라 이 조합이 오히려 다수 케이스다.
///   2. 지원 언어라도 사용자가 OS에서 24시간제를 켰다면 그 의사가 우선이다.
///
/// ⚠️ 반대 방향(기기 12시간제 + 언어 h24)은 **강제하지 않는다.** 그 언어권에서는
/// 24시간제가 표준 표기이고, 12시간제로 내리려면 `common_am`/`common_pm`이
/// 정확해야 하는데 언어별 정확도가 고르지 않다(태국어 `บ่าย`는 13~16시,
/// 인도네시아어 `sore`는 늦은 오후만 뜻해 밤 시간을 오표기한다). 이 비대칭은
/// 의도된 것이므로 "일관성"을 이유로 양방향으로 만들지 말 것.
TimeStyle get timeStyle {
  if (PlatformDispatcher.instance.alwaysUse24HourFormat) return TimeStyle.h24;
  return switch ('common_time_style'.tr) {
    'pre12' => TimeStyle.pre12,
    'post12' => TimeStyle.post12,
    // 키 누락/오타 시 24시간제로 폴백 — 어느 언어에서도 뜻이 왜곡되지 않는
    // 유일한 표기이므로 가장 안전한 기본값이다.
    _ => TimeStyle.h24,
  };
}

/// (hour, minute) → 로케일 표기 문자열
String formatTimeOfDay(int hour, int minute) {
  final m = minute.toString().padLeft(2, '0');
  final style = timeStyle;
  if (style == TimeStyle.h24) {
    return '${hour.toString().padLeft(2, '0')}:$m';
  }
  final period = hour < 12 ? 'common_am'.tr : 'common_pm'.tr;
  final h12 = hour % 12 == 0 ? 12 : hour % 12;
  return style == TimeStyle.pre12 ? '$period $h12:$m' : '$h12:$m $period';
}

/// "HH:mm" (24시간제 저장/전송 포맷) → 로케일 표기 문자열
String formatHhmmToDisplay(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length != 2) return hhmm;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return hhmm;
  return formatTimeOfDay(hour, minute);
}
