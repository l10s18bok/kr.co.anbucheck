---
name: getx-skill
description: GetX 초기 구조 생성
---

# Flutter 초기 아키텍처 생성 Skill

## 설명
`flutter create` 직후 실행하여, GetX 기반 **클린 아키텍처**의 규격화된 프로젝트 구조를 자동 생성한다.

## 아키텍처 원칙
```
┌─────────────────────────────────────────────┐
│  Presentation (modules/)                    │
│  UI + Controller → UseCase만 의존           │
├─────────────────────────────────────────────┤
│  Domain (domain/)                           │
│  Entity + UseCase + Repository 인터페이스    │
│  ※ 순수 Dart, 프레임워크 의존 없음           │
├─────────────────────────────────────────────┤
│  Data (data/)                               │
│  DTO Model + DataSource + Repository 구현체  │
│  Domain의 인터페이스를 구현                   │
├─────────────────────────────────────────────┤
│  Core (core/)                               │
│  Network, Theme, i18n, Utils 등 공통 인프라   │
└─────────────────────────────────────────────┘

의존성 방향: Presentation → Domain ← Data
Domain은 어떤 레이어도 의존하지 않는다.
```

## 입력
- `{{project_name}}` : pubspec.yaml의 name 필드값 (패키지 import 경로에 사용)

> **사용법**: 이 문서의 모든 `{{project_name}}`을 실제 프로젝트명으로 치환하여 적용한다.

---

## Step 1: pubspec.yaml 의존성 추가

기존 pubspec.yaml에 아래 의존성을 **merge**한다 (버전은 최신 stable 확인 후 적용):

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  get: ^4.6.6
  dio: ^5.7.0
  flutter_screenutil: ^5.9.3
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
```

---

## Step 2: analysis_options.yaml

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: true
```

---

## Step 3: build.yaml

```yaml
targets:
  $default:
    builders:
      json_serializable:
        options:
          any_map: true
          checked: true
```

---

## Step 4: 디렉토리 구조 생성

아래 구조의 모든 디렉토리와 파일을 생성한다:

```
lib/
├── main.dart
├── app.dart
├── app/
│   ├── core/
│   │   ├── base/
│   │   │   └── base_controller.dart
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   ├── api_response.dart
│   │   │   ├── api_connect.dart
│   │   │   ├── dio_connect.dart
│   │   │   ├── api_client_factory.dart
│   │   │   ├── api_error.dart
│   │   │   └── api_endpoints.dart
│   │   ├── models/
│   │   │   └── api_response_model.dart
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_theme.dart
│   │   │   └── app_theme.dart
│   │   ├── translations/
│   │   │   ├── app_translations.dart
│   │   │   ├── ko_kr.dart
│   │   │   └── en_us.dart
│   │   ├── usecases/
│   │   │   └── use_case.dart
│   │   ├── utils/
│   │   │   ├── constants.dart
│   │   │   └── extensions.dart
│   │   └── widgets/
│   │       └── .gitkeep
│   ├── domain/
│   │   ├── entities/
│   │   │   └── .gitkeep
│   │   ├── repositories/
│   │   │   └── .gitkeep
│   │   └── usecases/
│   │       └── .gitkeep
│   ├── data/
│   │   ├── models/
│   │   │   └── .gitkeep
│   │   ├── datasources/
│   │   │   ├── remote/
│   │   │   │   └── .gitkeep
│   │   │   └── local/
│   │   │       └── .gitkeep
│   │   └── repositories/
│   │       └── .gitkeep
│   ├── modules/
│   │   └── splash/
│   │       ├── bindings/
│   │       │   └── splash_binding.dart
│   │       ├── controllers/
│   │       │   └── splash_controller.dart
│   │       └── views/
│   │           └── splash_page.dart
│   └── routes/
│       ├── app_pages.dart
│       └── app_routes.dart
test/
├── unit/
│   ├── domain/
│   │   └── .gitkeep
│   └── data/
│       └── .gitkeep
├── widget/
│   └── .gitkeep
└── helpers/
    └── test_helper.dart
```

### 레이어별 역할

| 레이어 | 디렉토리 | 역할 | 의존 가능 대상 |
|---|---|---|---|
| **Domain** | `domain/entities/` | 순수 비즈니스 객체 (프레임워크 의존 없음) | 없음 (독립) |
| | `domain/repositories/` | Repository 추상 인터페이스 정의 | Entity만 |
| | `domain/usecases/` | 비즈니스 로직 단위 (하나의 기능 = 하나의 UseCase) | Entity, Repository 인터페이스 |
| **Data** | `data/models/` | Freezed DTO (JSON ↔ Entity 변환) | Domain Entity |
| | `data/datasources/remote/` | API 호출 (ApiConnect 사용) | Core Network |
| | `data/datasources/local/` | 로컬 캐시/DB | - |
| | `data/repositories/` | Domain Repository 인터페이스 구현체 | DataSource, Model |
| **Presentation** | `modules/{feature}/` | UI + Controller | Domain UseCase만 |
| **Core** | `core/` | 공통 인프라 (네트워크, 테마 등) | Flutter/Dart SDK |

---

## Step 5: Core Layer 파일

### 5-1. `lib/app/core/base/base_controller.dart`

```dart
import 'package:get/get.dart';

abstract class BaseController extends FullLifeCycleController
    with FullLifeCycleMixin {
  final _isLoading = false.obs;

  set isLoading(bool value) => _isLoading.value = value;
  bool get isLoading => _isLoading.value;

  @override
  void onDetached() {}

  @override
  void onHidden() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {}
}
```

### 5-2 ~ 5-4. Network Layer (전체 파일)

> **참조 소스**: `templates/network/` 폴더의 파일을 `lib/app/core/network/`로 복사한다.
> 복사 후 파일 내의 `package:llm_agent_auto`를 `package:{{project_name}}`으로 치환한다.

```
templates/network/
├── api_client.dart          ← 공통 추상 인터페이스 + getBody() Extension
├── api_response.dart        ← 공통 응답 모델 ApiResult<T>
├── api_connect.dart         ← GetConnect 기반 구현체 (GetConnectClient)
├── dio_connect.dart         ← Dio 기반 구현체 (DioClient)
├── api_client_factory.dart  ← 팩토리 (구현체 선택 스위칭)
├── api_error.dart           ← API 에러 클래스
└── api_endpoints.dart       ← 엔드포인트 상수
```

**아키텍처 구조:**
```
┌─────────────────────────┐
│  ApiClient (abstract)   │  ← 공통 인터페이스
│  get / post / put / del │
│  + getBody() Extension  │
└──────┬──────────┬───────┘
       │          │
  ┌────▼────┐  ┌──▼──────┐
  │GetConnect│  │DioClient│  ← 구현체 (선택적)
  │Client   │  │         │
  └─────────┘  └─────────┘
       ▲          ▲
       └────┬─────┘
  ┌─────────▼─────────┐
  │ApiClientFactory    │  ← main.dart에서 init
  │.init(type: ...)    │
  └───────────────────┘
```

**사용법 (DataSource에서):**
```dart
final api = ApiClientFactory.instance;
final result = await api.get('/users');
final data = result.getBody(); // 에러 자동 처리
```

### 5-5. `lib/app/core/models/api_response_model.dart`

> ref의 `general_response_model.dart`를 Freezed로 변환한 버전

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response_model.freezed.dart';
part 'api_response_model.g.dart';

@Freezed(genericArgumentFactories: true)
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    T? data,
  }) = _ApiResponse;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);
}

@Freezed(genericArgumentFactories: true)
class ApiListResponse<T> with _$ApiListResponse<T> {
  const factory ApiListResponse({
    @Default('') String errCode,
    @Default('') String errNo,
    @Default([]) List<T> data,
  }) = _ApiListResponse;

  factory ApiListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiListResponseFromJson(json, fromJsonT);
}

@freezed
class DynamicResponse with _$DynamicResponse {
  const factory DynamicResponse({
    required String code,
    required String msg,
    required dynamic result,
  }) = _DynamicResponse;

  factory DynamicResponse.fromJson(Map<String, dynamic> json) =>
      _$DynamicResponseFromJson(json);
}
```

### 5-6. `lib/app/core/usecases/use_case.dart`

> UseCase 베이스 인터페이스 — 모든 UseCase가 구현하는 공통 계약

```dart
/// UseCase 베이스 인터페이스
/// [Type] : 반환 타입
/// [Params] : 입력 파라미터 타입
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// 파라미터가 필요 없는 UseCase용
class NoParams {
  const NoParams();
}
```

---

## Step 6: Theme 파일

### 6-1. `lib/app/core/theme/app_colors.dart`

```dart
import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryVariant = Color(0xFF3700B3);

  // Secondary
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);

  // Background
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // Status
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);

  // Divider
  static const Color divider = Color(0xFFBDBDBD);
}
```

### 6-2. `lib/app/core/theme/app_text_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:{{project_name}}/app/core/theme/app_colors.dart';

abstract class AppTextTheme {
  static TextStyle heading1({Color? color, FontWeight? fw}) => TextStyle(
        fontSize: 24.sp,
        fontWeight: fw ?? FontWeight.w700,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle heading2({Color? color, FontWeight? fw}) => TextStyle(
        fontSize: 20.sp,
        fontWeight: fw ?? FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle body1({Color? color, FontWeight? fw}) => TextStyle(
        fontSize: 16.sp,
        fontWeight: fw ?? FontWeight.w400,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle body2({Color? color, FontWeight? fw}) => TextStyle(
        fontSize: 14.sp,
        fontWeight: fw ?? FontWeight.w400,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle caption({Color? color, FontWeight? fw}) => TextStyle(
        fontSize: 12.sp,
        fontWeight: fw ?? FontWeight.w400,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle button({Color? color, FontWeight? fw}) => TextStyle(
        fontSize: 16.sp,
        fontWeight: fw ?? FontWeight.w600,
        color: color ?? Colors.white,
      );
}
```

### 6-3. `lib/app/core/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:{{project_name}}/app/core/theme/app_colors.dart';

abstract class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.error,
          surface: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        dividerColor: AppColors.divider,
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.error,
        ),
      );
}
```

---

## Step 7: Translations (다국어)

### 7-1. `lib/app/core/translations/app_translations.dart`

```dart
import 'package:get/get.dart';
import 'package:{{project_name}}/app/core/translations/ko_kr.dart';
import 'package:{{project_name}}/app/core/translations/en_us.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ko_KR': KoKr.translations,
        'en_US': EnUs.translations,
      };
}
```

### 7-2. `lib/app/core/translations/ko_kr.dart`

```dart
abstract class KoKr {
  static const Map<String, String> translations = {
    // 공통
    '확인': '확인',
    '취소': '취소',
    '저장': '저장',
    '삭제': '삭제',
    '닫기': '닫기',
    '로딩중': '로딩중...',

    // API 에러
    '알수없는 에러': '알수없는 에러가 발생했습니다.',
    '타임아웃 에러': '요청 시간이 초과되었습니다.',
    '연결 에러': '네트워크 연결을 확인해주세요.',
    '비승인 사용자': '인증이 필요합니다.',
  };
}
```

### 7-3. `lib/app/core/translations/en_us.dart`

```dart
abstract class EnUs {
  static const Map<String, String> translations = {
    // Common
    '확인': 'Confirm',
    '취소': 'Cancel',
    '저장': 'Save',
    '삭제': 'Delete',
    '닫기': 'Close',
    '로딩중': 'Loading...',

    // API Errors
    '알수없는 에러': 'An unknown error occurred.',
    '타임아웃 에러': 'Request timed out.',
    '연결 에러': 'Please check your network connection.',
    '비승인 사용자': 'Authentication required.',
  };
}
```

---

## Step 8: Utils

### 8-1. `lib/app/core/utils/constants.dart`

```dart
abstract class AppConstants {
  static const String appName = '{{project_name}}';

  // SharedPreferences Keys
  static const String keyToken = 'token';
  static const String keyLocale = 'locale';
}
```

### 8-2. `lib/app/core/utils/extensions.dart`

```dart
import 'dart:developer' as dev;

extension StringExt on String {
  /// 디버그 로그 출력
  void printLog() {
    dev.log(this, name: 'APP');
  }
}

extension NullableStringExt on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
```

---

## Step 9: Domain Layer 파일 (샘플)

> Domain 레이어는 순수 Dart로만 구성한다. Flutter/GetX 등 프레임워크에 의존하지 않는다.
> 실제 모듈 추가 시 getx-module skill에서 Entity, Repository 인터페이스, UseCase를 함께 생성한다.

### 9-1. 디렉토리 구조 설명

```
domain/
├── entities/           ← 순수 Dart 클래스 (프레임워크 의존 없음)
│                         비즈니스 핵심 객체 정의
│                         예: User, Product, Order
├── repositories/       ← 추상 클래스 (인터페이스 역할)
│                         Data 레이어가 이를 구현
│                         예: abstract class UserRepository { ... }
└── usecases/           ← 비즈니스 로직 단위
                          하나의 UseCase = 하나의 기능
                          Repository 인터페이스에만 의존
                          예: GetUserUseCase, LoginUseCase
```

### 9-2. 의존성 흐름 예시

```
[SplashController]
    │ 의존
    ▼
[CheckAuthUseCase]          ← domain/usecases/
    │ 의존
    ▼
[AuthRepository] (abstract) ← domain/repositories/ (인터페이스)
    │ 구현
    ▼
[AuthRepositoryImpl]        ← data/repositories/ (구현체)
    │ 의존
    ▼
[AuthRemoteDataSource]      ← data/datasources/remote/ (API 호출)
    │ 사용
    ▼
[ApiClientFactory.instance] ← core/network/ (ApiClient 인터페이스)
    │ 구현체 선택
    ├── GetConnectClient    ← GetConnect 기반
    └── DioClient           ← Dio 기반
```

---

## Step 10: Routes

### 10-1. `lib/app/routes/app_routes.dart`

```dart
part of 'app_pages.dart';

abstract class AppRoutes {
  static const splash = '/splash';
  static const home = '/home';
}
```

### 10-2. `lib/app/routes/app_pages.dart`

```dart
import 'package:get/get.dart';
import 'package:{{project_name}}/app/modules/splash/bindings/splash_binding.dart';
import 'package:{{project_name}}/app/modules/splash/views/splash_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
      transition: Transition.noTransition,
      transitionDuration: const Duration(seconds: 0),
    ),
  ];
}
```

---

## Step 11: Splash 모듈 (샘플)

### 11-1. `lib/app/modules/splash/bindings/splash_binding.dart`

```dart
import 'package:get/get.dart';
import 'package:{{project_name}}/app/modules/splash/controllers/splash_controller.dart';

class SplashBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(),
    );
  }
}
```

### 11-2. `lib/app/modules/splash/controllers/splash_controller.dart`

```dart
import 'package:get/get.dart';
import 'package:{{project_name}}/app/core/base/base_controller.dart';
import 'package:{{project_name}}/app/routes/app_pages.dart';

/// Splash 컨트롤러
/// 실제 프로젝트에서는 UseCase를 주입받아 초기화 로직을 처리한다.
/// 예: CheckAuthUseCase, AppVersionCheckUseCase 등
class SplashController extends BaseController {
  // 실제 사용 시 UseCase 주입:
  // final CheckAuthUseCase _checkAuth;
  // SplashController(this._checkAuth);

  @override
  void onInit() {
    super.onInit();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    Get.offNamed(AppRoutes.home);
  }
}
```

### 11-3. `lib/app/modules/splash/views/splash_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:{{project_name}}/app/core/theme/app_colors.dart';
import 'package:{{project_name}}/app/core/theme/app_text_theme.dart';
import 'package:{{project_name}}/app/modules/splash/controllers/splash_controller.dart';

class SplashPage extends GetWidget<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flutter_dash,
                size: 96.w,
                color: Colors.white,
              ),
              SizedBox(height: 16.h),
              Text(
                '{{project_name}}'.tr,
                style: AppTextTheme.heading1(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Step 12: Entry Points

### 12-1. `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:{{project_name}}/app.dart';
import 'package:{{project_name}}/app/core/network/api_client_factory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // HTTP 클라이언트 선택: getConnect 또는 dio
  ApiClientFactory.init(type: HttpClientType.getConnect);

  runApp(const App());
}
```

### 12-2. `lib/app.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:{{project_name}}/app/core/theme/app_theme.dart';
import 'package:{{project_name}}/app/core/translations/app_translations.dart';
import 'package:{{project_name}}/app/routes/app_pages.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: '{{project_name}}',
          translations: AppTranslations(),
          locale: const Locale('ko', 'KR'),
          fallbackLocale: const Locale('en', 'US'),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
        );
      },
    );
  }
}
```

---

## Step 13: Test Helper

### `test/helpers/test_helper.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// GetX 테스트용 바인딩 초기화
void setupTestBinding() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;
}

/// 테스트 후 GetX 정리
void tearDownGetX() {
  Get.reset();
}
```

---

## Step 14: build_runner 실행

모든 파일 생성 후 아래 명령어를 실행한다:

```bash
dart run build_runner build --delete-conflicting-outputs
```

이 명령은 `*.freezed.dart`와 `*.g.dart` 파일을 자동 생성한다.

---

## 검증 체크리스트

1. `flutter pub get` — 의존성 설치 성공
2. `dart run build_runner build --delete-conflicting-outputs` — 코드 생성 성공
3. `flutter analyze` — 에러 없음
4. `flutter run` — 앱 실행 및 splash 화면 표시
5. **클린 아키텍처 검증**: Controller가 UseCase만 의존하고, Provider/DataSource를 직접 참조하지 않음
