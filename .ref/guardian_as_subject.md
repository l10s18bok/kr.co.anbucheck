# 보호자 겸 대상자 기능 (v2.0)

> 보호자가 본인도 안부 보호를 받을 수 있도록, 보호자 앱 내에서 대상자 기능을 활성화하는 기능.
> 별도 앱 재설치나 모드 전환 없이, 설정 화면에서 버튼 하나로 활성화.


## 1. 개요

### 1.1 배경
현재 앱은 "대상자 모드"와 "보호자 모드"를 최초 설치 시 선택하며, 한 기기에서 하나의 역할만 수행한다.
하지만 실제 사용 시나리오에서 **보호자 본인도 누군가에게 안부 보호를 받고 싶은 경우**가 있다:
- 1인 가구 보호자가 부모님을 보호하면서 본인도 보호받고 싶은 경우
- 부부가 서로의 안부를 확인하고 싶은 경우

### 1.2 핵심 원칙
- **기존 코드 구조 변경 최소화** — heartbeat 로직은 역할과 무관하게 이미 독립적으로 동작
- **모드 전환 아님** — 보호자 기능은 그대로 유지하면서 대상자 기능을 **추가** 활성화
- **기존 구독 모델 유지** — 나를 보호하는 보호자가 별도로 구독 (기존 정책 그대로)


## 2. 사용자 플로우

```
[보호자 앱 — 설정 화면]

설정 → 안부 수호자 카드 영역
  │
  ├─ (기본 상태) [🛡 나도 안부 보호 받기] 버튼 표시
  │
  └─ 버튼 탭 시:
      │
      ├─ 1. 안내 다이얼로그 표시
      │   "나도 안부 보호를 받으시겠습니까?
      │    안전 코드가 생성되며, 이 코드를
      │    보호자에게 전달하면 됩니다."
      │   [활성화] [취소]
      │
      ├─ 2. [활성화] 탭 → 서버 API 호출
      │   POST /api/v1/users/enable-subject
      │   → invite_code 발급 + heartbeat 스케줄 생성
      │
      ├─ 3. 권한 요청 (대상자와 동일)
      │   ├─ Android: 신체 활동 권한 (ACTIVITY_RECOGNITION)
      │   └─ iOS: NSMotionUsageDescription (이미 Info.plist에 등록됨)
      │
      ├─ 4. WorkManager/BGTask 예약 등록
      │   ├─ one-off 태스크 (다음 heartbeat 시각)
      │   ├─ periodic 태스크 (보조 안전망)
      │   └─ 데드맨 스위치 로컬 알림 (heartbeat 시각 + 30분)
      │
      └─ 5. UI 활성화 (숨겨둔 위젯 표시)
          ├─ 안전 코드 카드 (복사/공유 버튼)
          ├─ 안부 확인 상태 카드 (마지막 확인 시각)
          ├─ 예약 시각 변경 버튼
          └─ [지금 안부 보고하기] 수동 전송 버튼
```

### 비활성 상태 — 설정 화면 레이아웃 (기존과 동일)

```
┌─────────────────────────────┐
│  ⚙ 설정                     │
│                             │
│  프로필 카드                 │
│  ┌───────────────────────┐  │
│  │ 👤 안부 수호자          │  │
│  │    앱버전: v2.0.0   🌙 │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ 🛡 나도 안부 보호 받기  │  │  ← 활성화 버튼
│  └───────────────────────┘  │
│                             │
│  ── 연결 관리 ──             │  ← 보임
│  ┌───────────────────────┐  │
│  │ 👥 연결 관리            │  │
│  │ 관리 보호 대상자 수     │  │
│  │              1 / 5명    │  │
│  └───────────────────────┘  │
│                             │
│  ── 구독 및 서비스 ──        │
│  구독 카드                   │
│  알림 설정                   │
│  약관                        │
│  브랜드                      │
│                             │
│  [홈] [연결] [알림] [설정]   │
└─────────────────────────────┘
```

### 활성화 후 — 설정 화면 레이아웃

```
┌─────────────────────────────┐
│  ⚙ 설정                     │
│                             │
│  프로필 카드                 │
│  ┌───────────────────────┐  │
│  │ 👤 안부 수호자          │  │
│  │    앱버전: v2.0.0   🌙 │  │
│  └───────────────────────┘  │
│                             │
│  ── 나의 안부 보호 ──        │  ← 대상자 기능 영역
│  ┌───────────────────────┐  │
│  │  SAFETY SHARE CODE     │  │
│  │  K7M-4PXR             │  │
│  │  [복사] [공유]         │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │  ✅ 마지막 안부 확인    │  │
│  │  오전 9:30 정상 보고됨  │  │
│  │  보호자: 1명 연결됨     │  │
│  └───────────────────────┘  │
│  ┌──────────┬────────────┐  │
│  │ 🔋 배터리 │ 📶 통신상태 │  │
│  │  85%     │  연결됨     │  │
│  └──────────┴────────────┘  │
│  [📱 지금 안부 보고하기]     │
│  확인 시각: 매일 09:30       │
│  [⏰ 시각 변경]              │
│  [🚫 안부 보호 해제]         │
│                             │
│  ── 연결 관리 ──             │  ← 히든 (연결 탭에서 확인 가능)
│                             │
│  ── 구독 및 서비스 ──        │
│  구독 카드                   │
│  알림 설정                   │
│  약관                        │
│  브랜드                      │
│                             │
│  [홈] [연결] [알림] [설정]   │
└─────────────────────────────┘
```

**UI 배치 원칙:**
- 대상자 기능은 **프로필 카드 바로 아래** — "나"에 대한 설정이므로 최상단 배치
- 활성화 시 **연결 관리 카드 히든** — 연결 탭(인덱스 1)에서 동일 기능 제공, 화면 공간 확보
- 대상자 홈의 위젯(SafetyCodeCard, StatusCard, BentoGrid, ManualReportButton, HeartbeatScheduleTile) **그대로 재사용**
- 해제 시 대상자 영역 숨김 + 연결 관리 카드 복원 + [나도 안부 보호 받기] 버튼 복원

### 해제 플로우

```
[안부 보호 해제] 탭
  │
  ├─ 확인 다이얼로그
  │   "안부 보호를 해제하시겠습니까?
  │    연결된 보호자에게 더 이상
  │    안부 확인이 전송되지 않습니다."
  │   [해제] [취소]
  │
  └─ [해제] 탭 시:
      ├─ 서버 API: DELETE /api/v1/users/disable-subject
      │   → invite_code 삭제 + guardians 연결 해제
      ├─ WorkManager 예약 취소
      ├─ 데드맨 알림 취소
      ├─ 로컬 센서 데이터 삭제
      └─ UI: 대상자 영역 숨김 → [나도 안부 보호 받기] 버튼 복원
```


## 3. 서버 변경사항

### 3.1 API 추가

#### 대상자 기능 활성화
```
POST /api/v1/users/enable-subject
Headers:
  Authorization: Bearer <device_token>
Response: 200 OK
{
  "invite_code": "K7M-4PXR",
  "heartbeat_hour": 9,
  "heartbeat_minute": 30,
  "message": "안부 보호가 활성화되었습니다"
}
```

처리:
- `users` 테이블에 `invite_code` 생성 (기존 대상자와 동일한 생성 로직)
- `devices` 테이블에 `heartbeat_hour`, `heartbeat_minute` 기본값 설정
- role은 `guardian` 유지 (변경하지 않음)
- **invite_code 존재 여부**가 대상자 기능 활성화 판단 기준

#### 대상자 기능 해제
```
DELETE /api/v1/users/disable-subject
Headers:
  Authorization: Bearer <device_token>
Response: 200 OK
{
  "message": "안부 보호가 해제되었습니다"
}
```

처리:
- `users.invite_code` → NULL
- `guardians` 테이블에서 `subject_user_id = 본인` 레코드 삭제
- `alerts` 테이블에서 `subject_user_id = 본인` 삭제
- `notification_events` 테이블에서 `subject_user_id = 본인` 삭제
- `devices` 테이블의 heartbeat 관련 필드 초기화
- 연결된 보호자에게 "대상자 해제" Push 발송

### 3.2 기존 API 변경

#### GET /api/v1/devices/me 응답 확장
```json
{
  "device_id": "uuid-v4",
  "heartbeat_hour": 9,
  "heartbeat_minute": 30,
  "last_seen": "2026-04-05T09:30:00+09:00",
  "subscription_active": true,
  "subscription_plan": "yearly",
  "guardian_count": 1,
  "is_also_subject": true,
  "invite_code": "K7M-4PXR"
}
```
- `is_also_subject`: 보호자가 대상자 기능도 활성화했는지 여부
- `invite_code`: 활성화 시 안전 코드 (비활성이면 null)

### 3.3 서버 스케줄러 변경

미수신 체크 쿼리 변경:

**파일: `services/scheduler.py`**

```python
# 기존 (라인 51) — job_heartbeat_check()
WHERE u.role = 'subject'

# 변경: 대상자 + 대상자 기능 활성화된 보호자 모두 포함
WHERE u.invite_code IS NOT NULL
```

```python
# 기존 (라인 241) — job_cleanup_orphan_subjects()
WHERE u.role = 'subject'

# 변경: 보호자+대상자는 정리 대상에서 제외해야 함
WHERE u.role = 'subject' AND u.invite_code IS NOT NULL
# 또는 guardian이면서 invite_code가 있는 사용자는 제외하는 조건 추가
```

invite_code가 있으면 heartbeat를 전송하는 사용자이므로, role과 무관하게 미수신 체크 대상에 포함.

### 3.4 invite_code 생성 조건 변경

**파일: `services/user_service.py`**

```python
# 기존 (라인 73-82) — register_user()
if role == "subject":
    invite_code = _generate_invite_code()

# enable-subject API에서도 동일한 _generate_invite_code() 로직 재사용
# 기존 register_user()의 코드 변경은 불필요 — 새 API에서 별도 호출
```

### 3.5 자기 자신 연결 방지

**파일: `services/subject_service.py` — link_subject() (라인 8-59)**

현재 자기 자신 연결 방지 로직이 **없음**. 아래 검증 추가 필요:

```python
# 라인 16 이후에 추가
if subject["id"] == guardian_user_id:
    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail="자기 자신을 대상자로 연결할 수 없습니다"
    )
```

또한 현재 invite_code 조회 시 `AND role = 'subject'` 조건이 있으므로 (라인 11),
보호자+대상자의 invite_code도 조회되도록 변경 필요:

```python
# 기존 (라인 10-14)
subject = await db.fetchrow(
    "SELECT id, invite_code FROM users WHERE invite_code = $1 AND role = 'subject'",
    invite_code,
)

# 변경: role 조건 제거 (invite_code 존재 자체가 대상자 기능 활성화 의미)
subject = await db.fetchrow(
    "SELECT id, invite_code FROM users WHERE invite_code = $1",
    invite_code,
)
```


## 4. 클라이언트 변경사항

### 4.1 핵심 파일 변경 (최소)

#### heartbeat_worker_service.dart — 콜백 역할 체크
```dart
// 기존
if (role != 'subject') return true;

// 변경: 대상자이거나, 보호자+대상자 기능 활성화
final isSubjectEnabled = await tokenDs.getIsAlsoSubject();
if (role != 'subject' && !isSubjectEnabled) return true;
```

#### subject_home_controller.dart 로직 재사용
- `_checkAndSendHeartbeat()`, `_reloadLocalState()`, `_syncScheduleFromServer()` 등
  핵심 로직을 **mixin 또는 별도 서비스**로 추출
- `GuardianSettingsController`에서도 동일 로직 사용

### 4.2 로컬 저장소 추가

```dart
// TokenLocalDatasource에 추가
Future<bool> getIsAlsoSubject();           // 대상자 기능 활성 여부
Future<void> saveIsAlsoSubject(bool value);
```

- 기존 heartbeat 관련 저장 키 (`lastHeartbeatDate`, `lastHeartbeatTime`, `heartbeatHour`, `heartbeatMinute`)는 그대로 공유
- 센서 저장 키 (`lastSteps`, `accel_*`, `gyro_*`)도 그대로 사용

### 4.3 UI 변경

#### guardian_settings 화면
- `isAlsoSubject` 상태에 따라 대상자 영역 표시/숨김
- 안전 코드 카드, 상태 카드, 시각 변경, 수동 보고 버튼 — 대상자 홈 위젯 재사용

#### 신규 위젯 (공통화)
- `SubjectStatusCard` — 안부 확인 상태 카드 (대상자 홈 + 보호자 설정 공용)
- `SafetyCodeCard` — 안전 코드 표시/복사/공유 (대상자 홈 + 보호자 설정 공용)
- `ManualReportButton` — 수동 보고 버튼 (대상자 홈 + 보호자 설정 공용)

### 4.4 FCM 알림 처리

변경 없음. 보호자 앱은 이미 FCM을 수신하고 있으며:
- 보호자로서 받는 알림: 대상자 경고 Push → 기존 라우팅 그대로
- 대상자로서 받는 로컬 알림: 데드맨/suspicious → 기존 `_handleNotificationTap` 그대로


## 5. 구독 정책

기존 정책 100% 유지. 변경사항 없음.

```
[보호자 A] ──구독──→ 대상자 B, C를 모니터링
           ↑
[보호자 D] ──구독──→ 보호자 A를 대상자로 모니터링

· 보호자 A의 구독: B, C에 대한 경고 알림 수신용
· 보호자 D의 구독: A에 대한 경고 알림 수신용
· 두 구독은 완전히 독립적
```


## 6. 탈퇴 처리 (DELETE /api/v1/users/me)

보호자+대상자 사용자가 탈퇴하면 **양쪽 데이터 모두 삭제**해야 한다.
role 값을 추가하지 않고, `invite_code` 유무로 대상자 데이터 존재 여부를 판단한다.

### 탈퇴 시 삭제 흐름

```
DELETE /api/v1/users/me
  │
  ├─ 1. invite_code IS NOT NULL? (대상자 데이터 존재 여부)
  │   └─ YES → 대상자 데이터 삭제:
  │       ├─ heartbeat_logs (device_id 기준)
  │       ├─ alerts (subject_user_id = 본인)
  │       ├─ notification_events (subject_user_id = 본인)
  │       ├─ guardians (subject_user_id = 본인) — 나를 보호하는 보호자 연결
  │       ├─ devices 테이블의 센서/heartbeat 관련 데이터
  │       └─ 나를 보호하던 보호자에게 "대상자 탈퇴" Push 발송
  │
  ├─ 2. role == 'guardian'? (보호자 데이터 존재 여부)
  │   └─ YES → 보호자 데이터 삭제:
  │       ├─ guardians (guardian_user_id = 본인) — 내가 보호하는 대상자 연결
  │       ├─ guardian_notification_settings (guardian_user_id = 본인)
  │       ├─ dismissed_notifications (guardian_user_id = 본인)
  │       ├─ subscriptions (user_id = 본인)
  │       └─ 내가 보호하던 대상자에게는 별도 알림 없음
  │
  └─ 3. 공통 삭제:
      ├─ devices (user_id = 본인)
      └─ users (id = 본인)
```

### 기존 탈퇴 로직과의 차이

```
현재 (v1): role에 따라 한쪽만 삭제
  · role = 'subject'  → 대상자 데이터만 삭제
  · role = 'guardian'  → 보호자 데이터만 삭제

v2: invite_code 유무 + role 조합으로 양쪽 삭제
  · role = 'guardian' + invite_code 없음  → 보호자 데이터만 삭제 (기존과 동일)
  · role = 'guardian' + invite_code 있음  → 보호자 + 대상자 데이터 모두 삭제
  · role = 'subject'                     → 대상자 데이터만 삭제 (기존과 동일)
```

### 서버 변경 포인트

**파일: `services/user_service.py` — delete_user() 함수**

```python
# 기존: role 기반 분기
if user["role"] == "subject":
    # 대상자 데이터 삭제
elif user["role"] == "guardian":
    # 보호자 데이터 삭제

# 변경: invite_code 유무 추가 판단
if user["invite_code"] is not None:
    # 대상자 데이터 삭제 (role과 무관)
if user["role"] == "guardian":
    # 보호자 데이터 삭제
# 공통: devices, users 삭제
```

### 클라이언트 변경 포인트

**파일: `subject_home_controller.dart` — deleteAccount()**

보호자 설정 화면에서 탈퇴 시에도 동일하게:
```dart
await HeartbeatWorkerService.cancel();  // WorkManager 예약 취소
await LocalAlarmService.cancel();       // 데드맨 알림 취소
await _tokenDs.clear();                 // 로컬 토큰/센서 데이터 전부 삭제
```
기존 대상자 탈퇴 로직을 그대로 호출하면 됨.


## 7. 영향 범위 요약

### 변경 필요 (코드)

| 파일 | 변경 내용 | 규모 |
|------|-----------|------|
| `heartbeat_worker_service.dart` | 콜백 역할 체크 1줄 | 최소 |
| `token_local_datasource.dart` | `isAlsoSubject` 저장/조회 추가 | 소 |
| `guardian_settings` 컨트롤러/뷰 | 대상자 활성화/해제 + 히든 UI 토글 | 중 |
| 공통 위젯 추출 | 대상자 홈 위젯 → 재사용 가능하게 분리 | 중 |

### 변경 필요 (서버)

| 파일 | 변경 내용 | 규모 |
|------|-----------|------|
| `routers/user.py` | enable-subject, disable-subject 엔드포인트 추가 | 소 |
| `routers/device.py` | /devices/me 응답에 `is_also_subject`, `invite_code` 추가 | 최소 |
| `services/scheduler.py` | 미수신 체크 쿼리 `role='subject'` → `invite_code IS NOT NULL` | 최소 |
| `routers/subject.py` | 자기 자신 연결 방지 검증 추가 | 최소 |
| `services/user_service.py` | 탈퇴 시 invite_code 유무 판단 → 양쪽 데이터 삭제 | 소 |

### 변경 없음

| 항목 | 이유 |
|------|------|
| `heartbeat_service.dart` | 역할과 무관하게 독립 동작 |
| `fcm_service.dart` | 알림 탭 라우팅 변경 없음 |
| `local_alarm_service.dart` | 역할과 무관하게 독립 동작 |
| 구독 로직 (서버/클라이언트) | 기존 정책 그대로 |
| heartbeat API | 기존 엔드포인트 그대로 사용 |
| 보호자 대시보드 | 본인은 대상자 목록에 안 뜸 (guardians 테이블에 자기 자신 레코드 없으므로) |


## 7. 구현 순서 (권장)

```
1단계: 서버 API 추가
  ├─ POST /api/v1/users/enable-subject
  ├─ DELETE /api/v1/users/disable-subject
  ├─ GET /api/v1/devices/me 응답 확장
  ├─ 자기 자신 연결 방지
  └─ 미수신 스케줄러 쿼리 변경

2단계: 클라이언트 로컬 저장 + WorkManager 역할 체크 수정
  ├─ TokenLocalDatasource에 isAlsoSubject 추가
  └─ heartbeat_worker_service.dart 콜백 수정

3단계: 공통 위젯 추출
  ├─ SubjectStatusCard
  ├─ SafetyCodeCard
  └─ ManualReportButton

4단계: 보호자 설정 화면 UI
  ├─ [나도 안부 보호 받기] 버튼
  ├─ 활성화 시 히든 영역 표시
  └─ [안부 보호 해제] 버튼

5단계: 테스트
  ├─ 보호자 → 대상자 활성화 → heartbeat 전송 확인
  ├─ 다른 보호자가 안전 코드로 연결 → 알림 수신 확인
  ├─ 자기 자신 연결 시도 → 차단 확인
  └─ 해제 → WorkManager/알림 취소 확인
```


## 8. 주의사항

- **모드 전환이 아님**: 기존 `users.role`은 `guardian`으로 유지. `invite_code` 유무로 대상자 기능 판단
- **대상자 전용 앱과 동일한 heartbeat 로직**: 센서 수집, suspicious 판정, 데드맨 알림 모두 동일하게 동작
- **보호자 기능에 영향 없음**: 대시보드, 알림, 연결 관리 등 기존 보호자 기능은 그대로 유지
- **앱 재설치 시**: `is_also_subject` 상태는 서버 `/devices/me` 응답으로 복원 가능
