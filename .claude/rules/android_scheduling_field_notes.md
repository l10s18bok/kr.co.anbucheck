# Android 백그라운드 실행 실측 기록 (2026-08-16 ~ 08-18)

heartbeat worker가 "예약시각에 왜 안 뛰는가"를 추적하며 실기기에서 측정한 값과 관측 사례.
**추정이 아니라 전부 `dumpsys`/`logcat` 실측이다.** 같은 논의가 다시 나오면 여기부터 읽는다.

- 측정 기기: **삼성 SM-A325N (Galaxy A32)**, `minSdk 29 / targetSdk 36`, SIM 없음(WiFi 전용)
- 앱: `kr.co.anbucheck.live`, Play 스토어 설치본, uid `u0a1227`
- ⚠️ 기기 1대 표본이다. 값 자체는 다른 기기에서 다를 수 있으나 **메커니즘은 AOSP 공통**이다.

---

## 1. 발화를 막는 3개 층 (독립적으로 작동)

예약시각이 되어도 worker가 뛰지 않는 이유는 하나가 아니다. **아래 셋을 모두 통과해야** 실행된다.

| 층 | 무엇 | 이 기기 값 |
|---|---|---|
| ① Doze | 유지보수 창 밖에서는 job 자체가 실행 불가 | 딥 Doze 최소 보장 **30초**, 실측 창 **약 64초** |
| ② QuotaController | 버킷별 **세션 수** 상한 | RARE = **24시간에 3세션** |
| ③ JobScheduler 배칭 | 준비된 job을 묶어서 지연 실행 | **최대 31분** |

③은 Doze가 아니어도, 화면이 켜져 있어도 적용된다. **이 셋을 혼동하면 오진한다.**

### 전체 그림 — 가장 흔한 오해

⚠️ **31분은 Doze 창 간격이 아니다.** ①(Doze)과 ③(배칭)은 완전히 별개 층인데 자주 섞인다.

```
                 ┌─ Doze 창 밖  →  발화 불가 (절대)
기기 상태 ───────┤
                 ├─ Doze 창 안  →  거의 즉시 발화 ★
                 │                  창이 열리는 순간 온 기기의 job이 한꺼번에 ready가 되어
                 │                  min_ready_non_active_jobs_count(5)가 즉시 충족 → 배칭이 바로 풀림
                 │
                 └─ Doze 아님   →  제약은 다 풀렸는데도 배칭에 걸림
                    (화면 켬 등)     · 우리 job 혼자 ready  →  최대 31분 대기
                                     · 다른 앱이 job 생성   →  즉시 방출
```

**역설**: 딥 Doze 창은 드물게 열리지만 **열리면 빠르다**(모두가 동시에 ready라 배칭이 무의미해진다).
반대로 화면만 켠 상태는 제약이 전부 풀렸는데도 **혼자라서 최대 31분 기다린다.**
실측이 정확히 그랬다 — 15:05 화면 켬 → 15:07:52 발화(2분 50초), 15:13 준비 → 유튜브 실행 전까지 9분 대기.

### ① Doze (`dumpsys deviceidle`)

```
min_deep_maintenance_time         = +30s      # 딥 Doze 유지보수 최소 보장
min_light_maintenance_time        = +5s
light_idle_maintenance_min_budget = +1m
light_idle_maintenance_max_budget = +3m
light_idle_to = +5m,  light_idle_factor = 2.0,  light_max_idle_to = +20m
inactive_to   = +15m         # 화면 꺼짐 후 inactive 진입
idle_after_inactive_to = +20m # 딥 Doze 진입까지 추가 대기
idle_to = +1h, max_idle_to = +6h, idle_factor = 2.0
```

- **실측 유지보수 창: 2026-08-18 02:16:34 → 02:17:38, 약 64초.** 그 창에서 밀린 job 2개가 batch fire됐다.
- **창 사이 간격은 고정이 아니라 배증한다.**

  | 단계 | 창 사이 유휴 구간 |
  |---|---|
  | 라이트 Doze | 5분 → 10분 → 20분 → 이후 20분 고정 (`light_idle_to` × `light_idle_factor`, 상한 `light_max_idle_to`) |
  | **딥 Doze** | **1시간 → 2시간 → 4시간 → 이후 6시간 고정** (`idle_to` × `idle_factor`, 상한 `max_idle_to`) |

  딥 Doze 진입 자체가 `inactive_to(15분) + idle_after_inactive_to(20분) = 35분` 뒤다.
  실측 대조: 14:08 마지막 조작 → 약 14:43 딥 Doze 진입 → 15:05 시점 `mNextAlarmTime=+38m22s`(= **15:43**) = 진입 +1시간. 정확히 일치했다.
  그래서 **밤새 창은 몇 시간에 한 번**만 열린다 — 8/18 새벽 02:16 단 1회 발화, periodic 4시간 18분 초과 미발화가 전부 여기서 설명된다.
- 창 길이도 고정이 아니다: `idle_pending_to=5분`(→ 최대 10분)은 **상한**이고, 할 일이 끝나면 조기에 닫힌다. `min_deep_maintenance_time=30초`가 최소 보장이며 실측은 64초였다.
- 창이 닫히면 실행 중인 worker는 `onStopJob` → `stopEngine()`으로 **즉시 죽는다**. 그래서 전송보다 재무장·메모를 먼저 해야 한다.
- 판정: `dumpsys deviceidle | grep -E 'mState|mScreenOn|mCharging|mNextAlarmTime'`
  - `mState=IDLE` = 딥 Doze, `mNextAlarmTime` = 다음 창까지 남은 시간
- job 항목의 `readyNotDozing: false`가 같은 사실을 job 관점에서 보여준다.

### ② QuotaController (`dumpsys jobscheduler` 상단 상수)

```
qc_allowed_time_per_period_*_ms = 600000   # 전 버킷 공통 10분
qc_window_size_rare_ms      = 86400000 (24h)   qc_max_session_count_rare      = 3
qc_window_size_frequent_ms  = 28800000  (8h)   qc_max_session_count_frequent  = 8
qc_window_size_working_ms   =  7200000  (2h)   qc_max_session_count_working   = 10
qc_window_size_restricted_ms= 86400000 (24h)   qc_max_session_count_restricted= 1
qc_max_job_count_rare = 48 / working = 120 / frequent = 200 / restricted = 10
qc_timing_session_coalescing_duration_ms = 5000   # 5초 내 시작한 job은 1세션으로 합산
```

**병목은 실행시간(10분)이 아니라 세션 수다.** RARE 버킷이면 **하루 3번**만 깨어날 수 있다.
"periodic 15분 폴링 = 하루 96회"라는 설계 전제는 RARE에서 성립하지 않는다.

- 5초 이내 동시 시작한 one-off + periodic은 **1세션**으로 합쳐진다(실측: 02:16:38.446 / .854).

**2026-08-21 09:27 실측 — 세션 병목이 가설이 아니라 사실임이 확인됐다.**

```
Standby bucket = 40 (RARE)          # adb shell am get-standby-bucket <pkg>
RARE: sessionCountLimit=3           # 상한
      sessionCountInWindow=7        # 현재 — 2배 이상 초과
      executionTimeInWindow=17812   # 10분 예산 중 17.8초 (0.3%)
      inQuotaTime=11733369973       # 회복 시각(elapsed) → 이 시점 기준 +4h06m
→ "#u0a1227/184 from u0a1227: RARE, not within quota, 582188ms remaining in quota"
```

`remaining`이 582초나 남았는데도 `not within quota`다 — **실행시간은 남고 세션만 소진된 상태.**
"쿼터가 남았다"는 표현에 속지 말 것. 반드시 `sessionCountInWindow` vs `sessionCountLimit`을 볼 것.

⚠️ **상위 버킷에서 쓴 세션이 나중에 RARE 상한에 걸린다.** 창(24h)은 버킷과 무관하게 굴러가고
평가만 현재 버킷 기준으로 하므로, ACTIVE일 때(앱을 열어본 직후) 실행한 job이 몇 시간 뒤
RARE로 내려앉은 시점의 예산을 갉아먹는다. **"잠깐 앱만 열어 확인"과 진단 브로드캐스트는 공짜가 아니다.**

```bash
# 잔량 요약(부정확 — 실행시간만 보여줌)
adb shell dumpsys jobscheduler | grep -A1 "from u0a1227"

# ★ 정확한 세션 카운트 — 패키지별 ExecutionStats
adb shell dumpsys jobscheduler | grep -A8 "<0>kr.co.anbucheck.live" | grep "RARE:"
adb shell am get-standby-bucket kr.co.anbucheck.live    # 10 ACTIVE / 20 WORKING_SET
                                                        # 30 FREQUENT / 40 RARE / 45 RESTRICTED
```

### ③ JobScheduler 배칭 — 가장 놓치기 쉬움

```
min_ready_non_active_jobs_count   = 5
max_non_active_job_batch_delay_ms = 1860000  ( = 31분 )
```

- **AOSP 기본값과 정확히 일치**한다(`android14-release`의 `DEFAULT_MIN_READY_NON_ACTIVE_JOBS_COUNT = 5`,
  `DEFAULT_MAX_NON_ACTIVE_JOB_BATCH_DELAY_MS = 31 * MINUTE_IN_MILLIS`). 삼성 고유값이 아니다.
- `device_config list jobscheduler`가 **0개 키** → Google 원격 배포도 걸려 있지 않은 순수 빌드 기본값.
- 상수 이름이 **`non_active`** 다 → **ACTIVE/EXEMPTED 버킷이 아닌 앱**에만 적용된다.
- 증상: job이 `Ready: true`, `Unsatisfied constraints:` 비어 있고 `Run time earliest`가 음수(초과)인데도 실행되지 않는다.
  같은 항목에 `Time since first force batch attempt: -Nm` 이 함께 찍힌다.
- **해제 조건: 준비된 non-active job이 5개 모이거나 31분 경과.** 다른 앱을 실행하면 그쪽 job이 카운트를 채워 우리 job이 같이 방출된다(실측, §2 참조).

---

## 2. 관측된 발화 / 미발화 사례

| 일시 | 계기 | 결과 |
|---|---|---|
| 08-16 18:08:43 | 사용자가 **화면 켬** | 예약 18:00 → **8분 43초 지연** 후 발화, 전송 성공 |
| 08-17 종일 | 핫스팟 OFF | **0회 발화.** 망 제약(`NetworkType.connected`)으로 worker 시작조차 안 됨 |
| 08-17 20:13:30 | **FCM 푸시 도착** | `CONNECTIVITY`가 52초간 충족됐으나 `readyNotDozing=false` → **미발화** |
| 08-17 20:16:06 | **USB 케이블 연결**(adb) | 충전 시작 → Doze 해제 → 필수 제약 전부 충족 **26.5초**, 그래도 배칭으로 **미발화** |
| 08-18 02:16:34 | **Doze 유지보수 창**(약 64초) | one-off + periodic **동시 발화**(0.4초 차) |
| 08-18 02:31~06:49 | — | periodic이 **4시간 18분 초과**하도록 미발화 (딥 Doze) |
| 08-18 15:07:52 | 사용자가 **화면 켬**(15:05) | 2분 50초 뒤 발화 → **0.73초 만에 lmkd 킬** |
| 08-18 15:22:25 | 사용자가 **유튜브 실행** | 15:13 준비 → **9분 뒤** 배칭 방출로 발화, 전송 성공 |

**핵심 교훈**

- "폰 화면을 켜면 뜬다"는 **반만 맞다.** Doze는 풀리지만 배칭 지연이 그 뒤에 또 붙는다(실측 2.5분~8분).
- **다른 앱 실행이 오히려 효과적인 트리거**다. 그쪽 job이 `min_ready_non_active_jobs_count=5`를 채워 우리 job까지 방출시킨다.
- FCM 푸시 도착은 **망만 잠깐 열 뿐** Doze를 풀지 않는다 → job 발화 트리거가 되지 못한다.
- ⚠️ **Doze를 깨는 것은 adb가 아니라 USB 충전이다** (2026-08-21 정정). 이전 판에는 "adb 접속은 Doze를 깨운다"라고 적혀 있었으나 상관을 인과로 오해한 것이다. Doze 진입 조건은 **화면 꺼짐 + 비충전 + 정지**이고 adb 프로토콜은 어디에도 없다. 위 08-17 20:16 관측도 USB 케이블의 **충전** 때문이었다.
- **무선 adb는 Doze를 깨지 않는다 — 실측 확인.** 무선으로 붙은 채 `dumpsys`를 반복 호출하는 동안에도 `mState=IDLE`이 유지됐다(2026-08-21 09:27). 부분 wakelock도 Doze 진입을 막지 못한다(wakelock을 무시하는 것이 Doze의 본질). **관측은 §4의 무선 adb로 하면 대상을 바꾸지 않는다.**

---

## 3. lmkd(저메모리 킬러) — 창 만료와 같은 급의 실패 모드

```
08-18 15:07:53.213  I/lmkd: Reclaim 'kr.co.anbucheck.live' (20550), uid 11227,
                    oom_score_adj 905, state 19 to free 162172kB rss, 31032kB swap;
                    reason: low watermark is breached and swap is low
```

- worker가 시작 **0.73초** 만에 죽었다. 같은 날 포그라운드 앱도 14:34:31에 한 번 죽었다.
- Doze 창 만료와 결과가 같다 — **그 시점 이후의 Dart 코드가 통째로 실행되지 않는다.**
- 그래서 `heartbeatWorkerCallback`은 **네트워크보다 먼저 재무장**한다. 이 사건에서 재무장은 킬 **105ms 전**에 완료되어 살아남았다.
- 검색: `logcat | grep lmkd | grep <패키지명>`

---

## 4. 진단 도구 (릴리스 빌드에서도 동작)

릴리스는 `main()`과 worker 콜백에서 `debugPrint`를 무력화하므로 **Dart 로그는 안 나온다.** 대신 아래를 쓴다.

### 4.0 기기 접속 — **반드시 무선 adb로 한다**

⚠️ **USB 케이블로 붙으면 충전이 시작되어 Doze가 아예 진입하지 않는다.** 그 상태에서 찍은
`dumpsys`는 Doze 관측으로서 무효다. 무선 adb는 충전을 하지 않으므로 **Doze가 정상 진행되는
기기를 그대로 들여다볼 수 있다**(2026-08-21 실측: 무선으로 붙어 `dumpsys`를 반복 호출하는
동안 `mState=IDLE` 유지).

```bash
ADB=~/Library/Android/sdk/platform-tools/adb

# 1) 기기 찾기 — ★ IP를 외우지 말 것. DHCP/핫스팟 재접속으로 서브넷째로 바뀐다.
#    (2026-08-21: 저장돼 있던 10.160.142.227 → 실제 10.208.23.227)
$ADB mdns services
#   → adb-RF9T2020HHZ   _adb._tcp.   10.208.23.227:5555

# 2) 연결
$ADB connect 10.208.23.227:5555
$ADB devices -l          # "device"로 뜨면 성공 (model:SM_A325N)

# 3) 이후 모든 명령에 -s 로 지정
SER=10.208.23.227:5555
$ADB -s "$SER" shell dumpsys deviceidle | grep -E "mState=|mCharging=|mNextAlarmTime|mNextIdleDelay"
```

- **`-s` 인자는 반드시 따로 넘긴다.** `D="-s $SER"` 처럼 한 변수에 묶어 쓰면 zsh가 한 단어로
  전달해 `adb: -s requires an argument`로 죽는다.
- **`adb connect`는 죽은 IP를 향하면 오래 블로킹된다.** 스크립트에서는 `timeout 15`로 감쌀 것.
  IP 추측 대신 항상 `adb mdns services`로 먼저 찾는 편이 빠르다.
- 포트 스캔(`nc -z <subnet> 5555`)은 병렬로 254개를 띄우면 놓치는 경우가 있다. mdns가 정답이다.
- `adb devices`에 아무것도 없거나 mdns가 비어 있으면 **tcpip 모드가 풀린 것**이다(재부팅 시 해제).
  USB로 1회 연결해 `$ADB -s <serial> tcpip 5555` 후 케이블을 뽑고 다시 connect한다.
  이때 잠깐 붙은 USB가 Doze를 깨므로, **관측은 케이블을 뽑고 최소 35분**
  (`inactive_to 15분 + idle_after_inactive_to 20분`) 지난 뒤부터 유효하다.
- 무선 연결이 유휴 상태에서 끊기는 경우가 있다(Wi-Fi 절전). 끊기면 1)부터 다시 하면 되고,
  **재연결 자체는 Doze를 깨지 않는다.**
- 관측 목적이면 **`adb logcat`을 계속 물고 있지 말 것** — 필요할 때 `logcat -d`로 덤프만 뜬다.


```bash
# 0) 로그 버퍼 확대 — 이 기기 상한은 5MB(약 38시간 커버)
adb logcat -G 16M

# 1) worker가 실제로 실행됐는가  ★ 가장 먼저 볼 것
adb logcat -d -s WM-WorkerWrapper:V | grep "Starting work for dev.fluttercommunity"
adb logcat -d | grep "was cancelled"          # self-cancel 흔적

# 2) 등록 상태 — unique name까지 보인다
adb logcat -c
adb shell am broadcast -a "androidx.work.diagnostics.REQUEST_DIAGNOSTICS" -p <pkg> --user 0
sleep 7; adb logcat -d -s WM-DiagnosticsWrkr:V

# 3) 왜 안 뛰는가
adb shell dumpsys jobscheduler | grep -A32 "JOB #u0a1227"
#   Run time: earliest=-Nm   → 음수면 초과(뛰었어야 함)
#   Ready: true + Unsatisfied 비어 있음 + "force batch attempt" → ③ 배칭
#   readyNotDozing: false                                       → ① Doze
#   Unsatisfied: WITHIN_QUOTA                                   → ② 쿼터

# 4) Doze / 배칭 상수
adb shell dumpsys deviceidle | grep -E "mState|mScreenOn|mCharging|mNextAlarmTime"
adb shell dumpsys jobscheduler | grep -E "min_ready_non_active|max_non_active_job_batch|qc_max_session"
adb shell device_config list jobscheduler      # 비어 있으면 빌드 기본값

# 5) 배칭 우회 강제 실행 (테스트용)
adb shell cmd jobscheduler run -f <pkg> <jobId>

# 6) 걸음수 실측 — pedometer_2 네이티브 로그
adb logcat -d | grep "ContentValues" | grep -E "result:|readLocalSteps|buckets-Size"
```

- **걸음수 로그가 릴리스에서 보이는 이유**: `proguard-rules.pro`에 `-assumenosideeffects android.util.Log` 규칙이 없어 네이티브 `Log.d`가 스트립되지 않는다. 로그를 막고 싶어지면 이 진단 수단이 사라진다는 것을 감안할 것.
- 태그가 `ContentValues`인 것은 `pedometer_2`가 `import android.content.ContentValues.TAG`를 잘못 쓴 탓이다(플러그인 버그). 앱 PID로 걸러 읽는다.

### dated unique name의 부수 효과

one-off 이름이 `heartbeat_scheduled_<yyyy-MM-dd>`라, **이름만 보고 상태를 판정할 수 있다.**
- `..._2026-08-18` 이 enqueued → 오늘 슬롯 **미소비**
- `..._2026-08-19` 이 enqueued → 오늘 슬롯 **소비 완료**(성공 경로가 내일치를 등록했다는 뜻)

---

### periodic flex 실측 — `flexInterval` 누락의 서명 (2026-08-20)

`registerPeriodicTask`에 `flexInterval`을 넘기지 않으면 플러그인 기본값 5분
(`DEFAULT_FLEX_INTERVAL_SECONDS = MIN_PERIODIC_FLEX_MILLIS`)이 적용된다.
같은 기기에서 **앱 실행 1회를 사이에 두고** 찍은 before/after:

| | flex 미지정 (구버전) | `flexInterval: 15분` (수정 후) |
|---|---|---|
| one-off (`heartbeat_scheduled_<날짜>`) | 15:00:58 | 15:00:06 |
| periodic 첫 fire (`heartbeat_periodic`) | **15:13:58** | **15:03:06** |
| 코드상 오프셋(+3분) 대비 | **+10분 초과** | 일치 |

`13분 = 3분(코드 오프셋) + 10분(주기 15분 − flex 5분)`이 초 단위까지 맞는다.
WorkManager가 flex를 "첫 실행을 `interval − flex`만큼 더 미루는" 방식으로 흉내내기 때문이며,
`flex == interval`이면 이 보정이 사라진다. 실행 가능 구간도 주기의 **마지막 5분**에서
**주기 전체**로 넓어진다 — Doze 유지보수 창(하룻밤 1~5회, 약 64초)이 열렸을 때 job이
ready 상태일 확률이 곱으로 회복된다.

⚠️ **dumpsys에 `Period:`/`flex=` 줄은 나오지 않는다.** WorkManager가 flex를 JobScheduler에
넘기지 않고 자체 처리하므로 두 job 모두 `Minimum latency`로 잡힌다. 확인 지표는 문자열이
아니라 **one-off과 periodic의 간격(13분 → 3분)**이다.

```bash
# 두 job의 발화 예정 시각을 절대시각으로 환산
adb shell dumpsys jobscheduler | grep -A45 "JOB #u0a1227" | grep "Run time:"
```

### setAndAllowWhileIdle 실측 — 발화는 되고 **네트워크는 안 된다** (2026-08-21)

`kr.co.anbucheck.live` 자체 알람으로 측정. 19:05 예약 → **19:37:17 발화**(+32분,
문서상 "API 31+는 1시간 이내"와 일치). 이때 기기는 **딥 Doze(`idle=true`)**, 앱은
**RARE 버킷(40)**, 유지보수 창 밖(직전 창 없음, 다음 창 19:49).

| 관측 | 결과 |
|---|---|
| 딥 Doze + RARE에서 발화 | ✅ **된다** — JobScheduler로는 불가능한 시점에 떴다 |
| 재무장이 네트워크보다 먼저 | ✅ `ARMED(refire)` 로그가 `FIRED`보다 앞섬 |
| T+0s / T+9s / T+15s 네트워크 | ❌ **3회 모두 즉시 실패** (`UnknownHostException`, 6~11ms) |

**실패 원인은 Wi-Fi도 DNS 서버도 아니다.** 같은 시각 `wpa_supplicant Heartbeat`가
계속 찍혔고(연결 유지), 기기가 IDLE인 상태에서 **shell UID(2000)로는 같은 호스트가
정상 resolve + ping 응답**했다. 앱만 막힌 것이다:

```
dumpsys netpolicy:
  UID=11227 blocked_state={blocked=DOZE|APP_STANDBY, allowed=NONE, effective=DOZE|APP_STANDBY}
```

⚠️ **결정적 — 알람은 temp power-save allowlist를 받지 못한다.** 알람 등록 시
`dumpsys alarm`의 `idle-options`에 `temporaryAppAllowlistDuration=10000`이 분명히
붙어 있는데도, `dumpsys netpolicy`의 `temp-power-save whitelist for 11227` 이력에
**19:37 항목이 아예 없다.** 반면 같은 날 다른 두 경로는 실제로 부여받았다:

```
17:00:00.553 → true   reason=PUSH_MESSAGING <broadcast:u0a222:...RECEIVE, reason:high-prio FCM>
17:00:20.640 → false                                            (20초)
17:05:50.254 → true   reason=PACKAGE_REPLACED
17:06:10.269 → false
```

**즉 고우선순위 FCM은 20초짜리 네트워크 창을 실제로 열어주고, allow-while-idle
알람은 열어주지 않는다.** 이 대비가 설계의 분기점이다.

**따라서 "알람으로 heartbeat를 전송한다"는 설계는 이 기기에서 성립하지 않는다.**
알람이 할 수 있는 것은 **앱을 깨워 로컬 작업(걸음수 수집·보류 큐 저장)을 하는 것까지**다.
전송에는 (a) 유지보수 창 또는 (b) 고우선순위 FCM이 필요하다.

**미부여의 유력한 메커니즘 — 그리고 이게 삼성 문제가 아닌 이유**: 같은 알람 덤프에
`temporaryAppAllowlistReasonCode=-1`, `temporaryAppAllowlistReason=`(빈 문자열)이 함께
찍혀 있다. `-1`은 `REASON_UNKNOWN`이다. AOSP가 알 수 없는 reason code의
`setTemporaryAppAllowlist`를 거부한다면 이는 **플랫폼 공통 동작**이지 OEM 커스터마이징이
아니다. 대비되는 성공 사례가 이유를 명시하고 있다는 점이 방증이다 —
`reason=PUSH_MESSAGING <..., reason:high-prio FCM>`.

⚠️ 그러므로 **"픽셀이나 샤오미에서 다시 해보자"에 하루를 쓰지 말 것.** 표본은
SM-A325N 1대지만 원인이 reason code라면 기기를 바꿔도 결과가 같다. 설계는 최악을 가정한다.

**아직 검증 안 된 구조 경로 하나** — 알람이 앱을 깨운 뒤 **expedited WorkManager job**을
enqueue하면 망이 열릴 가능성이 있다. 같은 덤프의 uid `10222` 줄이
`blocked=DOZE, allowed=FOREGROUND|POWER_SAVE_ALLOWLIST|…, effective=NONE`인데,
expedited job이 앱을 foreground급 proc state로 올리면 `FOREGROUND` 허용이
`DOZE|APP_STANDBY`를 상쇄한다. **판별 질문: expedited job 실행 중 uid 11227의
`blocked_state`가 `effective=NONE`으로 바뀌는가.** RARE 버킷의 expedited 쿼터가
0에 가깝거나 `OutOfQuotaPolicy`로 일반 job으로 강등되면 실패한다.
비용은 리시버에 ~10줄이고 기존 Dart 경로를 통째로 재사용하므로,
FCM 전환(서버 스케줄러 변경 + 백그라운드 핸들러 + PRD §2.2 결정 번복)보다 **먼저** 시험한다.

⚠️ **관측 시 주의**: `am set-standby-bucket ... rare`를 실행하면 곧바로
`11227-standby-deny` + `App idle state: true`가 찍혀 APP_STANDBY 방화벽이 추가로
닫힌다. RARE 강제와 네트워크 차단은 함께 온다는 것을 감안해 해석할 것.

### expedited job은 딥 Doze의 **방화벽을 연다** (2026-08-22 07:07)

알람 발화와 동시에 `OneTimeWorkRequest.setExpedited(RUN_AS_NON_EXPEDITED_WORK_REQUEST)`를
enqueue한 실측. 기기는 **딥 Doze(`idle=true`), 앱은 RARE(40)** — 어제 종일 JobScheduler가
한 번도 못 뛴 바로 그 상태다.

```
07:07:18.771  FIRED (idle=true bucket=40)          ← 알람 재현 n=2, 예약 07:00 대비 +7분
07:07:18.784  EXPEDITED enqueued
07:07:18.885  ★ 11227-dozable-allow + 11227-standby-default   ← 방화벽 열림
07:07:19.385  DozeAlarmProbeWorker 시작            ← enqueue 후 622ms 만에 실행
07:07:19.948  ★ 11227-dozable-default + standby-deny          ← 닫힘 (약 1.06초)
07:07:25.098  BackgroundWorker(heartbeat) 종료     ← 창이 닫힌 뒤에도 5초 더 실행
```

| 관측 | 결과 |
|---|---|
| 딥 Doze + RARE에서 job 실행 | ✅ **된다** — enqueue 622ms 후. 일반 job은 이 상태에서 불가 |
| 네트워크 방화벽 | ✅ **열린다** — `dozable-allow` + `standby-default` |
| 알람 단독(2026-08-21 19:37) | ❌ 방화벽 변경 **전혀 없음** — 문을 연 것은 **expedited enqueue**다 |

⚠️ **창 길이는 expedited job의 수명과 같다.** 위 실측에서 프로브가 2ms 만에 끝나 창이
1.06초만 열렸고, **같은 순간 실행 중이던 `BackgroundWorker`(실제 heartbeat)는 창이 닫힌
뒤에도 5초를 더 돌았다.** 즉 **전송을 별도 worker에 맡기면 창이 먼저 닫힌다.**
→ **설계 제약: heartbeat 전송은 expedited job "안에서" 수행해야 한다.**

⚠️ **이날 네트워크 측정은 무효다** — 핫스팟이 거리로 이탈해 07:08:13에야 BSS를 재선택했다
(`wpa_supplicant: selected ... ssid=`). 프로브 실패는 Doze가 아니라 망 부재 탓이다.
**방화벽이 열렸다는 사실만 유효**하며, 데이터가 실제로 흐르는지는 재측정이 필요하다.

⚠️ **`wpa_supplicant: Heartbeat NNN`을 연결 지표로 쓰지 말 것.** 연결이 끊긴 상태에서도
계속 찍힌다(이 날 확인). association 판정은 `NetworkController.WifiSignalController`의
`connected=`, `WIFI_CONNECTIVITY_ACTION`, BSS 재선택 로그로 한다.

### 프로브가 자기 측정을 오염시킨 사례 — DNS 음성 캐시 (2026-08-22 09:37)

같은 발화에서 직접 프로브(T+0s)와 expedited 프로브를 함께 돌렸는데, **직접 프로브가
expedited 프로브를 망가뜨렸다.**

```
09:37:17.616  DNS Requested by 11227   ← T+0s. 이때 blocked=DOZE|APP_STANDBY
09:37:17.617  PROBE T+0s FAIL          ← 방화벽 닫힌 상태의 실패가 음성 캐시에 적재
09:37:17.678  ★ dozable-allow + standby-default        ← 방화벽 열림
09:37:17.717  EXPEDITED_WORKER started (lag 130ms)
09:37:17.720  EXPEDITED_PROBE FAIL 1ms  ← 열린 창 안인데 실패
09:37:18.054  ★ dozable-default + standby-deny         ← 닫힘 (376ms)
```

**증거**: netd의 DNS 요청 로그가 그 발화에서 **정확히 3건**(`17.616`/`26.597`/`32.598`)
= 직접 프로브 3회뿐이다. **expedited 프로브는 DNS를 조회조차 하지 않았다** — 100ms 전
실패가 음성 캐시에 남아 즉시 실패했다.

**교훈 — 다음 프로브 설계의 불변 규칙:**
1. **방화벽이 닫힌 구간에서 같은 호스트를 조회하지 말 것.** 그 실패가 캐시에 남아
   이후 열린 구간의 측정을 오염시킨다. 측정 대상보다 **먼저** 도는 프로브를 두지 않는다.
2. `java.security.Security.setProperty("networkaddress.cache.negative.ttl", "0")`으로
   음성 캐시를 끈다.
3. **DNS와 TCP를 분리해 측정한다** — 호스트명 조회와 IP 직결 연결을 각각 재면
   "DNS만 막힌 것"과 "통신 자체가 막힌 것"을 구분할 수 있다. 전자라면 IP를 미리
   캐시해 두는 우회로가 생긴다.

### 창 길이는 job 수명을 따라간다 (2026-08-22 확증)

| 발화 | worker 작업 시간 | 방화벽 열린 시간 |
|---|---|---|
| 08-22 07:07 | 프로브 2ms | **1.06초** |
| 08-22 09:37 | 프로브 1ms | **376ms** |

worker가 즉시 반환하면 proc state가 곧바로 떨어져 창이 닫힌다. **아직 모르는 것:
job을 오래 살려두면 창도 그만큼 열려 있는가, 아니면 상한이 있는가.**
heartbeat POST가 0.5~2초 걸리므로 이 상한이 설계를 좌우한다.

### 두 번 날린 교란 — 관측에 반드시 넣을 것

08-22 07:07 측정은 **핫스팟 이탈**로 무효였고, 그 사실을 사후에 logcat을 뒤져서야
알았다. 프로브가 **매 시도마다 Wi-Fi association 상태(supplicant state·RSSI)를 직접
로그로 남기면** 이 판정이 그 자리에서 끝난다. `WifiManager.getConnectionInfo()`는
앱의 네트워크 차단과 무관하게 시스템 서비스 조회라 Doze에서도 읽힌다.

### ★ 결론 — expedited job은 딥 Doze에서 **실제로 통신한다** (2026-08-22 11:04)

딥 Doze + RARE(40) 상태에서 allow-while-idle 알람이 발화하고, 그 알람이 enqueue한
expedited job 안에서 **41초 동안 8회 측정한 결과 전부 성공**했다.

```
11:04:13.924  FIRED  bucket=40
11:04:14.021  ★ 11227-dozable-allow + 11227-standby-default      ← 방화벽 열림(발화 +97ms)
11:04:14.062  EXP started lag=139ms
11:04:15  t+0s   tcp=OK(112ms)  https=422(1039ms)  idle=false imp=230 net=validated
11:04:29  t+15s  tcp=OK(202ms)  https=422(822ms)   idle=true  imp=230 net=validated
11:04:34  t+20s  tcp=OK(115ms)  ...                idle=true
11:04:44  t+30s  tcp=OK(154ms)  ...                idle=true
11:04:54  t+40s  tcp=OK(185ms)  ...                idle=true
11:04:54.938  EXP done total=41015ms      ← onStopped() 미발생
11:04:54.958  ★ 11227-dozable-default + standby-deny             ← 닫힘(worker 종료 +20ms)
```

`netpolicy`가 그 사이 모든 샘플에서 **`allowed=FOREGROUND, effective=NONE`** — 즉
`DOZE|APP_STANDBY`가 걸려 있는데도 **실효 차단이 없다.** proc importance는 230
(PERCEPTIBLE)으로 승격돼 있었다.

| 질문 | 답 |
|---|---|
| 열린 방화벽으로 데이터가 흐르는가 | ✅ **흐른다** — TCP 112~216ms, HTTPS 왕복 535~1148ms |
| 창이 몇 초까지 열리는가 | ✅ **job 수명과 동일** — 창 40.937초 vs worker 41.015초 |
| expedited 실행시간 상한 | ✅ 41초까지 `onStopped()` 없음 |
| DNS도 되는가 | ✅ 호스트명 HTTPS가 왕복 성공 |

⚠️ 로그의 `https=FileNotFoundException`은 **네트워크 실패가 아니다.** 이 엔드포인트가
`HTTP 422`를 반환해 `getInputStream()`이 던진 것이다(별도 curl로 422 확인). 4xx일 때
`errorStream`을 읽지 않은 프로브 쪽 처리 누락이며, **왕복이 성공했다는 사실이 요점**이다.

⚠️ `idle=false`가 t+10s까지 찍힌 구간이 있으나, **t+15s 이후 `idle=true`에서도 tcp가
전부 성공**했으므로 딥 Doze 판정에는 영향이 없다.

## 이로써 확정된 설계

```
allow-while-idle 알람   → 앱을 깨운다 (방화벽은 못 연다)
  └ expedited job enqueue → 방화벽을 연다 (allowed=FOREGROUND)
      └ 창 = job 수명   → **heartbeat 전송을 이 job 안에서 해야 한다**
```

⚠️ **전송을 별도 worker에 맡기면 안 된다.** 2026-08-22 07:07 실측에서 창이 376ms 만에
닫힌 뒤에도 `BackgroundWorker`(실제 heartbeat)가 5초를 더 돌았다 — 그 5초는 차단 상태였다.

## 5. 테스트 환경 주의사항 (실수로 날린 것들)

- **이 테스트폰은 Play 설치본**(`installer=com.android.vending`)이다. 로컬 서명 release APK를 사이드로드하면 서명 불일치로 실패하거나, 강제로 재설치할 경우 **SSAID가 바뀌어 서버 계정(G+S·구독·보호자 연결)이 고아가 된다.** 검증 빌드는 **Play 내부 테스트 트랙**으로 올린다. → [[project_ssaid_signing_scope]]
- **스와이프 킬은 job을 지우지 않는다**(실측 확인). 삼성에서도 프로세스 종료일 뿐이다. 반면 **설정 → 앱 → 강제 중지는 job을 전부 삭제**한다. 테스트 중 금지.
- **USB 충전 중에는 Doze에 진입하지 않는다.** 케이블을 꽂은 채로는 어떤 Doze 관측도 성립하지 않는다. → **관측은 §4의 무선 adb로 한다**(케이블 없이 붙으므로 Doze가 정상 진행된다). 부득이 USB를 써야 하면 `adb shell dumpsys battery unplug`로 프레임워크에 비충전 상태를 시뮬레이션하고, 끝나면 **반드시 `adb shell dumpsys battery reset`** (안 하면 재부팅 전까지 가짜 상태가 유지돼 다음 테스트가 오염된다).
- **앱을 열면 standby 버킷이 ACTIVE로 리셋**된다(배칭 비대상 + 세션 75). 수십 분 내 WORKING_SET으로 내려가고, 장기 미사용 시 RARE가 된다. 앱을 연 직후의 테스트는 **평상시보다 유리한 조건**이라는 것을 명시할 것.
- **앱 진입(`_syncScheduleFromServer`)만으로 `HeartbeatWorkerService.schedule()`이 포그라운드에서 실행**된다. 포그라운드에는 실행 중인 worker가 없어 self-cancel이 원리적으로 불가능하므로, unique name 마이그레이션 같은 위험한 정리는 이 경로가 가장 안전하다.

---

## 6. 이 기기에서 "정시 발화"는 성립하지 않는다

배터리 최적화 기본 설정(= EXEMPTED 버킷 아님) 상태에서는 **예약시각 + 수 분 ~ 31분**이 정상 동작이다.
앱 코드로 줄일 수 없다(③은 시스템 배칭이고 ①②는 OS 전력 관리다).

제품상 문제는 없다 — 서버 미수신 체크가 **예약시각 +2시간**이라 여유 안에 있다.
다만 "정시에 전송된다"는 서술은 사실과 다르므로 문서·문구에 쓰지 않는다.
