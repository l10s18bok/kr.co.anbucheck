# Anbu (안부) — 안부 확인 앱

독거노인·1인 가구의 안녕을 자동으로 확인하는 Android/iOS 앱.
하나의 앱에서 **대상자 모드** (heartbeat 전송, Teal 테마)와 **보호자 모드** (Push 수신, Indigo 테마)를 선택.
보호자가 **G+S(Guardian+Subject) 모드**로 대상자 역할을 겸할 수 있음.

## 플랫폼별 모드 제한

- **Android**: 대상자 모드 + 보호자 모드 모두 지원 (모드 선택 화면 표시)
- **iOS**: 보호자 모드 전용 (모드 선택 화면 스킵, Splash → 바로 권한 화면으로 이동)
  - iOS BGTaskScheduler의 불안정성(앱 스와이프 종료 시 미실행) 때문에 대상자 heartbeat 전송 신뢰성을 보장할 수 없음
  - App Store 심사 시 "보호자 모니터링 앱"으로 포지셔닝
  - 심사 메모에 Android 언급 금지 — "대상자 기기에서 자동 전송되는 안부 신호를 보호자가 모니터링하는 앱"
  - 분기 코드: `splash_controller.dart` → `Platform.isIOS` 시 `AppRoutes.permission`(guardian)으로 직행

## 기술 스택

- **Flutter** 3.41.9 / Dart 3.11.5
- **상태관리**: GetX / Clean Architecture (Presentation → Domain ← Data)
- **HTTP**: GetConnect / Dio (ApiClientFactory 패턴)
- **코드생성**: Freezed + json_serializable / flutter_screenutil (375×812 기준)
- **패키지명**: `kr.co.anbucheck.live` / pubspec name: `anbucheck`

## 프로젝트 구조
```
lib/
├── main.dart
├── app.dart
├── firebase_options.dart
└── app/
    ├── core/
    │   ├── base/           # BaseController
    │   ├── config/         # ApiConfig, AdConfig
    │   ├── mixins/         # HeartbeatScheduleMixin
    │   ├── models/         # ApiResponseModel (Freezed)
    │   ├── network/        # ApiClient, ApiClientFactory, ApiConnect, DioConnect,
    │   │                   # ApiEndpoints, ApiError, ApiResponse
    │   ├── services/       # FcmService, HeartbeatService, HeartbeatWorkerService,
    │   │                   # LocalAlarmService, GuardianSubjectService,
    │   │                   # IapService, SubscriptionService, AdService, ThemeService
    │   ├── theme/          # AppColors, AppSpacing, AppTextTheme, AppTheme
    │   ├── translations/   # 20개 언어 (ko_kr ~ id_id) + AppTranslations
    │   ├── usecases/       # UseCase 기반 클래스
    │   ├── utils/          # constants, extensions, time_utils, phone_utils,
    │   │                   # notification_text_cache, back_press_handler
    │   └── widgets/        # BannerAdWidget, GuardianBottomNav,
    │                       # HeartbeatScheduleTile, AddSubjectButton
    ├── data/
    │   ├── datasources/
    │   │   ├── local/      # TokenLocalDatasource,
    │   │   │               # HeartbeatLocalDatasource, HeartbeatLockDatasource,
    │   │   │               # NicknameLocalDatasource
    │   │   └── remote/     # UserRemoteDatasource, DeviceRemoteDatasource,
    │   │                   # HeartbeatRemoteDatasource, SubjectRemoteDatasource,
    │   │                   # EmergencyRemoteDatasource, NotificationRemoteDatasource,
    │   │                   # NotificationSettingsRemoteDatasource, VersionRemoteDatasource,
    │   │                   # SubscriptionRemoteDatasource
    │   ├── models/         # HeartbeatRequest
    │   └── repositories/   # NotificationRepositoryImpl
    ├── domain/
    │   ├── entities/       # NotificationEntity
    │   ├── repositories/   # NotificationRepository (추상)
    │   └── usecases/       # GetNotifications, DeleteAllNotifications
    ├── modules/
    │   ├── splash/
    │   ├── mode_select/
    │   ├── permission/
    │   ├── onboarding/
    │   ├── safety_home/                # S/G+S 통합 안전 홈 (role 분기, 부모 SafetyHomeBaseController + 자식 2개 + 6개 공통 위젯)
    │   ├── guardian_dashboard/         # 보호자 대시보드
    │   ├── guardian_add_subject/       # 대상자 추가
    │   ├── guardian_connection_management/
    │   ├── guardian_notifications/     # 경고 알림 목록
    │   ├── guardian_notification_settings/
    │   └── guardian_settings/
    └── routes/             # AppRoutes, AppPages
```

각 모듈은 `bindings/`, `controllers/`, `views/` 3개 파일로 구성.

## G+S (Guardian+Subject) 모드

보호자가 동시에 대상자 역할을 겸하는 모드. 두 가지 진입 경로:

1. **설정에서 활성화**: 보호자 설정 화면 → G+S 토글 → `enableSubjectFeature()` → invite_code 발급 + heartbeat 예약
2. **재설치 시 자동 감지**: 모드 선택 → `checkDevice(deviceId)` → `has_invite_code: true` → 권한 화면에 `isAlsoSubject: true` 전달

**핵심 플래그:**
- `TokenLocalDatasource.isAlsoSubject` — G+S 활성화 여부 (로컬)
- `PermissionController.needsActivityPermission` — `Platform.isAndroid && (isSubjectMode || isAlsoSubject)`
- `GuardianDashboardController._scheduleHeartbeatIfGS()` — G+S일 때만 onInit에서 서버 스케줄 재동기화 + Android는 WorkManager 재등록, **iOS는 `LocalAlarmService.schedule()` 재단언** (idempotent — `matchDateTimeComponents.time`으로 한 번 등록하면 OS가 매일 자동 반복하므로 중복 등록은 동일 ID 덮어쓰기로 안전. 재설치 시 prefs는 복원되지만 알람은 사라지므로 onInit 재단언이 필수)

**G+S 관련 컨트롤러:**
- `GuardianDashboardController` — G+S 라이프사이클 + heartbeat 자동 재전송 단독 소유: 활성화/비활성화, WorkManager/LocalAlarm 예약, `_checkAndSendHeartbeat` 미전송 체크, 안전코드 페이지 진입. **진입점 2원화**: (1) onInit/onResumed → `refreshAndSend()` → `_checkAndSendHeartbeat()` → `isReportedToday=false`일 때만 전송(`manual:false`), (2) FcmService `gs_deadman` 탭 → `refreshAndForceSend()` → `isReportedToday=false`일 때만 전송(`manual:true`), 이미 전송됐으면 전송 없이 다이얼로그만 표시(Android `subject_safety_net` 탭과 동일 패턴). `priorTime`은 탭 직전 `_captureHeartbeatStateForSafetyNet()`이 미리 캡처하므로 전송 스킵 시에도 "이미 @priorTime에 전달됨" 다이얼로그가 정확히 안내됨. Dashboard/Settings 바인딩에서 `permanent: true`로 공유 등록하여 SafetyCode에서도 `Get.find` 가능
- `GuardianSafetyCodeController` — UI 전용 (invite_code, heartbeat 스케줄 변경, 수동 보고, 긴급 요청). 보고 상태 표시는 Dashboard의 `lastHeartbeatDate`/`lastHeartbeatTime`/`isReportedToday` Rx를 구독. 수동 보고(`reportNow`) 후 `_dashboard.reloadHeartbeatState()` 호출해 카드 즉시 갱신. 긴급 요청(`sendEmergency`)은 S 홈과 동일하게 공통 헬퍼 `captureEmergencyLocation()`로 위치 획득 후 `EmergencyRemoteDatasource.send(deviceId, location: ...)` — G+S 사용자도 긴급 시 위치가 첨부됨. `locationPermissionDenied` Rx + `requestLocationPermissionAgain()`으로 긴급 버튼 아래 권한 경고 위젯 동작
- `GuardianSettingsController` — UI 전용. G+S 활성화/해제/탈퇴 시 Dashboard 컨트롤러에 위임
- `ModeSelectController` — 재설치 시 `has_invite_code`로 G+S 감지 → `isAlsoSubject` 전달

## 구독 게이팅 (보호자 모니터링 잠금)

구독 만료/체험 종료 시 **보호자 모니터링의 "시각화"만 마스킹한다**(통신 차단 아님). 상세는 PRD-FrontEnd §9.8.

- **`SubscriptionService`** (`core/services/subscription_service.dart`, Splash `permanent`, 영속값 init) — `subscription_active` 단일 반응형 소스(`RxBool isActive`). `subscription_active`를 쓰는 모든 경로(IAP verify, `/subjects`·`/devices/me` 응답)가 `set()`으로 일원화(Rx+영속 동시).
- **마스킹 위치(표시 전용)**: `/subjects`는 정상 호출(연결관리와 공유 — 통신 막아봐야 옆 탭에서 받아오므로 실효 없음)하고, **대시보드 `_mapSubjects`에서 표시값만 치환** — 만료 시 `alertLevel→'normal'`(등급 변화 숨김)·`weeklySteps→[0×7]`·`daysInactive→0`, 이름/배터리/마지막확인은 실제값. 30일 차트(`loadMonthlyStepsIfNeeded`)도 만료면 서버 호출 없이 `[0×30]`. 알림은 `load`에서 `!isActive`면 비움(빈 상태). 대시보드 상단 **만료 안내 카드**가 구독 동선([설정으로 이동]) 제공.
- **즉시 해제**: 대시보드(permanent) `ever(isActive)` true → `monthlyStepsCache.clear()` + `_loadSubjects(force)` 재매핑(캐시 실제값 즉시). 알림(lazyPut)은 탭 진입 `onInit→load` 또는 살아있으면 `ever`로 fresh. 결제는 설정(비게이트)→IAP→`/verify`(비게이트)로 항상 가능.
- **절대 건드리지 않음**: heartbeat 전송 경로(`_checkAndSendHeartbeat`/`_scheduleHeartbeatIfGS`)와 `safety_home`(guardianCount 게이팅)에는 read-gate 없음 — 대상자 본인 안부 신호는 구독 무관 계속 동작. safety_home은 `set` 쓰기만 경유.
- ⚠️ **거짓 안심 / emergency 불일치(의도)**: 만료 중 대시보드는 실제 긴급/경고 대상자도 '정상'으로 표시(거짓 안심) + 서버는 SOS를 구독 무관 발송하나 만료 보호자의 알림 목록이 차단돼 in-app에서 가려진다. 의도된 제품 결정 — 한쪽을 맞춰 "수정"하지 말 것.
- **무료체험 종료 1회 로컬 알림** (`LocalAlarmService.scheduleTrialEnded`, ID `_trialEndedId`, payload `trial_ended`): **최초 설치 보호자 전용**. onboarding `_saveAndNavigate`에서 register 직전 `checkDevice.exists==false`(첫 설치)면 가입 +90일(서버 `FREE_TRIAL_DAYS=90`과 동일, 로컬 계산)에 단발 예약(`matchDateTimeComponents` 없음, 재부팅은 `ScheduledNotificationBootReceiver`로 복원). 제목 "안부"/"Anbu", 본문 `trial_ended_noti_body`(20개 언어). 탭 → 보호자 설정(구독). **취소**: IAP verify 성공(유료 전환)·탈퇴(`deleteAccount`)에서 `cancelTrialEnded()`. 재설치·S→G+S 전환은 예약 안 함(서버 RTDN이 없는 서버 시간 기반 체험이라 푸시 대신 클라 로컬 알림으로 처리).

## 핵심 파일 (Heartbeat 3계층 구조)

이 앱의 핵심은 "사용자 조작 없이 매일 heartbeat가 확실히 전송되는 것"이다.
아래 4개 파일이 3계층 전송 구조를 각각 담당하며, 어느 하나가 망가져도 안부 확인 서비스가 무너진다.

| 계층           | 파일                                                                                              | 역할                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| -------------- | ------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 공통           | `lib/app/core/services/heartbeat_service.dart`                                                    | heartbeat 1회 실행의 전체 로직: 걸음수(steps_delta) 조회 → suspicious 판정 → **전송 전 보류 큐 저장** → 서버 전송 → 성공 시 `clearPendingIfMatches`로 큐 삭제 → `_onHeartbeatSent` housekeeping. ⚠️ **저장이 전송보다 먼저인 이유**: Doze 유지보수 창은 30초~1분이고(실측 약 64초), 창이 만료되면 워커는 `onStopJob → stopEngine()`으로 **즉시** 죽는다. lmkd(저메모리 킬러)도 같은 결과를 낸다(2026-08-18 실측: 워커가 시작 0.73초 만에 사망). 전송 뒤에 저장하면 그 죽음에 걸린 날은 걸음수가 통째로 사라진다. 삭제는 반드시 `clearPendingIfMatches`로 — 무조건 `clearPending()`을 부르면 그 사이 다른 isolate가 저장한 **남의 메모를 지운다**. **전송 예산은 20초 데드라인**(`_sendDeadline`)으로 창 안에 묶고, 연결 자체가 안 되는 실패(`HeartbeatSendException.isUnreachable`)면 백오프를 생략한다 — 도달 불가 상태에서 5초·10초를 쉬는 것은 창 예산만 태운다. **`execute()`는 서버 도달 여부를 `bool`로 반환한다** — `_busy` 스킵·락 실패·전송 실패가 모두 `false`다. 반환값을 무시하는 새 호출부를 추가할 때는 그 경로가 사용자에게 성공을 주장하지 않는지 확인할 것(과거 `reportNow`가 아무것도 안 보내고 "안부를 전했습니다"를 띄우며 하루 1회 제한까지 소모했다). **`_sendPendingInternal`의 마커 규칙 (보류 큐가 남의 슬롯을 먹지 않게)**: 보류 payload의 **날짜가 오늘일 때만**(`heartbeatPayloadIsFromToday` — `scheduled_key` 앞 10자, 없으면 `timestamp`의 로컬 날짜. ⚠️ 예약시각은 `_syncScheduleFromServer`로도 바뀌므로 **키 문자열 전체를 비교하면 안 된다** — 오늘 payload가 지난 기록으로 오분류돼 같은 날 기록 2건이 서버에 도착하고 `auto_report` Push가 중복된다) `lastHeartbeatDate`/`lastScheduledKey`를 찍고 `_onHeartbeatSent`를 부른다(오늘 18:00 실패 → 18:15 periodic이 큐를 비우는 정상 경로). **지난 날짜 키면 마커를 찍지 않고** 큐 비우기 + `cancelSendFailed`/`cancelSubjectSafetyNet`만 한다 — 어제 기록을 보냈다고 오늘 슬롯까지 소비하면 뒤이어 실행되는 `_executeInternal`이 키 일치로 스킵되어 **그날 걸음수가 통째로 누락**된다(막대 0). 마커를 비워두면 같은 `execute()` 안에서 오늘 heartbeat가 따로 나가고, 서버가 두 기록을 각자의 날짜에 귀속시킨다. 재예약도 여기서 하지 않는다(뒤따르는 오늘 전송의 성공 경로가 담당). ⚠️ **서버 측 짝 규칙**: 서버는 `scheduled_key`의 날짜가 도착일보다 **엄격히 과거**일 때만(`<` — 타임존/시계 오차로 날짜가 앞서는 경우를 당일 처리로 흘려보내기 위함) "지난 기록 보정"으로 분류해 이력 적재 + 경고 해소(+활동 증명 시 suspicious 카운터 리셋)만 하고 `auto_report`·`오늘 N보`·suspicious 에스컬레이션·배터리 부족 Push를 생략한다(`anbucheck-server/services/heartbeat_keys.py`). 이 클라 변경은 그 서버 규칙이 배포된 뒤에만 안전하다. **`_onHeartbeatSent` (전송 성공 직후 단일 책임 — 자동/수동/pending 큐 모든 성공 경로 공통)**: (a) **iOS 알람 미처리** — iOS 안전망 알림은 `matchDateTimeComponents.time`으로 한 번 등록하면 OS가 매일 자동 반복하므로, heartbeat 성공 후 재등록·취소가 불필요하다. 등록 시점: 최초 설치(`enableSubjectFeature`/온보딩), 재설치(`_scheduleHeartbeatIfGS` onInit — 같은 ID 덮어쓰기 idempotent), 예약시각 변경(`onHeartbeatTimeChanged`). `_onHeartbeatSent`는 iOS 알람을 건드리지 않는다. **Android는 `schedule()`이 cancel-only no-op** — Android 일일 로컬 안전망 알림은 폐지되고 **서버 FCM 푸시 `subject_safety_net`(서버 미수신 체크 = heartbeat 예약시각 +2h)로 이관**됐다(폐지 사유: heartbeat+3h + `matchDateTimeComponents.time` 조합이 forceNextDay로 날짜를 내일로 밀어도 "그 시각의 다음 발생=오늘"로 당겨 정상 전송한 날에도 매일 오발화하던 결정적 버그. iOS는 0h offset이라 무관. Android의 cancel은 업그레이드 기기에 남은 잔존 버그 알림 정리 역할), (b) Android `HeartbeatWorkerService.schedule(hour, minute)` 호출 → one-off + periodic **둘 다 cancel + 내일자 register** (worker 콜백은 schedule()을 호출하지 않음. 단일 책임 분리로 한 번의 worker fire에서 cancel+register mutation이 4건 발생하던 부작용 제거. **단 `_onHeartbeatSent`는 전송 성공 경로 전용**이라 여기서만 풀 `schedule()`로 periodic까지 내일로 재워 배터리를 아낀다. **전송 실패 시에는** `_sendOrSavePending`/`_sendPendingInternal`이 `_rescheduleNextDay(success: false)` → `HeartbeatWorkerService.rescheduleOneOffOnly()`로 **one-off만 내일자로 재무장하고 periodic 15분 폴링은 살려둔다** — 살아있는 periodic이 같은 날 통신 복구를 15분 내 잡아 보류 큐를 비운다. 실패 분기가 풀 schedule()을 불러 periodic을 내일로 밀면 일시적 통신 장애가 그날의 15분 안전망을 통째로 해체한다(Defect 1) — **이 성공/실패 분기를 다시 합치지 말 것**), (c) Android `LocalAlarmService.cancelSendFailed()` 호출 → retry 3회 실패 시 띄웠던 stale "전송 실패" 알림 제거. (d) Android `LocalAlarmService.cancelSubjectSafetyNet()` 호출 → 서버 FCM 푸시 `subject_safety_net` 잔존 알림 제거 (`getActiveNotifications()`로 `tag="anbu_safety_net"` 알림 실제 ID 조회 후 `cancel(id, tag:)` — WorkManager 백그라운드 isolate에서도 `_ensureInitialized()`로 동작. 회복 전송은 `_onHeartbeatSent`를 호출하지 않으므로 미처리되나 이후 정시 전송 성공 시 정리됨). **suspicious 판정 우선순위**: (1) `manual=true` → false, (2) `steps_delta > 0` → false (하루 전체 활동 확정), (3) `isInteractiveAtTrigger=true` → false (worker fire 시점 화면 깨어있음 = 최근 기기 사용 신호), (4) 그 외 → true (걸음 기록도 없고 발화 시점 기기 미사용 = 활동 증거 부재). **두 신호의 범위 비대칭 주의**: `steps_delta`는 오늘 자정~현재 누적(하루 전체), `isInteractiveAtTrigger`는 worker fire **순간**의 1회 스냅샷이다. `isInteractive=true`는 발화 시점 살아있는 신호지만 `isInteractive=false`는 "하루 종일 안 썼다"가 아니라 "그 순간 안 썼다"일 뿐이므로, 보호자 알림 문구는 "폰 사용 흔적" 대신 "활동 기록"으로 순화되어 있다(noti_*_suspicious_body 계열). `isInteractiveAtTrigger`는 worker 콜백에서 `ScreenState.isInteractive()`로 조회해 전달하며, 포그라운드 호출부(홈 자동 전송·수동 보고·G+S 활성화 첫 전송)는 앱이 포그라운드에 있다는 것 자체가 interactive 증거이므로 항상 `true`를 명시 전달한다. 가속도/자이로/지자기는 Android 9+ 백그라운드 제한으로 WorkManager에서 항상 null이므로 제거됨. 오탐/미탐, 중복 전송, 데이터 누락 모두 이 파일에서 발생                                                                                                                                                                                                        |
| 1차            | `lib/app/core/services/heartbeat_worker_service.dart`                                             | WorkManager 백그라운드 예약 실행 (Android 전용). ⚠️ **불변 규칙 — 재무장을 네트워크보다 먼저 한다.** 콜백은 role 확인·스케줄 로드 직후 `rescheduleOneOffOnly()`를 **무조건** 호출하고, 그 뒤에야 걸음수·전송으로 넘어간다. 창 만료나 lmkd 킬로 워커가 중도에 죽어도 다음 날 트리거가 살아남게 하기 위함이다(2026-08-18 15:07 실측: 재무장이 킬 **105ms 전**에 완료되어 생존). 성공 경로의 `_onHeartbeatSent → schedule()`이 나중에 같은 값으로 다시 등록해도 dated 이름이라 idempotent다. 2계층 구조 — (a) one-off: 예약시각에 정확히 1회 fire, (b) periodic 15분: 안전망 폴링 (one-off 누락 시 백업 발화 + 화면 켜짐 Doze 해제 piggyback). ⚠️ **"15분 내"는 사실이 아니다** — 실측 cadence는 딥 Doze에서 **하룻밤 1~5회**다(창 간격이 1→2→4→6시간으로 배증). RARE 버킷이면 24시간에 **3세션**이 상한이라 하루 96회라는 전제 자체가 성립하지 않는다. 그럼에도 폴링의 가치는 실증됐다 — 2026-08-18 15:22 전송을 성공시킨 것이 periodic이었다. 상세는 `.claude/rules/android_scheduling_field_notes.md`. 두 task 모두 전송 성공 시 `_onHeartbeatSent`가 `HeartbeatWorkerService.schedule()`로 cancel+register하여 내일자로 재등록(periodic도 내일로 재워 밤샘 폴링 off → 배터리 절약)하며, worker 콜백은 schedule()을 호출하지 않는다 (이전 안전망 패턴 제거: 한 번의 worker fire에서 cancel+register mutation이 4건 발생하던 부작용 차단). **단 풀 `schedule()`은 성공 경로 전용**이다 — **전송 실패 시에는** `_rescheduleNextDay(success: false)` → `rescheduleOneOffOnly()`로 **one-off만 내일자로 재무장하고 periodic 15분 폴링은 유지**해 같은 날 통신 복구를 15분 내 잡는다(실패 분기가 풀 schedule()을 부르면 일시적 통신 장애가 그날 안전망을 해체 — Defect 1, 합치지 말 것). 또한 **전송이 한 번도 성공하지 못한 기간 동안에는 살아있는 periodic 15분 폴링이 재시도를 담당**한다(실패 분기가 periodic을 끄지 않으므로 cadence 유지). one-off은 fire 후 `rescheduleOneOffOnly`로 다음 정시에 재무장된 채 함께 대기한다. ⚠️ **망 제약(`NetworkType.connected`)은 제거됐다** — 제약이 있으면 망이 없는 동안 worker가 **시작조차 하지 않아** 그날 걸음수를 메모할 기회가 사라진다(2026-08-17 실측: 망 없는 하루 동안 발화 0회, 보류 큐도 비어 데이터 영구 소실). 지금은 망 없이도 발화해 걸음수를 수집하고 메모를 남긴 뒤 실패한다. ⚠️ **self-cancel 금지 — 실측 확인된 결함이다.** 실행 중인 worker가 자기 unique work를 `cancelByUniqueName`하면 `BackgroundWorker.onStopped() → stopEngine()`이 FlutterEngine을 파괴해 **바로 다음 줄의 재등록이 실행되지 않는다**(2026-08-18 02:16 실측: `Work [...] was cancelled` 직후 재등록 로그 없음 → one-off 영구 유실). 그래서 one-off은 **대상 날짜를 unique name에 넣어**(`heartbeat_scheduled_<yyyy-MM-dd>`) 취소 대상이 자기 자신이 될 수 없게 하고, periodic은 **자기 자신이면 재등록을 건너뛴다**(`runningUniqueName` 판별). 취소를 다시 넣지 말 것. execute 호출 직전 `ScreenState.isInteractive()`(Android PowerManager 커스텀 플러그인)를 1회 조회해 `HeartbeatService.execute(isInteractiveAtTrigger: ...)`로 전달 — Doze maintenance window에서 화면 꺼진 채 자연 fire(false)와 화면이 깨어있는 상태에서 fire(true)를 구분해 suspicious 판정에 반영. **콜백 진입 시각 가드**: 콜백은 `scheduled = 오늘 hour:minute` 기준으로 시각을 판정한다 — `lastHeartbeatDate == 오늘`이면 스킵(오늘 정시 전송 완료), `예약시각 -15분` 이후면 정상 정시 전송(`execute(isInteractiveAtTrigger: ...)`), `예약시각 -15분` 이전이면 평소엔 스킵하되 **회복 전송 예외**가 적용된다 — ⚠️ 이 가드의 근거를 "periodic +3분 offset의 조기 발화 흡수"로 적지 말 것. 실측상 **job은 일찍 뛰지 않는다. 늦게만 뛴다**(예약시각 +수 분~수 시간). 이 가드가 실제로 하는 일은 **지난 날짜용으로 등록됐다가 뒤늦게 발화한 job을 오늘 정시 전송으로 오인하지 않는 것**이다. **worker 회복 전송**(`execute(recovery: true)` — **정시 슬롯 미소비**): 예약시각 이전 구간에서 `lastHeartbeatDate`가 오늘도 어제도 아닌 2일 이상 미전송 갭이면 예약시각을 기다리지 않고 살아있음 신호를 보낸다(전용 키 `recovery_<날짜>`, `steps_delta=null`, `suspicious=false`, 마커 `lastRecoveryDate`로 1일 1회). **`lastHeartbeatDate`를 갱신하지 않으므로 예약시각 정시 전송이 그대로 수행되어 그날 걸음수가 온전히 기록된다** — 과거에는 정시 키로 전송해 슬롯을 소비했고, 그 탓에 정시 전송이 콜백 상단 `lastHeartbeatDate == 오늘` 가드에 걸려 **그날 걸음수가 폰을 켠 시각까지만**(이른 아침이면 사실상 0) 기록되던 결함이 있었다 — 포그라운드 회복 전송과 다시 갈라놓지 말 것. 재무장은 이 분기가 아니라 **콜백 진입부에서 네트워크보다 먼저** 무조건 수행된다(아래 참조). iOS는 worker가 없어 미적용(Android 전용). **포그라운드 진입 시 회복**(`SubjectHomeController._isRecoveryPending`)도 완전히 동일한 `_executeRecovery` 경로를 쓴다. **connectivity_plus의 Doze 오판 주의**: `connectivity_plus.checkConnectivity()`가 Doze 상태에서 오프라인으로 잘못 판단하는 케이스가 있어 사전 네트워크 체크를 제거했다(커밋 56f38e8). **다시 넣지 말 것** — 오판이 정상 전송을 보류 큐로 빠뜨린다. 도달 가능 여부는 전송 시도 결과로만 판정한다(망 제약도 제거됐으므로 발화 사실은 온라인의 근거가 되지 않는다). retry 3회 모두 실패 시 자동 경로(`manual=false`)는 `LocalAlarmService.notifySendFailed()`로 사용자 안내 알림 표시(payload 무시 — 탭하면 앱 포그라운드 전환만, 홈 컨트롤러의 자동 재전송이 처리). iOS는 BGTaskScheduler 불안정성으로 사용하지 않음 |
| 2차            | `lib/app/modules/safety_home/controllers/subject_home_controller.dart`                            | 앱 열기/복귀 시 안전망. onInit/onResumed에서 **예약시각 경과 + 당일 미전송**이면 자정 전까지 무조건 자동 전송. 가드는 `isReportedToday`(이미 전송 차단) + Android의 `isScheduleInFuture`(예약시각 이전 차단) 두 개로 단순화 — 자정이 유일한 의미 경계. iOS S/G+S는 시각 가드 자체가 없음(`Platform.isAndroid &&` 조건). `isScheduleInFuture`에 막혀도 `_isRecoveryPending`(`lastHeartbeatDate`가 오늘도 어제도 아닌 미전송 갭)이면 1차 worker와 동일한 **회복 전송**(`HeartbeatService().execute(recovery: true)`)을 보낸다 — 포그라운드 진입 자체가 살아있음 증거라 worker처럼 화면 활성 게이트는 두지 않으며, 정시 슬롯을 소비하지 않아 예약시각 정시 전송은 그대로 수행된다. 이전에 있던 `isScheduleTooOld`(예약 +3h 초과 차단) 가드는 보호자 stale 경고 방지 효과보다 늦은 정상 복귀 차단의 부작용이 커서 제거됨 — 21:30이든 23:50이든 사용자가 앱을 연 행위 자체가 강한 alive 신호이고, 늦은 전송 성공 시 `_onHeartbeatSent`가 WorkManager를 즉시 내일자로 재등록해 정시 사이클이 정상화된다. **첫 설치 시 시각 가드 우회**: `lastHeartbeatDate.isEmpty`이면 `isScheduleInFuture`까지 건너뛰고 즉시 전송 — Google Fit 구독 생성 + last_seen baseline + 파이프라인 검증을 한 번에 처리해 D0 갭 해소. `SafetyHomeBaseController`(abstract) 상속 자식 — 부모는 invite_code·schedule·권한·배터리·네트워크·reportNow·sendEmergency 공통 로직, 자식은 `lastHeartbeatDate/Time` 자기 Rx + Drawer/탈퇴/모드전환/휴면 다이얼로그 담당. **안전코드 페이지 기능 활성화(보고/긴급/헤더 배지)는 `guardianCount > 0`만으로 판정 — 구독 상태와 무관(연결된 보호자가 있으면 구독 만료여도 동작, 새로고침은 항상 동작). 과거 `isGuardianConnected`(=`subscription_active` misnamed Rx)로 게이팅해 G+S 구독 만료 시 페이지가 마비되던 버그를 수정하며 해당 Rx 제거.** ⚠️ **시각 변경(`ScheduleRowButton`)만은 게이팅에서 제외 — 항상 활성**이다(`enabled: true` 하드코딩). 보고/긴급을 막는 이유는 "받을 보호자가 없는데 전달됐다고 믿게 하는 거짓 안심" 차단인데, 시각 변경은 전달 동작이 아니라 설정이라 그 위험이 없다. 게다가 스케줄은 보호자 유무와 무관하게 이미 동작 중이라(WorkManager 발화 → heartbeat 전송 → 걸음수 적재) 막으면 이미 적용 중인 값을 못 바꾸게 된다. 되돌리면 야간 노동자가 기본값 18:00인 채 보호자를 연결하게 되어(그 시각엔 수면 → steps=0 + 화면 꺼짐 → `suspicious=true`) **보호자의 첫 알림이 거짓 경고**가 된다. 세 버튼을 다시 하나의 게이트로 묶지 말 것. G+S 자식(`GuardianSafetyCodeController`)은 같은 디렉토리에 위치하며 Dashboard에 위임                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| 3차 (안전망)   | **iOS**: `lib/app/core/services/local_alarm_service.dart` / **Android**: 서버 FCM 푸시 `subject_safety_net` (`anbucheck-server/services/scheduler.py`)                                                  | 일일 안부 확인 안전망. **iOS**: `LocalAlarmService`가 heartbeat 예약 시각 정시에 매일 로컬 알림(payload `gs_deadman`, `matchDateTimeComponents.time`) — BGTaskScheduler 미사용으로 사실상 PRIMARY 트리거. heartbeat 성공 후 재등록·취소 없음 — `matchDateTimeComponents.time`으로 OS가 매일 자동 반복하므로 불필요하다. `_onHeartbeatSent`는 iOS 알람을 건드리지 않는다. **Android**: 일일 로컬 안전망 알림 **폐지** — `LocalAlarmService.schedule()`은 Android에서 기존 알림 cancel 후 즉시 return(업그레이드 기기 잔존 버그 알림 정리). 대신 **서버**가 미수신 체크(heartbeat 예약시각 +2h, 기존 보호자 경고와 동일 스케줄러 tick)에서 **보호자/구독 게이팅 앞**에서 대상자 본인 Android 기기로 FCM 푸시 `subject_safety_net`을 보낸다(보호자 유무·구독 만료 무관). 미수신일마다 1회 → 무시 시 매일 반복(기존 "무시 시 반복" 그대로). 서버 발송이라 OEM이 worker/로컬알람을 죽인 LAST-RESORT 상황에도 도달. (폐지 사유: heartbeat+3h + `matchDateTimeComponents.time` 조합이 forceNextDay로도 "그 시각의 다음 발생=오늘"로 당겨 정상 전송일에도 매일 오발화하던 결정적 버그; iOS 0h offset은 무관.) **푸시 탭 라우팅**: 클라 `fcm_service._handleNotificationTap`가 type `subject_safety_net`을 `safety_net`과 동일 경로로 처리 → **safety_home으로 이동** + `pendingSafetyNetDialog` → 홈/대시보드 onResumed가 미전송 heartbeat 자동 재전송 + 안내 다이얼로그(kill 런치는 splash). **안내 다이얼로그 문구는 탭 *이전* 전송 여부로 분기**(`consumeSafetyNetDialogIfPending`): 전송 *전에* 캡처한 `wasReported`/`priorTime`을 넘겨, 탭 이전 이미 전송됨이면 "이미 @time에 전달됨"(`safety_net_dialog_already_body`, `formatTo12Hour` 오전/오후), 탭으로 새로 전송이면 "방금 전달됨"(`safety_net_dialog_body`). iOS `gs_deadman` 탭도 Android `subject_safety_net` 탭과 동일 분기: `isReportedToday=false`일 때만 전송, 이미 전송됐으면 전송 없이 다이얼로그만 표시. `priorTime`은 탭 직전 캡처되므로 전송 스킵 시에도 "이미 @priorTime에 전달됨"이 정확히 안내됨. 상세 §PRD-FrontEnd 2.5.1. iOS `gs_deadman`도 동일하게 safety_home으로(`_routeToSafetyHome` — 역할 인식: G+S는 Dashboard base + push, 순수 S는 단독). **예약시각 변경 시**(`HeartbeatScheduleMixin.onHeartbeatTimeChanged`): iOS 안전망 알림은 `LocalAlarmService.schedule(hour, minute)` 재등록 — `scheduled.isBefore(now)` 기준으로 오늘/내일 자동 결정(`forceNextDay` 파라미터 없음); 미전송+과거 시각이면 `HeartbeatService.execute()`로 **즉시 전송**(오늘분 기록 → 거짓 미수신 경고 방지) + "안부 전했습니다"(`subject_home_manual_report_sent`) 스낵바, 이미 오늘 전송됨이면 `lastHeartbeatDate` 유지로 재전송 차단(Android는 서버 푸시가 담당하므로 로컬 안전망 재예약 없음). **iOS 알람 등록 불변 규칙**: iOS 안전망 알림 등록 진입점은 `enableSubjectFeature`(최초 설치), `_scheduleHeartbeatIfGS`(재설치 복원 — onInit 매번 재단언, 같은 ID 덮어쓰기 → idempotent), `onHeartbeatTimeChanged`(예약시각 변경) 3개뿐. `_onHeartbeatSent`와 `_syncScheduleFromServer`/onResumed는 iOS 알람을 건드리지 않는다 — `matchDateTimeComponents.time`으로 OS가 매일 자동 반복하므로 heartbeat 성공마다 재등록이 불필요하고, onResumed마다 재등록하면 "최초 설치·재설치·시각 변경 시에만" 원칙을 위반한다. **send_failed / trial_ended / 배터리·네트워크 Android 로컬 알림은 이번 변경과 무관하게 유지**(retry 3회 실패 알림 `_sendFailedId`은 `cancelSendFailed()`로 정리). FCM 보호자 경고 푸시(`alert_*` 등)는 알림 목록으로 가는 것과 구분됨                                                                                                                                                                                                |
| 공유 캐시      | `lib/app/core/services/guardian_subject_service.dart`                                             | 보호자 대상자 목록 공유 캐시 (2분 TTL). 대시보드·설정·연결관리에서 동일 데이터 사용. 구독 상태 동기화. **대상자 별칭 서버 동기화(`syncAliasesIfChanged`)** — 별칭은 로컬(`NicknameLocalDatasource`)이 원본이지만, 보호자 Push 본문에 "누구의 알림인지"(`삼촌 · 오늘 안부 확인이…`)를 표시하려면 앱이 꺼져 있어도 OS가 그리는 알림 문구를 서버가 만들어야 하므로 사본을 `guardians.alias`에 올린다(`PUT /api/v1/subjects/aliases`). 트리거는 **스냅샷 비교 하나**(`nicknames_synced`와 다를 때만 전송, 성공 시에만 스냅샷 갱신) — 백필·개별 저장·실패 재시도가 이 하나로 전부 처리된다. 일회성 플래그로 바꾸면 실패가 영구화되므로 금지. 호출은 `load()` 성공 직후 + 연결관리 별칭 수정 직후 2곳, 둘 다 `unawaited` **fire-and-forget**(동기화 실패가 연결·저장·화면을 막으면 안 됨). 상세는 PRD-FrontEnd §9.6.1 |
| 긴급 위치      | `lib/app/modules/guardian_emergency_map/`                                                         | 대상자 긴급 도움 요청 시 첨부된 위치를 보호자가 Google Maps로 확인하는 페이지. **진입 경로는 알림 목록의 [🗺️ 위치 보기] 버튼 단 하나**. FCM 탭은 `alert_emergency` 포함 모든 `alert_*` type을 알림 목록으로 라우팅하며 (`_routeToNotifications` 자동 새로고침), 사용자가 목록에서 해당 emergency 카드의 버튼을 탭해 지도로 진입 — 단일 진입점 유지로 뒤로가기 스택/새로고침 일관성 확보                                                                                                                                                                                                             |
| 긴급 위치 획득 | `lib/app/data/datasources/remote/emergency_remote_datasource.dart` — `captureEmergencyLocation()` | S 홈 / G+S SafetyCode 긴급 버튼이 공통 사용하는 top-level 헬퍼. 2단계 폴백: (1) `getLastKnownPosition` (수 ms 내 반환) → (2) `getCurrentPosition` medium 정확도 + 10초 타임아웃. high는 GPS only라 실내/콜드 스타트에서 timeout 빈발, medium은 GPS+Wi-Fi+셀룰러 병용해 실내에서도 fix 가능. 권한 거부·GPS 실패·타임아웃 어떤 예외에서도 null 반환하고 throw하지 않는다 — 긴급 API 호출 자체는 위치 유무와 독립                                                                                                                                                                                     |

## 알림 트레이 정리 (포그라운드 진입 시)

> 상세는 PRD-FrontEnd §2.5.2.

앱이 포그라운드로 진입하면(콜드 스타트 / 백그라운드 복귀) 트레이에 쌓인 **표시 중인 알림 전부**를 제거한다 — FCM 푸시·로컬 알림 구분 없이. 사용자가 알림 하나만 탭해도 나머지가 남지 않게 하는 것이 목적이며, 보호자 경고는 서버 기반 in-app 알림 목록(`GET /notifications`)에 당일 내내 남으므로 정보 손실이 없다.

- 진입점: `FcmService.init()` 말미 1회(콜드 스타트) + `AppLifecycleListener(onResume:)`(복귀). **kill 런치 payload(`getInitialMessage`/`getNotificationAppLaunchDetails`)를 읽어 캐시한 *뒤*에 호출**해야 라우팅·안내 다이얼로그 플래그가 살아남는다.
- 구현: `LocalAlarmService.clearDeliveredNotifications()` → Android는 `screen_state` 채널의 `clearDeliveredNotifications`(`NotificationManager.cancelAll()`, posted 전용), iOS는 AppDelegate `kr.co.anbucheck/notifications` 채널의 `clearDelivered`(`removeAllDeliveredNotifications()` + 배지 0). screen_state는 Android 전용 플러그인이라 iOS는 AppDelegate `didInitializeImplicitFlutterEngine`에서 `applicationRegistrar.messenger()`로 채널 등록(`getFlutterVC()`는 scene 기반 앱에서 런치 직후 nil일 수 있음).
- ⚠️ **불변 규칙 — 예약(pending)은 절대 건드리지 말 것**: `FlutterLocalNotificationsPlugin.cancelAll()`(표시+예약 동시 제거)과 iOS `removeAllPendingNotificationRequests` 사용 금지. iOS 일일 안전망 알림(`gs_deadman`, `matchDateTimeComponents.time`)은 pending 반복 요청으로 살아 있어야 매일 발화하며 **iOS G+S의 PRIMARY heartbeat 트리거**다 — 지우면 iOS 안부 전송이 조용히 죽는다. `trial_ended` 단발 예약도 동일.
- `cancelSubjectSafetyNet()`/`cancelSendFailed()`는 **대체되지 않는다** — WorkManager 백그라운드 isolate(앱 미포그라운드)에서 `_onHeartbeatSent`가 호출하는 별개 경로다.
- 부작용(수용): `send_failed`는 `onlyAlertOnce`로 반복 실패 시 무음 갱신되는데, 트레이를 비운 뒤 다음 실패는 소리와 함께 새로 표시된다.
- **앱이 이미 포그라운드일 때 도착한 알림은 정리 대상이 아니다(의도)**: `_handleForegroundMessage`가 앱이 열린 상태에서도 트레이 알림을 표시하고 iOS `willPresent`도 `.list`를 반환하지만, resume 전환이 없어 다음 백그라운드→포그라운드 사이클까지 남는다. 즉시 제거하면 방금 띄운 헤드업 알림을 사용자가 읽기 전에 지우게 되므로 **현행 유지**로 결정(2026-07-30). 지연 제거·표시 억제로 "수정"하지 말 것.

## 위치 수집 범위

정기 heartbeat에는 위치를 일절 포함하지 않는다. 대상자가 [🚨 도움이 필요해요] 버튼을 누른 경우에 한해 사용자 동의 하에 1회 수집하여 보호자 전원에게 전달하고, 서버는 `notification_events` 테이블에만 저장한다(최대 24시간 보관, 자정 정리 스케줄러가 일괄 삭제). 백그라운드 위치는 절대 사용하지 않는다 (`ACCESS_BACKGROUND_LOCATION` / `Always` / `Background Modes: location` 모두 금지).

## 참조 문서

| 문서             | 경로                                   | 참조 시점                            |
| ---------------- | -------------------------------------- | ------------------------------------ |
| 프론트엔드 PRD   | `.claude/rules/PRD-FrontEnd.md`        | UI 구현, 화면 설계, 로컬 저장소 정책 |
| 백엔드 PRD       | `../anbucheck-server/.ref/PRD-BackEnd.md` (외부 repo) | API 명세, 요청/응답, DB 스키마       |
| Heartbeat 플로우 | `.claude/rules/heartbeat_flowchart.md` | heartbeat 수집·전송·경고 플로우      |
| Android 실행 실측 | `.claude/rules/android_scheduling_field_notes.md` | worker 미발화 진단, Doze·쿼터·배칭 실측값, adb 진단 절차 |

## 웹사이트 (외부 repo: `../averic-lab` → averic.co.kr)

홈·FAQ·사용설명·비공개 테스트 안내 페이지는 **별도 저장소 `../averic-lab`**(GitHub Pages)에서 관리한다. 이 repo가 아니다 — 페이지 구조·빌드·배포는 전부 `averic-lab/CLAUDE.md`에 있다.

⚠️ **이 저장소에서 알아야 할 것은 번역 키 계약 하나뿐이다.** 그 페이지들이 `lib/app/core/translations/*.dart`를 읽어 만들어지므로, 현재 **101개 키**를 **이름 변경·삭제하면 페이지 빌드가 실패**한다(`extract_strings.py`가 exit 1). 문구만 바꾸는 것은 안전하며, averic-lab에서 `extract_strings.py`를 재실행하면 20개 언어에 반영된다.

- 어떤 키인지는 `averic-lab/_faq-build/extract_strings.py`의 `KEYS`가 **유일한 권위**다(용도별 주석 포함). 여기에 목록을 복사해 두지 않는다 — 두 곳이 조용히 어긋나고 매 세션 토큰만 먹는다.
- ⚠️ 이 키들의 값에 **`@`로 시작하는 자리표시자를 새로 넣지 말 것** — 페이지가 채우지 못해 사용자에게 `@days` 같은 문자열이 그대로 보인다. `extract_strings.py`가 이를 검사해 실패시킨다.

## 규칙
1. 모든 응답·주석·커밋 메시지 **한글** 작성
2. 불확실하면 추론 금지 — **코드를 직접 찾아보고** 답변
3. 새 페이지 모듈은 반드시 `.claude/skills/getx-module/SKILL.md` 절차 준수
4. Controller → UseCase만 의존 (DataSource/Repository 직접 참조 금지)
5. Domain 레이어는 순수 Dart만 사용 (Flutter/GetX import 금지)
6. Freezed 모델은 `abstract class`로 선언
7. 모듈 생성 후 `flutter analyze` 실행
8. **다국어 번역 필수** — UI에 새 문자열 추가·변경 시 반드시 20개 언어 번역 파일에 동시 반영
   - 번역 파일: `lib/app/core/translations/` 아래 20개 파일
   - 대상 언어: ko_KR, en_US, ja_JP, zh_CN, zh_TW, de_DE, fr_FR, es_ES, it_IT, nl_NL, pt_BR, ru_RU, ar_SA, tr_TR, pl_PL, vi_VN, th_TH, sv_SE, hi_IN, id_ID
   - 앱 이름 브랜드 규칙: 한국어만 "안부", 나머지 19개 언어는 "Anbu"
   - 하드코딩 한글 텍스트 금지 — 반드시 `'key'.tr` 사용

## 디자인 시스템

- 1px 실선 경계 금지 (배경색 전환으로 구분)
- 그림자 대신 Tonal Layering, 플로팅 요소에 Glassmorphism (80% 투명도)
- 최소 버튼 높이 64px / 터치 영역 48×48dp
- 순수 검정 `#000000` 금지 → `#1a1c1c` 사용
- 수평 마진 `spacing.5` / 수직 그룹 간격 `spacing.8`

## 작업 원칙

1. skills/memory 내용 신뢰 — 이미 아는 파일 재읽기 금지
2. 추측성 도구 호출 금지
3. 독립적 도구 호출은 반드시 병렬 실행
4. 출력 20줄 이상이면 서브에이전트로 위임
5. 사용자가 이미 말한 내용 반복 금지

## 빌드

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```
