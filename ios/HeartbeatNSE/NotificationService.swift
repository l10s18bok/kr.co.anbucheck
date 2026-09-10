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

    /// 계측 문자열(잠금 상태·걸음수·도착 지연). **판정에는 쓰지 않는다** — 로그 전용.
    /// iOS가 안드로이드처럼 `suspicious`를 판정할 수 있는지 가늠하기 위한 측정이다.
    private var diag = ""

    /// suspicious 판정에 쓰는 두 값. `didReceive`에서 채우고 `send`에서 읽는다.
    private var unlockedNow: Bool?
    private var fgToday = false

    /// 피기백 실행 중인가. true면 성공해도 **알림 내용을 절대 건드리지 않는다** —
    /// 보호자 경고·리포트 문구가 "안부 전달 완료"로 덮이면 정보가 사라진다.
    private var piggyback = false

    /// 회복 전송(살아있음 신호) 실행 중인가. true면 성공해도 **문구를 바꾸지 않는다** —
    /// 회복 전송은 "오늘의 안부"가 아니라 "기기가 살아 있다"이므로, "안부 전달 완료"로
    /// 바꾸면 거짓말이 된다(오늘 안부는 아직 안 나갔고, 폴백이 +45분 뒤에 그렇다고 알린다).
    private var recoveryMode = false

    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var original: UNNotificationContent?
    private var mutable: UNMutableNotificationContent?

    /// CMPedometer는 강한 참조를 유지해야 콜백이 온다
    private let pedometer = CMPedometer()

    /// 확장이 시작된 시각. 백필처럼 **부가적인** 작업을 예산 잔량으로 가르는 데 쓴다.
    private let startedAt = Date()

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
        let type = (request.content.userInfo["type"] as? String) ?? ""
        let isTrigger = (type == "heartbeat_push")

        // ─────────────────────────────────────────────────────────────
        // ★ 피기백 — 밀려난 트리거를 **다른 푸시가 대신 실어 나른다.**
        //
        // APNs는 기기가 도달 불가일 때 앱(토픽)당 알림을 **1개만** 보관하고 새 알림이
        // 앞의 것을 버린다(coalescing, 애플 문서). 그런데 iOS 사용자는 **전원 보호자를
        // 겸하므로**, 대상자 안부 알림이 매일 아침 자기 트리거와 슬롯을 다툰다.
        // 2026-08-27 실측: 화면 끈 채 83분 방치 → 트리거 → 긴급 순서로 보내자
        // **긴급만 도착**하고 트리거는 영구 소실됐다.
        //
        // 그래서 트리거 하나에 의존하지 않는다. 서버는 `send_push`에서 **모든** 푸시에
        // `mutable_content=True`를 붙이므로 이 확장은 보호자 알림에서도 이미 깨어난다.
        // 그 기회를 그대로 쓴다 — **어느 푸시가 살아남든 안부가 나간다.**
        //
        // ⚠️ **허용목록(allow-list)이다. 부정목록으로 바꾸지 말 것.**
        // 새 푸시 타입이 추가됐을 때 안전한 쪽(즉시 통과)으로 떨어져야 한다.
        //
        // ⚠️ **긴급·경고·구독 계열은 절대 넣지 말 것.** 여기 넣으면 네트워크를 기다리는
        // 만큼 **긴급 경고가 늦게 뜬다.** 사람 안전이 걸린 알림을 안부 전송 편의와
        // 바꾸지 않는다.
        let piggybackable: Set<String> = [
            "auto_report",      // 오늘 안부 확인 완료
            "manual_report",    // 수동 안부 확인
            "steps",            // 활동 정보
            "battery_low",
            "battery_dead",
            "alert_resolved",   // 정상 복귀
            "alert_cleared",    // 보호자 경고 클리어
        ]
        let isPiggyback = piggybackable.contains(type)

        guard isTrigger || isPiggyback else {
            contentHandler(request.content)
            return
        }

        guard let body = request.content.mutableCopy() as? UNMutableNotificationContent else {
            contentHandler(request.content)
            return
        }
        self.mutable = body
        self.piggyback = isPiggyback

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

        // ── 계측 (판정에 영향 없음) ─────────────────────────────
        // 잠금 해제 여부와 예약시각 대비 도착 지연을 남긴다. 며칠 모으면
        // "iOS도 suspicious를 판정할 수 있는가"를 데이터로 답할 수 있다.
        let unlocked = HeartbeatStore.deviceUnlocked()
        let lag = HeartbeatStore.minutesSinceScheduled(hour: store.hour, minute: store.minute)
        let fgToday = (store.appFgDate == HeartbeatStore.today())
        self.unlockedNow = unlocked
        self.fgToday = fgToday
        diag = " unlocked=\(unlocked.map { $0 ? "Y" : "N" } ?? "?")"
            + " fg=\(fgToday ? "Y" : "N")"
            + " lag=\(lag.map { "\($0)m" } ?? "?")"
            + " type=\(isTrigger ? "trigger" : "piggyback")"

        // 움직임 이력은 비동기다. **계측이 전송을 지연시켜서는 안 되므로** 기다리지 않는다.
        //
        // ⚠️ 그래서 `finish()`가 먼저 끝나는 경로(already-sent 등 빠른 분기)에서는
        // 결과가 diag에 실리지 못한다 — 실제로 09-01 00:07 관측에서 motion이 통째로
        // 빠졌다. 늦게 온 값은 **별도 줄로** 남겨 잃지 않게 한다.
        HeartbeatStore.motionSummary { [weak self] day, recent in
            guard let self = self else { return }
            let v = " motion=\(day) motion15=\(recent)"
            if self.contentHandler == nil {
                HeartbeatStore.log("nse motion-late\(v)")  // 이미 배달됨
            } else {
                self.diag += v
            }
        }

        // ⚠️ **안부를 보내는 쪽이 아니면 여기서 끝낸다(순수 보호자).**
        // 트리거 푸시는 서버가 G+S에게만 보내 이 검사가 필요 없었지만, 피기백은
        // **모든 보호자에게 가는 알림**(auto_report 등)에 얹히므로 그 게이팅이 통하지
        // 않는다. 이 가드가 없으면 순수 보호자 기기가 대상자 알림을 받을 때마다
        // 자기 heartbeat를 서버로 보낸다 — `lastSentDate`가 늘 비어 있고 예약시각
        // 기본값이 18:00이라 저녁 이후 알림마다 조건이 성립한다.
        guard store.isSubject else {
            finish(success: false, note: "not-subject")
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

        // ⚠️ 예약시각 이전이면 오늘 몫이 아니다 — 자정을 넘겨 배달된 어제 트리거다.
        // 여기서 보내면 `오늘_HH:mm` 키로 서버에 귀속돼 오늘 정시 트리거가 통째로
        // 스킵되고, 그날 걸음수가 배달 시각까지만 기록된다. 상세는
        // HeartbeatStore.scheduledTimePassed 주석 참조.
        guard HeartbeatStore.scheduledTimePassed(hour: store.hour, minute: store.minute) else {
            attemptRecovery(store: store)
            return
        }

        // 중복 전송 방지 — 보호자 알림 여러 건이 동시에 도착하면 확장이 병렬로 뜬다.
        // 못 잡으면 다른 인스턴스가 이미 보내는 중이므로 원본만 배달하고 끝낸다.
        guard HeartbeatStore.tryAcquireSendLock() else {
            finish(success: false, note: "locked")
            return
        }

        collectSteps { steps in
            self.diag += " steps=\(steps.map(String.init) ?? "?")"
            self.send(store: store, steps: steps) { ok in
                HeartbeatStore.releaseSendLock()
                guard ok else {
                    self.finish(success: false, note: "send-failed")
                    return
                }
                HeartbeatStore.markSent(scheduledKey: store.scheduledKey)
                HeartbeatStore.clearTodayOfflineFallback()
                HeartbeatStore.rearmOfflineFallback(hour: store.hour, minute: store.minute)

                // ★ 오늘 안부가 나간 **뒤에만** 어제 걸음수를 채운다.
                // ⚠️ `store`는 값 복사본이라 `markSent` 뒤에도 `yesterdayMissed`가
                //    전송 이전 상태를 그대로 들고 있다(App Group을 다시 읽지 않는다).
                // ⚠️ 예산이 절반 넘게 지났으면 건너뛴다 — 알림 배달이 우선이다.
                //    건너뛰어도 다음 날 같은 판정이 다시 돌아 기회가 남는다.
                let elapsed = Date().timeIntervalSince(self.startedAt)
                guard store.yesterdayMissed, elapsed < Self.overallBudget / 2 else {
                    self.finish(success: true, note: "sent")
                    return
                }
                self.backfillYesterday(store: store) {
                    self.finish(success: true, note: "sent")
                }
            }
        }
    }

    // MARK: - 회복 전송 (예약시각 이전)

    /// 예약시각 이전에 도착한 푸시로 **살아있음 신호**를 보낸다 (2026-09-10 도입).
    ///
    /// **왜 필요한가.** 안드로이드는 워커가 예약시각 전에 발화하면 앱 실행 없이 회복
    /// 전송을 보낸다. iOS에는 그 경로가 없어 **사람이 앱을 열어야만** 회복됐다 —
    /// 그런데 이 앱의 대상자는 앱을 열지 않는 것이 정상 사용 패턴이다. 그래서 며칠씩
    /// 망이 끊겼다 복구돼도, 그날 예약시각(저녁)까지 보호자는 아무 신호를 못 받았다.
    ///
    /// **왜 안전한가 — `recovery_<오늘>` 키가 열쇠다.** 이 분기가 원래 아무것도 하지
    /// 않았던 이유는 `오늘_HH:mm` 키로 보내면 서버가 당일 안부로 귀속시켜 **그날 정시
    /// 트리거가 미발사**되기 때문이다(자정 넘겨 배달된 어제 트리거 문제, §13.2 ①).
    /// 회복 키는 서버가 `is_todays_report=False`로 분류해 `last_seen`·`steps_delta`를
    /// 밀지 않으므로(2026-09-09 서버 수정) **정시 트리거가 그대로 발사된다.**
    ///
    /// ⚠️ **`scheduledTimePassed` 가드의 두 번째 목적은 그대로 살아 있다.**
    /// 자정을 넘겨 배달된 어제 트리거는 `lastSentDate == 어제`라 갭 조건에 걸리지 않아
    /// 예전처럼 원본만 통과한다. 갭이 2일 이상일 때만 회복 키로 나가고, 그 키는
    /// 애초에 정시 슬롯을 소비할 수 없다. **가드가 약해졌다고 보고 되돌리지 말 것.**
    private func attemptRecovery(store: HeartbeatStore) {
        // 하루치만 비었으면 보내지 않는다 — 그건 그날 정시 전송이 메운다.
        guard store.hasMultiDayGap else {
            finish(success: false, note: "before-schedule")
            return
        }
        guard !HeartbeatStore.recoverySentToday() else {
            finish(success: false, note: "recovery-done")
            return
        }
        guard HeartbeatStore.tryAcquireSendLock() else {
            finish(success: false, note: "locked")
            return
        }

        recoveryMode = true

        collectSteps { steps in
            self.diag += " steps=\(steps.map(String.init) ?? "?")"

            // ⚠️ **세 신호는 `suspicious` 값이 아니라 "보낼지 말지"를 정한다.**
            // 회복 전송이 서버에서 하는 일은 "이 기기 살아있다"를 알리는 것이고,
            // 사람 흔적이 없으면 그 주장을 할 근거가 없다. 그때는 아무것도 보내지
            // 않는 것이 맞다 — 경고가 유지되는 게 정확하고, 그날 정시 트리거는
            // 여전히 살아 있으니 잃는 것도 없다.
            //
            // ⚠️ **`suspicious=true`인 회복 전송을 만들지 말 것.** 서버에서 회복 키는
            // 지난 기록 보정과 달리 조기 반환을 타지 않아 suspicious 분기로 떨어지고,
            // 거기서 caution/warning/urgent **에스컬레이션 푸시가 발송된다.**
            // "기기가 돌아왔다"는 신호로 경고를 올리는 셈이라 설계가 뒤집힌다.
            let alive = (steps ?? 0) > 0 || self.unlockedNow == true || self.fgToday
            guard alive else {
                HeartbeatStore.releaseSendLock()
                self.finish(success: false, note: "recovery-no-signal")
                return
            }

            // 걸음수는 싣지 않는다 — 안드로이드 `_executeRecovery`와 동일.
            // 회복 전송은 그날의 걸음수를 확정하지 않으며, 그 일은 정시 전송이 한다.
            self.send(store: store, steps: nil, scheduledKey: store.recoveryKey) { ok in
                HeartbeatStore.releaseSendLock()
                if ok {
                    HeartbeatStore.markRecoverySent()
                    // ⚠️ `markSent`도 `clearTodayOfflineFallback`도 부르지 않는다.
                    // 오늘 안부는 아직 안 나갔으므로 오늘치 폴백은 **살아 있어야 한다.**
                    // 롤링 창만 채워 둔다(§13.2 ③ — 확장이 돌 때마다 7일 창을 갱신).
                    HeartbeatStore.rearmOfflineFallback(hour: store.hour, minute: store.minute)
                }
                self.finish(success: ok, note: ok ? "recovery" : "recovery-failed")
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

        HeartbeatStore.log("nse \(note)\(diag)")

        // ⚠️ 피기백은 **성공해도 원본을 그대로 배달한다.** 이 알림의 본래 용도(보호자
        // 리포트·배터리 안내 등)가 우선이고, 안부 전송은 그 뒤에 조용히 얹힌 것이다.
        guard success, !piggyback, !recoveryMode, let body = mutable else {
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
    ///
    /// 범위를 받지 않으면 **오늘 자정 ~ 지금**을 센다(정시 전송의 기본 동작).
    /// ⚠️ `CMPedometer`는 **최근 7일**만 소급 조회할 수 있다 — 그보다 오래된 날은
    /// 날짜를 알아도 값을 채울 수 없다(애플 문서).
    private func collectSteps(
        from: Date? = nil,
        to: Date? = nil,
        _ done: @escaping (Int?) -> Void
    ) {
        guard CMPedometer.isStepCountingAvailable() else { done(nil); return }

        var finished = false
        let complete: (Int?) -> Void = { v in
            guard !finished else { return }
            finished = true
            done(v)
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + Self.stepTimeout) { complete(nil) }

        let start = from ?? Calendar.current.startOfDay(for: Date())
        let end = to ?? Date()
        pedometer.queryPedometerData(from: start, to: end) { data, _ in
            complete(data?.numberOfSteps.intValue)
        }
    }

    // MARK: - 지난 걸음수 백필

    /// 어제가 미전송이었으면 **어제 걸음수만** 뒤늦게 부친다 (2026-09-10 도입).
    ///
    /// **왜 필요한가.** 안드로이드는 전송에 실패한 날 걸음수를 보류 큐에 저장했다가
    /// 다음 성공 전송 때 부쳐 그날 막대를 채운다. iOS에는 그 큐가 없다 — 미전송이
    /// 발생하는 순간 앱도 확장도 돌지 않아 **저장할 주체가 없기** 때문이다.
    /// 대신 `CMPedometer`가 최근 7일을 소급 조회할 수 있으므로 **사후에 만들어** 부친다.
    ///
    /// ⚠️ **어제 하루만 채운다.** 안드로이드 보류 큐도 1건만 보관해 마지막 실패일
    /// 하나만 복구하므로, 이게 두 플랫폼을 같게 만드는 지점이다. 더 채우려면 POST가
    /// 날짜 수만큼 늘어 확장 예산(20초)을 위협하고, 서버 쪽 경고 해소도 그만큼 반복된다.
    ///
    /// ⚠️ **정시 전송이 성공한 뒤에만 부른다.** 오늘 안부가 본질이고 어제 걸음수는
    /// 부가 정보다 — 예산이 모자라면 버려야 하는 쪽은 후자다.
    ///
    /// ⚠️ **`battery_level`을 싣지 않는다.** 지금 배터리는 어제 값이 아니고, 서버는
    /// 지난 기록에서도 `battery_level`을 갱신하므로(계약이 "마지막으로 수신한 heartbeat의
    /// 배터리") 실으면 미수신 스케줄러의 배터리 분기 입력이 오염된다.
    private func backfillYesterday(store: HeartbeatStore, done: @escaping () -> Void) {
        let cal = Calendar.current
        guard let yStart = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: Date())),
              let yEnd = cal.date(byAdding: .day, value: 1, to: yStart)
        else { done(); return }

        collectSteps(from: yStart, to: yEnd) { steps in
            // ⚠️ **0보도 부친다.** 안드로이드는 보류 메모를 걸음수와 무관하게 그대로
            // 부치므로 여기서만 걸러내면 두 플랫폼이 갈린다. 0보는 `suspicious=true`가
            // 되어 서버가 이력만 적재하고 경고는 건드리지 않는다(지난 기록은 새 경고를
            // 만들지도 않는다) — 그날 막대가 "값 없음"이 아니라 "0보"로 확정된다.
            //
            // 조회 **실패**(nil)는 다르다. 그건 "0보였다"가 아니라 "모른다"이므로
            // 부치지 않는다 — 모르는 것을 0으로 단정하면 그날 막대가 거짓이 된다.
            guard let steps = steps else {
                HeartbeatStore.log("nse backfill-skip y=?")
                done()
                return
            }
            self.sendBackfill(store: store, steps: steps) { ok in
                HeartbeatStore.log("nse backfill\(ok ? "" : "-failed") y=\(steps) key=\(store.yesterdayKey)")
                done()
            }
        }
    }

    // MARK: - 전송

    /// 어제 걸음수 1건을 부친다. `<어제>_HH:mm` 키라 서버가 **지난 기록 보정**으로
    /// 분류해 `last_seen`을 밀지 않고 당일 알림도 보내지 않는다(`heartbeat_keys.py`).
    ///
    /// `suspicious`는 걸음수로 정한다 — 안드로이드 보류 메모가 담고 있던 값과 같은
    /// 의미다(0보 = 활동 증거 없음). 서버는 지난 기록으로 **새 경고를 만들지 않으므로**
    /// `true`여도 보호자에게 알림이 가지 않고, `false`일 때만 지난 경고를 해소한다.
    private func sendBackfill(store: HeartbeatStore, steps: Int, done: @escaping (Bool) -> Void) {
        guard let url = URL(string: store.apiBase + "/api/v1/heartbeat") else { done(false); return }

        let payload: [String: Any] = [
            "device_id": store.deviceId,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "scheduled_key": store.yesterdayKey,
            "steps_delta": steps,
            "suspicious": steps <= 0,
            // ⚠️ battery_level 없음 — 지금 값은 어제 것이 아니다(위 주석 참조).
        ]

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer " + store.deviceToken, forHTTPHeaderField: "Authorization")
        req.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        let cfg = URLSessionConfiguration.ephemeral
        cfg.timeoutIntervalForRequest = Self.netTimeout
        cfg.timeoutIntervalForResource = Self.netTimeout

        URLSession(configuration: cfg).dataTask(with: req) { _, resp, _ in
            let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
            done((200...299).contains(code))
        }.resume()
    }

    /// `scheduledKey`를 밖에서 받는 이유: 정시 전송(`오늘_HH:mm`)과 회복 전송
    /// (`recovery_<오늘>`)이 같은 경로를 쓰되 **서버 분류만 다르기** 때문이다.
    private func send(
        store: HeartbeatStore,
        steps: Int?,
        scheduledKey: String? = nil,
        done: @escaping (Bool) -> Void
    ) {
        guard let url = URL(string: store.apiBase + "/api/v1/heartbeat") else { done(false); return }

        var payload: [String: Any] = [
            "device_id": store.deviceId,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "scheduled_key": scheduledKey ?? store.scheduledKey,
            // ── suspicious 판정 (2026-09-01 도입) ─────────────────────
            // 안드로이드와 **같은 질문**을 한다: "전송 시점에 사람의 조작 흔적이 있는가".
            //   안드로이드  워커 발화 시점에 화면이 켜져 있었는가
            //   iOS        확장 실행 시점에 잠금이 풀려 있었는가
            // 오히려 iOS 쪽이 정확하다 — 알림만으로 화면이 켜져도 참이 되는 안드로이드와
            // 달리 잠금 해제는 Face ID나 암호를 요구한다(§18.10 ② 실측).
            //
            // ⚠️ **구제 조건으로만 쓴다.** 세 신호 중 하나라도 참이면 false다.
            // "잠김"은 "30분 전에 뭘 했는지"를 모르므로 단독으로 true의 근거가 못 된다.
            // true는 **셋 다 아닐 때**만 나온다.
            //
            // ⚠️ `motion`은 판정에 넣지 않는다. 비동기라 이 시점에 값이 없을 수 있고,
            // walking·running이 걸음수를 함께 올려 `steps>0`과 대부분 겹친다(§18.15).
            //
            // ⚠️ **되돌리려면 이 줄을 `false`로 바꾸면 된다.** iOS에 없던 경고 종류가
            // 생기는 변경이라, 보호자 경고가 과도해지면 그것이 즉시 복구 경로다.
            //
            // ⚠️ **회복 전송은 항상 false다.** 위 attemptRecovery가 세 신호로 이미
            // "사람 흔적이 있을 때만" 보내도록 걸렀고, 회복 키의 `suspicious=true`는
            // 서버에서 정의되지 않은 경로다(에스컬레이션 푸시가 나간다).
            "suspicious": recoveryMode ? false : !(
                (steps ?? 0) > 0 || unlockedNow == true || fgToday
            ),
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
