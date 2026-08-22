import CoreMotion
import UserNotifications

/// iOS Notification Service Extension 프로브 (버리는 코드 — probe/ios-nse 전용)
///
/// 검증 대상 3개:
///   Q1 net   — 확장 프로세스에서 네트워크가 열리는가 (앱 강제 종료 상태 포함)
///   Q2 pend  — 확장이 **다른 프로세스가 심어둔** pending 알림을 지우고 새로 심을 수 있는가
///   Q3 steps — 확장 안에서 CMPedometer로 걸음수를 읽을 수 있는가
///
/// ⚠️ **판독 규칙 — 대조군이 핵심이다.**
/// 확장이 실행되면 알림 제목/본문이 측정값으로 **반드시** 덮어써진다.
/// 화면에 `PROBE-ORIGINAL`이 그대로 보이면 = 확장이 **아예 실행되지 않았다**
/// (자원 부족 / 크래시 / 30초 예산 초과). 이 대조군이 없으면 "안 돌았다"와
/// "돌았는데 실패했다"가 화면상 구분되지 않는다.
///
/// ⚠️ 인증은 일부러 배선하지 않는다. Q1은 "확장에서 소켓이 열리는가"이지
/// "우리 device_token이 붙었는가"가 아니다. App Group 미러링은 Q1이 초록으로
/// 나온 뒤에 만든다. (안드로이드 DozeAlarmProbeWorker와 같은 규율)
final class NotificationService: UNNotificationServiceExtension {

    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var bestAttempt: UNMutableNotificationContent?

    /// CMPedometer는 강한 참조를 유지해야 콜백이 온다
    private let pedometer = CMPedometer()

    /// 앱이 심어두는 오프라인 알림 (확장이 지울 대상)
    private static let appArmedId = "probe-offline"
    /// 확장이 새로 심는 알림 (재무장 가능 여부 검증)
    private static let nseArmedId = "probe-armed-by-nse"

    /// 확장 전체 예산. iOS 상한은 30초지만 여유를 두고 조기 마감한다.
    private static let overallBudget: TimeInterval = 12.0
    /// 네트워크 단독 상한. 망이 죽었을 때 예산을 통째로 태우면
    /// 결과 표시조차 못 하고 PROBE-ORIGINAL로 떨어져 원인을 오독한다.
    private static let netTimeout: TimeInterval = 10.0

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        let content = (request.content.mutableCopy() as? UNMutableNotificationContent)
            ?? UNMutableNotificationContent()
        self.bestAttempt = content

        let started = Date()
        // 발신 측이 찍은 nonce — 어느 푸시가 이 결과를 냈는지 대조용
        let nonce = (request.content.userInfo["probe"] as? String) ?? "-"

        var netResult = "net=?"
        var pendResult = "pend=?"
        var stepResult = "steps=?"

        let group = DispatchGroup()

        // ── Q1: 네트워크 ────────────────────────────────────────────
        group.enter()
        probeNetwork { line in
            netResult = line
            group.leave()
        }

        // ── Q2: pending 조작 ────────────────────────────────────────
        group.enter()
        probePending { line in
            pendResult = line
            group.leave()
        }

        // ── Q3: 걸음수 ──────────────────────────────────────────────
        group.enter()
        probeSteps { line in
            stepResult = line
            group.leave()
        }

        let deliver = { [weak self] (suffix: String) in
            guard let self = self, let handler = self.contentHandler,
                  let body = self.bestAttempt else { return }
            self.contentHandler = nil  // 중복 호출 방지
            let ms = Int(Date().timeIntervalSince(started) * 1000)
            body.title = "NSE ran \(ms)ms\(suffix)"
            body.body = "\(netResult)\n\(pendResult)\n\(stepResult)\nnonce=\(nonce)"
            handler(body)
        }

        group.notify(queue: .main) { deliver("") }

        // 예산 초과 시에도 부분 결과를 반드시 띄운다
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.overallBudget) {
            deliver(" (budget)")
        }
    }

    /// iOS가 30초 예산 만료를 알릴 때 — 여기서 안 띄우면 원본이 표시된다
    override func serviceExtensionTimeWillExpire() {
        guard let handler = contentHandler, let body = bestAttempt else { return }
        contentHandler = nil
        body.title = "NSE expired"
        handler(body)
    }

    // MARK: - Q1

    private func probeNetwork(_ done: @escaping (String) -> Void) {
        let url = URL(string:
            "https://web-production-43beb.up.railway.app/api/v1/app/version-check"
            + "?platform=ios&current_version=0.0.1")!

        let cfg = URLSessionConfiguration.ephemeral
        cfg.timeoutIntervalForRequest = Self.netTimeout
        cfg.timeoutIntervalForResource = Self.netTimeout
        cfg.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let t0 = Date()
        URLSession(configuration: cfg).dataTask(with: url) { data, resp, err in
            let ms = Int(Date().timeIntervalSince(t0) * 1000)
            if let err = err as NSError? {
                done("net=FAIL \(ms)ms [\(err.domain) \(err.code)]")
                return
            }
            let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
            done("net=\(code) \(ms)ms \(data?.count ?? 0)B")
        }.resume()
    }

    // MARK: - Q2

    /// ⚠️ 같은 호출에서 심고 지우면 아무것도 증명하지 못한다.
    /// 실제 설계는 **다른 날 다른 프로세스(앱)가** 심어둔 요청을 지우는 것이므로,
    /// 앱이 미리 심어둔 `probe-offline`이 존재했는지(had)와 제거 후 사라졌는지(gone)를 본다.
    private func probePending(_ done: @escaping (String) -> Void) {
        let center = UNUserNotificationCenter.current()

        center.getPendingNotificationRequests { before in
            let n0 = before.count
            let had = before.contains { $0.identifier == Self.appArmedId }

            center.removePendingNotificationRequests(withIdentifiers: [Self.appArmedId])

            let c = UNMutableNotificationContent()
            c.title = "PROBE-ARMED-BY-NSE"
            c.body = "확장이 심은 알림 (1시간 뒤)"
            let req = UNNotificationRequest(
                identifier: Self.nseArmedId,
                content: c,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
            )

            center.add(req) { addErr in
                let addOk = addErr == nil ? "ok" : "ERR(\(addErr!.localizedDescription))"
                // 제거·추가가 반영되기까지 약간의 지연이 있어 짧게 쉬고 다시 읽는다
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.4) {
                    center.getPendingNotificationRequests { after in
                        let n1 = after.count
                        let gone = !after.contains { $0.identifier == Self.appArmedId }
                        let armed = after.contains { $0.identifier == Self.nseArmedId }
                        done("pend \(n0)→\(n1) had=\(had ? "Y" : "N")"
                             + " rm=\(gone ? "ok" : "FAIL") add=\(addOk)/\(armed ? "Y" : "N")")
                    }
                }
            }
        }
    }

    // MARK: - Q3

    /// ⚠️ 값만 찍으면 "권한이 없어서 nil"과 "확장에선 원천 불가"가 구분되지 않는다.
    /// isStepCountingAvailable / authorizationStatus를 함께 남긴다.
    /// authorizationStatus: 0=notDetermined 1=restricted 2=denied 3=authorized
    private func probeSteps(_ done: @escaping (String) -> Void) {
        let avail = CMPedometer.isStepCountingAvailable()
        let auth = CMPedometer.authorizationStatus().rawValue

        guard avail else {
            done("steps=UNAVAIL av=0 auth=\(auth)")
            return
        }

        let from = Calendar.current.startOfDay(for: Date())
        pedometer.queryPedometerData(from: from, to: Date()) { data, err in
            if let err = err as NSError? {
                done("steps=ERR av=1 auth=\(auth) [\(err.domain) \(err.code)]")
                return
            }
            let n = data?.numberOfSteps.intValue ?? -1
            done("steps=\(n) av=1 auth=\(auth)")
        }
    }
}
