import 'package:get/get.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';

/// 구독 활성 상태 단일 반응형 소스(single source of truth).
///
/// `subscription_active`를 기록하는 모든 경로(IAP verify, 서버 /subjects·/devices/me
/// 응답)가 [set]으로 일원화하고, 모든 보호자 화면은 [isActive]를 Obx로 구독한다.
/// [set](true)는 즉시 전 화면 잠금 해제 트리거가 된다 — 대시보드/알림 컨트롤러가
/// `ever(isActive)`로 재조회하므로, 재구독/첫 구독 verify 성공 시 모든 모니터링
/// 화면이 동시에 풀린다.
///
/// **게이팅 범위는 보호자(guardian) 모니터링에 한정**한다 — 구독 만료 시 대시보드
/// 대상자 카드·걸음수 그래프와 알림 목록의 데이터 로드를 차단한다. 대상자(subject)
/// 측(= G+S 본인 heartbeat 전송, safety_home 안전코드 페이지의 `guardianCount`
/// 게이팅)에는 일절 관여하지 않는다. 이 서비스는 데이터 흐름(쓰기/읽기)만 제공하고,
/// safety_home은 이 값을 읽기-게이트로 사용하지 않는다.
class SubscriptionService extends GetxService {
  final _tokenDs = TokenLocalDatasource();

  /// 구독 활성 여부. 영속값(SharedPreferences)으로 init되며, 보호자 모니터링
  /// 게이트의 단일 진실. 하드코딩 true가 아니라 마지막으로 알려진 값으로 시작해
  /// 만료 사용자가 콜드 스타트 시 곧바로 잠금 상태가 되도록 한다.
  final isActive = false.obs;

  Future<SubscriptionService> init() async {
    isActive.value = await _tokenDs.getSubscriptionActive();
    return this;
  }

  /// Rx + 영속 동시 갱신. subscription_active를 쓰는 모든 경로는 이 메서드를 경유한다.
  /// (RxBool은 동일값 재할당 시 notify하지 않으므로 set(true)↔재조회 피드백 루프 없음.)
  Future<void> set(bool active) async {
    await _tokenDs.saveSubscriptionActive(active);
    isActive.value = active;
  }
}
