import 'package:get/get.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

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

  /// 분할 가능 상태로 대시보드가 최상단에 있는가 — 푸시 탭이 오른쪽 pane에 열릴 수 있는 조건.
  static bool get paneActive =>
      paneId != null && Get.currentRoute == AppRoutes.guardianDashboard;

  /// 콜드 스타트 푸시 탭: 대시보드 직후엔 셸이 pane을 아직 켜지 않았을 수 있어 잠시 기다린다.
  /// 분할 불가(폰·접힘)면 기다림 없이 기존처럼 루트에 push.
  static Future<void> pushFromLaunch(String route, {dynamic arguments}) async {
    for (var i = 0; i < 10 && paneId == null; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    if (paneActive) {
      await offNamed(route, arguments: arguments);
    } else {
      await Get.toNamed(route, arguments: arguments);
    }
  }

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

  static void back<T>({T? result}) {
    final id = paneId;
    if (id != null) {
      // pane에서는 Navigator를 직접 pop한다. `Get.back`은 스낵바가 떠 있으면 페이지가 아니라
      // 스낵바만 닫고 끝내서(GetX 4.x 호환 코드) 연결 성공 직후 화면이 안 닫힐 수 있다.
      final nav = Get.nestedKey(id)?.currentState;
      if (nav != null && nav.canPop()) nav.pop<T>(result);
      return;
    }
    Get.back<T>(result: result);
  }
}
