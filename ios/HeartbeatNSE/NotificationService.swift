import CoreMotion
import UIKit
import UserNotifications

/// iOS heartbeat 트리거 확장.
///
/// iOS는 앱이 강제 종료되면 어떤 스케줄러도 돌지 않는다. 킬 상태에서도 실행되는 유일한
/// 경로가 **표시형 푸시가 띄우는 이 확장**이며, 여기서 heartbeat를 직접 전송한다.
/// 그래서 사용자가 알림을 **탭하지 않아도** 안부가 전달된다.
/// (실측 근거: `.claude/rules/ios_nse_field_notes.md` — 강제 종료 + 화면 잠금 상태에서
///  확장 실행, HTTPS 왕복 성공, 걸음수 조회, pending 알림 제거까지 확인)
final class NotificationService: UNNotificationServiceExtension {

    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var original: UNNotificationContent?
    private var mutable: UNMutableNotificationContent?

    /// CMPedometer는 강한 참조를 유지해야 콜백이 온다
    private let pedometer = CMPedometer()

    private static let overallBudget: TimeInterval = 20.0  // iOS 상한 30초보다 여유
    private static let netTimeout: TimeInterval = 10.0
    private static let stepTimeout: TimeInterval = 3.0

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        self.original = request.content

        // ─────────────────────────────────────────────────────────────
        // ⚠️ 불변 규칙 — 지정 타입이 아니면 **즉시 원본 통과**시킨다.
        //
        // 서버는 `push_service.send_push`에서 **모든 푸시에 mutable_content=True**를
        // 붙인다. 따라서 이 확장이 존재하는 순간 보호자 경고·긴급·구독 안내까지 전부
        // 여기를 통과한다. 아래 분기 없이 본문을 가공하면 경고 문구가 훼손되고,
        // 네트워크를 기다리면 **긴급 경고가 그만큼 늦게 뜬다**.
        // 이 가드를 지우거나 아래로 옮기지 말 것.
        // ─────────────────────────────────────────────────────────────
        guard (request.content.userInfo["type"] as? String) == "heartbeat_push" else {
            contentHandler(request.content)
            return
        }

        guard let body = request.content.mutableCopy() as? UNMutableNotificationContent else {
            contentHandler(request.content)
            return
        }
        self.mutable = body

        // 예산 초과 시에도 반드시 무언가를 배달한다(안 하면 iOS가 원본을 띄운다 —
        // 그 경우도 안전하지만, 여기서 명시적으로 끝내 로그를 남긴다).
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.overallBudget) { [weak self] in
            self?.finish(success: false, note: "budget")
        }

        guard let store = HeartbeatStore.load() else {
            // 토큰이 없다(미등록/로그아웃). 원본 문구를 그대로 보여 사용자가 탭하게 둔다.
            finish(success: false, note: "no-credentials")
            return
        }

        // 이미 오늘 보냈으면 통신하지 않는다 — 앱이 먼저 보낸 날의 중복 전송 차단.
        if store.lastSentDate == HeartbeatStore.today() {
            HeartbeatStore.clearTodayOfflineFallback()
            // ⚠️ 이 분기에서도 롤링 창을 채운다. 빼면 앱이 먼저 보낸 날마다 7일 창이
            // 하루씩 줄어들고, 복구가 "사용자가 앱을 여는 것"에 의존하게 된다 —
            // 이 앱의 대상자는 앱을 열지 않는 것이 정상 사용 패턴이다.
            HeartbeatStore.rearmOfflineFallback(hour: store.hour, minute: store.minute)
            finish(success: true, note: "already-sent")
            return
        }

        collectSteps { steps in
            self.send(store: store, steps: steps) { ok in
                if ok {
                    HeartbeatStore.markSent(scheduledKey: store.scheduledKey)
                    HeartbeatStore.clearTodayOfflineFallback()
                    HeartbeatStore.rearmOfflineFallback(hour: store.hour, minute: store.minute)
                }
                self.finish(success: ok, note: ok ? "sent" : "send-failed")
            }
        }
    }

    /// iOS가 30초 예산 만료를 알릴 때 — 여기서 안 띄우면 원본이 표시된다(=현행 동작).
    override func serviceExtensionTimeWillExpire() {
        finish(success: false, note: "expired")
    }

    // MARK: - 배달

    /// 성공하면 문구를 "전달 완료"로 바꾸고 **무음·배너 없음**으로 내린다.
    /// 실패하면 원본(탭 유도) 그대로 — 확장이 못 돌았을 때와 같은 상태로 안전하게 되돌아간다.
    private func finish(success: Bool, note: String) {
        guard let handler = contentHandler else { return }
        contentHandler = nil  // 중복 배달 방지

        HeartbeatStore.log("nse \(note)")

        guard success, let body = mutable else {
            handler(original ?? UNMutableNotificationContent())
            return
        }

        body.title = HeartbeatStore.text("nse_delivered_title", fallback: "Wellness check sent")
        body.body = HeartbeatStore.text(
            "nse_delivered_body",
            fallback: "Today's wellness check has been delivered."
        )
        // 사용자가 **아무것도 하지 않아도 된다**는 것을 표시 강도로도 알린다.
        body.sound = nil
        if #available(iOS 15.0, *) {
            body.interruptionLevel = .passive  // 배너 없이 알림센터에만
        }
        handler(body)
    }

    // MARK: - 걸음수

    /// 실패해도 전송은 진행한다 — 걸음수는 부가 정보고, 안부 신호가 본질이다.
    private func collectSteps(_ done: @escaping (Int?) -> Void) {
        guard CMPedometer.isStepCountingAvailable() else { done(nil); return }

        var finished = false
        let complete: (Int?) -> Void = { v in
            guard !finished else { return }
            finished = true
            done(v)
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + Self.stepTimeout) { complete(nil) }

        pedometer.queryPedometerData(from: Calendar.current.startOfDay(for: Date()), to: Date()) {
            data, _ in
            complete(data?.numberOfSteps.intValue)
        }
    }

    // MARK: - 전송

    private func send(store: HeartbeatStore, steps: Int?, done: @escaping (Bool) -> Void) {
        guard let url = URL(string: store.apiBase + "/api/v1/heartbeat") else { done(false); return }

        var payload: [String: Any] = [
            "device_id": store.deviceId,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "scheduled_key": store.scheduledKey,
            // ⚠️ 확장 전송은 항상 suspicious=false다.
            // 지금까지 iOS heartbeat는 전부 포그라운드에서 나가 `isInteractiveAtTrigger: true`가
            // 하드코딩됐고, 그래서 **iOS는 "활동 기록 없음" 경고를 한 번도 낸 적이 없다**.
            // 확장에는 화면 상태 신호가 없어(iOS 확장은 UIApplication 접근 불가) 걸음수만
            // 남는데, 걸음수만으로 판정하면 안드로이드보다 **더 엄격해진다**(안드로이드는
            // 화면 켜짐이라는 구제 조건이 하나 더 있다). 없던 경고 종류를 "탭 없이 전달"이라는
            // 핵심 변경과 같은 릴리스에 넣지 않기로 했다. 걸음수는 계속 실어 보내므로
            // 실제 분포가 쌓이고, 나중에 켜는 것은 쉽다. 상세는 PRD-FrontEnd §2.3.
            "suspicious": false,
        ]
        if let steps = steps { payload["steps_delta"] = steps }
        if let battery = batteryLevel() { payload["battery_level"] = battery }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer " + store.deviceToken, forHTTPHeaderField: "Authorization")
        req.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        let cfg = URLSessionConfiguration.ephemeral
        cfg.timeoutIntervalForRequest = Self.netTimeout
        cfg.timeoutIntervalForResource = Self.netTimeout

        URLSession(configuration: cfg).dataTask(with: req) { _, resp, err in
            let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
            if let err = err {
                HeartbeatStore.log("post error: \(err.localizedDescription)")
            }
            done((200...299).contains(code))
        }.resume()
    }

    /// 확장에서도 UIDevice는 쓸 수 있다(UIApplication과 달리). 실패하면 nil.
    private func batteryLevel() -> Int? {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = UIDevice.current.batteryLevel
        guard level >= 0 else { return nil }  // -1 = 확인 불가
        return Int((level * 100).rounded())
    }
}
