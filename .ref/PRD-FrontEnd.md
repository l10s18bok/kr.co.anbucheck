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
- **대상자**: 독거노인, 1인 가구 등 안부 확인이 필요한 분
- **보호자**: 대상자의 안전을 원격으로 확인하려는 가족, 돌봄 서비스 운영자


### 1.5 수익 모델
- **보호자가 결제**: 3개월 무료 체험 → 이후 연 $9.99 자동 갱신 구독
- **대상자 앱은 완전 무료** (결제 기능 없음)
- **대상자 최대 5명** (단일 요금, 티어 구분 없음)
- **하단 고정 배너 광고** (유료 구독 보호자는 광고 제거)


### 1.6 개인정보 보호 원칙
- 서버에 **이름, 전화번호 등 개인정보를 일절 저장하지 않음**
- 대상자-보호자 연결은 서버가 발급한 **고유 코드(invite_code)**로 매칭
- 보호자가 대상자를 식별하기 위한 별칭(예: "삼촌")은 **보호자 앱 로컬에만 저장**
- 서버 DB가 유출되어도 개인 식별 불가
- 앱 심사 시 개인정보 수집 항목 최소화 → 심사 통과 유리


### 1.7 앱 구조
하나의 앱에서 **"대상자 모드"**와 **"보호자 모드"**를 선택하는 구조:
- 대상자 모드: heartbeat 전송, 안부 확인 서비스 동작
- 보호자 모드: Push 알림 수신, 대상자 상태 확인

```
[앱 최초 실행]
Splash → 버전 체크 → 모드 선택
    │
    ├─ 버전 체크 (GET /api/v1/app/version-check)
    │   ├─ force_update = true → 강제 업데이트 다이얼로그 → 스토어 이동
    │   ├─ force_update = false → 선택적 업데이트 안내 (건너뛰기 가능)
    │   └─ 서버 응답 실패 → 건너뛰고 정상 진행
    │
    └─ 모드 선택
        ├─ "나의 안전을 확인받고 싶어요" → [대상자 모드]
        │   권한 요청 안내 화면
        │   ├─ 알림 권한 (필수)
        │   ├─ 활동 인식 권한 (Android만, 걸음수 감지용)
        │   ├─ 배터리 최적화 제외 (Android만)
        │   └─ [확인] 탭 → OS 권한 팝업 순차 표시
        │   Onboarding (서비스 소개/동작 안내) → 서버 등록 (자동) → Home (고유 코드 표시)
        │
        └─ "소중한 사람을 지켜보고 싶어요" → [보호자 모드]
            권한 요청 안내 화면
            ├─ 알림 권한 (필수)
            └─ [확인] 탭 → OS 권한 팝업 순차 표시
            서버 등록 (자동) → 대시보드 (대상자 추가 대기)
```


---


## 2. [대상자 모드] 안부 확인 아키텍처 (클라이언트 관점)

> ⚠️ **이 섹션 전체는 대상자 모드 전용입니다.**
> 보호자 모드는 heartbeat를 전송하지 않으며, 이 아키텍처와 무관합니다.
> 보호자 모드 아키텍처는 섹션 3(Push 알림 수신)을 참조하세요.

> 📊 **전체 플로우차트**: [heartbeat_flowchart.md](heartbeat_flowchart.md) 참조
> - 차트 1: 클라이언트 Heartbeat 수집 및 전송 플로우 (대상자 앱)
> - 차트 4: 적응형 Heartbeat 주기 상태도 (정상 24h → 주의 6h → 경계 3h)


### 2.1 핵심 설계 원칙 (대상자 앱)

- **매일 고정 시각** heartbeat 전송 (기본 오전 9:30, 보호자가 대상자별 변경 가능)
- 대상자 앱이 **상시 실행되지 않는** 구조 — 지정 시각에만 잠깐 깨어나 작업 후 종료
- **가속도+자이로 센서 스냅샷 비교**를 보조 활동 지표로 사용
- 보호자 앱은 heartbeat를 전송하지 않으므로 이 메커니즘이 동작하지 않음

```
┌─────────────────────────────────────────────────────┐
│                    서버 (Go)                         │
│  Android/iOS 공통: 매일 고정 시각에 FCM Silent Push 발송│
│  Android: FCM data 메시지(heartbeat_trigger)         │
│  iOS: APNs content-available: 1                     │
│  heartbeat 수신 → last_seen 갱신                     │
│  지정 시각 + 2시간 미수신 → 보호자에게 Push 경고 (3일간 반복) │
└──────────────────────┬──────────────────────────────┘
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
┌─────────────────┐      ┌─────────────────┐
│   Android 앱     │      │    iOS 앱        │
│                 │      │                  │
│ FCM Silent Push │      │ FCM Silent Push  │
│ 수신 (서버가     │      │ 수신 (서버가      │
│ 09:30 발송)     │      │ 09:30 발송)      │
│   ↓             │      │   ↓              │
│ 센서 스냅샷 조회  │      │ 센서 스냅샷 조회  │
│   ↓             │      │   ↓              │
│ heartbeat 전송   │      │ heartbeat 전송    │
│   ↓             │      │   ↓              │
│ 앱 종료          │      │ 앱 종료           │
└─────────────────┘      └─────────────────┘
```


### 2.2 OS별 안부 확인 메커니즘

|                       | Android                                                                                                           | iOS                                                                                               |
| --------------------- | ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| 주 방식               | **FCM Silent Push** (서버가 매일 고정 시각에 FCM data 메시지 발송)                                               | **FCM Silent Push** (서버가 매일 고정 시각에 APNs 발송)                                           |
| 트리거                | 서버가 지정 시각(기본 09:30)에 FCM `data` 메시지(`heartbeat_trigger`) 발송 → OS가 앱 깨움                        | 서버가 지정 시각(기본 09:30)에 APNs `content-available: 1` 발송 → OS가 앱 깨움                    |
| 백그라운드 실행       | `FirebaseMessaging.onBackgroundMessage` 핸들러                                                                    | `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)`                             |
| UI 표시               | 없음 (사용자 인지 불가)                                                                                           | 없음 (사용자 인지 불가)                                                                           |
| 보조 방식             | **로컬 알림 데드맨 스위치** (heartbeat 성공 시마다 예약 갱신, 실패 시 알림 표시하여 앱 실행 유도)                 | **로컬 알림 데드맨 스위치** (heartbeat 성공 시마다 예약 갱신, 실패 시 알림 표시하여 앱 실행 유도) |
| 앱 강제 종료 시       | **FCM Silent Push 미전달** (Android 12+ 정책 — 강제 종료된 앱에 FCM 미전달)                                      | **FCM Silent Push 미전달** (Apple 정책)                                                           |
| 앱 포그라운드 진입 시 | heartbeat 즉시 전송                                                                                               | heartbeat 즉시 전송                                                                               |


#### Heartbeat 시각 설정

**기본값:** 오전 09:30 (기기 로컬 시간대 기준, 모든 국가 공통)

| 항목                    | 값                                                                               |
| ----------------------- | -------------------------------------------------------------------------------- |
| 기본 heartbeat 시각     | **09:30** (로컬 시간대)                                                          |
| 데드맨 스위치 알림 시각 | **11:30** (heartbeat 시각 + 2시간)                                               |
| 설정 변경               | 보호자 앱에서 대상자별 변경 가능                                                 |
| 변경 반영               | 서버에 저장 → Android/iOS 공통으로 서버가 다음 FCM Silent Push 발송 시각을 변경  |

**시각 결정 근거:**
- 오전 9:30: 전 세계 고령자 대부분이 기상 후 활동 중인 시간대
- 이상 발견 시(11:30~) 보호자가 **당일 오후에 대응 가능**한 시간적 여유 확보
- 국가/지역별 차이는 최대 1시간 이내이므로 단일 기본값으로 통일

**기기 등록 시 서버 전달:**
```json
POST /api/v1/devices
{
  "device_id": "기기 고유 ID (Android: SSAID, iOS: identifierForVendor)",
  "fcm_token": "...",
  "os_type": "android",
  "timezone": "Asia/Seoul",
  "heartbeat_hour": 9,
  "heartbeat_minute": 30
}
```

**보호자 또는 대상자가 시간 변경 시:**
```json
PATCH /api/v1/devices/{device_id}/heartbeat-schedule
{
  "heartbeat_hour": 8,
  "heartbeat_minute": 0
}
```
- 대상자가 직접 변경: 데드맨 스위치 알림 시각 갱신 + 서버에 반영 → 서버가 다음 FCM Silent Push 발송 시각을 변경 (Android/iOS 공통)
- 보호자가 변경: 서버에 반영 → 대상자 기기가 다음 heartbeat 시 서버 응답에 포함된 새 시각으로 자동 반영
- iOS: 서버가 다음 Silent Push 발송 시각을 변경


#### iOS 보조 방식: 로컬 알림 데드맨 스위치 (Dead Man's Switch)

**배경 — BGTaskScheduler를 채택하지 않는 이유:**
- `BGTaskScheduler`는 iOS가 실행 시점을 **OS 재량으로 결정**하며, 등록한 주기대로 실행된다는 보장이 없음
- 배터리 상태, 사용 패턴, 시스템 부하에 따라 **수일간 실행되지 않을 수 있음**
- 사용자가 `설정 → 일반 → 백그라운드 앱 새로고침`을 끄면 **아예 동작하지 않음**
- 앱 강제 종료(스와이프) 시에도 동작하지 않음
- 결론: 매일 고정 시각의 신뢰성이 핵심인 이 앱에서는 **BGTaskScheduler에 의존할 수 없음**

**대안 — 로컬 알림 데드맨 스위치:**

iOS의 로컬 알림(`UNUserNotificationCenter`)은 **예약한 시간에 정확히 표시가 보장**되며, 앱이 강제 종료되어도 정상 동작한다. 이 특성을 활용한 데드맨 스위치 패턴을 적용한다.

```
[heartbeat 전송 성공 시마다 (Silent Push / 앱 포그라운드)]
    │
    ├─ 1. 기존 반복 알림 취소
    │     cancel(identifier: "deadman_switch")
    │
    ├─ 2. 매일 반복 로컬 알림 등록 (heartbeat 시각 + 2시간, repeats: true)
    │     UNCalendarNotificationTrigger(hour: heartbeat_hour + 2, repeats: true)
    │     ┌──────────────────────────────────────┐
    │     │ 📱 안부 확인이 필요합니다              │
    │     │                                      │
    │     │ 메시지를 터치하여 앱을 열어주세요.      │
    │     └──────────────────────────────────────┘
    │     ※ 기본: heartbeat 09:30 → 데드맨 알림 11:30
    │     ※ 2시간 여유 = Silent Push 전달 지연 감안
    │     ※ repeats: true → 사용자가 앱을 열 때까지 매일 같은 시각에 반복
    │
    └─ 3. 다음 heartbeat 성공 시 → 1번으로 돌아감 (취소+재등록 반복)

[정상 동작 시]
    매일 09:30 Silent Push → heartbeat 성공 → 알림 취소+재등록 → 다음 날 09:30 또 성공 → ...
    → 데드맨 알림(11:30)이 실제로 표시될 일 없음 (매번 리셋되므로)

[비정상 시 (Silent Push 실패, 앱 강제 종료, 네트워크 끊김 등)]
    당일 11:30 → 1차 알림 표시 (heartbeat 시각으로부터 2시간 경과)
    다음 날 11:30 → 2차 알림 표시 (사용자가 1차를 무시한 경우)
    그 다음 날 11:30 → 3차 알림 표시 ...
    → 사용자가 앱을 열 때까지 매일 같은 시각에 계속 반복
    → 사용자가 알림 탭 → 앱 실행 → heartbeat 즉시 전송 → 알림 취소+재등록
```

**로컬 알림 vs BGTaskScheduler 비교:**

|                               | 로컬 알림 반복 (채택)              | BGTaskScheduler (미채택)      |
| ----------------------------- | ---------------------------------- | ----------------------------- |
| 정시 실행                     | **보장됨**                         | 보장 안 됨 (OS 재량)          |
| 앱 강제 종료 시               | **정상 동작**                      | 동작 안 함                    |
| 백그라운드 앱 새로고침 OFF 시 | **정상 동작**                      | 동작 안 함                    |
| 사용자가 무시 시              | **매일 같은 시각에 재알림** (반복) | 1회 실행 후 OS 재량           |
| 코드 자동 실행                | 불가 (사용자 탭 필요)              | 가능                          |
| 필요 권한                     | 알림 권한 (앱에서 이미 사용)       | 없음 (설정에서 비활성화 가능) |
| 앱 심사                       | 문제 없음                          | 문제 없음                     |

**최초 설치 시 즉시 예약:**
- 대상자 모드 선택 → 서버 등록 완료 시점에 **즉시 매일 반복 알림을 등록** (heartbeat 시각 + 2시간)
- 첫 Silent Push가 도달하기 전에 앱이 강제 종료되거나 네트워크가 끊기는 경우에 대비
- 이후 첫 heartbeat 전송 성공 시 기존 반복 알림 취소 + 재등록하여 정상 주기 진입

```
[대상자 모드 최초 등록 시]
    │
    ├─ 서버 등록 완료 → 첫 heartbeat 전송
    ├─ 데드맨 스위치 매일 반복 알림 등록 (기본 11:30, repeats: true)
    │   ※ 11:30 = heartbeat 시각(09:30) + 2시간 여유
    └─ 이후부터 heartbeat 성공 시마다 취소+재등록 반복
```

**한계 및 대응 (iOS 데드맨 스위치 한정):**
- 사용자가 알림을 무시하면 앱이 열리지 않음 → 이 경우 서버가 지정 시각 + 2시간 미수신을 감지하여 보호자에게 경고 발송, 보호자가 직접 연락하여 확인
- 사용자가 알림 권한을 거부하면 동작 안 함 → 모드 선택 전 권한 요청 안내 화면(7.0)에서 알림 권한의 중요성을 안내하고, 권한 미허용 시 설정 화면에서 재요청 유도
- 알림 권한은 이 앱의 핵심 기능(보호자 경고 Push 수신)에도 필수이므로, 별도 권한 추가 부담 없음
- ※ Android도 FCM Silent Push로 전환하였으므로, iOS와 동일하게 데드맨 스위치를 적용함 (앱 강제 종료 시 FCM 미전달 대응)


### 2.3 활동 지표

**주 지표: heartbeat 수신 여부**
- 서버가 heartbeat를 수신했다는 것 자체가 **폰이 정상 동작 중**이라는 증거
- 지정 시각 + 2시간 내 heartbeat 미수신 → 경고 발생 (기본: 09:30 미수신 → 11:30 경고)

**활동 지표: 걸음수(primary) + 가속도/자이로(secondary) 결합 분석**

heartbeat가 정상 수신되더라도 사용자가 실제로 활동 중인지를 추가 판별한다.
(백그라운드에서 heartbeat가 자동 전송되므로, 사용자가 의식불명 상태여도 heartbeat는 수신될 수 있음)

```
[heartbeat 실행 시]
    │
    ├─ 1단계: 걸음수 변화 확인 (pedometer 패키지)
    │   · 이전 heartbeat 이후 걸음수 증가량(steps_delta) 조회
    │   · steps_delta > 0 → suspicious = false (즉시 정상 판정, 이하 생략)
    │
    └─ 2단계: 걸음수 변화 없을 때만 (steps_delta = 0)
        │
        ├─ 가속도계(accelerometer) 스냅샷 조회 (sensors_plus)
        ├─ 자이로스코프(gyroscope) 스냅샷 조회 (sensors_plus)
        ├─ 이전 스냅샷과 비교
        │   · 가속도 변화량 = √((Δx)² + (Δy)² + (Δz)²)
        │   · 자이로 변화량 = √((Δx)² + (Δy)² + (Δz)²)
        │
        ├─ 의심 조건 (두 조건 모두 충족 시):
        │   · 가속도 변화량 < 5.0 m/s²
        │   · 자이로 변화량 < 0.3 rad/s
        │   → suspicious = true
        │
        └─ 정상 조건 (하나라도 충족 시):
            · 가속도 변화량 ≥ 5.0 m/s²
            · 자이로 변화량 ≥ 0.3 rad/s
            → suspicious = false
```

**의심 상태(suspicious) 발생 시 서버 동작:**
- heartbeat는 정상 수신된 것이므로 즉시 경고를 발생시키지 않음
- suspicious 플래그를 서버에 기록
- **연속 2회 이상 suspicious** 상태 시 → 보호자에게 참고 알림 발송
- 보호자가 판단하여 직접 확인하도록 유도

**권한:**
- Android: `ACTIVITY_RECOGNITION` 런타임 권한 필요 (사용자 허용 필요)
- iOS: `NSMotionUsageDescription` Info.plist 등록, 첫 사용 시 팝업 자동 표시
- 가속도계/자이로스코프는 권한 불필요 (OS 기본 센서)

**센서 미지원 기기 대응:**
- 걸음수 권한 거부 시 → 가속도/자이로 단독으로 판별
- 가속도계마저 미지원 시 → 보조 지표 없이 heartbeat 수신 여부만으로 동작


### 2.4 진입점 분기

앱은 **세 가지 진입점**에 따라 다르게 동작한다:

| 진입점                                           | 동작                                             | UI 표시   |
| ------------------------------------------------ | ------------------------------------------------ | --------- |
| 사용자가 앱 아이콘 터치                          | `main()` → 전체 UI 렌더링 + heartbeat 전송       | 전체 화면 |
| 백그라운드 스케줄러/Silent Push (매일 고정 시각) | 센서 스냅샷(가속도+자이로) 조회 → heartbeat 전송 | 없음      |
| 일반 Push 알림 터치 (보호자)                     | `main()` → 대상자 상태 화면으로 이동             | 전체 화면 |

```dart
// 백그라운드 진입점 (UI 없이 실행)
@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  await sendHeartbeat();
}

// 공통 heartbeat 전송 로직 (Android/iOS 동일 Dart 코드)
Future<void> sendHeartbeat() async {
  // 1. 센서 스냅샷
  final accel = await accelerometerEvents.first;   // 가속도 (m/s²)
  final gyro = await gyroscopeEvents.first;         // 자이로 (rad/s)

  // 2. 이전 값과 비교 → 의심 상태 판별
  final prev = await loadPrevSensorData();
  bool suspicious = false;
  if (prev != null) {
    final accelDelta = calcDelta(accel, prev.accel);  // √(Δx² + Δy² + Δz²)
    final gyroDelta = calcDelta(gyro, prev.gyro);
    suspicious = accelDelta < 5.0 && gyroDelta < 0.3; // 진동 수준 = 의심
  }

  // 3. 현재 값 로컬 저장 (다음 비교용)
  await saveSensorData(accel, gyro);

  // 4. heartbeat 데이터 구성 → 서버 전송
}
```


### 2.5 Silent Push vs 일반 Push 구분

```json
// Silent Push - 안부 확인용 (사용자 모름, 대상자 기기 대상)
{
  "aps": { "content-available": 1 },
  "type": "heartbeat_check"
}

// 일반 Push - 보호자 경고용 (보호자 기기에 표시)
{
  "aps": {
    "alert": {
      "title": "안부 확인",
      "body": "대상자의 오늘 안부 확인이 없습니다. 통신 불가 상태일 수 있습니다."
    },
    "sound": "default"
  },
  "type": "alert_guardian"
}

// 일반 Push - 정상 복귀 알림 (보호자 기기에 표시)
{
  "aps": {
    "alert": { "title": "안부 확인", "body": "대상자의 안부 확인이 정상 복귀되었습니다." },
    "sound": "default"
  },
  "type": "alert_resolved"
}
```


### 2.6 경고 발생 흐름

```
[기본 heartbeat 시각 09:30 기준 예시]

Day 0, 09:30: heartbeat 정상 수신 → 안부 확인됨
Day 1, 09:30: heartbeat 미수신
Day 1, 11:30: 서버 확인 (09:30 + 2시간) → 1차 경고 (보호자에게 Push 알림)
Day 2, 09:30: heartbeat 미수신
Day 2, 11:30: 2차 경고 (보호자에게 Push 알림)
Day 3, 11:30: 3차 경고 (보호자에게 Push 알림, 최종)
Day 4+: 추가 알림 없음 (향후 정책 변경 가능)

[보호자가 경고 클리어 시]
경고 상태 → cleared (miss_count 리셋)
이후 heartbeat가 여전히 없으면 → 다음 날 같은 시각에 1차 경고부터 재시작
```

**경고 판정 기준:**
- 서버는 각 기기의 `heartbeat_hour`를 알고 있으므로, **지정 시각 + 2시간** 경과 후 미수신이면 즉시 경고 판정
- 기존 "24시간 경과 여부"를 매 1시간 폴링하는 방식 대비, **감지 속도가 대폭 단축** (최대 24시간 → 2시간)
- 경고 알림은 heartbeat 시각 + 2시간에 발송되므로, 기본값(09:30) 기준 **11:30에 보호자 알림** → 보호자가 당일 오후에 대응 가능
- 별도 시간대 제한 불필요 (heartbeat 시각 자체가 보호자 변경 가능한 활동 시간대이므로)


### 2.7 엣지 케이스 및 대응

| 상황                              | 대응                                                                                                                                                                                                                                                                                                       |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| iOS 앱 스와이프 강제 종료         | Silent Push 미전달 → 서버가 "응답 없음"으로 처리                                                                                                                                                                                                                                                           |
| Android 중국 제조사 배터리 최적화 | 설정 화면에서 배터리 최적화 제외 안내, 제조사별 가이드 제공                                                                                                                                                                                                                                                |
| 네트워크 장시간 불가 (Android)    | FCM Silent Push 수신 → 네트워크 없음 감지 → 로컬 큐에 적재 + 대상자 폰에 로컬 알림 표시 ("인터넷 연결이 꺼져 있습니다") + 복구 시 일괄 전송 → 서버가 경고 자동 해소                                                                                                                                       |
| 네트워크 장시간 불가 (iOS)        | Silent Push 미수신으로 앱이 깨어나지 않음 → heartbeat 시각 + 2시간 후 **데드맨 스위치 로컬 알림** 표시 (기본 11:30, "안부 확인이 필요합니다. 앱을 열어주세요") → 사용자가 알림 탭 → 앱 실행 → 네트워크 복구 시 로컬 큐 일괄 전송 → 서버가 경고 자동 해소. 알림 무시 시 매일 반복 + 서버 경고 플로우로 전환 |
| 기기 재부팅 (Android)             | FCM은 재부팅 후에도 OS가 자동 복구 — 별도 재등록 불필요. 단, 앱이 강제 종료 상태였다면 FCM 미전달 → 데드맨 스위치 로컬 알림으로 사용자 유도                                                                                                                                                               |
| 다중 기기 사용                    | device_id별 독립 추적, 어느 기기라도 사용하면 alive                                                                                                                                                                                                                                                        |
| 구독 만료 (보호자)                | 보호자 앱 실행 시 결제 페이지 전환 → 대상자 heartbeat는 계속 수신하되 경고 알림 발송 중단                                                                                                                                                                                                                  |
| 보호자가 앱 삭제                  | 서버가 Push 발송 실패 감지 → 대상자에게 "보호자 연결 끊김" 알림                                                                                                                                                                                                                                            |
| 대상자 앱 재설치                  | 새 계정 재등록 → 새 고유 코드 발급 → 보호자가 새 코드로 재연결 필요                                                                                                                                                                                                                                        |
| 보호자 앱 재설치                  | 새 계정 재등록 → 대상자 고유 코드 다시 입력하여 재연결                                                                                                                                                                                                                                                     |
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
  "timestamp": "2026-03-18T09:30:00+09:00",
  "steps_delta": 342,
  "suspicious": false,
  "battery_level": 85
}
```
- `steps_delta`: 이전 heartbeat 이후 걸음수 증가량 (권한 허용 시), 거부 시 null
- `suspicious`: 앱에서 판정 후 전송 (steps_delta > 0이면 항상 false)

**필요 패키지:** `pedometer` (걸음수, Android/iOS 통합), `sensors_plus` (가속도/자이로), `battery_plus` (배터리 잔량, 권한 불필요)


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
    │   └─ battery_level ≤ 10%
    │       │
    │       └─ heartbeat에 battery_level 포함하여 서버 전송
    │           → 서버: 기존 info 경고 없으면 보호자에게 정보 등급 Push 1회 발송
    │           ┌──────────────────────────────────────┐
    │           │ 🔋 대상자 폰 배터리 부족               │
    │           │                                      │
    │           │ [삼촌]의 폰 배터리가 10% 이하입니다.  │
    │           │ 충전이 필요할 수 있습니다.              │
    │           └──────────────────────────────────────┘

※ 배터리 정보 등급은 1회 발송 후 종료. 이후 미수신이 지속되어도 상향 없음
※ heartbeat 수신 시 배터리 info 경고 자동 해소
※ 배터리 충분(>20%)한 상태에서 heartbeat 끊김 → 누적 미수신 기반 경고 플로우 진행
```


### 3.3 suspicious 판정 (걸음수 primary + 가속도/자이로 secondary)

**핵심:** 걸음수 변화가 있으면 즉시 정상 판정. 걸음수 0일 때만 가속도/자이로로 보완 판정.

```
[heartbeat 수집 시 활동 판정]

    1단계: steps_delta > 0 → suspicious = false (즉시 정상, 이하 생략)

    2단계: steps_delta = 0 일 때
      의심 조건 (두 조건 모두 충족 시 suspicious = true):
        · accel_delta < 5.0 m/s²  (가속도 변화 없음)
        · gyro_delta < 0.3 rad/s  (자이로 변화 없음)

      정상 조건 (하나라도 충족 시 suspicious = false):
        · accel_delta ≥ 5.0 m/s²
        · gyro_delta ≥ 0.3 rad/s

    ※ 걸음수 권한 거부 시 → 2단계(가속도/자이로)만으로 판정
    ※ 첫 heartbeat (이전 스냅샷 없음) → suspicious = false 처리

[서버 판정]
    suspicious = false → 활성 경고 해소 여부 확인
                         ├─ 활성 경고 있었음 → 완전 해소 + 보호자 Push "정상 복귀" (정보 등급 DND 적용)
                         └─ 활성 경고 없었음
                             ├─ manual = true  → 보호자 Push "수동 안부 확인" (정보 등급 DND 적용)
                             └─ manual = false → 보호자 Push "오늘 안부 확인 완료" (정보 등급 DND 적용)
    suspicious = true  → warning/urgent → caution 하향 (정상 복귀 알림 없음)
                         → 앱 클라이언트가 FlutterLocalNotificationsPlugin으로 즉시 로컬 알림 표시
                           · 알림 ID: 0x57656C6C (고정 — 중복 발송 시 덮어씀)
                           · 메시지: "💛 안부 확인 / 잘 지내고 계시죠? 이 메시지 알림을 한 번 터치해 주세요."
                           · 서버 FCM Push 없음 — 네트워크 없어도 동작
                         - 1회 → 주의 등급 발생
                         - 2회 이상 → 경고 등급 발생
```


### 3.4 경고 등급 최종 확정 테이블

**경고 등급 체계 (4단계):**

| 등급 | 조건 | 발송 |
|------|------|------|
| 🚨 긴급 | 경고 3회 이상 누적 | 매일 반복, 보호자 확인까지 종료 없음 |
| ⚠ 경고 | 미수신 2회 이상 OR suspicious 2회 이상 | 1~2회 다음날 재발송 |
| ⚠ 주의 | 미수신 1회 OR suspicious 1회 | 1회 발송 |
| 🔵 정보 | 배터리 ≤ 10% / 자동 heartbeat 정상 수신 / 정상복귀 / 수동 heartbeat | DND 적용 (시간 외 소리, 시간 내 조용) |

```
[경고 등급별 발송 흐름]

    heartbeat 미수신 발생
        │
        ├─ battery_level ≤ 10%?
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

    suspicious 수신 (heartbeat는 수신 중)
        ├─ 1회 → 주의 등급
        └─ 2회 이상 → 경고 등급

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
│  └──┘  폰 배터리가 10% 이하입니다.            │
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
| 서버 `guardian_notifications` | 당일 발생한 모든 보호자 알림 | 당일 — 매일 00:00 KST 자정 일괄 삭제 |

**알림 종류:**
| alert_level | Push 발송 | DB 저장 | 내용 |
|-------------|-----------|---------|------|
| info | ✅ (DND 적용) | ✅ | 자동 안부 완료, 수동 안부, 정상 복귀, 배터리 부족 |
| info (걸음수) | ❌ | ✅ | 어제 vs 오늘 걸음수 비교 (steps_delta 있을 때만 생성) |
| caution | ✅ | ✅ | 미수신 1회 |
| warning | ✅ | ✅ | 미수신 2회 이상 |
| urgent | ✅ | ✅ | 미수신 3회 이상 |

**흐름:**
```
서버 heartbeat 수신 또는 미수신 판정
    ↓
guardian_notifications 테이블에 저장 (title, body, alert_level, is_push_sent)
    ↓
is_push_sent = true인 경우 → FCM Push 발송
is_push_sent = false인 경우 → DB 전용 (걸음수 정보 알림)

보호자 앱 알림 목록 화면
    ↓
GET /api/v1/notifications 호출 (당일 알림 시간순 조회)
    ↓
오늘 알림 목록 표시 (is_push_sent = false 항목도 포함)
```

**자정 정리 정책:**
- 매일 00:00 KST 서버 스케줄러가 전날 알림 전체 삭제
- 클라이언트는 로컬 DB에 알림 이력을 저장하지 않음
- 앱 삭제/기기 변경 시에도 당일 알림은 서버에서 재조회 가능

**과거 알림 (guardian_past_notifications 화면):**
- 제거됨 — 당일 알림만 제공하며 과거 이력은 유지하지 않음
- "더보기" 버튼 및 지난 알림 섹션 없음


### 3.7 선택적 안부 확인 (보호자 옵션)

**문제:** 제로 인터랙션은 핵심 원칙이지만, 실제 위험 의심 시 한 번의 대상자 응답으로 오탐을 줄일 수 있음
**핵심:** 매일 체크인이 아니라, **의심 상황에서만** 1회 발동하는 선택적 기능

```
[보호자 설정]
    │
    └─ "의심 시 안부 확인 알림" 설정
        ├─ 기본값: OFF (제로 인터랙션 유지)
        └─ ON 시 동작:

[suspicious 연속 2회 발생 시]
    │
    ├─ 대상자 폰에 알림 표시
    │   ┌──────────────────────────────────────┐
    │   │ 💛 안부 확인                           │
    │   │                                      │
    │   │ 잘 지내고 계시죠?                      │
    │   │ 확인을 한 번 터치해 주세요.             │
    │   │                                      │
    │   │          [확인]                       │
    │   └──────────────────────────────────────┘
    │
    ├─ 대상자가 [확인] 터치 또는 알림 터치
    │   → 즉시 heartbeat 전송 (suspicious = false)
    │   → 보호자에게 "정상 확인됨" 알림
    │       ┌──────────────────────────────────────┐
    │       │ ✅ 안부 확인 완료                      │
    │       │                                      │
    │       │ [삼촌]가 안부 확인에 응답했습니다.    │
    │       └──────────────────────────────────────┘
    │
    └─ 대상자가 6시간 내 미응답
        → 보호자에게 주의 등급 알림 (기존 플로우 계속)
        → 추가 안부 확인 알림 발송하지 않음 (1회만)

※ 경쟁 앱의 "매일 체크인"과의 차이:
  · 경쟁 앱: 매일 버튼 클릭 요구 → 감정적 부담 ("내 죽음을 감시하는 느낌")
  · 이 기능: 의심 상황에서만 1회 → 며칠에 한 번 또는 아예 발동 안 됨
  · 기본값 OFF → 보호자가 원할 때만 활성화
  · 알림 문구가 부드러움 ("잘 지내고 계시죠?")
```


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
- 앱 재설치 시 device_token 분실 → **재등록** (계정 복구 없음, 새 코드 발급)


### 3.4 무료 체험 기준

**보호자 기준** (대상자는 항상 무료):
- 보호자가 최초 대상자를 연결할 때 3개월 무료 체험 시작
- 동일 device_id + 앱 재설치 → 기존 무료 체험 기간 유지 (device_id로 식별)
- 다른 device_id → 새 무료 체험 허용 (기기 변경)
- Android: `Settings.Secure.ANDROID_ID` 사용 (앱 삭제해도 유지)
- iOS: `identifierForVendor` 사용 + Apple 구독 시스템이 자체적으로 무료 체험 중복 관리


### 3.5 앱 재설치 시 동작

```
[대상자 앱 재설치]
  · 로컬 데이터(device_token, 고유 코드) 소멸
  · 재등록 → 새 invite_code 발급, 새 device_token 발급
  · 기존 보호자 연결 끊어짐 → 보호자가 새 코드로 재연결 필요
  · 대상자 앱에는 결제 기능 없음 (결제는 보호자가 담당)

[보호자 앱 재설치]
  · 로컬 데이터(device_token, 대상자 별칭) 소멸
  · 재등록 → 새 device_token 발급
  · 대상자 고유 코드 다시 입력하여 재연결
  · 별칭 다시 설정 필요
  · 기존 유료 구독은 Apple/Google 구독 복원(restoreTransactions)으로 복구

※ 앱 재설치는 드문 이벤트이며, 연결 대상이 소수(1~2명)이므로
  재연결 부담이 작음. 계정 복구를 위해 개인정보를 수집하지 않는 것이
  더 큰 가치를 제공함.
```


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
- 보호자 앱 실행 → **결제 페이지로 자동 전환** (다른 화면 접근 불가)
- 대상자 heartbeat는 계속 수신하되, **경고 알림 발송 중단**
- 서버는 구독 만료 보호자에게 경고를 발송하지 않음

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

Riverpod + Dio + GoRouter 기반 클린 아키텍처 (riverpod-skill 기반)

```
lib/
├── main.dart                          # 앱 진입점 (ProviderScope 래핑)
├── app.dart                           # MaterialApp.router (ConsumerWidget)
└── app/
    ├── core/                          # ── 공통 인프라 ──
    │   ├── network/
    │   │   ├── dio_client.dart         # Dio 기반 HTTP 클라이언트
    │   │   ├── dio_interceptors.dart   # 로깅/인증 인터셉터
    │   │   ├── api_response.dart       # 공통 응답 모델 ApiResult<T>
    │   │   ├── api_error.dart          # API 에러 클래스
    │   │   └── api_endpoints.dart      # 서버 URL, API 경로 상수
    │   ├── providers/
    │   │   └── core_providers.dart     # DioClient 싱글턴 Provider (@riverpod)
    │   ├── services/
    │   │   ├── push_service.dart       # FCM/APNs 수신 처리 (Silent Push 포함)
    │   │   ├── background_service.dart # FCM Silent Push 수신 처리 / 로컬 알림 데드맨 스위치 관리 (Android/iOS 공통)
    │   │   ├── sensor_service.dart      # 가속도+자이로 센서 조회 (보조 활동 지표)
    │   │   └── ad_service.dart         # 하단 고정 배너 광고 관리
    │   ├── theme/
    │   │   ├── app_colors.dart
    │   │   ├── app_text_theme.dart
    │   │   └── app_theme.dart
    │   ├── l10n/
    │   │   ├── app_ko.arb
    │   │   └── app_en.arb
    │   ├── router/
    │   │   └── app_router.dart         # GoRouter Provider (@riverpod)
    │   ├── usecases/
    │   │   └── use_case.dart
    │   ├── utils/
    │   │   ├── constants.dart
    │   │   ├── extensions.dart
    │   │   └── device_info.dart        # 기기 고유 ID (device_info_plus), OS 구분(android/ios) 관리
    │   └── widgets/
    │       ├── banner_ad_widget.dart   # 하단 고정 배너 광고 위젯
    │       └── paywall_widget.dart     # 유료 전환 안내 위젯
    │
    ├── domain/                         # ── 순수 비즈니스 (프레임워크 의존 없음) ──
    │   ├── entities/
    │   │   ├── heartbeat_entity.dart
    │   │   ├── user_entity.dart        # role(subject/guardian), invite_code 포함
    │   │   ├── subject_link_entity.dart # 보호자-대상자 연결 정보
    │   │   ├── alert_entity.dart       # 경고 정보 (상태, 횟수, 클리어 이력)
    │   │   └── subscription_entity.dart
    │   ├── repositories/
    │   │   ├── heartbeat_repository.dart
    │   │   ├── auth_repository.dart
    │   │   ├── subject_link_repository.dart
    │   │   ├── alert_repository.dart
    │   │   └── subscription_repository.dart
    │   └── usecases/
    │       ├── send_heartbeat_usecase.dart
    │       ├── register_device_usecase.dart
    │       ├── link_subject_usecase.dart   # 고유 코드로 대상자 연결
    │       ├── clear_alert_usecase.dart
    │       └── check_subscription_usecase.dart
    │
    ├── data/                           # ── DTO + DataSource + Repository 구현체 ──
    │   ├── models/
    │   │   ├── heartbeat_model.dart    # Freezed DTO (센서 데이터 포함)
    │   │   ├── user_model.dart         # Freezed DTO (OS 타입, role, invite_code 포함)
    │   │   ├── subject_link_model.dart # Freezed DTO (연결 상태)
    │   │   ├── alert_model.dart        # Freezed DTO (경고 상태, 클리어 정보)
    │   │   └── subscription_model.dart
    │   ├── datasources/
    │   │   ├── remote/
    │   │   │   ├── heartbeat_remote_datasource.dart
    │   │   │   ├── auth_remote_datasource.dart
    │   │   │   ├── subject_link_remote_datasource.dart
    │   │   │   ├── alert_remote_datasource.dart
    │   │   │   └── subscription_remote_datasource.dart
    │   │   └── local/
    │   │       ├── heartbeat_local_datasource.dart      # 전송 실패 큐 (sqflite)
    │   │       ├── token_local_datasource.dart          # device_token 로컬 저장
    │   │       ├── sensor_local_datasource.dart          # 이전 센서 값 저장 (가속도+자이로)
    │   │       ├── nickname_local_datasource.dart        # 대상자 별칭 로컬 저장
    │   │       └── notification_local_datasource.dart   # 보호자 알림 이력 (sqflite, 30일/100건)
    │   └── repositories/
    │       ├── heartbeat_repository_impl.dart
    │       ├── auth_repository_impl.dart
    │       ├── subject_link_repository_impl.dart
    │       ├── alert_repository_impl.dart
    │       └── subscription_repository_impl.dart
    │
    └── modules/                        # ── Presentation (UI + Provider) ──
        ├── splash/
        │   ├── providers/
        │   │   └── splash_provider.dart     # 버전 체크 + 로컬 토큰 확인
        │   └── views/
        │       └── splash_page.dart
        ├── permission/                 # 권한 요청 안내 (모드 선택 전)
        │   ├── providers/
        │   │   └── permission_provider.dart
        │   └── views/
        │       └── permission_page.dart
        ├── mode_select/                # 대상자/보호자 모드 선택
        │   └── views/
        │       └── mode_select_page.dart
        │
        ├── subject/                    # ── 대상자 모드 ──
        │   ├── onboarding/
        │   │   ├── providers/
        │   │   │   └── onboarding_provider.dart
        │   │   ├── views/
        │   │   │   └── onboarding_page.dart
        │   │   └── widgets/
        │   │       ├── onboarding_step_widget.dart
        │   │       └── pricing_info_widget.dart
        │   ├── home/
        │   │   ├── providers/
        │   │   │   └── home_provider.dart
        │   │   ├── views/
        │   │   │   └── home_page.dart
        │   │   └── widgets/
        │   │       └── .gitkeep
        │   └── settings/
        │       ├── providers/
        │       │   └── settings_provider.dart
        │       ├── views/
        │       │   └── settings_page.dart
        │       └── widgets/
        │           └── .gitkeep
        │
        ├── guardian/                   # ── 보호자 모드 ──
        │   ├── dashboard/
        │   │   ├── providers/
        │   │   │   └── guardian_dashboard_provider.dart
        │   │   └── views/
        │   │       └── guardian_dashboard_page.dart
        │   ├── link_subject/           # 대상자 연결 (고유 코드 입력)
        │   │   ├── providers/
        │   │   │   └── link_subject_provider.dart
        │   │   └── views/
        │   │       └── link_subject_page.dart
        │   └── settings/
        │       ├── providers/
        │       │   └── guardian_settings_provider.dart
        │       └── views/
        │           └── guardian_settings_page.dart
        │
        └── subscription/              # ── 공통: 구독/결제 ──
            ├── providers/
            │   └── subscription_provider.dart
            ├── views/
            │   └── subscription_page.dart
            └── widgets/
                └── .gitkeep
```


### 의존성 흐름
```
┌──────────────────── Presentation ────────────────────┐
│  Notifier (@riverpod) → UseCase만 의존                │
│  Page (ConsumerWidget) → ref.watch(provider)          │
├──────────────────── Domain ──────────────────────────┤
│  Entity (순수 Dart)                                   │
│  Repository (추상 인터페이스)                           │
│  UseCase (비즈니스 로직)                               │
├──────────────────── Data ────────────────────────────┤
│  Model (Freezed DTO)                                  │
│  DataSource (API 호출 / 로컬 저장)                     │
│  RepositoryImpl (Domain 인터페이스 구현)               │
├──────────────────── Core ────────────────────────────┤
│  PushService / BackgroundService / SensorService      │
│  DioClient (ref.watch(dioClientProvider)로 주입)      │
│  GoRouter / Theme / AdService                         │
└──────────────────────────────────────────────────────┘
```


---


## 6. 플랫폼별 네이티브 코드

### Android
```
android/app/src/main/
├── kotlin/.../
│   ├── MainActivity.kt
│   └── HeartbeatFcmHandler.kt    # FCM Silent Push(heartbeat_trigger) 수신 핸들러 (백그라운드 heartbeat)
└── AndroidManifest.xml
```

### iOS
```
ios/Runner/
├── AppDelegate.swift              # Silent Push 수신 핸들러 등록
└── Info.plist                     # Background Modes: remote-notification
```


---


## 7. Flutter 핵심 패키지

| 패키지                                     | 용도                   | 비고                                                             |
| ------------------------------------------ | ---------------------- | ---------------------------------------------------------------- |
| `flutter_riverpod` + `riverpod_annotation` | 상태관리 + 코드 생성   |                                                                  |
| `dio`                                      | HTTP 클라이언트        | heartbeat API 통신                                               |
| `go_router`                                | 라우팅                 |                                                                  |
| `firebase_messaging`                       | FCM/APNs Push 수신     | Silent Push + 일반 Push                                          |
| `workmanager`                              | 백그라운드 주기적 작업 | Android 매일 고정 시각 스케줄러 (기본 09:30)                     |
| `flutter_local_notifications`              | 로컬 알림 예약/취소    | iOS 데드맨 스위치 + 배터리/네트워크 안내 알림 (Android/iOS 공통) |
| `pedometer`                                | 걸음수 조회           | **primary 활동 지표** (걸음수 변화 감지), Android: ACTIVITY_RECOGNITION 권한 필요, iOS: NSMotionUsageDescription |
| `sensors_plus`                             | 가속도/자이로 센서 조회 | **secondary 활동 지표** (걸음수 0일 때 보완), 권한 불필요       |
| `google_mobile_ads`                        | AdMob 하단 고정 배너   | 유료 사용자 광고 제거                                            |
| `shared_preferences`                       | 경량 로컬 저장소       | device_token, 이전 센서 값, 대상자 별칭 저장                     |
| `sqflite`                                  | 로컬 DB                | 전송 실패 heartbeat 큐, 보호자 알림 이력 (30일/100건)            |
| `device_info_plus`                         | 기기 고유 ID + 기기 정보 | device_id (Android: SSAID, iOS: identifierForVendor), OS 타입/버전 |
| `connectivity_plus`                        | 네트워크 상태          | 오프라인 시 전송 보류                                            |
| `freezed_annotation` + `json_annotation`   | 직렬화                 | Freezed DTO                                                      |
| `in_app_purchase`                          | 인앱 결제              | 유료 구독 전환, 구독 복원                                        |
| `lottie`                                   | Lottie 애니메이션 재생 | 온보딩, 빈 상태, 로딩 등 UI 공백 연출                            |
| `battery_plus`                             | 배터리 상태            | 배터리 잔량·충전 여부 조회, 권한 불필요                          |


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


### 8.3 Lottie 애니메이션 활용 가이드

> 무료 Lottie 소스: [LottieFiles](https://lottiefiles.com/free-animations) 에서 MIT/무료 라이선스 파일 사용
> 파일 위치: `assets/lottie/` 폴더에 JSON 파일 저장

**화면별 Lottie 배치:**

| 화면                          | 애니메이션              | 위치                           | 크기 비율 | 키워드 (검색용)                                  |
| ----------------------------- | ----------------------- | ------------------------------ | --------- | ------------------------------------------------ |
| Splash                        | 로고 펄스 또는 하트비트 | 화면 중앙                      | 40% 너비  | `heartbeat`, `pulse`, `loading`                  |
| 온보딩 Step 1 (서비스 소개)   | 가족·돌봄 일러스트      | 상단 60%                       | 전체 너비 | `family`, `care`, `protection`, `elderly`        |
| 온보딩 Step 2 (자동 감지)     | 스마트폰 자동 체크      | 상단 60%                       | 전체 너비 | `smartphone`, `automatic`, `check`, `shield`     |
| 권한 요청                     | 알림 벨 또는 설정       | 상단 40%                       | 60% 너비  | `notification`, `bell`, `settings`, `permission` |
| 모드 선택                     | 두 사람 연결            | 상단 35%                       | 70% 너비  | `connection`, `people`, `link`                   |
| 대상자 홈 (정상 상태)         | 체크마크·안심           | 상태 표시 영역                 | 30% 너비  | `success`, `checkmark`, `heart`, `safe`          |
| 보호자 대시보드 (대상자 없음) | 빈 상태 안내            | 화면 중앙                      | 50% 너비  | `empty`, `add`, `search`, `invite`               |
| 보호자 대시보드 (전원 정상)   | 안심 상태               | 목록 상단                      | 25% 너비  | `all good`, `relax`, `peace`                     |
| 구독 안내                     | 선물·프리미엄           | 상단 40%                       | 50% 너비  | `gift`, `premium`, `subscribe`, `unlock`         |
| 로딩 상태 (공통)              | 미니 로딩               | 콘텐츠 영역 중앙               | 15% 너비  | `loading`, `dots`, `spinner`                     |
| 연결 성공                     | 축하·체크               | 화면 중앙 (1.5초 후 자동 전환) | 40% 너비  | `success`, `celebrate`, `confetti`               |
| 네트워크 끊김                 | 와이파이 끊김           | 화면 중앙                      | 40% 너비  | `no wifi`, `offline`, `disconnect`               |

**Lottie 구현 규칙:**
- 반복 재생(`repeat`): Splash, 대상자 홈 정상 상태, 빈 상태, 로딩
- 1회 재생(`once`): 연결 성공, 온보딩 진입 시
- 애니메이션 아래에 간결한 텍스트 1~2줄 배치
- 애니메이션과 텍스트 사이 간격: `24dp`
- 색상이 모드 메인 컬러와 어울리는 파일 선정 (대상자=Teal 계열, 보호자=Indigo 계열)

```dart
// 사용 예시
Lottie.asset(
  'assets/lottie/onboarding_care.json',
  width: MediaQuery.of(context).size.width * 0.7,
  repeat: false,
)
```

**assets 폴더 구조:**
```
assets/
├── lottie/
│   ├── splash_heartbeat.json
│   ├── onboarding_care.json
│   ├── onboarding_auto.json
│   ├── permission_bell.json
│   ├── mode_select_connect.json
│   ├── subject_home_safe.json
│   ├── guardian_empty.json
│   ├── guardian_all_good.json
│   ├── subscription_gift.json
│   ├── loading.json
│   ├── success_celebrate.json
│   └── offline.json
└── images/
    └── app_logo.png
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

**권한 요청 안내 화면 (최초 실행 시에만 표시):**
```
┌─────────────────────────────┐
│                             │
│    [Lottie: 알림 벨]        │
│    permission_bell.json     │
│    (상단 40%, 60% 너비)     │
│                             │
│   "서비스에 필요한 권한"     │
│                             │
│   이 앱이 정상 동작하려면    │
│   다음 권한이 필요합니다.    │
│                             │
│   ✓ 알림 권한               │
│     안부 확인 결과 알림 수신  │
│                             │
│   ✓ 배터리 최적화 제외      │
│     (Android만 표시)        │
│     백그라운드 안정적 동작   │
│                             │
│         [확인]              │
└─────────────────────────────┘
```
- [확인] 탭 시 OS 권한 팝업 순차 표시 (알림 권한 → 배터리 최적화 제외)
- 권한 허용/거부 후 모드 선택 화면으로 이동
- 권한 거부 시에도 앱 사용 가능하나, 설정 화면에서 권한 재요청 유도 안내 표시
- 이미 권한이 허용된 상태(재실행 시)에는 이 화면을 건너뜀


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


### 9.2 대상자 모드 - 온보딩 (2스텝)

> 권한 요청은 모드 선택 전에 이미 완료된 상태 (9.0 참조)

```
[Step 1: 서비스 소개]
┌─────────────────────────────┐
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │  [Lottie: 가족·돌봄]  │  │
│  │  onboarding_care.json │  │
│  │  (상단 60%, 전체 너비) │  │
│  │  1회 재생             │  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│   "소중한 사람의 안전을      │
│    자동으로 확인합니다"      │
│                             │
│   스마트폰 사용 패턴으로    │
│   안녕을 자동으로 확인     │
│                             │
│         [다음 →]            │
└─────────────────────────────┘

[Step 2: 동작 방식 안내]
┌─────────────────────────────┐
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │  [Lottie: 자동 체크]  │  │
│  │  onboarding_auto.json │  │
│  │  (상단 60%, 전체 너비) │  │
│  │  1회 재생             │  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│   "별도 조작이 필요 없어요"  │
│                             │
│   · 하루 한 번 자동 확인    │
│   · 배터리 소모 최소화      │
│   · 앱을 종료하지 마세요    │
│                             │
│       [시작하기]            │
└─────────────────────────────┘
```

- [시작하기] 탭 시 서버에 자동 등록 (기기 정보만 전송)
- 등록 완료 시 고유 코드(invite_code) + device_token 수신 → 메인 화면으로 이동


### 9.3 대상자 모드 - 메인 화면

> 테마 컬러: **Teal `#009688`** 계열 적용

```
┌─────────────────────────────┐
│  [AppBar: Teal #009688]     │
│                             │
│    [Lottie: 안심 체크]      │
│    subject_home_safe.json   │
│    (30% 너비, 반복 재생)    │
│                             │
│     정상 동작 중             │
│                             │
│  나의 고유 코드              │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │      K7M-4PXR         │  │  ← 크고 명확하게 표시
│  │                       │  │
│  │      [코드 복사]       │  │
│  └───────────────────────┘  │
│  이 코드를 보호자에게        │
│  알려주세요                  │
│                             │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━ │
│  마지막 보고: 2026-03-18    │
│  14:32 KST                  │
│  서버 연결: 연결됨           │
│  보호자: 1명 연결됨          │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                             │
│  확인 시각: 매일 09:30       │
│  [⏰ 시각 변경]              │
│                             │
│  [⚙ 설정]                  │
│                             │
│  ┌───────────────────────┐  │
│  │   하단 고정 배너 광고   │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```


### 9.4 대상자 모드 - 설정 화면

```
┌─────────────────────────────┐
│        설정                  │
│                             │
│  ── 나의 정보 ──             │
│  고유 코드: K7M-4PXR [복사]  │
│  OS: Android 14             │
│  연결된 보호자: 1명          │
│                             │
│  ── 시스템 ──               │
│  [배터리 최적화 제외 설정]   │
│  [알림 권한 설정]            │
│  앱 버전: 1.0.0             │
└─────────────────────────────┘
```


### 9.5 보호자 모드 - 대시보드

> 테마 컬러: **Indigo `#3F51B5`** 계열 적용

```
[대상자가 없는 초기 상태]
┌─────────────────────────────┐
│  [AppBar: Indigo #3F51B5]   │
│      보호자 대시보드         │
│                             │
│    [Lottie: 빈 상태]        │
│    guardian_empty.json       │
│    (50% 너비, 반복 재생)    │
│                             │
│   아직 연결된 대상자가       │
│   없습니다                   │
│                             │
│   대상자의 고유 코드를       │
│   입력하여 연결하세요        │
│                             │
│  [+ 대상자 추가]             │
│                             │
│  [⚙ 설정]                  │
│                             │
│  ┌───────────────────────┐  │
│  │   하단 고정 배너 광고   │  │
│  └───────────────────────┘  │
└─────────────────────────────┘

[대상자 연결 후 - 정상 상태]
┌─────────────────────────────┐
│      보호자 대시보드         │
│                             │
│  ── 관리 대상자 ──           │
│                             │
│  ┌───────────────────────┐  │
│  │  삼촌 (로컬 별칭)     │  │
│  │  상태: 정상             │  │
│  │  마지막 확인: 3시간 전  │  │
│  │  확인 시각: 매일 09:30  │  │
│  │  [⏰ 시각 변경]         │  │
│  └───────────────────────┘  │
│                             │
│  (추가 대상자가 있으면       │
│   목록으로 표시)             │
│                             │
│  [+ 대상자 추가]             │
│  [⚙ 설정]                  │
│                             │
│  ┌───────────────────────┐  │
│  │   하단 고정 배너 광고   │  │
│  └───────────────────────┘  │
└─────────────────────────────┘

[경고 발생 시 대시보드]
┌─────────────────────────────┐
│      보호자 대시보드         │
│                             │
│  ── 관리 대상자 ──           │
│                             │
│  ┌───────────────────────┐  │
│  │  ⚠ 삼촌              │  │
│  │  상태: 경고 (2/3회)     │  │
│  │  마지막 확인: 48시간 전 │  │
│  │                       │  │
│  │  [건강 확인 완료]       │  │
│  └───────────────────────┘  │
│                             │
│  ※ 클리어 후에도 안부 확인이  │
│    없으면 다시 1차 경고부터  │
│    알림이 발송됩니다         │
│                             │
│  [+ 대상자 추가]             │
│  [⚙ 설정]                  │
│                             │
│  ┌───────────────────────┐  │
│  │   하단 고정 배너 광고   │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

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

```
┌─────────────────────────────┐
│      대상자 추가             │
│                             │
│  대상자의 고유 코드:         │
│  [___] - [____]             │
│                             │
│  별칭 (선택):               │
│  [_______________]          │
│  예: 삼촌, 아버지          │
│                             │
│  ─────────────────────────  │
│  대상자 앱의 메인 화면에     │
│  표시된 고유 코드를           │
│  입력해 주세요               │
│  ─────────────────────────  │
│                             │
│        [연결하기]           │
└─────────────────────────────┘
```

- 별칭은 **보호자 앱 로컬에만 저장** (서버 미전송)
- 별칭 미입력 시 고유 코드로 표시


### 9.7 보호자 모드 - 설정 화면

```
┌─────────────────────────────┐
│        설정                  │
│                             │
│  ── 나의 정보 ──             │
│  OS: iOS 17                 │
│  관리 대상자: 1명 / 최대 5명 │
│                             │
│  ── 구독 ──                 │
│  상태: 무료 체험 (D-72)     │
│  요금: 연 $9.99             │
│  [구독 관리]  ←── OS 구독    │
│              관리 페이지로   │
│              딥링크 이동     │
│  [구독 복원]                │
│                             │
│  ── 시스템 ──               │
│  [알림 권한 설정]            │
│  앱 버전: 1.0.0             │
└─────────────────────────────┘
```

- [구독 관리] → Apple/Google 구독 관리 페이지로 딥링크 이동 (구독 취소/변경 가능)
- [구독 복원] → 앱 재설치 후 기존 구독이 있는 경우 Apple/Google에서 복원

**대상자 heartbeat 시각 변경:**
- 보호자 대시보드 → 대상자 카드의 [⏰ 시각 변경] 탭 → 시간 선택 다이얼로그
- 선택 범위: 06:00 ~ 21:00 (30분 단위)
- 변경 시 서버에 `PATCH /api/v1/subjects/{subject_id}/heartbeat-schedule` 호출
- 대상자 기기에 변경된 시각이 다음 heartbeat 시 자동 반영됨
- 대상자 본인도 메인 화면에서 시각 변경 가능 (변경 시 서버에 반영 → 보호자 앱에도 동기화)


### 9.8 보호자 모드 - 유료 전환 안내 (3개월 만료 시)

```
┌─────────────────────────────┐
│                             │
│    [Lottie: 선물/프리미엄]  │
│    subscription_gift.json   │
│    (상단 40%, 50% 너비)     │
│                             │
│   무료 체험 기간이           │
│   종료되었습니다             │
│                             │
│   대상자 모니터링을          │
│   계속하시려면               │
│   구독이 필요합니다          │
│                             │
│   ┌───────────────────────┐ │
│   │  연 구독: $9.99/년    │ │
│   │  (대상자 최대 5명)    │ │
│   └───────────────────────┘ │
│                             │
│       [구독하기]            │
│       [구독 복원]           │
│                             │
│   ※ 구독하지 않으면         │
│     경고 알림이              │
│     발송되지 않습니다        │
└─────────────────────────────┘
```

- 보호자 구독 만료 시 보호자 앱 실행 → 이 화면만 표시 (다른 화면 접근 불가)
- 결제 완료 → 서버가 `is_active = true`로 변경 → 정상 화면 복귀
- [구독 복원] → 앱 재설치 후 기존 구독이 있는 경우 Apple/Google에서 복원
- 대상자 앱은 구독 만료와 무관하게 정상 동작 유지


---


## 10. 필요 퍼미션

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### iOS (Info.plist)
```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

> 센서 조회(`sensors_plus`)는 별도 권한이 필요하지 않다.
> 걸음 수(보조 지표)는 선택 사항이며, 사용 시에만 HealthKit/ACTIVITY_RECOGNITION 권한 추가.
> 로컬 알림(`flutter_local_notifications`)은 iOS에서 **알림 권한**(UNAuthorizationOptions)을 런타임에 요청해야 한다.
> 이 권한은 FCM Push 수신에도 필수이므로, 앱 최초 실행 시 권한 요청 안내 화면(7.0)에서 한 번만 요청하면 된다.


---


## 11. Heartbeat 전송 로직

```
[백그라운드 기동 시 (FCM Silent Push — Android/iOS 공통) — 매일 고정 시각 (기본 09:30)]
    │
    ├─ 센서 스냅샷 (sensors_plus)
    │   ├─ 가속도계 (x, y, z) + 자이로스코프 (x, y, z)
    │   └─ 이전 저장값과 비교 → suspicious 플래그 설정
    │
    ├─ heartbeat 데이터 구성
    │   {
    │     device_id, timestamp, source,
    │     accel_x, accel_y, accel_z,
    │     gyro_x, gyro_y, gyro_z,
    │     suspicious
    │   }
    │
    ├─ 네트워크 연결 확인
    │   ├─ 연결됨 → 서버 전송 (POST /api/v1/heartbeat)
    │   │   └─ 전송 성공 시:
    │   │       ├─ 데드맨 스위치 반복 알림 취소 (identifier: "deadman_switch")
    │   │       └─ 매일 반복 알림 재등록 (heartbeat 시각 + 2시간, repeats: true):
    │   │           "안부 확인이 필요합니다. 앱을 열어주세요."
    │   │           ※ 기본: 매일 11:30 (09:30 + 2시간)
    │   │           ※ heartbeat 실패 시 매일 같은 시각에 반복 표시
    │   │           ※ 다음 heartbeat 성공 시 다시 취소+재등록
    │   └─ 미연결:
    │       ├─ 로컬 큐에 저장 (sqflite)
    │       └─ 대상자 폰에 로컬 알림 표시:
    │           "인터넷 연결이 꺼져 있습니다.
    │            안부 확인이 전송되지 않고 있으며,
    │            보호자에게 경고가 발생할 수 있습니다."
    │
    ├─ 현재 센서 값(가속도 + 자이로)을 로컬에 저장 (다음 비교용)
    │
    └─ 전송 실패 시
        ├─ 로컬 큐에 pending 저장
        └─ 다음 주기 또는 네트워크 복구 시 재시도

[네트워크 복구 시]
    │
    ├─ 로컬 큐의 미전송 heartbeat 일괄 전송
    ├─ 서버가 heartbeat 수신 → 경고 자동 해소 (resolved)
    └─ 보호자에게 "정상 복귀" 알림 발송

[앱 포그라운드 진입 시]
    │
    ├─ 즉시 heartbeat 전송 (가장 확실한 안부 신호)
    ├─ 로컬 큐의 미전송 건 일괄 전송
    └─ 보호자 앱: 구독 상태 확인 → 만료 시 결제 페이지 전환
```


---


## 12. 보안 (클라이언트)

- 기기 등록 시 서버에서 발급받은 `device_token`을 `shared_preferences`에 안전하게 저장
- 모든 API 호출에 `Authorization: Bearer <device_token>` 사용
- HTTPS 필수 (TLS 1.2+)
- **개인정보 미수집**: 이름, 전화번호, 위치정보, 사용 앱 목록 등 일절 수집하지 않음
- 수집 데이터 최소화: device_id, 센서 스냅샷(가속도+자이로), 앱 버전
- 인앱 결제 영수증은 서버에서 Apple/Google 서버와 직접 검증
- 대상자 별칭은 보호자 앱 로컬에만 저장, 서버에 전송되지 않음


---


## 12. 배포

- **Android**: Google Play 스토어 (내부 테스트 → 프로덕션)
- **iOS**: App Store (TestFlight → 프로덕션)
- 최소 지원: Android 8.0 (API 26) / iOS 14.0

### 앱 심사 대응

| 심사 포인트                | 대응                                                    |
| -------------------------- | ------------------------------------------------------- |
| 백그라운드 실행 사유 (iOS) | `remote-notification`만 선언, 상시 실행 아님            |
| 배터리 소모 (Android)      | FCM Silent Push 사용, Foreground Service 없음 — 매일 1회 순간 기동 후 종료               |
| 카테고리                   | Health & Fitness 또는 Lifestyle                         |
| 인앱 결제                  | Apple/Google 공식 인앱 결제 API 사용 (수수료 정책 준수) |
| 광고                       | AdMob 공식 SDK, 하단 고정 배너만 사용                   |
| 개인정보                   | 이름/전화번호 미수집, 개인정보처리방침 최소화           |


---


## 13. 성공 지표 (클라이언트)

| 지표                        | 목표                       |
| --------------------------- | -------------------------- |
| Heartbeat 전송 성공률       | ≥ 99% (네트워크 정상 환경) |
| 거짓 경고(false alarm) 비율 | ≤ 5%                       |
| 배터리 소모                 | 하루 1% 미만 추가 소모     |
| 무료→유료 전환율            | ≥ 10% (목표)               |


---


## 14. 연동 API 목록 (BackEnd 참조)

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
| `/api/v1/app/version-check`    | GET    | 앱 버전 체크 (강제 업데이트 판정)                      |

> API 상세 스펙은 [PRD-BackEnd.md](PRD-BackEnd.md) 참조
