# Firebase 서비스 계정 설정 가이드

서버에서 FCM 푸시 알림을 발송하려면 Firebase 서비스 계정 인증이 필요하다.
`FIREBASE_CREDENTIALS` 환경변수가 없으면 heartbeat_trigger, schedule_updated, 경고 알림 등
모든 FCM 발송이 비활성화된다.

```python
# services/push_service.py
creds_json = os.getenv("FIREBASE_CREDENTIALS", "")
if not creds_json:
    logger.warning("FIREBASE_CREDENTIALS 환경변수가 설정되지 않았습니다. Push 기능이 비활성화됩니다.")
    return
```


## Step 1 — 서비스 계정 키 발급

1. [Firebase Console](https://console.firebase.google.com) → 프로젝트 선택
2. **⚙️ 프로젝트 설정** → **서비스 계정** 탭
3. **새 비공개 키 생성** 버튼 클릭
4. JSON 파일 다운로드

다운로드된 파일 형태:
```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "...",
  "private_key": "-----BEGIN RSA PRIVATE KEY-----\n...",
  "client_email": "firebase-adminsdk-xxx@your-project.iam.gserviceaccount.com",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token"
}
```

> ⚠️ 이 파일은 비공개 키를 포함하므로 Git에 커밋하지 않는다. `.gitignore`에 추가할 것.


## Step 2 — Railway 환경변수 설정 (운영)

Railway 대시보드 → 프로젝트 → **Variables** 탭 → **New Variable**

| Key | Value |
|-----|-------|
| `FIREBASE_CREDENTIALS` | 다운로드한 JSON 파일의 전체 내용을 그대로 붙여넣기 |

Railway는 멀티라인 값을 지원하므로 JSON을 한 줄로 변환할 필요 없다.


## Step 3 — 로컬 개발 환경 설정

프로젝트 루트의 `.env` 파일에 추가:

```
FIREBASE_CREDENTIALS={"type":"service_account","project_id":"your-project-id","private_key_id":"...","private_key":"-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----\n","client_email":"..."}
```

> 로컬에서는 JSON을 한 줄로 압축하거나, 아래 방법을 사용한다:

```bash
# JSON 파일을 한 줄로 압축하여 출력
python3 -c "import json,sys; print(json.dumps(json.load(open('서비스계정.json'))))"
```

출력된 값을 `.env`의 `FIREBASE_CREDENTIALS=` 뒤에 붙여넣는다.


## 설정 확인

서버 시작 로그에서 확인:

```
# 설정 실패 (환경변수 없음)
FIREBASE_CREDENTIALS 환경변수가 설정되지 않았습니다. Push 기능이 비활성화됩니다.

# 설정 성공
Firebase 초기화 완료
```


## 주의사항

- 서비스 계정 JSON 파일을 **Git에 커밋하지 않는다**
- `.gitignore`에 `*.json` 또는 `serviceAccount*.json` 패턴 추가 권장
- Railway 환경변수는 배포 후 자동 적용된다 (재시작 필요)
- 키가 유출된 경우 Firebase Console에서 즉시 해당 키를 삭제하고 재발급한다
