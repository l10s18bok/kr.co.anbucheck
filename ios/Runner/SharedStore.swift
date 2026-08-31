import Foundation

/// 앱 ↔ Notification Service Extension 상태 공유 다리.
///
/// **왜 필요한가.** 확장은 앱과 **별도 프로세스**라 앱의 컨테이너를 볼 수 없다. 그런데
/// 확장이 heartbeat를 보내려면 `device_token`이 필요하고, 보낸 뒤에는 앱이 그 사실을
/// 알아야 한다 — 모르면 앱이 포그라운드 진입 시 "오늘 미전송"으로 판단해 **또 보낸다.**
/// (중복 방지 장치인 `HeartbeatLockDatasource`는 SQLite라 앱 컨테이너 안에 있고,
///  확장은 접근할 수 없다. 그래서 마커를 App Group에 두고 앱이 흡수한다.)
///
/// **왜 이 방식인가.** Flutter `shared_preferences`는 iOS에서 `UserDefaults.standard`에
/// `flutter.` 접두어로 저장한다. 플러그인을 App Group suite로 통째로 전환하면 기존
/// 사용자 데이터 마이그레이션이 필요해 위험 대비 이득이 없다. 그래서 **필요한 키만
/// 명시적 시점에 복사하는 다리**를 놓는다 — 기존 Dart 저장 경로는 전혀 건드리지 않는다.
enum SharedStore {

  /// 확장이 성공 시 보여줄 문구 + 오프라인 폴백 문구.
  /// 확장은 GetX 번역을 쓸 수 없으므로, 앱이 포그라운드에서 캐시해 둔 값을 넘긴다
  /// (NotificationTextCache가 `flutter.noti_text_<키>`에 저장한다).
  private static let textKeys = [
    "nse_delivered_title", "nse_delivered_body",
    "offline_alarm_title", "offline_alarm_body",
  ]

  private static var group: UserDefaults? { HeartbeatStore.group }

  /// shared_preferences가 쓰는 실제 키 이름
  private static func std(_ key: String) -> String { "flutter." + key }

  /// ⚠️ Dart `ApiConfig.baseUrl`이 prefs에 아직 안 쓰였을 때만 쓰는 폴백.
  /// 정상 경로는 앱이 시작 시 `api_base_url`을 prefs에 기록하는 것이다.
  private static let apiBaseFallback = "https://web-production-43beb.up.railway.app"

  // MARK: - 앱 → 확장

  /// 확장이 쓸 값들을 App Group으로 내보낸다.
  /// 호출 시점: 런치 직후 + 백그라운드 진입(확장이 도는 동안 최신값을 보게 하려고).
  static func exportToExtension() {
    guard let g = group else { return }
    let d = UserDefaults.standard

    g.set(d.string(forKey: std("device_token")), forKey: HeartbeatStore.K.deviceToken)
    g.set(d.string(forKey: std("device_id")), forKey: HeartbeatStore.K.deviceId)
    g.set(d.string(forKey: std("api_base_url")) ?? apiBaseFallback, forKey: HeartbeatStore.K.apiBase)
    g.set(d.string(forKey: std("last_heartbeat_date")), forKey: HeartbeatStore.K.lastDate)

    // ── 계측 ① 앱 포그라운드 마커 ─────────────────────────
    // "오늘 사용자가 앱을 열었는가"를 확장에 알린다. 잠금 프로브(§18.10)는 정확하지만
    // **창이 극도로 좁다** — 화면을 끄는 즉시 N이라 "지금 보고 있다"만 잡는다.
    // 이 마커는 반대로 **하루 단위**라, 아침에 한 번 열었어도 저녁 확장 실행에서
    // 잡힌다. 두 신호는 서로의 사각을 메운다.
    // export는 런치 직후 + 백그라운드 진입에 호출되므로, 앱이 떴다는 사실이 곧 기록된다.
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    g.set(f.string(from: Date()), forKey: HeartbeatStore.K.appFgDate)

    // ⚠️ **안부를 보내는 쪽인지**를 확장에 알린다. invite_code가 있으면 대상자다
    // (G+S 포함). 이게 없으면 피기백이 순수 보호자 기기에서도 발동해, 보호자가
    // 대상자 알림을 받을 때마다 자기 heartbeat를 서버로 보내게 된다.
    // 트리거 푸시는 서버가 G+S에게만 보내 안전했지만, 피기백은 **모든 보호자에게
    // 가는 알림에 얹히므로** 그 게이팅이 통하지 않는다.
    let inviteCode = d.string(forKey: std("invite_code")) ?? ""
    g.set(!inviteCode.isEmpty, forKey: HeartbeatStore.K.isSubject)

    // shared_preferences의 setInt는 NSNumber로 저장된다
    if let h = d.object(forKey: std("heartbeat_hour")) as? NSNumber { g.set(h.intValue, forKey: HeartbeatStore.K.hour) }
    if let m = d.object(forKey: std("heartbeat_minute")) as? NSNumber { g.set(m.intValue, forKey: HeartbeatStore.K.minute) }

    for key in textKeys {
      if let v = d.string(forKey: std("noti_text_" + key)) {
        g.set(v, forKey: HeartbeatStore.K.textPrefix + key)
      }
    }
  }

  // MARK: - 확장 → 앱

  /// 확장이 남긴 전송 마커를 앱의 prefs로 흡수한다.
  ///
  /// ⚠️ **`super.application(...)`(= Flutter 엔진 시작)보다 먼저 호출해야** Dart가
  /// 첫 조회에서 최신값을 본다. 늦으면 앱이 "오늘 미전송"으로 판단해 중복 전송한다.
  ///
  /// 날짜 문자열은 `yyyy-MM-dd`라 사전식 비교가 곧 시간순 비교다.
  /// 마커는 지우지 않는다 — 비교 기반이라 여러 번 흡수해도 결과가 같다(멱등).
  @discardableResult
  static func importFromExtension() -> Bool {
    guard let g = group, let sentDate = g.string(forKey: HeartbeatStore.K.sentDate), !sentDate.isEmpty else {
      return false
    }
    let d = UserDefaults.standard
    let known = d.string(forKey: std("last_heartbeat_date")) ?? ""
    guard sentDate > known else { return false }

    d.set(sentDate, forKey: std("last_heartbeat_date"))
    if let t = g.string(forKey: HeartbeatStore.K.sentTime) { d.set(t, forKey: std("last_heartbeat_time")) }
    if let k = g.string(forKey: HeartbeatStore.K.sentKey) { d.set(k, forKey: std("last_scheduled_key")) }

    NSLog("[SharedStore] 확장 전송 마커 흡수: %@ (이전 %@)", sentDate, known.isEmpty ? "없음" : known)
    return true
  }
}
