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

- 잔량 확인: `dumpsys jobscheduler | grep -A1 "from u0a1227"` → `RARE, within regular quota, 591463ms remaining`
- 5초 이내 동시 시작한 one-off + periodic은 **1세션**으로 합쳐진다(실측: 02:16:38.446 / .854).

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
| 08-17 20:16:06 | **adb 접속** | 필수 제약 전부 충족 **26.5초**, 그래도 배칭으로 **미발화** |
| 08-18 02:16:34 | **Doze 유지보수 창**(약 64초) | one-off + periodic **동시 발화**(0.4초 차) |
| 08-18 02:31~06:49 | — | periodic이 **4시간 18분 초과**하도록 미발화 (딥 Doze) |
| 08-18 15:07:52 | 사용자가 **화면 켬**(15:05) | 2분 50초 뒤 발화 → **0.73초 만에 lmkd 킬** |
| 08-18 15:22:25 | 사용자가 **유튜브 실행** | 15:13 준비 → **9분 뒤** 배칭 방출로 발화, 전송 성공 |

**핵심 교훈**

- "폰 화면을 켜면 뜬다"는 **반만 맞다.** Doze는 풀리지만 배칭 지연이 그 뒤에 또 붙는다(실측 2.5분~8분).
- **다른 앱 실행이 오히려 효과적인 트리거**다. 그쪽 job이 `min_ready_non_active_jobs_count=5`를 채워 우리 job까지 방출시킨다.
- FCM 푸시 도착은 **망만 잠깐 열 뿐** Doze를 풀지 않는다 → job 발화 트리거가 되지 못한다.
- adb 접속은 Doze를 깨운다 → **관측이 관측 대상을 바꾼다.** 스냅샷은 짧게 찍고 바로 끊을 것.

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

## 5. 테스트 환경 주의사항 (실수로 날린 것들)

- **이 테스트폰은 Play 설치본**(`installer=com.android.vending`)이다. 로컬 서명 release APK를 사이드로드하면 서명 불일치로 실패하거나, 강제로 재설치할 경우 **SSAID가 바뀌어 서버 계정(G+S·구독·보호자 연결)이 고아가 된다.** 검증 빌드는 **Play 내부 테스트 트랙**으로 올린다. → [[project_ssaid_signing_scope]]
- **스와이프 킬은 job을 지우지 않는다**(실측 확인). 삼성에서도 프로세스 종료일 뿐이다. 반면 **설정 → 앱 → 강제 중지는 job을 전부 삭제**한다. 테스트 중 금지.
- **USB 충전 중에는 Doze에 진입하지 않는다.** 관측 전 최소 2시간은 뽑아둘 것.
- **앱을 열면 standby 버킷이 ACTIVE로 리셋**된다(배칭 비대상 + 세션 75). 수십 분 내 WORKING_SET으로 내려가고, 장기 미사용 시 RARE가 된다. 앱을 연 직후의 테스트는 **평상시보다 유리한 조건**이라는 것을 명시할 것.
- **앱 진입(`_syncScheduleFromServer`)만으로 `HeartbeatWorkerService.schedule()`이 포그라운드에서 실행**된다. 포그라운드에는 실행 중인 worker가 없어 self-cancel이 원리적으로 불가능하므로, unique name 마이그레이션 같은 위험한 정리는 이 경로가 가장 안전하다.

---

## 6. 이 기기에서 "정시 발화"는 성립하지 않는다

배터리 최적화 기본 설정(= EXEMPTED 버킷 아님) 상태에서는 **예약시각 + 수 분 ~ 31분**이 정상 동작이다.
앱 코드로 줄일 수 없다(③은 시스템 배칭이고 ①②는 OS 전력 관리다).

제품상 문제는 없다 — 서버 미수신 체크가 **예약시각 +2시간**이라 여유 안에 있다.
다만 "정시에 전송된다"는 서술은 사실과 다르므로 문서·문구에 쓰지 않는다.
