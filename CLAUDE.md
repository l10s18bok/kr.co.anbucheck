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
    │   │   ├── local/      # TokenLocalDatasource, SensorLocalDatasource,
    │   │   │               # HeartbeatLocalDatasource, NicknameLocalDatasource
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
    │   ├── subject_home/               # 대상자 홈
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
- `GuardianSettingsController` — G+S 활성화/비활성화 라이프사이클 관리, 안전코드 페이지 진입
- `GuardianDashboardController` — G+S일 때 heartbeat 예약 + 활동 인식 권한 확인
- `ModeSelectController` — 재설치 시 `has_invite_code`로 G+S 감지 → `isAlsoSubject` 전달

## 핵심 파일 (Heartbeat 3계층 구조)

이 앱의 핵심은 "사용자 조작 없이 매일 heartbeat가 확실히 전송되는 것"이다.
아래 4개 파일이 3계층 전송 구조를 각각 담당하며, 어느 하나가 망가져도 안부 확인 서비스가 무너진다.

| 계층 | 파일 | 역할 |
|------|------|------|
| 공통 | `lib/app/core/services/heartbeat_service.dart` | heartbeat 1회 실행의 전체 로직: 센서 수집 → suspicious 판정 → 서버 전송 → 실패 시 큐 저장 → 데드맨 알림 재예약. 오탐/미탐, 중복 전송, 데이터 누락 모두 이 파일에서 발생 |
| 1차 | `lib/app/core/services/heartbeat_worker_service.dart` | WorkManager 백그라운드 예약 실행 (Android 전용). 2계층 구조 — (a) one-off: 예약시각에 정확히 1회 fire 후 내일로 재등록, (b) periodic 1시간: 안전망 폴링 (one-off 누락 시 1시간 내 백업 발화, fire 후 재등록하지 않고 그대로 유지 — UPDATE/REPLACE 모두 self-cancel/initialDelay 무시 이슈 때문). race는 2중 dedup으로 방어: worker 콜백 `lastHeartbeatDate` + `HeartbeatService._executeInternal`의 `lastScheduledKey`. iOS는 BGTaskScheduler 불안정성으로 사용하지 않음 |
| 2차 | `lib/app/modules/subject_home/controllers/subject_home_controller.dart` | 앱 열기/복귀 시 안전망. onInit/onResumed에서 예약시각 경과 + 미전송 시 자동 전송. 서버 스케줄 동기화로 WorkManager 체인 복구도 담당 |
| 3차 (iOS) | `lib/app/core/services/local_alarm_service.dart` | iOS 전용 데드맨 스위치 로컬 알림. heartbeat 시각 + 30분(일반) 또는 예약 시각 정각(G+S)에 매일 반복 → 앱 포그라운드 전환 시 홈 화면 onInit/onResumed에서 자동 전송. Android는 데드맨 알림 없이 앱 열기 자동 전송(2차)만으로 안전망 구성 |
| 공유 캐시 | `lib/app/core/services/guardian_subject_service.dart` | 보호자 대상자 목록 공유 캐시 (2분 TTL). 대시보드·설정·연결관리에서 동일 데이터 사용. 구독 상태 동기화 |

## 참조 문서

| 문서             | 경로                                   | 참조 시점                            |
| ---------------- | -------------------------------------- | ------------------------------------ |
| 프론트엔드 PRD   | `.claude/rules/PRD-FrontEnd.md`        | UI 구현, 화면 설계, 로컬 저장소 정책 |
| 백엔드 PRD       | `.claude/rules/PRD-BackEnd.md`         | API 명세, 요청/응답, DB 스키마       |
| Heartbeat 플로우 | `.claude/rules/heartbeat_flowchart.md` | heartbeat 수집·전송·경고 플로우      |

## 규칙
0. 코드 파악이 필요할 때 파일을 직접 읽기 전에 qmd로 먼저 검색
   - `qmd query "검색어"` — 권장 (하이브리드 검색)
   - `qmd search "검색어"` — 키워드 정확 매칭
   - `qmd vsearch "검색어"` — 의미 유사도 검색
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
