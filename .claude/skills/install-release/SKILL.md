---
name: install-release
description: Android 실기기 release 설치(기기 설치/설치해줘/실기기 설치/release 설치/apk 설치/다른 기기 설치). release APK를 빌드한 뒤 연결된 실기기에 설치 (flutter run 금지, 항상 build → install 순서). "다른 기기 설치" 명령은 재빌드 없이 기존 APK만 새로 연결된 기기에 설치
---

# 실기기 release 설치 Skill

## 설명
Android 실기기에 release 빌드를 설치한다. **반드시 먼저 APK를 빌드한 뒤 install 명령으로 기기에 넣는다.** `flutter run --release`는 사용하지 않는다 (빌드 산출물이 남지 않고, 여러 기기 설치 시 재빌드가 발생한다).

## 명령 구분

- **"설치해줘 / 기기 설치 / 실기기 설치 / release 설치 / apk 설치"**: 아래 절차 1~3 전체 실행 (build → install)
- **"다른 기기 설치"**: 재빌드 건너뛰고 `flutter devices`로 연결 기기만 재확인한 뒤 절차 3만 실행. 직전에 이미 release 빌드한 `app-release.apk`를 그대로 새로 연결된 기기에 설치하는 용도. 소스 변경 후에는 이 명령을 쓰지 말 것 — 변경이 반영되지 않는다.

## 절차

1. 연결된 기기 확인
   ```bash
   flutter devices
   ```
   - Android 실기기(physical)만 대상. simulator/emulator/desktop/web 제외.
   - 연결된 기기가 없으면 사용자에게 알리고 종료.

2. release APK 빌드 (1회만)
   ```bash
   flutter build apk --release
   ```
   - 산출물: `build/app/outputs/flutter-apk/app-release.apk`
   - 빌드 실패 시 중단하고 에러 원인 보고.

3. 연결된 각 Android 실기기에 설치
   ```bash
   flutter install --release -d <device_id>
   ```
   - 기기가 여러 대면 각각 `-d <device_id>`로 순차 설치한다.
   - `flutter install`은 2단계에서 만든 APK를 재사용하므로 재빌드하지 않는다.

## 금지
- `flutter run --release -d <device>` 사용 금지 (빌드+실행+로그 스트리밍까지 묶여 있어 설치 용도에 부적합).
- `adb install` 직접 호출 금지 — `flutter install`이 Flutter 앱 설치 메타데이터를 올바르게 처리한다.
- debug 빌드 설치 금지 — 이 skill은 release 전용.

## 출력
설치 완료한 기기 ID와 모델명을 1줄로 보고한다. 예:
> `326d3404 (23021RAA2Y)에 release 설치 완료`
