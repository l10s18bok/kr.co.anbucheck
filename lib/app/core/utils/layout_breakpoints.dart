/// 대형 화면(폴더블 펼침·태블릿) 분기 기준 폭(dp).
///
/// `App.largeScreenBreakpoint`(ScreenUtil designSize 확대)와 대시보드 카드 배치 분기가
/// **같은 값**을 써야 해서 한 곳에 둔다. Material 3 window size class의 medium 하한이자
/// Android가 방향·리사이즈 제한을 무시하기 시작하는 sw600dp와 같다.
///
/// ⚠️ 분기는 **창 폭**으로만 한다 — 기기 종류(idiom)로 판별하지 말 것(Apple 지침).
const double kLargeScreenBreakpoint = 600;
