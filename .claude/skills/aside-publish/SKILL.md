---
name: aside-publish
description: 안부 쇼츠를 Claude Code가 Aside(브라우저 에이전트 CLI)에 지시해 유튜브 Studio·네이버 클립에 업로드·예약·공개·점검한다. "유튜브에 올려 줘", "쇼츠 공개해 줘", "클립에 올려 줘", "어사이드로 올려", "업로드 진행해", "공개 전환해 줘", "올라간 거 확인해 줘"처럼 쇼츠 게시 요청이 오면 반드시 이 스킬을 쓴다. Aside 앱에서 직접 하지 않고 이 세션이 모든 지시를 한다. 영상 제작은 `shorts` 스킬, Railway 로그·DB 조회는 서버 저장소 `.ref/ASIDE-OPS.md`. 스레드·인스타·블로그는 아직 검증 전이라 쓰기 전에 사용자에게 묻는다.
---

# Aside로 쇼츠 업로드 지시하기

**역할 분담 (2026-10-11 변경):** 업로드에 쓰이는 **문구(제목·설명·해시태그·태그·클립 설명)는 전부 Claude Code가 `upload.json`에 최종본으로 적고 사용자 승인을 받는다.** Aside는 그 문구를 **한 글자도 고치지 않고 그대로 입력**하는 일(업로드·예약·`publish.json` 기록)만 한다. 문구를 쓰는 규칙은 같은 폴더의 **`copy-rules.md`**(권위, 여기뿐)이고, 문구를 쓰거나 고칠 때는 먼저 그것을 읽는다.

업로드 *절차*(Studio·클립 화면 조작법, 한도, 실전 메모)의 원본은 **Aside 앱의 사용자 스킬 `sns-content-ops`**(`~/.aside/u/0/skills/user/sns-content-ops/`)이며 Aside가 직접 읽고 따른다. **여기에 옮겨 적지 않는다**(두 벌이 어긋난다). Aside 스킬 맨 위(SKILL.md·`youtube-publish.md`)에 "2026-10-11 변경" 덮어쓰기 블록을 넣어 두었다(문구는 `upload.json` 그대로, `metadata_final: true`만 업로드, 저장소는 `SNS Uploads`). 이 스킬이 맡는 것은 다음 다섯이다 — **문구를 쓰고 승인받기**, 언제 Aside를 부를지, 무엇을 말할지, 어디서 멈출지, 결과를 어떻게 검증할지.

## 0. 기준 폴더와 역할 (2026-10-11 확정)

구글 드라이브 데스크톱을 삭제했고 `안부 쇼츠`는 `SNS Uploads`로 옮겼다. **2026-10-11 구조 변경 — 파일이 세 곳으로 나뉜다:**

| 폴더 | 역할 | git |
|---|---|---|
| `/Users/macmini/Project/Anbu/averic-lab/_shorts-build/.mix/hq/<파일명>.mp4` | **유튜브용 고화질 원본 mp4(CRF 18, 소리 포함)** — 모든 언어가 한 폴더(파일명은 ko=`<편id>.mp4`, 그 외 `<편id>-<언어>.mp4`). `upload.json`의 `file` 필드가 가리키는 곳 | 커밋 안 됨(`.gitignore`) |
| `/Users/macmini/Documents/SNS Uploads/` | `upload.json`·`publish.json`(장부)과 **1080×1920 썸네일 jpg**(`videos/<언어>/<파일명>.jpg`) — 약 15MB, **mp4를 두지 않는다**(iCloud 동기화·용량) | 해당 없음 |
| `/Users/macmini/Project/Anbu/averic-lab/media/shorts/` | 홈페이지용 저화질 사본(CRF 28) + 540px 포스터 | 커밋됨 |

```
SNS Uploads/
├── videos/<언어>/<파일명>.jpg   ← 썸네일만
├── upload.json     ← Claude Code(제작)만 수정
├── publish.json    ← Aside만 수정 (Claude Code는 읽기만)
└── _drive-backup-2026-10-11/   ← 드라이브 제거 직전 백업
```
- `media/shorts`의 mp4는 **업로드 원본이 아니다**(저화질). 업로드에는 항상 `.mix/hq`의 mp4를 쓴다. 두 곳의 같은 이름 파일을 서로 덮어쓰지 않는다.
- 백업은 필요 없다는 것이 사용자 결정(2026-10-11)이다 — `.mix/hq`는 이 Mac에만 있다.
- Aside는 이 폴더를 **읽고 쓸 수 있다**(ls·read·write 실측 통과, 승인 요청 없음). 그래서 `publish.json`은 이제 **로컬 파일에 Aside가 직접 쓴다**(드라이브 웹 "새 버전 업로드" 경로는 없어졌다). 쓰는 주체가 하나라는 원칙은 그대로다.
- ⚠️ Aside의 스킬 문서(`youtube-publish.md` 2절 등)는 아직 드라이브 방식으로 적혀 있다. 그래서 **프롬프트에서 기준 경로를 매번 덮어쓴다**(§3의 고정 문장). Aside 스킬 문서를 고치는 일은 사용자 허락 후에만 한다.
- Aside는 `~/Library/CloudStorage`, `Project/Anbu/averic-lab/` 아래(`media/shorts`, `.mix/hq` 포함)를 읽지 못한다(`Operation not permitted`) — 그래서 mp4는 제가 세션 폴더로 복사해 준다(§4 「파일 넘기기」).

## 1. 먼저 점검 (읽기 전용, 몇 초)

```bash
~/.local/bin/aside account status    # signed in 이어야 함
~/.local/bin/aside host profiles     # 프로필 connected 이어야 함
~/.local/bin/aside session list      # §2 판단에 쓴다
```
PATH에 없으면 전체 경로를 쓴다. 로그인이 풀렸으면 사용자가 `aside login`을 해야 한다 — 대신 해 주지 못한다.

## 2. 새 세션인가, 이어서인가 (서버 저장소 `.ref/ASIDE-OPS.md` 4.1절)

요청마다 `session list`를 보고 판단하고, 요청 직전에 사용자에게 한 줄로 알린다("새 세션으로 시작한다 / 세션 `<id>`(제목)에 이어서 한다 — 이유").

- **업로드는 같은 편의 1단계(초안)와 2단계(실행)를 한 세션으로 잇는다.** 2단계는 반드시 `session resume`.
- 다른 편·다른 날의 업로드는 새 세션(이전 편의 맥락이 섞이면 제목·태그가 오염된다).
- 잘못 만든 세션은 즉시 `session stop <id>` → 필요하면 `session delete <id>`.

## 3. 모든 프롬프트에 넣는 고정 문장

Aside에 보내는 업로드 관련 프롬프트에는 **빠짐없이** 아래를 넣는다. 하나라도 빠지면 Aside 스킬 본문의 기본값(자동 진행)이 이긴다.

1. **기준 경로 덮어쓰기**: "쇼츠 기준 폴더는 구글 드라이브가 아니라 `/Users/macmini/Documents/SNS Uploads/`다. `upload.json`·`publish.json`은 이 폴더의 로컬 파일을 읽는다. `publish.json`은 이 로컬 파일에 직접 쓴다(쓰기 전에 최신본을 다시 읽는다). 드라이브 웹은 쓰지 않는다."
2. **0절 점검 금지**: "SKILL.md 0절 대화 시작 점검은 하지 않는다. 그 점검은 publish.json을 쓸 수 있으므로, 이번 요청에서는 건너뛴다."
3. **채널 확인**: "Studio에서 활성 채널이 `안부 Anbu`(채널 ID `UCxM4jWte1dG3SZpSJkK5vmg`)인지 먼저 확인한다. `sangbong lee`(개인 채널)이면 아무것도 하지 말고 멈춘다. 개인 채널에는 광고 수익 정보가 묶여 있어 잘못 올리면 옮길 수 없다."
4. **대상 명시**: 편 id × 언어를 직접 적는다("before-departure/ko"). "새 거 올려 줘"처럼 모호하게 쓰지 않는다.
5. **공개 방식을 프롬프트에 적는다**(2026-10-11 정책, `copy-rules.md` 7절): 기본은 "썸네일까지 넣고 업로드가 끝나면 **바로 공개**한다(예약하지 않는다). 네이버 클립은 '등록 예약'을 켜지 않고 바로 등록한다." 시험 업로드처럼 공개하지 않을 때는 "비공개로 둔다"를 적는다. 프롬프트에 적히지 않은 공개·예약은 하지 않는다. `metadata_final`이 `true`가 아니면 공개하지 않는다.
5-1. **캘린더**: "구글 캘린더에는 등록하지 않는다"를 적는다(바로 공개하는 영상은 일정이 필요 없다).
6. **문구는 `upload.json` 그대로**: "제목·설명·태그·클립 설명은 `upload.json`의 `title` `description` `tags` `naver_caption`을 한 글자도 바꾸지 않고 입력한다. `metadata_final`이 `true`가 아닌 항목은 올리지 않고 멈춘다. 입력 후 읽어서 승인본과 같은지 비교한다." (Aside 스킬의 13절 "다국어 설명을 알아서 정해 올림"은 덮어쓰기 블록으로 대체했지만, 프롬프트에도 한 번 더 적는다. 다국어 항목도 내가 먼저 문구를 쓰고 승인받는다.)
7. **오류 대응**: "'Cannot find context' 같은 오류가 나면 다시 올리지 말고 먼저 현재 창 상태(제목·파일 이름)를 읽고 이어서 진행한다. 일일 업로드·썸네일 한도 메시지가 뜨면 즉시 멈추고 보고한다."
8. **보고 형식**: "본 것과 추정한 것을 구분한다. 확인하지 않은 것을 완료라고 말하지 않는다."
8-1. **유튜브 쇼츠 링크를 항상 출력하고 저장한다**(2026-10-11 사용자 지시): "업로드가 끝나면 **유튜브 쇼츠 링크 전체**(`https://youtube.com/shorts/<ID>`)와 일반 링크(`watch?v=<ID>`)를 한 글자도 줄이지 말고 보고하고, `publish.json`의 그 항목 `youtube_id`·`links.shorts`·`links.watch`·`links.studio`에 적는다." 링크는 홈페이지(`averic.co.kr`)가 쓰므로 필수다. **네이버 클립 링크는 홈페이지가 쓰지 않으므로 찾지 않는다**(`naver_clip.clip_url`은 `null`이어도 된다, 2026-10-11 사용자 지시). 링크가 없는 채로 '완료'라고 말하지 않는다. 나는 `publish.json`을 읽어 `youtube_id`와 `links.shorts`가 서로 맞는지만 확인한다(`youtube.getMetadata` 조회는 하지 않는다 — 2026-10-11 사용자 결정).
   (유튜브 링크는 내가 받아 `averic.co.kr` 홈페이지 영상 페이지에 반영한다 — 아래 §6-1.)

## 4. 두 단계로 진행한다 (승인 없이 게시되지 않게)

### 0단계 — 문구를 내가 쓰고 승인받는다 (Aside를 부르기 전)

1. `copy-rules.md`를 읽고 `upload.json`의 해당 `"편id/언어"` 항목에 최종 `title`·`description`·`hashtags`·`tags`·`naver_caption`을 쓴다(`metadata_final: false`). 클립 설명은 글자 수를 직접 센다(300자 이내).
2. 사용자에게 **한 메시지**로 보여 준다: 최종 문자열 전문(글자 수 포함), 해시태그 구성(고정 태그 변경이 있으면 따로 표시), 플랫폼별 공개 슬롯(날짜·시각). **"업로드해 보자"는 계획에 대한 승인일 뿐 이 문구에 대한 승인이 아니다.** 사용자가 답하기 전에는 올리지 않는다.
3. 슬롯을 제안하기 전에 로컬 `publish.json`과 **Studio 실제 상태**(1단계 점검)로 이미 잡힌 일정을 확인한다. 하루 1편 규칙(기본: 네이버 클립 19:00 / 유튜브 20:00).
4. 승인되면 `metadata_final: true`, `finalized_at: <오늘>`로 바꾼다. 승인 후 한 글자라도 고치면 `false`로 되돌리고 다시 승인받는다.

### 1단계 — 업로드 전 점검 (새 세션, 읽기 전용, 아무것도 올리지 않음)

프롬프트: §3 고정 문장 + "읽기 전용 점검이다. 업로드·예약·공개 전환·수정·삭제·`publish.json` 쓰기·캘린더 등록을 하지 않는다. 대상 `<편id>/<언어>`. ① `upload.json`의 해당 항목에서 `metadata_final`·`title`·`hashtags`·`tags` 값을 인용하고 `naver_caption`의 글자 수를 센다 ② 로컬 `upload.json`·`publish.json`에서 `id + lang` 중복 확인 ③ Studio에서 활성 채널이 `안부 Anbu`인지 확인(업로드 버튼은 누르지 않음) ④ 네이버 클립 크리에이터 로그인 여부(로그아웃이면 로그인하지 말고 보고) ⑤ Studio·클립 콘텐츠 목록에서 앞으로 7일 안에 예약된 영상(날짜·시각·제목)과 `publish.json`의 `scheduled` 항목의 실제 상태(불일치만, 고치지 않음). 본 것과 추정한 것을 구분한다."

→ 출력은 파일로 받아 **전부** 읽는다(§5). 이 점검이 끝나기 전에 0단계 슬롯을 확정하지 않는다. 승인 없이 2단계로 가지 않는다. **네이버 클립이 로그아웃이면 사용자가 Aside 브라우저에서 직접 로그인해야 한다**(에이전트가 대신 로그인하지 않는다).

### 파일 넘기기 (2단계 직전, 내가 한다)

Aside의 `setInputFiles`는 **그 세션 폴더 안의 경로만** 받는다(`escapes the session directory` 실측). `SNS Uploads`도 거부된다. 그래서:

```bash
aside session list | head -3                               # 방금 만든 세션 id
SD=$(ls -d ~/.aside/u/0/sessions/*<세션id> | head -1)
H=/Users/macmini/Project/Anbu/averic-lab/_shorts-build/.mix/hq; U="/Users/macmini/Documents/SNS Uploads/videos/<언어>"
mkdir -p "$SD/tmp" && cp "$H/<파일명>.mp4" "$U/<파일명>.jpg" "$SD/tmp/"   # mp4 는 hq 에서, jpg 는 SNS Uploads 에서 (upload.json 의 file / thumbnail 필드)
shasum -a 256 원본 "$SD/tmp/…"                               # 해시가 같고 0바이트가 아닌지 확인
```
파일명 규칙: ko는 `편id.mp4/.jpg`, 다른 언어는 `편id-언어.mp4/.jpg`. mp4 또는 썸네일 jpg가 없으면 올리지 않고 사용자에게 알린다. **`.mix/hq`에 mp4가 없으면 `media/shorts`의 저화질 사본으로 대신 올리지 않는다**(재렌더가 필요함을 알린다).

### 2단계 — 실행 (1단계와 같은 세션에 `session resume`)

프롬프트: §3 고정 문장 + "승인됐다(`metadata_final: true`). `upload.json`의 `<편id>/<언어>` 항목을 **그대로** 입력한다. 파일은 이 세션 `tmp`에 복사해 뒀다: `<경로>`(mp4 `<n>`바이트, jpg `<m>`바이트)를 `setInputFiles`에 쓴다. 제목·설명·태그 칸·클립 설명을 입력한 뒤 입력창을 읽어서 `upload.json`과 글자 하나, 줄바꿈 하나까지 같은지 비교하고, 다르면 저장하지 않고 멈춘다. 공개 상태는 `<예약 / 비공개 / …>`, 슬롯은 `<날짜·시각>`. 완료되면 로컬 `publish.json`에 항목을 쓰고(쓰기 전 최신본 재독), 영상 ID·링크·상태·실제 입력한 값(`title_live` `description_live` `caption_live` `tags_live` `hashtags_live`)을 보고한다."
공개 전환·예약 확정은 위처럼 **프롬프트에 적은 것만** 한다.

업로드가 끝나고 §6 검증을 마친 뒤 세션 `tmp`에 복사해 둔 mp4/jpg를 **지운다**(Aside는 지우지 않는다 — 세션 폴더는 `session delete` 후에도 남는다).

## 5. 실행 방식 (출력을 잃지 않게)

- 오래 걸리므로 **백그라운드 + 출력 파일**로 돌리고, 끝나면 파일을 **통째로** 읽는다. `| tail -N`으로 자르지 않는다(보고문 앞부분을 잃은 사례가 있다).
  ```bash
  OUT=<scratchpad>/aside-<작업>.txt; aside session resume <id> "…" > "$OUT" 2>&1; echo "done exit=$?" >> "$OUT"
  ```
- 진행 중 약 60초마다 사용자에게 한 줄 상태를 알린다(`aside guide` 권고).
- 프롬프트에 한글이 길어도 된다. 따옴표 안의 `"`·`$`·백틱은 이스케이프한다.

## 6. 결과는 Aside의 말을 그대로 전하지 않고 직접 검증한다

Aside가 "올렸다"고 보고하면 아래를 **내가 직접** 확인한 뒤 사용자에게 알린다.

1. `publish.json`(로컬)을 읽어 해당 `"편id/언어"` 항목의 `youtube_id`·`status`·`title_live`·`publish_at`·`thumbnail_set`·`tags_live`를 확인. (Aside만 쓰는 파일이므로 쓰지 않고 읽기만.)
2. `publish.json`의 `title_live`·`description_live`·`caption_live`·`tags_live`가 **승인된 `upload.json` 값과 글자 그대로 같은지** 대조한다(`diff`). 채널이 `안부 Anbu`인지도 확인한다.
3. 틀린 곳이 있으면 고친 척하지 말고 그대로 사용자에게 알린다.

### 6-1. 홈페이지(averic.co.kr) 반영 — 빌드·커밋·푸시 (SNS 업로드의 마지막 단계, 2026-10-11 사용자 지시)

유튜브 쇼츠가 **공개**로 `publish.json`에 기록되면(§6) 곧바로 이어서 한다. 별도 지시를 기다리지 않고, **푸시까지** 한다(사용자의 상시 허락 — 예전의 "커밋만, 푸시는 나중에" 규칙은 폐기).

1. `publish.json`(로컬 `~/Documents/SNS Uploads/publish.json`)에 그 `"편id/언어"`의 `youtube_id`·`status: public`이 있는지 확인한다. `unlisted`·`private`·`scheduled`이면 반영하지 않는다(공개될 때까지 보류, 사용자에게 알림).
2. 포스터 `averic-lab/media/shorts/<언어>/<파일명>.jpg`(540px, 한국어는 `<편id>.jpg`)가 있어야 한다. 없으면 만든다. **mp4는 커밋하지 않는다**(유튜브로 재생하므로 필요 없다).
3. `cd /Users/macmini/Project/Anbu/averic-lab && git fetch && git status` — `main`이고 원격보다 뒤처지지 않았는지 본다. 뒤처졌으면 `git pull --rebase`. 충돌이 나면 멈추고 사용자에게 알린다.
4. `python3 i18n/build.py` — 빌드 경고(`publish.json 을 읽지 못함`)가 없어야 한다. 경고가 나오면 **커밋하지 말고** 멈춘다(전부 mp4로 되돌아간 페이지가 푸시된다).
5. `git diff --stat`으로 바뀐 파일이 **그 언어의 `shorts.html`(플레이어 추가)과 포스터 jpg뿐**인지 확인한다. 그 밖의 페이지가 바뀌었으면 멈추고 원인을 본다.
6. `git add <shorts.html> <포스터.jpg>`로 **파일을 골라** 넣는다(`git add -A`·`.` 금지 — averic-lab에는 무관한 미추적 파일이 많다). 커밋 메시지는 한글, 끝에 공동 작성 줄.
7. `git push`. 푸시가 거절되면 `git pull --rebase` 후 한 번만 다시 시도하고, 그래도 안 되면 멈춘다. `--force` 금지.
8. GitHub Pages 반영을 확인한다: `curl -s https://averic.co.kr/<언어>/shorts.html | grep -c <youtube_id>`가 1 이상이 될 때까지 최대 약 3분 기다린다(캐시 때문에 `?v=<타임스탬프>`를 붙인다). 안 되면 "푸시했으나 아직 반영 전"으로 보고한다.
9. 사용자에게 알린다: 반영한 페이지 URL(`https://averic.co.kr/<언어>/shorts.html`), 유튜브 쇼츠 링크, 커밋 해시.

다국어판을 한꺼번에 올렸을 때는 언어별로 따로 커밋하지 않고 **한 번에 빌드해 한 커밋·한 푸시**로 묶는다(`shorts.html` 여러 개 + 포스터 jpg 여러 개).

## 7. 실측으로 확인된 사실 (2026-10-11)

| 항목 | 결과 |
|---|---|
| `aside exec` / `session resume` | 동작. 이전 세션의 맥락이 유지된다 |
| `SNS Uploads` ls·읽기·쓰기 | 됨 (승인 요청 없음) |
| `SNS Uploads` 경로를 `setInputFiles`에 | **안 됨** (`escapes the session directory`) |
| 세션 폴더 `tmp`의 파일을 `setInputFiles`에 | **됨** (mp4 2096302B, jpg 21483B 정확히 입력) |
| `~/Library/CloudStorage`, `averic-lab/media/shorts` | Aside 접근 불가 (`Operation not permitted`) |
| `aside repl` + `youtube.getMetadata` | 브라우저 에이전트 없이 동작 |
| **실제 업로드 종단 시험** (before-departure/ko, 2026-10-11) | **성공.** 점검 세션을 `resume`해 유튜브(공개, 썸네일 적용)와 네이버 클립(공개, 커버 적용)에 약 6분 만에 업로드. 제목·설명·태그·클립 설명이 `upload.json`과 글자 그대로 일치(내가 `publish.json`과 `youtube.getMetadata`로 직접 대조), 다른 `publish.json` 항목 변경 0, 일일 한도 없음 |
| 네이버 클립 링크 | 홈페이지가 쓰지 않아 필요 없음(2026-10-11 사용자 결정). 찾아야 하면 클립 상세에서 공유 버튼의 `naver.me/…` 단축 링크를 쓴다(`seedMediaId`만 붙인 주소는 오류가 났음) |
| 네이버 클립 카테고리 | Aside가 스킬 기준으로 `라이프스타일 > 가족` 선택(소재별 2차 분류는 Aside 판단) |
| 클립 설명 300자 카운터 | 299/300에서 통과(줄바꿈 1자 계산) |
| 구글 캘린더 | 정책대로 등록하지 않음(확인) |
| 네이버 클립 삭제 (2026-10-11, 7편) | 성공. 삭제 확인 창에 **클립 제목이 나오지 않으므로** 제목으로 찾은 줄의 더보기 메뉴에서 눌러야 한다(지우기 전에 목록 분류표를 받고, 한 편씩 지우며 매번 개수 감소 확인). 삭제된 항목은 `publish.json`의 `naver_clip.status: "removed"`, `clip_url: null`, `removed_at`로 기록. 유튜브는 건드리지 않음 |
| Aside의 `tmp` 정리 | **하지 않는다** — mp4·jpg·`publish.json.bak`·스크린샷 17장이 남음. 업로드·검증 뒤 내가 `find "$SD/tmp" -mindepth 1 -delete`로 비운다 |

## 8. 하지 않는 것

- **YouTube API로 업로드하지 않는다.** 감사 전 API 업로드는 비공개로 고정돼 공개할 수 없다.
- `publish.json`을 쓰지 않는다(Aside 전용). `upload.json`은 제작 단계에서만 고친다.
- 사용자 승인 없이 공개·예약 확정·삭제·채널 설정 변경을 지시하지 않는다. (삭제를 지시할 때는 유지·삭제 목록을 제목으로 못 박고, "둘 다 아님"이 있으면 지우지 말고 멈추게 한다.)
- **유튜브 영상을 비공개로 바꾸거나 지우지 않는다** — 홈페이지(`averic.co.kr/*/shorts.html`)가 유튜브 임베드로 재생하고, 비공개 영상은 임베드에서도 재생되지 않는다(공개·일부 공개만 재생).
- Aside 앱의 스킬 파일(`~/.aside/u/0/skills/`)과 설정을 허락 없이 고치지 않는다.
- 개인 채널(`sangbong lee`)에는 어떤 경우에도 올리지 않는다.
- **제목·설명·해시태그를 Aside에게 쓰게 하지 않는다.** 문구는 내가 `upload.json`에 쓰고 승인받는다. `metadata_final`이 `true`가 아닌 항목은 업로드를 지시하지 않는다.
- Aside가 막힌 곳(`Operation not permitted` 등)에서 우회하라고 시키지 않는다.

## 9. 아직 정해지지 않은 것 · 알려진 문제

- 스레드·인스타그램·블로그·댓글 답글을 이 방식으로 지시할지(같은 구조를 쓰되 검증 전).
- 고정 해시태그는 2026-10-11 승인됨(`#1인가구 #부모님안부 #안부확인`). Aside 쪽 `keywords-hashtags.md` 3절에는 옛 4개가 남아 있지만 쇼츠에는 덮어쓰기 블록이 우선한다.
- `state/post-log.md`는 Aside 로컬 상태 파일이다 — 공개된 편을 기록하는 것은 Aside에 맡긴다.
- **다른 저장소의 드라이브 경로**: `averic-lab/_shorts-build/3d/deliver.py` 14행(`DRIVE = ~/Library/CloudStorage/...`)과 `_shorts-build/README.md` 220행은 삭제된 경로를 가리킨다. 그대로 실행하면 실패하거나 그 폴더를 다시 만든다. 고치기 전에는 `deliver.py`를 실행하지 않는다.
- **`publish.json`이 낡아 있다**: 2026-10-11 점검에서 `scheduled`로 남은 22개(how-to-use 20개, anbu-3d ja·en)가 Studio에서는 모두 공개였다. Aside에게 "점검만, 0절" 요청을 따로 줘서 로컬 `publish.json`에 반영하게 한다(사용자 승인 후).
