package kr.co.anbucheck.live

import android.app.AlarmManager
import android.app.usage.UsageStatsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.wifi.WifiManager
import android.os.Build
import android.os.PowerManager
import android.os.SystemClock
import android.util.Log
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequest
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
import java.net.InetAddress
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

/**
 * Doze 관통 실측 프로브 — **알람은 앱을 깨우고, expedited job이 방화벽을 연다.**
 *
 * ## 지금까지 확정된 것 (실측)
 *
 * | 관측 | 결과 |
 * |---|---|
 * | allow-while-idle 알람이 딥 Doze + RARE에서 발화 | ✅ n=3 (+7~32분) |
 * | 알람 단독으로 네트워크 방화벽이 열리는가 | ❌ **안 열림** — `temp-power-save` 미부여 |
 * | expedited job enqueue 시 방화벽 | ✅ **열림** — `dozable-allow` + `standby-default` |
 * | 창 길이 | job 수명을 따라감 (worker 즉시 반환 시 376ms~1.06초) |
 * | 열린 창으로 데이터가 흐르는가 | ❓ **미측정** ← [DozeAlarmProbeWorker]가 잰다 |
 *
 * ## 이 리시버가 하지 **않는** 것 — 직접 네트워크 프로브
 *
 * 이전 판은 발화 직후 T+0/9/15s에 직접 HTTP 프로브를 돌렸다. 그 T+0s는 **방화벽이 열리기
 * 62ms 전**에 실행되어 반드시 실패했고, 그 실패가 DNS 음성 캐시에 남아 **103ms 뒤 열린
 * 창에서 돌던 expedited 프로브를 DNS 조회도 없이 1ms 만에 실패**시켰다(2026-08-22 09:37).
 * Android의 음성 캐시는 2초 고정이며 `networkaddress.cache.negative.ttl`은 죽은
 * 코드라 끌 수 없다(AOSP libcore). **측정 대상보다 먼저 도는 네트워크 호출을 두지 않는 것이
 * 유일한 해법**이라 전부 제거했다. "닫힌 창에서는 실패한다"는 대조군은 `dumpsys netpolicy`의
 * `allowed=NONE` 기록으로 이미 n=2 확보돼 있어 앱에서 다시 잴 필요가 없다.
 */
class DozeAlarmProbeReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON"
        ) {
            armNextDaily(context, reason = "boot")
            return
        }

        // ★ 재무장을 무엇보다 먼저. worker에서 배운 불변식이다 — lmkd가 프로세스를 시작
        // 0.73초 만에 죽인 실측이 있고(2026-08-18 15:07) 리시버도 동일하게 노출돼 있다.
        armNextDaily(context, reason = "refire")

        val t0 = SystemClock.elapsedRealtime()
        Log.d(TAG, "FIRED at=${now()} ${context(context)}")

        // 네트워크를 건드리는 첫 동작이 expedited worker여야 한다(위 클래스 주석 참조).
        enqueueExpedited(context, t0)
    }

    private fun now(): String = SimpleDateFormat("HH:mm:ss.SSS", Locale.US).format(Date())

    private fun context(c: Context): String {
        val idle = try {
            (c.getSystemService(Context.POWER_SERVICE) as PowerManager).isDeviceIdleMode
        } catch (_: Throwable) { null }
        val bucket = try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                (c.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager).appStandbyBucket
            } else -1
        } catch (_: Throwable) { -2 }
        val wifi = try {
            @Suppress("DEPRECATION")
            val i = (c.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager)
                .connectionInfo
            "${i.supplicantState}/${i.rssi}dBm"
        } catch (_: Throwable) { "?" }
        return "idle=$idle bucket=$bucket wifi=$wifi"
    }

    companion object {
        const val TAG = "DozeAlarmProbe"
        private const val REQUEST_CODE = 90001
        private const val ACTION = "kr.co.anbucheck.live.DOZE_ALARM_PROBE"
        private const val EXPEDITED_NAME = "doze_alarm_expedited_probe"

        private const val PREFS = "doze_alarm_probe"
        private const val KEY_HOUR = "hour"
        private const val KEY_MINUTE = "minute"
        private const val KEY_IP = "server_ip"
        private const val PROBE_HOST = "web-production-43beb.up.railway.app"

        private fun pendingIntent(context: Context) = android.app.PendingIntent.getBroadcast(
            context,
            REQUEST_CODE,
            Intent(context, DozeAlarmProbeReceiver::class.java).setAction(ACTION),
            android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE,
        )

        /**
         * expedited one-time work 등록 — **방화벽을 여는 실제 주체.**
         *
         * `RUN_AS_NON_EXPEDITED_WORK_REQUEST`: 쿼터 소진 시 예외 대신 일반 job으로 강등된다.
         * 강등은 로그 시각으로 구분된다(발화 직후면 expedited, 유지보수 창에야 나타나면 강등).
         * 던지는 정책을 쓰면 쿼터 소진이 크래시가 되어 측정 자체가 날아간다.
         *
         * API 31 미만은 expedited가 foreground service를 요구하는데 FGS는 제품 결정상
         * 쓰지 않으므로 등록하지 않는다(minSdk 29라 실기기에서 발생 가능한 분기).
         */
        private fun enqueueExpedited(context: Context, t0: Long) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
                Log.d(TAG, "EXP skipped — API ${Build.VERSION.SDK_INT} < 31 (FGS 필요)")
                return
            }
            try {
                val ip = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                    .getString(KEY_IP, null) ?: DozeAlarmProbeWorker.FALLBACK_IP
                val req = OneTimeWorkRequest.Builder(DozeAlarmProbeWorker::class.java)
                    .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
                    .setInputData(
                        Data.Builder()
                            .putLong(DozeAlarmProbeWorker.KEY_ENQUEUED_AT, t0)
                            .putString(DozeAlarmProbeWorker.KEY_SERVER_IP, ip)
                            .build(),
                    )
                    .build()
                WorkManager.getInstance(context)
                    .enqueueUniqueWork(EXPEDITED_NAME, ExistingWorkPolicy.REPLACE, req)
                Log.d(TAG, "EXP enqueued ip=$ip")
            } catch (e: Throwable) {
                Log.d(TAG, "EXP enqueue 실패: ${e.javaClass.simpleName}: ${e.message}")
            }
        }

        /**
         * 매일 [hour]:[minute]에 발화하도록 무장하고, **이 시점에 서버 IP를 해석해 저장**한다.
         *
         * 무장은 앱 포그라운드에서만 일어나므로 이때는 망이 열려 있다. 발화 시점에는 DNS가
         * 막혀 있을 수 있으므로 미리 확보한 IP로 **raw TCP를 시도**해 "DNS만 막힌 것"과
         * "통신 자체가 막힌 것"을 구분한다. 전자라면 IP 캐시가 그대로 우회로가 된다.
         *
         * ⚠️ `setAndAllowWhileIdle`(부정확) + `RTC_WAKEUP` 조합이어야 한다.
         *  - `setExactAndAllowWhileIdle`은 `SCHEDULE_EXACT_ALARM`을 요구하고, 그 권한은
         *    Android 14+ 기본 거부 + Play 정책상 알람시계·캘린더 전용이라 쓸 수 없다.
         *  - `RTC`(비-wakeup)는 다음 기기 기상까지 미뤄져 탈출하려던 문제를 그대로 재현하고
         *    "allow-while-idle이 안 되는구나"로 오독하게 만든다.
         */
        fun arm(context: Context, hour: Int, minute: Int) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                .putInt(KEY_HOUR, hour).putInt(KEY_MINUTE, minute).apply()
            resolveAndCacheIp(context)
            armNextDaily(context, reason = "arm($hour:$minute)")
        }

        private fun resolveAndCacheIp(context: Context) {
            Thread {
                try {
                    val ip = InetAddress.getByName(PROBE_HOST).hostAddress ?: return@Thread
                    context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
                        .putString(KEY_IP, ip).apply()
                    Log.d(TAG, "IP cached: $ip")
                } catch (e: Throwable) {
                    Log.d(TAG, "IP 해석 실패(폴백 사용): ${e.javaClass.simpleName}")
                }
            }.start()
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

        /** 테스트용 단발 — [minutes]분 뒤 1회. */
        fun armInMinutes(context: Context, minutes: Int) {
            resolveAndCacheIp(context)
            val at = System.currentTimeMillis() + minutes * 60_000L
            val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pendingIntent(context))
            Log.d(TAG, "ARMED (in ${minutes}m) for=${SimpleDateFormat("MM-dd HH:mm:ss", Locale.US).format(Date(at))}")
        }

        fun cancel(context: Context) {
            (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager)
                .cancel(pendingIntent(context))
            Log.d(TAG, "CANCELLED")
        }
    }
}
