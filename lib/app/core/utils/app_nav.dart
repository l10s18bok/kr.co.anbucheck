import 'package:get/get.dart';

/// 보호자 화면 이동 헬퍼 — 분할 화면(폴더블 펼침)에서 오른쪽 pane으로 보내기 위한 단일 진입점.
///
/// 화면(페이지) 이동에만 쓴다. 대화상자 닫기(`Get.back` + result)는 그대로 `Get.back`을 쓸 것 —
/// 대화상자는 루트 오버레이 위에 있어 pane Navigator로 pop하면 엉뚱한 화면이 닫힌다.
///
/// 1단계: 분할이 비활성이라 [paneId]가 항상 null → `Get.*` 호출과 동작이 완전히 같다.
class AppNav {
  AppNav._();

  /// 분할 중일 때 오른쪽 pane의 `Get.nestedKey` id. null이면 루트 Navigator(기존 동작).
  static int? paneId;

  static Future<T?>? toNamed<T>(String route, {dynamic arguments}) =>
      Get.toNamed<T>(route, arguments: arguments, id: paneId);

  /// pane 모드에서는 pane 스택 맨 아래(빈 시작 화면)만 남기고 교체 — 탭 전환이 스택에 쌓이지 않게.
  static Future<T?>? offNamed<T>(String route, {dynamic arguments}) {
    if (paneId != null) {
      return Get.offNamedUntil<T>(
        route,
        (r) => r.isFirst,
        arguments: arguments,
        id: paneId,
      );
    }
    return Get.offNamed<T>(route, arguments: arguments);
  }

  static void back<T>({T? result}) => Get.back<T>(result: result, id: paneId);
}
