---
name: store-update
description: 스토어 업데이트/배포(스토어 업데이트/스토어 배포/앱 배포/release 배포/store update)와 서버 버전 반영(서버 버전 업데이트/서버 버전 올려/앱버전 서버 반영/서버 db 버전/버전 체크 활성화)을 한 스킬에서 처리한다. 빌드 모드는 플랫폼(android/ios)을 묻고 버전을 올린 뒤 스토어용 빌드를 만들고(android는 APK/AAB 선택, ios는 ipa 빌드 후 Xcode Organizer), 이어서 출시 노트를 작성할지 묻는다(Android=Play Console 태그, iOS=App Store Connect 언어별, 20개 언어). 서버 반영 모드는 app_versions DB(latest_version/min_version/store_url)를 admin API로 갱신해 버전 체크 다이얼로그를 활성화한다 — **스토어에 신버전이 실제 출시된 것을 확인한 뒤에만** 실행하며, 빌드 직후 자동 실행은 금지한다.
---

# 스토어 업데이트 Skill (빌드 → 출시 노트 → 서버 버전 반영)

## 설명
앱 릴리스의 세 가지 작업을 한 스킬에서 처리한다. **단, 서버 반영은 시점이 다르므로 별도 모드로 분리돼 있다.**

| 모드 | 언제 | 하는 일 |
|------|------|---------|
| **A. 빌드 모드** (기본) | 스토어에 올릴 빌드를 만들 때 | 1~7단계 — 버전 상향 → 빌드 → 출시 노트 |
| **B. 서버 반영 모드** | **스토어에 신버전이 실제 출시(심사 통과·배포 완료)된 뒤** | 8단계 — `app_versions` DB 갱신 |

**모드 판별**: 사용자 발화가 "서버 버전 업데이트 / 서버 버전 올려 / 앱버전 서버 반영 / 버전 체크 활성화"처럼 **서버**를 가리키면 1~7단계를 건너뛰고 **곧바로 8단계**로 간다. 그 외("스토어 업데이트/배포/빌드")는 A 모드로 1단계부터 시작한다.

> ⚠️ **빌드 직후에 서버 DB를 자동으로 바꾸지 않는다.** 서버를 먼저 바꾸면 스토어 심사가 끝나기 전에 사용자에게 "아직 받을 수 없는 버전"으로 업데이트 안내가 뜨고, 강제 업데이트면 soft-brick이 된다. 심사 시점은 예측 불가하므로 A 모드는 7단계에서 **안내만 하고 끝난다** — 8단계는 사용자가 출시를 확인한 뒤 다시 불러야 실행된다. 두 모드를 한 번의 실행으로 이어붙이지 말 것.

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

### 6. 출시 노트 작성 질문
빌드가 끝나면 `AskUserQuestion`으로 묻는다: **"출시 노트를 작성할까요?"**
- **작성** — 아래 절차로 만들어 출력한다. **5단계에서 빌드한 플랫폼에 맞는 포맷만** 낸다(둘 다 빌드했으면 6-A·6-B 둘 다).
- **건너뛰기** — 바로 7단계로.

#### 6-0. 공통 — 요약 만들기

1. **기준 커밋을 찾는다.** `git log --oneline -40 -- pubspec.yaml`로 릴리스 커밋 이력을 보고, **그 플랫폼에서 마지막으로 실제 스토어(프로덕션)에 출시된 버전**의 커밋을 기준으로 잡는다. 커밋 메시지에 "내부 테스트"·"TestFlight"라고 적힌 것은 사용자에게 도달하지 않았으므로 기준이 아니다. ⚠️ **Android와 iOS는 기준 커밋이 다를 수 있다** — 심사 타이밍 차이로 스토어 버전이 어긋나기 때문. 판단이 애매하면 사용자에게 "직전 스토어 출시 버전이 무엇인가"를 플랫폼별로 묻는다.
2. `git log --oneline <기준커밋>..HEAD`로 그 사이 커밋을 전부 읽는다.
3. **그 플랫폼 사용자에게 보이는 변화만** 5줄로 요약한다.
   - 제외: 문서(`문서:`)·실측(`실측:`/`실험:`)·계측·릴리스 버전업 커밋.
   - ⚠️ **플랫폼 전용 변경을 반대편 노트에 넣지 말 것.** 이 앱은 **Android만 대상자·보호자 모두 지원하고 iOS는 보호자 모드 전용**이라, Android 전용 계층(예약 실행·백그라운드 전송 관련) 개선은 iOS 노트에 넣으면 거짓이 된다. 반대로 iOS 전용 알림 처리 개선은 Android 노트에 넣지 않는다. 커밋 제목·변경 파일 경로(`android/`, `ios/`)로 가른다.
   - 요약은 **"무엇이 좋아졌는가"**를 사용자 언어로 쓴다.
4. 아래 6-A / 6-B의 해당 포맷으로 코드블록에 출력한다(사용자가 통째로 복사해 붙여넣는다).
5. 코드블록 아래에 **요약 근거**(어떤 커밋군을 어느 줄로 묶었는지) 한 문단을 덧붙인다. 둘 다 만들었으면 플랫폼별로 따로 적는다.

⚠️ **문구 규칙 — 일반 사용자가 읽는 글이다(양 플랫폼 공통):**
- **기술 용어 금지**: Doze, WorkManager, worker, heartbeat, FCM, APNs, NSE, 피기백, 워커, 폴링, 스케줄러, 락, isolate 등을 그대로 쓰지 않는다. "안부 신호", "정해진 시각", "폰을 오래 쓰지 않아도" 같은 일상어로 바꾼다.
- 내부 결함 이름·커밋 제목을 그대로 옮기지 않는다. **증상이 아니라 개선된 결과**를 쓴다.
- 앱 이름은 한국어만 "안부", 나머지 19개 언어는 "Anbu" — 다만 출시 노트에서는 앱 이름을 넣지 않는 편이 자연스럽다.

#### 6-A. Android — Google Play Console 포맷

언어 태그로 감싼 한 덩어리로 출력한다(Play Console 출시 노트 입력란에 통째로 붙여넣는 형식). **각 언어 500자 이내.**

```
<en-US>
</en-US>
<ar>
</ar>
<de-DE>
</de-DE>
<es-ES>
</es-ES>
<fr-FR>
</fr-FR>
<hi-IN>
</hi-IN>
<id>
</id>
<it-IT>
</it-IT>
<ja-JP>
</ja-JP>
<ko-KR>
</ko-KR>
<nl-NL>
</nl-NL>
<pl-PL>
</pl-PL>
<pt-BR>
</pt-BR>
<ru-RU>
</ru-RU>
<sv-SE>
</sv-SE>
<th>
</th>
<tr-TR>
</tr-TR>
<vi>
</vi>
<zh-CN>
</zh-CN>
<zh-TW>
</zh-TW>
```

#### 6-B. iOS — App Store Connect 포맷

App Store Connect는 **언어별 "이번 버전의 새로운 기능" 칸에 하나씩 직접 입력**한다(태그 일괄 붙여넣기 불가). 그래서 **언어 이름을 제목으로 단 개별 블록**으로 출력해 한 칸씩 복사하기 쉽게 만든다. **각 언어 4000자 이내.**

⚠️ **언어 이름은 한국어로 적는다** — `Dutch`가 아니라 `네덜란드어`. 사용자가 한국어로 읽고 찾으므로 영문 언어명을 그대로 두지 않는다(뒤의 로케일 코드가 입력 칸을 식별해 주므로 영문명은 없어도 된다). ⚠️ 단 **Android 6-A의 `<en-US>` 같은 태그는 입력 형식 그 자체**이므로 절대 한국어로 바꾸지 않는다 — 바꾸면 Play Console이 파싱하지 못한다.

⚠️ **로케일 코드가 Play와 다르다** — 아래 App Store Connect 표기를 쓴다:

```
■ 영어(미국) / en-US

■ 아랍어 / ar-SA

■ 독일어 / de-DE

■ 스페인어(스페인) / es-ES

■ 프랑스어 / fr-FR

■ 힌디어 / hi

■ 인도네시아어 / id

■ 이탈리아어 / it

■ 일본어 / ja

■ 한국어 / ko

■ 네덜란드어 / nl-NL

■ 폴란드어 / pl

■ 포르투갈어(브라질) / pt-BR

■ 러시아어 / ru

■ 스웨덴어 / sv

■ 태국어 / th

■ 터키어 / tr

■ 베트남어 / vi

■ 중국어 간체 / zh-Hans

■ 중국어 번체 / zh-Hant
```

Play와 다른 코드: `hi-IN→hi`, `it-IT→it`, `ja-JP→ja`, `ko-KR→ko`, `pl-PL→pl`, `ru-RU→ru`, `sv-SE→sv`, `tr-TR→tr`, `ar→ar-SA`, `zh-CN→zh-Hans`, `zh-TW→zh-Hant`.

⚠️ **App Store Connect에 그 언어의 현지화가 추가돼 있지 않으면 입력 칸 자체가 없다.** 없는 언어는 건너뛰라고 안내하고, 목록을 억지로 채우게 하지 않는다.

### 7. 마무리 안내 (A 모드 종료 지점)
빌드/출시 노트가 끝나면 반드시 안내하고 **여기서 실행을 끝낸다.**
> 빌드가 준비됐습니다. **스토어에 신버전이 실제 출시(심사 통과/배포 완료)된 것을 확인한 뒤** "서버 버전 업데이트"라고 말씀해 주세요 — 그때 8단계(서버 `app_versions` 갱신)를 실행해 버전 체크 다이얼로그를 켭니다. 출시 전에 서버를 먼저 바꾸면 사용자에게 받을 수 없는 버전으로 업데이트 안내가 떠 soft-brick이 발생합니다.

⚠️ **여기서 "이어서 서버도 반영할까요?"라고 묻지 않는다.** 물으면 사용자가 습관적으로 "예"를 눌러 출시 전에 DB가 바뀐다. 심사 통과 확인은 며칠 뒤의 일이므로, 사용자가 **다시 스킬을 호출하는 행위 자체**가 게이트다.

---

### 8. 서버 버전 반영 (B 모드 — 별도 호출로만 진입)

서버 `app_versions` 테이블을 admin API로 갱신한다. 이걸 갱신해야 앱의 버전 체크가 신버전을 인식해 강제/일반 업데이트 다이얼로그를 띄운다.

#### 8-0. 출시 확인 게이트 (건너뛰기 금지)
`AskUserQuestion`으로 먼저 묻는다: **"이 버전이 스토어에 이미 출시(심사 통과·배포 완료)되어 사용자가 지금 내려받을 수 있나요?"**
- **예, 출시 완료** → 8-1로 진행
- **아직 심사 중/미출시** → **중단한다.** 출시 후 다시 부르라고 안내하고 서버를 건드리지 않는다.

#### 8-1. 전제 — admin 인증키 파일
admin API는 `X-Admin-Key` 헤더(서버 `ADMIN_SECRET_KEY`)를 요구한다. 키는 **git 미추적 로컬 파일**에서 읽는다:

```
.claude/skills/store-update/admin_key
```

- 이 파일은 `.gitignore`에 등록되어 커밋되지 않는다. 한 줄에 키 값만 넣는다(개행/공백 주의).
- 파일이 없으면 사용자에게 안내하고 중단한다:
  > `.claude/skills/store-update/admin_key` 파일에 서버 `ADMIN_SECRET_KEY`(Railway 환경변수 값)를 한 줄로 저장해 주세요.

#### 8-2. 키·주소 준비
서버 주소는 `lib/app/core/config/api_config.dart`의 `baseUrl`을 코드에서 직접 읽는다(하드코딩 금지).
```bash
KEY="$(tr -d '\r\n' < .claude/skills/store-update/admin_key)"
BASE="$(grep -m1 baseUrl lib/app/core/config/api_config.dart | sed -E "s/.*'(https?:[^']+)'.*/\1/")"
[ -z "$KEY" ] && { echo "admin_key 파일이 비어있음 — 중단"; exit 1; }
echo "BASE=$BASE"
```

#### 8-3. 플랫폼 질문
`AskUserQuestion`: **Android** / **iOS**. (행이 분리돼 있으므로 두 플랫폼 모두 반영하려면 각각 실행한다.)

#### 8-4. 현재 DB 상태 조회 (공개 엔드포인트 — 키 불필요)
```bash
curl -s "$BASE/api/v1/app/version-check?platform=<platform>&current_version=0.0.0"
```
응답의 `latest_version` / `min_version` / `store_url`을 파악해 사용자에게 현재 상태를 보여준다.

#### 8-5. 버전 질문
`pubspec.yaml`의 현재 버전명(빌드번호 `+N` 제외, 예: `1.3.0`)을 기본값으로 제시하고 `AskUserQuestion`:
- **pubspec 버전 사용**(기본) — 스토어에 올린 그 버전
- **수동 입력** — 버전명을 직접 입력

> 여기서 넣는 값이 **스토어에 실제 출시된 버전**과 일치해야 한다. 불일치하면 "받을 수 없는 버전 안내" 문제가 재발한다. ⚠️ Android·iOS 스토어 버전이 어긋나 있으면 pubspec 값이 한쪽에만 맞을 수 있으므로, 플랫폼별로 실제 출시 버전을 확인한다.

#### 8-6. 강제 여부 질문
`AskUserQuestion`: **강제 업데이트** / **일반(선택적) 업데이트**.
- **강제** → `min_version = latest_version = 새 버전` (이 미만 전부 차단)
- **일반** → `latest_version = 새 버전`, `min_version = 기존 값 유지`(8-4에서 읽은 값)

#### 8-7. store_url 확인/설정
8-4에서 읽은 현재 `store_url`을 보여준다.
- 값이 placeholder이거나(예: iOS `id000000000`, 또는 Android 패키지명이 `kr.co.anbucheck.live`가 아님) 비어 있으면 **반드시 실제 URL을 입력받는다.**
- **강제 업데이트인데 store_url이 placeholder면 절대 진행하지 말 것** — 닫을 수 없는 다이얼로그 + 잘못된 URL = soft-brick. 실제 URL을 받기 전까지 중단한다.
- 정상값이면 그대로 유지(PUT 본문에서 생략하면 서버가 기존값 유지)한다.

#### 8-8. 최종 확인 (저장 직전)
변경 요약을 표로 보여주고 `AskUserQuestion`으로 **"서버에 저장할까요?"**를 반드시 묻는다. 예:

| 항목 | 현재 | 변경 후 |
|------|------|---------|
| platform | android | android |
| latest_version | 1.2.5 | 1.3.0 |
| min_version | 1.0.0 | 1.3.0 (강제) |
| store_url | ...id=...live | (유지) |

사용자가 **저장**을 고를 때만 8-9로 진행한다. 취소면 중단(서버 미변경).

#### 8-9. 저장 (admin API PUT)
```bash
curl -s -X PUT "$BASE/api/v1/admin/app-version" \
  -H "X-Admin-Key: $KEY" -H "Content-Type: application/json" \
  -d '{"platform":"<platform>","latest_version":"<new>","min_version":"<min>","store_url":"<url 또는 생략>"}'
```
- `store_url`을 유지할 경우 본문에서 키를 빼면 서버가 기존값을 보존한다.
- 서버 검증: `latest_version >= min_version`이어야 200. 아니면 400.
- 403이면 admin_key 불일치 — 키 파일을 확인하라고 안내.

#### 8-10. 검증·보고
```bash
curl -s "$BASE/api/v1/app/version-check?platform=<platform>&current_version=<new>"
```
- 같은(=새) 버전으로 조회 시 `force_update:false`가 나와야 정상(자기 버전엔 강제 안 걸림).
- 한 단계 낮은 버전으로 조회해 의도대로 `force_update`가 나오는지 확인 후, 최종 DB 상태(latest/min/store_url)를 1~2줄로 보고한다.

## 주의사항
- 빌드번호(`+` 뒤 정수)는 매 업로드마다 이전보다 커야 한다 — 자동/수동 어느 쪽이든 +1 한다.
- **둘 다**를 고르면 한 번 실행으로 Android·iOS를 모두 빌드한다. 버전은 3단계에서 **양쪽 동일**(pubspec 1회 수정) 또는 **플랫폼별 개별**(빌드 플래그 주입, pubspec 미수정) 중 선택한다 — 스토어 버전이 이미 어긋난 경우 개별을 쓴다.
- iOS 출시 노트의 **언어 이름은 한국어**로 적는다(`네덜란드어 / nl-NL`). Android 6-A의 `<en-US>` 태그는 입력 형식이므로 그대로 둔다.
- 출시 노트는 **빌드한 플랫폼의 포맷만** 낸다 — Play Console과 App Store Connect는 로케일 코드도 입력 방식도 다르다. Android 전용 개선을 iOS 노트에 넣지 말 것(iOS는 보호자 모드 전용이라 거짓이 된다).
- **A 모드(1~7단계)는 서버 API를 호출하지 않는다.** 서버 접근은 8단계에서만, 그것도 별도 호출로 진입했을 때만 일어난다.
- **서버 반영은 출시 확인 후** — 8-0 게이트가 이 분리의 존재 이유다. 빌드 직후 이어서 실행하지 말 것.
- admin_key는 절대 커밋/출력하지 않는다(로그에도 노출 금지).
- Android/iOS는 `app_versions` 행이 분리돼 있으므로 플랫폼별로 8단계를 각각 실행한다.
- 한 번 더: **강제 + placeholder store_url = 금지.**
