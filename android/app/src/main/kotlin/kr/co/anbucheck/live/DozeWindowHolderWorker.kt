package kr.co.anbucheck.live

import android.content.Context
import android.os.SystemClock
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * **방화벽 창을 열어두는 것만이 임무인** expedited worker.
 *
 * ## 왜 필요한가 (2026-08-23 06:07 실패에서 나온 설계)
 *
 * 딥 Doze에서 네트워크 방화벽은 **expedited job이 실행되는 동안에만** 열린다
 * (`allowed=FOREGROUND`). 창 길이 = job 수명이라는 것은 08-22에 확인했다.
 *
 * 처음에는 heartbeat 전송 자체를 expedited job 안에서 하려 했다(플러그인의
 * `BackgroundWorker`를 expedited로 enqueue). 그런데 **실패했다**:
 *
 *  - 알람이 프로세스를 깨우자 WorkManager가 밀려 있던 one-off·periodic까지 방출해
 *    **워커가 3개** 떴고, 각자 FlutterEngine을 부팅하느라 Dart 진입에 **11초**가 걸렸다.
 *  - SQLite 락을 잡아 실제로 전송하는 워커가 **expedited가 아닐 수 있다.** 그날이 그랬다 —
 *    expedited job은 락 경쟁에서 져 11초 만에 스킵으로 끝났고, **창은 그때 닫혔으며**,
 *    전송은 창 밖에서 이뤄져 실패했다(`send_failed` 알림).
 *
 * → **전송 주체와 창을 여는 주체를 분리한다.** 이 worker는 아무 일도 하지 않고 그냥
 *   살아 있으면서 창을 유지한다. 그러면 **누가 전송하든 창 안**에서 끝난다.
 *
 * ## 언제 끝나는가
 *
 * `flutter.last_heartbeat_date`(Flutter `shared_preferences`가 쓰는 실제 키)를 폴링해
 * 오늘 날짜가 되면 조기 종료한다. 못 읽거나 갱신되지 않으면 [HOLD_MS]까지 버틴다 —
 * **읽기 실패의 안전한 방향이 "더 오래 여는 것"**이라 키 이름이 바뀌어도 망가지지 않는다.
 * 어느 쪽으로 끝났는지 로그에 남으므로 키 접근이 실제로 되는지도 함께 검증된다.
 *
 * ## 상한 근거
 *
 * 08-22 실측에서 41초까지 `onStopped()`가 없었다. [HOLD_MS]는 그보다 길게 잡되
 * (엔진 11초 + 걸음수 조회 + 전송 여유), 시스템이 중단시키면 `onStopped()` 로그로
 * 그 상한이 어디인지 드러난다.
 */
class DozeWindowHolderWorker(private val ctx: Context, params: WorkerParameters) :
    Worker(ctx, params) {

    @Volatile private var stopped = false

    override fun onStopped() {
        stopped = true
        Log.d(TAG, "HOLD onStopped at=${now()}  ← 시스템이 중단시킴(창 상한 발견)")
        super.onStopped()
    }

    override fun doWork(): Result {
        val t0 = SystemClock.elapsedRealtime()
        Log.d(TAG, "HOLD started at=${now()} budget=${HOLD_MS}ms")

        var reason = "timeout"
        while (SystemClock.elapsedRealtime() - t0 < HOLD_MS) {
            if (stopped) { reason = "stopped"; break }
            if (heartbeatDoneToday()) { reason = "heartbeat-done"; break }
            try { Thread.sleep(POLL_MS) } catch (_: InterruptedException) { reason = "interrupted"; break }
        }

        Log.d(
            TAG,
            "HOLD ended at=${now()} held=${SystemClock.elapsedRealtime() - t0}ms reason=$reason",
        )
        return Result.success()
    }

    /**
     * Dart가 전송 성공 시 기록하는 마커를 네이티브에서 읽는다.
     *
     * `shared_preferences`는 `FlutterSharedPreferences` XML에 `flutter.` 접두사로 저장하고,
     * 문자열은 그대로 들어간다. 같은 프로세스라 Dart의 `apply()` 결과가 바로 보인다.
     * 읽기에 실패하면 `false`를 돌려 **창을 더 오래 여는 쪽**으로 기운다.
     */
    private fun heartbeatDoneToday(): Boolean = try {
        val v = ctx.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .getString("flutter.last_heartbeat_date", null)
        v != null && v == SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
    } catch (_: Throwable) {
        false
    }

    private fun now(): String = SimpleDateFormat("HH:mm:ss.SSS", Locale.US).format(Date())

    companion object {
        private val TAG = DozeAlarmProbeReceiver.TAG

        /**
         * 창을 유지할 최대 시간.
         *
         * 실측 근거: 엔진 부팅 11초 + 걸음수 조회(딥 Doze에서 33초 관측) + 전송 20초 예산.
         * 08-22에 41초까지는 `onStopped()`가 없었다. 90초가 통과하는지는 이번 회차가 잰다.
         */
        private const val HOLD_MS = 90_000L
        private const val POLL_MS = 500L
    }
}
