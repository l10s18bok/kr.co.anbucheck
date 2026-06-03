---
name: store-update
description: 스토어 업데이트(스토어 업데이트/스토어 배포/앱 배포/release 배포/store update) — 플랫폼(android/ios)을 묻고 버전을 올린 뒤 스토어용 빌드를 만든다. android는 APK/AAB 중 선택, ios는 ipa 빌드 후 Xcode Organizer를 연다. **서버 버전 DB는 절대 건드리지 않는다** — 스토어에 신버전이 실제 출시(심사 통과)된 것을 확인한 뒤 별도 "서버 버전 업데이트" 스킬을 실행한다.
---

# 스토어 업데이트 Skill (빌드/업로드 전용)

## 설명
스토어 배포용 빌드를 만든다. 플랫폼·산출물·버전을 사용자에게 질문으로 확정한 뒤 `pubspec.yaml` 버전을 올리고 빌드한다.

> **이 스킬은 서버 `app_versions` DB를 갱신하지 않는다.** 빌드/업로드와 서버 버전 플립을 분리하는 이유: 서버 DB를 먼저 바꾸면 스토어 심사가 끝나기 전에 사용자에게 "아직 받을 수 없는 버전"으로 업데이트 안내(강제면 soft-brick)가 뜬다. 심사 시점은 예측 불가하므로, **스토어에 신버전이 실제 출시된 것을 확인한 뒤** "서버 버전 업데이트" 스킬(`server-version-update`)을 따로 실행한다.

## 절차

### 1. 플랫폼 질문
`AskUserQuestion`으로 묻는다: **Android** / **iOS** / **둘 다**.

### 2. (Android 포함 시) 산출물 질문
**Android** 또는 **둘 다** 선택 시 `AskUserQuestion`으로 Android 산출물을 묻는다:
- **AAB (appbundle)** — Play Console 정식 배포용 (`build/app/outputs/bundle/release/app-release.aab`)
- **APK** — 직접 배포/QA 설치용 (`build/app/outputs/flutter-apk/app-release.apk`). 빌드 후 실기기 설치는 `install-release` 스킬로.
- **둘 다** — AAB·APK 모두 빌드 (Play Console 업로드 + QA 실기기 설치를 한 번에)

iOS는 산출물 질문 없이 ipa.

### 3. 버전 질문

**단일 플랫폼(Android 또는 iOS)** 선택 시 — `pubspec.yaml`의 현재 `version`(예: `1.1.5+23`)을 보여주고 `AskUserQuestion`으로 묻는다:
- **다음 버전 자동** — 버전명 patch +1, 빌드번호 +1 (예: `1.1.5+23` → `1.1.6+24`)
- **수동 입력** — 버전명을 직접 입력받는다(예: `1.2.0`). 빌드번호는 **항상 +1** 한다(스토어는 동일 버전이라도 빌드번호가 이전보다 커야 함).

**둘 다(Android+iOS)** 선택 시 — 먼저 버전 정책을 `AskUserQuestion`으로 묻는다:
- **양쪽 동일 버전** — 위 단일 질문(자동/수동)을 1회 받아 두 플랫폼에 같은 버전 적용. 동시 릴리스의 일반적 경우. `pubspec.yaml`의 `version`은 단일 값이고 Android(versionCode)·iOS(빌드번호)가 이를 공유하므로 한 번만 묻는다.
- **플랫폼별 개별 버전** — Android·iOS 버전이 이미 어긋나 있는 경우(스토어 심사 타이밍·핫픽스로 드리프트). **각 플랫폼의 버전명 + 빌드번호를 따로 입력**받는다. (단일 `pubspec.yaml version`으로 두 버전을 담을 수 없으므로 빌드 시 `--build-name`/`--build-number`로 주입 — 4·5단계 참조.)

### 4. 버전 반영

- **단일 플랫폼 / 둘 다·양쪽 동일** (공유 버전):
  - `pubspec.yaml`의 `version`을 새 값으로 수정한다.
  - `lib/app/modules/splash/controllers/splash_controller.dart`의 `_appVersionFallback` 상수도 새 **버전명**(빌드번호 제외)으로 맞춘다 — 정상 경로는 `PackageInfo`가 실제 버전을 읽지만, 조회 실패 시 fallback이 stale하면 버전 비교가 틀어지므로 동기화한다.
  - 빌드는 pubspec 값을 그대로 읽는다(플래그 주입 없음).

- **둘 다·플랫폼별 개별** (드리프트):
  - 빌드 자체는 5단계에서 `--build-name`/`--build-number`로 플랫폼별 버전을 주입한다(각 바이너리가 자기 버전을 가짐).
  - 단, `pubspec.yaml`의 `version`은 **두 버전 중 최신(높은) 것으로 기록한다** — 버전명으로 비교(서버 `_compare_versions`와 동일 규칙: 점 구분 정수 비교)하고, 버전명이 같으면 빌드번호가 큰 쪽의 전체 버전을 그대로 쓴다. 예: Android `1.1.6+24`, iOS `1.2.0+11` → pubspec `1.2.0+11`.
  - `_appVersionFallback`도 그 **최신 버전명**(빌드번호 제외)으로 맞춘다 — 정상 경로는 각 바이너리의 `PackageInfo`가 주입된 버전을 읽으므로, fallback은 조회 실패 시의 예비값으로 최신 버전을 가리키면 충분하다.

### 5. 빌드
선택한 플랫폼의 빌드를 실행한다. **둘 다**면 Android(선택한 산출물) → iOS 순서로 **둘 다 실행**한다.

> **플랫폼별 개별 버전(드리프트) 모드**일 때는 아래 각 명령 끝에 해당 플랫폼 버전을 주입한다: `--build-name=<버전명> --build-number=<빌드번호>` (예: Android `--build-name=1.1.6 --build-number=24`, iOS `--build-name=1.2.0 --build-number=11`). **양쪽 동일/단일** 모드는 플래그 없이 pubspec 값을 그대로 쓴다.

- **Android AAB**
  ```bash
  flutter build appbundle --release
  ```
  완료 후 산출물 경로 안내: `build/app/outputs/bundle/release/app-release.aab`
  → Play Console → 해당 트랙(비공개 테스트/프로덕션) → 새 버전 만들기 → 이 `.aab` 업로드

- **Android APK**
  ```bash
  flutter build apk --release
  ```
  완료 후 산출물 경로 안내: `build/app/outputs/flutter-apk/app-release.apk`
  → QA 실기기 설치는 `install-release` 스킬(무선 연결 + 설치)로 이어서 진행 가능

- **Android 둘 다 (AAB + APK)**: 위 두 명령을 모두 실행한다(`flutter build appbundle --release` + `flutter build apk --release`). 두 산출물 경로를 함께 안내한다.

- **iOS**
  ```bash
  flutter build ipa
  ```
  빌드 성공 시 Xcode Organizer를 연다:
  ```bash
  open build/ios/archive/Runner.xcarchive
  ```
  사용자 안내:
  - Xcode Organizer에서 **Distribute App** → **App Store Connect** → **Upload**
  - 업로드 완료 후 5~10분 내 TestFlight에서 빌드 처리 완료
  - "수출 규정 관련 문서 누락" 경고 시 → "위에 언급된 알고리즘에 모두 해당하지 않음" 선택
  - "Upload Symbols Failed" 경고는 무시해도 된다(앱 동작에 영향 없음)

### 6. 마무리 안내
빌드/업로드 완료 후 반드시 안내한다:
> **스토어에 신버전이 실제 출시(심사 통과/배포 완료)된 것을 확인한 뒤** `server-version-update`("서버 버전 업데이트") 스킬을 실행해 서버 DB의 버전 체크를 활성화하세요. 출시 전에 서버를 먼저 바꾸면 사용자에게 받을 수 없는 버전으로 업데이트 안내가 떠 soft-brick이 발생합니다.

## 주의사항
- 빌드번호(`+` 뒤 정수)는 매 업로드마다 이전보다 커야 한다 — 자동/수동 어느 쪽이든 +1 한다.
- **둘 다**를 고르면 한 번 실행으로 Android·iOS를 모두 빌드한다. 버전은 3단계에서 **양쪽 동일**(pubspec 1회 수정) 또는 **플랫폼별 개별**(빌드 플래그 주입, pubspec 미수정) 중 선택한다 — 스토어 버전이 이미 어긋난 경우 개별을 쓴다.
- 이 스킬은 서버 API를 호출하지 않는다. `force_update`(강제 여부)는 `server-version-update` 스킬에서 묻는다.
