# iOS Notification Service Extension 실측 기록 (2026-08-22)

"iOS는 앱이 강제 종료되면 아무것도 못 한다"를 우회할 경로가 실제로 있는지 측정한 기록.
**추정이 아니라 실기기 실측이다.** 같은 논의가 다시 나오면 여기부터 읽는다.

- 측정 기기: **iPhone XS (iPhone11,2), iOS 17.4.1**, 개발자 모드 ON, USB 연결(충전 중)
- 앱: 프로브 전용 번들 `kr.co.anbucheck.probe` (운영 `.live`와 공존), release 빌드
- 확장: `kr.co.anbucheck.probe.ProbeNSE`
- 발송: firebase-admin → FCM → APNs(개발 인증 키 `2CZ89UJHA8`)

---

## 1. 왜 이걸 재는가 — 안드로이드와 문제의 종류가 다르다

| | Android | iOS |
|---|---|---|
| 문제 | OS가 실행은 시켜주되 **언제**를 조인다 | 앱이 죽으면 **아예 실행되지 않는다** |
| 해법 | 측정으로 창을 찾는다(알람 → expedited job) | 측정으로는 안 풀린다. **서버가 트리거**가 돼야 한다 |

킬 상태에서도 실행되는 경로는 **표시형 푸시가 띄우는 Notification Service Extension** 하나뿐이다.

## 2. ★ 결과 — 강제 종료 상태에서 확장이 돌고, 통신까지 된다

앱을 앱 스위처에서 **스와이프 킬한 뒤** 푸시 1건 발송:

```
21:22:42  앱 실행 → arm probe-offline: ok / motion auth=3 / notification granted
21:22:5x  앱 스와이프 킬
21:23:33  푸시 발송 (mutable-content:1 + alert title/body)
21:23:34  ProbeNSE(pid 2586) 실행
          net=200 1220ms 194B | pend 2→2 had=Y rm=ok add=ok/Y | steps=0 av=1 auth=3
          총 1225ms
```

| 질문 | 답 | 근거 |
|---|---|---|
| **Q1** 확장에서 네트워크가 열리는가 | ✅ **열린다** | HTTPS GET 200, 왕복 **1220ms**, 194B 수신. DNS·TLS·HTTP 전 구간 성공 |
| **Q2** 다른 프로세스가 심은 pending을 조작하는가 | ✅ **된다** | 앱이 심은 `probe-offline` 존재(had=Y) → 확장이 **제거 성공**(rm=ok) → 새 요청 추가도 성공(add=ok, 재조회 Y) |
| **Q3** 확장에서 걸음수를 읽는가 | ✅ **된다** | 2차 측정에서 **`steps=34`**(폰을 흔들어 걸음을 만든 뒤). `av=1 auth=3`, 에러 없음 |

### 2차 측정 — Q3 확정 + Q2 이중 확증 (21:28:37, 앱은 계속 강제 종료 상태)

```
net=200 1613ms 194B | pend 2→2 had=N rm=ok add=ok/Y | steps=34 av=1 auth=3
```

- **`steps=34`** — 1차의 0은 실제로 걸음이 없었던 것이고, 확장 안에서 CMPedometer가
  정상 동작한다. **확장이 걸음수를 실어 보낼 수 있다.**
- **`had=N`** — 1차에서 확장이 제거한 `probe-offline`이 그대로 사라져 있다.
  API 성공 보고(`rm=ok`)가 실제 상태 변화였음이 다음 측정으로 확증됐다.
- 네트워크 2회 연속 성공(1220ms / 1613ms).

## 3. 대조군이 값을 했다 — 반드시 유지할 것

원본 페이로드에 `PROBE-ORIGINAL`을 심고 확장이 항상 덮어쓰게 했다. 판독이 이분법이 된다:

- 화면/로그에 측정값 → 확장이 실행됨
- 화면에 `PROBE-ORIGINAL` → **확장이 아예 안 돌았다**(자원 부족·크래시·예산 초과)

시뮬레이터 측정(§4)에서 정확히 이 대조군 덕분에 "확장이 돌았는데 전부 실패"로 오독하지 않았다.

## 4. ⚠️ `xcrun simctl push`는 NSE를 호출하지 않는다 (2026-08-22, iOS 18.6 시뮬)

확장 번들이 정상인데도(principal class 해석됨, `didReceive` 심볼 존재, 시스템이
`PluginBundleIds`에 등록) **ProbeNSE 프로세스가 한 번도 뜨지 않았다.** 앱 종료 상태·
포그라운드 상태 두 번 다 0회이고 대조군이 그대로 표시됐다. 시뮬레이터는 APNs 파이프라인을
거치지 않고 `usernotificationsd`에 직접 주입하는 것으로 보인다.

→ **NSE 검증은 실기기에서만 가능하다.** 시뮬레이터에 시간을 쓰지 말 것.

## 5. 재현 절차 (probe/ios-nse 브랜치)

```bash
# 1) 타겟 생성(재실행 안전) — 이미 커밋돼 있으면 불필요
cd ios && ruby add_probe_nse_target.rb

# 2) release 빌드로 설치 (⚠️ debug 빌드는 홈 화면에서 실행 불가 — iOS 14+)
flutter run --release -d <UDID>

# 3) 기기 로그 캡처 (root 불필요. `log collect --device`는 root를 요구해 못 쓴다)
idevicesyslog -u <UDID> > syslog.txt

# 4) 앱 실행 → 스와이프 킬 → 푸시
python3 tool/probe/send_probe_push.py <FCM_TOKEN> <nonce>

# 5) 판독
grep "PROBE-NSE" syslog.txt
```

## 6. 함정 모음 (전부 실제로 걸렸던 것)

| 함정 | 증상 | 해결 |
|---|---|---|
| 임베드 페이즈 위치 | `error: Cycle inside Runner` | 'Embed App Extensions'를 Flutter의 'Thin Binary' **앞**으로 |
| debug 빌드 | 홈 화면 아이콘 탭 시 "debug mode Flutter apps can only be launched from Flutter tooling" | **release 빌드**로 설치 |
| 번들 ID 공유 | 개발 빌드가 TestFlight 앱을 대체 → 데이터 삭제 + 계정 고아화 위험 | 프로브 전용 번들 `kr.co.anbucheck.probe` |
| Firebase 앱 분리 | 새 번들엔 APNs 키가 **비어 있다**(앱별 설정) | 기존 `.p8`(팀 단위 키)를 새 앱에도 업로드 |
| 콘솔 테스트 메시지 | 확장이 안 뜸 | Firebase 콘솔은 `mutable-content`를 못 붙인다. **스크립트로 발송** |
| `log collect --device` | `Must be root` | `idevicesyslog` 사용 |
| `devicectl process launch` | 이미 떠 있으면 런치 코드가 다시 안 돈다 | 스와이프 킬 후 아이콘 탭 |

## 7. 이 결과가 여는 설계

```
서버가 예약시각에 표시형 푸시(mutable-content) 발송
  └ NSE가 강제 종료 상태에서도 실행 (실측)
      ├ heartbeat POST를 확장 안에서 수행       ← Q1 초록
      ├ 성공 시 문구를 "전달 완료"로 교체 + passive → 배너·소리 없음
      └ 오프라인 폴백 로컬 알림을 pending에서 제거  ← Q2 초록
  └ 푸시가 안 오면(망 없음) 확장도 안 돌아 폴백 알림이 그대로 발화
```

**걸음수도 확장이 직접 읽을 수 있으므로**(Q3), 확장이 보내는 heartbeat는 회복 전송이
아니라 **걸음수를 실은 정상 heartbeat**가 될 수 있다.

아직 안 만든 것: App Group + device_token 미러링(진짜 heartbeat 전송에 필요),
`.passive` iOS 14 분기(`if #available`), 7일 롤링 재무장.

---

## 8. 배포 시 하위호환 검토 — 구버전 iOS 앱은 안전한가

새 설계는 **서버 변경(예약시각 iOS 푸시)** 과 **앱 변경(NSE 추가)** 이 짝을 이룬다.
서버는 즉시 전원에게 적용되지만 앱은 각자 업데이트해야 하므로, **업데이트하지 않은
iOS 사용자**에게 무슨 일이 생기는지 따로 따져야 한다.

### 8.1 구버전 앱이 새 푸시를 받으면 (NSE 없음)

| 항목 | 결과 |
|---|---|
| 알림 표시 | ⭕ 원본 페이로드 그대로 표시된다. `mutable-content`는 확장이 없으면 **무시**된다 |
| 크래시·오류 | ❌ 없음. `content_available`는 기존 no-op 백그라운드 핸들러로 떨어진다 |
| 탭 라우팅 | type을 **`subject_safety_net`으로 재사용하면** 구버전도 `_routeToSafetyHome` → 자동 전송 + 안내 다이얼로그까지 정상 동작한다(클라 코드가 플랫폼을 가리지 않는다). 새 type을 쓰면 `default` → 대시보드로 가는데, G+S는 대시보드 `onInit/onResumed`가 `refreshAndSend()`를 부르므로 heartbeat는 결국 나간다(안내 다이얼로그만 없음) |
| **중복 알림** | ⚠️ **이것이 유일한 실질 퇴행이다.** 구버전은 `gs_deadman` 정시 로컬 알림을 계속 갖고 있어, 같은 시각에 **로컬 알림 + 서버 푸시 2개**가 뜬다 |

### 8.2 중복 알림 해법 — 서버가 앱 버전을 모른다

`devices` 테이블에는 `os_version`만 있고 **앱 버전 컬럼이 없다**(2026-08-22 확인).
따라서 오늘 당장은 "새 버전에만 보내기"가 불가능하다.

**전제조건(선택 아님): 능력 플래그 게이팅.**

```sql
ALTER TABLE devices ADD COLUMN supports_push_heartbeat BOOLEAN NOT NULL DEFAULT false;
```

새 클라만 등록·토큰 갱신 시 `true`로 올린다. 구버전은 영영 `false`이므로 새 푸시가
**아예 발송되지 않는다** → 구버전 사용자는 변화 0. 앱 버전 문자열(semver) 비교보다
정확하고, 나중에 NSE를 뺀 버전이 나와도 플래그만 끄면 된다.

⚠️ **이것을 "개선"이 아니라 "전제조건"으로 취급할 것.** 게이팅 없이 배포하면
같은 시각에 알림이 2개 뜨는데, 대상이 고령 사용자다. "두 번 눌러야 하나"라는 혼란을
없애는 것이 이 앱의 제품 가치인데 그것을 스스로 깬다. 게다가 **클라의
`subject_safety_net` 처리는 2026-06-01(`fb73356`)에 들어왔으므로**, 그 이전 버전은
푸시를 탭해도 `default` → 대시보드로 떨어져 **"안부 전달됨" 다이얼로그가 뜨지 않는다**
(전송 자체는 대시보드 `refreshAndSend`로 이뤄지나 사용자는 확신할 수 없다).

**부수 효과 — 배포 순서가 저절로 안전해진다.** 서버를 먼저 켜도 그 시점엔 아무도
`true`가 아니라 실제 발송이 0건이다. 앱이 배포되며 업데이트한 기기부터 하나씩
새 방식으로 전환되고, 문제가 생기면 **서버 조건 한 줄로 전원 즉시 롤백**된다.

알려진 예외: 새 버전 설치 후 TestFlight로 구버전을 재설치하면 플래그가 `true`인 채
구버전 코드가 돌아 알림이 2개가 된다(구버전엔 플래그를 내릴 코드가 없다).
App Store 사용자는 다운그레이드가 불가능하므로 **내부 테스터 한정**이다.

### 8.3 ⚠️ "강제 업데이트로 해결" 은 iOS G+S에서 잘 듣지 않는다

강제 업데이트는 **사용자가 앱을 열어야** 걸린다. 그런데 PRD §9.0의 **버전 체크 skip 정책**은
heartbeat 전송 유도 알림(`gs_deadman`/`subject_safety_net`/`safety_net`/`send_failed`)으로
런치하면 **버전 체크를 통째로 건너뛴다**(강제 업데이트 포함). 그리고 iOS G+S 사용자의
주 진입 경로가 바로 그 `gs_deadman` 탭이다.

→ **알림만 탭해서 쓰는 사용자에게는 강제 업데이트가 영영 안 걸릴 수 있다.**
아이콘으로 앱을 여는 날에만 걸린다. 강제 업데이트를 이주 수단으로 **전제하지 말 것**.
8.2의 NULL 게이팅이 강제 업데이트 없이도 안전하므로 그쪽이 본선이다.

### 8.4 ⚠️ NSE는 **모든** 푸시를 거친다 — 지정 타입만 개입해야 한다

`push_service.py:138-147`은 **모든 푸시에 이미 `mutable_content=True`를 붙이고 있다.**
따라서 앱에 NSE가 추가되는 순간, 보호자 경고·긴급·구독 안내 등 **모든 알림이 확장을 통과**한다.

두 가지 위험이 생긴다:

1. **문구 훼손** — 확장이 무조건 제목·본문을 덮어쓰면 경고 알림이 깨진다.
2. **표시 지연** — 확장이 네트워크를 기다리면 그만큼 알림이 늦게 뜬다. 긴급 경고가
   10초 늦게 뜨는 것은 이 서비스에서 받아들일 수 없다.

→ **불변 규칙: 확장은 지정 타입(heartbeat 트리거)일 때만 개입하고, 그 외 타입은
`didReceive` 진입 즉시 원본 그대로 `contentHandler`를 호출해 통과시킨다.**
프로브는 모든 푸시를 가공했지만 본 구현에서는 반드시 분기해야 한다.

### 8.5 정리

| 위험 | 심각도 | 대응 |
|---|---|---|
| 구버전에 중복 알림 | 중 (UX 퇴행) | `devices.app_version` 추가 + NULL이면 새 푸시 미발송 |
| 구버전 탭 라우팅 | 낮 | type을 `subject_safety_net`으로 재사용하면 구버전도 정상 경로 |
| 강제 업데이트 미적용 | 중 | 이주 수단으로 전제하지 말 것 (§8.3). NULL 게이팅이 본선 |
| 경고 알림 훼손·지연 | **높** | 확장이 지정 타입만 개입 (§8.4) |
| 크래시·데이터 손상 | 없음 | — |

**결론: 구버전 iOS 앱을 업데이트하지 않아도 기능적 문제는 없다.**
단 §8.2를 하지 않으면 알림이 하루 두 번 뜨고, §8.4를 하지 않으면 **새 버전 사용자의
보호자 경고가 훼손·지연될 수 있다** — 후자가 구버전 문제보다 위험하다.
