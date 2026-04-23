# 안부 확인 앱 - FrontEnd PRD


## 1. 개요


### 1.1 프로젝트명
**Anbu** (안부)

| 항목              | 값                     |
| ----------------- | ---------------------- |
| 도메인            | `anbucheck.co.kr`      |
| Android 패키지명  | `kr.co.anbucheck.live` |
| iOS Bundle ID     | `kr.co.anbucheck.live` |
| 인앱 결제 상품 ID | `anbu_yearly`          |


### 1.2 목적
스마트폰 사용 패턴을 기반으로 사용자의 안녕을 자동으로 확인하는 크로스 플랫폼(Android/iOS) 시스템.
24시간 이상 스마트폰 미사용 시 서버에 경고를 기록하고 보호자에게 알림을 발송하여, 독거노인·1인 가구 등의 안전을 원격으로 모니터링한다.

**이 앱은 응급상황 알림 앱이 아니다.** 사용자의 일상적 안부 확인만을 목적으로 한다.


### 1.3 핵심 가치
- **제로 인터랙션**: 사용자가 별도 조작 없이 자동으로 안부 신호를 보고
- **최소 배터리 소모**: 상시 백그라운드 실행 없이, OS 네이티브 메커니즘으로 매일 1회 확인
- **신뢰성**: 거짓 경고(false alarm) 최소화
- **크로스 플랫폼**: Android/iOS 동시 지원, 앱 심사 통과 용이한 설계
- **단순함**: 대상 사용자(독거노인 등)가 설치 후 신경 쓸 것 없는 앱
- **개인정보 미수집**: 이름, 전화번호 등 개인정보를 서버에 저장하지 않음


### 1.4 타겟 사용자
- **보호 대상자**: 독거노인, 1인 가구 등 안부 확인이 필요한 분
- **보호자**: 대상자의 안전을 원격으로 확인하려는 가족, 돌봄 서비스 운영자


### 1.5 수익 모델
- **보호자가 결제**: 3개월 무료 체험 → 이후 연 $9.99 자동 갱신 구독
- **보호 대상자 앱은 완전 무료** (결제 기능 없음)
- **보호 대상자 최대 5명** (단일 요금, 티어 구분 없음)
- **하단 고정 배너 광고** (유료 구독 보호자는 광고 제거)


### 1.6 개인정보 보호 원칙
- 서버에 **이름, 전화번호 등 개인정보를 일절 저장하지 않음**
- 보호 대상자-보호자 연결은 서버가 발급한 **고유 코드(invite_code)**로 매칭
- 보호자가 대상자를 식별하기 위한 별칭(예: "삼촌")은 **보호자 앱 로컬에만 저장**
- **위치정보는 정기 heartbeat에서 수집하지 않음.** 대상자가 [🚨 도움이 필요해요] 버튼을 직접 누른 경우에만 사용자 동의 하에 위도/경도/정확도를 1회 수집하여 연결된 보호자에게 전달하고, 대상자 기기 타임존 자정까지만 서버에 보관 (§2 참조)
- 서버 DB가 유출되어도 개인 식별 불가 (당일 긴급 요청 위치 외에는 보관 없음)
- 앱 심사 시 개인정보 수집 항목 최소화 → 심사 통과 유리


### 1.7 앱 구조
하나의 앱에서 **"보호 대상자 모드"**와 **"보호자 모드"**를 선택하는 구조:
- 보호 대상자 모드: heartbeat 전송, 안부 확인 서비스 동작 **(Android 전용)**
- 보호자 모드: Push 알림 수신, 대상자 상태 확인 **(Android + iOS)**


### 1.8 플랫폼별 모드 제한

| 플랫폼 | 대상자 모드 | 보호자 모드 | 모드 선택 화면 |
|--------|------------|------------|--------------|
| **Android** | ✅ 지원 | ✅ 지원 | 표시 (대상자/보호자 선택) |
| **iOS** | ❌ 미지원 | ✅ 전용 | **스킵** (Splash → 바로 권한 화면) |

**iOS 보호자 전용 사유:**
- iOS BGTaskScheduler는 앱 스와이프 강제 종료 시 백그라운드 태스크가 미실행되어 heartbeat 전송 신뢰성을 보장할 수 없음
- 대상자 모드의 핵심인 "매일 heartbeat가 확실히 전송되는 것"을 iOS에서는 구조적으로 충족 불가
- App Store 심사 시 "보호자 모니터링 앱"으로 포지셔닝 (Background Mode 선언 부담 제거)

**App Store 심사 유의사항:**
- 앱 설명/스크린샷: 보호자 기능만 표시
- 심사 메모: "대상자 기기에서 자동 전송되는 안부 신호를 보호자가 모니터링하는 앱" (Android 언급 금지)
- 앱 카테고리: Health & Fitness 또는 Lifestyle

**구현:** `splash_controller.dart`에서 `Platform.isIOS` 분기 → `AppRoutes.permission`(guardian)으로 직행

```
[앱 최초 실행]
Splash → 버전 체크 → 플랫폼 분기
    │
    ├─ 버전 체크 (GET /api/v1/app/version-check)
    │   ├─ force_update = true → 강제 업데이트 다이얼로그 → 스토어 이동
    │   ├─ force_update = false → 선택적 업데이트 안내 (건너뛰기 가능)
    │   └─ 서버 응답 실패 → 건너뛰고 정상 진행
    │
    ├─ [Android] 모드 선택
    │   ├─ "나의 안전을 확인받고 싶어요" → [보호 대상자 모드]
    │   │   권한 요청 안내 화면 (모드 선택 후 진입)
    │   │   ├─ 알림 권한 (필수)
    │   │   ├─ 신체 활동 권한 (ACTIVITY_RECOGNITION, 걸음수 감지용)
    │   │   └─ [확인] 탭 → OS 권한 팝업 순차 표시 (사전 안내 다이얼로그 없이 바로)
    │   │   Onboarding (서비스 소개/동작 안내) → 서버 등록 (자동) → Home (고유 코드 표시)
    │   │
    │   └─ "소중한 사람을 지켜보고 싶어요" → [보호자 모드]
    │       모드 선택 시 checkDevice API로 기존 등록 여부 확인
    │       ├─ G+S 재설치 감지 (has_invite_code=true) → isAlsoSubject=true 전달
    │       권한 요청 안내 화면 (모드 선택 후 진입)
    │       ├─ 알림 권한 (필수)
    │       ├─ 신체 활동 권한 — isAlsoSubject=true일 때만 표시/요청 (G+S 복원)
    │       │   순수 보호자는 걸음수 전송이 없으므로 표시하지 않음 (Lazy Permission)
    │       └─ [확인] 탭 → OS 권한 팝업 순차 표시
    │       Onboarding → 서버 등록 (자동) → 대시보드 (보호 대상자 추가 대기)
    │
    └─ [iOS] 모드 선택 스킵 → 보호자 모드 직행
        권한 요청 안내 화면 (보호자 모드 자동 설정)
        ├─ 알림 권한 (필수, APNs)
        └─ [확인] 탭 → OS 권한 팝업 (모션 권한은 G+S 활성화 시점에 지연 요청)
        Onboarding → 서버 등록 (자동) → 대시보드 (보호 대상자 추가 대기)
```


---


## 2. [보호 대상자 모드] 안부 확인 아키텍처 (클라이언트 관점)

> ⚠️ **이 섹션 전체는 대상자 모드 전용입니다.**
> 보호자 모드는 heartbeat를 전송하지 않으며, 이 아키텍처와 무관합니다.
> **예외: G+S 모드** — 보호자가 대상자 역할을 겸할 때 이 아키텍처가 동작함. 활성화/해제/예약은 `GuardianDashboardController`가, heartbeat 자동 재전송은 `GuardianSafetyCodeController`가 단독 소유한다.
> 보호자 모드 아키텍처는 섹션 3(Push 알림 수신)을 참조하세요.

> 📊 **전체 플로우차트**: [heartbeat_flowchart.md](heartbeat_flowchart.md) 참조
> - 차트 1: 클라이언트 Heartbeat 수집 및 전송 플로우 (대상자 앱)
> - 차트 4: 적응형 Heartbeat 주기 상태도 (정상 24h → 주의 6h → 경계 3h)


### 2.1 핵심 설계 원칙 (보호 대상자 앱)

- **매일 고정 시각** heartbeat 전송 (기본 오후 6:00, 보호자가 대상자별 변경 가능)
- 보호 대상자 앱이 **상시 실행되지 않는** 구조 — 지정 시각에만 잠깐 깨어나 작업 후 종료
- **걸음수(steps_delta)** 로 suspicious 판정: `steps_delta > 0 → false`, `null 또는 0 → true`
- 보호자 앱은 heartbeat를 전송하지 않으므로 이 메커니즘이 동작하지 않음

```
┌─────────────────────────────────────────────────────┐
│                    서버 (Python)                      │
│  heartbeat 수신 → last_seen 갱신                     │
│  지정 시각 + 2시간 미수신 → 보호자에게 Push 경고       │
│  (Silent Push 발송 없음 — 클라이언트 자체 스케줄링)    │
└──────────────────────┬──────────────────────────────┘
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
┌─────────────────┐      ┌─────────────────┐
│   Android 앱     │      │    iOS 앱        │
│                 │      │                  │
│ WorkManager     │      │ BGTaskScheduler  │
│ (예약 시각에     │      │ + Background     │
│  백그라운드 실행) │      │   Fetch          │
│   ↓             │      │   ↓              │
│ 걸음수 조회      │      │ 걸음수 조회       │
│   ↓             │      │   ↓              │
│ heartbeat 전송   │      │ heartbeat 전송    │
│   ↓             │      │   ↓              │
│ 동일시각 매일 재예약 │      │ 동일시각 매일 재예약    │
└─────────────────┘      └─────────────────┘
```


### 2.2 OS별 안부 확인 메커니즘

|                       | Android                                                                                                           | iOS                                                                                               |
| --------------------- | ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| 주 방식 (1차)         | **WorkManager** (클라이언트가 예약 시각에 백그라운드 실행)                                                        | **BGTaskScheduler + Background Fetch** (클라이언트가 예약 시각에 백그라운드 실행)                  |
| 트리거                | 2계층: `registerOneOffTask()` 정확 시각 + `registerPeriodicTask(frequency: 1h)` 안전망 폴링(OEM 배터리 절약 백업 + 화면 켜짐 Doze 해제 piggyback). one-off는 fire 후 내일로 재등록, periodic은 재등록 없이 유지(UPDATE는 initialDelay 무시, REPLACE는 self-cancel). race 방어는 **3선**: (1) 콜백 `lastHeartbeatDate == 오늘` 검사, (2) `lastScheduledKey` = 성공 마커(API 전송 성공 + `lastHeartbeatDate` 저장 후에만 save, 당일 재전송 차단), (3) `HeartbeatLockDatasource.tryAcquire(scheduledKey)` = **SQLite UNIQUE INSERT 기반 cross-isolate 원자 락**. WorkManager 워커마다 새 isolate가 생성되어 SharedPreferences의 `reload→check→save`는 CAS가 아니지만, SQLite `UNIQUE`는 Android WAL로 cross-isolate writer를 직렬화해 하나만 성공시킨다. TTL 30초 초과 stale 락은 `tryAcquire` 진입 시 동일 트랜잭션에서 일괄 청소되어 crashed isolate가 남긴 락을 새 진입자가 이어받는다. | `registerProcessingTask()` → BGProcessingTask (earliestBeginDate 존중). ⚠️ `registerOneOffTask()`는 iOS에서 `beginBackgroundTask`를 사용하여 즉시 실행되므로 사용 금지 (flutter_workmanager PR #511) |
| 백그라운드 실행       | `workmanager` 패키지 콜백 (top-level function)                                                                    | `workmanager` 패키지 콜백 (top-level function)                                                    |
| UI 표시               | 없음 (사용자 인지 불가)                                                                                           | 없음 (사용자 인지 불가)                                                                           |
| 보조 방식 (2차)       | **앱 열기/복귀 자동 전송** — 예약 시각 경과 + 당일 미전송 시 heartbeat 즉시 전송                                   | **앱 열기/복귀 자동 전송** — 예약 시각 경과 + 당일 미전송 시 heartbeat 즉시 전송                    |
| 안전망 (3차)          | **periodic 1시간 폴링** (WorkManager)이 1차 one-off 누락 시 최대 1시간 내 백업 발화. 최종적으로 앱 열기 자동 전송(2차)이 보완 | **오늘의 안부 확인 메시지 로컬 알림** (heartbeat 예약 시각, 매일 반복) — BGTask 실패 시 사용자에게 앱 실행 유도  |
| 앱 강제 종료 시       | WorkManager는 OS가 재스케줄링하므로 **정상 동작** (단, 정확한 시각 보장 불가)                                      | BGTask 미실행 → 오늘의 안부 확인 메시지 로컬 알림으로 사용자 유도                                            |
| 앱 포그라운드 진입 시 | 예약 시각 경과 + 당일 미전송 시 heartbeat 즉시 전송                                                                | 예약 시각 경과 + 당일 미전송 시 heartbeat 즉시 전송                                                |


#### Heartbeat 시각 설정

**기본값:** 오후 18:00 (기기 로컬 시간대 기준, 모든 국가 공통)

| 항목                    | 값                                                                               |
| ----------------------- | -------------------------------------------------------------------------------- |
| 기본 heartbeat 시각     | **18:00** (로컬 시간대)                                                          |
| 로컬 안전망 알림 시각   | **18:30** (heartbeat 시각 + 30분)                                                |
| 설정 변경               | 대상자 본인만 변경 가능                                                          |
| 변경 반영               | 서버에 저장 → 클라이언트 WorkManager/BGTask + 로컬 알림 재예약                   |

**시각 결정 근거:**
- 오후 18:00: 하루 활동이 누적된 퇴근/저녁 시간대이므로 `steps_delta > 0`이 거의 보장되어 걸음수 기반 정상 판정이 안정적
- 이상 발견 시(18:30~, 경고 20:00~) 야간 발송 제한(22:00~09:00) 이전이라 보호자가 **당일 저녁에 대응 가능**
- 국가/지역별 차이는 최대 1시간 이내이므로 단일 기본값으로 통일

**기기 등록 시 서버 전달:**
```json
POST /api/v1/devices
{
  "device_id": "기기 고유 ID (Android: SSAID, iOS: identifierForVendor)",
  "fcm_token": "...",
  "os_type": "android",
  "timezone": "Asia/Seoul",
  "heartbeat_hour": 18,
  "heartbeat_minute": 0
}
```

**보호 대상자가 시간 변경 시:**
```json
PATCH /api/v1/devices/{device_id}/heartbeat-schedule
{
  "heartbeat_hour": 8,
  "heartbeat_minute": 0
}
```
- 보호 대상자가 직접 변경: 서버에 반영 + WorkManager/BGTask 재예약 + iOS 로컬 알림 시각 갱신
- 보호자는 heartbeat 시각을 변경할 수 없음 (대상자 본인만 변경 가능)


#### 주 방식: WorkManager(Android) / BGTaskScheduler(iOS) 예약 실행

**채택 배경:**
- 기존 서버 Silent Push 방식은 앱 강제 종료 시 FCM 미전달로 heartbeat가 누락되는 문제가 있었음
- WorkManager(Android)는 앱 강제 종료 후에도 OS가 재스케줄링하므로 **Silent Push보다 안정적**
- BGTaskScheduler(iOS)는 정확한 시각 보장이 안 되지만, 앱 열기 자동 전송 + 오늘의 안부 확인 메시지 로컬 알림와 조합하면 충분한 신뢰성 확보
- 서버 의존도를 줄여 **오프라인 상황에서도 클라이언트 자체적으로 heartbeat 시도** 가능

**3계층 Heartbeat 실행 구조:**

| 계층 | 방식 | 실행 조건 | 특성 |
|------|------|-----------|------|
| 1차 (정확) | WorkManager `registerOneOffTask` (Android) | 예약 시각 정각 도래 | 정확한 발화. 전송 성공 후 `rescheduleOneOffForNextDay()`로 내일 예약시각에 재등록. iOS는 사용하지 않음 |
| 1차 (폴링 안전망) | WorkManager `registerPeriodicTask(frequency: 1h)` (Android) | 매 1시간 | one-off가 OEM 배터리 절약/Doze로 지연·미실행되어도 최대 1시간 내 백업 발화 + 화면 켜짐 Doze 해제 piggyback. fire 후 재등록하지 않고 유지(UPDATE/REPLACE 모두 이슈 있음). 당일 중복 전송은 `lastScheduledKey`(성공 마커) + `HeartbeatLockDatasource`(SQLite UNIQUE CAS, TTL 30초)로 차단 |
| 2차 | 앱 열기/복귀 자동 전송 | 예약 시각 경과 + 당일 미전송 | 포그라운드 진입 시 즉시 전송. 1차 2계층 모두 실패 시 최종 안전망 |
| 3차 (iOS) | 로컬 알림 오늘의 안부 확인 메시지 로컬 알림 | heartbeat 시각 + 30분 (매일 반복, iOS 전용) | BGTask 미사용이므로 iOS는 이것이 1차. 사용자가 알림을 탭하면 앱이 열리며 `onInit`/`onResumed`에서 자동 전송. Android는 오늘의 안부 확인 메시지 로컬 알림 없음 |

```
[1차: WorkManager/BGTaskScheduler — 백그라운드 실행]
    │
    ├─ Android (2계층):
    │   ├─ registerOneOffTask() — initialDelay로 정확한 시각 지정 (정확 발화)
    │   └─ registerPeriodicTask(frequency: 1h) — 안전망 폴링 (최대 1시간 내 백업)
    │       ※ one-off: fire 후 내일 예약시각으로 재등록 (rescheduleOneOffForNextDay)
    │       ※ periodic: fire 후 재등록 없이 그대로 유지
    │          (UPDATE는 initialDelay 무시, REPLACE는 self-cancel 이슈)
    │       ※ 두 계층이 거의 동시에 fire되는 race는 3선 방어로 차단:
    │          (1) 콜백 진입 시 lastHeartbeatDate == 오늘 검사 (콜백 레벨 1차 거름)
    │          (2) HeartbeatService._executeInternal:
    │              · lastScheduledKey(성공 마커) 검사 — 이미 성공한 스케줄이면 스킵
    │              · HeartbeatLockDatasource.tryAcquire(scheduledKey)
    │                — SQLite UNIQUE INSERT 기반 cross-isolate 원자 락.
    │                  WorkManager 워커마다 새 isolate라 SharedPreferences는 CAS가
    │                  아니지만, SQLite UNIQUE는 Android WAL로 writer를 직렬화해
    │                  하나만 INSERT 성공, 나머지는 UniqueConstraintError로 즉시 실패.
    │                  finally에서 release() 호출.
    │              · TTL 30초 초과 stale 락은 tryAcquire 진입 시 동일 트랜잭션에서
    │                일괄 청소 → crashed isolate가 남긴 락을 새 진입자가 이어받음
    │
    ├─ iOS:
    │   ├─ registerProcessingTask() — BGProcessingTask (earliestBeginDate 존중)
    │   │   ⚠️ registerOneOffTask()는 iOS에서 beginBackgroundTask를 사용하여
    │   │      initialDelay를 무시하고 즉시 실행되므로 사용 금지
    │   │      (flutter_workmanager PR #511 참고)
    │   └─ AppDelegate에서 registerBGProcessingTask(withIdentifier:) 등록 필수
    │
    ├─ 콜백 (Android/iOS 공통):
    │   ├─ 당일 이미 전송 여부 확인 (lastHeartbeatDate) → 중복 전송 방지
    │   ├─ 예약 시각 이전이면 스킵 (Android periodic 폴링이 예약시각 전에 fire될 때)
    │   ├─ 미전송 시 → heartbeat 전송 (센서 + API)
    │   └─ Android: one-off만 내일 예약시각으로 재등록 (periodic은 그대로 유지)
    │      iOS: registerProcessingTask 재등록
    └─ 실행 후 자동 종료

[2차: 앱 열기/복귀 자동 전송]
    │
    ├─ 앱 포그라운드 진입 시 서버에서 스케줄 동기화 (/devices/me)
    ├─ stale lastScheduledKey 정리 — `isReportedToday=false`인데 오늘 날짜의
    │  lastScheduledKey가 남아 있으면 제거 (`_clearStaleScheduledKey`, 커밋 4260e53).
    │  Worker가 중도 종료되어 남긴 ghost 성공 마커가 2차 안전망을 차단하지 않도록 하는
    │  전환기 방어선. SubjectHome / GuardianSafetyCode 진입 시 모두 수행.
    ├─ 현재 시각 ≥ 예약 시각 AND 당일 미전송 → heartbeat 즉시 전송
    └─ WorkManager/BGTask 재예약 (다음 날)

[3차 (iOS 전용): 로컬 알림 오늘의 안부 확인 메시지 로컬 알림 — 1차·2차 모두 실패 시]
    │
    ├─ heartbeat 시각 + 30분에 매일 반복 로컬 알림 (iOS 전용)
    │   ┌──────────────────────────────────────┐
    │   │ 📱 안부 확인이 필요합니다              │
    │   │                                      │
    │   │ 이 메시지 알림을 한 번 터치해 주세요.   │
    │   └──────────────────────────────────────┘
    │   ※ 기본: heartbeat 18:00 → 오늘의 안부 확인 메시지 로컬 알림 18:30
    │   ※ Android는 오늘의 안부 확인 메시지 로컬 알림 없이 WorkManager periodic 1시간 폴링과 포그라운드 복귀 자동 전송(2차)이 안전망 역할을 한다
    │
    │   [iOS 로컬 알림 예약 정책 — isReportedToday 기반 1회성/매일반복 분기]
    │   matchDateTimeComponents.time을 사용하면 iOS는 날짜를 무시하고 다음 HH:mm만 찾아 발화한다.
    │   heartbeat 전송 후 같은 날 예약시각에 알림이 또 트리거되는 버그를 방지하기 위해:
    │   · forceNextDay=true (오늘 이미 전송 완료) + 오늘 예약시각 아직 안 지남
    │     → matchDateTimeComponents 없이 내일 날짜+시각을 정확히 지정하는 1회성 알림
    │       (iOS가 오늘 날짜를 선택하는 것을 차단)
    │   · 그 외 (오늘 예약시각이 이미 지났거나 forceNextDay=false인 정상 경우)
    │     → matchDateTimeComponents.time으로 매일 반복 알림
    │   forceNextDay 결정 기준: isReportedToday = (lastHeartbeatDate == 오늘 날짜)
    │
    └─ 사용자가 알림 탭 → 앱 실행 → 2차 로직에 의해 heartbeat 전송

[정상 동작 시]
    매일 18:00 WorkManager/BGTask 실행 → heartbeat 성공 → 예약시각 매일 재예약
    → 오늘의 안부 확인 메시지 로컬 알림(18:30)이 실제로 표시될 일 없음

[비정상 시 (BGTask 미실행, 앱 미사용) — iOS]
    당일 18:30 → 오늘의 안부 확인 메시지 로컬 알림 표시
    → 사용자가 알림 탭 → 앱 실행 → heartbeat 즉시 전송
    → 무시 시 매일 같은 시각에 계속 반복
```

**최초 설치 시 즉시 예약:**
- 보호 대상자 모드 선택 → 서버 등록 완료 시점에:
  1. WorkManager/BGTask 예약 (다음 heartbeat 시각)
  2. iOS: 오늘의 안부 확인 메시지 로컬 알림 등록 (heartbeat 시각 + 30분, repeats: true)
  3. 첫 heartbeat 즉시 전송

```
[보호 대상자 모드 최초 등록 시]
    │
    ├─ 서버 등록 완료 → 첫 heartbeat 전송
    ├─ WorkManager/BGTask 예약 (다음 날 18:00)
    ├─ iOS: 오늘의 안부 확인 메시지 로컬 알림 (매일 반복) 등록 (기본 18:30, repeats: true)
    └─ 이후부터 heartbeat 성공 시마다 알림 취소+재등록 반복
```

**한계 및 대응:**
- **iOS BGProcessingTask 미실행**: iOS가 실행 시점을 OS 재량으로 결정 → 2차(앱 열기) + 3차(오늘의 안부 확인 메시지 로컬 알림)로 보완. iOS에서는 periodic 태스크(BGAppRefreshTask) 미사용
- **Android Doze/OEM 절전 모드**: 스와이프 종료 + 화면 꺼짐 상태에서 one-off 태스크가 지연/미실행될 수 있음. periodic 1시간 폴링이 최대 1시간 내 백업 발화로 대부분 복구하며, 그래도 실패 시 앱 열기 자동 전송(2차)이 최종 안전망. Splash의 "배터리 제한없음" 안내 다이얼로그(9.0.1)가 예방책
- 사용자가 알림을 무시하면 앱이 열리지 않음 → 서버가 미수신 감지 → 보호자에게 경고 발송
- iOS: 사용자가 알림 권한을 거부하면 3차 안전망(오늘의 안부 확인 메시지 로컬 알림) 동작 안 함 → 모드 선택 후 권한 요청 안내 화면(9.0)에서 중요성 안내
- 알림 권한은 이 앱의 핵심 기능(보호자 경고 Push 수신)에도 필수이므로, 별도 권한 추가 부담 없음


### 2.3 활동 지표

**주 지표: heartbeat 수신 여부**
- 서버가 heartbeat를 수신했다는 것 자체가 **폰이 정상 동작 중**이라는 증거
- 지정 시각 + 2시간 내 heartbeat 미수신 → 경고 발생 (기본: 18:00 미수신 → 20:00 "주의" -> 2번째 "경고" -> 3번이상 "긴급")

**활동 지표: 걸음수(steps_delta) 단일 판정**

heartbeat가 정상 수신되더라도 사용자가 실제로 활동 중인지를 추가 판별한다.
(백그라운드에서 heartbeat가 자동 전송되므로, 사용자가 의식불명 상태여도 heartbeat는 수신될 수 있음)

```
[heartbeat 실행 시]
    │
    └─ 걸음수 확인 (pedometer_2 패키지)
        · **오늘 자정 ~ 현재 시각** 누적 걸음수(steps_delta) 조회
        · steps_delta > 0   → suspicious = false (활동 확인)
        · steps_delta == 0 또는 null → suspicious = true (활동 의심)
        · manual = true (수동 보고)  → suspicious = false (항상)
```

> **가속도/자이로/지자기 센서를 사용하지 않는 이유:**
> Android 9+ 공식 제한(Behavior changes: Android 9)에 따라, 연속 리포팅 모드 센서(가속도계·자이로스코프·지자기)는 백그라운드 앱에서 이벤트를 수신할 수 없다. WorkManager 워커는 백그라운드 컨텍스트에서 실행되므로 이 세 센서는 항상 null을 반환한다. 반면 걸음수(TYPE_STEP_COUNTER)는 하드웨어 FIFO 배칭 방식이라 백그라운드 제한을 받지 않으며 워커에서도 정상 수집된다. 따라서 백그라운드 suspicious 판정에서 유일하게 신뢰할 수 있는 지표는 걸음수뿐이며, sensors_plus 패키지는 제거됐다.

**의심 상태(suspicious) 발생 시 서버 동작:**
- suspicious 플래그를 서버에 기록
- suspicious = true, 1회 "주의" → 2번째 "경고" → 3번이상 "긴급" 순서로 보호자에게 알림 발송
- 보호자가 판단하여 직접 확인하도록 유도
- 서버의 다일 에스컬레이션 필터(caution→warning→urgent, 며칠에 걸쳐 상향)가 일시적 보행 없음(누워있기, 외출 안 함)으로 인한 false positive를 자연스럽게 흡수

**권한 (Lazy Permission — 걸음수 전송이 실제로 필요한 시점에만 요청):**
- **요청 시점 분기**:
  - Android 대상자 모드 / Android G+S 복원(`isAlsoSubject=true`) → 최초 권한 요청 화면(§9.0)에서 요청
  - Android 순수 보호자 → heartbeat 전송이 없으므로 권한 요청 없음
  - iOS (보호자 전용) → 최초 권한 요청 화면에서 **요청하지 않음**. G+S 활성화 다이얼로그(§9.7)에서 CMPedometer 호출로 시스템 팝업 유발
- Android: `ACTIVITY_RECOGNITION` 런타임 권한 — `Permission.activityRecognition.request()` 호출 시 시스템 팝업 표시
- iOS: `NSMotionUsageDescription` Info.plist 등록 필수. **iOS는 `Permission.activityRecognition.request()` 호출만으로는 시스템 팝업이 뜨지 않고**, CMPedometer/CMMotionActivityManager 데이터를 실제로 조회하는 시점에만 최초 1회 팝업이 표시됨. 따라서 G+S 활성화 시 `Pedometer.stepCountStream.first.timeout(3s)`를 호출해 CMPedometer를 유발 → 시스템 팝업 표시
- OS 시스템 권한 팝업 문구는 `ios/Runner/{lang}.lproj/InfoPlist.strings` 20개 언어에 각각 등록되어 기기 locale에 맞춰 자동 번역 표시
- 권한 거부 시: G+S 활성화 자체는 계속 진행하되, 안전코드 화면에 "걸음수 권한 거부" 경고 텍스트 상시 노출 — 탭하면 권한 재요청 (§9.7)


### 2.4 진입점 분기

앱은 **세 가지 진입점**에 따라 다르게 동작한다:

| 진입점                                           | 동작                                             | UI 표시   |
| ------------------------------------------------ | ------------------------------------------------ | --------- |
| 사용자가 앱 아이콘 터치                          | `main()` → 전체 UI 렌더링 + 예약 시각 경과 시 heartbeat 자동 전송 | 전체 화면 |
| WorkManager/BGTask (매일 예약 시각)              | 걸음수(steps_delta) 조회 → suspicious 판정 → heartbeat 전송 → 다음날부터 해당 시각 매일 재예약(전송당일 예약x) | 없음      |
| 오늘의 안부 확인 메시지 로컬 알림 터치 (iOS 대상자)        | `main()` → 앱 포그라운드 전환만 (알림 자체에서 heartbeat 전송 안 함) → 홈 화면 `onInit`/`onResumed`에서 예약시각 경과 + 미전송 시 자동 전송 | 전체 화면 |
| 일반 Push 알림 터치 (보호자)                     | `main()` → 대상자 상태 화면으로 이동             | 전체 화면 |

```dart
// WorkManager 백그라운드 진입점 (UI 없이 실행)
@pragma('vm:entry-point')
void heartbeatWorkerCallback() {
  Workmanager().executeTask((taskName, inputData) async {
    // 0. 역할 확인 (대상자 모드만 실행)
    // 1. 당일 이미 전송 여부 확인 (lastHeartbeatDate)
    // 2. 미전송 시 → heartbeat 전송 (센서 + API)
    // 3. 다음 날 동일 시각으로 재예약
    return true;
  });
}

// 공통 heartbeat 전송 로직 (Android/iOS 동일 Dart 코드)
Future<void> sendHeartbeat({bool manual = false}) async {
  // 1. 걸음수 조회 → suspicious 판정
  final stepsDelta = await getStepsDelta();  // 오늘 자정 ~ 현재 누적 (권한 거부 시 null)
  final suspicious = manual ? false : (stepsDelta == null || stepsDelta == 0);

  // 2. heartbeat 데이터 구성 → 서버 전송
  // (가속도/자이로 센서는 Android 9+ 백그라운드 제한으로 WorkManager에서 항상 null → 미사용)
}
```


### 2.5 FCM Push 구분

서버는 heartbeat 트리거 Silent Push를 발송하지 않는다. FCM은 보호자 경고 알림에만 사용한다.

```json
// 일반 Push - 보호자 경고용 (보호자 기기에 표시)
{
  "aps": {
    "alert": {
      "title": "안부 확인",
      "body": "보호 대상자의 오늘 안부 확인이 없습니다."
    },
    "sound": "default"
  },
  "type": "alert_guardian"
}

// 일반 Push - 정상 복귀 알림 (보호자 기기에 표시)
{
  "aps": {
    "alert": { "title": "안부 확인", "body": "보호 대상자의 안부 확인이 정상 복귀되었습니다." },
    "sound": "default"
  },
  "type": "alert_resolved"
}
```


### 2.5.1 알림 탭 라우팅 (보호자 모드)

알림을 탭했을 때 앱 상태(포그라운드/백그라운드/종료)에 따라 처리 경로가 다르다.

**앱 상태별 처리 경로:**

| 앱 상태 | iOS 처리 경로 | Android 처리 경로 |
|---------|--------------|-------------------|
| 포그라운드 (앱 활성) | AppDelegate `didReceive` → MethodChannel `onNotificationTap` → Dart `_handleNotificationTap` | `flutter_local_notifications` `onDidReceiveNotificationResponse` → `_handleNotificationTap` |
| 백그라운드 (앱 일시정지) | AppDelegate `didReceive` → `super` 호출 → `FirebaseMessaging.onMessageOpenedApp` → Dart `_handleMessageOpenedApp` | `FirebaseMessaging.onMessageOpenedApp` → `_handleMessageOpenedApp` |
| 종료 (스와이프 종료) | AppDelegate `didReceive` → `super` 호출 → `FirebaseMessaging.getInitialMessage()` → Dart `_handleMessageOpenedApp` | `FirebaseMessaging.getInitialMessage()` → `_handleMessageOpenedApp` |

**iOS 포그라운드 알림 수신 시 추가 동작:**
- AppDelegate `willPresent` → MethodChannel `onForegroundMessage` → `GuardianSubjectService.refresh()` (대시보드 카드 갱신)
- Android는 `FirebaseMessaging.onMessage` → `_handleForegroundMessage` → `_refreshSubjectsIfNeeded()` 로 동일 동작

**페이로드 `type`별 라우팅 대상:**

| 서버 Push `type` | 라우팅 대상 | 설명 |
|------------------|------------|------|
| `alert_caution` | 알림 목록 (`guardianNotifications`) | 주의 등급 |
| `alert_warning` | 알림 목록 | 경고 등급 |
| `alert_urgent` | 알림 목록 | 긴급 등급 |
| `alert_emergency` | 알림 목록 | 긴급 도움 요청 |
| `alert_info` | 알림 목록 | 정보 등급 (배터리 부족 등) |
| `alert_resolved` | 알림 목록 | 경고 해소 |
| `alert_cleared` | 알림 목록 | 보호자 경고 클리어 |
| `auto_report` | 알림 목록 | 자동 안부 확인 완료 |
| `manual_report` | 알림 목록 | 수동 안부 확인 |
| `heartbeat` | 무시 (라우팅 없음) | 대상자 전용 |
| `subscription_expired` | 대시보드 (기본 홈) | 별도 라우팅 불필요 |
| 기타 / 없음 | 대시보드 (기본 홈) | 앱 포그라운드 전환만 |

**로컬 알림 페이로드:**

| 로컬 알림 | payload | 라우팅 | 비고 |
|-----------|---------|--------|------|
| FCM 포그라운드 알림 (Android/iOS) | `message.data['type']` | 위 테이블과 동일 | `flutter_local_notifications`로 표시 후 탭 시 라우팅 |
| 오늘의 안부 확인 메시지 로컬 알림 (iOS 대상자 전용) | `heartbeat` | 무시 → 홈 화면 자동 전송 | 알림 탭 → 앱 포그라운드 전환만, `onInit`/`onResumed`에서 heartbeat 자동 전송 |

```
[알림 탭 라우팅 흐름]

    알림 탭
        │
        ├─ iOS 포그라운드
        │   AppDelegate.didReceive (applicationState == .active)
        │   → MethodChannel "onNotificationTap" (type 전달)
        │   → fcm_service._handleNotificationTap(type)
        │
        ├─ iOS 백그라운드 / 종료
        │   AppDelegate.didReceive → super 호출
        │   → firebase_messaging 플러그인이 페이로드 캐시
        │   → onMessageOpenedApp (백그라운드) / getInitialMessage (종료)
        │   → fcm_service._handleMessageOpenedApp(message)
        │
        └─ Android (모든 상태)
            ├─ FCM Push 탭: onMessageOpenedApp / getInitialMessage
            └─ 로컬 알림 탭: onDidReceiveNotificationResponse → payload로 라우팅
```


### 2.6 경고 발생 흐름

```
[기본 heartbeat 시각 18:00 기준 예시]

Day 0, 18:00: heartbeat 정상 수신 → 안부 확인됨
Day 1, 18:00: heartbeat 미수신
Day 1, 20:00: 서버 확인 (18:00 + 2시간) →  "주의" (보호자에게 Push 알림)
Day 2, 18:00: heartbeat 미수신
Day 2, 20:00: "경고" (보호자에게 Push 알림)
Day 3, 20:00: "긴급" (보호자에게 Push 알림)
Day 4, 20:00: "긴급" (보호자에게 Push 알림)
Day 5, 20:00: "긴급" (보호자에게 Push 알림)
Day 6, 20:00: "긴급" (보호자에게 Push 알림)
Day 7, 20:00: "긴급" (보호자에게 Push 알림)
Day 8+: 추가 알림 없음 (향후 정책 변경 가능)

[보호자가 주의,경고,긴급 클리어 시]
경고 상태 → cleared (miss_count 리셋)
이후 heartbeat가 여전히 없으면 → 다음 날 같은 시각에 1차 "주의"부터 재시작
```

**경고 판정 기준:**
- 서버는 각 기기의 `heartbeat_hour`를 알고 있으므로, **지정 시각 + 2시간** 경과 후 미수신이면 즉시 주의,경고,긴급 판정
- 기존 "24시간 경과 여부"를 매 1시간 폴링하는 방식 대비, **감지 속도가 대폭 단축** (최대 24시간 → 2시간)
- 주의,경고,긴급 알림은 heartbeat 시각 + 2시간에 발송되므로, 기본값(18:00) 기준 **20:00에 보호자 알림** → 보호자가 당일 저녁에 대응 가능
- 별도 시간대 제한 불필요 (heartbeat 시각 자체가 보호자 변경 가능한 활동 시간대이므로)


### 2.7 엣지 케이스 및 대응

| 상황                              | 대응                                                                                                                                                                                                                                                                                                       |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| iOS 앱 스와이프 강제 종료         | BGTask 미실행 → 오늘의 안부 확인 메시지 로컬 알림(18:30)으로 사용자에게 앱 실행 유도 → 무시 시 서버가 미수신 감지 → 보호자에게 경고                                                                                            
| 네트워크 장시간 불가 (Android)    | WorkManager 실행 → 네트워크 없음 감지 → 로컬 큐에 적재 + 대상자 폰에 로컬 알림 표시 ("인터넷 연결이 꺼져 있습니다") + 복구 시 일괄 전송 → 서버가 경고 자동 해소                                                                                                                                            |
| 네트워크 장시간 불가 (iOS)        | BGTask 실행 실패 또는 네트워크 없음 → heartbeat 시각 + 30분 후 **오늘의 안부 확인 메시지 로컬 알림** 표시 ("안부 확인이 필요합니다. 이 알림을 터치 해주세요") → 사용자가 알림 탭 → 앱 실행 → 네트워크 복구 시 heartbeat 전송 → 서버가 경고 자동 해소. 알림 무시 시 매일 반복 + 서버 경고 플로우로 전환                          |
| 기기 재부팅 (Android)             | WorkManager는 OS가 자동 복구 — 별도 재등록 불필요. 재부팅 후에도 예약된 작업이 정상 실행됨                                                                                                                                                                                                                 |
| 다중 기기 사용                    | device_id별 독립 추적, 어느 기기라도 사용하면 alive                                                                                                                                                                                                                                                        |
| 구독 만료 (보호자)                | 보호자 앱 실행 시 결제 페이지 전환 → 대상자 heartbeat는 계속 수신하되 경고 알림 발송 중단                                                                                                                                                               
| 대상자 앱 재설치                  | device_id로 기존 계정 자동 복원 → 기존 고유 코드 유지, device_token만 재발급 → 보호자 재연결 불필요                                                                                                                                                                                                          |
| 보호자 앱 재설치                  | device_id로 기존 계정 자동 복원 → 기존 구독·대상자 연결 유지, device_token만 재발급 → 대상자 재연결 불필요 (로컬 별칭만 재설정 필요)                                                                                                                                                                          |
| 보호자 미연결 30일 경과           | 서버가 대상자 데이터 자동 삭제 → 앱 실행 시 401 → 모드 선택 화면으로 이동 → 재등록                                                                                                                                                                                                                         |


---


## 3. 오탐 방지 및 감지 정확도 향상

> 📊 **플로우차트**: [heartbeat_flowchart.md](heartbeat_flowchart.md) 참조
> - 차트 1: 배터리 부족 알림, 네트워크 끊김 처리 플로우
> - 차트 5: 경고 등급 요약 (정보/주의/경고/긴급)


### 3.1 개요

제로 인터랙션 설계의 핵심 과제는 **오탐(false alarm) 최소화**와 **위험 감지 속도 향상**이다.
아래 보완 설계를 통해 단순 heartbeat 미수신 판정을 넘어, 복합 지표 기반의 정밀한 생존 판단을 구현한다.

**heartbeat 전송 데이터:**
```json
{
  "device_id": "기기 고유 ID (Android: SSAID, iOS: identifierForVendor)",
  "timestamp": "2026-03-18T18:00:00+09:00",
  "steps_delta": 342,
  "suspicious": false,
  "battery_level": 85
}
```
- `steps_delta`:
  - 자동/수동 공통 → **오늘 자정 ~ 현재 시각** 누적 걸음수 (권한 허용 시), 거부 시 null
  - 활동 정보 알림 중복 방지는 **서버 가드** 담당 (`manual=false AND steps_delta is not None AND steps_delta > 0`일 때만 생성). 클라이언트는 수동 보고에서도 실제 걸음수를 실어 보내고, 보호자 대시보드의 일별 걸음수 이력(`heartbeat_logs`) 정확도를 확보한다.
- `suspicious`: 앱에서 판정 후 전송 (steps_delta > 0이면 항상 false, 수동 보고는 항상 false)

**필요 패키지:** `pedometer_2` (걸음수, iOS `queryPedometerData` + Android Google Fit Local Recording API 통합), `battery_plus` (배터리 잔량, 권한 불필요)


### 3.2 배터리 방전 오탐 방지

**문제:** 고령자가 충전을 잊어 폰 배터리 방전 → heartbeat 미전송 → 불필요한 경고 발생
**핵심:** 배터리 방전은 예측 가능한 이벤트이므로, 사전 알림으로 경고를 예방한다

```
[heartbeat 전송 시 배터리 잔량 확인]
    │
    ├─ battery_level > 20%
    │   → 정상 (추가 동작 없음)
    │
    ├─ battery_level ≤ 20%
    │   │
    │   ├─ 대상자 폰: 로컬 알림 표시
    │   │   ┌──────────────────────────────────────┐
    │   │   │ 📱 충전이 필요합니다                    │
    │   │   │                                      │
    │   │   │ 배터리가 부족합니다.                    │
    │   │   │ 충전하지 않으면 안부 확인이              │
    │   │   │ 중단될 수 있습니다.                    │
    │   │   └──────────────────────────────────────┘
    │   │
    │   └─ battery_level < 20%
    │       │
    │       └─ heartbeat에 battery_level 포함하여 서버 전송
    │           → 서버: 기존 info 경고 없으면 보호자에게 정보 등급 Push 1회 발송
    │           ┌──────────────────────────────────────┐
    │           │ 🔋 폰 배터리 부족                    │
    │           │                                      │
    │           │ [삼촌]의 폰 배터리가 20% 미만입니다.  │
    │           │ 충전이 필요할 수 있습니다.              │
    │           └──────────────────────────────────────┘

※ 배터리 정보 등급은 1회 발송 후 종료. 이후 미수신이 지속되어도 상향 없음
※ heartbeat 수신 시 배터리 info 경고 자동 해소
※ 배터리 충분(>20%)한 상태에서 heartbeat 끊김 → 누적 미수신 기반 경고 플로우 진행
```


### 3.3 suspicious 판정 (걸음수 단일 판정)

**핵심:** 걸음수(steps_delta) 하나로 판정. 오늘 자정부터 현재까지 1보라도 걸었으면 정상.

> **가속도/자이로/지자기를 사용하지 않는 이유:**
> Android 9+ 공식 제한에 따라 연속 리포팅 모드 센서(가속도계·자이로스코프·지자기)는 백그라운드 앱에서 이벤트를 수신할 수 없다. WorkManager 워커는 백그라운드 컨텍스트이므로 이 세 센서는 항상 null. 반면 걸음수(TYPE_STEP_COUNTER)는 하드웨어 FIFO 배칭 방식이라 워커에서도 정상 수집된다. 따라서 sensors_plus 패키지는 제거됐다.

```
[heartbeat 수집 시 활동 판정]

    steps_delta > 0      → suspicious = false (활동 확인)
    steps_delta == 0 또는 null → suspicious = true (활동 의심)
    manual = true        → suspicious = false (수동 보고는 항상 정상)

    ※ 걸음수 권한 거부 시 steps_delta = null → suspicious = true
    ※ 서버의 다일 에스컬레이션 (caution→warning→urgent)이 false positive 흡수

[서버 판정]
    suspicious = false → 활성 경고 해소 여부 확인
                         ├─ 활성 경고 있었음 → 완전 해소 + 보호자 Push "정상 복귀" (정보 등급 DND 적용)
                         └─ 활성 경고 없었음
                             ├─ manual = true  → 보호자 Push "수동 안부 확인" (정보 등급 DND 적용)
                             └─ manual = false → 보호자 Push "오늘 안부 확인 완료" (정보 등급 DND 적용)
    suspicious = true  → warning/urgent → caution 하향 (정상 복귀 알림 없음)
                         → suspicious_count 기반 보호자 경고 에스컬레이션:
                           - suspicious_count=1 → 주의(caution) 등급 생성 + 보호자 Push + notification_event 저장
                           - suspicious_count=2 → 경고(warning) 등급 생성 + 보호자 Push + notification_event 저장
                           - suspicious_count≥3 → 긴급(urgent) 등급 생성 + 보호자 Push + notification_event 저장 (매일 반복)
                           - 보호자 경고 클리어 시 suspicious_count 리셋 → 다음 suspicious부터 1차 재시작
```


### 3.4 경고 등급 최종 확정 테이블

**경고 등급 체계 (4단계):**

| 등급 | 조건 | 발송 |
|------|------|------|
| 🚨 긴급 | 미수신 3회+ OR suspicious 3회+ | 매일 5회까지 반복 |
| ⚠ 경고 | 미수신 2회 OR suspicious 2회 | 1~2회 다음날 재발송 |
| ⚠ 주의 | 미수신 1회 OR suspicious 1회 | 1회 발송 |
| 🔵 정보 | 배터리 < 20% / 자동 heartbeat 정상 수신 / 정상복귀 / 수동 heartbeat | DND 적용 (시간 외 소리, 시간 내 조용) |

```
[경고 등급별 발송 흐름]

    heartbeat 미수신 발생
        │
        ├─ battery_level < 20%?
        │   ├─ YES → 정보 등급 1회 발송 후 종료 (이후 상향 없음)
        │   │        heartbeat 수신 시 자동 해소
        │   │
        │   └─ NO → 누적 미수신 횟수 기반 판정:
        │       ├─ 활성 경고 없음 → 주의 등급 (1회)
        │       ├─ 주의 활성     → 경고 등급
        │       ├─ 경고 활성     → 긴급 등급
        │       └─ 긴급 활성     → 긴급 반복 (매일)

    heartbeat 수신 (suspicious = false)
        ├─ 활성 경고 있었음 → 완전 해소 + 보호자 Push "정상 복귀" (정보 등급 DND 적용)
        └─ 활성 경고 없었음
            ├─ manual = true  → 보호자 Push "수동 안부 확인" (정보 등급 DND 적용)
            └─ manual = false → 보호자 Push "오늘 안부 확인 완료" (정보 등급 DND 적용)

    suspicious 수신 (heartbeat는 수신 중, suspicious_count 기반)
        ├─ 1회 → 주의(caution) 등급
        ├─ 2회 → 경고(warning) 등급
        └─ 3회+ → 긴급(urgent) 등급 (매일 반복)

※ DND(방해금지): 보호자가 시간대 설정 가능 (기본 OFF)
※ 긴급 등급은 DND 무관하게 항상 발송
※ 정보 등급은 DND 시간 내 조용한 알림, 시간 외 소리 알림
```


### 3.5 경고 등급별 알림 디자인

**서버 Push 데이터:**
```json
{
  "data": {
    "type": "alert_warning",
    "alert_level": "warning",
    "subject_user_id": "1"
  }
}
```
- 클라이언트는 `alert_level` 값에 따라 알림 채널, UI 색상, 소리를 분기 처리


**등급별 색상 및 알림 설정:**

```
┌────────┬───────────────────┬─────────────┬──────────────┬───────────────────────────┐
│ 등급   │ 배경색             │ 테두리/강조  │ 아이콘        │ 소리/진동                  │
├────────┼───────────────────┼─────────────┼──────────────┼───────────────────────────┤
│ 정보   │ #E3F2FD (연한 파랑) │ #1565C0     │ 🔋 📱        │ 소리 없음                  │
│ 주의   │ #FFF8E1 (연한 노랑) │ #F9A825     │ ⚠           │ 기본 소리                  │
│ 경고   │ #FFF3E0 (연한 주황) │ #E65100     │ ⚠           │ 기본 소리 + 진동            │
│ 긴급   │ #FFEBEE (연한 빨강) │ #B71C1C     │ 🚨          │ 기본 소리 + 진동 반복       │
└────────┴───────────────────┴─────────────┴──────────────┴───────────────────────────┘
```


**Android Notification Channel 설정:**
```dart
// 앱 초기화 시 4개 채널 미리 생성
const channels = [
  NotificationChannel(
    id: 'alert_info',
    name: '정보 알림',
    importance: Importance.low,         // 소리 없음, 상태바만 표시
  ),
  NotificationChannel(
    id: 'alert_caution',
    name: '주의 알림',
    importance: Importance.defaultImportance,  // 기본 소리
  ),
  NotificationChannel(
    id: 'alert_warning',
    name: '경고 알림',
    importance: Importance.high,        // 헤드업 알림 + 기본 소리 + 진동
  ),
  NotificationChannel(
    id: 'alert_urgent',
    name: '긴급 알림',
    importance: Importance.high,        // 헤드업 알림 + 기본 소리 + 진동 반복
    vibrationPattern: [0, 500, 200, 500, 200, 500],
  ),
];
```

**iOS Notification Category 설정:**
```swift
// AppDelegate에서 카테고리 등록
let infoCategory = UNNotificationCategory(identifier: "ALERT_INFO", actions: [], intentIdentifiers: [])
let cautionCategory = UNNotificationCategory(identifier: "ALERT_CAUTION", actions: [], intentIdentifiers: [])
let warningCategory = UNNotificationCategory(identifier: "ALERT_WARNING", actions: [], intentIdentifiers: [])
let urgentCategory = UNNotificationCategory(identifier: "ALERT_URGENT", actions: [], intentIdentifiers: [])

// 긴급 등급: 일반 알림 (기본 소리 + 진동 반복)
// 무음 모드에서는 소리가 나지 않으나, 진동과 화면 표시로 대응
```

**앱 내 경고 카드 UI (보호자 대시보드):**
```
[정보 등급 카드]
┌─────────────────────────────────────────────┐
│  배경: #E3F2FD                               │
│  ┌──┐                                       │
│  │🔋│  [삼촌] 폰 배터리 부족                │
│  └──┘  폰 배터리가 20% 미만입니다.            │
│        충전이 필요할 수 있습니다.              │
│                              3분 전          │
│  좌측 테두리: #1565C0 (4px)                   │
└─────────────────────────────────────────────┘

[주의 등급 카드]
┌─────────────────────────────────────────────┐
│  배경: #FFF8E1                               │
│  ┌──┐                                       │
│  │⚠│  [삼촌] 폰 미사용 감지                 │
│  └──┘  폰 사용이 48시간째 감지되지 않습니다.   │
│        직접 안부를 확인해 보시기 바랍니다.      │
│                              2시간 전         │
│  좌측 테두리: #F9A825 (4px)                   │
└─────────────────────────────────────────────┘

[경고 등급 카드]
┌─────────────────────────────────────────────┐
│  배경: #FFF3E0                               │
│  ┌──┐                                       │
│  │⚠│  [삼촌] 안부 확인                      │
│  └──┘  안부 확인이 24시간째 없습니다.           │
│        통신 불가 상태일 수 있습니다.            │
│                 [경고 클리어]     1일 전       │
│  좌측 테두리: #E65100 (4px)                   │
└─────────────────────────────────────────────┘

[긴급 등급 카드]
┌─────────────────────────────────────────────┐
│  배경: #FFEBEE                               │
│  전체 테두리: #B71C1C (2px) + 펄스 애니메이션  │
│  ┌──┐                                       │
│  │🚨│  [삼촌] 긴급: 확인 필요                │
│  └──┘  안부 확인이 없으며, 마지막 확인 시        │
│        폰 사용 흔적도 없었습니다.              │
│        즉시 확인이 필요합니다.                 │
│                 [경고 클리어]     방금 전      │
│  좌측 테두리: #B71C1C (4px)                   │
│  카드 상단: "긴급" 뱃지 (#B71C1C, 흰색 텍스트) │
└─────────────────────────────────────────────┘
```

**보호자 대시보드 대상자 상태 표시:**
```
[대상자 목록에서 상태 아이콘 + 배경 변경]

┌─────────────────────────────────────────────┐
│  🟢 삼촌          정상         마지막 확인 2시간 전  │
│  🔵 아버지          정보         🔋 배터리 부족       │
│  🟡 이모            주의         ⚠ 폰 미사용 48h    │
│  🟠 삼촌            경고         ⚠ 안부 확인 없음     │
│  🔴 할머니          긴급         🚨 즉시 확인 필요    │
└─────────────────────────────────────────────┘

상태 아이콘 색상:
  · 정상: #4CAF50 (초록)
  · 정보: #1565C0 (파랑)
  · 주의: #F9A825 (노랑)
  · 경고: #E65100 (주황)
  · 긴급: #B71C1C (빨강) + 펄스 애니메이션
```

**Flutter 구현 핵심:**
```dart
// alert_level에 따른 색상 매핑
enum AlertLevel { info, caution, warning, urgent }

extension AlertLevelStyle on AlertLevel {
  Color get backgroundColor => switch (this) {
    AlertLevel.info    => const Color(0xFFE3F2FD),
    AlertLevel.caution => const Color(0xFFFFF8E1),
    AlertLevel.warning => const Color(0xFFFFF3E0),
    AlertLevel.urgent  => const Color(0xFFFFEBEE),
  };

  Color get accentColor => switch (this) {
    AlertLevel.info    => const Color(0xFF1565C0),
    AlertLevel.caution => const Color(0xFFF9A825),
    AlertLevel.warning => const Color(0xFFE65100),
    AlertLevel.urgent  => const Color(0xFFB71C1C),
  };

  String get channelId => 'alert_${name}';
}

// Push 수신 시 채널 분기
void onMessageReceived(RemoteMessage message) {
  final level = AlertLevel.values.byName(
    message.data['alert_level'] ?? 'info',
  );
  showNotification(
    channelId: level.channelId,
    title: message.notification?.title,
    body: message.notification?.body,
  );
}
```

**알림 소리 정책:**
- 모든 등급에서 **OS 기본 알림 소리**를 사용한다 (커스텀 소리 파일 불필요)
- 경고/긴급 등급은 `Importance.high`로 설정하여 헤드업 알림 + 기본 소리 + 진동으로 주의를 끈다
- 무음 모드에서는 소리가 나지 않으나, 진동과 화면 표시(헤드업 알림)로 대응


### 3.6 보호자 알림 저장 및 조회 정책

**설계 원칙:** 당일 알림은 서버 DB에 저장하고 API로 조회한다. 로컬 sqflite 저장 없음.

**역할 분리:**
| 저장소 | 데이터 | 유지 기간 |
|--------|--------|-----------|
| 서버 `alerts` | `active` 상태 경고만 | 경고 해소(cleared) 시 삭제 |
| 서버 `notification_events` | 당일 발생한 대상자별 알림 이벤트 | 당일 — 대상자 기기 타임존 자정 일괄 삭제 |

**알림 종류:**
| alert_level | Push 발송 | DB 저장 | 내용 |
|-------------|-----------|---------|------|
| info | ✅ (DND 적용) | ✅ | 자동 안부 완료, 수동 안부, 정상 복귀, 배터리 부족 |
| health (활동 정보) | ❌ | ✅ | 활동 정보 알림 — 오늘 자정~현재 누적 걸음수 표시 ("오늘 N보를 걸으셨습니다"). 서버 가드: `manual=false AND steps_delta > 0`일 때만 생성하여 수동 보고 시 중복 알림을 차단 |
| caution | ✅ | ✅ | 미수신 or suspicious = true 1회 |
| warning | ✅ | ✅ | 미수신 or suspicious = true 2회 이상 |
| urgent | ✅ | ✅ | 미수신 or suspicious = true 3회 이상 |

**흐름:**
```
서버 heartbeat 수신 또는 미수신 판정
    ↓
notification_events 테이블에 대상자 기준 1건 저장 (title, body, alert_level)
    ↓
보호자별 알림 설정(guardian_notification_settings) 확인 후 FCM Push 개별 발송
  - Push 발송과 DB 저장은 분리 (DB에는 대상자 기준 1건만 저장)
  - DND 적용: 긴급 등급은 항상 발송, 나머지는 DND 시간대 Push 미발송

보호자 앱 알림 목록 화면
    ↓
GET /api/v1/notifications 호출 (당일 알림 시간순 조회)
    ↓
서버에서 보호자에 연결된 대상자의 notification_events 조회
    + 보호자별 알림 설정으로 등급 필터링하여 반환
    ↓
같은 대상자를 보는 모든 보호자가 동일한 알림 목록을 확인 가능
```

**자정 정리 정책:**
- 대상자 기기 타임존 기준 자정에 서버 스케줄러가 전날 알림 전체 삭제
- 클라이언트는 로컬 DB에 알림 이력을 저장하지 않음
- 앱 삭제/기기 변경 시에도 당일 알림은 서버에서 재조회 가능

**과거 알림 (guardian_past_notifications 화면):**
- 제거됨 — 당일 알림만 제공하며 과거 이력은 유지하지 않음


### 3.7 suspicious 판정 후 동작

suspicious = true 판정 시 서버가 suspicious_count 기반으로 보호자 경고를 에스컬레이션한다.
대상자에게 별도 로컬 알림을 표시하지 않는다 (제로 인터랙션 원칙).

- suspicious_count=1 → 주의(caution) 등급 → 보호자 Push
- suspicious_count=2 → 경고(warning) 등급 → 보호자 Push
- suspicious_count≥3 → 긴급(urgent) 등급 → 보호자 Push (매일 반복)
- 보호자 경고 클리어 시 suspicious_count 리셋 → 다음 suspicious부터 1차 재시작


---


## 4. 대상자-보호자 연결 (고유 코드 방식)


### 3.1 고유 코드 (invite_code)

```
[대상자 등록 시]
앱 설치 → 모드 선택(대상자) → 서버에 자동 등록
  · 서버가 고유 코드 발급: "K7M-4PXR" (3자리-4자리, 대문자+숫자)
  · 서버가 device_token 발급

[고유 코드 형식]
  · 7자리 영숫자 (대문자 A-Z + 숫자 0-9)
  · 포맷: XXX-XXXX (3자리-4자리, 하이픈 구분)
  · 서버에서 생성 시 UNIQUE 보장 (DB 제약조건 + 중복 시 재생성)
  · 조합 수: 36^7 = 약 783억 → 사실상 충돌 없음
```

**대상자가 보호자에게 코드를 전달하는 방법:**
- 화면에 크게 표시된 코드를 보여주기
- [코드 복사] 버튼 → 카톡/문자로 전송
- 공유 버튼 -> sns 공유
- 전화로 구두 전달 (7자리이므로 전달 용이)


### 3.2 보호자-대상자 연결 흐름

```
[보호자 앱]
앱 설치 → 모드 선택(보호자) → 서버에 자동 등록
  · 서버가 device_token 발급
  · 아직 연결된 대상자 없음

[대상자 추가] (설치 후 언제든 가능)
대시보드 → [+ 대상자 추가]
  · 고유 코드 입력: "K7M-4PXR"
  · 별칭 입력 (선택): "삼촌"   ← 보호자 앱 로컬에만 저장, 서버 미전송
  · [연결하기] → 서버에서 코드 확인 → 연결 완료
```

```
[연결 관계 (서버)]
대상자 (user_id:1, invite_code:"K7M-4PXR")
    │
    └── guardians (subject_user_id:1, guardian_user_id:2)
                                          │
                                          └── 보호자 (user_id:2)

[보호자 앱 로컬]
대상자 목록:
  · { invite_code: "K7M-4PXR", nickname: "삼촌" }  ← 로컬 저장
```


### 3.3 인증 방식: 무제한 device_token

```
[등록]
모드 선택 → 서버에 기기 정보만 전송 → 서버가 device_token 발급 (만료 없음) → 앱에 로컬 저장 → 끝

[이후 모든 API 호출]
Authorization: Bearer <device_token> → 항상 유효

[구독 상태는 서버가 판단]
보호자 앱 실행 시 서버 응답에 구독 상태 포함:
{
  "subscription": {
    "is_active": true,
    "days_remaining": 45
  }
}

[보호자 앱의 동작]
· is_active = true  → 정상 화면
· is_active = false → 결제 페이지로 자동 전환

[대상자 앱의 동작]
· 구독 상태와 무관하게 항상 정상 동작 (heartbeat 전송 유지)
· 대상자 앱에는 결제 관련 UI 없음
```

- 사용자가 토큰 만료/재인증을 신경 쓸 필요 없음
- 앱 재설치 시 device_token 분실 → **재등록** (device_id로 기존 계정 자동 복원, device_token만 재발급)


### 3.4 무료 체험 기준

**보호자 기준** (대상자는 항상 무료):
- 보호자가 최초 대상자를 연결할 때 3개월 무료 체험 시작
- 동일 device_id + 앱 재설치 → 기존 무료 체험 기간 유지 (device_id로 식별)
- 다른 device_id → 새 무료 체험 허용 (기기 변경)
- Android: `Settings.Secure.ANDROID_ID` (SSAID) 사용 — 앱 삭제 후에도 유지, 공장 초기화 시에만 변경
- iOS: `identifierForVendor` + **Keychain 백업** 사용 — IDFV는 vendor 앱을 전부 삭제 후 재설치하면 변경되므로, 최초 발급값을 `flutter_secure_storage`로 Keychain에 저장해 재설치 후에도 동일 device_id를 복원. Apple 구독 시스템도 자체적으로 무료 체험 중복 관리


### 3.5 앱 재설치 시 동작

```
[대상자 앱 재설치]
  · 로컬 데이터(device_token, 고유 코드) 소멸
  · 재등록 시 서버가 device_id로 기존 계정 조회 → 기존 계정 자동 복원
  · 기존 invite_code 유지, device_token만 재발급
  · 보호자 연결 유지 → 재연결 불필요
  · 대상자 앱에는 결제 기능 없음 (결제는 보호자가 담당)

[보호자 앱 재설치]
  · 로컬 데이터(device_token, 대상자 별칭) 소멸
  · 재등록 시 서버가 device_id로 기존 계정 조회 → 기존 계정 자동 복원
  · 기존 구독·대상자 연결 유지, device_token만 재발급
  · 대상자 재연결 불필요 (로컬 별칭만 재설정 필요)

[iOS device_id 복원 메커니즘]
  · iOS `identifierForVendor`는 vendor 앱 전부 삭제 후 재설치 시 값이 변경됨
    → Keychain 백업 없이는 서버가 새 device_id를 새 계정으로 인식 → 구독·대상자 연결 끊어짐
  · TokenLocalDatasource.getOrCreateDeviceId()가 최초 발급 시 SharedPreferences + Keychain(accessibility=unlocked_this_device) 양쪽 저장
  · 재설치 후 _getHardwareDeviceId()는 Keychain 우선 조회 → 없을 때만 IDFV fallback
  · Keychain 저장은 계정 복원 전용 (광고/트래킹 아님) — Apple 정책상 fingerprinting에 해당하지 않음
  · iCloud 동기화 차단(unlocked_this_device)으로 다른 기기로 전파되지 않음
  · Android는 SSAID가 자연스럽게 유지되므로 Keychain 불필요

[모드 변경 (동일 기기에서 다른 모드 선택)]
  · 서버: DELETE /api/v1/users/me → 전체 데이터 삭제
    (users, devices, guardians, alerts, notification_events, heartbeat_logs, subscriptions, guardian_notification_settings)
  · 앱 로컬: _tokenDs.clear() + _nicknameDs.clearAll() 호출
    → device_token, 역할, 초대 코드 등 토큰 정보 및 대상자 별칭 전체 삭제
  · 이후 새 모드로 재등록 (completeOnboarding 재호출)
```


### 3.7 연결 해제 시 처리

```
[보호자가 연결 해제]
연결관리 → 대상자 삭제 버튼 → 확인 다이얼로그 → 해제
```

**앱(클라이언트) 처리:**
- 서버 DELETE `/api/v1/subjects/{guardian_id}/unlink` 호출
- `NicknameLocalDatasource`에서 해당 `invite_code` 별칭 삭제
- `GuardianSubjectService` 인메모리 캐시에서 제거

**서버 처리:**
- `guardians` 레코드 삭제
- `notification_events`는 삭제하지 않음 (대상자 중심 데이터 — 다른 보호자에게도 유효)
- `alerts`는 삭제하지 않음 (대상자 기준 공유 데이터 — 다른 보호자에게도 유효)

**재연결:**
- 동일 `invite_code`로 재연결 가능 (대상자 계정 유지)
- 재연결 후 별칭은 다시 설정 필요 (로컬 삭제되었으므로)
- 재연결 후 알림 이력은 새로 시작


### 3.6 구독 및 결제

**결제 주체: 보호자**
- 대상자 앱은 완전 무료 (결제 UI 없음, heartbeat 전송만 담당)
- 보호자가 대상자 모니터링 서비스에 대해 결제

**구독 방식: 자동 갱신 구독 (Auto-Renewable Subscription)**
- 자동 갱신으로 모니터링 공백 방지 (고령 대상자가 갱신을 잊을 위험 없음)
- 취소 시 보호자 앱 설정에서 OS 구독 관리 페이지로 딥링크 제공 (2탭으로 취소)
  - Android: `https://play.google.com/store/account/subscriptions`
  - iOS: `https://apps.apple.com/account/subscriptions`
- 대상자 사망 시 보호자가 본인 계정에서 직접 구독 취소 가능

**구독 만료 시 동작:**
- 보호자 대시보드는 정상 접근 가능 (대상자 목록·상태 조회 가능)
- 대시보드 상단에 구독 만료 안내 배너 + [구독하기] 버튼 표시
- 대상자 heartbeat는 계속 수신하되, **경고 알림(Push) 발송 중단**
- 서버는 구독 만료 보호자에게 경고를 발송하지 않음
- 배너에 "경고 알림이 발송되지 않고 있습니다" 안내 표시

**구독 상품 (단일 요금):**
- 연 $9.99 (한국: ₩13,000~₩15,000) — 대상자 최대 5명
- 티어 구분 없음, 상품 1개로 단순화
- 기관 남용 방지를 위해 대상자 5명 상한 설정

**인앱 결제 (Apple/Google):**
- 결제는 보호자의 Apple ID / Google 계정에 귀속 → 서버에 개인정보 불필요
- 서버는 영수증(receipt) 토큰만 검증
- 보호자 앱 재설치 시 `restoreTransactions`로 기존 구독 자동 복원 가능


---


## 5. 프로젝트 구조

GetX + GetConnect/Dio + Clean Architecture 기반

```
lib/
├── main.dart                          # 앱 진입점 (WorkManager 콜백 등록)
├── app.dart                           # GetMaterialApp (GetX 라우팅)
├── firebase_options.dart
└── app/
    ├── core/                          # ── 공통 인프라 ──
    │   ├── base/
    │   │   └── base_controller.dart   # GetxController 공통 베이스
    │   ├── config/
    │   │   ├── api_config.dart        # API 서버 URL
    │   │   └── ad_config.dart         # AdMob 설정
    │   ├── mixins/
    │   │   └── heartbeat_schedule_mixin.dart  # heartbeat 시각 관리 공통 mixin
    │   ├── models/
    │   │   └── api_response_model.dart  # Freezed 공통 응답 모델
    │   ├── network/
    │   │   ├── api_client.dart         # GetConnect 기반 HTTP 클라이언트
    │   │   ├── api_client_factory.dart  # Dio 기반 HTTP 클라이언트 팩토리
    │   │   ├── api_connect.dart        # GetConnect 래퍼
    │   │   ├── dio_connect.dart        # Dio 래퍼
    │   │   ├── api_response.dart       # 공통 응답 처리
    │   │   ├── api_error.dart          # API 에러 클래스
    │   │   └── api_endpoints.dart      # API 경로 상수
    │   ├── services/
    │   │   ├── fcm_service.dart        # FCM Push 수신 + 로컬 알림 탭 라우팅
    │   │   ├── heartbeat_service.dart  # heartbeat 1회 실행 (센서→판정→전송)
    │   │   ├── heartbeat_worker_service.dart  # WorkManager 백그라운드 예약
    │   │   ├── local_alarm_service.dart  # 오늘의 안부 확인 메시지 로컬 알림
    │   │   ├── guardian_subject_service.dart  # G+S 모드 서비스
    │   │   ├── ad_service.dart         # AdMob 배너 관리
    │   │   └── theme_service.dart      # 다크모드 전환
    │   ├── theme/
    │   │   ├── app_colors.dart
    │   │   ├── app_spacing.dart
    │   │   ├── app_text_theme.dart
    │   │   └── app_theme.dart
    │   ├── translations/              # 20개 언어 번역 파일
    │   │   ├── app_translations.dart  # GetX Translations 등록
    │   │   ├── ko_kr.dart ~ id_id.dart  # 20개 언어
    │   ├── usecases/
    │   │   └── use_case.dart
    │   ├── utils/
    │   │   ├── constants.dart
    │   │   ├── extensions.dart
    │   │   ├── time_utils.dart
    │   │   ├── phone_utils.dart
    │   │   ├── notification_text_cache.dart  # 백그라운드 isolate용 번역 캐시
    │   │   └── back_press_handler.dart
    │   └── widgets/
    │       ├── banner_ad_widget.dart
    │       ├── guardian_bottom_nav.dart
    │       ├── heartbeat_schedule_tile.dart
    │       └── add_subject_button.dart
    │
    ├── data/                           # ── DataSource + Repository 구현체 ──
    │   ├── datasources/
    │   │   ├── local/
    │   │   │   ├── token_local_datasource.dart    # device_token, 스케줄, 역할 등 로컬 저장
    │   │   │   ├── heartbeat_local_datasource.dart # 전송 실패 보류 heartbeat 1건
    │   │   │   └── nickname_local_datasource.dart  # 대상자 별칭 로컬 저장
    │   │   └── remote/
    │   │       ├── user_remote_datasource.dart
    │   │       ├── device_remote_datasource.dart
    │   │       ├── heartbeat_remote_datasource.dart
    │   │       ├── subject_remote_datasource.dart
    │   │       ├── emergency_remote_datasource.dart
    │   │       ├── notification_remote_datasource.dart
    │   │       ├── notification_settings_remote_datasource.dart
    │   │       └── version_remote_datasource.dart
    │   ├── models/
    │   │   └── heartbeat_request.dart
    │   └── repositories/
    │       └── notification_repository_impl.dart
    │
    ├── domain/                         # ── 순수 비즈니스 (프레임워크 의존 없음) ──
    │   ├── entities/
    │   │   └── notification_entity.dart
    │   ├── repositories/
    │   │   └── notification_repository.dart  # 추상 인터페이스
    │   └── usecases/
    │       ├── get_notifications_usecase.dart
    │       └── delete_all_notifications_usecase.dart
    │
    └── modules/                        # ── Presentation (GetX Binding + Controller + View) ──
        ├── splash/                     # 앱 시작 + 버전 체크 + 기존 토큰 확인
        ├── mode_select/                # 대상자/보호자 모드 선택 (Android만)
        ├── permission/                 # 권한 안내 + OS 권한 요청
        ├── onboarding/                 # 서비스 소개 → 서버 등록
        ├── subject_home/               # 대상자 홈 (고유 코드, heartbeat 상태)
        ├── guardian_dashboard/         # 보호자 대시보드 (대상자 상태 카드)
        ├── guardian_add_subject/       # 대상자 추가 (고유 코드 입력)
        ├── guardian_connection_management/  # 연결 관리
        ├── guardian_notifications/     # 경고 알림 목록
        ├── guardian_notification_settings/  # 알림 설정 (등급별 ON/OFF, DND)
        └── guardian_settings/          # 보호자 설정 (구독, 약관, 탈퇴)
```

각 모듈은 `bindings/`, `controllers/`, `views/` 3개 파일로 구성.


### 의존성 흐름
```
┌──────────────────── Presentation ────────────────────┐
│  GetxController → DataSource 직접 참조               │
│  Page (GetWidget) → controller.field / Obx()          │
├──────────────────── Domain ──────────────────────────┤
│  Entity (순수 Dart)                                   │
│  Repository (추상 인터페이스)                           │
│  UseCase (비즈니스 로직) — 알림 조회 등 일부만 구현      │
├──────────────────── Data ────────────────────────────┤
│  DataSource (API 호출 / SharedPreferences 저장)        │
│  RepositoryImpl (Domain 인터페이스 구현)               │
├──────────────────── Core ────────────────────────────┤
│  FcmService / HeartbeatService / HeartbeatWorkerService │
│  ApiClientFactory (Dio) / ApiClient (GetConnect)       │
│  GetX 라우팅 / Theme / AdService                       │
└──────────────────────────────────────────────────────┘
```


---


## 6. 플랫폼별 네이티브 코드

### Android
```
android/app/src/main/
├── kotlin/.../
│   └── MainActivity.kt
└── AndroidManifest.xml
```
- WorkManager는 Flutter `workmanager` 패키지가 자동 등록 (네이티브 코드 불필요)

### iOS
```
ios/Runner/
├── AppDelegate.swift              # WorkmanagerPlugin.registerBGProcessingTask(withIdentifier:) 등록 필수
│                                  # registerProcessingTask()가 BGProcessingTaskRequest를 제출하려면
│                                  # didFinishLaunchingWithOptions에서 먼저 등록해야 함
└── Info.plist                     # Background Modes: fetch, processing, remote-notification
                                   # BGTaskSchedulerPermittedIdentifiers: workmanager.background.task
```


---


## 7. Flutter 핵심 패키지

| 패키지 | 용도 | 비고 |
| --- | --- | --- |
| `get` (GetX) | 상태관리 + 라우팅 + DI | GetxController, Get.toNamed, Get.put/find |
| `dio` | HTTP 클라이언트 | ApiClientFactory 패턴, heartbeat API 통신 |
| `firebase_core` + `firebase_messaging` | FCM/APNs Push 수신 | 보호자 경고 Push (Silent Push 미사용) |
| `workmanager` | 백그라운드 예약 실행 | WorkManager(Android) / BGTaskScheduler(iOS) heartbeat 스케줄링 |
| `flutter_local_notifications` | 로컬 알림 예약/취소 | 오늘의 안부 확인 메시지 로컬 알림 + 배터리/네트워크 안내 알림 (Android/iOS 공통) |
| `pedometer_2` | 걸음수 조회 | **primary 활동 지표**. iOS는 `queryPedometerData(from:to:)`로 kill 구간 포함 누적값 조회. Android는 Google Fit Local Recording API 사용(Samsung TYPE_STEP_COUNTER 0 발화 버그 회피, **minSdk 29 필요**). Android: ACTIVITY_RECOGNITION 권한, iOS: NSMotionUsageDescription |
| `shared_preferences` | 경량 로컬 저장소 | device_token, 대상자 별칭, 보류 heartbeat 1건 저장 |
| `device_info_plus` | 기기 고유 ID + 기기 정보 | device_id (Android: SSAID, iOS: identifierForVendor), OS 타입/버전 |
| `connectivity_plus` | 네트워크 상태 | 오프라인 시 전송 보류 |
| `battery_plus` | 배터리 상태 | 배터리 잔량·충전 여부 조회, 권한 불필요 |
| `freezed_annotation` + `json_annotation` | 직렬화 | Freezed DTO + json_serializable |
| `flutter_screenutil` | 반응형 UI | 375×812 기준 dp/sp 변환 |
| `lottie` | Lottie 애니메이션 재생 | 온보딩, 빈 상태, 로딩 등 UI 공백 연출 |
| `flutter_svg` | SVG 렌더링 | 아이콘·일러스트 SVG 표시 |
| `share_plus` | SNS 공유 | 고유 코드 공유 (카톡/문자 등) |
| `url_launcher` | URL 열기 | 스토어 이동, 구독 관리 딥링크, 약관/개인정보처리방침 |
| `permission_handler` | 런타임 권한 관리 | 알림, 활동 인식 등 권한 요청 |
| `timezone` + `flutter_timezone` | 타임존 처리 | 기기 로컬 타임존 감지 + IANA timezone 변환 |
| `sqflite` | 로컬 DB | 알림 이력 등 구조화 데이터 저장 |
| `in_app_purchase` | 인앱 결제 | **미구현** — 유료 구독 전환, 구독 복원 |
| `google_mobile_ads` | AdMob 하단 고정 배너 | **미구현** — 유료 사용자 광고 제거 |
| `geolocator` | 현재 위치 1회 획득 | 대상자 긴급 도움 요청 시 lat/lng/accuracy 획득 (포그라운드, 5초 타임아웃). 정기 heartbeat에는 사용하지 않음 |
| `google_maps_flutter` | 지도 표시 | 보호자 긴급 위치 지도 페이지(`guardian_emergency_map`)에서 마커 표시 |


---


## 8. 디자인 시스템


### 8.1 디자인 원칙

- **단순 심플**: 장식 최소화, 넉넉한 여백, 콘텐츠 중심
- **모드별 색상 분리**: 대상자/보호자가 한눈에 구분되는 메인 컬러
- **Lottie 활용**: UI 요소가 적은 화면의 빈 공간을 감성적 애니메이션으로 채움
- **그림자 최소화**: 카드는 그림자 없이 얇은 테두리(`1px #E0E0E0`) 또는 미세 elevation(`0.5`)만 사용
- **둥근 모서리**: 카드·버튼 radius `12~16`으로 부드러운 인상


### 8.2 모드별 메인 컬러

|                 | 대상자 모드        | 보호자 모드      |
| --------------- | ------------------ | ---------------- |
| **메인 컬러**   | Teal `#009688`     | Indigo `#3F51B5` |
| **밝은 변형**   | `#B2DFDB`          | `#C5CAE9`        |
| **어두운 변형** | `#00796B`          | `#303F9F`        |
| **느낌**        | 따뜻함, 안심, 건강 | 신뢰, 보호, 안정 |

```
[대상자 모드]
  AppBar/버튼:  Teal #009688
  강조 텍스트:   Teal Dark #00796B
  카드 배경:     White #FFFFFF
  배지/칩:       Teal Light #B2DFDB

[보호자 모드]
  AppBar/버튼:  Indigo #3F51B5
  강조 텍스트:   Indigo Dark #303F9F
  카드 배경:     White #FFFFFF
  배지/칩:       Indigo Light #C5CAE9
```

**공통 색상:**

| 용도            | 색상      |
| --------------- | --------- |
| 배경 (기본)     | `#FFFFFF` |
| 배경 (섹션)     | `#F5F5F5` |
| 텍스트 (주)     | `#212121` |
| 텍스트 (보조)   | `#757575` |
| 텍스트 (비활성) | `#BDBBD`  |
| 디바이더        | `#E0E0E0` |
| 성공            | `#4CAF50` |
| 에러            | `#B00020` |

**모드 전환 시 테마 적용:**
```dart
// 모드 선택 시 메인 컬러를 동적으로 변경
// 대상자 모드 → Teal 기반 ThemeData
// 보호자 모드 → Indigo 기반 ThemeData
```
---


## 9. 앱 UI 설계


### 9.0 앱 시작 플로우 (Splash → 버전 체크 → 권한 요청)

**Splash 화면:**
```
┌─────────────────────────────┐
│                             │
│                             │
│    [Lottie: 하트비트 펄스]   │
│    splash_heartbeat.json    │
│    (화면 중앙, 40% 너비)    │
│                             │
│         안 부               │
│                             │
│  · 버전 체크 API 호출       │
│  · 로컬 토큰 확인           │
│                             │
└─────────────────────────────┘
```

**강제 업데이트 다이얼로그:**
```
┌─────────────────────────────┐
│                             │
│    ┌─────────────────────┐  │
│    │                     │  │
│    │   앱 업데이트 필요    │  │
│    │                     │  │
│    │  새로운 버전이        │  │
│    │  출시되었습니다.      │  │
│    │  계속 사용하려면      │  │
│    │  업데이트가           │  │
│    │  필요합니다.          │  │
│    │                     │  │
│    │   [업데이트 하기]     │  │  ← 스토어로 이동
│    │                     │  │
│    └─────────────────────┘  │
│                             │
└─────────────────────────────┘
```
- `force_update = true`: [업데이트 하기] 버튼만 표시 (닫기/건너뛰기 없음, 앱 사용 차단)
- `force_update = false`: [업데이트 하기] + [나중에] 버튼 표시 (선택적)
- 버튼 탭 시 서버 응답의 `store_url`로 이동 (Android: Play Store, iOS: App Store)

**권한 요청 안내 화면 (모드 선택 후 진입):**
```
┌─────────────────────────────┐
│                             │
│                             │
│   앱 사용을 위해             │
│   권한이 필요합니다          │
│                             │
│  ┌───────────────────────┐  │
│  │ 🔔 알림 권한           │  │
│  │  [대상자] 안부 확인     │  │
│  │  알림을 받기 위해       │  │
│  │  필요합니다             │  │
│  │  [보호자] 보호 대상자의 │  │
│  │  안전 상태 알림을 받기  │  │
│  │  위해 필요합니다        │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ 🚶 신체 활동 권한      │  │  ← Android 대상자/G+S 복원 시만 표시
│  │  걸음수를 감지하여      │  │    (iOS 전체 + Android 보호자: 숨김)
│  │  활동 여부를 확인하는   │  │
│  │  데 사용됩니다          │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ 📍 위치 정보           │  │  ← Android 대상자/G+S 복원 시만 표시
│  │  긴급 도움 요청 시에만  │  │    (긴급 버튼 탭 시점에 Lazy로 요청하면
│  │  현재 위치를 보호자에게 │  │     기존 거부 이력 때문에 OS 팝업이
│  │  전달합니다             │  │     억제돼 사전 요청으로 전환)
│  └───────────────────────┘  │
│                             │
│         [확인]              │
└─────────────────────────────┘
```
- 모드 선택 화면에서 모드 선택 후 이 화면으로 진입 (`arguments['mode']`, `arguments['isAlsoSubject']`로 모드 및 G+S 구분)
- G+S 재설치 감지: `mode_select_controller.dart`에서 `checkDevice` API의 `has_invite_code` 응답으로 판별 → `isAlsoSubject=true` 전달
- **권한 요청 시점 정책**:
  - **up-front (이 화면에서 사전 요청)**: 알림 / 신체 활동 / 위치(긴급 도움 요청 첨부용). 사용자 납득이 쉽고 OS 팝업이 반드시 표시되는 시점
  - **Lazy (활성화 시점 요청)**: iOS G+S 활성화 시 모션 권한. 선택적 기능 활성화에 연동된 권한만 Lazy 유지
- **신체 활동 / 위치 권한 표시 조건**: `Platform.isAndroid && (isSubjectMode || isAlsoSubject)` — Android에서 대상자 기능을 쓰는 모든 경로(S 신규 설치, S 재설치, G+S 재설치 복원, S→G+S 전환 후 재설치)에서 카드 표시 + OS 권한 요청
- **숨김 조건**: iOS 전체(보호자 전용) + Android 순수 보호자 모드 (heartbeat 전송·긴급 요청 없음)
- **위치 권한을 up-front로 전환한 이유**: Lazy로 긴급 버튼 탭 시점에 요청하면 `permission_handler`의 `.request()`가 기존 거부 이력(Android 12+ 2회 거부 시, iOS 1회 거부 시) 때문에 OS 팝업을 다시 띄우지 않아 권한 획득이 실패한다. 긴급 상황에서 설정 앱 이동으로 복구하는 플로우는 비현실적이므로 사전 요청으로 전환
- iOS G+S 활성화 시점에 별도 플로우로 모션 권한을 요청 (§9.7 참조) — App Store 심사 시 "선택 기능 활성화 시에만 모션 권한 요청" 포지셔닝 유지
- [확인] 탭 시 OS 권한 팝업 순차 표시:
  - iOS: Firebase Messaging `requestPermission()`으로 APNs 권한 + FCM 토큰 발급 (모션 권한 요청 없음)
  - Android 대상자/G+S 복원: `permission_handler`로 알림 권한 → `Permission.activityRecognition` → `Permission.locationWhenInUse` 순차 요청 (사전 안내 다이얼로그 없이 OS 팝업 직접 표시)
  - Android 순수 보호자: 알림 권한만 요청 (활동 인식·위치 권한 요청 없음)
  - iOS G+S 활성화 시점의 모션 권한 팝업 문구는 `ios/Runner/{lang}.lproj/InfoPlist.strings` 20개 언어로 번역되어 기기 locale에 맞게 자동 표시
- 알림 권한 거부 시 재요청 다이얼로그 표시 ("설정으로 이동" / "나중에" 선택)
- 권한 처리 후 온보딩 화면으로 이동 (`Get.offNamed(AppRoutes.onboarding)`)
- 배터리 최적화 제외 권한(`REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`)은 매니페스트에서 제거됨 — Splash 단계에서 다이얼로그로 안내 (9.0.1 참조)
- 온보딩에서는 권한 요청 없음 — 서버 등록 + 화면 이동만 담당


#### 9.0.1 배터리 최적화 안내 다이얼로그 (Splash, 대상자/G+S 전용)

매일 정해진 시각의 heartbeat 전송이 OEM 배터리 절약 정책으로 누락되는 것을 막기 위해, Splash 단계에서 사용자에게 직접 안내한다. Google Play 정책상 `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` 권한은 사용하지 않고, 사용자가 앱 설정 화면에서 배터리를 "제한없음"으로 직접 변경하도록 유도한다.

**표시 조건 (`splash_controller.dart::_checkBatteryOptimization`):**
- Android 전용 (iOS는 즉시 return)
- `userRole == 'subject'` 또는 `isAlsoSubject == true` (순수 보호자는 heartbeat 전송 안 함 → 표시 안 함)
- 기존 등록된 사용자에게만 표시 (Splash → 홈 이동 직후)

**1회 표시 플래그 (`SharedPreferences: battery_dialog_shown`):**
- [설정으로 이동] 클릭 시에만 플래그 저장 → 다음부터 표시 안 함
- [나중에] 클릭 시 플래그 미저장 → **다음 앱 실행 시 다시 표시** (사용자가 적극 설정하도록 유도)

**다이얼로그 내용 (`permission_battery_required_*` 번역키):**
- 제목: "배터리 \"제한없음\"으로 설정해주세요"
- 본문: "배터리 최적화" 또는 "배터리 절약" 설정 시 안부 확인 누락 가능 안내 + [설정으로 이동] → "배터리" → "제한없음" 선택 단계 안내
- `barrierDismissible: false` (외부 탭으로 닫기 불가)
- [설정으로 이동] → `permission_handler.openAppSettings()` 호출 (앱 정보 화면 → 사용자가 배터리 항목으로 직접 진입)


### 9.1 모드 선택 화면 (최초 실행 시)

```
┌─────────────────────────────┐
│                             │
│    [Lottie: 두 사람 연결]   │
│    mode_select_connect.json │
│    (상단 35%, 70% 너비)     │
│                             │
│   어떻게 사용하시겠어요?     │
│                             │
│  ┌───────────────────────┐  │
│  │  나의 안전을            │  │
│  │  확인받고 싶어요        │  │
│  │  (관심 대상자 모드)        │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │  상대방의 안부를        │  │
│  │  확인하고 싶어요        │  │
│  │  (보호자 모드)          │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**ModeSelectController 동작 (`_selectMode`):**
1. `TokenLocalDatasource.getOrCreateDeviceId()`로 device_id 획득
2. `UserRemoteDatasource.checkDevice(deviceId)` → 기존 등록 여부 확인
3. 기존 등록 + 다른 역할 → 경고 다이얼로그 (모드 변경 시 기존 데이터 삭제 안내)
4. 보호자 모드 + `has_invite_code: true` → G+S 재설치 감지 → `isAlsoSubject: true` 전달
5. 권한 화면으로 이동: `Get.toNamed(AppRoutes.permission, arguments: {'mode': mode, 'isAlsoSubject': needsSubjectPermission})`


### 9.2 온보딩 (4스텝, 대상자/보호자 공통)

> 권한 요청은 모드 선택 후 이미 완료된 상태 (9.0 참조)
> 대상자·보호자 동일한 온보딩 화면 사용, 등록 시점에 mode로 분기

```
[4스텝 감정 흐름: 공감 → 해결 → 연결 → 신뢰]

┌─────────────────────────────┐
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │  [SVG: unDraw 일러스트]│  │
│  │  배경 장식 원 +        │  │
│  │  onboarding_*.svg     │  │
│  │  (상단 60%, 전체 너비) │  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│   Step 1: "혼자 사는 소중한 │
│   사람, 걱정되시나요?"      │
│   Step 2: "안부는 말없이도  │
│   전해집니다"               │
│   Step 3: "소중한 사람과    │
│   안부를 나누세요"          │
│   Step 4: "이름도, 전화번호 │
│   도 수집하지 않습니다"     │
│                             │
│   ● ○ ○ ○  (dot 인디케이터) │
│                             │
│  [다음] / 마지막: [시작하기] │
└─────────────────────────────┘
```

- PageView 기반 스와이프 + [다음] 버튼으로 이동
- 마지막 스텝에서 [시작하기] 탭 시 서버에 자동 등록 (`POST /api/v1/users`)
- **기존 기기 감지는 모드 선택 화면(ModeSelectController)에서 처리** — 온보딩 진입 전에 이미 완료
- `OnboardingController.completeOnboarding()`: 서버 등록 → `_saveAndNavigate()` → 홈 이동
- 등록 완료 시:
  - 대상자: invite_code + device_token 저장 → SubjectHome 이동
  - 보호자: device_token 저장 → GuardianDashboard 이동
  - G+S 복원 (invite_code 포함 응답): `isAlsoSubject=true` 로컬 저장
- SVG 일러스트: `assets/illustrations/onboarding_empathy.svg`, `onboarding_solution.svg`, `onboarding_connection.svg`, `onboarding_trust.svg`
- Lottie 파일 확보 시 교체 가능하도록 구조화


### 9.3 보호 대상자 모드 - 메인 화면

> 테마 컬러: **Teal `#009688`** 계열 적용

```
┌─────────────────────────────┐
│  [AppBar: ≡ 메뉴   프로필]  │
│                             │
│  안전 코드 공유 카드         │
│  ┌───────────────────────┐  │
│  │  K7M-4PXR             │  │  ← 크고 명확하게 표시
│  │  [복사] [공유]         │  │
│  │  이 코드를 보호자에게   │  │
│  │  알려주세요             │  │
│  └───────────────────────┘  │
│                             │
│  마지막 안부 확인 상태 카드  │
│  ┌───────────────────────┐  │
│  │  ✅ 마지막 확인: 3시간전│  │
│  │  보호자: 1명 연결됨     │  │
│  └───────────────────────┘  │
│                             │
│  [📱 지금 안부 보고하기]     │  ← 즉시 heartbeat 전송
│                             │
│  확인 시각: 매일 18:00       │
│  [⏰ 시각 변경]              │
│                             │
│  ┌───────────────────────┐  │
│  │  🚨 도움이 필요해요     │  │  ← 긴급 도움 요청
│  │  보호자에게 긴급 상황을  │  │    배경 #FFEBEE, 텍스트 #B71C1C
│  │  알립니다               │  │    확인 다이얼로그 후 전송
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │   하단 고정 배너 광고   │  │
│  └───────────────────────┘  │
│                             │
│  [Drawer 메뉴]              │
│  ├─ 🌙 다크모드 토글        │
│  ├─ 📄 이용약관             │
│  ├─ 🔒 개인정보처리방침     │
│  └─ 🚪 탈퇴하기             │
└─────────────────────────────┘
```

- Lottie 애니메이션 없음 — 아이콘 기반 UI
- Drawer 메뉴에서 다크모드 전환, 약관, 탈퇴 기능 제공
- "지금 안부 보고하기" 버튼으로 수동 heartbeat 즉시 전송 가능 (manual = true) + 연락처 선택 → 전화 걸기
  - **하루 1회 제한**: `TokenLocalDatasource.lastManualReportDate`(yyyy-MM-dd)에 마지막 수동 보고 날짜 저장. 같은 날 재시도 시 `subject_home_manual_report_limit_reached` 안내 스낵바 표시 후 차단 (서버 호출 없음). 자정 지나면 재가능
  - 수동 보고 시에도 `stepsDelta`에 실제 누적 걸음수를 실어 보낸다. 서버가 `manual=true`를 가드로 활동 정보 알림(`steps`) 중복 생성을 차단하므로 보호자 알림 목록에는 "수동 안부 확인"(`manual_report`) 1건만 도달하며, 일별 걸음수 이력은 자동/수동 구분 없이 `heartbeat_logs`에 집계된다
- **SubjectHomeController 핵심 동작:**
  - `onInit()`: 로컬 데이터 로드 + 알림 권한 확인 + 배터리/네트워크 상태 감시 + 서버 스케줄 동기화
  - `onResumed()`: heartbeat 상태 갱신 + 예약시각 경과 시 자동 전송 (`_checkAndSendHeartbeat`)
  - `_syncScheduleFromServer()`: G+S 모드 진입 시 전달받은 `deviceData`가 있으면 서버 호출 스킵 (중복 API 호출 방지)
  - 활동 인식 권한 요청은 하지 않음 — 권한 화면(PermissionController)에서 일괄 처리
- "도움이 필요해요" 긴급 버튼으로 보호자 전원에게 즉시 긴급 알림 발송 (POST /api/v1/emergency)
  - 확인 다이얼로그 표시 후 전송 (오탐 방지)
  - 기존 heartbeat 경고 에스컬레이션(suspicious_count, days_inactive)과 독립 동작
  - 버튼 색상: 배경 `#FFEBEE`, 텍스트/테두리 `#B71C1C` (긴급 등급 색상 통일)


### 9.4 대상자 모드 - 설정 화면

> 대상자 설정은 메인 화면의 Drawer 메뉴에 통합.
> 별도 설정 페이지 없이 Drawer에서 다크모드, 약관, 개인정보처리방침, 탈퇴 기능을 제공한다.


### 9.5 보호자 모드 - 대시보드

> 테마 컬러: **Indigo `#4355B9`** 계열 적용
> BottomNavigationBar: 홈 / 연결 / 알림 / 설정 (4탭)

```
[대상자 연결 후 - 정상 상태]
┌─────────────────────────────┐
│  [AppBar: 경고레벨 뱃지]     │
│                             │
│  (구독 만료 시 경고 배너)    │
│  ┌───────────────────────┐  │
│  │ ⚠ 구독이 만료되었습니다│  │
│  │ 경고 알림이 발송되지    │  │
│  │ 않고 있습니다           │  │
│  │        [구독하기]       │  │
│  └───────────────────────┘  │
│                             │
│  N명의 대상자를 보호 중      │
│                             │
│  대상자 카드 (PageView 슬라이드) │
│  ┌───────────────────────┐  │
│  │ 좌측 컬러 보더          │  │
│  │ (등급별 색상 변경)      │  │
│  │  삼촌 (로컬 별칭)      │  │
│  │  [정상] 상태 뱃지       │  │
│  │  마지막 확인: 3시간 전  │  │
│  │  활동량: 안정적임       │  │
│  │  ~~~ 웨이브 차트 ~~~    │  │
│  │  [📞 전화] [✅ 안전확인] │  │
│  └───────────────────────┘  │
│  ● ○ ○  (dot 인디케이터)    │
│                             │
│  범례: 🟢정상 🟡주의 🟠경고  │
│        🔴긴급               │
│                             │
│  [+ 대상자 추가]             │
│                             │
│  프리미엄 서비스 배너        │
│                             │
│  [홈] [연결] [알림] [설정]   │
└─────────────────────────────┘
```

- Lottie 애니메이션 없음 — 아이콘 + 웨이브 애니메이션 기반 UI
- 대상자 카드는 PageView로 좌우 슬라이드 전환, **경고 등급순 정렬** (긴급 → 경고 → 주의 → 정보 → 정상)
- 카드 좌측 보더 색상이 경고 등급에 따라 변경 (정상: 초록, 주의: 노랑, 경고: 주황, 긴급: 빨강)
- 배터리 표시는 정상 상태일 때만 표시 (주의/경고/긴급 등급에서는 배터리 아이콘·퍼센트 숨김)
- 경고 상태(주의/경고/긴급)일 때 활동 라벨: "안전 확인이 필요합니다"
- 전화 버튼 탭 시 해당 대상자를 강조 대상으로 등록 → 복귀 시 안전확인 유도
- 구독 만료 시 대시보드 상단에 경고 배너 표시 (전면 차단 아님)

**경고 클리어 동작 (안부 확인 완료 시퀀스):**

보호자가 대상자의 건강을 직접 확인한 후 [건강 확인 완료] 버튼을 탭하면 다음이 일괄 처리된다:

```
보호자 [건강 확인 완료] 탭
    │
    ├─ 1. PUT /api/v1/alerts/clear-all { subject_user_id }
    │
    ├─ 2. 서버: 해당 대상자의 모든 활성 경고 일괄 cleared
    │      (정보/주의/경고/긴급 등급 모두 포함)
    │
    ├─ 3. 서버: 카운터 리셋
    │      ├─ days_inactive → 0
    │      ├─ suspicious_count → 0
    │      └─ 예약된 미발송 알림(push_pending) 취소
    │
    ├─ 4. 서버: 적응형 주기 → 정상 주기(매일 고정 시각) 복원
    │
    ├─ 5. 클라이언트: 대시보드 경고 카드 제거
    │      └─ "정상" 상태 UI로 전환
    │
    └─ 6. 이후 heartbeat가 여전히 없으면
         → 다음 날 같은 시각에 새로운 1차 경고부터 재시작
```

- 클리어 이력은 서버에 기록됨 (보호자 ID, 시각)
- 보호자 본인에게 연결된 대상자의 경고만 클리어 가능


### 9.6 보호자 모드 - 대상자 추가 화면

> BottomNavigationBar "연결" 탭 (currentIndex=1)

```
┌─────────────────────────────┐
│      대상자 추가             │
│                             │
│  안내 텍스트                 │
│                             │
│  고유 코드 입력 (8자리)      │
│  [________________]          │
│                             │
│  별칭 입력 (선택):           │
│  [________________]          │
│  예: 삼촌, 아버지           │
│                             │
│        [연결하기]           │
│                             │
│  [홈] [연결] [알림] [설정]   │
└─────────────────────────────┘
```

- 별칭은 **보호자 앱 로컬에만 저장** (NicknameLocalDatasource, 서버 미전송)
- 별칭 미입력 시 고유 코드로 표시
- 연결 완료 시 result=true 반환 → 대시보드에서 목록 즉시 갱신


### 9.7 보호자 모드 - 설정 화면

> BottomNavigationBar "설정" 탭 (currentIndex=3)

```
┌─────────────────────────────┐
│  ⚙ 설정                     │
│                             │
│  프로필 카드                 │
│  ┌───────────────────────┐  │
│  │ 👤 안부 수호자          │  │
│  │    앱버전: v1.0.0   🌙 │  │  ← 다크모드 토글 + 모드 텍스트
│  └───────────────────────┘  │
│                             │
│  연결 관리 카드              │
│  ┌───────────────────────┐  │
│  │ 👥 연결 관리            │  │
│  │ 관리 보호 대상자 수     │  │
│  │              1 / 5명    │  │
│  └───────────────────────┘  │
│                             │
│  ── 구독 및 서비스 ──        │
│  구독 카드 (그라디언트, plan별 분기) │
│  ┌───────────────────────┐  │
│  │ ✓ 현재 멤버십          │  │
│  │   yearly: 프리미엄 구독 중 (인디고) │
│  │   free_trial: 무료 체험 중 (회색)  │
│  │   yearly → [구독 관리]  │  │
│  │   free_trial → [구독하기] │  │
│  └───────────────────────┘  │
│                             │
│  [🔔 알림 설정 →]            │
│                             │
│  📄 약관                     │
│  [개인정보처리방침 ↗]        │
│  [이용약관 ↗]               │
│                             │
│  ANBU GUARD NETWORK         │
│  © 2026 Ark SB Inc.     │
│                             │
│  [홈] [연결] [알림] [설정]   │
└─────────────────────────────┘
```

- 구독 카드는 `GET /api/v1/devices/me`의 `subscription_plan` 값으로 분기:
  - `yearly`: 인디고 그라데이션 + "프리미엄 구독 중" + [구독 관리] 버튼만 표시
  - `free_trial`/기타: 회색 그라데이션 + "무료 체험 중" + [구독하기] 버튼만 표시
- [구독 관리] → Apple/Google 구독 관리 페이지로 딥링크 이동 (기존 구독 취소/변경)
- [구독하기] → 인앱 결제 SDK 연동 후 구현 예정 (현재 placeholder)
- [알림 설정] → 알림 설정 페이지로 이동 (등급별 ON/OFF, DND 설정)
- 다크모드 토글: ThemeService를 통한 즉시 전환

**G+S (Guardian+Subject) 모드 — 보호자가 대상자 역할 겸임:**

G+S 라이프사이클(활성화/해제/스케줄 예약)은 `GuardianDashboardController`가 단독 소유한다. 설정 화면(`GuardianSettingsController`)은 UI 전용이며 heartbeat 전송이나 예약 로직을 갖지 않는다. Heartbeat 자동 재전송은 `GuardianSafetyCodeController`가 단독 소유하여 중복 전송 race를 구조적으로 차단한다. `GuardianDashboardBinding` / `GuardianSettingsBinding` 모두 Dashboard 컨트롤러를 `permanent: true`로 등록해 어느 진입 경로에서도 동일 인스턴스를 공유한다.

- **활성화** (`GuardianDashboardController.enableSubjectFeature()`):
  1. **기능 안내 다이얼로그** 표시 (iOS는 안부 푸시 알림 동작 방식 포함) → 사용자가 `이해했습니다, 활성화` 탭으로만 진행
  2. **Lazy Permission — 걸음수 권한 요청** (다이얼로그 확정 직후, 최초 권한 화면에서 요청하지 않았으므로):
     - Android: `Permission.activityRecognition.request()` 호출
     - iOS: `Pedometer.stepCountStream.first.timeout(3s)` 호출로 CMPedometer를 유발해 모션 권한 시스템 팝업 표시
     - **권한 결과와 무관하게 활성화는 계속 진행** (거부해도 중단하지 않음). 거부 시 안전코드 화면에 "걸음수 권한 거부" 경고 텍스트가 상시 노출되며, 탭하면 권한 재요청
  3. 서버 `POST /api/v1/users/enable-subject` → invite_code 발급
  4. 로컬 `isAlsoSubject=true`, invite_code, heartbeat 스케줄 저장
  5. 예약:
     - Android: `HeartbeatWorkerService.schedule()` + `LocalAlarmService.schedule()`
     - **iOS G+S**: `LocalAlarmService.schedule()`만 등록 (BGTaskScheduler 사용하지 않음)
  6. 첫 heartbeat 즉시 전송 (`HeartbeatService().execute()`) — 이후 SafetyCode `onInit`의 자동 재전송은 `HeartbeatService` 내부 `HeartbeatLockDatasource`(SQLite UNIQUE CAS, TTL 30초) + `lastScheduledKey`(성공 마커) + `isReportedToday=true`로 중복 전송이 구조적으로 차단됨
  7. 성공 시 `goToSafetyCode()` 호출 → 안전코드 페이지(`GuardianSafetyCodePage`)로 자동 이동

- **안전코드 화면 걸음수 권한 경고** (`GuardianSafetyCodeController` + `GuardianSafetyCodePage`):
  - 코드 공유 박스 아래에 권한 상태를 감시하는 위젯 배치
  - `Permission.activityRecognition.status`(Android) 또는 `Permission.sensors`/Pedometer 실제 조회(iOS)로 권한 여부 판정
  - 거부 상태일 때만: 빨간색 계열 텍스트 "걸음수 권한이 거부되어 있습니다. 여기를 눌러 권한을 허용해 주세요" 상시 노출
  - 텍스트 탭 → Android: `Permission.activityRecognition.request()` 재호출 (영구 거부 시 `openAppSettings()` 대체), iOS: `Permission.sensors.request()`로 CMMotionActivityManager 호출해 모션 권한 팝업 유도 또는 설정 이동
  - 포그라운드 복귀 시(`onResumed`) 권한 상태 재확인 → 허용됐으면 위젯 숨김 (Rx로 상태 반응)

- **긴급 버튼 아래 위치 권한 경고** (S 모드 홈 + G+S 안전코드 공통):
  - `SubjectHomeController` / `GuardianSafetyCodeController`에 `locationPermissionDenied` Rx, `refreshLocationPermissionStatus()`, `requestLocationPermissionAgain()` 추가. onInit/onResumed에서 상태 재조회
  - 🚨 도움이 필요해요 버튼 **바로 아래**에 권한 상태 감시 위젯 배치. `Permission.locationWhenInUse.status`로 판정
  - 거부 상태일 때만: 빨간색 경고 카드 "긴급 요청 시 위치가 전달되지 않습니다. 탭하여 허용." 노출 (`location_permission_warning` 키, 20개 언어 번역)
  - 텍스트 탭 → 일반 거부: `Permission.locationWhenInUse.request()` 재호출 (OS가 허용하는 경우 시스템 팝업). 영구 거부/restricted: 설정 이동 다이얼로그 → `openAppSettings()`
  - 다이얼로그 본문은 **플랫폼별 분기**: iOS는 "'안부'를 찾아 선택한 뒤, '위치' 항목에서 '앱을 사용하는 동안'을 선택"(`location_permission_settings_body_ios`), Android는 "'권한' → '위치' 순서로 선택한 뒤 '앱 사용 중에만 허용'을 선택"(`location_permission_settings_body_android`). 20개 언어 모두 해당 OS의 실제 현지화된 Settings UI 레이블을 사용
  - **iOS 18 한계 대응**: Apple이 iOS 18에서 Settings 구조를 재편하면서 `UIApplication.openSettingsURLString`이 앱 페이지 직접 딥링크를 보장하지 않음 (Settings → Apps 리스트에 도달하고 멈추는 케이스 발생). 앱에서 우회 불가 (App Store 심사 상 `prefs:` URL 금지)이므로 다이얼로그 본문의 단계별 안내가 유일한 완화책
  - 포그라운드 복귀 시(`onResumed`) 상태 재확인 → 허용됐으면 위젯 숨김

- **비활성화** (`GuardianDashboardController.disableSubjectFeature()`):
  1. 서버 `POST /api/v1/users/disable-subject`
  2. 예약 취소:
     - Android: `HeartbeatWorkerService.cancel()` + `LocalAlarmService.cancel()`
     - iOS G+S: `LocalAlarmService.cancel()`만 호출
  3. 로컬 데이터 정리 (isAlsoSubject=false, inviteCode, 센서 스냅샷, lastHeartbeatDate/Time 등)

- **앱 재진입 시 스케줄 동기화** (`_scheduleHeartbeatIfGS()`): Dashboard `onInit`에서 G+S 여부 확인 후 서버 `GET /api/v1/devices/me`로 heartbeat 스케줄 재동기화 및 WorkManager/로컬 알림 재예약

- **탈퇴 처리**: `GuardianSettingsController.deleteAccount()`가 `GuardianDashboardController.cancelHeartbeatSchedules()`를 호출해 예약 정리를 Dashboard에 위임

**iOS G+S 모드 동작 원칙 (Android와 차이):**

iOS는 BGTaskScheduler의 불안정성 때문에 백그라운드 예약 실행을 사용하지 않는다. 대신 `LocalAlarmService`가 **heartbeat 예약 시각에 정확히** 오늘의 안부 확인 메시지 로컬 알림(payload `gs_deadman`)을 표시하고, 사용자가 알림을 탭하거나 앱을 직접 열었을 때 홈 화면의 `onInit`/`onResumed`에서 미전송 여부만 확인하여 즉시 heartbeat를 전송한다.

- **전송 조건**: `isReportedToday == false` 하나뿐. 시각 경과 여부는 확인하지 않음.
  - `Platform.isAndroid && isScheduleInFuture`일 때만 예약 시각 전 전송을 차단 → iOS는 통과 → 앱만 열면 당일 미전송 시 항상 전송
  - G+S 전용 자동 재전송은 `GuardianDashboardController._checkAndSendHeartbeat`가 단독 소유. Dashboard `onInit`(`_initGuardianSubjectMode`) / `onResumed`(`_resumeGuardianSubjectMode`) / FcmService `gs_deadman` 탭(`refreshAndSend()`) 모두 이 단일 진입점을 호출. SafetyCode 컨트롤러는 heartbeat 재전송 로직을 갖지 않고 Dashboard의 `lastHeartbeatDate`/`lastHeartbeatTime`/`isReportedToday` Rx를 구독해 카드 상태만 표시하므로, 어느 화면에서 G+S 앱이 포그라운드로 복귀하든 동일하게 미전송 체크가 동작
- **오늘의 안부 확인 메시지 로컬 알림 시각**: iOS G+S는 heartbeat 예약 시각 +30분이 아니라 **예약 시각과 동일** (`LocalAlarmService.schedule`에서 오프셋 제거)
- **오늘의 안부 확인 메시지 로컬 알림 탭 라우팅** (`fcm_service._handleNotificationTap`): payload `gs_deadman` 수신 시 route와 무관하게 `Get.find<GuardianDashboardController>().refreshAndSend()`를 호출해 즉시 미전송 heartbeat 재확인(Dashboard가 permanent이므로 항상 findable). 현재 route가 `guardianSafetyCode`가 아니면 `Get.offAllNamed(guardianDashboard)` + `Get.toNamed(guardianSafetyCode)`로 스택을 `[dashboard, safetyCode]`로 재구성하여 뒤로가기 시 대시보드로 복귀. kill 상태 런치에서는 스택에 Dashboard가 없어 `offNamedUntil` predicate가 매칭되지 않고 SafetyCode가 root가 되어 뒤로가기 불가 이슈가 있었기 때문에 `offAllNamed`로 재구성한다. 이미 `guardianSafetyCode`면 스택 유지
- **UI 라벨 분기**: `HeartbeatScheduleTile`의 기본 label이 `Platform.isIOS`일 때 `heartbeat_schedule_title_ios`("안부 푸시 알림 시각")로 전환. 시간 변경 다이얼로그/힌트용으로 `heartbeat_schedule_change_title_ios`, `heartbeat_schedule_hint_ios` 번역 키도 추가
- **iOS 네이티브 정리**: `Info.plist`에서 `UIBackgroundModes`의 `fetch`/`processing` 제거, `BGTaskSchedulerPermittedIdentifiers` 제거. `AppDelegate.swift`에서 `WorkmanagerPlugin.registerBGProcessingTask` 호출 제거
- **`HeartbeatWorkerService`**: iOS 관련 코드 경로 모두 제거 (Android 전용 서비스)

- **안전코드 페이지** (`GuardianDashboardController.goToSafetyCode()`):
  - G+S 활성화 시 대시보드/설정 화면에서 안전코드 페이지(`GuardianSafetyCodePage`)로 이동 가능
  - Dashboard가 보유한 heartbeat 시각·구독 상태·보호자 수를 arguments의 `deviceData`로 전달하여 중복 API 호출 방지
  - `GuardianSafetyCodeController`가 arguments로 받아 초기 상태 구성

- 설정 화면에서 G+S 관련 UI:
  - G+S 비활성: "나도 안부를 확인받고 싶어요" 카드 표시 → 탭 시 `enableSubjectFeature()`
  - G+S 활성: 안전코드 카드 (invite_code + 상태 표시) + heartbeat 상태 카드 + [안전코드 보기] 버튼

**대상자 heartbeat 시각 변경:**
- 대상자 본인이 메인 화면에서 [⏰ 시각 변경] 탭 → 시간 선택 다이얼로그
- 선택 범위: 06:00 ~ 21:00 (30분 단위)
- 변경 시 서버에 `PATCH /api/v1/devices/{device_id}/heartbeat-schedule` 호출
- WorkManager/BGTask + 로컬 안전망 알림 동시 재예약


### 9.8 보호자 모드 - 구독 만료 시 동작

- 보호자 구독 만료 시 **대시보드 상단에 경고 배너** 표시 (전면 차단 아님)
- 대시보드, 연결 관리, 알림, 설정 등 모든 화면 정상 접근 가능
- 배너 내용: "구독이 만료되었습니다 / 경고 알림이 발송되지 않고 있습니다" + [구독하기] 버튼
- 서버는 구독 만료 보호자에게 경고 Push를 발송하지 않음
- 대상자 heartbeat는 계속 수신 (대상자 앱에 영향 없음)
- 구독 상태는 `TokenLocalDatasource.getSubscriptionActive()`로 로컬 확인
- [구독하기] → 인앱 결제 SDK 연동 후 구현 예정 (현재 placeholder)


---


## 10. 필요 퍼미션

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<!-- 대상자 긴급 도움 요청 시에만 포그라운드에서 1회 위치 수집 — 백그라운드 위치 선언 금지 -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**권한 요청 시점** (Android):
- 알림 / 활동 인식 / 위치 → **권한 안내 화면(§9.0)에서 up-front 요청** (Android 대상자 기능 사용 경로: S 신규/재설치, G+S 재설치 복원, S→G+S 전환 후 재설치)
- 순수 보호자 모드는 알림 권한만 요청, 활동 인식·위치는 요청하지 않음
- 위치 권한을 Lazy로 두지 않는 이유: Android 12+는 2회 거부 후 `permission_handler.request()`가 OS 팝업을 억제하여 긴급 상황에서 권한 획득이 실패하기 때문

> ⚠️ **백그라운드 위치 선언 금지** — `ACCESS_BACKGROUND_LOCATION`는 매니페스트에 선언하지 않는다. 위치는 사용자가 긴급 버튼을 눌렀을 때만 포그라운드에서 1회 획득한다. (Google Play 심사 리스크 회피)
> Google Maps 키는 `local.properties`의 `MAPS_API_KEY`를 `build.gradle.kts`의 `manifestPlaceholders`로 주입 (`com.google.android.geo.API_KEY` 메타데이터). 실제 키는 Git에 커밋 금지.

### iOS (Info.plist) — 보호자 전용 (G+S 모드 포함)

> iOS는 보호자 모드만 지원하며 BGTaskScheduler를 사용하지 않으므로 `fetch`, `processing`, `BGTaskSchedulerPermittedIdentifiers`는 불필요하다. G+S 활성화 시 `pedometer_2`로 걸음수를 조회해야 하므로 `NSMotionUsageDescription` 선언은 필수이나, **시스템 팝업은 G+S 활성화 시점에만 표시된다** (Lazy Permission — App Store 심사 시 "선택 기능 활성화 시에만 요청" 포지셔닝 유지). `geolocator` / `google_maps_flutter` 플러그인이 내부적으로 "Always" 위치 API를 참조하므로 Apple이 `NSLocationAlwaysAndWhenInUseUsageDescription` 키 선언을 요구한다 (ITMS-90683). **앱이 백그라운드 위치를 실제로 사용하지 않음을 설명 문자열에 명시**해야 하며, `UIBackgroundModes`에 `location`은 추가하지 않는다.

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
<key>NSMotionUsageDescription</key>
<string>걸음수를 감지하여 활동 여부를 확인하는 데 사용됩니다.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>긴급 도움 요청 시 현재 위치를 보호자에게 전달하여 빠른 이동을 돕습니다. 평상시에는 위치를 수집하지 않습니다.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>이 앱은 백그라운드에서 위치를 수집하지 않습니다. 위치는 사용자가 긴급 도움 요청 버튼을 직접 눌렀을 때만 1회 수집되며, 연결된 보호자에게 전달 후 즉시 삭제됩니다.</string>
<!-- Google Maps iOS API 키 — Git에 커밋 금지, 배포 전 실제 키로 교체 -->
<key>GMSApiKey</key>
<string>YOUR_IOS_MAPS_API_KEY</string>
```

> ⚠️ **`UIBackgroundModes`에 `location` 추가 금지**
> - `NSLocationAlwaysAndWhenInUseUsageDescription`은 geolocator/google_maps_flutter 플러그인의 내부 API 참조로 인해 App Store Connect(ITMS-90683)가 요구하므로 선언하지만, 앱이 "Always" 위치 권한을 실제로 요청하거나 백그라운드 위치를 수집하지는 않음
> - 최초 권한 요청 화면(§9.0): 알림 권한(UNAuthorizationOptions)만 요청 — 모션/위치 권한은 요청하지 않음
> - G+S 활성화 시점(§9.7): 기능 안내 다이얼로그 → `Pedometer.stepCountStream.first.timeout(3s)` 호출로 CMPedometer를 유발해 모션 권한 시스템 팝업 표시
> - 시스템 팝업 문구는 `ios/Runner/{lang}.lproj/InfoPlist.strings` 20개 언어 파일에 `NSMotionUsageDescription` / `NSLocationWhenInUseUsageDescription` 키로 등록되어 기기 locale에 맞춰 자동 번역 표시 (기본 폴백은 `Info.plist`의 한국어 문자열)
> - 센서(가속도/자이로) 조회, 배터리 최적화 관련 권한은 iOS에서 불필요


---


## 11. Heartbeat 전송 로직

```
[1차: WorkManager(Android 2계층) / BGTaskScheduler(iOS) — 매일 예약 시각 (기본 18:00)]
    │ Android: one-off 정각 발화 + periodic 1h 안전망 폴링 (두 계층 동시 등록)
    │
    ├─ 역할 확인 (대상자 모드만 실행)
    ├─ 예약 시각 이전이면 스킵 (periodic 폴링이 예약시각 전에 fire되는 경우)
    ├─ 당일 이미 전송 여부 확인 (lastHeartbeatDate == 오늘 → 스킵, 콜백 레벨 1차 거름)
    ├─ HeartbeatService._executeInternal:
    │    · lastScheduledKey(성공 마커) 검사 — 이미 성공한 스케줄이면 스킵
    │    · HeartbeatLockDatasource.tryAcquire(scheduledKey)
    │      — SQLite UNIQUE INSERT 기반 cross-isolate 원자 락
    │      — WorkManager 워커마다 새 isolate라 SharedPreferences는 CAS가 아니지만,
    │        SQLite UNIQUE는 Android WAL로 writer를 직렬화해 하나만 성공
    │      — 실패(UniqueConstraintError) → 다른 isolate 전송 중 → 즉시 스킵
    │      — 성공 → 걸음수 조회·전송 진행, finally에서 release(scheduledKey)
    │      — TTL 30초 초과 stale 락은 tryAcquire 진입 시 같은 트랜잭션에서 일괄 청소
    │
    ├─ 걸음수 조회 (pedometer_2) → suspicious 판정
    │   · steps_delta > 0 → suspicious = false
    │   · steps_delta == 0 또는 null → suspicious = true
    │   · manual = true → suspicious = false (항상)
    │
    ├─ heartbeat 데이터 구성
    │   {
    │     device_id, timestamp, source,
    │     steps_delta, suspicious, battery_level
    │   }
    │
    ├─ 네트워크 연결 확인
    │   ├─ 연결됨 → 서버 전송 (POST /api/v1/heartbeat)
    │   │   └─ 전송 성공 시 (이 순서로 원자적 처리):
    │   │       ├─ lastHeartbeatDate 저장
    │   │       ├─ lastScheduledKey 저장 (성공 마커 — 여기서만 save)
    │   │       ├─ 오늘의 안부 확인 메시지 로컬 알림 취소+재등록
    │   │       └─ Android: one-off만 내일로 재등록 (periodic은 그대로 유지)
    │   │          iOS: BGTask 재예약
    │   │       ※ finally에서 HeartbeatLockDatasource.release() 호출 (SQLite CAS 락 해제)
    │   └─ 미연결:
    │       ├─ 보류 heartbeat 1건 저장 (shared_preferences)
    │       └─ 다음 날 재예약 (앱 열기 시 재시도)
    │
    ├─ 현재 센서 값을 로컬에 저장 (다음 비교용)
    │
    └─ 전송 실패 시
        ├─ 로컬 큐에 pending 저장
        └─ 앱 열기 시 또는 다음 날 재시도

[2차: 앱 포그라운드 진입 시 — 앱 열기/복귀]
    │
    ├─ 서버에서 스케줄 동기화 (GET /api/v1/devices/me)
    ├─ 현재 시각 ≥ 예약 시각 AND 당일 미전송 → heartbeat 즉시 전송
    ├─ WorkManager/BGTask 재예약 + 로컬 알림 재예약
    ├─ 로컬 큐의 미전송 건 일괄 전송
    └─ 보호자 앱: 구독 상태 확인 → 만료 시 결제 페이지 전환

[3차 (iOS 전용): 오늘의 안부 확인 메시지 로컬 알림 — heartbeat 시각 + 30분 (1차·2차 실패 시)]
    │
    ├─ iOS 전용 매일 반복 로컬 알림 표시 ("안부 확인이 필요합니다. 이 메시지 알림을 한 번 터치해 주세요.")
    ├─ 사용자가 알림 탭 → 앱 포그라운드 전환만 (알림 자체에서 heartbeat 전송 안 함)
    │   → 홈 화면 onInit/onResumed에서 예약시각 경과 + 미전송 시 자동 전송
    ├─ 무시 시 매일 같은 시각에 계속 반복
    └─ Android는 오늘의 안부 확인 메시지 로컬 알림 없이 WorkManager periodic 1시간 폴링과 포그라운드 복귀 자동 전송(2차)이 안전망 역할을 한다

[네트워크 복구 시]
    │
    ├─ 로컬 큐의 미전송 heartbeat 일괄 전송
    ├─ 서버가 heartbeat 수신 → 경고 자동 해소 (resolved)
    └─ 보호자에게 "정상 복귀" 알림 발송
```


---


## 12. 알림 다국어(i18n) 설계


### 12.1 개요

앱은 20개 언어를 지원하며, 서버 Push 알림과 클라이언트 로컬 알림 모두 사용자의 기기 locale에 맞춰 번역된 메시지를 표시한다.

**지원 언어 (20개):**
ko_KR, en_US, ja_JP, zh_CN, zh_TW, de_DE, fr_FR, es_ES, it_IT, nl_NL, pt_BR, ru_RU, ar_SA, tr_TR, pl_PL, vi_VN, th_TH, sv_SE, hi_IN, id_ID


### 12.2 기기 locale 전달

클라이언트는 다음 2개 시점에 기기 locale을 서버에 전달한다:
- **기기 등록 시** (`POST /api/v1/users`): `device.locale` 필드로 전달
- **FCM 토큰 갱신 시** (`PUT /api/v1/devices/fcm-token`): `locale` 필드로 전달

```dart
// 기기 locale 문자열 생성 (예: 'ko_KR', 'en_US')
String _localeString() {
  final locale = Get.deviceLocale;
  if (locale == null) return 'en_US';
  final lang = locale.languageCode;
  final country = locale.countryCode ?? '';
  return country.isNotEmpty ? '${lang}_$country' : lang;
}
```

- `Get.deviceLocale`로 시스템 locale 감지 (하드코딩 금지)
- 앱 시작 시 `locale: Get.deviceLocale`, `fallbackLocale: Locale('en', 'US')`로 설정


### 12.3 서버 Push 알림 (보호자)

서버가 보호자의 `devices.locale`을 참조하여 해당 언어로 Push 메시지를 구성한다.
클라이언트는 별도 처리 없이 OS가 표시하는 Push 알림을 그대로 수신한다.

**선택 근거:** 앱이 완전히 종료된 상태에서도 Push 알림이 번역되어야 하므로, 서버 측에서 locale별 메시지를 생성하여 발송한다. (data-only push 방식은 앱 종료 시 기본 언어로만 표시되는 문제)


### 12.4 보호자 알림 목록 (message_key 기반 클라이언트 번역)

서버 `notification_events` 테이블에 `message_key`와 `message_params`(JSON)를 함께 저장한다.
클라이언트는 알림 목록 화면에서 `message_key`를 기반으로 GetX `.tr` / `.trParams()`로 로컬 번역 렌더링한다.

**message_key 목록:**

| message_key | 등급 | 설명 | params |
|---|---|---|---|
| `auto_report` | info | 자동 안부 확인 완료 | - |
| `manual_report` | info | 수동 안부 확인 | - |
| `battery_low` | info | 배터리 20% 미만 | - |
| `battery_dead` | info | 배터리 방전 추정 | `battery_level` |
| `caution_suspicious` | caution | 폰 사용 흔적 없음 (suspicious=true 1회) | - |
| `caution_missing` | caution | 안부 미수신 1회 (scheduler) | - |
| `warning` | warning | 연속 미수신 2회 (scheduler) | - |
| `warning_suspicious` | warning | 폰 사용 흔적 연속 없음 (suspicious=true 2회) | - |
| `urgent` | urgent | 긴급 미수신 3회+ (scheduler) | `days` |
| `urgent_suspicious` | urgent | 폰 사용 흔적 연속 없음 (suspicious=true 3회+) | `days` |
| `steps` | health | 걸음수 활동 정보 ("오늘 N보를 걸으셨습니다") | `steps` |
| `emergency` | urgent | 긴급 도움 요청 (대상자 직접) | - |
| `cleared_by_guardian` | info | 보호자 수동 경고 클리어 (다른 보호자에게 발송) | - |

> suspicious 경로(heartbeat는 수신되었으나 폰 사용 흔적 없음)와 미수신 경로(scheduler 기반)는 같은 등급이라도 별도 message_key/문구로 구분된다. suspicious 경로는 "폰 사용 흔적 없음"을, 미수신 경로는 "안부 확인 없음"을 강조.

**클라이언트 번역 키 매핑:**
```dart
// message_key → 클라이언트 .tr 키
'auto_report'         → 'noti_auto_report_body'.tr
'battery_dead'        → 'noti_battery_dead_body'.trParams({'battery_level': '...'})
'warning'             → 'noti_warning_body'.tr
'warning_suspicious'  → 'noti_warning_suspicious_body'.tr
'urgent'              → 'noti_urgent_body'.trParams({'days': '...'})
'urgent_suspicious'   → 'noti_urgent_suspicious_body'.trParams({'days': '...'})
'steps'               → 'noti_steps_body'.trParams({'steps': '...'})
'cleared_by_guardian' → 'noti_cleared_by_guardian_body'.tr
// message_key가 없으면 서버 제공 body(fallback) 사용
```

**알림 카드 표시 등급 (`_DisplayLevel` — message_key 우선 분류):**

서버 `alert_level`은 안부 정상/배터리/걸음수/보호자 클리어를 모두 `info`로 묶어 보내지만, UX상 "정상 안부 확인"과 "참고용 정보"를 구분 표시할 필요가 있어 [guardian_notifications_page.dart](../../lib/app/modules/guardian_notifications/views/guardian_notifications_page.dart)의 `_NotificationCard`는 `message_key` 우선으로 라벨/색상/아이콘을 결정한다.

| message_key | 표시 라벨 | 색상 | 아이콘 |
|---|---|---|---|
| `auto_report`, `manual_report`, `resolved`, `cleared_by_guardian` | **정상** (`notifications_level_health`) | 초록 (#43A047) | check_circle |
| `steps` | **정보** (`notifications_level_info`) | 파랑 (#4355B9) | directions_walk |
| `battery_low`, `battery_dead` | **정보** | 보라 (#7B1FA2, `isBatteryRelated`) | battery_alert |
| `caution_*` | **주의** | 노랑 (#FFC107) | info |
| `warning`, `warning_suspicious` | **경고** | 주황 (#FF9800) | warning_amber |
| `urgent`, `urgent_suspicious`, `emergency` | **긴급** | 빨강 (#E53935) | error |

알림 등급 안내 다이얼로그(`_showAlertLevelGuide`)의 분류와 동일. 시간 표시는 `messageKey == 'steps'`일 때만 숨긴다.

**아이콘/색상 분기:**
- 기존 `item.title.contains('배터리')` → `item.isBatteryRelated` (messageKey 기반)
- `NotificationEntity.isBatteryRelated`: `messageKey == 'battery_low' || messageKey == 'battery_dead'`


### 12.5 대상자 로컬 알림 (백그라운드 isolate 번역)

WorkManager/BGTaskScheduler 콜백은 별도 isolate에서 실행되므로 GetX `.tr`이 동작하지 않는다.
**SharedPreferences 캐시 방식**으로 해결한다:

```
[포그라운드 — Splash 초기화 시]
    NotificationTextCache.cacheAll()
    → GetX .tr로 번역 문자열을 SharedPreferences에 저장
    → 키: 'noti_text_local_alarm_title', 'noti_text_local_alarm_body' 등

[백그라운드 isolate — WorkManager/BGTask 콜백]
    NotificationTextCache.get('local_alarm_title', fallback: 'Wellness check needed')
    → SharedPreferences에서 캐시된 번역 문자열 읽기
    → 캐시 없으면 영문 fallback 사용
```

**대상 로컬 알림 (iOS 전용 1건):**

| 알림 | 캐시 키 | 한국어 기본값 |
|---|---|---|
| 오늘의 안부 확인 메시지 로컬 알림 (iOS 전용) | `local_alarm_title`, `local_alarm_body` | 📱 안부 확인이 필요합니다 / 이 메시지 알림을 한 번 터치해 주세요. |
| Android 채널명 | `noti_channel_name` | 안부 알림 |


### 12.6 번역 파일 구조

```
lib/app/core/translations/
├── ko_kr.dart    # 한국어 (기본)
├── en_us.dart    # 영어 (fallback)
├── ja_jp.dart    # 일본어
├── zh_cn.dart    # 중국어 간체
├── zh_tw.dart    # 중국어 번체
├── de_de.dart    # 독일어
├── fr_fr.dart    # 프랑스어
├── es_es.dart    # 스페인어
├── it_it.dart    # 이탈리아어
├── nl_nl.dart    # 네덜란드어
├── pt_br.dart    # 포르투갈어
├── ru_ru.dart    # 러시아어
├── ar_sa.dart    # 아랍어
├── tr_tr.dart    # 터키어
├── pl_pl.dart    # 폴란드어
├── vi_vn.dart    # 베트남어
├── th_th.dart    # 태국어
├── sv_se.dart    # 스웨덴어
├── hi_in.dart    # 힌디어
└── id_id.dart    # 인도네시아어
```

- 앱 이름 브랜드 규칙: 한국어만 "안부", 나머지 19개 언어는 "Anbu"
- UI 문자열 추가/변경 시 반드시 20개 파일 동시 반영
- GetX `.tr` / `.trParams()` 사용 (하드코딩 한글 금지)


---


## 13. 보안 (클라이언트)

- 기기 등록 시 서버에서 발급받은 `device_token`을 `shared_preferences`에 안전하게 저장
- 모든 API 호출에 `Authorization: Bearer <device_token>` 사용
- HTTPS 필수 (TLS 1.2+)
- **개인정보 최소 수집**: 이름, 전화번호, 사용 앱 목록 일절 수집하지 않음. 위치정보는 정기 heartbeat에서 미수집이며, 대상자가 [🚨 도움이 필요해요] 버튼을 직접 누른 경우에만 사용자 동의 하에 1회 수집하여 보호자에게 전달 (최대 24시간 서버 보관, 그 외 시점 일절 수집 없음)
- 수집 데이터 최소화: device_id, 걸음수(steps_delta), suspicious 플래그, 배터리 잔량, 앱 버전, locale, 긴급 요청 시 위도/경도/정확도
- 인앱 결제 영수증은 서버에서 Apple/Google 서버와 직접 검증
- 대상자 별칭은 보호자 앱 로컬에만 저장, 서버에 전송되지 않음


---


## 14. 배포

- **Android**: Google Play 스토어 (내부 테스트 → 프로덕션)
- **iOS**: App Store (TestFlight → 프로덕션)
- 최소 지원: Android 10 (API 29) / iOS 14.0
  - Android minSdk 29 사유: `pedometer_2`가 Google Fit Local Recording API를 사용하며 해당 API가 Android 10+만 지원 (Samsung TYPE_STEP_COUNTER 0 발화 버그 회피를 위해 채택)

### 앱 심사 대응

| 심사 포인트                | Android                                                   | iOS (보호자 전용)                                          |
| -------------------------- | --------------------------------------------------------- | ---------------------------------------------------------- |
| 모드                       | 대상자 + 보호자 모두 지원                                  | **보호자 모드만 지원** (모드 선택 화면 스킵)                |
| 백그라운드 실행             | WorkManager 기반 매일 1회 heartbeat 전송                   | 백그라운드 실행 불필요 (heartbeat 전송 없음, Push 수신만)   |
| Background Mode 선언       | -                                                         | `remote-notification`만 필요 (`fetch`, `processing` 불필요) |
| 배터리 소모                | WorkManager, Foreground Service 없음 — 매일 1회 순간 기동  | 최소 (Push 수신만)                                          |
| 카테고리                   | Health & Fitness 또는 Lifestyle                            | Health & Fitness 또는 Lifestyle                             |
| 앱 설명                    | 대상자·보호자 기능 모두 안내                                | **"보호자 모니터링 앱"으로 포지셔닝** (Android 언급 금지)   |
| 심사 메모                  | -                                                         | "대상자 기기에서 자동 전송되는 안부 신호를 보호자가 모니터링하는 앱" |
| 인앱 결제                  | Google 공식 인앱 결제 API (수수료 정책 준수)               | Apple 공식 인앱 결제 API (수수료 정책 준수)                 |
| 광고                       | AdMob 공식 SDK, 하단 고정 배너만 사용                      | AdMob 공식 SDK, 하단 고정 배너만 사용                       |
| 개인정보                   | 이름/전화번호 미수집, 개인정보처리방침 최소화              | 이름/전화번호 미수집, 개인정보처리방침 최소화               |


---


## 15. 성공 지표 (클라이언트)

| 지표                        | 목표                       |
| --------------------------- | -------------------------- |
| Heartbeat 전송 성공률       | ≥ 99% (네트워크 정상 환경) |
| 거짓 경고(false alarm) 비율 | ≤ 5%                       |
| 배터리 소모                 | 하루 1% 미만 추가 소모     |
| 무료→유료 전환율            | ≥ 10% (목표)               |


---


## 16. 연동 API 목록 (BackEnd 참조)

| API                            | 메서드 | 용도                                                   |
| ------------------------------ | ------ | ------------------------------------------------------ |
| `/api/v1/users`                | POST   | 사용자 등록 (대상자/보호자)                            |
| `/api/v1/heartbeat`            | POST   | 안부 확인 heartbeat 전송                                |
| `/api/v1/subjects/link`        | POST   | 고유 코드로 대상자 연결 (보호자용)                     |
| `/api/v1/subjects`             | GET    | 연결된 대상자 목록 조회 (보호자용)                     |
| `/api/v1/subjects/{id}/unlink` | DELETE | 대상자 연결 해제 (보호자용)                            |
| `/api/v1/subscription`         | GET    | 구독 상태 확인                                         |
| `/api/v1/subscription/verify`  | POST   | 인앱 결제 영수증 검증                                  |
| `/api/v1/subscription/restore` | POST   | 구독 복원 (앱 재설치 시)                               |
| `/api/v1/alerts`               | GET    | 대상자별 경고 목록 조회 (보호자용)                     |
| `/api/v1/alerts/{id}/clear`    | PUT    | 개별 경고 클리어 (보호자가 건강 확인 후)               |
| `/api/v1/alerts/clear-all`     | PUT    | 대상자별 모든 활성 경고 일괄 클리어 + 적응형 주기 복원 |
| `/api/v1/devices/fcm-token`    | PUT    | FCM 토큰 갱신                                          |
| `/api/v1/emergency`            | POST   | 긴급 도움 요청 (대상자 → 보호자 전원 긴급 Push, body.location optional: 사용자 동의 시 lat/lng/accuracy 1회 첨부) |
| `/api/v1/app/version-check`    | GET    | 앱 버전 체크 (강제 업데이트 판정)                      |

> API 상세 스펙은 [PRD-BackEnd.md](PRD-BackEnd.md) 참조
