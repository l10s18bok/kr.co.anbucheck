# Heartbeat 감지 및 경고 플로우차트

## 경고 등급 최종 확정 테이블

| 등급 | 조건 | 발송 |
|------|------|------|
| 🚨 긴급 | 경고 3회 이상 누적 | 매일 반복, 보호자 확인까지 종료 없음 |
| 🚨 긴급 | 대상자 긴급 도움 요청 (POST /api/v1/emergency) | 즉시 1회 발송 (에스컬레이션 독립) |
| ⚠ 경고 | 미수신 2회 이상 | 1~2회 다음날 재발송 |
| ⚠ 주의 | 미수신 1회 | 1회 발송 |
| 🔵 정보 | 배터리 < 20% (마지막 heartbeat 기준) | 1회 발송, 이후 상향 없음 |
| ✅ 정보 | 보호자 수동 경고 클리어 (PUT /api/v1/alerts/clear-all) | 클리어한 보호자 제외 다른 보호자에게 1회 발송 |


## 용어 설명

| 용어 | 값 | 의미 |
|------|-----|------|
| `suspicious` | `true` | 센서 변화 없음 — 폰을 아무도 만지지 않은 것으로 의심되는 상태 |
| `suspicious` | `false` | 센서 변화 감지 — 누군가 폰을 사용한 정상 상태 |


## 1. 클라이언트 — Heartbeat 수집 및 전송

```mermaid
flowchart TD
    Start([heartbeat 트리거])
    Start --> Trigger

    Trigger{트리거 종류?}
    Trigger -->|고정 시각 Android| WM[WorkManager one-off 태스크<br/>예약 시각에 백그라운드 실행<br/>+ periodic 태스크 1시간 주기 보조<br/>실행 후 다음 날 자동 재예약]
    Trigger -->|고정 시각 iOS| BG[BGProcessingTask one-off<br/>+ BGAppRefreshTask periodic 보조<br/>OS 재량에 따라 지연 가능<br/>두 경로 모두 동일 콜백 실행]
    Trigger -->|공통| FG[앱 열기 / 포그라운드 복귀<br/>예약 시각 경과 + 오늘 미전송 시<br/>자동 heartbeat 전송]

    WM --> Collect
    BG --> Collect
    FG --> FGCheck{예약 시각 지남<br/>AND 오늘 미전송?}
    FGCheck -->|YES| Collect
    FGCheck -->|NO| End0([종료 — 이미 전송 완료])

    Collect[데이터 수집]
    Collect --> Steps[걸음수 조회<br/>pedometer<br/>steps_delta]
    Collect --> Battery[배터리 상태 조회<br/>battery_level]

    Steps --> StepsCheck{steps_delta > 0?}
    StepsCheck -->|YES| Normal[suspicious = false<br/>활동 확인]
    StepsCheck -->|NO| Sensor[가속도/자이로 조회<br/>sensors_plus]

    Sensor --> Compare{이전 센서 값과 비교}
    Compare -->|가속도 변화 < 5.0 m/s²<br/>AND 자이로 변화 < 0.3 rad/s| Suspicious[suspicious = true<br/>활동 의심]
    Compare -->|가속도 변화 ≥ 5.0 m/s²<br/>OR 자이로 변화 ≥ 0.3 rad/s| Normal

    Battery --> BattCheck{배터리 ≤ 20%?}
    BattCheck -->|YES| SubjectNoti[대상자 로컬 알림<br/>📱 충전이 필요합니다<br/>배터리가 부족합니다<br/>충전하지 않으면 안부 확인이<br/>중단될 수 있습니다]
    BattCheck -->|NO| Build

    SubjectNoti --> Build

    Suspicious --> Build
    Normal --> Build

    Build[heartbeat 데이터 구성<br/>battery_level 포함]

    Build --> Network{네트워크 연결?}

    Network -->|연결됨| Send[서버 전송<br/>POST /api/v1/heartbeat]
    Network -->|미연결| Queue[로컬 큐 저장<br/>SharedPreferences]

    Queue --> LocalNoti1[대상자 로컬 알림<br/>📱 인터넷 연결이 꺼져 있습니다<br/>안부 확인이 전송되지 않고 있으며<br/>보호자에게 경고가 발생할 수 있습니다]

    Send --> AlarmReset[로컬 안전망 알림 갱신<br/>기존 알림 취소<br/>다음날 같은 시각으로 재예약<br/>heartbeat 시각 + 30분<br/>기본 10:00, 매일 반복]

    AlarmReset --> SaveEnd[센서 값 로컬 저장<br/>완료]

    SaveEnd --> End1([종료 — 다음 주기 대기])

    LocalNoti1 --> End2([종료 — 네트워크 복구 시 재전송])
```


## 2. 서버 — Heartbeat 수신 후 판정

```mermaid
flowchart TD
    Receive([서버: heartbeat 수신])
    Receive --> UpdateLastSeen[last_seen 갱신]

    UpdateLastSeen --> TodayCheck{오늘(기기 로컬 타임존) 이미<br/>heartbeat 수신 여부?}
    TodayCheck -->|이미 수신 + suspicious=true| ForceNormal[suspicious 강제 false<br/>하루 첫 heartbeat에서만 판정]
    TodayCheck -->|첫 heartbeat| BattCheck

    ForceNormal --> BattCheck

    BattCheck{battery_level < 20%?}
    BattCheck -->|YES| BattNoti[🔵 정보 등급<br/>보호자 Push 알림 소리 없음<br/>🔋 배터리 부족<br/>충전이 필요합니다]
    BattCheck -->|NO| AlertActive
    BattNoti --> AlertActive

    AlertActive{기존 경고 활성 중?}
    AlertActive -->|YES| SuspiciousFirst{suspicious?}

    SuspiciousFirst -->|false| Resolve[경고 완전 해소<br/>보호자 Push 알림<br/>✅ 대상자의 안부 확인이<br/>정상 복귀되었습니다]
    SuspiciousFirst -->|true| Downgrade[경고 등급 하향<br/>warning / urgent → caution<br/>정상 복귀 알림 없음<br/>폰 신호만 수신, 사용 흔적 없음]

    AlertActive -->|NO| CheckSuspicious{suspicious?}
    Resolve --> StatusNormal([✅ 정상<br/>센서 움직임 감지 — 사용 확인])
    Downgrade --> WellbeingCheck

    CheckSuspicious -->|false| StatusNormal
    CheckSuspicious -->|true| WellbeingCheck[앱 로컬 알림 즉시 표시<br/>💛 안부 확인<br/>잘 지내고 계시죠? 이 메시지 알림을<br/>한 번 터치해 주세요.<br/>서버 왕복 없음 — 오프라인에서도 동작]
    WellbeingCheck --> Wait1([⏱ 다음 heartbeat 대기<br/>보호자 경고는 미수신 시에만 발생])

    StatusNormal --> SaveNoti[보호자 알림 DB 저장<br/>guardian_notifications<br/>alert_level: info<br/>is_push_sent: true/false]
    SaveNoti --> StepsNoti{steps_delta > 0?}
    StepsNoti -->|YES| StepsCompare[활동 정보 알림 DB 저장<br/>🚶 활동 정보<br/>M/D 오전/오후 HH:MM ~ M/D 오전/오후 HH:MM 사이 N보를 걸으셨습니다.<br/>Push 발송 없음]
    StepsNoti -->|NO| End3([완료])
    StepsCompare --> End3
```


## 3. 서버 — Heartbeat 미수신 시 경고 플로우

```mermaid
flowchart TD
    Scheduler([서버 APScheduler: 매 분 정각 실행<br/>CronTrigger(second=0)<br/>heartbeat 시각 + 2시간 경과 시 미수신 체크])
    Scheduler --> FindMissing[해당 시각까지<br/>heartbeat 미수신 대상자 조회]

    FindMissing --> SubActive{보호자<br/>구독 활성?}
    SubActive -->|NO| Skip([알림 미발송<br/>heartbeat는 계속 수신])
    SubActive -->|YES| CheckLastBatt{마지막 heartbeat의<br/>battery_level < 20%?}

    CheckLastBatt -->|YES| BattDead[🔵 정보 등급 판정<br/>배터리 방전 추정]
    BattDead --> BattDeadNoti[보호자 Push 알림 정보 등급 소리 없음<br/>🔋 배터리 방전 추정<br/>충전 후 자동으로 정상 복귀됩니다]
    BattDeadNoti --> BattSave[guardian_notifications DB 저장<br/>alert_level: info, is_push_sent: true]
    BattSave --> BattEnd([1회 발송 후 종료<br/>이후 미수신 지속되어도 상향 없음<br/>heartbeat 수신 시 자동 해소])

    CheckLastBatt -->|NO| MissCount{누적 미수신 횟수?}

    MissCount -->|1회| Caution[⚠ 주의 등급 판정]
    Caution --> CautionNoti[보호자 Push 알림 주의 등급<br/>⚠ 안부 확인<br/>오늘 안부 확인이 없습니다]
    CautionNoti --> CautionSave[guardian_notifications DB 저장<br/>alert_level: caution, is_push_sent: true]
    CautionSave --> NextDay0([다음 날 재확인])

    MissCount -->|2회 이상| Warning[⚠ 경고 등급 판정]
    Warning --> NightCheck1{현재 시각<br/>22:00~09:00?}

    NightCheck1 -->|NO 주간| WarningNoti[보호자 Push 알림 경고 등급<br/>⚠ 안부 확인<br/>안부 확인이 없습니다<br/>통신 불가 상태일 수 있습니다]
    NightCheck1 -->|YES 야간| Delay1([DB에 기록 후<br/>다음 날 09:00에 발송 예약])
    Delay1 --> WarningNoti

    WarningNoti --> WarningSave[guardian_notifications DB 저장<br/>alert_level: warning, is_push_sent: true]
    WarningSave --> WarningRepeat{경고 횟수?}
    WarningRepeat -->|2회 이하| NextDay1([다음 날 같은 시각에 재발송])
    WarningRepeat -->|3회 이상| UpgradeUrgent[🚨 긴급 등급으로 상향]
    UpgradeUrgent --> NightCheck2{현재 시각<br/>22:00~09:00?}

    NightCheck2 -->|NO 주간| UrgentNoti[보호자 Push 알림 긴급 등급<br/>🚨 긴급: 대상자 확인 필요<br/>즉시 확인이 필요합니다]
    NightCheck2 -->|YES 야간| Delay2([DB에 기록 후<br/>다음 날 09:00에 발송 예약])
    Delay2 --> UrgentNoti

    UrgentNoti --> UrgentSave[guardian_notifications DB 저장<br/>alert_level: urgent, is_push_sent: true]
    UrgentSave --> DailyRepeat([매일 같은 시각에 반복<br/>보호자 확인까지 종료 없음])
```


## 4. 보호자 알림 자정 정리 스케줄러

```mermaid
flowchart TD
    Midnight([서버 스케줄러: 매 분 정각 실행<br/>보호자별 로컬 타임존 자정 도달 시 처리])
    Midnight --> DeleteOld["guardian_notifications에서<br/>전날(보호자 로컬 타임존 기준) 알림 전체 삭제<br/>보호자별 타임존으로 자정 UTC 계산 후 삭제"]
    DeleteOld --> Log["[자정 알림 정리] 삭제 완료 — N건"]
    Log --> End([완료])
```

**보호자 알림 조회 흐름:**
```
보호자 앱 실행 또는 알림 목록 화면 진입
    ↓
GET /api/v1/notifications 호출
    ↓
서버: 당일(KST) guardian_notifications 반환 (시간순)
    ↓
클라이언트: is_push_sent = false 항목도 목록에 표시
    ↓
자정 이후 → 서버가 전날 알림 삭제 → 다음 날 00:00부터 새 목록 시작
```


## 5. 적응형 Heartbeat 주기 상태도

```mermaid
flowchart LR
    Normal([🟢 정상<br/>매일 고정 시각<br/>기본 09:30])
    Caution([🟡 주의<br/>미수신 1회])
    Warning([🔴 경고<br/>미수신 2회 이상])
    Urgent([⬛ 긴급<br/>경고 3회 이상 누적])

    Normal -->|미수신 1회| Caution
    Caution -->|미수신 2회| Warning
    Warning -->|3회 이상 누적| Urgent
    Caution -->|정상 heartbeat 수신| Normal
    Warning -->|정상 heartbeat 수신| Normal
```


## 6. 경고 등급 요약

```mermaid
flowchart TD
    subgraph 긴급등급[🚨 긴급 — 매일 반복, 보호자 확인까지 종료 없음]
        U1[경고 3회 이상 누적]
    end

    subgraph 경고등급[⚠ 경고 — 1~2회 다음날 재발송]
        W1[미수신 2회 이상]
    end

    subgraph 주의등급[⚠ 주의 — 1회 발송]
        C1[미수신 1회]
    end

    subgraph 정보등급[🔵 정보 — 소리 없음, 1회 발송, 이후 상향 없음]
        I1[🔋 배터리 < 20%<br/>마지막 heartbeat 수신 시 포함된 값 기준]
    end

    subgraph 야간발송제한[⏰ 야간 발송 제한 — 경고/긴급 공통]
        N1[22:00~09:00 사이 판정된 경고<br/>→ 다음 날 09:00에 발송]
    end
```


## 7. 대상자 긴급 도움 요청 플로우

> 대상자가 앱에서 직접 긴급 버튼을 눌러 보호자 전원에게 즉시 urgent 알림을 발송하는 플로우.
> 기존 heartbeat 경고 에스컬레이션(suspicious_count, days_inactive)과 완전히 독립 동작한다.

```mermaid
flowchart TD
    Start([대상자: 🚨 도움이 필요해요 버튼 탭])
    Start --> Confirm{확인 다이얼로그<br/>보호자 전원에게 긴급 알림이<br/>발송됩니다. 정말 도움을<br/>요청하시겠습니까?}

    Confirm -->|취소| End0([종료])
    Confirm -->|긴급 요청 보내기| Send[POST /api/v1/emergency<br/>device_id 전송]

    Send --> Auth{require_subject<br/>인증 확인}
    Auth -->|실패| Error([에러 — 대상자만 호출 가능])
    Auth -->|성공| CreateAlert[alerts 테이블에 즉시 생성<br/>alert_level: urgent<br/>note: emergency_request<br/>days_inactive: 0]

    CreateAlert --> SaveNoti[notification_events 저장<br/>message_key: emergency<br/>alert_level: urgent]

    SaveNoti --> FindGuardians[연결된 보호자 전원 조회<br/>guardians + devices JOIN]

    FindGuardians --> Push[보호자 전원에게 긴급 Push 발송<br/>asyncio.gather 병렬 처리<br/>DND 무시, 구독 만료 무관]

    Push --> Response([200 OK 응답<br/>긴급 알림이 전송되었습니다])

    style CreateAlert fill:#FFEBEE,stroke:#B71C1C
    style Push fill:#FFEBEE,stroke:#B71C1C
```

**긴급 도움 요청의 특성:**

| 항목 | 동작 |
|------|------|
| 경고 등급 | 즉시 urgent (caution→warning→urgent 단계 생략) |
| 기존 카운터 | suspicious_count, days_inactive 변경 없음 |
| DND | 무시 (항상 발송) |
| 구독 상태 | 무관 (만료되어도 발송) |
| 보호자 범위 | 연결된 전원 |
| 반복 발송 | 없음 (1회 즉시 발송) |
| 클라이언트 | 확인 다이얼로그로 오탐 방지 |


## 8. Heartbeat 예약 실행 계층 (WorkManager + 로컬 알림 안전망)

> **1차**: WorkManager(Android) / BGTaskScheduler(iOS)가 예약 시각에 heartbeat를 백그라운드 실행한다. one-off 태스크(정확한 시각)와 periodic 태스크(iOS: BGAppRefreshTask, Android: WorkManager 주기)를 병행 등록하여 실행 확률을 높인다. 콜백 내 `lastHeartbeatDate` 검사로 당일 중복 전송을 방지한다.
> **2차**: 앱 열기/포그라운드 복귀 시 오늘 미전송이면 자동 전송한다.
> **3차**: 로컬 알림 안전망 (heartbeat 시각 + 30분)이 OS에 의해 표시되며, 사용자가 탭하면 앱이 열린다. 알림 자체에서 heartbeat를 전송하지 않고, 홈 화면의 `onInit`/`onResumed`에서 예약시각 경과 + 미전송 시 자동 전송한다. suspicious 알림 탭 시에는 예외로 manual=true heartbeat를 즉시 재전송한다.

```mermaid
flowchart TD
    subgraph 최초설치[대상자 앱 최초 등록]
        Install([대상자 모드 선택<br/>서버 등록 완료])
        Install --> FirstWM[WorkManager one-off + periodic 태스크 예약<br/>heartbeat 시각 기본 09:30]
        FirstWM --> FirstAlarm[로컬 안전망 알림 예약<br/>heartbeat 시각 + 30분<br/>기본 매일 10:00]
    end

    FirstAlarm --> Wait

    subgraph 정상주기[정상 동작 주기]
        Wait([다음 heartbeat 대기])
        Wait -->|WorkManager/BGTaskScheduler 실행| Collect[heartbeat 수집 및 서버 전송]
        Collect --> Reschedule[다음날 같은 시각으로<br/>WorkManager 재예약 +<br/>로컬 안전망 알림 재예약<br/>heartbeat 시각 + 30분]
        Reschedule --> Wait
        Wait -->|앱 실행 또는 포그라운드 복귀| AutoSend{예약 시각 지남<br/>AND 오늘 미전송?}
        AutoSend -->|YES| Collect
        AutoSend -->|NO| ServerSync[서버에서 최신 heartbeat 시각 조회<br/>WorkManager + 로컬 알림 재예약]
        ServerSync --> Wait
    end

    Wait -->|WorkManager 미실행<br/>heartbeat 시각 + 30분 경과| Alarm

    subgraph 안전망[안전망 동작 — 로컬 알림]
        Alarm[OS가 로컬 알림 표시<br/>📱 안부 확인이 필요합니다<br/>이 메시지 알림을 한 번 터치해 주세요]

        Alarm --> UserAction{사용자 반응?}

        UserAction -->|알림 탭| AppOpen[앱 포그라운드 전환<br/>알림 자체에서 heartbeat 전송 안 함<br/>홈 화면 onInit/onResumed에서<br/>예약시각 경과+미전송 시 자동 전송]
        AppOpen --> Wait

        UserAction -->|알림 무시| Repeat[다음 날 같은 시각에 다시 알림<br/>앱을 열 때까지 매일 반복]
        Repeat --> UserAction

        Repeat -.->|동시에| ServerAlert[서버 측 미수신 경고<br/>보호자에게 Push 알림 발송<br/>→ 차트 3 경고 플로우 진입]
    end
```

**Heartbeat 예약 실행이 실패하는 상황 및 보완:**

| 상황 | WorkManager/BGTask | 앱 열기 자동 전송 | 로컬 안전망 알림 | 결과 |
|------|-------------------|-----------------|----------------|------|
| 정상 동작 (09:30) | 실행 → heartbeat 성공 | 이미 전송 완료 → 건너뜀 | 재예약되어 10:00 표시 안 됨 | 정상 |
| 앱 스와이프 종료 (Android MIUI) | **지연 또는 미실행 가능** | 앱 열면 자동 전송 | **10:00 표시 → 탭 시 복구** | 사용자가 앱을 열면 복구 |
| 앱 강제 종료 (iOS 스와이프) | **미실행** (Apple 정책) | 앱 열면 자동 전송 | **10:00 표시 → 탭 시 복구** | 사용자가 앱을 열면 복구 |
| 네트워크 장시간 불가 | 실행되나 전송 실패 → 큐 저장 | 전송 실패 → 큐 저장 | **10:00 표시** | 네트워크 복구 + 앱 실행 시 복구 |
| 알림 권한 거부 | 영향 없음 (정상 실행) | 영향 없음 (정상 전송) | **표시 불가** | WorkManager/앱 열기로 대응 |

※ 위 시각은 기본값(09:30) 기준.
※ 예약 시각 변경은 대상자 앱에서만 가능. 변경 시 WorkManager 재예약 + 로컬 안전망 알림 재예약이 동시에 수행됨.


## Mermaid 렌더링 방법

- **VS Code**: [Markdown Preview Mermaid Support](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid) 확장 프로그램 설치 → `Ctrl+Shift+V`로 미리보기
- **GitHub**: push하면 자동 렌더링
- **웹**: [Mermaid Live Editor](https://mermaid.live/)에 코드 붙여넣기
