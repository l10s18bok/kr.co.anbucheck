# Anbu (안부) - 생존확인 앱

## 프로젝트 개요
독거노인·1인 가구의 생존 여부를 자동으로 확인하는 크로스 플랫폼(Android/iOS) 앱.
매일 고정 시각(기본 09:30)에 센서 스냅샷을 수집하여 heartbeat를 서버에 전송하고,
24시간 이상 미수신 시 보호자에게 알림을 발송한다.

## 앱 구조
하나의 앱에서 **대상자 모드**와 **보호자 모드**를 선택하는 듀얼 모드 구조:
- **대상자 모드**: heartbeat 전송, 생존확인 서비스 동작 (Teal 테마)
- **보호자 모드**: Push 알림 수신, 대상자 상태 확인 (Indigo 테마)

## 기술 스택
- Flutter 3.41.5 / Dart 3.11.3
- 상태관리: GetX
- 아키텍처: Clean Architecture (Presentation → Domain ← Data)
- HTTP 클라이언트: GetConnect / Dio (ApiClientFactory 패턴)
- 코드 생성: Freezed + json_serializable
- 반응형: flutter_screenutil (375x812 기준)

## 패키지 정보
- Android 패키지명: `kr.co.anbucheck.live`
- iOS Bundle ID: `kr.co.anbucheck.live`
- pubspec name: `anbucheck`

## 디자인 시스템 (The Gentle Guardian)
- **No-Line Rule**: 1px 실선 경계 금지, 배경색 전환으로 섹션 구분
- **Tonal Layering**: 그림자 대신 배경색 단계로 깊이 표현
- **Glassmorphism**: 플로팅 헤더/네비게이션에 80% 투명도 + backdrop-blur
- **최소 버튼 높이**: 64px
- **최소 터치 영역**: 48x48dp
- **순수 검정(#000000) 사용 금지** → `#1a1c1c` 사용
- **수평 마진**: spacing.5 (1.7rem)
- **수직 그룹 간격**: spacing.8 (2.75rem)

## 참조 문서

| 문서 | 경로 | 참조 시점 |
|------|------|-----------|
| 프론트엔드 PRD | `.ref/PRD-FrontEnd.md` | UI 구현, 화면 설계, 플로우, 로컬 저장소 정책 확인 시 |
| 백엔드 PRD | `.ref/PRD-BackEnd.md` | API 명세, 요청/응답 구조, DB 스키마 확인 시 |
| Heartbeat 플로우차트 | `.ref/heartbeat_flowchart.md` | heartbeat 수집·전송·경고 플로우 확인 시 |


## 주의 사항

### **중요 지침**
1. 모든 응답, 주석, 문서, 커밋 메시지를 **한글**로 작성
2. 질문에 대답할 때 확실하지 않으면 추론으로 대답하지 말 것
3. 모르면 **코드를 찾아보고** 답변해야 함
4. 페이지 화면을 만들 때는 반드시 `.claude/skills/getx-module/SKILL.md`를 활용하여 클린 아키텍처 구조로 생성할 것
5. Controller는 UseCase만 의존 — DataSource/Repository를 직접 참조하지 않음
6. Domain 레이어는 순수 Dart만 사용 — Flutter/GetX import 금지
7. Freezed 모델은 반드시 `abstract class`로 선언
8. 모듈 생성 후 반드시 `flutter analyze` 실행하여 에러 확인

## 빌드 명령어
```bash
# 의존성 설치
flutter pub get

# Freezed 코드 생성
dart run build_runner build --delete-conflicting-outputs

# 분석
flutter analyze

# 실행
flutter run
```
