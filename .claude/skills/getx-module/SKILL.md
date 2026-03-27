---
name: getx-module
description: GetX 모듈 추가
---

# Flutter 모듈 생성 Skill

## 설명
기존 프로젝트에 새로운 모듈(feature)을 추가한다. getx-skill로 생성된 클린 아키텍처 구조를 전제로 한다.

## 클린 아키텍처 의존성 규칙
```
Controller → UseCase → Repository(인터페이스) ← RepositoryImpl → DataSource
```
- Controller는 UseCase만 의존한다 (DataSource/Provider를 직접 참조하지 않는다)
- UseCase는 Domain Repository 인터페이스만 의존한다
- RepositoryImpl(Data 레이어)이 Domain 인터페이스를 구현한다

## 입력
- `{{module_name}}` : snake_case 모듈명 (예: user_profile, order_history)
- `{{project_name}}` : pubspec.yaml의 name 필드값

## 옵션 (기본값: 모두 true)
- `has_api` : DataSource/Repository/UseCase 생성 여부 (API 연동이 필요한 모듈)
- `has_model` : Freezed DTO 모델 + Domain Entity 생성 여부

---

## 네이밍 규칙

`{{module_name}}`으로부터 자동 도출:

| 항목 | 규칙 | 예시 (user_profile) |
|---|---|---|
| 디렉토리 | snake_case | `modules/user_profile/` |
| 클래스 접두사 | PascalCase | `UserProfile` |
| 라우트 상수 | camelCase | `AppRoutes.userProfile` |
| 라우트 경로 | kebab-case | `'/user-profile'` |
| 파일명 | snake_case | `user_profile_controller.dart` |

> 아래 템플릿에서 `{{Name}}`은 PascalCase, `{{name}}`은 snake_case를 의미한다.

---

## Step 1: Domain Layer 파일 (has_api = true 일 때)

> Domain은 순수 Dart만 사용한다. Flutter/GetX 등 프레임워크를 import하지 않는다.

### 1-1. `lib/app/domain/entities/{{name}}_entity.dart` (has_model = true 일 때)

```dart
/// {{Name}} 도메인 엔티티
/// 순수 비즈니스 객체 — 프레임워크 의존 없음
class {{Name}}Entity {
  final String? id;
  final String? name;
  // 비즈니스에 필요한 필드 추가

  const {{Name}}Entity({
    this.id,
    this.name,
  });
}
```

### 1-2. `lib/app/domain/repositories/{{name}}_repository.dart`

```dart
import 'package:{{project_name}}/app/domain/entities/{{name}}_entity.dart';

/// {{Name}} Repository 인터페이스
/// Data 레이어에서 이를 구현한다
abstract class {{Name}}Repository {
  Future<List<{{Name}}Entity>> fetchList();
  Future<{{Name}}Entity> fetchById(String id);
  Future<void> create({{Name}}Entity entity);
  Future<void> update({{Name}}Entity entity);
  Future<void> remove(String id);
}
```

### 1-3. `lib/app/domain/usecases/get_{{name}}_list_usecase.dart`

```dart
import 'package:{{project_name}}/app/core/usecases/use_case.dart';
import 'package:{{project_name}}/app/domain/entities/{{name}}_entity.dart';
import 'package:{{project_name}}/app/domain/repositories/{{name}}_repository.dart';

class Get{{Name}}ListUseCase implements UseCase<List<{{Name}}Entity>, NoParams> {
  final {{Name}}Repository _repository;

  Get{{Name}}ListUseCase(this._repository);

  @override
  Future<List<{{Name}}Entity>> call(NoParams params) {
    return _repository.fetchList();
  }
}
```

> 필요에 따라 UseCase를 추가 생성한다:
> - `Get{{Name}}DetailUseCase` (단건 조회)
> - `Create{{Name}}UseCase` (생성)
> - `Update{{Name}}UseCase` (수정)
> - `Delete{{Name}}UseCase` (삭제)

---

## Step 2: Data Layer 파일 (has_api = true 일 때)

### 2-1. `lib/app/data/models/{{name}}_model.dart` (has_model = true 일 때)

> Freezed DTO — JSON 직렬화/역직렬화 담당. Domain Entity와 변환 메서드 포함.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:{{project_name}}/app/domain/entities/{{name}}_entity.dart';

part '{{name}}_model.freezed.dart';
part '{{name}}_model.g.dart';

@freezed
abstract class {{Name}}Model with _${{Name}}Model {
  const {{Name}}Model._();

  const factory {{Name}}Model({
    String? id,
    String? name,
    // 필요한 필드 추가 (API 응답 필드와 1:1 매핑)
  }) = _{{Name}}Model;

  factory {{Name}}Model.fromJson(Map<String, dynamic> json) =>
      _${{Name}}ModelFromJson(json);

  /// DTO → Domain Entity 변환
  {{Name}}Entity toEntity() => {{Name}}Entity(
        id: id,
        name: name,
      );

  /// Domain Entity → DTO 변환
  factory {{Name}}Model.fromEntity({{Name}}Entity entity) => {{Name}}Model(
        id: entity.id,
        name: entity.name,
      );
}
```

### 2-2. `lib/app/data/datasources/remote/{{name}}_remote_datasource.dart`

> API 호출만 담당한다. 비즈니스 로직 없음.

```dart
import 'package:{{project_name}}/app/core/network/api_client_factory.dart';
import 'package:{{project_name}}/app/core/network/api_endpoints.dart';
import 'package:{{project_name}}/app/data/models/{{name}}_model.dart';

class {{Name}}RemoteDataSource {
  final _api = ApiClientFactory.instance;

  Future<List<{{Name}}Model>> fetchList() async {
    final response = await _api.get(ApiEndpoints.{{name}});
    final body = response.getBody();
    // API 응답 구조에 맞게 파싱
    // return (body as List).map((e) => {{Name}}Model.fromJson(e)).toList();
    throw UnimplementedError();
  }

  Future<{{Name}}Model> fetchById(String id) async {
    final response = await _api.get('${ApiEndpoints.{{name}}}/$id');
    final body = response.getBody();
    // return {{Name}}Model.fromJson(body);
    throw UnimplementedError();
  }

  Future<void> create({{Name}}Model model) async {
    await _api.post(ApiEndpoints.{{name}}, model.toJson());
  }

  Future<void> update({{Name}}Model model) async {
    await _api.put('${ApiEndpoints.{{name}}}/${model.id}', model.toJson());
  }

  Future<void> remove(String id) async {
    await _api.delete('${ApiEndpoints.{{name}}}/$id');
  }
}
```

### 2-3. `lib/app/data/repositories/{{name}}_repository_impl.dart`

> Domain Repository 인터페이스를 구현한다. Entity ↔ Model 변환을 여기서 처리.

```dart
import 'package:{{project_name}}/app/data/datasources/remote/{{name}}_remote_datasource.dart';
import 'package:{{project_name}}/app/data/models/{{name}}_model.dart';
import 'package:{{project_name}}/app/domain/entities/{{name}}_entity.dart';
import 'package:{{project_name}}/app/domain/repositories/{{name}}_repository.dart';

class {{Name}}RepositoryImpl implements {{Name}}Repository {
  final {{Name}}RemoteDataSource _remoteDataSource;

  {{Name}}RepositoryImpl(this._remoteDataSource);

  @override
  Future<List<{{Name}}Entity>> fetchList() async {
    final models = await _remoteDataSource.fetchList();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<{{Name}}Entity> fetchById(String id) async {
    final model = await _remoteDataSource.fetchById(id);
    return model.toEntity();
  }

  @override
  Future<void> create({{Name}}Entity entity) async {
    await _remoteDataSource.create({{Name}}Model.fromEntity(entity));
  }

  @override
  Future<void> update({{Name}}Entity entity) async {
    await _remoteDataSource.update({{Name}}Model.fromEntity(entity));
  }

  @override
  Future<void> remove(String id) async {
    await _remoteDataSource.remove(id);
  }
}
```

---

## Step 3: Presentation Layer 파일

### 3-1. `lib/app/modules/{{name}}/bindings/{{name}}_binding.dart`

> Binding에서 전체 의존성 체인을 조립한다: DataSource → Repository → UseCase → Controller

```dart
import 'package:get/get.dart';
import 'package:{{project_name}}/app/modules/{{name}}/controllers/{{name}}_controller.dart';
// has_api = true 일 때 아래 import 추가
import 'package:{{project_name}}/app/data/datasources/remote/{{name}}_remote_datasource.dart';
import 'package:{{project_name}}/app/data/repositories/{{name}}_repository_impl.dart';
import 'package:{{project_name}}/app/domain/usecases/get_{{name}}_list_usecase.dart';

class {{Name}}Binding implements Bindings {
  @override
  void dependencies() {
    // has_api = true 일 때: 의존성 체인 조립
    final dataSource = {{Name}}RemoteDataSource();
    final repository = {{Name}}RepositoryImpl(dataSource);
    final useCase = Get{{Name}}ListUseCase(repository);

    Get.lazyPut<{{Name}}Controller>(
      () => {{Name}}Controller(get{{Name}}List: useCase),
    );

    // has_api = false 일 때:
    // Get.lazyPut<{{Name}}Controller>(
    //   () => {{Name}}Controller(),
    // );
  }
}
```

### 3-2. `lib/app/modules/{{name}}/controllers/{{name}}_controller.dart`

> Controller는 UseCase만 의존한다. DataSource/Repository를 직접 참조하지 않는다.

```dart
import 'package:get/get.dart';
import 'package:{{project_name}}/app/core/base/base_controller.dart';
// has_api = true 일 때 아래 import 추가
import 'package:{{project_name}}/app/core/usecases/use_case.dart';
import 'package:{{project_name}}/app/domain/entities/{{name}}_entity.dart';
import 'package:{{project_name}}/app/domain/usecases/get_{{name}}_list_usecase.dart';

class {{Name}}Controller extends BaseController {
  // has_api = true 일 때
  final Get{{Name}}ListUseCase _get{{Name}}List;

  {{Name}}Controller({
    required Get{{Name}}ListUseCase get{{Name}}List,
  }) : _get{{Name}}List = get{{Name}}List;

  // has_api = false 일 때
  // {{Name}}Controller();

  final _items = <{{Name}}Entity>[].obs;
  List<{{Name}}Entity> get items => _items;

  @override
  void onInit() {
    super.onInit();
    // fetchList();
  }

  Future<void> fetchList() async {
    try {
      isLoading = true;
      final result = await _get{{Name}}List(const NoParams());
      _items.assignAll(result);
    } catch (e) {
      // 에러 처리
    } finally {
      isLoading = false;
    }
  }
}
```

### 3-3. `lib/app/modules/{{name}}/views/{{name}}_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:{{project_name}}/app/modules/{{name}}/controllers/{{name}}_controller.dart';

class {{Name}}Page extends GetWidget<{{Name}}Controller> {
  const {{Name}}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('{{Name}}'.tr),
      ),
      body: SafeArea(
        child: Obx(
          () => controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      '{{Name}} Page',
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
```

### 3-4. `lib/app/modules/{{name}}/widgets/` — 디렉토리만 생성 (.gitkeep)

---

## Step 4: 라우트 등록 (기존 파일 수정)

### 4-1. `lib/app/routes/app_routes.dart`에 추가

```dart
static const {{moduleName}} = '/{{module-name}}';
```

> `{{moduleName}}`은 camelCase, `{{module-name}}`은 kebab-case

### 4-2. `lib/app/routes/app_pages.dart`에 추가

상단 import 추가:
```dart
import 'package:{{project_name}}/app/modules/{{name}}/bindings/{{name}}_binding.dart';
import 'package:{{project_name}}/app/modules/{{name}}/views/{{name}}_page.dart';
```

pages 리스트에 추가:
```dart
GetPage(
  name: AppRoutes.{{moduleName}},
  page: () => const {{Name}}Page(),
  binding: {{Name}}Binding(),
),
```

---

## Step 5: ApiEndpoints 등록 (has_api = true 일 때)

`lib/app/core/network/api_endpoints.dart`에 엔드포인트 추가:

```dart
static const String {{name}} = '/{{module-name}}';
```

---

## Step 6: build_runner 실행 (has_model = true 일 때)

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 생성 파일 요약

### has_api = true, has_model = true (전체 생성)

```
생성:
  Domain Layer:
    lib/app/domain/entities/{{name}}_entity.dart
    lib/app/domain/repositories/{{name}}_repository.dart
    lib/app/domain/usecases/get_{{name}}_list_usecase.dart

  Data Layer:
    lib/app/data/models/{{name}}_model.dart                        (Freezed)
    lib/app/data/datasources/remote/{{name}}_remote_datasource.dart
    lib/app/data/repositories/{{name}}_repository_impl.dart

  Presentation Layer:
    lib/app/modules/{{name}}/bindings/{{name}}_binding.dart
    lib/app/modules/{{name}}/controllers/{{name}}_controller.dart
    lib/app/modules/{{name}}/views/{{name}}_page.dart
    lib/app/modules/{{name}}/widgets/.gitkeep

수정:
    lib/app/routes/app_routes.dart     → 라우트 상수 추가
    lib/app/routes/app_pages.dart      → GetPage + import 추가
    lib/app/core/network/api_endpoints.dart → 엔드포인트 추가
```

### has_api = false, has_model = false (UI 전용)

```
생성:
    lib/app/modules/{{name}}/bindings/{{name}}_binding.dart
    lib/app/modules/{{name}}/controllers/{{name}}_controller.dart
    lib/app/modules/{{name}}/views/{{name}}_page.dart
    lib/app/modules/{{name}}/widgets/.gitkeep

수정:
    lib/app/routes/app_routes.dart     → 라우트 상수 추가
    lib/app/routes/app_pages.dart      → GetPage + import 추가
```

---

## 의존성 흐름 다이어그램 (has_api = true)

```
┌──────────────────── Presentation ────────────────────┐
│                                                      │
│  {{Name}}Binding                                     │
│    └─ 조립: DataSource → RepoImpl → UseCase → Ctrl  │
│                                                      │
│  {{Name}}Controller                                  │
│    └─ 의존: Get{{Name}}ListUseCase (Domain만)         │
│                                                      │
│  {{Name}}Page                                        │
│    └─ 의존: {{Name}}Controller                       │
│                                                      │
├──────────────────── Domain ──────────────────────────┤
│                                                      │
│  {{Name}}Entity          (순수 Dart 객체)              │
│  {{Name}}Repository      (추상 인터페이스)              │
│  Get{{Name}}ListUseCase  (비즈니스 로직)               │
│                                                      │
├──────────────────── Data ────────────────────────────┤
│                                                      │
│  {{Name}}Model               (Freezed DTO)           │
│    └─ toEntity() / fromEntity()                      │
│  {{Name}}RemoteDataSource    (API 호출)               │
│    └─ ApiClientFactory 사용                           │
│  {{Name}}RepositoryImpl      (Repository 구현체)      │
│    └─ DataSource 사용, Entity ↔ Model 변환            │
│                                                      │
└──────────────────────────────────────────────────────┘
```

---

## 주의사항 (필수 준수)

### Freezed 모델 선언
- Freezed 모델은 반드시 `abstract class`로 선언한다.
- `class {{Name}}Model` ❌ → `abstract class {{Name}}Model` ✅
- 최신 Freezed(v3+)에서는 mixin이 abstract getter와 `toJson()`을 포함하므로, 일반 class로 선언하면 `non_abstract_class_inherits_abstract_member` 에러가 발생한다.
- `const {{Name}}Model._()` private 생성자는 반드시 유지한다 (서브클래스 `_{{Name}}Model`이 `super._()` 호출).

---

## 검증 체크리스트

1. `flutter pub get` — 의존성 확인
2. `dart run build_runner build --delete-conflicting-outputs` — Freezed 코드 생성 (has_model 시)
3. **`flutter analyze` — 에러 없음 확인 (필수)**
4. 라우트 등록 확인 — `AppRoutes`와 `AppPages`에 정상 등록
5. **클린 아키텍처 검증**:
   - Controller가 UseCase만 import하고 있는가?
   - Domain 파일에 Flutter/GetX import가 없는가?
   - Repository 인터페이스(Domain)와 구현체(Data)가 분리되어 있는가?

> **중요**: 모듈 생성 완료 후 반드시 `flutter analyze`를 실행하여 에러가 없는지 확인한다. 에러가 있으면 수정 후 다시 analyze를 통과시킨다.

---

## 사용 예시

### 예시 1: home 모듈 (API 연동 + 모델)
```
module_name: home
project_name: my_app
has_api: true
has_model: true
```

### 예시 2: settings 모듈 (UI 전용)
```
module_name: settings
project_name: my_app
has_api: false
has_model: false
```
