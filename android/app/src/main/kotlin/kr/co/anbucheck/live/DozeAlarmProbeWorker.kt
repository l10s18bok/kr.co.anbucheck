package kr.co.anbucheck.live

import android.app.ActivityManager
import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiManager
import android.os.Build
import android.os.PowerManager
import android.os.SystemClock
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters
import java.net.HttpURLConnection
import java.net.InetSocketAddress
import java.net.Socket
import java.net.URL
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import javax.net.ssl.HttpsURLConnection

/**
 * expedited job 안에서 **네트워크 창을 측정**하는 worker.
 *
 * ## 이 파일이 답해야 하는 두 질문
 *
 *  (A) 열린 방화벽으로 **데이터가 실제로 흐르는가**
 *  (B) 창이 **몇 초까지** 열려 있는가 (heartbeat POST가 0.5~2초 걸리므로 설계를 좌우)
 *
 * 2026-08-22 실측으로 방화벽이 열리는 것 자체는 확인됐다(`dozable-allow` +
 * `standby-default`, n=2). 창 길이는 **job 수명을 따라간다** — worker가 즉시 반환하면
 * 376ms~1.06초만 열렸다. 그래서 이 worker는 **일부러 살아 있으면서** 반복 측정한다.
 *
 * ## 설계 불변 규칙 (전부 실패에서 나온 것들)
 *
 * 1. **DNS 음성 캐시를 건드리지 않는다.** 2026-08-22 09:37, 방화벽이 닫힌 구간에서 돈
 *    직접 프로브의 실패가 캐시에 남아, 103ms 뒤 열린 창에서 돌던 expedited 프로브가
 *    DNS 조회조차 없이 1ms 만에 실패했다. Android의 음성 캐시는 **2초 고정이고
 *    `networkaddress.cache.negative.ttl`은 죽은 코드라 끌 수 없다**(AOSP libcore).
 *    → 그래서 (a) 이 worker보다 **먼저** 같은 호스트를 조회하는 프로브를 두지 않고,
 *      (b) 주 지표를 **DNS를 타지 않는 raw TCP**로 삼는다.
 *
 * 2. **DNS와 TCP를 분리해 잰다.** 둘 다 실패면 통신 차단, TCP만 성공이면 DNS만 막힌
 *    것이고 그때는 **IP를 미리 캐시해 두는 우회로**가 생긴다.
 *
 * 3. **매 시도마다 맥락을 남긴다.** 08-22 07:07 측정은 핫스팟 이탈로 무효였는데 그걸
 *    사후에 logcat을 뒤져서야 알았다(테스트 1회 = 약 2시간). Wi-Fi association·Doze·
 *    proc importance를 그 줄에 같이 찍으면 그 자리에서 판정이 끝난다.
 */
class DozeAlarmProbeWorker(private val ctx: Context, params: WorkerParameters) :
    Worker(ctx, params) {

    @Volatile private var stopped = false

    override fun onStopped() {
        // expedited job에 실행시간 상한이 있는지 확인하는 유일한 신호.
        stopped = true
        Log.d(TAG, "EXP onStopped at=${now()}  ← 시스템이 job을 중단시킴")
        super.onStopped()
    }

    override fun doWork(): Result {
        val t0 = inputData.getLong(KEY_ENQUEUED_AT, 0L)
            .takeIf { it > 0 } ?: SystemClock.elapsedRealtime()
        val serverIp = inputData.getString(KEY_SERVER_IP) ?: FALLBACK_IP

        Log.d(TAG, "EXP started at=${now()} lag=${SystemClock.elapsedRealtime() - t0}ms ip=$serverIp")

        for (offsetSec in OFFSETS_SEC) {
            if (stopped) {
                Log.d(TAG, "EXP aborted at ${offsetSec}s — onStopped")
                return Result.success()
            }
            val target = t0 + offsetSec * 1000L
            val wait = target - SystemClock.elapsedRealtime()
            if (wait > 0) {
                try { Thread.sleep(wait) } catch (_: InterruptedException) { break }
            }

            // ① raw TCP 443 — DNS를 타지 않으므로 음성 캐시에 오염되지 않는다. 주 지표.
            val tcp = measure { Socket().use { it.connect(InetSocketAddress(serverIp, 443), 5_000); "OK" } }
            // ② 호스트명 HTTPS GET — DNS까지 포함한 종단 확인.
            //    음성 캐시가 2초이므로 offset 간격이 3초 이상인 지점에서만 유효하다.
            val https = measure { httpGet() }

            Log.d(
                TAG,
                "EXP t+${offsetSec}s | tcp=$tcp | https=$https | ${context()}",
            )
        }
        Log.d(TAG, "EXP done at=${now()} total=${SystemClock.elapsedRealtime() - t0}ms")
        return Result.success()
    }

    // ── 측정 ──────────────────────────────────────────────

    private inline fun measure(block: () -> String): String {
        val s = SystemClock.elapsedRealtime()
        val r = try { block() } catch (e: Throwable) { "${e.javaClass.simpleName}" }
        return "$r(${SystemClock.elapsedRealtime() - s}ms)"
    }

    private fun httpGet(): String {
        var c: HttpURLConnection? = null
        return try {
            c = (URL(PROBE_URL).openConnection() as HttpsURLConnection).apply {
                requestMethod = "GET"
                connectTimeout = 5_000
                readTimeout = 5_000
                useCaches = false
            }
            val code = c.responseCode
            c.inputStream.use { it.readBytes() }
            "HTTP$code"
        } catch (e: Throwable) {
            e.javaClass.simpleName
        } finally {
            try { c?.disconnect() } catch (_: Throwable) {}
        }
    }

    /** 매 줄에 붙는 맥락 — 무효 측정을 그 자리에서 걸러내기 위함. */
    private fun context(): String {
        val idle = try {
            (ctx.getSystemService(Context.POWER_SERVICE) as PowerManager).isDeviceIdleMode
        } catch (_: Throwable) { null }

        // Wi-Fi association — 앱의 네트워크 차단과 무관한 시스템 서비스 조회라 Doze에서도 읽힌다.
        val wifi = try {
            @Suppress("DEPRECATION")
            val info = (ctx.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager)
                .connectionInfo
            "${info.supplicantState}/${info.rssi}dBm"
        } catch (_: Throwable) { "?" }

        // proc state 승격이 실제로 일어났는지 — 방화벽이 열리는 근거.
        val importance = try {
            val i = ActivityManager.RunningAppProcessInfo()
            ActivityManager.getMyMemoryState(i)
            i.importance
        } catch (_: Throwable) { -1 }

        val net = try {
            val cm = ctx.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val n = cm.activeNetwork
            if (n == null) "none" else {
                val cap = cm.getNetworkCapabilities(n)
                if (cap == null) "noCap"
                else if (cap.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)) "validated"
                else "unvalidated"
            }
        } catch (_: Throwable) { "?" }

        return "idle=$idle wifi=$wifi imp=$importance net=$net"
    }

    private fun now(): String = SimpleDateFormat("HH:mm:ss.SSS", Locale.US).format(Date())

    companion object {
        private val TAG = DozeAlarmProbeReceiver.TAG
        const val KEY_ENQUEUED_AT = "enqueued_at"
        const val KEY_SERVER_IP = "server_ip"

        /** 무장 시 해석에 실패했을 때만 쓰는 폴백(2026-08-21 확인값). */
        const val FALLBACK_IP = "69.46.46.31"

        /**
         * 측정 시점. 창 경계를 찾는 것이 목적이라 앞을 촘촘히, 뒤를 성기게 둔다.
         * 호스트명 GET은 음성 캐시(2초)를 피하려고 간격이 3초 이상인 지점부터 의미가 있다.
         */
        private val OFFSETS_SEC = listOf(0L, 3L, 6L, 10L, 15L, 20L, 30L, 40L)

        private const val PROBE_URL =
            "https://web-production-43beb.up.railway.app/api/v1/app/version-check" +
                "?version=1.0.0&platform=android"
    }
}
