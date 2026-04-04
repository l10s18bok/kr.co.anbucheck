# Anbu (안부) — 안부 확인 앱

독거노인·1인 가구의 안녕을 자동으로 확인하는 Android/iOS 앱.
하나의 앱에서 **대상자 모드** (heartbeat 전송, Teal 테마)와 **보호자 모드** (Push 수신, Indigo 테마)를 선택.

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
    │   ├── config/         # ApiConfig
    │   ├── database/       # AppDatabase (sqflite)
    │   ├── mixins/         # HeartbeatScheduleMixin
    │   ├── models/         # ApiResponseModel (Freezed)
    │   ├── network/        # ApiClient, ApiClientFactory, ApiEndpoints, ApiError
    │   ├── services/       # FcmService, HeartbeatService, GuardianSubjectService
    │   ├── theme/          # AppColors, AppSpacing, AppTextTheme, AppTheme
    │   ├── translations/   # ko_kr, en_us
    │   ├── usecases/       # UseCase 기반 클래스
    │   ├── utils/          # constants, extensions, time_utils, phone_utils
    │   └── widgets/        # 공통 위젯
    ├── data/
    │   ├── datasources/
    │   │   ├── local/      # TokenLocalDatasource, SensorLocalDatasource,
    │   │   │               # HeartbeatLocalDatasource, NicknameLocalDatasource,
    │   │   │               # NotificationLocalDatasource
    │   │   └── remote/     # UserRemoteDatasource, DeviceRemoteDatasource,
    │   │                   # HeartbeatRemoteDatasource, SubjectRemoteDatasource,
    │   │                   # NotificationSettingsRemoteDatasource, VersionRemoteDatasource
    │   ├── models/         # HeartbeatRequest, NotificationModel
    │   └── repositories/   # NotificationRepositoryImpl
    ├── domain/
    │   ├── entities/       # NotificationEntity
    │   ├── repositories/   # NotificationRepository (추상)
    │   └── usecases/       # GetNotifications, MarkNotificationRead,
    │                       # ResetAllNotificationsRead, CleanupNotifications
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
    │   ├── guardian_past_notifications/
    │   ├── guardian_notification_settings/
    │   └── guardian_settings/
    └── routes/             # AppRoutes, AppPages
```

각 모듈은 `bindings/`, `controllers/`, `views/` 3개 파일로 구성.

## 참조 문서

| 문서             | 경로                                   | 참조 시점                            |
| ---------------- | -------------------------------------- | ------------------------------------ |
| 프론트엔드 PRD   | `.claude/rules/PRD-FrontEnd.md`        | UI 구현, 화면 설계, 로컬 저장소 정책 |
| 백엔드 PRD       | `.claude/rules/PRD-BackEnd.md`         | API 명세, 요청/응답, DB 스키마       |
| Heartbeat 플로우 | `.claude/rules/heartbeat_flowchart.md` | heartbeat 수집·전송·경고 플로우      |

## 규칙
0. 파일을 읽기전에 항상 qmd로 검색
   - qmd search "query"
   - qmd vsearch "query"
   - qmd query "query"
1. 모든 응답·주석·커밋 메시지 **한글** 작성
2. 불확실하면 추론 금지 — **코드를 직접 찾아보고** 답변
3. 새 페이지 모듈은 반드시 `.claude/skills/getx-module/SKILL.md` 절차 준수
4. Controller → UseCase만 의존 (DataSource/Repository 직접 참조 금지)
5. Domain 레이어는 순수 Dart만 사용 (Flutter/GetX import 금지)
6. Freezed 모델은 `abstract class`로 선언
7. 모듈 생성 후 `flutter analyze` 실행

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
