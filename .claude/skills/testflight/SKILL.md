---
name: testflight
description: iOS TestFlight(테스트플라이트/테스트 플라이트) 빌드 및 업로드
---

# TestFlight 업로드 Skill

## 설명
iOS 앱을 빌드하고 App Store Connect(TestFlight)에 업로드한다.

## 절차

1. `pubspec.yaml`의 현재 `version` 필드를 읽는다 (예: `1.0.2+2`)
2. 버전을 자동 증가시킨다
   - patch 버전(마지막 숫자)을 +1 한다 (예: `1.0.2` → `1.0.3`)
   - 빌드번호(`+` 뒤 숫자)도 +1 한다 (예: `+2` → `+3`)
   - `pubspec.yaml`에 반영한다 (예: `1.0.3+3`)
3. iOS 릴리즈 빌드를 실행한다
   ```bash
   flutter build ipa
   ```
4. 빌드 성공 시 Xcode Organizer를 열어 업로드한다
   ```bash
   open build/ios/archive/Runner.xcarchive
   ```
5. 사용자에게 안내한다:
   - Xcode Organizer에서 **Distribute App** → **App Store Connect** → **Upload**
   - 업로드 완료 후 5~10분 내 TestFlight에서 빌드 처리 완료
   - "수출 규정 관련 문서 누락" 경고 시 → "위에 언급된 알고리즘에 모두 해당하지 않음" 선택

## 주의사항
- 빌드번호는 App Store Connect에서 같은 버전의 빌드를 구분하는 정수이며, 매 업로드마다 이전보다 커야 한다
- "Upload Symbols Failed" 경고는 무시해도 된다 (앱 동작에 영향 없음)
- 사용자에게 버전을 묻지 않고 자동 증가 처리한다
