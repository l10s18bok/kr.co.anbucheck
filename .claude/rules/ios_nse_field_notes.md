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
| **Q3** 확장에서 걸음수를 읽는가 | ⚠️ **되는 것으로 보이나 값이 0** | `isStepCountingAvailable=1`, `authorizationStatus=3`(authorized), 에러 없음. 같은 시각 앱에서도 0이었으므로 실제 걸음이 0인 것으로 보이지만, **0이 아닌 값으로 재확인 필요** |

⚠️ **Q3는 아직 완전히 닫히지 않았다.** 걸음이 쌓인 상태에서 한 번 더 재서 확장이
0이 아닌 값을 읽는지 확인해야 "확장에서 CMPedometer가 된다"가 확정된다.

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

아직 안 만든 것: App Group + device_token 미러링(진짜 heartbeat 전송에 필요),
`.passive` iOS 14 분기(`if #available`), 7일 롤링 재무장.
