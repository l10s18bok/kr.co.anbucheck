package kr.co.anbucheck.live

import android.app.AlarmManager
import android.app.usage.UsageStatsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.wifi.WifiManager
import android.os.Build
import android.os.PowerManager
import android.util.Log
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequest
import androidx.work.ListenableWorker
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
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
 * | 열린 창으로 데이터가 흐르는가 | ✅ 2026-08-24 종단 성공 (예약 07:00 → 전송 07:07:56) |
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
class HeartbeatAlarmReceiver : BroadcastReceiver() {

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
            // 부팅·업데이트 복원은 **무조건 무장한다**(force). 이 경로들은 알람이
            // 사라진 상태를 되돌리는 것이 목적이라 "오늘 창 유지" 판정이 끼어들면 안 된다.
            armNextDaily(context, reason = "system:${intent.action}", force = true)
            return
        }

        // ★ 재무장을 무엇보다 먼저. worker에서 배운 불변식이다 — lmkd가 프로세스를 시작
        // 0.73초 만에 죽인 실측이 있고(2026-08-18 15:07) 리시버도 동일하게 노출돼 있다.
        // ⚠️ **재무장은 무조건이다(force).** 발화 직후는 "창 안 + 오늘 미전송"이 모두
        //    참이라 가드에 걸리는데, 여기서 건너뛰면 **다음 날 알람이 무장되지 않는다.**
        //    창 만료·lmkd 킬로 이 프로세스가 곧 죽어도 트리거가 살아남아야 한다.
        armNextDaily(context, reason = "refire", force = true)

        Log.d(TAG, "FIRED at=${now()} ${context(context)}")

        // 네트워크를 건드리는 첫 동작이 expedited worker여야 한다(위 클래스 주석 참조).
        // ★ 역할 분리 (2026-08-23 06:07 실패에서 나온 설계)
        //   (1) expedited "창 유지자" — 방화벽을 열어둔 채 버틴다
        //   (2) 일반 heartbeat worker — 실제 전송을 한다
        // 전송을 expedited job "안에서" 하려던 앞선 시도는 실패했다. 알람이 깨운
        // 프로세스에서 워커가 3개 뜨고, SQLite 락을 잡아 전송하는 워커가 expedited가
        // 아닐 수 있어 **창이 전송보다 먼저 닫혔다**(11.1초).
        enqueueWindowHolder(context)
        enqueueHeartbeat(context)
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
        const val TAG = "HeartbeatAlarm"
        private const val REQUEST_CODE = 90001
        private const val ACTION = "kr.co.anbucheck.live.HEARTBEAT_ALARM"
        private const val HEARTBEAT_WORK_NAME = "heartbeat_alarm"
        private const val HOLDER_WORK_NAME = "heartbeat_window_holder"
        private const val WM_BACKGROUND_WORKER = "dev.fluttercommunity.workmanager.BackgroundWorker"
        private const val WM_DART_TASK_KEY = "dev.fluttercommunity.workmanager.DART_TASK"

        /**
         * `HeartbeatWorkerService._taskName`과 같은 값이어야 한다(Dart/Kotlin이 상수를
         * 공유할 수 없어 수동 동기화). 다만 우리 Dart 콜백은 `taskName`으로 분기하지 않고
         * `inputData`만 읽으므로, 어긋나도 동작에는 영향이 없고 로그만 달라진다.
         */
        private const val DART_TASK_NAME = "heartbeat_task"

        /**
         * 예약시각은 **Dart가 쓰는 prefs를 직접 읽는다.** 알람이 자체 복사본을 갖지 않는 이유:
         *
         *  - 복사본은 **포그라운드에서만** 채워진다. 그러면 업데이트·재부팅 후 사용자가 앱을
         *    열기 전까지 알람이 무장되지 않는다. 이 앱의 주 대상은 **앱을 열지 않는 사용자**라
         *    혜택을 가장 받아야 할 사람이 못 받는 구조가 된다.
         *  - 단일 출처가 되어 Dart의 예약시각과 알람이 어긋날 여지가 없다.
         *  - prefs 이름이 바뀌어도 마이그레이션이 필요 없다.
         *
         * ⚠️ `shared_preferences`는 Dart `int`를 **`putLong`으로 저장**한다
         * (`MethodCallHandlerImpl`의 `putLong(key, number.longValue())`). `getInt`로 읽으면
         * `ClassCastException`이 난다 — 반드시 `getLong`을 쓰고, 구버전 대비 `getInt` 폴백을 둔다.
         */
        /**
         * allow-while-idle 알람의 배달 창 상한. `dumpsys alarm`이 이 알람에 대해
         * `window=+1h0m0s0ms`로 표시하는 값과 같고, 문서상 "API 31+는 1시간 이내"와도 일치한다.
         * 실측 발화는 예약 +7~32분(n=6)이었다.
         *
         * [todaysWindowStillUseful]이 "오늘 알람이 아직 뜰 수 있는가"를 판정하는 데만 쓴다.
         * 조금 넉넉하게 잡아도 손해는 헛기상 1회뿐이고, 짧게 잡으면 아직 뜰 수 있는 알람을
         * 지우게 되므로 **줄이지 말 것.**
         */
        private const val ALARM_WINDOW_MS = 60L * 60L * 1000L

        private const val FLUTTER_PREFS = "FlutterSharedPreferences"
        private const val KEY_HOUR = "flutter.heartbeat_hour"
        private const val KEY_MINUTE = "flutter.heartbeat_minute"

        /**
         * 역할 가드용 키. Dart 워커 콜백의 `if (role != 'subject' && !isAlsoSubject) return`과
         * **같은 기준**이다.
         *
         * ⚠️ 예약시각만 보고 무장하면 안 된다. `disableSubjectFeature`(G+S 끄기)는
         * `is_also_subject=false`만 저장하고 **예약시각은 남겨 둔다**(재활성화 시 설정 보존).
         * 그 상태에서 프로세스가 뜨면 `Application.onCreate`가 남은 시각으로 알람을 다시
         * 무장하고, `onReceive`가 스스로 재무장하므로 **매일 기기를 깨우는 낭비가 영구히
         * 반복된다.** 발화해도 Dart의 role 가드에 걸려 아무 일도 하지 않지만, 깨우는 비용은
         * 그대로 든다. 백그라운드 isolate의 401 계정 삭제 경로는 `HeartbeatAlarm.cancel()`이
         * 채널 부재로 스킵되므로 더 확실히 걸린다.
         */
        private const val KEY_ROLE = "flutter.user_role"
        private const val KEY_IS_ALSO_SUBJECT = "flutter.is_also_subject"
        private fun pendingIntent(context: Context) = android.app.PendingIntent.getBroadcast(
            context,
            REQUEST_CODE,
            Intent(context, HeartbeatAlarmReceiver::class.java).setAction(ACTION),
            android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE,
        )

        /**
         * 방화벽을 열어둘 [HeartbeatWindowHolderWorker]를 **expedited로** 등록한다.
         * 이 worker가 방화벽을 여는 유일한 주체이며, heartbeat worker는 일반 우선순위로
         * 따로 돌면서 그 창 안에서 전송을 끝낸다.
         */
        private fun enqueueWindowHolder(context: Context) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return
            try {
                val req = OneTimeWorkRequest.Builder(HeartbeatWindowHolderWorker::class.java)
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
                // ⚠️ **expedited를 쓰지 않는다.** 창은 [HeartbeatWindowHolderWorker]가 담당한다.
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
                // ⚠️ 이 work는 **expedited가 아니다**(평범한 OneTimeWorkRequest). 방화벽을 여는
                //    expedited job은 창 유지자 하나뿐이다. 예전 문구가 "expedited"라
                //    로그만 보고 이 work가 창을 연다고 오해하기 쉬웠다.
                Log.d(TAG, "HB enqueued ($HEARTBEAT_WORK_NAME, non-expedited)")
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
            // Dart가 `saveHeartbeatSchedule`로 prefs를 먼저 쓴 뒤 이 경로를 부르므로
            // 값은 이미 저장돼 있다. 여기서는 전달받은 값을 그대로 써서 prefs 읽기에
            // 의존하지 않는다(포그라운드 경로는 정확한 값을 이미 갖고 있다).
            armAt(context, hour, minute, reason = "arm($hour:$minute)")
        }

        /** 저장된 시각의 "다음 발생"으로 무장. 이미 지났으면 내일. */
        /**
         * [force] = true면 "오늘 발화 창 유지" 판정을 건너뛰고 무조건 다음 발생으로 무장한다.
         * 알람이 사라진 상태를 되돌리는 경로(발화 직후 재무장·부팅·업데이트)에만 쓴다.
         * `Application.onCreate`처럼 **아무 이유로나 뜨는** 경로는 force를 쓰면 안 된다 —
         * 그게 아직 발화하지 않은 오늘 알람을 지우던 원인이다.
         */
        fun armNextDaily(context: Context, reason: String, force: Boolean = false) {
            val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
            if (!isSubjectEnabled(prefs)) {
                Log.d(TAG, "ARM skipped ($reason) — 대상자 기능 꺼짐")
                return
            }
            val hour = readScheduleInt(prefs, KEY_HOUR)
            val minute = readScheduleInt(prefs, KEY_MINUTE)
            if (hour < 0 || minute < 0) {
                // 대상자/G+S가 아니거나 아직 한 번도 스케줄을 받지 않은 기기 — 무장하지 않는다.
                Log.d(TAG, "ARM skipped ($reason) — 예약시각 없음 (h=$hour m=$minute)")
                return
            }
            if (!force && todaysWindowStillUseful(context, prefs, hour, minute)) {
                // 오늘 발화 창이 아직 살아 있고 오늘 전송도 없다 — 그대로 둔다.
                Log.d(TAG, "ARM skipped ($reason) — 오늘 발화 창 유지 ($hour:$minute)")
                return
            }
            armAt(context, hour, minute, reason)
        }

        /**
         * "지금 재무장하면 **아직 발화하지 않은 오늘 알람을 없애게 되는가**"를 판정한다.
         *
         * [armNextDaily]는 저장 시각의 **다음 발생**을 계산하므로, 예약시각이 지난 뒤
         * 어떤 이유로든 프로세스가 뜨면(워커 발화·FCM 도착) 같은 PendingIntent를 내일자로
         * 덮어써 **오늘 남은 발화 창을 지운다.** 취소는 `Application.onCreate`에서
         * **전송을 시도하기도 전에** 일어나므로 그날의 성패와 무관하다.
         *
         * 2026-08-27 샤오미 실측: one-off이 알람보다 1분 43초 먼저 프로세스를 띄웠고
         * (`ARMED (app-process-start) for=08-28`), 알람은 발화 기회를 잃었다. MIUI는
         * WorkManager가 관대해(+1m49s~+19분) 알람(+7~32분)보다 대체로 빠르므로 이게 상시였다.
         *
         * 대부분은 무해하다 — 워커가 성공하면 알람은 어차피 불필요하다. 그러나 **워커가
         * 먼저 실패한 날에는 방화벽을 여는 유일한 재시도를 잃는다**(창 유지자는 알람 경로에만 있다).
         *
         * 세 조건이 모두 참일 때만 건너뛴다:
         *  1. **오늘용 알람이 실제로 대기 중** — `FLAG_NO_CREATE`가 null이 아니어야 한다.
         *     ⚠️ 이 조건이 없으면 **최초 설치가 깨진다**: 창 안에서 처음 무장하는 기기가
         *     아무것도 등록하지 못한 채 건너뛰게 된다.
         *  2. 지금이 `[T, T + ALARM_WINDOW_MS]` 안 — 창 밖이면 오늘 알람은 이미 소멸했다.
         *  3. 오늘 전송 기록이 없다 — 있으면 오늘 알람은 불필요하니 내일자로 정리한다.
         *
         * 대가: 워커가 성공한 날에도 알람이 그대로 발화한다(성공 경로의 `HeartbeatAlarm.arm`은
         * MethodChannel이 `MainActivity` 전용이라 워커 isolate에서 no-op). 발화해도
         * `lastHeartbeatDate == 오늘` 가드로 즉시 스킵하고 `onReceive`가 내일자로 재무장하므로
         * 하루 1회 헛기상에 그친다(알람 계층 전체 실측 0.34 mAh/일).
         */
        private fun todaysWindowStillUseful(
            context: Context,
            prefs: android.content.SharedPreferences,
            hour: Int,
            minute: Int,
        ): Boolean = try {
            val pending = android.app.PendingIntent.getBroadcast(
                context,
                REQUEST_CODE,
                Intent(context, HeartbeatAlarmReceiver::class.java).setAction(ACTION),
                android.app.PendingIntent.FLAG_NO_CREATE or android.app.PendingIntent.FLAG_IMMUTABLE,
            )
            if (pending == null) {
                false
            } else {
                val scheduled = Calendar.getInstance().apply {
                    set(Calendar.HOUR_OF_DAY, hour)
                    set(Calendar.MINUTE, minute)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }.timeInMillis
                val now = System.currentTimeMillis()
                now >= scheduled &&
                    now < scheduled + ALARM_WINDOW_MS &&
                    !heartbeatDoneToday(prefs)
            }
        } catch (_: Throwable) {
            // 판정 실패 시 기존 동작(재무장)으로 간다 — 무장이 아예 없는 상태보다 낫다.
            false
        }

        /** `flutter.last_heartbeat_date`가 오늘인가. 창 유지자와 같은 값을 본다. */
        private fun heartbeatDoneToday(prefs: android.content.SharedPreferences): Boolean = try {
            val v = prefs.getString("flutter.last_heartbeat_date", null)
            v != null && v == SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        } catch (_: Throwable) {
            false
        }

        /** Dart 워커 콜백과 같은 기준: `role == 'subject' || isAlsoSubject`. */
        private fun isSubjectEnabled(prefs: android.content.SharedPreferences): Boolean = try {
            val role = prefs.getString(KEY_ROLE, null)
            val alsoSubject = try { prefs.getBoolean(KEY_IS_ALSO_SUBJECT, false) } catch (_: Throwable) { false }
            role == "subject" || alsoSubject
        } catch (_: Throwable) {
            // 읽기 실패 시 무장하지 않는다 — 잘못 무장해 매일 기기를 깨우는 쪽이
            // 무장하지 않는 쪽(= 기존 1~3차 동작)보다 나쁘다.
            false
        }

        /** `shared_preferences`의 Long 저장을 읽되, 구버전이 Int로 넣었을 가능성에 대비한다. */
        private fun readScheduleInt(prefs: android.content.SharedPreferences, key: String): Int =
            try {
                prefs.getLong(key, -1L).toInt()
            } catch (_: ClassCastException) {
                try { prefs.getInt(key, -1) } catch (_: Throwable) { -1 }
            } catch (_: Throwable) { -1 }

        private fun armAt(context: Context, hour: Int, minute: Int, reason: String) {
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

        fun cancel(context: Context) {
            (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager)
                .cancel(pendingIntent(context))
            Log.d(TAG, "CANCELLED")
        }
    }
}
