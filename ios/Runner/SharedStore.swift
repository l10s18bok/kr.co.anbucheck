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

  /// ⚠️ 앱·확장 양쪽 타겟의 App Group entitlement와 **정확히 일치**해야 한다.
  static let appGroupId = "group.kr.co.anbucheck.live"

  // 앱 → 확장 (확장이 heartbeat를 보내는 데 필요한 것)
  static let kDeviceToken = "hb_device_token"
  static let kDeviceId    = "hb_device_id"
  static let kApiBase     = "hb_api_base"
  static let kHour        = "hb_hour"
  static let kMinute      = "hb_minute"
  static let kLastDate    = "hb_last_date"     // 앱이 아는 마지막 전송일(yyyy-MM-dd)

  // 확장 → 앱 (확장이 보냈다는 사실)
  static let kNseSentDate = "nse_sent_date"
  static let kNseSentTime = "nse_sent_time"    // HH:mm
  static let kNseSentKey  = "nse_sent_key"     // scheduled_key
  static let kNseLastLog  = "nse_last_log"     // 진단용 마지막 실행 요약

  static var group: UserDefaults? { UserDefaults(suiteName: appGroupId) }

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

    g.set(d.string(forKey: std("device_token")), forKey: kDeviceToken)
    g.set(d.string(forKey: std("device_id")), forKey: kDeviceId)
    g.set(d.string(forKey: std("api_base_url")) ?? apiBaseFallback, forKey: kApiBase)
    g.set(d.string(forKey: std("last_heartbeat_date")), forKey: kLastDate)

    // shared_preferences의 setInt는 NSNumber로 저장된다
    if let h = d.object(forKey: std("heartbeat_hour")) as? NSNumber { g.set(h.intValue, forKey: kHour) }
    if let m = d.object(forKey: std("heartbeat_minute")) as? NSNumber { g.set(m.intValue, forKey: kMinute) }
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
    guard let g = group, let sentDate = g.string(forKey: kNseSentDate), !sentDate.isEmpty else {
      return false
    }
    let d = UserDefaults.standard
    let known = d.string(forKey: std("last_heartbeat_date")) ?? ""
    guard sentDate > known else { return false }

    d.set(sentDate, forKey: std("last_heartbeat_date"))
    if let t = g.string(forKey: kNseSentTime) { d.set(t, forKey: std("last_heartbeat_time")) }
    if let k = g.string(forKey: kNseSentKey) { d.set(k, forKey: std("last_scheduled_key")) }

    NSLog("[SharedStore] 확장 전송 마커 흡수: %@ (이전 %@)", sentDate, known.isEmpty ? "없음" : known)
    return true
  }
}
