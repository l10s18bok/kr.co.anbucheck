package kr.co.anbucheck.live

import android.app.Application

/**
 * 프로세스가 뜨는 **모든 경로**에서 heartbeat 알람을 재무장한다.
 *
 * ## 왜 Application인가
 *
 * 알람 무장 진입점은 원래 세 개뿐이었다 — 포그라운드(MethodChannel), `BOOT_COMPLETED`,
 * `MY_PACKAGE_REPLACED`. 이 셋에는 각각 구멍이 있다:
 *
 *  - **MethodChannel은 백그라운드에서 동작하지 않는다.** `anbucheck/heartbeat_alarm`은
 *    `MainActivity.configureFlutterEngine`에 등록돼 있어, WorkManager가 띄우는 백그라운드
 *    FlutterEngine에는 없다. 즉 워커가 `HeartbeatWorkerService.schedule()`을 불러도
 *    알람은 무장되지 않는다(`MissingPluginException`을 삼킨다).
 *  - **MIUI는 `MY_PACKAGE_REPLACED`를 차단한다**(`process is not permitted to auto start`,
 *    Redmi 1대 실측). Play 자동 업데이트 후 앱을 열지도 재부팅하지도 않으면 영영 무장되지 않는다.
 *
 * 그런데 이 앱의 주 대상은 **앱을 열지 않는 사용자**다. 그들에게 "업데이트 후 앱을 한 번
 * 열어 주세요"를 요구할 수 없다.
 *
 * `Application.onCreate`는 프로세스가 뜨는 이유를 가리지 않는다 — 포그라운드 실행,
 * WorkManager 워커, FCM 수신, 브로드캐스트 전부에서 실행된다. 그래서 위 구멍이 전부 메워진다:
 * MIUI에서도 WorkManager가 한 번 뛰면 그 순간 알람이 살아난다.
 *
 * ## 안전성
 *
 * `armNextDaily`는 **idempotent**하다 — 저장된 시각의 "다음 발생"을 계산해 같은
 * `PendingIntent`를 덮어쓰므로, 몇 번을 불러도 결과가 같다. 예약시각이 저장돼 있지 않은
 * 기기(순수 보호자 등)는 무장하지 않고 그냥 돌아온다.
 *
 * 비용은 SharedPreferences 1회 읽기 + `AlarmManager.setAndAllowWhileIdle` 1회다.
 * 콜드 스타트 경로에 있으므로 예외는 전부 삼킨다 — 알람 무장 실패가 앱 실행을 막으면 안 된다.
 */
class AnbuApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        try {
            HeartbeatAlarmReceiver.armNextDaily(this, reason = "app-process-start")
        } catch (t: Throwable) {
            // 무장 실패는 최악이라도 "알람 계층 없음" = 기존 1~3차 동작이다. 앱은 계속 뜬다.
        }
    }
}
