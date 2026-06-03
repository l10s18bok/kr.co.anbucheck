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
- `GuardianDashboardController._scheduleHeartbeatIfGS()` — G+S일 때만 onInit에서 서버 스케줄 재동기화 + **WorkManager만 재등록** (LocalAlarm 재예약 안 함 — S `_syncScheduleFromServer`와 동일). iOS 안전망 알림 재예약은 `_onHeartbeatSent`가 `forceNextDay`로 단일 소유하므로, onInit에서 `forceNextDay` 없이 재호출하면 이미 오늘 전송돼 내일로 옮겨둔 iOS 정시 알림을 당일로 되돌리는 버그가 발생한다(Android는 일일 로컬 안전망 알림이 폐지되고 서버 푸시 `subject_safety_net`로 이관돼 이 invariant가 iOS에만 적용)

**G+S 관련 컨트롤러:**
- `GuardianDashboardController` — G+S 라이프사이클 + heartbeat 자동 재전송 단독 소유: 활성화/비활성화, WorkManager/LocalAlarm 예약, `_checkAndSendHeartbeat` 미전송 체크, 안전코드 페이지 진입. **진입점 2원화**: (1) onInit/onResumed → `refreshAndSend()` → `_checkAndSendHeartbeat()` → `isReportedToday=false`일 때만 전송(`manual:false`), (2) FcmService `gs_deadman` 탭 → `refreshAndForceSend()` → `isReportedToday` 무관하게 **무조건** 탭한 날짜로 최신 걸음수와 함께 전송(`manual:true`). 사용자가 알림을 여러 번 탭해도 그때마다 전송. Dashboard/Settings 바인딩에서 `permanent: true`로 공유 등록하여 SafetyCode에서도 `Get.find` 가능
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
| 공통           | `lib/app/core/services/heartbeat_service.dart`                                                    | heartbeat 1회 실행의 전체 로직: 걸음수(steps_delta) 조회 → suspicious 판정 → 서버 전송 → 실패 시 큐 저장 → `_onHeartbeatSent` housekeeping. **`_onHeartbeatSent` (전송 성공 직후 단일 책임 — 자동/수동/pending 큐 모든 성공 경로 공통)**: (a) `LocalAlarmService.schedule(forceNextDay: true)` → **iOS만** 일일 안전망 알림 cancel + 내일자 정시 재예약(`cancel(_alarmId)`이 예약 + 표시 중 알림을 모두 제거하므로 stale 알림 잔존 없음). **Android는 `schedule()`이 cancel-only no-op** — Android 일일 로컬 안전망 알림은 폐지되고 **서버 FCM 푸시 `subject_safety_net`(서버 미수신 체크 = heartbeat 예약시각 +2h)로 이관**됐다(폐지 사유: heartbeat+3h + `matchDateTimeComponents.time` 조합이 forceNextDay로 날짜를 내일로 밀어도 "그 시각의 다음 발생=오늘"로 당겨 정상 전송한 날에도 매일 오발화하던 결정적 버그. iOS는 0h offset이라 무관. Android의 cancel은 업그레이드 기기에 남은 잔존 버그 알림 정리 역할), (b) Android `HeartbeatWorkerService.schedule(hour, minute)` 호출 → one-off + periodic **둘 다 cancel + 내일자 register** (worker 콜백은 schedule()을 호출하지 않음. 단일 책임 분리로 한 번의 worker fire에서 cancel+register mutation이 4건 발생하던 부작용 제거. **단 `_onHeartbeatSent`는 전송 성공 경로 전용**이라 여기서만 풀 `schedule()`로 periodic까지 내일로 재워 배터리를 아낀다. **전송 실패 시에는** `_sendOrSavePending`/`_sendPendingInternal`이 `_rescheduleNextDay(success: false)` → `HeartbeatWorkerService.rescheduleOneOffOnly()`로 **one-off만 내일자로 재무장하고 periodic 15분 폴링은 살려둔다** — 살아있는 periodic이 같은 날 통신 복구를 15분 내 잡아 보류 큐를 비운다. 실패 분기가 풀 schedule()을 불러 periodic을 내일로 밀면 일시적 통신 장애가 그날의 15분 안전망을 통째로 해체한다(Defect 1) — **이 성공/실패 분기를 다시 합치지 말 것**), (c) Android `LocalAlarmService.cancelSendFailed()` 호출 → retry 3회 실패 시 띄웠던 stale "전송 실패" 알림 제거. **suspicious 판정 우선순위**: (1) `manual=true` → false, (2) `steps_delta > 0` → false (하루 전체 활동 확정), (3) `isInteractiveAtTrigger=true` → false (worker fire 시점 화면 깨어있음 = 최근 기기 사용 신호), (4) 그 외 → true (걸음 기록도 없고 발화 시점 기기 미사용 = 활동 증거 부재). **두 신호의 범위 비대칭 주의**: `steps_delta`는 오늘 자정~현재 누적(하루 전체), `isInteractiveAtTrigger`는 worker fire **순간**의 1회 스냅샷이다. `isInteractive=true`는 발화 시점 살아있는 신호지만 `isInteractive=false`는 "하루 종일 안 썼다"가 아니라 "그 순간 안 썼다"일 뿐이므로, 보호자 알림 문구는 "폰 사용 흔적" 대신 "활동 기록"으로 순화되어 있다(noti_*_suspicious_body 계열). `isInteractiveAtTrigger`는 worker 콜백에서 `ScreenState.isInteractive()`로 조회해 전달하며, 포그라운드 호출부(홈 자동 전송·수동 보고·G+S 활성화 첫 전송)는 앱이 포그라운드에 있다는 것 자체가 interactive 증거이므로 항상 `true`를 명시 전달한다. 가속도/자이로/지자기는 Android 9+ 백그라운드 제한으로 WorkManager에서 항상 null이므로 제거됨. 오탐/미탐, 중복 전송, 데이터 누락 모두 이 파일에서 발생                                                                                                                                                                                                        |
| 1차            | `lib/app/core/services/heartbeat_worker_service.dart`                                             | WorkManager 백그라운드 예약 실행 (Android 전용). 2계층 구조 — (a) one-off: 예약시각에 정확히 1회 fire, (b) periodic 15분: 안전망 폴링 (one-off 누락 시 15분 내 백업 발화 + 화면 켜짐 Doze 해제 piggyback). 두 task 모두 전송 성공 시 `_onHeartbeatSent`가 `HeartbeatWorkerService.schedule()`로 cancel+register하여 내일자로 재등록(periodic도 내일로 재워 밤샘 폴링 off → 배터리 절약)하며, worker 콜백은 schedule()을 호출하지 않는다 (이전 안전망 패턴 제거: 한 번의 worker fire에서 cancel+register mutation이 4건 발생하던 부작용 차단). **단 풀 `schedule()`은 성공 경로 전용**이다 — **전송 실패 시에는** `_rescheduleNextDay(success: false)` → `rescheduleOneOffOnly()`로 **one-off만 내일자로 재무장하고 periodic 15분 폴링은 유지**해 같은 날 통신 복구를 15분 내 잡는다(실패 분기가 풀 schedule()을 부르면 일시적 통신 장애가 그날 안전망을 해체 — Defect 1, 합치지 말 것). 또한 **전송이 한 번도 성공하지 못한 기간 동안에는 살아있는 periodic 15분 폴링이 재시도를 담당**한다(실패 분기가 periodic을 끄지 않으므로 cadence 유지). one-off은 fire 후 `rescheduleOneOffOnly`로 다음 정시에 재무장된 채 함께 대기하며, 네트워크가 끊긴 동안에는 `NetworkType.connected` 제약으로 둘 다 보류되다 Doze 해제/네트워크 복구 시점에 fire된다. `schedule()`은 `cancelByUniqueName` + `register*Task` 패턴이라 self-cancel(periodic이 자기 자신을 cancel)도 currently 실행 중인 task는 유지하고 다음 예약만 취소하므로 안전. execute 호출 직전 `ScreenState.isInteractive()`(Android PowerManager 커스텀 플러그인)를 1회 조회해 `HeartbeatService.execute(isInteractiveAtTrigger: ...)`로 전달 — Doze maintenance window에서 화면 꺼진 채 자연 fire(false)와 화면이 깨어있는 상태에서 fire(true)를 구분해 suspicious 판정에 반영. **콜백 진입 시각 가드**: 콜백은 `scheduled = 오늘 hour:minute` 기준으로 시각을 판정한다 — `lastHeartbeatDate == 오늘`이면 스킵(오늘 정시 전송 완료), `예약시각 -15분` 이후면 정상 정시 전송(`execute(isInteractiveAtTrigger: ...)`), `예약시각 -15분` 이전이면 평소엔 스킵하되 **회복 전송 예외**가 적용된다 — `-15분` 창은 periodic이 +3분 offset으로 등록돼도 실제 발화가 Doze maintenance window에 종속돼 예측 불가한 변동성을 흡수하는 가드다. **회복 전송**(`execute(recovery: true)` → `_executeRecovery`): 예약시각 이전 구간에서 `lastHeartbeatDate`가 오늘도 어제도 아니고 비어있지도 않은 미전송 갭 + `isInteractive=true`(사용자가 폰을 깨운 시점)이면 예약시각을 기다리지 않고 "살아있음" 신호를 즉시 전송한다. 회복 전송은 **그 날 정시 슬롯을 소비하지 않는다** — `lastHeartbeatDate`/`lastScheduledKey`를 건드리지 않고 `_onHeartbeatSent`(재등록)도 호출하지 않으므로 예약시각 정시 전송이 그대로 수행돼 종일 걸음수가 정확히 기록된다(회복 전송은 정시 경로 재등록에 관여하지 않는다). `steps_delta=null`(예약시각 전 부분 집계가 어중간한 "오늘 N보" 알림으로 나가는 것 방지), `suspicious=false`(화면 활성 = 활동 증거). 정시 키(`<날짜>_HH:mm`)와 분리된 전용 키 `recovery_<날짜>`를 써서 서버 `(device_id, scheduled_key)` idempotency가 정시 전송을 막지 않고, 동시 발화(1:1 race)는 이 키 기반 `HeartbeatLockDatasource` SQLite UNIQUE 락 + 서버 dedup으로 차단한다. 당일 1회 제한 마커는 `TokenLocalDatasource.lastRecoveryDate`(정시 마커와 별도)라 오전 periodic 반복 발사가 차단되며, 실패 시 pending 큐에 넣지 않고 다음 periodic fire 또는 정시 전송이 자연 회복한다. iOS는 worker가 없어 회복 전송 미적용(Android 전용). race는 worker 콜백 `lastHeartbeatDate`(오늘 재전송 차단) + `HeartbeatService._executeInternal`의 `lastScheduledKey`(성공 마커) + `HeartbeatLockDatasource`(SQLite UNIQUE CAS, cross-isolate 원자 락)로 3중 방어. **connectivity_plus의 Doze 오판 주의**: WorkManager가 `NetworkType.connected` constraint로 task를 깨웠음에도 `connectivity_plus.checkConnectivity()`가 Doze 상태에서 오프라인으로 잘못 판단하는 케이스가 있었음. 이 때문에 사전 네트워크 체크를 제거하고 Dio 3회 retry(5s/10s 간격)로 처리 (커밋 56f38e8). retry 3회 모두 실패 시 자동 경로(`manual=false`)는 `LocalAlarmService.notifySendFailed()`로 사용자 안내 알림 표시(payload 무시 — 탭하면 앱 포그라운드 전환만, 홈 컨트롤러의 자동 재전송이 처리). iOS는 BGTaskScheduler 불안정성으로 사용하지 않음 |
| 2차            | `lib/app/modules/safety_home/controllers/subject_home_controller.dart`                            | 앱 열기/복귀 시 안전망. onInit/onResumed에서 **예약시각 경과 + 당일 미전송**이면 자정 전까지 무조건 자동 전송. 가드는 `isReportedToday`(이미 전송 차단) + Android의 `isScheduleInFuture`(예약시각 이전 차단) 두 개로 단순화 — 자정이 유일한 의미 경계. iOS S/G+S는 시각 가드 자체가 없음(`Platform.isAndroid &&` 조건). `isScheduleInFuture`에 막혀도 `_isRecoveryPending`(`lastHeartbeatDate`가 오늘도 어제도 아닌 미전송 갭)이면 1차 worker와 동일한 **회복 전송**(`HeartbeatService().execute(recovery: true)`)을 보낸다 — 포그라운드 진입 자체가 살아있음 증거라 worker처럼 화면 활성 게이트는 두지 않으며, 정시 슬롯을 소비하지 않아 예약시각 정시 전송은 그대로 수행된다. 이전에 있던 `isScheduleTooOld`(예약 +3h 초과 차단) 가드는 보호자 stale 경고 방지 효과보다 늦은 정상 복귀 차단의 부작용이 커서 제거됨 — 21:30이든 23:50이든 사용자가 앱을 연 행위 자체가 강한 alive 신호이고, 늦은 전송 성공 시 `_onHeartbeatSent`가 WorkManager를 즉시 내일자로 재등록해 정시 사이클이 정상화된다. **첫 설치 시 시각 가드 우회**: `lastHeartbeatDate.isEmpty`이면 `isScheduleInFuture`까지 건너뛰고 즉시 전송 — Google Fit 구독 생성 + last_seen baseline + 파이프라인 검증을 한 번에 처리해 D0 갭 해소. `SafetyHomeBaseController`(abstract) 상속 자식 — 부모는 invite_code·schedule·권한·배터리·네트워크·reportNow·sendEmergency 공통 로직, 자식은 `lastHeartbeatDate/Time` 자기 Rx + Drawer/탈퇴/모드전환/휴면 다이얼로그 담당. **안전코드 페이지 기능 활성화(보고/긴급/시각변경/헤더 배지)는 `guardianCount > 0`만으로 판정 — 구독 상태와 무관(연결된 보호자가 있으면 구독 만료여도 동작, 새로고침은 항상 동작). 과거 `isGuardianConnected`(=`subscription_active` misnamed Rx)로 게이팅해 G+S 구독 만료 시 페이지가 마비되던 버그를 수정하며 해당 Rx 제거.** G+S 자식(`GuardianSafetyCodeController`)은 같은 디렉토리에 위치하며 Dashboard에 위임                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| 3차 (안전망)   | **iOS**: `lib/app/core/services/local_alarm_service.dart` / **Android**: 서버 FCM 푸시 `subject_safety_net` (`anbucheck-server/services/scheduler.py`)                                                  | 일일 안부 확인 안전망. **iOS**: `LocalAlarmService`가 heartbeat 예약 시각 정시에 매일 로컬 알림(payload `gs_deadman`, `matchDateTimeComponents.time`) — BGTaskScheduler 미사용으로 사실상 PRIMARY 트리거. heartbeat 성공 시 `_onHeartbeatSent`가 `schedule(forceNextDay: true)` → `cancel(_alarmId)`로 예약 + 표시 중 알림을 모두 제거하고 내일자로 재예약(stale 잔존 없음). **Android**: 일일 로컬 안전망 알림 **폐지** — `LocalAlarmService.schedule()`은 Android에서 기존 알림 cancel 후 즉시 return(업그레이드 기기 잔존 버그 알림 정리). 대신 **서버**가 미수신 체크(heartbeat 예약시각 +2h, 기존 보호자 경고와 동일 스케줄러 tick)에서 **보호자/구독 게이팅 앞**에서 대상자 본인 Android 기기로 FCM 푸시 `subject_safety_net`을 보낸다(보호자 유무·구독 만료 무관). 미수신일마다 1회 → 무시 시 매일 반복(기존 "무시 시 반복" 그대로). 서버 발송이라 OEM이 worker/로컬알람을 죽인 LAST-RESORT 상황에도 도달. (폐지 사유: heartbeat+3h + `matchDateTimeComponents.time` 조합이 forceNextDay로도 "그 시각의 다음 발생=오늘"로 당겨 정상 전송일에도 매일 오발화하던 결정적 버그; iOS 0h offset은 무관.) **푸시 탭 라우팅**: 클라 `fcm_service._handleNotificationTap`가 type `subject_safety_net`을 `safety_net`과 동일 경로로 처리 → **safety_home으로 이동** + `pendingSafetyNetDialog` → 홈/대시보드 onResumed가 미전송 heartbeat 자동 재전송 + 안내 다이얼로그(kill 런치는 splash). **안내 다이얼로그 문구는 탭 *이전* 전송 여부로 분기**(`consumeSafetyNetDialogIfPending`): 전송 *전에* 캡처한 `wasReported`/`priorTime`을 넘겨, 탭 이전 이미 전송됨이면 "이미 @time에 전달됨"(`safety_net_dialog_already_body`, `formatTo12Hour` 오전/오후), 탭으로 새로 전송이면 "방금 전달됨"(`safety_net_dialog_body`). iOS `gs_deadman` 강제 재전송도 `priorTime` 캡처 후 동일 분기(재전송 동작 불변). 상세 §PRD-FrontEnd 2.5.1. iOS `gs_deadman`도 동일하게 safety_home으로(`_routeToSafetyHome` — 역할 인식: G+S는 Dashboard base + push, 순수 S는 단독). **예약시각 변경 시**(`HeartbeatScheduleMixin.onHeartbeatTimeChanged`): iOS 안전망 알림은 `forceNextDay = (이미 오늘 전송됨 || 새 시각이 오늘 지남)`로 재예약; 미전송+과거 시각이면 `HeartbeatService.execute()`로 **즉시 전송**(오늘분 기록 → 거짓 미수신 경고 방지) + "안부 전했습니다"(`subject_home_manual_report_sent`) 스낵바, 이미 오늘 전송됨이면 `lastHeartbeatDate` 유지로 재전송 차단(Android는 서버 푸시가 담당하므로 로컬 안전망 재예약 없음). **단일 소유 invariant(iOS)**: iOS 안전망 알림 재예약은 `_onHeartbeatSent`(`forceNextDay`)와 `onHeartbeatTimeChanged`만 담당하고, onInit/서버 동기화(S `_syncScheduleFromServer`, G+S `_scheduleHeartbeatIfGS`)는 worker만 재등록하고 LocalAlarm은 재예약하지 않는다 — `forceNextDay` 없는 onInit 재호출이 이미 내일로 옮긴 알림을 당일로 되돌리던 버그 차단. **send_failed / trial_ended / 배터리·네트워크 Android 로컬 알림은 이번 변경과 무관하게 유지**(retry 3회 실패 알림 `_sendFailedId`은 `cancelSendFailed()`로 정리). FCM 보호자 경고 푸시(`alert_*` 등)는 알림 목록으로 가는 것과 구분됨                                                                                                                                                                                                |
| 공유 캐시      | `lib/app/core/services/guardian_subject_service.dart`                                             | 보호자 대상자 목록 공유 캐시 (2분 TTL). 대시보드·설정·연결관리에서 동일 데이터 사용. 구독 상태 동기화                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| 긴급 위치      | `lib/app/modules/guardian_emergency_map/`                                                         | 대상자 긴급 도움 요청 시 첨부된 위치를 보호자가 Google Maps로 확인하는 페이지. **진입 경로는 알림 목록의 [🗺️ 위치 보기] 버튼 단 하나**. FCM 탭은 `alert_emergency` 포함 모든 `alert_*` type을 알림 목록으로 라우팅하며 (`_routeToNotifications` 자동 새로고침), 사용자가 목록에서 해당 emergency 카드의 버튼을 탭해 지도로 진입 — 단일 진입점 유지로 뒤로가기 스택/새로고침 일관성 확보                                                                                                                                                                                                             |
| 긴급 위치 획득 | `lib/app/data/datasources/remote/emergency_remote_datasource.dart` — `captureEmergencyLocation()` | S 홈 / G+S SafetyCode 긴급 버튼이 공통 사용하는 top-level 헬퍼. 2단계 폴백: (1) `getLastKnownPosition` (수 ms 내 반환) → (2) `getCurrentPosition` medium 정확도 + 10초 타임아웃. high는 GPS only라 실내/콜드 스타트에서 timeout 빈발, medium은 GPS+Wi-Fi+셀룰러 병용해 실내에서도 fix 가능. 권한 거부·GPS 실패·타임아웃 어떤 예외에서도 null 반환하고 throw하지 않는다 — 긴급 API 호출 자체는 위치 유무와 독립                                                                                                                                                                                     |

## 위치 수집 범위

정기 heartbeat에는 위치를 일절 포함하지 않는다. 대상자가 [🚨 도움이 필요해요] 버튼을 누른 경우에 한해 사용자 동의 하에 1회 수집하여 보호자 전원에게 전달하고, 서버는 `notification_events` 테이블에만 저장한다(최대 24시간 보관, 자정 정리 스케줄러가 일괄 삭제). 백그라운드 위치는 절대 사용하지 않는다 (`ACCESS_BACKGROUND_LOCATION` / `Always` / `Background Modes: location` 모두 금지).

## 참조 문서

| 문서             | 경로                                   | 참조 시점                            |
| ---------------- | -------------------------------------- | ------------------------------------ |
| 프론트엔드 PRD   | `.claude/rules/PRD-FrontEnd.md`        | UI 구현, 화면 설계, 로컬 저장소 정책 |
| 백엔드 PRD       | `../anbucheck-server/.ref/PRD-BackEnd.md` (외부 repo) | API 명세, 요청/응답, DB 스키마       |
| Heartbeat 플로우 | `.claude/rules/heartbeat_flowchart.md` | heartbeat 수집·전송·경고 플로우      |

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
