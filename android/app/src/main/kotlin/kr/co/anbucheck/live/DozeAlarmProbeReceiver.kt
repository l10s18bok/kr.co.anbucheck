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
import androidx.work.ListenableWorker
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
        // 재무장이 필요한 시스템 이벤트.
        //
        // ⚠️ `MY_PACKAGE_REPLACED`가 핵심이다 — **Play 자동 업데이트는 사용자가 앱을 열지
        // 않아도 일어나고, 그때 앱의 알람은 유실된다.** 이걸 처리하지 않으면 업데이트된
        // 기기는 사용자가 앱을 다시 열 때까지 알람이 없는 상태로 지낸다. 개발 중에는 매번
        // 설치 후 앱을 열어봐서 드러나지 않던 구멍이다.
        // 재부팅도 마찬가지로 알람을 지운다.
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == Intent.ACTION_MY_PACKAGE_REPLACED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON"
        ) {
            armNextDaily(context, reason = "system:${intent.action}")
            return
        }

        // ★ 재무장을 무엇보다 먼저. worker에서 배운 불변식이다 — lmkd가 프로세스를 시작
        // 0.73초 만에 죽인 실측이 있고(2026-08-18 15:07) 리시버도 동일하게 노출돼 있다.
        armNextDaily(context, reason = "refire")

        val t0 = SystemClock.elapsedRealtime()
        Log.d(TAG, "FIRED at=${now()} ${context(context)}")

        // 네트워크를 건드리는 첫 동작이 expedited worker여야 한다(위 클래스 주석 참조).
        if (MEASURE_ONLY) {
            enqueueMeasurementProbe(context, t0)
        } else {
            // ★ 역할 분리 (2026-08-23 06:07 실패에서 나온 설계)
            //   (1) expedited "창 유지자" — 방화벽을 열어둔 채 버틴다
            //   (2) 일반 heartbeat worker — 실제 전송을 한다
            // 전송을 expedited job "안에서" 하려던 앞선 시도는 실패했다. 알람이 깨운
            // 프로세스에서 워커가 3개 뜨고, SQLite 락을 잡아 전송하는 워커가 expedited가
            // 아닐 수 있어 **창이 전송보다 먼저 닫혔다**(11.1초).
            enqueueWindowHolder(context)
            enqueueHeartbeat(context)
        }
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

        /**
         * `true`면 실제 heartbeat 대신 [DozeAlarmProbeWorker]로 **창만 다시 측정**한다.
         * 평소에는 `false`. 창 특성이 의심될 때 이 한 줄만 뒤집으면 측정 모드로 돌아간다.
         */
        private const val MEASURE_ONLY = false

        private const val HEARTBEAT_WORK_NAME = "heartbeat_alarm"
        private const val HOLDER_WORK_NAME = "doze_window_holder"
        private const val WM_BACKGROUND_WORKER = "dev.fluttercommunity.workmanager.BackgroundWorker"
        private const val WM_DART_TASK_KEY = "dev.fluttercommunity.workmanager.DART_TASK"

        /**
         * `HeartbeatWorkerService._taskName`과 같은 값이어야 한다(Dart/Kotlin이 상수를
         * 공유할 수 없어 수동 동기화). 다만 우리 Dart 콜백은 `taskName`으로 분기하지 않고
         * `inputData`만 읽으므로, 어긋나도 동작에는 영향이 없고 로그만 달라진다.
         */
        private const val DART_TASK_NAME = "heartbeat_task"

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
        private fun enqueueMeasurementProbe(context: Context, t0: Long) {
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
         * ★ **실제 heartbeat를 expedited job으로 실행한다** — Phase 2의 본체.
         *
         * 2026-08-22 11:04 실측으로 확정된 구조를 그대로 따른다:
         *   알람이 앱을 깨우고 → expedited job이 방화벽을 열고(`allowed=FOREGROUND`)
         *   → **창이 job 수명을 따라가므로 전송을 그 job 안에서** 한다.
         * 전송을 별도 worker에 맡기면 창이 먼저 닫힌다(07:07 실측: 창 376ms 뒤 종료,
         * 그 뒤로도 `BackgroundWorker`가 5초를 차단 상태로 실행).
         *
         * 새 Dart 경로를 만들지 않고 **workmanager 플러그인의 `BackgroundWorker`를 그대로
         * expedited로 enqueue**한다. 콜백 핸들은 플러그인이 이미 SharedPreferences에
         * 저장해 둔 것을 그 worker가 읽으므로 우리가 관여하지 않는다.
         *
         * `Class.forName`을 쓰는 이유: 플러그인 Gradle 모듈에 컴파일 의존을 걸지 않기
         * 위함이다. 플러그인 구조가 바뀌면 컴파일 실패 대신 런타임 예외가 나고, 그때는
         * 이 경로만 조용히 죽고 기존 3계층은 그대로 산다.
         *
         * ⚠️ **중복 전송은 기존 방어선이 막는다** — `lastScheduledKey`(성공 마커) +
         * `HeartbeatLockDatasource`(SQLite UNIQUE CAS). 알람 경로와 정시 one-off/periodic이
         * 겹쳐도 하나만 전송된다. 여기에 새 가드를 추가하지 말 것.
         *
         * `payload_unique`를 넘기는 이유: Dart 콜백이 이 값으로 `runningUniqueName`을
         * 정하고, 그걸로 "재등록 대상이 자기 자신인가"를 판별해 self-cancel을 막는다.
         * 알람 경로는 one-off·periodic 어느 쪽도 아니므로 고유한 이름을 준다.
         */
        /**
         * 방화벽을 열어둘 [DozeWindowHolderWorker]를 **expedited로** 등록한다.
         * 이 worker가 방화벽을 여는 유일한 주체이며, heartbeat worker는 일반 우선순위로
         * 따로 돌면서 그 창 안에서 전송을 끝낸다.
         */
        private fun enqueueWindowHolder(context: Context) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return
            try {
                val req = OneTimeWorkRequest.Builder(DozeWindowHolderWorker::class.java)
                    .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
                    .build()
                WorkManager.getInstance(context)
                    .enqueueUniqueWork(HOLDER_WORK_NAME, ExistingWorkPolicy.REPLACE, req)
                Log.d(TAG, "HOLD enqueued ($HOLDER_WORK_NAME)")
            } catch (e: Throwable) {
                Log.d(TAG, "HOLD enqueue 실패: ${e.javaClass.simpleName}: ${e.message}")
            }
        }

        @Suppress("UNCHECKED_CAST")
        private fun enqueueHeartbeat(context: Context) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
                Log.d(TAG, "HB skipped — API ${Build.VERSION.SDK_INT} < 31 (expedited가 FGS 요구)")
                return
            }
            try {
                val cls = Class.forName(WM_BACKGROUND_WORKER) as Class<out ListenableWorker>
                // ⚠️ **expedited를 쓰지 않는다.** 창은 [DozeWindowHolderWorker]가 담당한다.
                // 둘 다 expedited면 쿼터를 두 배로 쓰면서, 먼저 끝나는 쪽이 창을 닫아
                // 08-23의 실패가 재현된다.
                val req = OneTimeWorkRequest.Builder(cls)
                    .setInputData(
                        Data.Builder()
                            .putString(WM_DART_TASK_KEY, DART_TASK_NAME)
                            .putString("payload_source", "alarm")
                            .putString("payload_unique", HEARTBEAT_WORK_NAME)
                            .build(),
                    )
                    .build()
                WorkManager.getInstance(context)
                    .enqueueUniqueWork(HEARTBEAT_WORK_NAME, ExistingWorkPolicy.REPLACE, req)
                Log.d(TAG, "HB expedited enqueued ($HEARTBEAT_WORK_NAME)")
            } catch (e: Throwable) {
                Log.d(TAG, "HB enqueue 실패: ${e.javaClass.simpleName}: ${e.message}")
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

        /**
         * 서버 IP를 미리 해석해 저장 — **[MEASURE_ONLY] 모드에서만 쓴다.**
         *
         * 측정 모드의 raw TCP 프로브가 DNS를 타지 않기 위한 값이다. 프로덕션 경로에서는
         * 쓰이지 않으므로, 앱 진입마다(=`schedule()`마다) 스레드를 띄워 DNS를 치는 낭비를
         * 하지 않도록 여기서 잘라낸다.
         */
        private fun resolveAndCacheIp(context: Context) {
            if (!MEASURE_ONLY) return
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
