# 번역 용어집 — 서버·앱·홈페이지·쇼츠 공통 기준

2026-10-05 전면 재검수 때 확정, 2026-10-07 일본어 호칭·코드 조합 규칙 보강. 원문은 ko_KR.
이 파일은 `.claude/rules/` 밖이라 매 세션 자동 로드되지 않는다 — **아래 작업을 하기 전에 먼저 읽을 것.**
(이전 진단 기록은 `.claude/i18n_audit.md`, 2026-08-14 — 대체됨)

## 이 용어집을 읽어야 하는 작업

| 작업 | 위치 | 비고 |
|---|---|---|
| 앱 UI·알림 문구 | 앱 `lib/app/core/translations/*.dart` 20개 | CLAUDE.md 규칙 8 |
| 서버 푸시·알림 문구 | 서버 `i18n/messages.py` | §6 서버↔앱 대응 — 푸시와 목록 문구는 글자까지 같게 |
| 홈페이지·FAQ·약관 | averic-lab `i18n/translations.json`, `_faq-build/copy/*.json` | averic-lab/CLAUDE.md |
| 쇼츠 영상 | averic-lab `_shorts-build`(`shorts.json`, `3d/manual.json`, `3d/upload_desc.json`), 공유 드라이브 `upload.json` 설명 | `shorts` 스킬 |
| 스토어 출시 노트 | `store-update` 스킬 | |

새 문구를 쓰거나 고칠 때: ① §1 검토 기준 ② §2 언어별 용어 ③ 숫자·복수형은 §3·§5. 용어를 바꾸면 **이 파일을 먼저 고치고** 위 위치들을 맞춘다 — 같은 용어를 여러 곳에서 따로 정하지 않는다.

## 1. 검토 기준

1. **사실 일치** — 문장이 주장하는 내용이 실제 동작과 같아야 한다. 한국어 원문이 주장하지 않은 것을 더하지 않는다.
   예: "매일 @time에 전달" ✗(정시 보장 안 됨) → "@time 무렵", "실시간 건강 상태" ✗ → "매일 안부와 걸음수".
   한국어 원문이 사실과 다르면 **원문도 고친다**(2026-10-05: 탈퇴 알림이 G+S 해제 경로에선 거짓이었다).
2. **역할 명확** — 누가 보내고 누가 받는지. 보호자에게 가는 제목이 "계정 삭제됨"처럼 본인 일로 읽히면 안 된다.
3. **비유·오독 금지** — 안부를 "신호(signal/sygnał/segnale)"로 부르지 않는다(통신 신호로 읽힘). "깊은 잠" 같은 비유 금지.
4. **법률 용어 금지** — 후견인·피후견인 뜻이 강한 단어(Betreuer, opekun, vårdnadshavare, personne protégée, 监护人, अभिभावक, الأوصياء, voogd, tutore, wali, giám hộ).
5. **건강 검진 어감 금지** — 안부를 health check로 옮기지 않는다(tr sağlık kontrolü, vi kiểm tra sức khỏe 등).
6. **"활동 기록이 감지되지 않음"을 "폰을 안 썼다"로 바꾸지 않는다** (PRD 의도적 표현).
7. **문장 조각을 이어 붙이지 않는다** — 이름·라벨은 `@name`/`@label` 자리표시자로 문장 안에 둔다.
8. **이름(@name·@alias)은 주격이고 성·격 일치가 없는 자리에만** — "@name: …" 형태. 자유 입력이라 성별·격을 알 수 없다.
9. **OS 설정 메뉴 이름**은 각 OS의 실제 현지화 표기여야 한다(PRD §9.7). 확인 근거 없이 바꾸지 않는다.
   — **2026-10-05 사용자 결정**: 안내문 속 OS 설정 메뉴 이름(권한·위치·배터리 '제한 없음'·모션 등)은 재작성 전 표기가 사용자가 과거에 직접 확인한 것이므로 **현행 유지**한다. 그 표기가 해당 언어에서 어색하지 않은 한 다시 대조하거나 바꾸지 않는다.
10. **화면 폭** — 버튼·칩·탭·배지는 짧게. `guardian_confirm_safety`는 동작형 짧은 라벨(maxLines 1).
11. 성별이 드러나는 1인칭·2인칭 동사는 피한다(pl dałeś·mógł, hi चाहता/चाहती).
12. 터키어처럼 **자리표시자 뒤에 붙는 접미사가 값에 따라 바뀌는 언어**는 "라벨: @time" 형태로.

## 2. 언어별 용어

| 로케일 | 경어 | 대상자(문장 / 라벨) | 보호자 | 안부 | 헤더(app_guardian_title) |
|---|---|---|---|---|---|
| en | — | your loved one / Loved one | guardian | wellness check | Anbu Guardian |
| ja | です・ます | 見守られる方 (본인 역할명: 見守られる側) | 見守る方 (본인 역할명: 見守る側) | 安否確認 | Anbu 見守り |
| zh_CN | 您 | 被守护者 | 守护者 | 报平安 / 平安信息 | Anbu 守护者 |
| zh_TW | 您 | 被守護者 | 守護者 | 報平安 / 平安訊息 (대만 어휘: 帳號·設定·偵測·推播·連線/連結 구분) | Anbu 守護者 |
| de | Sie | (서버 문장은 명사 생략) / Verbundene Person | Kontaktperson | Lebenszeichen (경보엔 "über Anbu") | Anbu Guardian |
| fr | vous | votre proche / Proche | aidant | nouvelles | Anbu Aidant |
| es | usted | su ser querido / Ser querido | cuidador | aviso | Anbu Cuidador |
| it | Lei | la persona cara / Persona cara | caregiver | check-in | Anbu Caregiver |
| pt_BR | você | seu ente querido / Ente querido | cuidador | check-in | Anbu Cuidador |
| nl | u | uw naaste / Naaste | contactpersoon | check-in | Anbu Guardian |
| ru | вы | подопечный | доверенное лицо | отметка | Anbu Guardian |
| pl | ty | podopieczny | opiekun | znak życia (경보엔 "aplikacja Anbu") | Anbu Opiekun |
| sv | du | din närstående / Närstående | kontaktperson | incheckning | Anbu Guardian |
| tr | siz | yakınınız / Yakın | koruyucu | haber (haber almak/vermek) | Anbu Koruyucu |
| ar | 2인칭 단수 | الشخص المحمي | المرافق | رسالة الاطمئنان | مرافق Anbu |
| hi | आप | आपके प्रियजन / प्रियजन | देखभाल करने वाले | खैरियत (की सूचना) | Anbu Guardian |
| vi | bạn | người thân của bạn / Người thân | người chăm sóc | tin bình an / báo bình an | Anbu Guardian |
| th | คุณ | ผู้ได้รับการดูแล | ผู้ดูแล | การแจ้งว่าสบายดี (마침표 없음) | ผู้ดูแล Anbu |
| id | Anda | orang tersayang Anda / Orang tersayang | pendamping | kabar | Anbu Pendamping |

ko의 `app_guardian_title`이 영문 "Anbu Guardian"인 것은 CLAUDE.md의 의도된 예외다.

### 일본어 호칭 규칙 (2026-10-07)
- **다른 사람을 가리킬 때**(보내는 사람이 보호자를 말하는 화면, 보호자끼리의 푸시 등): `見守る方` / `見守られる方`. 예: `見守る方に安否を伝えました`
- **사용자 본인의 역할명**(모드 배지·역할 선택·역할 전환 대화상자·약관의 정의어): `見守る側` / `見守られる側`. `私は見守る方`은 높임말이라 부적절하다
- G+S 라벨: `見守る側・見守られる側`. 앱 제목: `Anbu 見守り`
- 금지: `見守り人`(지자체 자원봉사자 용례), `見守り対象者`(행정 문서체). 근거는 웹 용례 + GPT 의견이며 **일본어 원어민 확인은 받지 못했다**

## 3. 코드로 조합하는 문장 규칙 (2026-10-07)

번역 값이 아니라 **코드가 조합하는 곳**의 언어별 처리다. 새로 조합 코드를 넣을 때 같은 곳을 쓴다.

| 대상 | 위치 | 규칙 |
|---|---|---|
| 천 단위 숫자 | `NumberText.format` | de·es·it·nl·pt·tr·id·vi `.` / fr·ru·pl·sv 공백 / 그 외 `,`. 서버 `i18n/messages.py` `format_number`와 같은 표. 차트 눈금도 이걸 쓴다 |
| 단수형 | `NumberText.tr(key, param, n)` | `n==1`이면 `<key>_one`. **`_one` 키가 없는 키로 부르면 키 이름이 화면에 나온다** — 키가 있는 곳에만 쓴다 |
| 아랍어 복수형 | `NumberText.trAr` | 1 `_one` / 2 `_two` / 3~10 기본 / 11~99 `_many` / 100+ `_other`. 아랍어 파일에만 키가 있다(**CLAUDE.md 규칙 8의 의도된 예외**). 컨트롤러 `_formatLastSeen`이 아랍어일 때만 이 경로를 탄다 |
| `라벨: 값` 구분자 | `labelSeparator({koSpaced})` (`core/utils/label_separator.dart`) | fr `\u00a0: `, ja·zh 전각 `：`, 그 외 `: `. 한국어는 활동량·마지막 안부 확인이 ` : `(영상 확정본), 등급 카운터는 `: ` |

확인된 사실: 폴란드어 `dn.`·`godz.`, 러시아어 `дн.`·`ч`, 이탈리아어 `h`는 표준 약어라 숫자와 무관하게 맞고, 힌디어 `1 घंटे पहले`는 후치사 때문에 oblique 형태가 맞다 — 고치지 말 것.
앱은 아랍어에서 이미 좌우 반전된다(`DefaultWidgetsLocalizations`가 RTL 처리). 빠진 것은 `flutter_localizations`(시각 선택기 등 Material 위젯 문구가 영어로 나옴)뿐이다.

## 4. 등급 라벨 (서버 푸시 제목 = 앱 notifications_level_*)

ja/zh 注意·警告·緊急, de Achtung·Warnung·Dringend, fr Attention·Alerte·Urgent, es Precaución·Alerta·Urgente,
it Attenzione·Allerta·Urgente, nl Let op·Waarschuwing·Dringend, pt Atenção·Alerta·Urgente, ru Внимание·Предупреждение·Срочно,
pl Uwaga·Ostrzeżenie·Pilne, sv Observera·Varning·Brådskande, tr Dikkat·Uyarı·Acil, ar تنبيه·تحذير·عاجل,
hi सावधानी·चेतावनी·अत्यावश्यक, vi Chú ý·Cảnh báo·Khẩn cấp, th ข้อควรระวัง·คำเตือน·เร่งด่วน, id Perhatian·Peringatan·Mendesak

## 5. 숫자

- 천 단위: `,` en ja zh ko th hi ar / `.` de es it nl pt tr id vi / U+00A0 fr ru pl sv
  — 서버 `i18n/messages.py`의 `format_number`, 앱 `lib/app/core/utils/number_text.dart` **두 곳이 같은 표**.
- `%` 앞 공백(U+00A0): de fr es ru sv. tr은 `%20`.
- 1일 때 단수형: 서버 `noti_steps_body_one`(해당 언어만), 앱 `<키>_one`(**20개 언어 모두 필수** — 없으면 GetX가 영어를 꺼냄).
  앱 대상 키: `noti_steps_body`, `guardian_last_check_days`, `guardian_checking_subjects`.
- ru·pl은 숫자에 따라 격이 3가지 이상 → "라벨: 숫자" 문장. 분·시간·일은 표준 약어(мин/ч/дн., min/godz./dn.)라 숫자와 무관하게 맞다.
- ar는 약어가 아니라 복수형 키(`_one/_two/_many/_other`)를 쓴다 — §3의 `NumberText.trAr`.
- 앱·서버 코드에서 이 숫자들을 조합하는 방법은 §3.
- 서버 `days`(긴급 일수)는 항상 ≥3.

## 6. 서버 ↔ 앱 대응 (같은 알림을 푸시와 목록에서 두 번 보여준다 — 글자까지 같게)

`push_*_body` ↔ `noti_*_body`(caution_suspicious·caution_missing·warning·warning_suspicious·urgent·urgent_suspicious·
manual_report·auto_report·battery_low·emergency), `push_alert_cleared_body` ↔ `noti_cleared_by_guardian_body`,
`noti_steps_body` ↔ `noti_steps_body`, `push_caution/warning/urgent_title` ↔ `notifications_level_*`.
`{x}`↔`@x`. 검사 스크립트는 재검수 세션 scratchpad의 `check_lang.py` 방식(쌍 비교 + 폐기 용어 grep).

## 7. 다른 곳에 있는 번역

- iOS 권한 팝업: `ios/Runner/{lang}.lproj/InfoPlist.strings` (2026-10-05 함께 재검수)
- 번역 캐시 부재 시 영어 대체 문구: `local_alarm_service.dart`, `HeartbeatStore.swift`, `NotificationService.swift`
- 홈페이지: averic-lab `_faq-build`(앱 키 101개 + `copy/*.json` 원고), `i18n/translations.json`
- 쇼츠: averic-lab `_shorts-build/gen.py` — 서버 `push_auto_report_title`·`push_emergency_title`, 앱 `APP_KEYS`

## 8. 검색 근거 (2026-10-05)

- en: Snug·AssureOkay·CheckIn More — check-in / loved one. AssureOkay가 "daily wellness check"도 씀 → wellness check 유지
- de: Still OK·leb — Lebenszeichen, Kontaktperson/Vertrauensperson. Betreuer는 BGB 법정 보호 용어
- fr: Dooinwell — check-in quotidien, proches / es: Estoy bien — aviso diario / pt-BR: Tô Bem·Guardião Sênior — check-in
- it: Dooinwell IT — check-in quotidiano / nl: Stiltemelder — dagelijkse check-in, Leefsignaal — naaste
- sv: Caretaker SV — incheckning, anhöriga / ru: Я_ОК — отметка «я в порядке», доверенное лицо
- pl: Żyję — znak życia / zh: 在么在么·好着呢 — 签到·报平安 / ja: 見守りアプリ 기사 — 見守る側·安否確認
- tr: "hal hatır"는 관용구(sormak)뿐, 앱 명사 사례 없음 → haber / ar: 기사·앱 설명 "الاطمئنان", "طمّنا عليك"는 구어·주체 모호
- th: "สบายดี" 상태 기록, ผู้ดูแล / vi: người thân, xác nhận an toàn / hi: 매체 "खैर खबर/हालचाल"(खैरियत 계열)
- ja(2026-10-07 교체): 見守る方/見守る側 — 웹 용례 + GPT 의견. 일본어 원어민 확인은 받지 못했다(§2 일본어 호칭 규칙).
