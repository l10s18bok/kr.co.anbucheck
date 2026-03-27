/// UseCase 베이스 인터페이스
/// [T] : 반환 타입
/// [Params] : 입력 파라미터 타입
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// 파라미터가 필요 없는 UseCase용
class NoParams {
  const NoParams();
}
