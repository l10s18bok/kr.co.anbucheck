# 번역 용어집 — 서버·앱·홈페이지·쇼츠 공통 기준

2026-10-05 전면 재검수 때 확정. 원문은 ko_KR. 이 파일은 `.claude/rules/` 밖이라 매 세션 자동 로드되지 않는다 —
번역을 새로 쓰거나 고칠 때 먼저 읽을 것. (이전 진단 기록은 `.claude/i18n_audit.md`, 2026-08-14)

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
| ja | です・ます | 見守り対象者 | 見守り人 | 安否確認 | Anbu 見守り人 |
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

## 3. 등급 라벨 (서버 푸시 제목 = 앱 notifications_level_*)

ja/zh 注意·警告·緊急, de Achtung·Warnung·Dringend, fr Attention·Alerte·Urgent, es Precaución·Alerta·Urgente,
it Attenzione·Allerta·Urgente, nl Let op·Waarschuwing·Dringend, pt Atenção·Alerta·Urgente, ru Внимание·Предупреждение·Срочно,
pl Uwaga·Ostrzeżenie·Pilne, sv Observera·Varning·Brådskande, tr Dikkat·Uyarı·Acil, ar تنبيه·تحذير·عاجل,
hi सावधानी·चेतावनी·अत्यावश्यक, vi Chú ý·Cảnh báo·Khẩn cấp, th ข้อควรระวัง·คำเตือน·เร่งด่วน, id Perhatian·Peringatan·Mendesak

## 4. 숫자

- 천 단위: `,` en ja zh ko th hi ar / `.` de es it nl pt tr id vi / U+00A0 fr ru pl sv
  — 서버 `i18n/messages.py`의 `format_number`, 앱 `lib/app/core/utils/number_text.dart` **두 곳이 같은 표**.
- `%` 앞 공백(U+00A0): de fr es ru sv. tr은 `%20`.
- 1일 때 단수형: 서버 `noti_steps_body_one`(해당 언어만), 앱 `<키>_one`(**20개 언어 모두 필수** — 없으면 GetX가 영어를 꺼냄).
  앱 대상 키: `noti_steps_body`, `guardian_last_check_days`, `guardian_checking_subjects`.
- ru·pl·ar은 숫자에 따라 격이 3가지 이상 → "라벨: 숫자" 문장. 분·시간은 약어(мин/ч, min/godz., د/س/ي).
- 서버 `days`(긴급 일수)는 항상 ≥3.

## 5. 서버 ↔ 앱 대응 (같은 알림을 푸시와 목록에서 두 번 보여준다 — 글자까지 같게)

`push_*_body` ↔ `noti_*_body`(caution_suspicious·caution_missing·warning·warning_suspicious·urgent·urgent_suspicious·
manual_report·auto_report·battery_low·emergency), `push_alert_cleared_body` ↔ `noti_cleared_by_guardian_body`,
`noti_steps_body` ↔ `noti_steps_body`, `push_caution/warning/urgent_title` ↔ `notifications_level_*`.
`{x}`↔`@x`. 검사 스크립트는 재검수 세션 scratchpad의 `check_lang.py` 방식(쌍 비교 + 폐기 용어 grep).

## 6. 다른 곳에 있는 번역

- iOS 권한 팝업: `ios/Runner/{lang}.lproj/InfoPlist.strings` (2026-10-05 함께 재검수)
- 번역 캐시 부재 시 영어 대체 문구: `local_alarm_service.dart`, `HeartbeatStore.swift`, `NotificationService.swift`
- 홈페이지: averic-lab `_faq-build`(앱 키 101개 + `copy/*.json` 원고), `i18n/translations.json`
- 쇼츠: averic-lab `_shorts-build/gen.py` — 서버 `push_auto_report_title`·`push_emergency_title`, 앱 `APP_KEYS`

## 7. 검색 근거 (2026-10-05)

- en: Snug·AssureOkay·CheckIn More — check-in / loved one. AssureOkay가 "daily wellness check"도 씀 → wellness check 유지
- de: Still OK·leb — Lebenszeichen, Kontaktperson/Vertrauensperson. Betreuer는 BGB 법정 보호 용어
- fr: Dooinwell — check-in quotidien, proches / es: Estoy bien — aviso diario / pt-BR: Tô Bem·Guardião Sênior — check-in
- it: Dooinwell IT — check-in quotidiano / nl: Stiltemelder — dagelijkse check-in, Leefsignaal — naaste
- sv: Caretaker SV — incheckning, anhöriga / ru: Я_ОК — отметка «я в порядке», доверенное лицо
- pl: Żyję — znak życia / zh: 在么在么·好着呢 — 签到·报平安 / ja: 見守りアプリ 기사 — 見守る側·安否確認
- tr: "hal hatır"는 관용구(sormak)뿐, 앱 명사 사례 없음 → haber / ar: 기사·앱 설명 "الاطمئنان", "طمّنا عليك"는 구어·주체 모호
- th: "สบายดี" 상태 기록, ผู้ดูแล / vi: người thân, xác nhận an toàn / hi: 매체 "खैर खबर/हालचाल"(खैरियत 계열)
