---
name: server-version-update
description: 서버 버전 업데이트(서버 버전 업데이트/서버 버전 올려/앱버전 서버 반영/서버 db 버전/버전 체크 활성화) — **스토어에 신버전이 실제 출시된 뒤** 실행한다. app_versions DB(latest_version/min_version/store_url)를 admin API로 갱신해 앱의 버전 체크 다이얼로그를 활성화한다. 플랫폼·버전·강제 여부·store_url을 묻고, 서버에 저장하기 직전 최종 확인한다.
---

# 서버 버전 업데이트 Skill (서버 DB 전용)

## 설명
서버 `app_versions` 테이블을 admin API로 갱신한다. 이걸 갱신해야 앱의 버전 체크가 신버전을 인식해 강제/일반 업데이트 다이얼로그를 띄운다.

> ⚠️ **반드시 스토어에 신버전이 실제 출시(심사 통과/배포 완료)된 것을 확인한 뒤 실행한다.** 출시 전에 DB를 바꾸면 사용자에게 아직 받을 수 없는 버전으로 업데이트 안내가 뜨고, 강제면 soft-brick이 된다. 빌드/업로드는 `store-update` 스킬이 담당한다.

## 전제: admin 인증키 파일

admin API는 `X-Admin-Key` 헤더(서버 `ADMIN_SECRET_KEY`)를 요구한다. 키는 **git 미추적 로컬 파일**에서 읽는다:

```
.claude/skills/server-version-update/admin_key
```

- 이 파일은 `.gitignore`에 등록되어 커밋되지 않는다. 한 줄에 키 값만 넣는다(개행/공백 주의).
- 파일이 없으면 사용자에게 안내하고 중단한다:
  > `.claude/skills/server-version-update/admin_key` 파일에 서버 `ADMIN_SECRET_KEY`(Railway 환경변수 값)를 한 줄로 저장해 주세요.

## 서버 주소
`lib/app/core/config/api_config.dart`의 `baseUrl`을 따른다 (현재: `https://web-production-43beb.up.railway.app`). 코드에서 직접 읽어 사용한다.

## 절차

### 1. 키·주소 준비
```bash
KEY="$(tr -d '\r\n' < .claude/skills/server-version-update/admin_key)"
BASE="$(grep -m1 baseUrl lib/app/core/config/api_config.dart | sed -E "s/.*'(https?:[^']+)'.*/\1/")"
[ -z "$KEY" ] && { echo "admin_key 파일이 비어있음 — 중단"; exit 1; }
echo "BASE=$BASE"
```

### 2. 플랫폼 질문
`AskUserQuestion`: **Android** / **iOS**.

### 3. 현재 DB 상태 조회 (공개 엔드포인트 — 키 불필요)
```bash
curl -s "$BASE/api/v1/app/version-check?platform=<platform>&current_version=0.0.0"
```
응답의 `latest_version` / `min_version` / `store_url`을 파악해 사용자에게 현재 상태를 보여준다.

### 4. 버전 질문
`pubspec.yaml`의 현재 버전명(빌드번호 `+N` 제외, 예: `1.1.5`)을 기본값으로 제시하고 `AskUserQuestion`:
- **pubspec 버전 사용**(기본) — 스토어에 올린 그 버전
- **수동 입력** — 버전명을 직접 입력

> 여기서 넣는 값이 스토어에 실제 출시된 버전과 일치해야 한다. 불일치하면 "받을 수 없는 버전 안내" 문제가 재발한다.

### 5. 강제 여부 질문
`AskUserQuestion`: **강제 업데이트** / **일반(선택적) 업데이트**.
- **강제** → `min_version = latest_version = 새 버전` (이 미만 전부 차단)
- **일반** → `latest_version = 새 버전`, `min_version = 기존 값 유지`(3번에서 읽은 값)

### 6. store_url 확인/설정
3번에서 읽은 현재 `store_url`을 보여준다.
- 값이 placeholder이거나(예: iOS `id000000000`, 또는 Android 패키지명이 `kr.co.anbucheck.live`가 아님) 비어 있으면 **반드시 실제 URL을 입력받는다.**
- **강제 업데이트인데 store_url이 placeholder면 절대 진행하지 말 것** — 닫을 수 없는 다이얼로그 + 잘못된 URL = soft-brick. 실제 URL을 받기 전까지 중단한다.
- 정상값이면 그대로 유지(PUT 본문에서 생략하면 서버가 기존값 유지)한다.

### 7. 최종 확인 (저장 직전)
변경 요약을 표로 보여주고 `AskUserQuestion`으로 **"서버에 저장할까요?"**를 반드시 묻는다. 예:

| 항목 | 현재 | 변경 후 |
|------|------|---------|
| platform | android | android |
| latest_version | 1.0.0 | 1.1.5 |
| min_version | 1.0.0 | 1.1.5 (강제) |
| store_url | ...id=...live | (유지) |

사용자가 **저장**을 고를 때만 8번으로 진행한다. 취소면 중단(서버 미변경).

### 8. 저장 (admin API PUT)
```bash
curl -s -X PUT "$BASE/api/v1/admin/app-version" \
  -H "X-Admin-Key: $KEY" -H "Content-Type: application/json" \
  -d '{"platform":"<platform>","latest_version":"<new>","min_version":"<min>","store_url":"<url 또는 생략>"}'
```
- `store_url`을 유지할 경우 본문에서 키를 빼면 서버가 기존값을 보존한다.
- 서버 검증: `latest_version >= min_version`이어야 200. 아니면 400.
- 403이면 admin_key 불일치 — 키 파일을 확인하라고 안내.

### 9. 검증·보고
```bash
curl -s "$BASE/api/v1/app/version-check?platform=<platform>&current_version=<new>"
```
- 같은(=새) 버전으로 조회 시 `force_update:false`가 나와야 정상(자기 버전엔 강제 안 걸림).
- 한 단계 낮은 버전으로 조회해 의도대로 `force_update`가 나오는지 확인 후, 최종 DB 상태(latest/min/store_url)를 1~2줄로 보고한다.

## 주의사항
- **출시 확인 후 실행** — 이 스킬의 존재 이유. 빌드 직후 바로 실행하지 말 것.
- admin_key는 절대 커밋/출력하지 않는다(로그에도 노출 금지).
- Android/iOS는 행이 분리돼 있으므로 플랫폼별로 각각 실행한다.
- 한 번 더: **강제 + placeholder store_url = 금지.**
