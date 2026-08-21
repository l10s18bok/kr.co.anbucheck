package kr.co.anbucheck.live

import android.app.AlarmManager
import android.app.usage.UsageStatsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.os.SystemClock
import android.util.Log
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequest
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import javax.net.ssl.HttpsURLConnection

/**
 * Doze 관통 알람 **실측 프로브** (Phase 1 — Dart 미실행, 순수 네이티브).
 *
 * 확인하려는 것은 "알람이 뜨는가"가 **아니다.** 프레임워크 상수상 그건 거의 확실하다
 * (`allow_while_idle_quota=72/1h`, `standby_quota_rare=1/1h`, 실측: GMS·sec.spp.push가
 * 딥 Doze 중 15분 간격 발화). 진짜 리스크는 그 다음이다:
 *
 *   **딥 Doze에서 평범한(비특권) 앱이 temp allowlist 10초 동안 실제로 쓸 수 있는
 *     네트워크를 받는가? 그리고 그 창이 닫히면 정말 끊기는가?**
 *
 * Doze는 비허용 앱의 네트워크를 막고, `allow_while_idle_whitelist_duration=+10s`가
 * 곧 네트워크 창이다. 이 창 안에 heartbeat POST가 못 끝나면 알람이 완벽히 떠도
 * 전송은 실패한다. 우리가 관측한 성공 사례는 전부 **남의 앱**(GMS/삼성 푸시)이고
 * 그들은 상시 allowlist를 가졌을 수 있다 — 발화에 달았던 단서가 네트워크에도 똑같이 붙는다.
 *
 * 그래서 3회 프로브로 창의 경계를 직접 잰다:
 *   T+0s   창 진입 직후      → 성공 기대
 *   T+9s   창 만료 직전      → 성공하면 창 전체가 쓸 만하다는 뜻
 *   T+15s  창 만료 **이후**  → ★ 대조군. 여기서도 성공하면 애초에 네트워크가
 *                              안 막혀 있었다는 뜻이라 10초 예산 자체가 허구다
 *
 * 세 결과의 조합이 Phase 2 설계를 정한다. 특히 T+15s가 실패해야만
 * "10초 안에 끝내야 한다"는 제약이 실재하는 것이고, 그 경우 heartbeat 전송 예산을
 * worker 경로(20초)와 다르게 잡아야 한다.
 */
class DozeAlarmProbeReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        // 재부팅 복원 — 알람은 재부팅 시 사라진다. flutter_local_notifications의
        // 부팅 리시버는 자기 알림만 복원하므로 우리 알람은 여기서 직접 되살린다.
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON"
        ) {
            armNextDaily(context, reason = "boot")
            return
        }

        // ★ 재무장을 네트워크보다 **먼저** 한다.
        // worker에서 이미 배운 불변식이다 — lmkd가 시작 0.73초 만에 프로세스를 죽인
        // 실측이 있고(2026-08-18 15:07), BroadcastReceiver도 똑같이 노출돼 있다.
        // 여기서 죽어도 내일 트리거는 살아남아야 한다.
        armNextDaily(context, reason = "refire")

        val t0 = SystemClock.elapsedRealtime()
        Log.d(TAG, "FIRED at=${now()} idle=${isDeviceIdle(context)} bucket=${bucket(context)}")

        // ★ 2026-08-21 실측 후속 — expedited job이 망을 받는지 함께 잰다.
        //
        // 알람 자체는 temp power-save allowlist를 못 받아 DNS가 즉시 거부됐다
        // (blocked=DOZE|APP_STANDBY, allowed=NONE). 그런데 expedited job이 앱을
        // foreground급 proc state로 올리면 allowed=FOREGROUND가 그 둘을 상쇄할
        // 가능성이 남아 있다. 아래 직접 프로브(T+0/9/15s)와 **같은 발화에서 동시에**
        // 재야 조건이 동일해 비교가 성립한다.
        enqueueExpeditedProbe(context, t0)

        val pending = goAsync()
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        // RTC_WAKEUP이 CPU를 깨우지만 onReceive 반환 후에도 프로브를 이어가려면
        // 우리 wakelock이 필요하다. WAKE_LOCK은 normal 권한이라 프롬프트가 없다.
        val wl = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "$TAG:probe")
        wl.acquire(30_000L)

        Thread {
            try {
                probe(context, "T+0s", t0)
                sleepUntil(t0, 9_000)
                probe(context, "T+9s(창 만료 직전)", t0)
                sleepUntil(t0, 15_000)
                probe(context, "T+15s(창 만료 이후·대조군)", t0)
            } catch (e: Throwable) {
                Log.d(TAG, "PROBE thread error: ${e.javaClass.simpleName}: ${e.message}")
            } finally {
                Log.d(TAG, "DONE at=${now()} total=${SystemClock.elapsedRealtime() - t0}ms")
                try { wl.release() } catch (_: Throwable) {}
                pending.finish()
            }
        }.start()
    }

    private fun sleepUntil(t0: Long, offsetMs: Long) {
        val remain = offsetMs - (SystemClock.elapsedRealtime() - t0)
        if (remain > 0) Thread.sleep(remain)
    }

    /** 실제 서버로 최소 GET 1회. 성공/실패와 소요 시간을 남긴다. */
    private fun probe(context: Context, label: String, t0: Long) {
        val started = SystemClock.elapsedRealtime()
        var conn: HttpURLConnection? = null
        val result = try {
            conn = (URL(PROBE_URL).openConnection() as HttpsURLConnection).apply {
                requestMethod = "GET"
                connectTimeout = 5_000
                readTimeout = 5_000
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
        val elapsed = SystemClock.elapsedRealtime() - started
        Log.d(
            TAG,
            "PROBE $label offset=${started - t0}ms elapsed=${elapsed}ms " +
                "idle=${isDeviceIdle(context)} result=$result"
        )
    }

    private fun now(): String =
        SimpleDateFormat("HH:mm:ss.SSS", Locale.US).format(Date())

    private fun isDeviceIdle(context: Context): Boolean {
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) pm.isDeviceIdleMode else false
    }

    /** 자기 자신의 standby 버킷 — 권한 불필요(API 28+). 10 ACTIVE / 40 RARE / 45 RESTRICTED */
    private fun bucket(context: Context): Int = try {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            (context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager)
                .appStandbyBucket
        } else -1
    } catch (e: Throwable) { -2 }

    companion object {
        const val TAG = "DozeAlarmProbe"
        private const val REQUEST_CODE = 90001
        private const val ACTION = "kr.co.anbucheck.live.DOZE_ALARM_PROBE"
        private const val EXPEDITED_NAME = "doze_alarm_expedited_probe"

        /** 프로브 대상 — 인증 불필요한 GET. 실제 운영 서버라 경로 특성이 heartbeat와 같다. */
        private const val PROBE_URL =
            "https://web-production-43beb.up.railway.app/api/v1/app/version-check" +
                "?version=1.0.0&platform=android"

        private const val PREFS = "doze_alarm_probe"
        private const val KEY_HOUR = "hour"
        private const val KEY_MINUTE = "minute"

        private fun pendingIntent(context: Context) = android.app.PendingIntent.getBroadcast(
            context,
            REQUEST_CODE,
            Intent(context, DozeAlarmProbeReceiver::class.java).setAction(ACTION),
            android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE,
        )

        /**
         * 매일 [hour]:[minute]에 발화하도록 무장한다.
         *
         * ⚠️ **`setAndAllowWhileIdle`(부정확) + `RTC_WAKEUP`** 조합이어야 한다.
         *  - `setExactAndAllowWhileIdle`은 `SCHEDULE_EXACT_ALARM`을 요구하고, 그 권한은
         *    Android 14+ 기본 거부 + Play 정책상 알람시계·캘린더 앱 전용이라 쓸 수 없다.
         *  - `RTC`(비-wakeup)를 쓰면 다음 기기 기상까지 미뤄져 **우리가 탈출하려던 문제를
         *    그대로 재현**하고, "allow-while-idle이 안 되는구나"로 오독하게 된다.
         */
        fun arm(context: Context, hour: Int, minute: Int) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                .putInt(KEY_HOUR, hour).putInt(KEY_MINUTE, minute).apply()
            armNextDaily(context, reason = "arm($hour:$minute)")
        }

        /** 저장된 시각의 "다음 발생"으로 무장. 이미 지났으면 내일. */
        fun armNextDaily(context: Context, reason: String) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val hour = prefs.getInt(KEY_HOUR, -1)
            val minute = prefs.getInt(KEY_MINUTE, -1)
            if (hour < 0 || minute < 0) {
                Log.d(TAG, "ARM skipped ($reason) — 저장된 시각 없음")
                return
            }
            val cal = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, hour)
                set(Calendar.MINUTE, minute)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
                if (timeInMillis <= System.currentTimeMillis()) add(Calendar.DAY_OF_YEAR, 1)
            }
            val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, cal.timeInMillis, pendingIntent(context))
            Log.d(
                TAG,
                "ARMED ($reason) for=${SimpleDateFormat("MM-dd HH:mm:ss", Locale.US).format(cal.time)}",
            )
        }

        /** 테스트용 — [minutes]분 뒤 1회. 매일 반복 무장과 무관하게 단발. */
        fun armInMinutes(context: Context, minutes: Int) {
            val at = System.currentTimeMillis() + minutes * 60_000L
            val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pendingIntent(context))
            Log.d(
                TAG,
                "ARMED (in ${minutes}m) for=${SimpleDateFormat("MM-dd HH:mm:ss", Locale.US).format(Date(at))}",
            )
        }

        /**
         * expedited one-time work 등록.
         *
         * `RUN_AS_NON_EXPEDITED_WORK_REQUEST`: expedited 쿼터가 소진됐으면 예외를 던지는
         * 대신 **일반 job으로 강등**된다. 강등되면 유지보수 창까지 밀리므로 로그 시각으로
         * 구분된다(발화 직후면 expedited, 한참 뒤면 강등). 던지는 정책을 쓰면 쿼터 소진이
         * 크래시가 되어 측정 자체가 날아간다.
         *
         * API 31 미만에서 expedited는 foreground service를 요구하는데 우리는 FGS를 쓰지
         * 않으므로(제품 결정) 그 아래에서는 등록하지 않는다. minSdk가 29라 실기기에서
         * 발생 가능한 분기다.
         */
        private fun enqueueExpeditedProbe(context: Context, t0: Long) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
                Log.d(TAG, "EXPEDITED skipped — API ${Build.VERSION.SDK_INT} < 31 (FGS 필요)")
                return
            }
            try {
                val req = OneTimeWorkRequest.Builder(DozeAlarmProbeWorker::class.java)
                    .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
                    .setInputData(
                        Data.Builder()
                            .putLong(DozeAlarmProbeWorker.KEY_ENQUEUED_AT, t0)
                            .build(),
                    )
                    .build()
                WorkManager.getInstance(context)
                    .enqueueUniqueWork(EXPEDITED_NAME, ExistingWorkPolicy.REPLACE, req)
                Log.d(TAG, "EXPEDITED enqueued ($EXPEDITED_NAME)")
            } catch (e: Throwable) {
                Log.d(TAG, "EXPEDITED enqueue 실패: ${e.javaClass.simpleName}: ${e.message}")
            }
        }

        fun cancel(context: Context) {
            (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager)
                .cancel(pendingIntent(context))
            Log.d(TAG, "CANCELLED")
        }
    }
}
