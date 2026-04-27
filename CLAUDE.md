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

- **Flutter** 3.41.5 / Dart 3.11.3
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
    │   │                   # AdService, ThemeService
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
    │   │                   # NotificationSettingsRemoteDatasource, VersionRemoteDatasource
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
- `GuardianDashboardController._scheduleHeartbeatIfGS()` — G+S일 때만 WorkManager/LocalAlarm 예약

**G+S 관련 컨트롤러:**
- `GuardianDashboardController` — G+S 라이프사이클 + heartbeat 자동 재전송 단독 소유: 활성화/비활성화, WorkManager/LocalAlarm 예약, `_checkAndSendHeartbeat` 미전송 체크, 안전코드 페이지 진입. **진입점 2원화**: (1) onInit/onResumed → `refreshAndSend()` → `_checkAndSendHeartbeat()` → `isReportedToday=false`일 때만 전송(`manual:false`), (2) FcmService `gs_deadman` 탭 → `refreshAndForceSend()` → `isReportedToday` 무관하게 **무조건** 탭한 날짜로 최신 걸음수와 함께 전송(`manual:true`). 사용자가 알림을 여러 번 탭해도 그때마다 전송. Dashboard/Settings 바인딩에서 `permanent: true`로 공유 등록하여 SafetyCode에서도 `Get.find` 가능
- `GuardianSafetyCodeController` — UI 전용 (invite_code, heartbeat 스케줄 변경, 수동 보고, 긴급 요청). 보고 상태 표시는 Dashboard의 `lastHeartbeatDate`/`lastHeartbeatTime`/`isReportedToday` Rx를 구독. 수동 보고(`reportNow`) 후 `_dashboard.reloadHeartbeatState()` 호출해 카드 즉시 갱신. 긴급 요청(`sendEmergency`)은 S 홈과 동일하게 공통 헬퍼 `captureEmergencyLocation()`로 위치 획득 후 `EmergencyRemoteDatasource.send(deviceId, location: ...)` — G+S 사용자도 긴급 시 위치가 첨부됨. `locationPermissionDenied` Rx + `requestLocationPermissionAgain()`으로 긴급 버튼 아래 권한 경고 위젯 동작
- `GuardianSettingsController` — UI 전용. G+S 활성화/해제/탈퇴 시 Dashboard 컨트롤러에 위임
- `ModeSelectController` — 재설치 시 `has_invite_code`로 G+S 감지 → `isAlsoSubject` 전달

## 핵심 파일 (Heartbeat 3계층 구조)

이 앱의 핵심은 "사용자 조작 없이 매일 heartbeat가 확실히 전송되는 것"이다.
아래 4개 파일이 3계층 전송 구조를 각각 담당하며, 어느 하나가 망가져도 안부 확인 서비스가 무너진다.

| 계층           | 파일                                                                                              | 역할                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| -------------- | ------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 공통           | `lib/app/core/services/heartbeat_service.dart`                                                    | heartbeat 1회 실행의 전체 로직: 걸음수(steps_delta) 조회 → suspicious 판정 → 서버 전송 → 실패 시 큐 저장 → 오늘의 안부 확인 메시지 로컬 알림 재예약. **suspicious 판정 우선순위**: (1) `manual=true` → false, (2) `steps_delta > 0` → false (하루 전체 활동 확정), (3) `isInteractiveAtTrigger=true` → false (worker fire 시점 화면 깨어있음 = 최근 기기 사용 신호), (4) 그 외 → true (걸음 기록도 없고 발화 시점 기기 미사용 = 활동 증거 부재). **두 신호의 범위 비대칭 주의**: `steps_delta`는 오늘 자정~현재 누적(하루 전체), `isInteractiveAtTrigger`는 worker fire **순간**의 1회 스냅샷이다. `isInteractive=true`는 발화 시점 살아있는 신호지만 `isInteractive=false`는 "하루 종일 안 썼다"가 아니라 "그 순간 안 썼다"일 뿐이므로, 보호자 알림 문구는 "폰 사용 흔적" 대신 "활동 기록"으로 순화되어 있다(noti_*_suspicious_body 계열). `isInteractiveAtTrigger`는 worker 콜백에서 `ScreenState.isInteractive()`로 조회해 전달하며, 포그라운드 호출부(홈 자동 전송·수동 보고·G+S 활성화 첫 전송)는 앱이 포그라운드에 있다는 것 자체가 interactive 증거이므로 항상 `true`를 명시 전달한다. 가속도/자이로/지자기는 Android 9+ 백그라운드 제한으로 WorkManager에서 항상 null이므로 제거됨. 오탐/미탐, 중복 전송, 데이터 누락 모두 이 파일에서 발생                                                                                                                                                                                                        |
| 1차            | `lib/app/core/services/heartbeat_worker_service.dart`                                             | WorkManager 백그라운드 예약 실행 (Android 전용). 2계층 구조 — (a) one-off: 예약시각에 정확히 1회 fire 후 내일로 재등록, (b) periodic 15분: 안전망 폴링 (one-off 누락 시 15분 내 백업 발화 + 화면 켜짐 Doze 해제 piggyback, fire 후 재등록하지 않고 그대로 유지 — UPDATE/REPLACE 모두 self-cancel/initialDelay 무시 이슈 때문). execute 호출 직전 `ScreenState.isInteractive()`(Android PowerManager 커스텀 플러그인)를 1회 조회해 `HeartbeatService.execute(isInteractiveAtTrigger: ...)`로 전달 — Doze maintenance window에서 화면 꺼진 채 자연 fire(false)와 화면이 깨어있는 상태에서 fire(true)를 구분해 suspicious 판정에 반영. race는 worker 콜백 `lastHeartbeatDate`(오늘 재전송 차단) + `HeartbeatService._executeInternal`의 `lastScheduledKey`(성공 마커) + `HeartbeatLockDatasource`(SQLite UNIQUE CAS, cross-isolate 원자 락)로 3중 방어. **connectivity_plus의 Doze 오판 주의**: WorkManager가 `NetworkType.connected` constraint로 task를 깨웠음에도 `connectivity_plus.checkConnectivity()`가 Doze 상태에서 오프라인으로 잘못 판단하는 케이스가 있었음. 이 때문에 사전 네트워크 체크를 제거하고 Dio 3회 retry(5s/10s 간격)로 처리 (커밋 56f38e8). iOS는 BGTaskScheduler 불안정성으로 사용하지 않음 |
| 2차            | `lib/app/modules/safety_home/controllers/subject_home_controller.dart`                            | 앱 열기/복귀 시 안전망. onInit/onResumed에서 예약시각 경과 + 미전송 시 자동 전송. 서버 스케줄 동기화로 WorkManager 체인 복구도 담당. **첫 설치 시 시각 가드 우회**: `lastHeartbeatDate.isEmpty`이면 `isScheduleInFuture`/`isScheduleTooOld` 검사를 건너뛰고 즉시 전송 — Google Fit 구독 생성 + last_seen baseline + 파이프라인 검증을 한 번에 처리해 D0 갭 해소. `SafetyHomeBaseController`(abstract) 상속 자식 — 부모는 invite_code·schedule·권한·배터리·네트워크·reportNow·sendEmergency 공통 로직, 자식은 `lastHeartbeatDate/Time` 자기 Rx + Drawer/탈퇴/모드전환/휴면 다이얼로그 담당. G+S 자식(`GuardianSafetyCodeController`)은 같은 디렉토리에 위치하며 Dashboard에 위임                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| 3차 (iOS)      | `lib/app/core/services/local_alarm_service.dart`                                                  | iOS 전용 오늘의 안부 확인 메시지 로컬 알림. heartbeat 예약 시각 정각에 매일 반복 → 앱 포그라운드 전환 시 홈 화면 onInit/onResumed에서 자동 전송                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| 공유 캐시      | `lib/app/core/services/guardian_subject_service.dart`                                             | 보호자 대상자 목록 공유 캐시 (2분 TTL). 대시보드·설정·연결관리에서 동일 데이터 사용. 구독 상태 동기화                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| 긴급 위치      | `lib/app/modules/guardian_emergency_map/`                                                         | 대상자 긴급 도움 요청 시 첨부된 위치를 보호자가 Google Maps로 확인하는 페이지. **진입 경로는 알림 목록의 [🗺️ 위치 보기] 버튼 단 하나**. FCM 탭은 `alert_emergency` 포함 모든 `alert_*` type을 알림 목록으로 라우팅하며 (`_routeToNotifications` 자동 새로고침), 사용자가 목록에서 해당 emergency 카드의 버튼을 탭해 지도로 진입 — 단일 진입점 유지로 뒤로가기 스택/새로고침 일관성 확보                                                                                                                                                                                                             |
| 긴급 위치 획득 | `lib/app/data/datasources/remote/emergency_remote_datasource.dart` — `captureEmergencyLocation()` | S 홈 / G+S SafetyCode 긴급 버튼이 공통 사용하는 top-level 헬퍼. 2단계 폴백: (1) `getLastKnownPosition` (수 ms 내 반환) → (2) `getCurrentPosition` medium 정확도 + 10초 타임아웃. high는 GPS only라 실내/콜드 스타트에서 timeout 빈발, medium은 GPS+Wi-Fi+셀룰러 병용해 실내에서도 fix 가능. 권한 거부·GPS 실패·타임아웃 어떤 예외에서도 null 반환하고 throw하지 않는다 — 긴급 API 호출 자체는 위치 유무와 독립                                                                                                                                                                                     |

## 위치 수집 범위

정기 heartbeat에는 위치를 일절 포함하지 않는다. 대상자가 [🚨 도움이 필요해요] 버튼을 누른 경우에 한해 사용자 동의 하에 1회 수집하여 보호자 전원에게 전달하고, 서버는 `notification_events` 테이블에만 저장한다(최대 24시간 보관, 자정 정리 스케줄러가 일괄 삭제). 백그라운드 위치는 절대 사용하지 않는다 (`ACCESS_BACKGROUND_LOCATION` / `Always` / `Background Modes: location` 모두 금지).

## 참조 문서

| 문서             | 경로                                   | 참조 시점                            |
| ---------------- | -------------------------------------- | ------------------------------------ |
| 프론트엔드 PRD   | `.claude/rules/PRD-FrontEnd.md`        | UI 구현, 화면 설계, 로컬 저장소 정책 |
| 백엔드 PRD       | `.claude/rules/PRD-BackEnd.md`         | API 명세, 요청/응답, DB 스키마       |
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
