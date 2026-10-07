import 'package:get/get.dart';

/// "라벨 ↔ 값" 사이 구분자 — 문장부호 규칙이 언어마다 달라 코드로 조합하는 문장에 쓴다.
///
/// · 프랑스어: 콜론 앞에 줄바꿈 없는 공백(` : `) — 줄 끝에서 콜론만 떨어지지 않게
/// · 일본어·중국어: 전각 콜론 `：`(앞뒤 공백 없음)
/// · 한국어: 호출부가 기존 표기를 유지할 수 있게 [koSpaced]로 고른다
///   (활동량·마지막 안부 확인은 영상 확정본에 맞춰 ` : `, 등급 카운터는 `: `)
/// · 그 외: `: `
String labelSeparator({bool koSpaced = false}) {
  switch (Get.locale?.languageCode) {
    case 'ko':
      return koSpaced ? ' : ' : ': ';
    case 'fr':
      return ' : ';
    case 'ja':
    case 'zh':
      return '：';
    default:
      return ': ';
  }
}
