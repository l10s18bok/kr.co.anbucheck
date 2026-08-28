import Foundation
import UserNotifications

/// 앱과 확장이 **함께 컴파일하는** 공유 저장소.
///
/// ⚠️ 이 파일은 Runner 타겟과 HeartbeatNSE 타겟 **양쪽에 포함**된다.
/// 키 목록을 두 벌로 나누면 한쪽만 고쳤을 때 조용히 어긋나고, 그 증상은
/// "확장이 아무것도 못 읽는다"로 나타나 원인 추적이 어렵다.
struct HeartbeatStore {

    /// ⚠️ 앱·확장 양쪽 entitlement의 App Group과 정확히 일치해야 한다.
    static let appGroupId = "group.kr.co.anbucheck.live"

    enum K {
        // 앱 → 확장
        static let deviceToken = "hb_device_token"
        static let deviceId    = "hb_device_id"
        static let apiBase     = "hb_api_base"
        static let hour        = "hb_hour"
        static let minute      = "hb_minute"
        static let lastDate    = "hb_last_date"
        /// 이 기기가 **안부를 보내는 쪽**인가(G+S 또는 순수 대상자).
        /// 순수 보호자는 false — 확장이 이 기기로 heartbeat를 보내면 안 된다.
        static let isSubject   = "hb_is_subject"
        static let textPrefix  = "hb_text_"      // 번역 문구 (백그라운드 캐시 패턴)

        // 확장 → 앱
        static let sentDate = "nse_sent_date"
        static let sentTime = "nse_sent_time"
        static let sentKey  = "nse_sent_key"
        static let lastLog  = "nse_last_log"
        static let inflight = "nse_inflight"
    }

    /// 오프라인 폴백 알림 식별자 접두어. 날짜별 **단발** 요청이라
    /// 확장이 "그날치만" 제거할 수 있다(반복 요청이면 제거 시 이후가 전부 사라진다).
    static let offlineIdPrefix = "anbu_offline_"
    /// 푸시가 도착했어야 할 시각으로부터 이만큼 뒤에 발화 — 그 사이 확장이 지운다.
    ///
    /// ⚠️ **15분이었다가 45분으로 늘렸다(2026-08-27). 되돌리지 말 것.**
    /// 로컬 알림은 예약시각에 **정확히** 발화하는데, 원격 푸시는 기기가 깨어날 때까지
    /// 보관됐다 전달된다(실측 지연 +9분·+15분·+19분). 이 비대칭 때문에 15분은 경계선
    /// 위였고, 08-27에는 전송 성공(06:14:51)과 폴백 발화(06:15:00)가 **9초** 차이였다.
    /// 45분이면 관측 상한의 2배 이상이면서 보호자 미수신 경고(+2h)까지 75분이 남아,
    /// 대상자가 스스로 고칠 창이 실질적으로 확보된다.
    static let offlineDelayMinutes = 45
    /// 재무장 창. 한 번의 실패로 최후 보루가 죽지 않도록 롤링으로 채운다.
    static let offlineRollingDays = 7

    static var group: UserDefaults? { UserDefaults(suiteName: appGroupId) }

    // MARK: - 값

    let deviceToken: String
    let deviceId: String
    let apiBase: String
    let hour: Int
    let minute: Int
    let lastSentDate: String
    /// 안부를 보내는 쪽인가. **순수 보호자면 false** — 피기백이 오발동하면
    /// 보호자 기기가 자기 heartbeat를 보내게 된다(§16).
    let isSubject: Bool

    /// 자동 heartbeat의 idempotency key — 서버 계약상 "YYYY-MM-DD_HH:mm"
    var scheduledKey: String {
        String(format: "%@_%02d:%02d", HeartbeatStore.today(), hour, minute)
    }

    static func load() -> HeartbeatStore? {
        guard let g = group,
              let token = g.string(forKey: K.deviceToken), !token.isEmpty,
              let devId = g.string(forKey: K.deviceId), !devId.isEmpty,
              let base = g.string(forKey: K.apiBase), !base.isEmpty
        else { return nil }

        return HeartbeatStore(
            deviceToken: token,
            deviceId: devId,
            apiBase: base,
            hour: g.object(forKey: K.hour) as? Int ?? 18,
            minute: g.object(forKey: K.minute) as? Int ?? 0,
            lastSentDate: g.string(forKey: K.lastDate) ?? "",
            // ⚠️ 기본값 false. 값이 없으면 **보내지 않는 쪽**으로 떨어져야 안전하다 —
            // 잘못 보내는 것(보호자가 대상자처럼 기록됨)이 안 보내는 것보다 나쁘다.
            isSubject: g.bool(forKey: K.isSubject)
        )
    }

    // MARK: - 날짜/문구/로그

    static func today() -> String { dayFormatter.string(from: Date()) }

    static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    /// 확장은 GetX 번역을 쓸 수 없다. 앱이 포그라운드에서 캐시해 둔 문구를 읽는다
    /// (안드로이드 백그라운드 isolate가 쓰는 NotificationTextCache와 같은 패턴).
    static func text(_ key: String, fallback: String) -> String {
        guard let v = group?.string(forKey: K.textPrefix + key), !v.isEmpty else { return fallback }
        return v
    }

    static func log(_ message: String) {
        NSLog("[HeartbeatNSE] %@", message)
        group?.set("\(Date()): \(message)", forKey: K.lastLog)
    }

    // MARK: - 확장 → 앱 마커

    /// 전송 성공을 App Group에 남긴다. 앱은 다음 진입 시 이걸 흡수해
    /// `last_heartbeat_date`에 반영하고, 기존 가드로 중복 전송을 건너뛴다.
    static func markSent(scheduledKey: String) {
        guard let g = group else { return }
        let now = Date()
        let t = DateFormatter()
        t.dateFormat = "HH:mm"
        t.locale = Locale(identifier: "en_US_POSIX")

        g.set(today(), forKey: K.sentDate)
        g.set(t.string(from: now), forKey: K.sentTime)
        g.set(scheduledKey, forKey: K.sentKey)
        // 확장 자신도 같은 값을 보고 판단하므로 즉시 갱신한다(같은 날 재발송 차단)
        g.set(today(), forKey: K.lastDate)
    }

    // MARK: - 오프라인 폴백 알림

    /// 확장 인스턴스 간 **중복 전송 방지** 마커. 잡으면 true.
    ///
    /// ⚠️ 피기백(§14.3)이 들어가면서 필요해졌다. 보호자 알림 여러 건이 거의 동시에
    /// 도착하면 확장이 **병렬로 여러 개** 뜨고, 각자 "오늘 미전송"으로 보고 동시에
    /// 전송할 수 있다. iOS 확장에는 안드로이드의 SQLite UNIQUE 같은 **원자 락이 없다** —
    /// UserDefaults는 CAS가 아니라 read→write 사이 틈이 남는다. 완벽하지 않지만
    /// 실제로 문제가 되는 "수백 ms 간격 병렬 기동"은 이걸로 막힌다.
    ///
    /// 서버의 `is_first_today` 판정이 `auto_report` 중복 푸시까지는 막아주지만,
    /// `heartbeat_logs`에 행이 둘 생기는 것은 막지 못한다.
    static func tryAcquireSendLock(ttl: TimeInterval = 30) -> Bool {
        guard let g = group else { return true }  // 못 읽으면 전송을 막지 않는다
        let now = Date().timeIntervalSince1970
        let prev = g.double(forKey: K.inflight)
        if prev > 0, now - prev < ttl { return false }  // 다른 인스턴스가 진행 중
        g.set(now, forKey: K.inflight)
        return true
    }

    static func releaseSendLock() {
        group?.removeObject(forKey: K.inflight)
    }

    /// 지금이 **오늘의** 예약시각을 지났는가.
    ///
    /// ⚠️ **자정을 넘겨 배달된 어제 트리거를 걸러내기 위한 것이다.**
    /// APNs는 기기가 깨어날 때까지 푸시를 보관하므로, 어제 18:00 트리거가 오늘 08:00에
    /// 배달될 수 있다. 그때 그냥 전송하면 `scheduled_key`가 `오늘_18:00`이 되어 서버가
    /// **오늘의 안부로 귀속**시키고, 그러면 오늘 18:00 트리거는 `last_seen`이 오늘이라
    /// 발사되지 않는다 → **그날 걸음수가 08시까지만** 기록된다.
    /// (안드로이드가 `heartbeatPayloadIsFromToday`로 막아둔 것과 같은 종류의 문제다.)
    ///
    /// 예약시각을 **지난 뒤의** 늦은 배달은 그대로 통과시킨다 — 그건 오늘 몫이 맞고,
    /// 늦게라도 보내는 것이 이 계층의 목적이다.
    static func scheduledTimePassed(hour: Int, minute: Int) -> Bool {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: Date())
        comps.hour = hour
        comps.minute = minute
        guard let scheduled = cal.date(from: comps) else { return true }  // 못 구하면 기존 동작
        return Date() >= scheduled
    }

    /// 오늘치 오프라인 폴백을 pending에서 제거한다.
    ///
    /// **이 제거가 이 설계의 핵심이다.** iOS 로컬 알림은 "망이 없을 때만 뜨게" 만들 수
    /// 없다 — 앱이 죽어 있어 조건을 판단할 주체가 없다. 그래서 조건을 뒤집는다:
    /// 무조건 심어두고, **푸시가 도착하면(=망이 있으면) 확장이 지운다.**
    /// 망이 없으면 푸시가 안 오고 확장도 안 돌아 알림이 그대로 발화한다.
    static func clearTodayOfflineFallback() {
        let center = UNUserNotificationCenter.current()
        let id = offlineIdPrefix + today()
        center.removePendingNotificationRequests(withIdentifiers: [id])
        // ⚠️ **표시된 것도 함께 지운다.** pending만 지우면, 폴백이 **이미 발화한 뒤**
        // 늦게 안부가 전달된 경우(재시도 성공·통신 복구 등) "누르지 않으면 오늘의 안부가
        // 전달되지 않습니다"가 트레이에 그대로 남아 **사실과 다른 안내**를 하게 된다.
        // 2026-08-23 실측: 06:15 폴백 발화 → 06:49 전송 성공 → 알림이 계속 남아 있었다.
        center.removeDeliveredNotifications(withIdentifiers: [id])
    }

    /// 앞으로 N일치 오프라인 폴백을 단발로 채운다(이미 있는 날은 같은 ID로 덮어씀).
    ///
    /// ⚠️ **롤링이 필수다.** 단발 알림 + 매일 재무장 구조는 재무장이 한 번만 실패해도
    /// 최후 보루가 조용히 사라진다 — 안드로이드에서 one-off 재무장 유실로 트리거가
    /// 영구 소실됐던 것과 같은 종류의 위험이다. 7일치를 미리 깔아 한 번의 실패를 흡수한다.
    static func rearmOfflineFallback(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        let cal = Calendar.current
        // ⚠️ **오늘 이미 전송됐으면 오늘치는 다시 심지 않는다.**
        // 성공 경로는 clearTodayOfflineFallback() **직후** 이 함수를 부른다. 그런데
        // 전송이 폴백 시각(+15분)보다 이르면 `fire > Date()`가 참이라 방금 지운 오늘치를
        // 같은 ID로 그대로 되살린다 — 그리고 전송이 폴백보다 이른 것이 **정상 성공
        // 케이스**라서 성공할 때마다 발동한다.
        // 2026-08-27 실측: 06:14:51 전송 성공 → 06:15:00 "인터넷 연결 확인" 발화.
        // (8/23에 본 "전송했는데 알림이 남아 있다"도 같은 원인이었고, removeDelivered
        //  추가는 증상만 덮은 것이었다.)
        let sentToday = group?.string(forKey: K.lastDate) == today()
        // ⚠️ 문구는 **원인을 특정하지 않는다.** 이전 문구는 "인터넷이 연결되면…"이라
        // 망 문제를 단정했는데, 실제로는 APNs 슬롯 덮어쓰기(§13.5)나 확장 실패로도 뜬다 —
        // 망이 멀쩡한데 "인터넷 연결 확인"이 뜨는 일이 드물지 않다. 이 알림이 참인 조건은
        // 하나뿐이다: **오늘 안부가 아직 나가지 않았다.** 문구도 그것만 말한다.
        let title = text("offline_alarm_title", fallback: "💗 Today's wellness check hasn't been sent")
        let body = text(
            "offline_alarm_body",
            fallback: "Tap this notification once.\nTapping sends your wellness check to your guardian."
        )

        for offset in 0..<offlineRollingDays {
            if offset == 0 && sentToday { continue }
            guard let day = cal.date(byAdding: .day, value: offset, to: Date()) else { continue }
            var comps = cal.dateComponents([.year, .month, .day], from: day)
            comps.hour = hour
            comps.minute = minute
            guard let base = cal.date(from: comps),
                  let fire = cal.date(byAdding: .minute, value: offlineDelayMinutes, to: base),
                  fire > Date()  // 이미 지난 시각은 심지 않는다
            else { continue }

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            content.userInfo = ["type": "offline_fallback"]

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: cal.dateComponents([.year, .month, .day, .hour, .minute], from: fire),
                repeats: false
            )
            let id = offlineIdPrefix + dayFormatter.string(from: day)
            center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        }
    }
}
