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

### ★ 세션 쿼터가 실제로 heartbeat job을 막았다 — 그리고 **알람은 세션을 안 썼다** (2026-08-26 07:23)

예약 07:00이 지났는데 job 두 개가 `Unsatisfied constraints: WITHIN_QUOTA`로 막혀 있었다.

```
RARE: sessionCountLimit=3, sessionCountInWindow=3     ← 상한 도달
      executionTimeInWindow=3667ms                     ← 10분 예산 중 3.7초(0.6%)만 사용
→ "RARE, not within quota, 581797ms remaining in quota"
```

`Timer<REG>` saved events를 벽시계로 환산한 결과(계산법은 아래):

| # | 시각 | 지속 | 정체 |
|---|---|---|---|
| ① | 08-25 09:00:00→09:00:02 | 1729ms | FCM이 깨운 회복 전송 |
| ② | 08-25 14:14:18→14:14:19 | 784ms | Doze 유지보수 창 |
| ③ | 08-25 20:15:44→20:15:45 | 1154ms | Doze 유지보수 창 |

`inQuotaTime` → 회복은 **08-26 09:00:02**(첫 세션 종료 +24h).

**★ 08-25 07:29 알람 발화로 워커 3~4개가 돌았는데 그 세션이 목록에 없다.** 즉 **알람 계층은
REG 세션을 소비하지 않았다.** `Timer<EJ>`(expedited 전용 쿼터)가 따로 존재하고, 알람이 깨운
워커는 승격된 proc state로 실행된다 — 둘 중 무엇이 이유인지는 **미확정**이지만 결과는 실측이다.
"알람이 쿼터를 태워 현상보다 나빠질 수 있다"던 우려는 이 관측으로 **반증됐다.**

#### ★★ 그리고 그날 아침, **알람이 쿼터를 우회해 전송했다** (2026-08-26 07:29)

위 차단 상태(세션 3/3) 그대로에서 알람이 발화해 **13초 만에 전송을 끝냈다.**

```
07:29:16.970  ARMED (app-process-start) for=08-27 07:00   ← 재무장이 먼저
07:29:16.976  ARMED (refire)
07:29:16.988  FIRED idle=true bucket=40                   ← 예약 07:00 대비 +29분 16초
07:29:17.421  HOLD started budget=90000ms
07:29:27.9    걸음수 조회 (Google Fit local recording)
07:29:30.469  HOLD ended held=13050ms reason=heartbeat-done   ← 조기 종료 = 전송 완료 감지
```

**우리 앱 RARE ExecutionStats가 발화 전후로 완전히 동일했다:**

| | 07:23 (발화 전) | 07:30 (발화 후) |
|---|---|---|
| `sessionCountInWindow` | 3 / 3 | **3 / 3** |
| `executionTimeInWindow` | 3667ms | **3667ms** |
| `bgJobCountInWindow` | 3 | **3** |

워커가 3개 떴는데 **RARE 쿼터에 한 건도 집계되지 않았다**(08-25에 이어 **n=2**).

**→ 알람 계층의 가치가 하나 늘었다. 정시성만이 아니라, JobScheduler 세션 쿼터가 소진된 날에
안부를 보낼 수 있는 유일한 경로다.** 이날이 정확히 그 상황이었고, 알람이 없었다면 09:00:02
쿼터 회복까지 기다렸다가 서버 미수신 체크(09:00)와 충돌해 거짓 경고가 나갔을 것이다.

⚠️ **정시성 재현**: 08-25 +29분 17초 / 08-26 +29분 16초. 둘 다 딥 Doze·RARE이고, 08-26의
다음 유지보수 창은 07:56이었다 — **창과 무관하게 알람이 스스로 발화**함이 재확인됐다.
두 날의 오프셋이 1초 차이인 이유는 미확인.

**쿼터를 태운 것은 어제 밤 통신 두절의 후폭풍이다.** 전송 실패로 periodic 폴링이 살아남았고
(Defect 1 수정의 의도된 동작) 그 폴링이 14:14·20:15에 세션을 썼다. 정상적인 날이면 전송 성공
시 `_onHeartbeatSent`가 periodic을 내일로 재워 이 세션들이 생기지 않는다. **즉 "실패한 날은
다음 날 쿼터가 빠듯해진다"**는 연쇄가 있다 — 설계상 수용 가능하나 알아둘 것.

```bash
# 세션 시각을 벽시계로 환산 (nowELAPSED과 date를 함께 읽어 오프셋 계산)
adb -s "$SER" shell "dumpsys alarm | grep -m1 -oE 'nowELAPSED=[0-9]+'"
adb -s "$SER" shell date +%s
adb -s "$SER" shell "dumpsys jobscheduler | grep -A10 '<0>kr.co.anbucheck.live'"   # Saved events
adb -s "$SER" shell "dumpsys jobscheduler | grep -A16 '<0>kr.co.anbucheck.live' | grep 'RARE:'"
```

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
### ⚠️ 2c 종단 실패 — 창은 열렸는데 전송이 창 밖으로 밀렸다 (2026-08-23 06:07)

**조건은 완벽했다.** 마지막 움직임 00:04, 직전 유지보수 창 03:48, 다음 창 07:48 →
06:07은 딥 Doze 한복판. 알람도 `idle=true bucket=40`으로 정확히 그 상태에서 발화했다.

```
06:07:18.856  ★ 방화벽 열림 (dozable-allow + standby-default)
06:07:18.87   BackgroundWorker #1 시작
06:07:19.10   BackgroundWorker #2 시작
06:07:19.13   BackgroundWorker #3 시작      ← 엔진 3개가 동시에 부팅
06:07:29.88   Worker SUCCESS
06:07:29.90   Worker SUCCESS
06:07:29.92   getStepCount 호출            ← Dart가 이제야 heartbeat 로직 진입(엔진 부팅 11초)
06:07:29.97   ★ 방화벽 닫힘 — 열린 시간 11.1초
06:08:03.08   걸음수 결과 도착             ← ★ 조회에만 33.1초
              → 이후 POST는 차단 상태에서 나감 → 3회 실패 → send_failed 알림
```

### ⚠️ 두 번 정정한다 — `.timeout(3초)`은 **발화하지 않았다**

이 절은 두 번 틀렸다. 처음엔 "33초 걸음수 조회 때문"이라 했다가, 다음엔 "Dart에 3초
타임아웃이 있으니 33초를 안 기다렸다"고 했다. **둘 다 틀렸다.** 로그가 답이다:

```
06:08:03.128  ContentValues: result: 127        ← 걸음수가 33초 만에 도착
06:08:03.166  DNS Requested by 11227            ← 38ms 뒤 POST 시작
```

**전송이 걸음수 도착 직후에 시작됐다** — 즉 Dart는 3초에 포기하지 않고 **33초를 그대로
기다렸다.** `_getStepsDelta`의 `.timeout(const Duration(seconds: 3))`이 발화하지 않은 것이다.
(`pedometer_2.getStepCount`은 평범한 MethodChannel `Future`라 정상이면 발화해야 한다.)

⚠️ **딥 Doze에서 Dart 타이머(`Future.timeout`·`Future.delayed`)를 신뢰하지 말 것.**
33초 벽시계가 흐르는 동안 3초 타이머가 안 뛰었다. 원인은 미확정이나(기기 suspend 중
`CLOCK_MONOTONIC` 정지가 유력) **결과는 재현된 실측**이다.
→ 다행히 `_sendDeadline`은 `DateTime.now()` 벽시계 비교라 이 영향을 받지 않는다.
   타이머 기반 예산을 새로 도입할 때는 이 사실을 전제로 할 것.

**따라서 실패의 직접 원인은 하나다 — 창(11.1초)보다 작업(45초)이 길었다.**
엔진 부팅 11초 + 걸음수 33초 + 전송이 순서대로 걸렸고, 창은 그 11초 지점에서 닫혔다.

**창이 11.1초에 닫혔고 그 시점에 Dart는 막 시작한 참이었다** — 이게 실패의 직접 원인이다.

| 구간 | 소요 |
|---|---|
| 알람 → Dart가 `getStepCount` 호출 | **11.07초** (워커 3개가 각자 FlutterEngine 부팅) |
| 방화벽이 열려 있던 시간 | **11.1초** |
| Dart 걸음수 타임아웃 → POST 시도 | 창이 닫힌 뒤 |

### 그래도 33초는 별개의 심각한 문제다

같은 로그 버퍼에서 잰 대비:

```
08-22 16:11  포그라운드   getStepCount →  0.17초
08-23 06:07  딥 Doze      getStepCount → 33.14초   (195배)
```

⚠️ **원인은 미확정이다.** Doze인지, GMS 콜드 스타트인지, 엔진 3개가 CPU를 물어서인지
n=1로는 구분되지 않는다.

**다만 걸음수가 유실되지는 않는다** — 타임아웃이 발화하지 않아 Dart가 끝까지 기다렸고
`steps_delta=127`, `suspicious=false`가 정상적으로 실렸다. 그날 08:00에 유지보수 창이
열리며 보류 메모가 그대로 나가 보호자는 **"정상" + 걸음수**를 받았다. 한때 "매일 거짓
주의 알림이 나갈 것"이라 우려했으나 **그 일은 일어나지 않는다.**

대신 이 33초는 **창 예산 산정의 입력값**이다: 엔진 11초 + 걸음수 33초 + 전송 →
창은 최소 45초, 여유를 봐서 90초가 필요하다.

### 핵심 결함 — 창을 여는 주체와 전송하는 주체가 다르다

창은 **expedited job의 수명**을 따라간다. 그런데 알람이 깨운 프로세스에서
WorkManager의 `ForceStopRunnable`이 밀려 있던 one-off·periodic까지 함께 방출해
**워커가 3개** 뜨고, 그중 SQLite 락을 잡아 실제로 전송하는 워커가 **expedited가 아닐 수
있다.** 이번이 정확히 그 경우다 — expedited job은 락 경쟁에서 져 11초 만에 스킵으로
끝났고, 창은 그때 닫혔으며, 전송은 창 밖에서 이뤄졌다.

### 수정 방향 — expedited job을 "창 유지자"로 분리

전송을 expedited job **안에서** 하려는 시도(2c)는 락 경쟁 때문에 보장되지 않는다.
대신 expedited job의 역할을 **방화벽을 열어둔 채 기다리는 것**으로 한정한다:

```
알람 → expedited "창 유지자" worker (Kotlin)
        · flutter.last_heartbeat_date 를 폴링하며 오늘이 될 때까지 대기
        · 최대 ~90초 (엔진 11초 + 걸음수 33초 + 전송 여유를 덮는 값)
        · 그 사이 방화벽이 계속 열려 있으므로 **어느 워커가 전송하든 창 안**
     → 별도로 기존 heartbeat 경로가 평소대로 전송
```

이미 확인된 사실 두 개가 이 설계를 뒷받침한다 — **창 길이 = job 수명**(08-22 11:04),
**41초까지 `onStopped()` 없음**(같은 날). 90초가 가능한지는 재측정이 필요하다.

### ★ 종단 성공 — 딥 Doze + RARE에서 heartbeat가 전송됐다 (2026-08-24 07:07, SM-A325N)

창 유지자(`DozeWindowHolderWorker`)를 도입한 뒤 첫 시도에서 성공했다.

```
07:07:17.752  FIRED  idle=true bucket=40(RARE)      ← 예약 07:00 대비 +7분 17초
07:07:17.773  HOLD enqueued
07:07:43.420  ★ 방화벽 열림
07:07:43.50~74  워커 4개 시작 (BackgroundWorker ×3 + 창 유지자)
07:07:54.662  걸음수 result: 61  (조회 0.17초)
07:07:55.210  DNS 요청 = POST 시작                  ← ★ 창 안에서
07:07:56.312  HOLD ended held=12572ms reason=heartbeat-done
07:07:56.347  방화벽 닫힘 — 열린 시간 12.9초
```

**전날 실패와의 유일한 차이가 창 길이다.**

| | 08-23 (실패) | 08-24 (성공) |
|---|---|---|
| 방화벽 열린 시간 | 11.1초 (expedited job이 먼저 끝남) | **12.9초** (유지자가 붙잡음) |
| POST 시점 | 창이 닫힌 뒤 33초 | **창 안** |
| 결과 | `send_failed` | **전송 성공** |

**성능**: 예약 07:00 → 전송 완료 07:07:56 = **+7분 56초**.
WorkManager 단독 실측(+1h27m ~ +2h52m, 상한 없음) 대비 **10~20배 개선**이며 상한 60분이 보장된다.

부수 확인:
- **중복 전송 없음** — `BackgroundWorker` 3개가 동시 실행됐는데도 `lastScheduledKey` + SQLite 락이 정상 차단
- `reason=heartbeat-done`이 나왔다 = **Kotlin이 `flutter.last_heartbeat_date`를 읽을 수 있다**(전날 08-23 10:07에 5ms 조기 종료로 먼저 검증)
- 걸음수 조회가 **0.17초** — 08-23의 33초는 재현되지 않았다. Doze 고유 특성이 아니라 그때의 GMS 콜드 스타트/경합이었을 가능성이 크다(n=2로 갈렸으므로 원인 미확정)

### ⚠️ 샤오미(MIUI)에서만 관측된 것 — **표본 1대, 일반화 금지**

아래는 **Redmi 23021RAA2Y / Android 15 / MIUI 1대에서만** 본 현상이다. 다른 제조사·기기에서
같은 일이 일어난다는 근거는 없다. 삼성(SM-A325N)에서는 관측되지 않았다.

같은 빌드로 같은 날 06:30 예약, **딥 Doze가 아닌 상태**(`idle=false`, 충전·핫스팟 소스):

```
06:32:00.233  FIRED  idle=false bucket=10           ← 알람은 오히려 더 정확(+2분)
06:32:06      걸음수 result: 9 (0.2초)
06:32:59      ★ send_failed 알림 게시 — 첫 전송 시도 실패
06:35:08.375  HOLD ended held=187763ms reason=timeout   ← 예산 90초인데 187초
06:35:08.382  HOLD onStopped                            ← 시스템이 job 중단
06:41:26.086  HOLD ended held=377622ms reason=timeout   ← 재시도, 377초
06:41:26      SmartPower: kr.co.anbucheck.live idle->background(374713ms)
06:46:38      ActivityManager: Killing 15140:kr.co.anbucheck.live (adj 965): empty
06:49         전송 성공 (이후 워커가 수행) — 예약 대비 **+19분**
```

**이 기기에서 관측된 것 세 가지:**

1. **프로세스 동결.** `held`가 예산의 2~4배로 늘었다. `Thread.sleep(500)` 루프가 정상이면
   90초에 끝나야 한다. MIUI `SmartPower`가 같은 시각 `idle->background(374713ms)`,
   즉 **374초 동안 idle 상태**였다고 찍었다. 창 유지자는 딥 Doze의 방화벽을 여는 장치이지
   이런 동결을 막지는 못한다.
2. **프로세스 강제 종료.** `Killing ... (adj 965): empty` — 워커가 끝난 뒤 곧바로 죽였다.
3. **`onStopped()` 첫 관측.** 약 188초 만에 시스템이 expedited job을 중단시켰다. 지금까지
   삼성에서는 41초까지 중단이 없었다. **expedited 실행시간 상한이 존재한다는 첫 증거지만,
   그 값이 AOSP 공통인지 MIUI 고유인지는 이 표본으로 알 수 없다.**

⚠️ **이 관측을 "안드로이드는 이렇다"로 확장하지 말 것.** 딥 Doze 상태도 아니었으므로
방화벽·창과는 다른 현상이다. 삼성 결과(위 절)와 뒤섞어 해석하면 둘 다 틀리게 된다.
MIUI 대응이 필요한지는 **딥 Doze 상태의 샤오미**에서 다시 재본 뒤에 판단한다.

### 알람 계층의 **미검증 구멍** (2026-08-24 기준)

코드는 있으나 실기기에서 한 번도 확인하지 않은 경로다. **클래스명 변경 같은 위험한 정리는
아래가 검증된 뒤에 한다** — 컴포넌트명이 바뀌면 기존 알람 `PendingIntent`가 무효화되므로,
재무장 경로가 실제로 도는지 먼저 알아야 한다.

| 경로 | SM-A325N | Redmi(MIUI) | 확인 방법 |
|---|---|---|---|
| **앱 업데이트 후 재무장**(`MY_PACKAGE_REPLACED`) | ⚠️ 브로드캐스트 도달 ✅ / **무장은 실패**(아래 참조) | ❌ **차단** | 설치 후 **앱을 열지 말고** `ARMED (system:...) for=`에 **실제 시각**이 찍히는지 확인. `ARM skipped`면 실패 |
| **재부팅 후 재무장**(`BOOT_COMPLETED`) | ✅ 08-24 09:07 | ✅ 09:03 | 재부팅 후 **5분 이상** 기다린 뒤 같은 확인 |
| WorkManager 복원 | ✅ | ✅ | `WM-RescheduleReceiver: Received intent ... BOOT_COMPLETED` |
| 딥 Doze 상태의 샤오미 | — | ❌ 미검증 | 샤오미는 충전·핫스팟 소스라 Doze에 안 들어갔다 |
| 알람 종단 성공 재현 | ⚠️ **n=1** (08-24) | — | 같은 빌드로 며칠 반복 |

**⚠️ MIUI는 브로드캐스트별로 자동 시작 제한을 다르게 적용한다** (Redmi 23021RAA2Y /
Android 15, **표본 1대**). 앱 업데이트는 막고 재부팅은 통과시킨다:

```
08-24 09:03:51  D/DozeAlarmProbe: ARMED (system:BOOT_COMPLETED)   ← 통과
08-24 09:03:51  D/WM-RescheduleReceiver: Received intent ... BOOT_COMPLETED  ← 통과
08-24 09:56:33  W/BroadcastQueueInjector: Unable to launch app kr.co.anbucheck.live/10521
                for broadcast { act=android.intent.action.MY_PACKAGE_REPLACED }:
                ★ process is not permitted to auto start         ← 차단 (08-22에도 동일)
```

**같은 기기·같은 날·53분 간격의 통제 대조다.** 자동시작 설정이 그 사이에 바뀌지 않았으므로
"자동시작이 꺼져 있어 모든 브로드캐스트가 막힌다"로는 설명되지 않는다 — **브로드캐스트별
차이**다. (인터넷 검색으로는 확증을 못 찾았다. 블로그·포럼은 "OEM이 BOOT_COMPLETED를 막는다"
수준의 일반론뿐이고 이 조합을 다룬 1차 자료가 없다. **근거는 위 실측 하나이며 표본 1대다.**)

⚠️ **차단되는 것은 "브로드캐스트 수신"이 아니라 "그 브로드캐스트를 위한 프로세스 콜드
스타트"다**(`Unable to launch app`). 알람 발화와 JobScheduler job은 같은 기기에서 정상적으로
프로세스를 띄운다(08-24 06:32 샤오미 알람 발화 + 워커 실행). 그래서 **`Application.onCreate`
재무장이 MIUI에서도 동작한다** — WorkManager가 한 번 뛰면 그때 프로세스가 뜨고 알람이 살아난다.

이 기기에서 업데이트 후 알람이 살아남은 것은 **우리 재무장 코드가 돈 결과가 아니라
MIUI가 알람을 지우지 않은 덕**이다(삼성은 지운다). 우연에 기대는 상태이므로,
MIUI 대응이 필요하면 이 구분을 근거로 삼는다. 다른 OEM에 일반화하지 말 것.

⚠️ **`BOOT_COMPLETED`는 부팅 직후가 아니라 2~4분 뒤에 온다**(삼성 +2m19s, 샤오미 +3m22s).
부팅 1~2분 시점에 "재무장 안 됐다"고 판정하면 오진이다.

⚠️ **재부팅은 무선 adb(`adb tcpip 5555`)와 `logcat -G` 설정을 모두 날린다.**
순서: 재부팅 → USB 연결 → `tcpip 5555` + `logcat -G` → **5분 대기 후 확인** → 케이블 제거.

업데이트가 알람을 지운다는 것 자체는 실측됐다 — 2026-08-22 16:11 로그에
`Force stopping kr.co.anbucheck.live: installPackageLI` / `pkg removed`가 찍혔다.
지금까지 테스트에서 드러나지 않은 이유는 **설치할 때마다 앱을 열어 재무장했기 때문**이다.
실사용자는 Play 자동 업데이트 뒤에 앱을 열지 않는다.

### ⚠️ 예약시각은 **Dart의 prefs를 직접 읽는다** — 복사본을 두면 조용히 죽는다 (2026-08-24)

알람은 한때 자체 prefs(`heartbeat_alarm`)에 예약시각 복사본을 두었다. 그 복사본은
**포그라운드에서만** 채워진다(`HeartbeatWorkerService.schedule` → `HeartbeatAlarm.arm`).
그래서 업데이트·재부팅으로 재무장 브로드캐스트가 와도 값이 비어 있으면 무장을 건너뛴다:

```
08-24 09:56:37  D/HeartbeatAlarm: ARM skipped (system:...MY_PACKAGE_REPLACED) — 저장된 시각 없음
                ← 1.2.7+49 설치 후 앱을 열지 않은 삼성. 재무장 코드는 돌았으나 값이 없어 무의미
```

**이 앱의 주 대상은 앱을 열지 않는 사용자다.** "업데이트 후 앱을 한 번 열어 주세요"는
요구할 수 없으므로, 알람은 복사본을 갖지 않고 `FlutterSharedPreferences`의
`flutter.heartbeat_hour` / `flutter.heartbeat_minute`를 직접 읽는다. 단일 출처가 되어
Dart 예약시각과 알람이 어긋날 여지도 사라진다. **복사본 방식으로 되돌리지 말 것.**

⚠️ **`shared_preferences`는 Dart `int`를 `putLong`으로 저장한다**
(`shared_preferences_android`의 `MethodCallHandlerImpl`: `putLong(key, number.longValue())`).
Kotlin에서 `getInt`로 읽으면 `ClassCastException`이 나고, catch가 없으면 리시버가 통째로
죽는다. `getLong` + `getInt` 폴백으로 읽는다.

⚠️ 이 경로는 **앱을 열지 않은 채로** 검증해야 한다. 설치 후 앱을 한 번이라도 열면
포그라운드 무장이 덮어써서 무엇이 통과했는지 알 수 없게 된다.

### 알람 무장 진입점 — **`Application.onCreate`가 본진**이다 (2026-08-24)

무장 경로가 원래 셋뿐이었고 셋 다 구멍이 있었다:

| 경로 | 구멍 |
|---|---|
| MethodChannel `anbucheck/heartbeat_alarm` | **`MainActivity.configureFlutterEngine`에만 등록**돼 있다 → WorkManager가 띄우는 백그라운드 FlutterEngine에는 없다. 워커의 `_onHeartbeatSent → schedule()`은 `MissingPluginException`을 삼키고 지나간다. **즉 포그라운드에서만 무장된다** |
| `MY_PACKAGE_REPLACED` | MIUI 차단(위 절) |
| `BOOT_COMPLETED` | 재부팅 전까지 무장 안 됨 |

그래서 `AnbuApplication.onCreate`에서 `armNextDaily`를 부른다. **프로세스가 뜨는 이유를
가리지 않는다** — 포그라운드 실행·WorkManager 워커·FCM 수신·알람 브로드캐스트 전부.

- `armNextDaily`는 저장 시각의 "다음 발생"으로 **같은 PendingIntent를 덮어쓰므로 idempotent**다.
- 예약시각 키가 없는 기기(순수 보호자)는 무장하지 않고 돌아온다.
- 비용은 prefs 1회 읽기 + `setAndAllowWhileIdle` 1회. 콜드 스타트 경로라 예외는 전부 삼킨다.
- `android:name`이 Flutter 기본값 `${applicationName}`에서 `.AnbuApplication`으로 바뀌었다.
  `-Pbase-application-name` 오버라이드는 minSdk 29(네이티브 multidex)라 쓰이지 않는다.
  ⚠️ **XML 주석을 `<application>` 시작 태그 *안*에 넣지 말 것** — 속성 목록 사이의 주석은
  파싱 에러다. 검증은 `python3 -c "import xml.dom.minidom; xml.dom.minidom.parse(...)"` +
  병합 매니페스트(`build/app/intermediates/merged_manifests/release/.../AndroidManifest.xml`)에서
  `android:name="kr.co.anbucheck.live.AnbuApplication"` 확인.
- ⚠️ Gradle은 **Java 17+**가 필요하다. Android Studio 번들 JDK가 11로 잡히면
  `export JAVA_HOME=/Users/macmini/Library/Java/JavaVirtualMachines/openjdk-19.0.2/Contents/Home`.

#### 실측 — 1.2.7+50 설치 직후, **앱을 열지 않은 상태** (2026-08-24 11:32)

| | SM-A325N (삼성) | 23021RAA2Y (MIUI) |
|---|---|---|
| `MY_PACKAGE_REPLACED` | 통과 | ❌ 차단 (**n=3**: 08-22, 09:56, 11:32) |
| 프로세스 시작 | ✅ | ❌ 시작 안 됨 |
| `ARMED (app-process-start)` | ✅ 11:32:22.459 → 08-25 07:00 | ❌ 로그 없음 |
| `ARMED (system:MY_PACKAGE_REPLACED)` | ✅ 11:32:22.544 (85ms 뒤 같은 값) | ❌ |
| 새 알람 `HEARTBEAT_ALARM` | ✅ 무장됨 | ❌ 없음 |
| WorkManager job | ✅ 2건 복원 | ❌ **0건** |

**삼성은 두 경로가 모두 통했고, 85ms 간격으로 같은 값을 덮어써 idempotent임이 확인됐다.**

⚠️ **MIUI는 업데이트 직후 앱이 통째로 잠든다 — 알람도 job도 0이다.**
```
11:32:37.068  Force stopping kr.co.anbucheck.live ... installPackageLI   ← job·알람 전부 취소
11:32:38.237  Unable to launch app ... MY_PACKAGE_REPLACED:
              process is not permitted to auto start                    ← 복구 브로드캐스트 차단
              (프로세스가 안 뜨므로 Application.onCreate도 실행되지 않는다)
```
**이건 알람 계층 때문에 생긴 회귀가 아니다** — 같은 업데이트가 예전에도 WorkManager job을
똑같이 지웠고, 앱을 열기 전까지 복구되지 않았다. 이번에 계측이 붙어 **보이게 됐을 뿐**이다.

MIUI에서 남은 복구 경로는 셋뿐이다: **FCM 푸시**(서버 미수신 체크 = 예약시각 +2h),
**재부팅**, **사용자가 앱 열기**. 첫 번째가 실제로 프로세스를 깨우는지는 **미검증**이며,
확인 방법은 공짜다 — 업데이트 다음 날 서버 안전망 푸시가 나간 뒤 기기가 살아나는지 본다.
(비용: 그날 하루 미전송 + 보호자에게 거짓 미수신 경고 1건.)

⚠️ MIUI 자동시작 설정은 **adb로 못 읽는다.** `cmd appops`에도 `dumpsys`에도 노출되지 않고
(`RUN_ANY_IN_BACKGROUND: allow`는 별개 항목이다) MIUI 전용 서비스에만 있다. 설정 상태를
알려면 기기에서 직접 봐야 한다.

#### ★ 자동시작 설정을 확인했다 — **OFF인데도 `BOOT_COMPLETED`는 통과한다** (2026-08-24)

HyperOS 2.0 / V816 / Android 15. 설정 위치는 앱 상세가 아니라 **보안 앱 → 권한 →
백그라운드 자동시작**이다(구버전 MIUI의 "앱 관리 → 자동 시작"이 아니다).
adb로 바로 열 수 있다:

```bash
adb -s "$SER" shell am start -n \
  com.miui.securitycenter/com.miui.permcenter.autostart.AutoStartManagementActivity
```

**이 기기의 `kr.co.anbucheck.live`는 OFF**(기본값 = 실사용자 조건)였다. 그 상태에서:

```
09:03:51.558  D/DozeAlarmProbe: ARMED (system:BOOT_COMPLETED)                     ← 통과
09:03:51.568  D/WM-RescheduleReceiver: Received ... cmp=kr.co.anbucheck.live/...  ← 프로세스 시작
09:56:33 / 11:32:38  Unable to launch app kr.co.anbucheck ... MY_PACKAGE_REPLACED  ← 차단 (4건)
```

같은 로그 버퍼에서 `Unable to launch app`은 **오직 `MY_PACKAGE_REPLACED`에만** 찍힌다.
즉 **자동시작 OFF는 부팅 복구를 막지 않는다** — 브로드캐스트별로 정책이 다르다.

⚠️ **dontkillmyapp.com 등은 "샤오미가 `BOOT_COMPLETED`를 막는다"고 적고 있으나 이 기기에서는
사실이 아니다.** 일반론을 그대로 옮기지 말 것.

**따라서 MIUI에서 실제 구멍은 하나뿐이다 — Play 자동 업데이트.**

| 경로 | 자동시작 OFF 기본 상태 |
|---|---|
| 재부팅 | ✅ 복구 (실측) |
| **Play 자동 업데이트** | ❌ 앱이 잠든다 — 단, 아래 FCM이 되살린다 |
| **FCM 푸시 도착** | ✅ **복구 (실측, 아래)** |
| 사용자가 앱 열기 | ✅ |

#### ★ FCM 푸시가 잠든 MIUI 앱을 되살린다 — 종단 확인 (2026-08-24 12:06)

업데이트로 job 0건·알람 0건이 된 샤오미에, 다른 기기(삼성)의 **수동 안부 보고**로
`manual_report` 푸시를 보냈다. 탭하지 않았다 — **도착만으로** 복구됐다.

```
12:06:00.389  ActivityManager: Start proc 10045:kr.co.anbucheck.live for broadcast
              {.../FlutterFirebaseMessagingReceiver} caller=com.google.android.gms
                                                    ← 자동시작 차단 로그 없음
12:06:00.566  WM-WrkMgrInitializer: Initializing WorkManager
12:06:00.587  WM-ForceStopRunnable: Performing cleanup operations      ← job 재등록
12:06:00.617  ★ HeartbeatAlarm: ARMED (app-process-start) for=08-25 06:30:00
```

| | 푸시 전 | 푸시 후 |
|---|---|---|
| `HEARTBEAT_ALARM` | 없음 | 08-25 06:30 무장 |
| WorkManager job | 0건 | **2건** (`TIME=+18h22m` / `+18h25m`) |

**두 가지가 동시에 확인됐다.**

1. **GMS는 MIUI 자동시작 제한을 받지 않는다.** 브로드캐스트 큐가 아니라 GMS가 직접
   프로세스를 띄우므로(`caller=com.google.android.gms`) `BroadcastQueueInjector`의
   차단 경로를 타지 않는다.
2. **알람을 살린 것은 `Application.onCreate`다** — `reason=app-process-start`이고
   우리 리시버에는 아무 브로드캐스트도 오지 않았다. 이 경로가 없었다면 FCM이
   WorkManager는 복원해도 **알람은 못 살렸다**(MethodChannel은 `MainActivity` 전용이라
   백그라운드 엔진에 없다). 설계 의도가 정확히 그 시나리오에서 실증됐다.

⚠️ **MIUI에서 job/알람을 셀 때 `JOB #u0aNNN`으로 grep하면 0으로 나온다.** HyperOS는
`JOB androidx.work.systemjobscheduler:u0a521/300` 형식을 쓴다. 패키지 경로로 세라:
```bash
adb -s "$SER" shell "dumpsys jobscheduler | grep -c 'kr.co.anbucheck.live/androidx.work.impl.background.systemjob'"
adb -s "$SER" shell "dumpsys alarm | grep -o 'anbucheck.live[^ ]*' | sort -u"
```

### ★★ MIUI `power_pending` — allow-while-idle 알람을 **정확히 +3일** 미룬다 (2026-08-25)

**0차 알람 계층이 이 MIUI 기기에서는 사실상 동작하지 않는다.** 배터리 설정은 **기본(최적화)**
상태였다 — 사용자가 무엇을 잘못 만진 결과가 아니다.

```
tag=*walarm*:kr.co.anbucheck.live.HEARTBEAT_ALARM
origWhen=2026-08-26 06:30:00.000
policyWhenElapsed: requester=+21h42m6s698ms ... power_pending=+3d21h42m6s698ms
whenElapsed=+3d21h42m6s698ms        ← ★ 실제 배달 예정
```

`whenElapsed`(실제 배달 시각)는 정책들의 **최댓값**이다. `power_pending`이 요청 시각에
**정확히 72시간**을 더하고 그게 최댓값이 되어, 알람이 예약일이 아니라 **3일 뒤**에 배달된다.
전날 덤프에서도 동일했다(`requester=+18h47m33s139ms` → `power_pending=+3d18h47m33s139ms`).

**경험적 확증**: 08-24 12:06에 08-25 06:30으로 무장 → **06:30에 발화하지 않았다.**
그날 06:34에 뛴 것은 WorkManager 단독이었고(`Start proc ... for service {SystemJobService}
caller=android` — 알람 브로드캐스트가 아님), 창 유지자가 없어 방화벽이 닫힌 채 전송을 시도해
프로세스 시작 **6.6초** 만에 `send_failed`가 게시됐다(즉시 unreachable → 백오프 생략 경로).

**삼성과의 정책 대비 — `power_pending`/`ssru`는 AOSP에 없다:**

| | SM-A325N (삼성) | 23021RAA2Y (MIUI) |
|---|---|---|
| 정책 목록 | requester / app_standby / device_idle / battery_saver / **tare** / **gms_manager** | requester / app_standby / device_idle / battery_saver / **ssru** / **power_pending** |
| 같은 날 실제 발화 | 예약 **+29분 17초** (딥 Doze·RARE) | **미발화** (+3일로 밀림) |

**앱별로 다르게 적용된다** — 그 시점 알람 223개 중 `power_pending=+`는 **32개**뿐이고
나머지 191개는 `power_pending=--`(미적용)였다.

- 적용됨: Facebook 계열, Toss, Play Store, MIUI 추천, **kr.co.anbucheck.live**
- 미적용: 카카오톡, GMS, 기본 시계, MIUI 알림

즉 "모든 앱을 3일 미루는" 전역 정책이 아니라 **선별 정책**이다. 선별 기준은 미확인.
⚠️ **인터넷에 1차 자료가 없다.** `power_pending`·`ssru`는 MIUI 비공개 구현이고 검색으로는
`dumpsys alarm` 일반 설명만 나온다. 근거는 위 실측뿐이며 **표본 1대**다.

**영향 범위 — 회귀는 아니다.** 알람이 안 떠도 1~3차는 그대로 돌았다(WorkManager가 06:34,
예약 +4분에 발화). MIUI에서는 0차의 정시성 이득만 사라지고 최악이 기존 동작이라는 설계
전제가 여기서도 유지된다. 다만 **"상한 60분 보장"은 MIUI에서 주장하면 안 된다.**

⚠️ **판정 시 `origWhen`을 보지 말 것.** `origWhen`은 요청 시각이라 정상으로 보인다.
반드시 `whenElapsed`와 `policyWhenElapsed`를 함께 읽어야 밀린 것이 보인다:
```bash
adb -s "$SER" shell "dumpsys alarm | grep -A4 'anbucheck.live.HEARTBEAT_ALARM'"
```

#### ⚠️ 정정 — `power_pending`은 **영구 플래그가 아니라 동적 상태**다 (2026-08-26 06:51)

다음 날 같은 기기에서 우리 앱 알람의 `power_pending`이 **`--`(미적용)로 바뀌어 있었다.**

```
origWhen=2026-08-27 06:30:00.000
policyWhenElapsed: requester=+23h36m45s816ms ... power_pending=--
whenElapsed=+23h36m45s816ms          ← 밀리지 않음 = 내일 06:30 정상
```

기기 전체로는 정책이 여전히 살아 있다(`power_pending=+` **38건** / `--` 195건). **우리 앱만
그 집합에서 빠진 것**이다. 그사이에 있었던 일은 두 가지 — 08-25 08:19~08:23 **사용자가 앱을
열었고**, 08-26 06:49 **heartbeat 전송이 성공**했다.

⚠️ **따라서 "MIUI에서 0차는 동작하지 않는다"는 단정은 과했다.** 정확한 진술은
**"MIUI는 앱이 `power_pending` 상태일 때 allow-while-idle 알람을 정확히 +72시간 미룬다"**이며,
그 상태가 무엇으로 설정·해제되는지는 **미확인**이다. 앱 사용이 해제 조건이라면, **앱을 열지 않는
실사용자는 대부분의 시간을 그 상태로 보내게 되므로** 실사용 영향은 여전히 크다.
확인 방법은 공짜다 — 앱을 열지 않은 채 며칠 두고 `power_pending`이 돌아오는지 본다.

#### 같은 날 MIUI 실측 — 알람 없이 WorkManager 단독으로 **+19분** (2026-08-26)

```
06:09:32  ARMED (app-process-start) for=08-26 06:30      ← 무장은 됨
06:30     (알람 미발화 — power_pending +3d 상태였음)
06:49:16  Start proc ... for service {SystemJobService} caller=android   ← JobScheduler
06:49:16  ARMED (app-process-start) for=08-27 06:30
06:49:22  걸음수 result: 20 → 전송 성공 (send_failed 없음)
```

기기는 **딥 Doze**(`mState=IDLE`, 화면 꺼짐, 비충전)였고 다음 창은 +28분이었다. 즉 06:49에
유지보수 창이 열려 job이 뛴 것이다. **예약 +19분** — 삼성의 WorkManager 단독 실측
(+1h27m~+2h52m)보다 훨씬 낫다.

⚠️ **"OEM별로 job 스케줄링이 관대하다"로 결론내지 말 것 — 조건이 다를 수 있다.**
이 샤오미는 **셀룰러 폰이자 다른 기기들의 핫스팟 소스**다(2026-08-27 사용자 확인).
테더링 중에는 딥 Doze에 잘 들어가지 않으므로, 빠른 발화가 OEM 특성이 아니라 **애초에
Doze가 아니었기 때문**일 수 있다. 실제로 08-27의 **+1분 49초**는 이례적으로 빠른데
그때 `mState`를 찍어두지 않았다. 위 08-26 06:51 판독만이 딥 Doze를 확인한 유일한 표본이다.
→ **샤오미 발화 시각을 기록할 때는 반드시 `dumpsys deviceidle`의 `mState`를 함께 남길 것.**
   그것 없이는 삼성과 비교 가능한 값이 아니다.

⚠️ **`dumpsys jobscheduler`의 "job 2개가 내일자"를 성공 서명으로 읽지 말 것.** 앱을 열면
`_syncScheduleFromServer → schedule()`이 같은 모양을 만든다. 2026-08-25에 이 오독으로
"샤오미 전송 성공"이라 판단했다가 `send_failed` 알림(ID `0x53466169`) 게시 로그로 뒤집혔다.
전송 성공/실패의 신뢰할 수 있는 지표는 **`notification_enqueue`의 알림 ID**와 서버 도착 기록이다.

### ★ 망 없는 밤의 실패 경로 종단 관측 — 알람 n=2 + FCM이 Doze를 뚫는다 (2026-08-25, SM-A325N)

핫스팟이 자리를 비워 **밤새 망이 없던** 날. 우연히 실패 경로 전체가 관측됐다.

```
07:29:17.860  ARMED (app-process-start) for=08-26 07:00   ← 재무장이 발화보다 먼저
07:29:17.866  ARMED (refire)
07:29:17.881  FIRED idle=true bucket=40                   ← 예약 07:00 대비 +29분 17초
07:29:18.628  HOLD started budget=90000ms
07:29:29.394  걸음수 result: 0
07:29:24      WifiSignalController: connected=false        ← 망 없음
07:30:49.018  HOLD ended held=90389ms reason=timeout      ← 안전한 방향으로 실패
  ~07:30      send_failed 알림 게시
08:20:54      Wi-Fi 재연결 (핫스팟 복귀)
09:00:00.598  Start proc — FCM subject_safety_net 도착
09:00:00.773  ARMED (app-process-start)
09:00:00.867  안전망 알림 표시 (tag=anbu_safety_net)
09:00:01.033  BackgroundWorker 시작                       ← ★ 딥 Doze에 막혀 있던 periodic이 풀림
09:00:01.428  DNS Requested by 11227 → 전송 성공
09:00:02.498  notification_cancel 1397121385 (send_failed)
09:00:02.536  notification_cancel tag=anbu_safety_net
```

**얻은 것 다섯 가지**

1. **알람 재현 n=2.** 딥 Doze + RARE에서 **+29분 17초**(상한 60분 이내). 08-24의 +7분 56초와 함께 2회.
2. **실패 경로가 설계대로다.** `dumpsys jobscheduler` 판독이 결정적이었다 —
   one-off `Minimum latency: +23h30m`(내일), **periodic `+14m59s` + `Unsatisfied constraints:` 비어 있음 + `earliest=-46m`**.
   즉 **전송 실패가 periodic 폴링을 해체하지 않았다**(Defect 1 수정 확인).
3. **⚠️ 망이 돌아와도 딥 Doze면 periodic은 못 뛴다.** 08:20에 Wi-Fi가 붙었는데 09:00까지 40분간
   `readyNotDozing: false`로 대기했다. 다음 유지보수 창은 **+5h23m**(약 14:14)이었다.
   "망만 복구되면 15분 안에 잡는다"는 기대는 **Doze 밖에서만 참이다.**
4. **★ FCM 도착이 그 Doze 벽을 뚫는다.** 푸시 도착 **435ms** 만에 막혀 있던 워커가 실행됐고,
   유지보수 창을 5시간 넘게 앞당겼다. 서버 미수신 체크(+2h)가 **알림 유도만이 아니라
   전송 자체의 트리거로도 기능한다** — 문서에 없던 성질이다.
5. **보류 큐가 그날 걸음수를 살렸다.** 09:00 전송에 걸음수 조회 로그가 없다 = 새로 수집한 게
   아니라 **07:29에 저장해 둔 payload를 보냈다**. "전송보다 저장이 먼저"가 실증됐다.

**부수 관측**
- 알림 정리 2건이 백그라운드 isolate에서 정상 동작 — `cancelSendFailed` + `cancelSubjectSafetyNet`.
  서버 안전망 알림은 뜬 지 **1.7초** 만에 사라졌다(전송이 곧바로 성공했으므로 정상).
- 전송 성공 뒤에도 periodic이 `+14m59s`로 남았다. 실행 중인 워커가 periodic 자신이라
  `schedule()`이 **자기 재등록을 건너뛴** 결과다(self-cancel 방지 설계). 그날 밤 폴링이
  한 번 더 살아 있게 되지만 의도된 동작이다.
- **이른 `send_failed` 알림의 실제 표시 시간 = 약 1시간 31분**(07:30경 → 09:00:02, 자동 소멸).
  이 케이스에서 그 알림은 **정확했다**(진짜 통신 두절). 알림 억제 정책을 논의할 때
  "억제하면 안 되는 쪽"의 사례로 이 건을 쓸 것.

### 계측 로그 읽는 법 — `src=`만 보면 오독한다 (2026-08-27)

`HeartbeatSend` 계측(1.2.8+51~)은 **어느 워커가 POST를 쐈는지**를 찍는다. 알람이 한 일은
거기 안 나온다 — 알람은 앱을 깨우고 창 유지자가 방화벽을 열 뿐, **전송은 그 창 안에서
평소의 워커가 하기 때문**이다(설계상 의도).

```
08-27 07:29:16.974  HeartbeatAlarm: FIRED idle=true bucket=40      ← 예약 07:00 대비 +29분 16초
08-27 07:29:17.367  HeartbeatWindowHolderWorker 시작
08-27 07:29:29.622  HeartbeatSend: OK src=periodic attempt=1 steps=54   ← ★ src는 periodic
08-27 07:29:29.927  HeartbeatAlarm: HOLD ended held=12550ms reason=heartbeat-done
```

**`src=periodic`을 "알람은 쓸모없었다"로 읽으면 틀린다.** 그 periodic은 딥 Doze에 막혀 있다가
알람이 깨워서 풀려난 것이다. 판독은 반드시 세 줄을 묶어서 한다:

| 로그 조합 | 판정 |
|---|---|
| `FIRED` → `HOLD started` → `src=*` → `HOLD ended reason=heartbeat-done` | **알람이 만든 창 안에서 전송** |
| `FIRED` 없이 `src=one-off`/`periodic` | 워커 단독 (알람은 발화 못 했거나 취소됨) |
| `FIRED` → `HOLD ended reason=timeout` | 알람은 떴으나 창 안에 전송이 못 들어감 |

⚠️ **`Application.onCreate`가 아직 발화하지 않은 오늘 알람을 취소한다** (2026-08-27 발견).
`armNextDaily`는 "저장 시각의 다음 발생"을 계산하므로, 예약시각이 지난 뒤 **어떤 이유로든**
프로세스가 뜨면(워커 발화·FCM 도착) 같은 PendingIntent를 내일자로 덮어써 **오늘 남은 발화 창을
없앤다.** 08-27 샤오미가 그 사례다 — one-off이 알람보다 1분 43초 먼저 프로세스를 띄웠고
(`ARMED (app-process-start) for=08-28`), 알람은 발화 기회를 잃었다. 취소는 **전송 시도 전에**
일어나므로 성패와 무관하다.

무해한 경우가 대부분이나(워커가 성공하면 알람은 불필요), **워커가 먼저 실패한 날에는 방화벽을
여는 유일한 재시도를 잃는다.** 수정 방향: `armNextDaily`가 ①오늘용 알람이 실제로 대기 중이고
(`PendingIntent.getBroadcast(..., FLAG_NO_CREATE) != null`) ②지금이 `[T, T+1h]` 안이며
③`flutter.last_heartbeat_date != 오늘`이면 **재무장을 건너뛴다.** ①이 없으면 최초 설치가
창 안에서 아무것도 무장하지 못한다. 대가는 워커가 성공한 날의 헛기상 1회다(성공 경로의
`HeartbeatAlarm.arm`은 MethodChannel이 `MainActivity` 전용이라 워커 isolate에서 no-op).

### 가드(`todaysWindowStillUseful`) 검증 기준 — 실패는 **로그가 아니라 부재로** 나타난다

`ARM skipped — 오늘 발화 창 유지` + `FIRED`만 보면 **위험한 방향을 못 잡는다.** 가드가 과하게
발동해 **무장이 멈추는** 실패는 아무 로그도 남기지 않는다. 그래서 판정은 두 갈래 모두 본다.

**① 필수 통과 조건 — 아침 사이클이 끝난 뒤 양쪽 폰에서:**
```bash
adb -s "$SER" shell "dumpsys alarm | grep -A3 'anbucheck.live.HEARTBEAT_ALARM'"
#   origWhen 이 **모레 날짜**여야 한다.
#   오늘·어제 날짜이거나 항목 자체가 없으면 → 재무장이 깨졌다 = 실패.
#   (그래도 창 밖 프로세스 시작에서 자가 복구되지만, 이 변경이 원인이므로 되돌린다.)
```

**② `ARM skipped (app-process-start)`는 "워커가 먼저 뛰었다"의 증거가 아니다.**
콜드 스타트 알람 배달에서는 `Application.onCreate`가 `onReceive`보다 **먼저** 돈다. 그 시점엔
pending 존재 + 창 안 + 오늘 미전송이 모두 참이라 **알람 자신의 발화 경로에서도 skip 줄이 찍힌다**
(그 뒤 `ARMED (refire)`가 따라온다). 발화 후 PendingIntent 레코드가 이미 회수됐다면 대신
`ARMED (app-process-start)`가 찍힌다 — **둘 다 정상이고 비결정적**이다(refire가 force라 무해).

판별자는 **바로 위의 프로세스 시작 사유**다:

| 앞 줄 | 의미 |
|---|---|
| `Start proc ... for service {SystemJobService} caller=android` | **워커가 프로세스를 띄웠다** → 가드가 설계 목적대로 동작 |
| `Start proc ... for broadcast {...HeartbeatAlarmReceiver}` | 알람 자체 발화 → skip 줄은 부수적, 판정 근거 아님 |

샤오미에서 **첫 번째 형태**가 확인돼야 이 수정이 실증된 것이다.

### 정시성 재현 — 3일 연속 +29분 16~17초 (SM-A325N)

| 날짜 | 예약 | 발화 | 지연 |
|---|---|---|---|
| 08-25 | 07:00 | 07:29:17 | +29m17s |
| 08-26 | 07:00 | 07:29:16 | +29m16s |
| 08-27 | 07:00 | 07:29:16 | +29m16s |

셋 다 딥 Doze·RARE이고 유지보수 창 밖이다. 초 단위 재현의 이유는 **미확인**.

### ★★ MIUI 실측 — 알람은 정시에 뜨는데 **창 유지자가 방화벽을 못 연다** (2026-08-28, 표본 1대)

Redmi 23021RAA2Y / HyperOS 2.0, 예약 06:30, 딥 Doze(`mState=IDLE`), 셀룰러 LTE, 비충전, 앱 미실행.

```
06:02:54  Start proc ... FlutterFirebaseMessagingReceiver (아이폰 06:00 안부 푸시)
06:02:55  ARMED (app-process-start) for=08-28 06:30      ← 창 밖이라 정상 무장
06:30:34  Start proc ... for broadcast {HeartbeatAlarmReceiver}
06:30:35.030  ARM skipped (app-process-start) — 오늘 발화 창 유지 (6:30)
06:30:35.070  ARMED (refire) for=08-29 06:30             ← force 정상
06:30:35.090  FIRED idle=true bucket=40                  ← ★ 예약 +35초
06:30:35.353  HOLD started budget=90000ms
06:30:38      SmartPower: adj=-10000 → adj=227           ← 발화 3초 만에 강등
06:30:41.044  FAIL src=alarm attempt=3 unreachable=true steps=110 notify=true
06:37:10.428  HOLD ended held=395077ms reason=timeout    ← ★ 90초 예산을 6분 35초에 소진
06:37:10.924  FAIL src=periodic attempt=3 unreachable=true
```

**① 알람 자체는 MIUI에서 아주 잘 뜬다 — 딥 Doze에서 예약 +35초.** 삼성의 +29분과 극명하게 다르다
(Doze 유지보수 창과 겹친 덕으로 보인다). `power_pending=--`였다.

**② 그런데 전송이 방화벽에 막힌다. 망은 멀쩡했다.**
```
망 : MOBILE[LTE] CONNECTED ... VALIDATED
앱 : blocked_state={blocked=APP_STANDBY|APP_BACKGROUND,
                    allowed=NOT_IN_BACKGROUND, effective=APP_STANDBY}
     06:30:35 Firewall rule changed: 10521-background-allow   ← background만 열림
     06:03:15 Firewall rule changed: 10521-standby-deny       ← standby 차단은 그대로
```
삼성이 성공했을 때는 `allowed=FOREGROUND` / `effective=NONE`이었다(2026-08-21 기록).
여기서는 `NOT_IN_BACKGROUND`에 그쳐 **`effective=APP_STANDBY`로 막힌다.**

**③ 그리고 프로세스가 6분 30초간 얼었다.** 창 유지자의 `held=395077ms`(예산 90,000ms)가 증거다 —
루프는 `elapsedRealtime` 기준 0.5초마다 도는데 그게 안 돌았다는 뜻이다. 해동 직후 periodic이
재시도했으나 같은 방화벽에 또 막혔다.

⚠️ **"expedited가 무시됐다"고 단정하려면 창 유지자가 실제로 expedited로 떴는지 먼저 확인해야 한다.**
`enqueueWindowHolder`는 `setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)`라
**EJ 쿼터가 없으면 조용히 일반 job으로 강등**된다. 강등됐다면 애초에 면제를 요청조차 안 한 것이므로
"MIUI가 expedited를 무시한다"는 결론이 성립하지 않는다.

**확인 방법 — `Timer<EJ>`가 아니라 `ShrinkableDebits`를 볼 것:**
```bash
adb -s "$SER" shell "dumpsys jobscheduler | grep -m2 -A2 'kr.co.anbucheck.live.*ShrinkableDebits'"
#   <0>kr.co.anbucheck.live: ShrinkableDebits { debit tally: 389125, bucket: 3 }
```
EJ 부채는 **expedited job만** 발생시킨다. 08-28 실측에서 부채 **389,125ms**가 창 유지자의
`held=395077ms`와 1.5% 안에서 일치했다 → **expedited로 실행된 것이 맞다**(enqueue 시점엔
부채가 거의 0이라 강등 조건도 아니었다). 따라서 이 기기에서는 **expedited 상태로도 동결과
APP_STANDBY 차단을 피하지 못한다.**

⚠️ `Timer<EJ>{...} started at ... N running bg jobs`를 근거로 쓰지 말 것 — 거기 표시되는 job 이름은
전부 `SystemJobService`라 어느 워커인지 알 수 없고, 시작 시각도 다른 EJ 세션의 것일 수 있다
(2026-08-28에 이걸로 한 번 오독했다).

⚠️ **결론: 이 기기에서 0차 계층은 "깨우기"까지만 되고 "내보내기"가 안 된다.** 회귀는 아니다
(1~3차는 그대로) 하지만 **MIUI에서 알람 계층의 이득을 기대하면 안 된다.** 표본 1대다.

#### ★ 부수 확인 — "인터넷 연결을 확인해 주세요" 알림이 **거짓 원인**임이 실증됐다

`send_failed`(ID `0x53466169`)가 게시된 그 시각에 **LTE가 `CONNECTED`+`VALIDATED`**였다.
문구는 망을 의심하라고 하지만 실제 원인은 **APP_STANDBY 방화벽**이다. 2026-08-25에 사용자가
"워커/알람 실패로 사용자가 오해할 수 있다"고 제기한 문제이며, 계측(`HeartbeatSend`)이 그
자리에서 `unreachable=true`와 망 `VALIDATED`를 함께 보여줘 처음으로 근거가 생겼다.
→ 알림 정책 변경("지속 실패에서만" / 문구에서 원인 단정 제거)을 검토할 때 이 건을 근거로 쓸 것.

⚠️ 판정 함정 재확인: 이날 `ARM skipped — 오늘 발화 창 유지`가 찍혔지만 앞 줄이
`Start proc ... for broadcast {HeartbeatAlarmReceiver}`였다 — **알람 자신의 발화 경로**다.
가드가 노리는 **워커-먼저 시나리오는 아직 미실증**이다.

### ★ 가드 검증 통과 — 그리고 MIUI를 실제로 구한 것은 **밖에서 들어온 FCM**이었다 (2026-08-28)

`1.2.8+52`(가드 `todaysWindowStillUseful` 포함) 양 기기 관측. **필수 조건 ①② 모두 통과.**

| | SM-A325N | 23021RAA2Y (MIUI) |
|---|---|---|
| 알람 발화 | 07:29:17 (예약 07:00, **4일 연속 +29분대**) | 06:30:35 (예약 06:30, **+35초**) |
| 가드 발동 | ✅ `ARM skipped — 오늘 발화 창 유지` | ✅ 동일 |
| **재무장** | ✅ `origWhen=08-29` | ✅ `origWhen=08-29` |
| 전송 | ✅ 07:29:29 `OK src=periodic steps=106` | ❌ 06:30·06:37 실패 → **07:29:33 FCM으로 성공** |

**★ 가드가 실제로 켜진 상태에서 재무장이 깨지지 않음이 양 기기에서 확인됐다** — `force` 분기가
정확히 그 자리를 막았다. 이것이 이 변경의 유일한 필수 조건이었다.

#### MIUI를 구한 것은 우리 트리거가 아니었다

```
06:30:35  알람 FIRED (정시 +35초)  →  06:30:41 FAIL src=alarm  unreachable=true
06:37:10  periodic                →  06:37:10 FAIL src=periodic unreachable=true
07:29:29  SmartPower: idle→background **adj=0**
          R(broadcast start Intent { act=...c2dm.intent.RECEIVE pkg=kr.co.anbucheck.live })
          ← 삼성 07:00 안부 → 서버 → 샤오미(보호자)로 FCM 도착
07:29:30  onNotificationRemoved ...|1397121385|   ← send_failed 제거 = _onHeartbeatSent 실행
07:29:33  서버 POST /api/v1/heartbeat 200 OK      ← 보류 큐의 06:30 payload(steps=110) 전달
```

**`adj=0`이 핵심이다.** 알람이 깨웠을 때는 3초 만에 `adj=227`로 강등돼 방화벽이 `APP_STANDBY`로
닫혀 있었다. FCM 브로드캐스트만이 프로세스를 포그라운드급으로 올려 방화벽을 열었다.

⚠️ **방화벽은 UID 단위다.** 다른 앱에 온 푸시는 소용없고 **`kr.co.anbucheck.live`로 배달되는
푸시**여야 한다. 그래서 **순수 S 모드 MIUI 사용자**는 보호자 푸시를 받을 일이 없어
`subject_safety_net`(+2h)까지 밀릴 수 있다 — 이날 샤오미가 1시간 일찍 구제된 것은 **G+S여서**
삼성의 안부가 보호자 푸시로 돌아온 덕이다.

→ 이 관측을 근거로 "사일런트 푸시로 앞당기기"를 TODO에 남겼다. 단 PRD §2.2가 이미 기각한
   항목이므로(하필 MIUI가 막는다고 적혀 있다) 실측 3건이 선행돼야 한다.

#### ⚠️ 계측 구멍 — 보류 큐 재전송에는 로그가 없다

`_sendPendingInternal`이 `HeartbeatRemoteDatasource.send()`를 **직접** 호출해
`_sendOrSavePending`의 `HeartbeatSend` 로그를 거치지 않는다. 그래서 07:29 성공이 로그에
남지 않았고, **무엇이 그 전송을 호출했는지(FCM 핸들러인가 풀려난 워커인가) 아직 못 갈랐다.**
다음 사이클에 로그 한 줄을 추가할 것.

#### 진단 팁 — `dumpsys alarm`의 이력 섹션

logcat 없이도 **과거 발화 시각**을 바로 볼 수 있다:
```bash
adb -s "$SER" shell "dumpsys alarm | grep -A6 'anbucheck.live.HEARTBEAT_ALARM'"
#   [tag=*walarm*:...HEARTBEAT_ALARM origWhen=... rtc=2026-08-27 07:29:16.660]
```
삼성은 08-26·08-27 배달이 `elapsed` 기준 **정확히 86,400,000ms 간격**이었다 — 시스템이 우리
알람을 매일 같은 시각에 도는 다른 알람과 **묶어서** 배달한다는 뜻이고, `+29분대`가 초 단위로
재현되는 이유다. ⚠️ 따라서 **요청 시각을 앞당겨도 배달 시각은 따라오지 않는다**(`setExactAndAllowWhileIdle`은
`SCHEDULE_EXACT_ALARM`이 필요해 쓸 수 없다). "알람을 몇 분 먼저 쏘자"는 방향은 성립하지 않는다.

### ★ 1.2.9+53(iOS 머지본) 검증 — 삼성 통과 / 샤오미는 전송 성공·재무장 지연 (2026-08-29)

두 기기 모두 안부 전달 성공. 삼성은 필수 조건 ①② 모두 통과, 샤오미는 ①이 **지연**됐다.

| | SM-A325N | 23021RAA2Y (MIUI) |
|---|---|---|
| 알람 발화 | 07:29:16 (**5일 연속 +29분 16~17초**) | ❌ 미발화 — `power_pending=+3d` |
| 가드 발동 | ✅ `ARM skipped — 오늘 발화 창 유지` | ✅ 동일(07:24, 07:29:28 두 번) |
| 재무장 | ✅ `ARMED (refire)` → `origWhen=08-30` | ⚠️ **`origWhen=08-29` 그대로** |
| 전송 | ✅ 07:29:29 `OK src=periodic steps=57` | ✅ 07:29:35 `OK src=periodic steps=64` |

#### ⚠️ 새로 드러난 케이스 — **알람이 발화 못 한 날은 재무장이 다음 프로세스 시작까지 밀린다**

샤오미의 재무장 미완은 **가드 오작동이 아니라** 세 조건이 겹친 결과다:

1. `power_pending`으로 알람이 +3일 밀려 **발화하지 못함** → `onReceive`의 `force` 재무장 경로가 아예 없었다.
2. 07:24·07:29:28의 `app-process-start`는 **창 안 + 오늘 미전송**이라 가드가 정확히 스킵했다(설계대로).
3. 07:29:35 전송 성공 후 `_onHeartbeatSent → HeartbeatWorkerService.schedule() → HeartbeatAlarm.arm()`은
   **MethodChannel이 `MainActivity` 전용이라 워커 isolate에서 no-op**이다.

→ 결과적으로 그날 재무장 기회가 **한 번도 오지 않았다.** 다음 프로세스 시작 때는
`flutter.last_heartbeat_date == 오늘`이라 가드가 스킵하지 않고 내일자로 무장하므로 **자가 복구된다.**

⚠️ 가드 커밋(`770b200`)에 적어둔 대가는 *"워커가 성공한 날에도 알람이 발화한다(헛기상 1회)"*였는데,
**그 반대 케이스** — 알람이 발화하지 못하고 워커가 성공한 날 — 는 적어두지 않았다. 최악은
"그날 0차 계층 없음 = 기존 1~3차 동작"이라 회귀는 아니다. 특히 이 기기는 `power_pending`으로
어차피 알람이 3일 밀려 있어 0차가 무의미한 상태였다.

#### 샤오미를 구한 것은 또 FCM이었다 (n=2)

```
07:29:28.554  Start proc ... FlutterFirebaseMessagingReceiver caller=com.google.android.gms
              ← 삼성 07:00 안부 → 서버 → 샤오미(보호자)로 푸시
07:29:35.270  HeartbeatSend: OK src=periodic steps=64      ← 푸시 도착 7초 뒤
```
08-28과 같은 패턴이 하루 더 재현됐다. 다만 이번엔 `src=periodic`으로 **계측 로그가 남았다**
(08-28은 보류 큐 경로라 로그가 없었다).

#### ★ "다른 앱 푸시는 소용없다"가 통제 실험으로 확정됐다

07:21경 **Gmail 알림이 도착했으나 우리 앱은 전혀 깨어나지 않았다.**
```
07:23:06  UID=10521 state=null
          blocked_state={blocked=DOZE|APP_BACKGROUND, allowed=NONE, effective=DOZE|APP_BACKGROUND}
          같은 시간대 Start proc(anbucheck): 0건 / HeartbeatSend: 없음
```
`state=null`은 프로세스가 아예 없다는 뜻이다. 지금까지 `netpolicy` 출력에서 "UID 단위니까"라고
**추론만** 하던 것이 반례 실험으로 확정됐다 — **우리 앱으로 배달되는 푸시여야 한다.**

⚠️ 차단 사유가 06:30의 `APP_STANDBY`에서 07:23엔 `DOZE`로 바뀌었다. 기기가 딥 Doze로 다시
들어갔기 때문이며, 어느 쪽이든 막힌다는 결과는 같다.

#### AOD는 Doze를 깨지 않는다

샤오미 화면이 불규칙하게 켜졌다 꺼지길 반복하는 것은 **AOD(항상 표시 화면)**다
(`settings get secure doze_always_on` = 1, `screen_doze` 이벤트 118건, 켜짐 구간 ~12초).
⚠️ **그런데 Doze는 유지된다** — 사용자가 "지금 화면이 켜졌다"고 한 시간대에 시스템은
`mScreenOn=false, mState=IDLE`로 보고했다. AOD는 디스플레이가 저전력 doze 상태로 켜지는 것이라
`DeviceIdleController`가 화면 켜짐으로 치지 않는다. **AOD 때문에 관측이 무효가 되지 않는다.**

## 5. 테스트 환경 주의사항 (실수로 날린 것들)

- **이 테스트폰은 Play 설치본**(`installer=com.android.vending`)이다. 로컬 서명 release APK를 사이드로드하면 서명 불일치로 실패하거나, 강제로 재설치할 경우 **SSAID가 바뀌어 서버 계정(G+S·구독·보호자 연결)이 고아가 된다.** 검증 빌드는 **Play 내부 테스트 트랙**으로 올린다. → [[project_ssaid_signing_scope]]
- **스와이프 킬은 job을 지우지 않는다**(실측 확인). 삼성에서도 프로세스 종료일 뿐이다. 반면 **설정 → 앱 → 강제 중지는 job을 전부 삭제**한다. 테스트 중 금지.
- **USB 충전 중에는 Doze에 진입하지 않는다.** 케이블을 꽂은 채로는 어떤 Doze 관측도 성립하지 않는다. → **관측은 §4의 무선 adb로 한다**(케이블 없이 붙으므로 Doze가 정상 진행된다). 부득이 USB를 써야 하면 `adb shell dumpsys battery unplug`로 프레임워크에 비충전 상태를 시뮬레이션하고, 끝나면 **반드시 `adb shell dumpsys battery reset`** (안 하면 재부팅 전까지 가짜 상태가 유지돼 다음 테스트가 오염된다).
- **앱을 열면 standby 버킷이 ACTIVE로 리셋**된다(배칭 비대상 + 세션 75). 수십 분 내 WORKING_SET으로 내려가고, 장기 미사용 시 RARE가 된다. 앱을 연 직후의 테스트는 **평상시보다 유리한 조건**이라는 것을 명시할 것.
- **앱 진입(`_syncScheduleFromServer`)만으로 `HeartbeatWorkerService.schedule()`이 포그라운드에서 실행**된다. 포그라운드에는 실행 중인 worker가 없어 self-cancel이 원리적으로 불가능하므로, unique name 마이그레이션 같은 위험한 정리는 이 경로가 가장 안전하다.

---

## 6. 이 기기에서 "정시 발화"는 성립하지 않는다 — 두 경로의 실측 지연

배터리 최적화 기본 설정(= EXEMPTED 버킷 아님)에서는 **어떤 경로도 정시에 뜨지 않는다.**
앱 코드로 줄일 수 없다(배칭은 시스템, Doze·쿼터는 OS 전력 관리, 알람은 부정확이 설계).

### JobScheduler / WorkManager (실측)

| 날짜 | 예약 | 실제 전송 | 지연 |
|---|---|---|---|
| 08-19 | 15:00 | 17:52 | +2h52m |
| 08-20 | 15:00 | 17:35 | +2h35m |
| 08-21 | 15:00 | 16:27 | +1h27m |

⚠️ **"예약시각 + 수 분 ~ 31분"이라고 적었던 이전 판은 틀렸다.** 31분은 §1③ 배칭 상한일
뿐이고, 실제 지배 요인은 §1① **Doze 유지보수 창**이다. 창 간격이 1h→2h→4h→6h로
배증하므로 **지연에 상한이 없다** — 최악은 6시간이다.

### allow-while-idle 알람 (실측)

| 날짜 | 예약 | 실제 발화 | 지연 | 발화 시점 `idle` |
|---|---|---|---|---|
| 08-21 | 19:05 | 19:37:17 | **+32분** | true (다음 창 19:49 — 창보다 12분 먼저) |
| 08-22 | 07:00 | 07:07:18 | +7분 | true |
| 08-22 | 09:30 | 09:37:17 | +7분 | true |
| 08-22 | 10:50 | 11:04:13 | +14분 | false → t+15s부터 true |
| 08-22 | 14:00 | 14:25:50 | **+26분** | false (14:25:44~14:26:14 비-idle 구간) |

평균 약 +17분, 최대 +32분. **문서상 상한은 1시간**이며 5회 모두 그 안이었다.

⚠️ `idle=false`로 찍힌 2회의 원인은 **미확정**이다. (가) 유지보수 창이 마침 열렸다,
(나) 알람이 배달 직전에 기기를 깨웠다 — 로그만으로 구분되지 않는다. 다만 08-21 19:37은
**다음 창보다 12분 먼저** 떴으므로 "창에 묶여야만 뜬다"는 설명은 반증된다.

### 핵심 차이는 평균이 아니라 **상한**이다

```
WorkManager :  +1h27m ~ +2h52m,  상한 없음 (창이 6시간까지 배증)
알람        :  +7분 ~ +32분,     상한 60분 (시스템 보장)
```

제품에서 중요한 건 정시성이 아니라 **서버 미수신 체크(예약시각 +2h)보다 먼저 도착하는가**다.
알람은 최악 +60분이어도 1시간 여유가 남지만, WorkManager는 실측에서 이미 그 선을 넘어
거짓 미수신 경고를 냈다(08-19·08-20).

### 정시로 만들 수 없다 / 앞당기지도 않는다

- **정확한 알람 불가**: `setExactAndAllowWhileIdle`은 `SCHEDULE_EXACT_ALARM`을 요구하고,
  그 권한은 Android 14+ 기본 거부 + Play 정책상 알람시계·캘린더 앱 전용이다.
- **예약시각 −30분에 무장하는 안은 기각한다**: 창이 `[T−30, T+30]`이 되어 평균은 당겨지지만,
  T−25분에 뜨면 Dart 콜백의 `−15분` 가드에 걸려 **스킵되고 알람이 소비**된다. 가드를 풀면
  예약시각 전에 전송되어 **그날 걸음수가 잘린다.** 정시성을 위해 데이터 정확도를 깎는 거래다.

### 문구 규칙

문서·UI에 **"정시에 전송된다"고 쓰지 않는다.** 정확한 표현은:

> 예약시각으로부터 **1시간 이내**에 전송된다 (알람 경로 실측 평균 +17분).
