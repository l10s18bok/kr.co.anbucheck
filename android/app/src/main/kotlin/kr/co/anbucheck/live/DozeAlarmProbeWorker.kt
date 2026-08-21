package kr.co.anbucheck.live

import android.content.Context
import android.os.SystemClock
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import javax.net.ssl.HttpsURLConnection

/**
 * [DozeAlarmProbeReceiver]가 expedited로 enqueue하는 **네트워크 측정 전용** worker.
 *
 * ## 재는 것 (하나뿐이다)
 *
 * **딥 Doze + RARE 버킷에서 expedited job은 네트워크를 받는가?**
 *
 * 2026-08-21 실측으로 allow-while-idle 알람은 발화는 하지만 temp power-save
 * allowlist를 못 받아 `blocked=DOZE|APP_STANDBY, allowed=NONE`으로 DNS가 즉시
 * 거부됐다. 반면 같은 날 고우선순위 FCM은 `reason=PUSH_MESSAGING`으로 20초짜리
 * 창을 실제로 받았다. 그 사이에 미검증 경로가 하나 있다 — expedited job이 앱을
 * foreground급 proc state로 올리면 `allowed=FOREGROUND`가 `DOZE|APP_STANDBY`를
 * 상쇄할 수 있다(같은 덤프의 uid 10222가 그 형태다).
 *
 * ## 왜 여기에 heartbeat를 붙이지 않았나
 *
 * 붙이려면 workmanager 플러그인의 `BackgroundWorker`를 직접 enqueue해야 하고,
 * 그 input data 키·클래스 가시성·gradle 모듈 의존을 손으로 맞춰야 한다. 실패했을 때
 * **"망이 안 열린 것"과 "내가 만든 input data가 틀린 것"을 구분할 수 없게 된다.**
 * 원인이 하나뿐인 측정을 먼저 하고, 통과하면 그때 확신을 갖고 배선한다.
 * (Phase 1이 값어치 있었던 이유가 정확히 이것이다 — 발화가 아니라 망을 쟀다.)
 *
 * ## 판정
 *
 *  - `EXPEDITED_PROBE ... result=HTTP 200`  → expedited가 망을 연다. 실제 heartbeat 배선 가능
 *  - `result=FAIL UnknownHostException`     → 알람과 동일하게 차단. expedited 경로도 사망
 *  - 로그가 **19:05~20:05 사이에 안 보이고 한참 뒤에 나타남** → 쿼터 소진으로 일반 job으로
 *    강등(`RUN_AS_NON_EXPEDITED_WORK_REQUEST`)되어 유지보수 창까지 밀린 것. 이것도 실패다
 */
class DozeAlarmProbeWorker(context: Context, params: WorkerParameters) :
    Worker(context, params) {

    override fun doWork(): Result {
        val enqueuedAt = inputData.getLong(KEY_ENQUEUED_AT, 0L)
        val lag = if (enqueuedAt > 0) SystemClock.elapsedRealtime() - enqueuedAt else -1L
        Log.d(
            DozeAlarmProbeReceiver.TAG,
            "EXPEDITED_WORKER started at=${now()} lagFromAlarm=${lag}ms",
        )

        val started = SystemClock.elapsedRealtime()
        var conn: HttpURLConnection? = null
        val result = try {
            conn = (URL(PROBE_URL).openConnection() as HttpsURLConnection).apply {
                requestMethod = "GET"
                connectTimeout = 8_000
                readTimeout = 8_000
                useCaches = false
            }
            val code = conn.responseCode
            conn.inputStream.use { it.readBytes() }
            "HTTP $code"
        } catch (e: Throwable) {
            "FAIL ${e.javaClass.simpleName}: ${e.message}"
        } finally {
            try { conn?.disconnect() } catch (_: Throwable) {}
        }

        Log.d(
            DozeAlarmProbeReceiver.TAG,
            "EXPEDITED_PROBE elapsed=${SystemClock.elapsedRealtime() - started}ms result=$result",
        )
        return Result.success()
    }

    private fun now(): String =
        SimpleDateFormat("HH:mm:ss.SSS", Locale.US).format(Date())

    companion object {
        const val KEY_ENQUEUED_AT = "enqueued_at"

        /** 알람 프로브와 **동일한** 엔드포인트 — 두 경로의 결과를 직접 비교하기 위함. */
        private const val PROBE_URL =
            "https://web-production-43beb.up.railway.app/api/v1/app/version-check" +
                "?version=1.0.0&platform=android"
    }
}
