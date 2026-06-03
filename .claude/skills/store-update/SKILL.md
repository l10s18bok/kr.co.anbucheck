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
`AskUserQuestion`으로 묻는다: **Android** / **iOS**.

### 2. (Android만) 산출물 질문
Android 선택 시 `AskUserQuestion`으로 묻는다:
- **AAB (appbundle)** — Play Console 정식 배포용 (`build/app/outputs/bundle/release/app-release.aab`)
- **APK** — 직접 배포/QA 설치용 (`build/app/outputs/flutter-apk/app-release.apk`). 빌드 후 실기기 설치는 `install-release` 스킬로.

iOS는 산출물 질문 없이 ipa.

### 3. 버전 질문
`pubspec.yaml`의 현재 `version`(예: `1.1.5+23`)을 읽어 보여주고 `AskUserQuestion`으로 묻는다:
- **다음 버전 자동** — 버전명 patch +1, 빌드번호 +1 (예: `1.1.5+23` → `1.1.6+24`)
- **수동 입력** — 버전명을 직접 입력받는다(예: `1.2.0`). 빌드번호는 **항상 +1** 한다(스토어는 동일 버전이라도 빌드번호가 이전보다 커야 함).

### 4. 버전 반영
- `pubspec.yaml`의 `version`을 새 값으로 수정한다.
- `lib/app/modules/splash/controllers/splash_controller.dart`의 `_appVersionFallback` 상수도 새 **버전명**(빌드번호 제외)으로 맞춘다 — 정상 경로는 `PackageInfo`가 실제 버전을 읽지만, 조회 실패 시 fallback이 stale하면 버전 비교가 틀어지므로 동기화한다.

### 5. 빌드
선택에 따라 하나만 실행한다.

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
- 한 번 실행에 한 플랫폼만 처리한다. Android와 iOS를 모두 올리려면 두 번 실행하되 **버전명은 동일하게** 맞춘다.
- 이 스킬은 서버 API를 호출하지 않는다. `force_update`(강제 여부)는 `server-version-update` 스킬에서 묻는다.
