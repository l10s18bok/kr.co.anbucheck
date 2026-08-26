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
        static let textPrefix  = "hb_text_"      // 번역 문구 (백그라운드 캐시 패턴)

        // 확장 → 앱
        static let sentDate = "nse_sent_date"
        static let sentTime = "nse_sent_time"
        static let sentKey  = "nse_sent_key"
        static let lastLog  = "nse_last_log"
    }

    /// 오프라인 폴백 알림 식별자 접두어. 날짜별 **단발** 요청이라
    /// 확장이 "그날치만" 제거할 수 있다(반복 요청이면 제거 시 이후가 전부 사라진다).
    static let offlineIdPrefix = "anbu_offline_"
    /// 푸시가 도착했어야 할 시각으로부터 이만큼 뒤에 발화 — 그 사이 확장이 지운다.
    static let offlineDelayMinutes = 15
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
            lastSentDate: g.string(forKey: K.lastDate) ?? ""
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
        let title = text("offline_alarm_title", fallback: "Check your internet connection")
        let body = text(
            "offline_alarm_body",
            fallback: "Tap this notification once you're back online.\nOtherwise today's wellness check won't be sent."
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
