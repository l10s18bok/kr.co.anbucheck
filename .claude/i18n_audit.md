# 앱 번역 전수 조사 (2026-08-14)

대상: `lib/app/core/translations/` 20개 언어 × 364키
제약: 키 이름 변경·삭제 금지 / 새 `@placeholder` 추가 금지 / `dart format` 금지

## 0. 기계적 검사 결과

- 키 파리티: **20개 언어 전부 364키 일치** (누락·추가 없음) ✅
- 플레이스홀더(`@version` 등) 무결성: **전 언어 일치** ✅
- 비-한국어 파일의 한글 잔존: **없음** ✅
- 브랜드 규칙(한국어만 "안부", 나머지 "Anbu"): **준수** ✅
- 발견된 기계적 결함:
  - **폴란드어** `common_pm` = `po poludniu` → `po południu` (ł 누락). `common_time_style=h24`라 현재 화면에 노출되지 않지만 오탈자.
  - DND 기본값 표기 폭 불일치: 폴란드어/태국어/베트남어만 `7:00`, 나머지 h24 언어는 `07:00`.

---

## 1. 일본어 (ja_JP)

### A급 — 용어 혼용 (같은 개념이 한 앱 안에서 2~4가지로)

| 키 | 현재 | 문제 |
|---|---|---|
| 보호자 = `見守り人` vs `保護者` 혼용 | `subject_home_report_desc`(見守り人) / `subject_home_emergency_desc`(保護者) | **같은 화면의 두 버튼 설명이 서로 다른 단어**. `見守り人`은 앱 전용 조어 느낌, `保護者`는 미성년 보호자 뉘앙스. 하나로 통일 필요 |
| 〃 | `onboarding_role_guardian`(見守り人) vs `onboarding_role_guardian_subject`(保護者兼対象者) | 같은 다이얼로그 안 역할 라벨이 불일치 |
| 구독 = `サブスクリプション` / `定期購入` / `購読` / `登録` 4중 혼용 | `guardian_subscribe`(サブスクリプション登録), `subscription_subscribe`(登録する), `trial_ended_noti_body`(定期購入), `subscription_purchase_success`(購読を開始) | **`購読`은 신문·잡지 구독**을 뜻해 앱 인앱 구독에 부자연스러움(원어민 위화감). Apple/Google 일본 스토어 표기는 「サブスクリプション」 |

### B급 — 어색한 표현

| 키 | 현재 | 문제 |
|---|---|---|
| `noti_steps_body` | `本日@steps歩歩きました。` | **「歩歩」가 연달아 붙어** 읽기 불편. `本日は@steps歩、歩きました。` 또는 `本日の歩数は@steps歩です。` |
| `subject_home_emergency_confirm_title` | `緊急ヘルプリクエスト` | 카타카나 혼종. 같은 파일 `permission_location_desc`는 `緊急ヘルプ要請`을 쓰고 있어 자체 불일치 |
| `gs_enable_dialog_ios_confirm` | `理解しました、有効化` | 직역투. 「同意して有効化」가 자연스러움 |
| `noti_resolved_body` | `正常に復帰しました。…安否が正常に確認されました。` | 한 문장에 `正常に` 2회 반복 |

### C급 — 사소

| 키 | 현재 | 문제 |
|---|---|---|
| `subject_home_check_body_*` | `@time 正常に報告済み` / `@time に報告予定` / `@time 報告待ち` | 조사 `に` 유무가 3개 키에서 제각각 |
| `permission_hibernation_title` | `自動的な権限の削除` | Android 일본어 실제 설정 명칭과 다를 가능성 — **검색 확인 필요** |

---

## 2. 중국어 간체 (zh_CN) / 번체 (zh_TW) — **가장 심각**

두 파일이 동일한 문제를 공유한다(번체는 간체를 변환한 것으로 보임).

### S급 — 중국어에 없는 단어 사용 (원어민이 이해 못 함)

| 문제 | 위치 | 설명 |
|---|---|---|
| **`安否`** (간체 16곳 / 번체 14곳) | `local_alarm_title`(💗 需要确认安否), `wellbeing_check_title`(💛 安否确认), `onboarding_notifications_title/desc`, `gs_enable_dialog_ios_warning_*`, `gs_enabled_message`(安否保护), `heartbeat_schedule_hint_ios`, `notifications_activity_note` 등 | **`安否`는 한국어·일본어 한자어이며 현대 중국어에 존재하지 않는다.** 중국어 사용자는 뜻을 유추하지 못한다. 특히 **로컬 알림 제목**에 쓰여 매일 화면에 노출됨 |
| **`对象者` / `對象者`** | `noti_manual_report_body` | 일본어 `対象者`를 그대로 옮긴 것. 중국어 아님 |
| **`安康信号` / `安康訊號`** | `permission_hibernation_message`, `stability_battery_dialog_message`, `s_to_gs_dialog_body` | `安康`은 "건강하시길"이라는 **축원어**라 "신호"와 결합하면 의미 불명 |

### A급 — 용어 혼용

| 개념 | 혼용된 표현 | 예시 |
|---|---|---|
| 보호자 | `守护者` vs `监护人` | `subject_home_report_desc`(守护者) vs `subject_home_emergency_desc`(监护人) — **같은 화면 두 버튼**. `onboarding_role_guardian`(守护者) vs `onboarding_role_guardian_subject`(监护人兼被监护人) — 같은 다이얼로그. `监护人`은 법적 후견인 뉘앙스 |
| 대상자 | `被守护者` / `被监护人` / `被守护人` / `对象者` / `保护对象` / `对象` | `noti_emergency_body`(被监护人), `noti_cleared_by_guardian_body`(被守护人), `connection_empty`(保护对象), `emergency_map_subject_label`(对象) |
| 안부 | `平安` / `安好` / `安康` / `问安` / `安否` | `app_tagline`(平安), `mode_subject_button`(传递安好), `drawer_enable_guardian`(管理家人的安康), `app_service_desc`(自动问安服务) — 5중 혼용 |
| 안전 코드 | `安全码` / `专属码` / `连接码` / `邀请码` | `subject_home_code_copied`(邀请码已复制)인데 화면 표시는 `安全码` → **사용자가 다른 것으로 오해** |

### B급 — 오역·조판

| 키 | 현재 | 문제 |
|---|---|---|
| `noti_resolved_body` (간체) | `被监护人的健康状况已正常确认` | 원문은 "안부 확인"인데 **"건강 상태 확인"으로 오역** — 의료 판정 뉘앙스. 번체는 `安全狀況`으로 달라 두 파일 간 불일치 |
| `permission_hibernation_message`, `stability_battery_dialog_message`, `location_permission_settings_body_*` | `Anbu平时几乎不会被打开,如果...` | **반각 쉼표 `,` 사용** — 중국어 조판은 전각 `，`. 여러 문장에 걸쳐 있음 |

---

## 3. **최우선** — 발음부호(diacritics) 통째 누락 : 베트남어 / 폴란드어 / 스웨덴어

번역문 상당수가 발음부호 없는 ASCII로 작성돼 있다. 오타 수준이 아니라 **해당 언어 표기법 위반**이며, 원어민에게는 "글자가 깨진 앱"으로 보인다. 나머지 17개 언어는 정상(터키어·독일어·프랑스어·스페인어·포르투갈어·이탈리아어·네덜란드어 모두 검사 결과 이상 없음).

| 언어 | 손상 항목 수 | 예시 (현재 → 올바른 표기) |
|---|---|---|
| **베트남어** | **148 / 364** | `Kiem tra suc khoe cua ban.` → `Kiểm tra sức khỏe của bạn.`<br>`Nguoi bao ve da ket noi` → `Người bảo vệ đã kết nối`<br>`Chia se ma an toan cua ban` → `Chia sẻ mã an toàn của bạn` |
| **폴란드어** | **153 / 364** | `Polaczeni opiekunowie` → `Połączeni opiekunowie`<br>`Potwierdz bezpieczenstwo` → `Potwierdź bezpieczeństwo`<br>`Mozesz zarejestrowac maksymalnie @max osob` → `Możesz zarejestrować maksymalnie @max osób`<br>`Polityka prywatnosci` → `Polityka prywatności` |
| **스웨덴어** | **159 / 364** | `valmaende` → `välmående` (19곳 이상, `ä→a`·`å→aa` 치환)<br>`Kontrollerar ditt valmaende.` → `Kontrollerar ditt välmående.`<br>`Behorigheter kravs for att anvanda appen` → `Behörigheter krävs för att använda appen` |

> 베트남어는 성조 부호가 없으면 단어 식별 자체가 불가능해 **가장 시급**하다.
> `common_pm`의 폴란드어 `po poludniu` 오탈자도 이 문제의 일부다.

### 참고 — 복수형 처리 (전 언어 교차 검사)

- 러시아어·폴란드어·아랍어는 수사에 따라 명사 형태가 3~4가지로 변하지만, 현재는 단일 형태만 쓴다.
  - 러시아어 `noti_urgent_body`: `Нет проверки самочувствия @days дн.` — 축약 `дн.`로 회피 (문법 오류는 아니나 딱딱함)
  - 폴란드어 `guardian_checking_subjects`: `@count podopiecznego(-ych)` — 괄호 회피
  - 아랍어 `guardian_checking_subjects`: `@count شخص/أشخاص` — 슬래시 회피
- 힌디어 `noti_urgent_body`: `@days दिनों से` — `दिनों`은 복수형이라 **@days=1일 때 문법 오류**
- 유럽어권은 `day(s)` / `Tag(en)` / `día(s)` 식 괄호 표기로 통일 — 오류는 아니나 알림 문구로는 투박함
- GetX는 복수형 분기를 지원하지 않으므로(플레이스홀더 추가도 금지) **현행 회피 표기를 유지하는 것이 현실적**. 힌디어만 단복수 무관한 형태로 조정 권장

---

## 4. 서버 번역과의 대조 — **앱만 미수정 상태**

`anbucheck-server/i18n/messages.py` 상단에 이미 다음 경고가 있다:

> ⚠️ **발음 부호(diacritic)를 제거하지 말 것.** 과거 라틴 문자권 문자열이 ASCII로 치환되어 있었는데, 이는 관례가 아니라 손상이었다 … 스웨덴어는 ö→oe와 ö→o를 혼용했다.

즉 **서버는 이미 수정됐고 앱은 그대로 남아 있다.** 서버는 20개 로케일 전부를 커버하며, 앱의 알림 문구 16개 키와 1:1로 대응한다.

| 항목 | 서버(수정됨) | 앱(미수정) |
|---|---|---|
| 스웨덴어 `noti_battery_low_body` | `Telefonens batteri är under 20%. Laddning kan behövas.` | `Telefonens batteri ar under 20%. Laddning kan behovas.` |
| 스웨덴어 `noti_caution_suspicious_body` | `En välmåendesignal mottogs…` | `En valmaendesignal mottogs…` |

→ **앱의 `noti_*` 16개 키는 서버 문구를 그대로 가져오면 된다**(플레이스홀더만 `{days}` → `@days`로 변환). 새로 번역할 필요 없음.

- 앱 vs 서버 문구 불일치: 로케일당 8~14건 (한국어 6건은 의도된 차이 — 앱 카드에는 대상자 이름이 이미 표시되므로 "보호 대상자의"를 생략)

---

## 5. 용어 혼용 — 전 언어 기계 검사 결과

`onboarding_role_guardian`(보호자) vs `onboarding_role_guardian_subject`(보호자 겸 대상자), `subject_home_report_desc` vs `subject_home_emergency_desc`(같은 화면 두 버튼)를 교차 비교.

| 언어 | 상태 | 내용 |
|---|---|---|
| 러시아어·독일어·포르투갈어·터키어·힌디어 | ✅ 일관 | (힌디어는 `emergency_map_subject_label`만 `देखभाल प्राप्तकर्ता`로 예외) |
| **스페인어** | ❌ | `Protector` vs `Guardián` — 같은 화면 두 버튼이 다른 단어 |
| **프랑스어** | ❌ | `Protecteur` vs `Gardien`. 또 `emergency_map_subject_label`만 `Personne surveillée`(감시받는 사람 — **부정적 뉘앙스**), 나머지는 `Personne protégée` |
| **이탈리아어** | ❌ | `Guardiano` vs `tutori` |
| **네덜란드어** | ❌ | `Beschermer` vs `Bewaker`(경비원 뉘앙스) |
| **아랍어** | ❌ | `حارس`(경비원) vs `وصي`(법적 후견인). 대상자도 `متابَع`/`الشخص المستفيد`/`الشخص المحمي` 3중 |
| **태국어** | ❌ | 대상자가 `ผู้อยู่ในการดูแล`/`ผู้ได้รับการดูแล`/`ผู้ถูกดูแล` 3중. **`ผู้ถูกดูแล`의 `ถูก`은 태국어에서 나쁜 일을 당할 때 쓰는 수동 표지**라 "돌봄을 당하는 사람"으로 읽힘 (검색 검증 완료). `ผู้ได้รับการดูแล`로 통일 필요. `app_guardian_title`만 `ผู้ปกป้อง` |

---

## 6. 존칭(경어) 혼용 — 온보딩 화면만 반말

고령 사용자 대상 앱인데 **온보딩 스텝만 반말**로 작성돼 앱 안에서 말투가 바뀐다.

| 언어 | 앱 전반 | 온보딩 |
|---|---|---|
| **독일어** | `Sie/Ihre` 60+회 (존칭) | `du/dein/Tippe` — `onboarding_emergency_title`, `onboarding_gs_switch_desc`, `onboarding_notifications_desc`, `onboarding_gs_enable_title/desc` 6곳 |
| **이탈리아어** | `Suo/Verifichi/Prema` (Lei 존칭) | `tuo/tuoi/tocca` 30회 — 온보딩 외 `stability_battery_dialog_message`까지 침범 |
| **스페인어** | `su/Haga/Toque/Introduzca` (usted) | `tu/tus/Toca/Suscríbete/Activa` 20회 |
| 프랑스어 | `vous/votre/vos` 일관 ✅ | — |

---

## 7. 시각 표기 자체 불일치

`common_time_style`이 `h24`인데 DND 기본값만 12시간제 문자열인 언어가 있다 → 같은 화면에서 두 형식이 섞임.

| 언어 | time_style | DND 기본값 | 문제 |
|---|---|---|---|
| **힌디어** | `h24` (→ `22:00` 렌더링) | `रात 10:00` / `सुबह 7:00` | 형식 불일치. 인도는 12시간제가 일반적이라 `pre12` 전환도 검토 대상 |
| 중국어 간체/번체 | `pre12` (→ `下午 10:00`) | `晚上 10:00` / `早上 7:00` | `common_pm`(下午)과 DND(晚上)가 다른 단어 |
| 일본어·한국어 | 일관 ✅ | | 손대지 말 것 |

---

## 8. 검토 범위 (정직한 명시)

- **전문 정독**: 한국어, 영어, 일본어, 중국어 간체 (4개)
- **부분 정독 + 기계 검사**: 중국어 번체, 스웨덴어, 이탈리아어, 독일어, 프랑스어, 스페인어 (6개)
- **기계 검사만** (키 파리티·플레이스홀더·발음부호·용어 드리프트·존칭·복수형·서버 대조): 나머지 10개
- 기계 검사는 위 7개 결함 유형을 전 언어에 동일하게 적용했으나, **개별 문장의 자연스러움까지 20개 언어 전부를 원어민 수준으로 확인하지는 못했다.**

---

# 【전문 정독】 언어별 상세

## 독일어 (de_DE)

### S급

| 키 | 현재 | 문제 |
|---|---|---|
| `app_guardian_title` / `onboarding_role_subject` | 둘 다 `Schutzperson` | **같은 단어가 보호자 타이틀과 대상자 역할명 양쪽에 쓰임.** `Anbu Schutzperson`은 보호자 화면 타이틀인데 대상자를 뜻하는 단어. 독일어 `Schutzperson`은 일반인에겐 "보호하는 사람"으로도 읽혀 방향이 반대로 전달될 수 있음 |
| `subject_home_manual_report_sent` | `Ihre Nachricht wurde an Ihre Kontaktpersonen gesendet.` | **오역**. "당신의 **메시지**가 **연락처**로 전송됨" — 원문은 "보호자에게 안부를 전했습니다". `Nachricht`(메시지)도 틀리고 `Kontaktpersonen`은 앱 용어 `Betreuer`와 불일치 |
| `Wellness-*` 계열 (10곳 이상) | `Wellness-Signal`, `Wellness-Check`, `Wellness-Schutz`, `Wellness-Push-Benachrichtigung` | **독일어에서 `Wellness`는 스파·사우나·미용 리조트를 뜻한다.** 안부 확인·안전 모니터링 맥락에 쓰면 원어민에게 전혀 다른 영역으로 읽힘 |

### A급 — "안부" 명사가 6중 혼용

같은 기능을 사용자가 6개 다른 이름으로 만난다:
`Wohlbefindens-Check/Signal` (다수) · `Wellness-Signal/Check` (온보딩·G+S) · `Lebenszeichen` (모드 선택 4곳, 구독 만료) · `Statusmeldung` (`safety_net_dialog_*` 3곳) · `Sicherheitssignal` (`notifications_activity_note`) · `Sicherheitsbericht` (`subject_home_manual_report_limit_reached`)

대상자도 4중: `Schutzperson` / `Schützling` / `betreute Person` / `zu betreuende Person`(`add_subject_error_self`)

`safety_net_dialog_*` 3곳은 보호자를 `Kontaktperson`으로 부름 — 앱 전체는 `Betreuer`

### B급
- 온보딩 6곳만 반말(`du`/`Tippe`), 나머지 전체는 존칭(`Sie`) — 화면 이동 시 말투가 바뀜
- `guardian_today_summary`: `Heutige Zusammenfassung` — "무엇의" 요약인지 빠짐(원문은 "오늘의 안부 요약")

## 프랑스어 (fr_FR)

### S급

| 키 | 현재 | 문제 |
|---|---|---|
| `guardian_chart_today` | **`Today`** | **영어가 그대로 남아 있음.** 걸음수 차트 축 라벨에 노출. → `Aujourd'hui` |
| `noti_resolved_body` | `Le **bilan de santé** du protégé est revenu à la normale.` | **`bilan de santé`는 "건강검진·건강진단서"**(의료 검사 결과)를 뜻함. 안부 확인이 아님 |
| `gs_enable_dialog_ios_warning_title` | `Comment votre **bilan de santé** est envoyé` | 같은 오역. 게다가 **같은 다이얼로그 본문은 `bien-être`를 씀** — 제목과 본문이 다른 개념 |
| `subject_home_manual_report_sent` | `Votre **message** a été envoyé à vos **proches**.` | 독일어와 동일한 오역. "메시지가 지인에게 전송됨" — 원문은 "보호자에게 안부를 전했습니다" |
| `notification_settings_warning` | **`Alertes d'alerte`** | "경고의 경고" — 같은 단어가 겹친 중복 표현. `guardian_status_warning`이 `Alerte`라서 발생 |

### A급 — 용어 혼용

- **보호자 3중**: `Protecteur`(주) / `Gardien`(`onboarding_role_guardian_subject`, `gs_enable_dialog_body`, `subject_home_emergency_confirm_body`, `gs_disable_dialog_body`) / `proche(s)`(`permission_location_desc`, `safety_net_dialog_*`, `stability_battery_dialog_message`)
  → `safety_net_dialog_body`는 "votre proche"(당신의 지인), 같은 앱 다른 화면은 "protecteur"
- **대상자 4중**: `Personne protégée`(주) / `protégé` / **`Personne surveillée`**(`emergency_map_subject_label` — "**감시받는** 사람", 부정적 뉘앙스) / `personne à suivre`(`add_subject_error_self`)
- **확인 동작 2중**: `vérification`(다수) vs `confirmation`(`heartbeat_schedule_change`, `heartbeat_schedule_title_ios`)

### B급

| 키 | 현재 | 문제 |
|---|---|---|
| `guardian_status_normal` / `_confirmed` | `Sûr` / `✅ Sûr` | 사람 상태 배지로 `sûr`는 "확실한"으로도 읽혀 모호. `Tout va bien` 등이 자연스러움 |
| `mode_subject_badge` | `Sénior` | 프랑스어 표준 표기는 악센트 없는 `senior` — **검색 확인 필요** |
| `guardian_today_summary` | `Résumé du jour` | "무엇의" 요약인지 빠짐(원문 "오늘의 안부 요약") — 독일어와 동일 |

> 참고: `20 %`처럼 % 앞 공백은 프랑스어 조판 규칙상 **정상**. 존칭도 `vous` 일관 ✅

## 스페인어 (es_ES)

### S급

| 키 | 현재 | 문제 |
|---|---|---|
| `subject_home_manual_report_sent` | `Tu **mensaje** ha sido enviado a tus **contactos**.` | 독일어·프랑스어와 **동일한 오역**("메시지가 연락처로 전송됨"). 3개 언어에 같은 오역이 있는 것으로 보아 공통 초안이 잘못된 듯 |
| `notification_settings_warning` | `Alertas de alerta` | 프랑스어와 동일한 "경고의 경고" 중복 표현 |

### A급 — 존칭이 **같은 화면 안에서** 뒤섞임 (가장 심각)

| 화면 | usted(존칭) | tú(반말) |
|---|---|---|
| 대상자 홈 | `Comparta su código`, `Haga saber a su protector` | `Ya has enviado…`, `Tu mensaje…`, `tu cuidador` |
| 대상자 추가 | `Introduzca el código único y un apodo.` | **바로 아래 필드**: `Si lo indicas, el botón de llamada…` |
| G+S | `Toque aquí para permitir` | `compártelo con otros guardianes` |
| 모드 선택 | — | `¿Cómo quieres empezar?`, `Dinos…` |

→ 고령 사용자 대상 앱에서 **한 화면 안에서 말을 놓았다 높였다** 하는 상태.

### A급 — 용어 혼용

- **보호자 4중**: `Protector`(주) / `Guardián`(`subject_home_emergency_desc`, `gs_enable_dialog_body` 등) / `cuidador`(`safety_net_dialog_*`, `subject_home_emergency_confirm_body`) / `contactos`(`subject_home_manual_report_sent`)
  → `subject_home_report_desc`(su protector) vs `subject_home_emergency_desc`(sus guardianes) — **같은 화면 두 버튼**
- **대상자 4중**: `Persona protegida` / `protegido` / `persona a cuidar`(`add_subject_error_self`) / `ser querido`(`add_subject_guide_subtitle`)

> `20 %`의 공백, `Sénior`의 악센트는 스페인어(RAE) 기준 **정상**

## 이탈리아어 (it_IT) — 존칭 혼용이 20개 언어 중 가장 심함

### S급

| 키 | 현재 | 문제 |
|---|---|---|
| `subject_home_manual_report_sent` | `Il tuo **messaggio** è stato inviato ai tuoi **contatti**.` | 독·프·스페인어와 동일 오역 (4번째 언어) |
| `notification_settings_warning` | `Avvisi di avviso` | "경고의 경고" 중복 (프랑스어·스페인어와 동일) |

### S급 — Lei(존칭) / tu(반말)가 한 화면 안에서 뒤섞임

**대상자 홈 화면 한 곳**에서:
- `subject_home_share_title`: `Condivida il **Suo** codice` (Lei)
- `subject_home_report_desc`: `**Faccia** sapere al **Suo** guardiano` (Lei)
- `subject_home_emergency_desc`: `ai **tuoi** tutori` (tu)
- `subject_home_manual_report_limit_reached`: `**Hai** già inviato… **Riprova**` (tu)
- `safety_net_dialog_body`: `al **tuo** familiare` (tu)

**대상자 추가 화면**에서도: `Inserisca il codice…`(Lei) 바로 아래 `…dovrai scegliere il contatto`(tu)

알림 본문은 Lei(`Verifichi di persona`), 온보딩은 전부 tu(`Condividi`, `Tocca`). 이탈리아어에서 이 혼용은 원어민에게 매우 부자연스럽다.

### A급 — 용어 혼용

- **보호자 3중**: `Guardiano`(주) / `tutore·tutori`(`permission_location_desc`, `subject_home_emergency_desc`, `noti_cleared_by_guardian_body`) / **`familiare`**(`safety_net_dialog_*` — "가족". 보호자가 가족이 아닐 수 있음)
- **대상자 4중**: `Assistito`(주) / `protetto` / `persona protetta` / `persona assistita`
- `guardian_status_normal`: `Sicuro` — 이탈리아어 `sicuro`는 "확실한"의 뜻이 강해 상태 배지로 모호(프랑스어 `Sûr`, 스페인어 `Seguro`와 같은 문제)

## 네덜란드어 (nl_NL) — 보호자 호칭 6중 혼용, 20개 언어 중 최다

### S급

| 키 | 현재 | 문제 |
|---|---|---|
| `subject_home_emergency_confirm_body` | `naar alle **voogden**` | **`voogd`는 미성년자 법적 후견인**을 뜻함. 이 앱 문맥에 부적절하며 이 키에만 유일하게 등장 |
| `emergency_map_subject_label` | **`Hulpbehoevende`** | "도움이 필요한 사람" — 낙인 뉘앙스. 다른 곳은 전부 `beschermeling` |
| `subject_home_manual_report_sent` | `Uw **bericht** is verzonden naar uw **contacten**.` | 독·프·스·이와 동일 오역 (5번째 언어) |

### A급 — 보호자 호칭 6가지

`Beschermer`(주) / `Bewaker`(경비원 — `gs_*` 4곳) / `verzorger`(요양보호사 — `stability_battery_dialog_message`) / `begeleider`(인솔자 — `safety_net_dialog_*`) / `voogd`(법적 후견인) / `contacten`

대상자도 5가지: `beschermeling` / `beschermde` / `beschermde persoon` / `zorgontvanger` / `Hulpbehoevende`

### A급 — u(존칭) / je(반말) 혼용

- `mode_select_title`: `Hoe wil **je** beginnen?` ↔ 바로 아래 `mode_select_notice`: `op basis van **uw** keuze` — **같은 화면**
- `error_network`: `Controleer **uw** netwerkverbinding` ↔ `notification_send_failed_title`: `Controleer **je** internetverbinding` — 같은 뜻의 두 문구가 다른 인칭
- 온보딩·`stability_battery_dialog_message`·`add_subject_phone_info`는 je, 홈·설정·알림은 u

## 포르투갈어 (pt_BR) — 상대적으로 양호

존칭(`você`) 일관, 발음부호 정상, 조판 정상. 문제는 용어 혼용에 국한.

| 구분 | 내용 |
|---|---|
| **S급** | `subject_home_manual_report_sent`: `Sua **mensagem** foi enviada aos seus **contatos**.` — 6번째 동일 오역 |
| **A급** | 보호자 5중: `Guardião`(주) / `protetor`(`permission_location_desc`, `noti_cleared_by_guardian_body`) / `cuidador`(`stability_battery_dialog_message`) / `responsável`(`safety_net_dialog_*`) / `contatos` |
| | 대상자 3중: `protegido` / `pessoa protegida` / `pessoa monitorada`(`add_subject_error_self`) |
| **B급** | `guardian_status_warning`(`Alerta`) vs `notification_settings_warning`(`Alertas de aviso`) — 등급명 불일치 |
| | `heartbeat_schedule_*`만 `confirmação`, 나머지는 `verificação` |

## 스웨덴어 (sv_SE) — 손상과 정상 표기가 한 파일 안에 뒤섞임

### S급 — 발음부호 누락이 **다른 뜻의 실제 단어**를 만듦

| 키 | 현재 | 문제 |
|---|---|---|
| `guardian_status_normal` / `_confirmed` | **`Saker`** / `✅ Saker` | `Säker`(안전한)에서 부호가 빠져 **`saker`= "물건들"**(sak의 복수형)이라는 실제 단어가 됨. 대시보드 상태 배지에 "물건들"이 표시되는 셈 |
| `settings_notification`, `notification_settings_title`, `notification_settings_level_section` | `Aviseringsinstellningar`, `Nivainstellningar` | 부호 누락이 아니라 **철자 오류**(`inställningar` → `instellningar`, e가 잘못 들어감) |
| `subject_home_manual_report_sent` | `Ditt **meddelande** har skickats till dina **kontakter**.` | 7번째 동일 오역 |

### S급 — 같은 단어가 한 파일에서 두 표기로

| 정상 | 손상 | 위치 |
|---|---|---|
| `Vårdare` (`mode_guardian_badge`) | `Vardare` (`onboarding_role_guardian`) | **같은 역할명** |
| `Välmåendekontroll` (`local_alarm_title`) | `Valmaendekontrollen` (`noti_auto_report_body`) | 같은 개념 |
| `säkerhetskod` (`gs_safety_code_title`) | `sakerhetskod` (`subject_home_share_title`) | 같은 개념 |
| `Fortsätt`, `Behöver`, `Gå till Inställningar` | `Bekrafta`, `Stang`, `Ga till Installningar` | 파일 전반 |

### A급 — 용어 혼용

- **보호자 5중**: `Vårdare`(주) / `vårdgivare`(의료 제공자 — `subject_home_emergency_desc` 등) / `anhörig`(친척 — `safety_net_dialog_*`, `permission_location_desc`) / **`vårdnadshavare`(미성년 법적 보호자 — `noti_cleared_by_guardian_body`)** / `kontakter`
- **대상자 5중**: `Skyddsperson` / `skyddad` / `Skyddad person` / `Den skyddade personen` / `person att bevaka`
- **안부 명사 5중**: `välmående`(주) / `hälso-`("건강" — `gs_enable_dialog_ios_*`, `noti_resolved_body`) / `statuskontroll`(`safety_net_dialog_*`) / `säkerhetssignal` / `livstecken`

### B급
- `permission_activity_denied_message`가 다른 19개 언어에 없는 문장을 추가로 담고 있음(`Utan denna behörighet skickas ingen steginformation till vårdnadshavare.`) — 원문·타 언어와 내용 불일치

## 러시아어 (ru_RU) — 품질 상위권, 문제는 어휘 선택에 국한

존칭 `вы` 일관 ✅, 보호자/대상자 용어 `Опекун`/`Подопечный` 일관 ✅

| 등급 | 키 | 현재 | 문제 |
|---|---|---|---|
| **S** | `noti_resolved_body` | `Проверка **здоровья** подопечного вернулась в норму.` | **"건강 검진"으로 오역** (프랑스어 `bilan de santé`, 중국어 `健康状况`과 동일 패턴) |
| **S** | `settings_premium` | `Премиум **активна**` | 성 불일치 — `Премиум`은 남성이라 `активен`이 맞음 |
| **A** | 안부 명사 4중 | `самочувствие` / `благополучие` / `весточка` / `сигнал безопасности` | `noti_*`는 `самочувствия`, 온보딩·`safety_net_dialog_*`는 `благополучия`, 모드 선택은 `весточка`, `notifications_activity_note`는 `безопасности` |
| **A** | `guardian_status_normal` | `Безопасно` | 부사형("안전하게"). `common_normal`은 `Норма`인데 상태 배지만 다름 |
| **A** | `nav_notification`(`Тревоги`) vs `notifications_title`(`Уведомления`) | | 하단 탭과 화면 제목이 다른 단어 |
| **B** | `subject_home_manual_report_sent` | `…отправлено **контактам**.` | 앱 용어는 `опекун`인데 여기만 "연락처" |

## 폴란드어 (pl_PL) — 발음부호 손상 + 문법 오류

### S급

| 키 | 현재 | 문제 |
|---|---|---|
| `noti_manual_report_body` | `Osoba chroniona **reczne** wyslala…` | **품사 오류** — 부사 `ręcznie`여야 하는데 형용사 중성형 `reczne`. 발음부호 누락과 별개의 문법 오류 |
| `guardian_status_normal` / `_confirmed` | `Bezpieczny` (남성형) | 대상자가 여성이면 `Bezpieczna`여야 함. **성 중립 표현 필요**(예: `Wszystko w porządku`) |
| `subject_home_manual_report_sent` | `Twoja wiadomość została wysłana do **kontaktów**.` | 8번째 동일 오역 |
| 발음부호 | 정상·손상 표기가 한 파일에 공존 | `Bezpieczeństwo potwierdzone.`(정상) ↔ `Potwierdz bezpieczenstwo`(손상), `Dziś`(정상) ↔ `Pozniej`(손상) |

### A급 — "안부" 명사 5중 혼용

`samopoczucie`(주) / **`pomyślność`**(`gs_enable_dialog_ios_*`, `heartbeat_schedule_hint_ios`, `heartbeat_scheduled_today`) / `dobrostan`(`permission_hibernation_message`, `drawer_enable_guardian`, `noti_resolved_body`) / `znak życia`(모드 선택 4곳) / `bezpieczeństwo`(`notifications_activity_note`)

> ⚠️ **`pomyślność`은 "번영·행운"을 뜻하는 축원어**("Życzę pomyślności")라 안부 확인 신호와 맞지 않음 — 중국어 `安康`과 같은 유형의 오류

대상자도 3중: `podopieczny`(주) / `Osoba chroniona` / `Osoba pod opieką`

## 터키어 (tr_TR)

### S급

| 키 | 현재 | 문제 |
|---|---|---|
| `local_alarm_title` | `💗 **Sağlık kontrolü** gerekli` | **`sağlık kontrolü`는 "건강검진(의료)"**. **매일 뜨는 알림 제목**이 "건강검진이 필요합니다"로 읽힘. 앱 전반은 `hal hatır`를 씀 |
| `wellbeing_check_title` / `noti_resolved_body` | `💛 Sağlık Kontrolü` / `…sağlık kontrolü normale döndü` | 같은 오역 (프랑스어 `bilan de santé`, 러시아어 `проверка здоровья`와 동일 유형) |
| `onboarding_role_subject` 외 다수 | **`Takip Edilen`** | "**추적·감시당하는 사람**". 프랑스어 `Personne surveillée`와 같은 문제인데, 터키어는 이것이 **주 표현**이라 앱 전체에 감시 뉘앙스가 깔림 |
| `subject_home_manual_report_sent` | `Durumunuz **kişilerinize** iletildi.` | 9번째 동일 오역 |

### A급

- **보호자 4중**: `Koruyucu`(주) / **`bakıcı`**(`safety_net_dialog_*`, `subject_home_emergency_confirm_body` — "아기 돌보미·간병인" 뉘앙스) / `bakım vereni` / `kişileriniz`
- **대상자 4중**: `Takip Edilen` / `korunan` / `Bakımı yapılan kişi` / `takip edilen kişi`
- **안부 명사 4중**: `hal hatır`(주 — 자연스러움 ✅) / **`iyilik`**("선행·호의"의 뜻이 우세 — 온보딩·`gs_*`·`heartbeat_*`) / `esenlik`(문어체) / `sağlık`
- **존칭**: 전반은 `siz`인데 온보딩만 `sen`. `onboarding_gs_switch_title`(`gözetin` 존칭) 바로 아래 `_desc`(`kullanabilirsin` 반말) — **같은 스텝 안에서 혼용**

> `%20`, `%@battery_level`처럼 % 기호를 앞에 두는 것은 터키어 표기 규칙상 **정상** ✅

## 베트남어 (vi_VN) — 발음부호 손상 + "건강검진" 오역

### S급

| 키 | 현재 | 문제 |
|---|---|---|
| 발음부호 148곳 | `Nguoi bao ve`, `Chia se ma an toan cua ban` | 성조 없이는 **읽기 자체가 불가**. 게다가 정상·손상이 혼재: `Người bảo vệ`(`mode_guardian_badge`) ↔ `Nguoi bao ve`(`app_guardian_title`, `onboarding_role_guardian`) — **같은 역할명** |
| `local_alarm_title` | `💗 Cần **kiểm tra sức khỏe**` | **"건강검진이 필요합니다"**. 매일 뜨는 알림 제목. `noti_*` 전체가 `sức khỏe`(건강)를 써서 안부 확인이 아니라 **의료 검진**으로 읽힘 |
| `guardian_today_summary` | `Tom tat **suc khoe** hom nay` | "오늘의 건강 요약" — 같은 오역 |
| `add_subject_error_self` | `nguoi duoc **theo doi**` | "**추적·감시당하는 사람**" |

### A급 — 용어 혼용

- **보호자 3중**: `Người bảo vệ`(주) / `người bảo hộ`(`permission_location_desc`, `stability_battery_dialog_message`) / **`người giám hộ`**(법적 후견인 — `subject_home_emergency_*`, `safety_net_dialog_*`, `gs_*`)
- **대상자 4중**: `Người được bảo vệ` / `Người được chăm sóc`(`emergency_map`) / `người được theo dõi` / `đối tượng bảo vệ`(`connection_empty` — 사물 느낌)
- **안부 명사 3중**: `sức khỏe`(건강 — `noti_*` 전체) / `tín hiệu an toàn`(안전 신호 — 온보딩·`gs_*`) / `tin bình an`(평안 소식 — 모드 선택)

## 태국어 (th_TH)

### S급

| 키 | 현재 | 문제 |
|---|---|---|
| `noti_emergency_body` | `ผู้**ถูก**ดูแล` | **`ถูก`은 나쁜 일을 당할 때 쓰는 수동 표지** → "돌봄을 당하는 사람". 다른 키는 `ผู้ได้รับการดูแล`(중립)를 씀 ([검증](https://talkpal.ai/grammar/passive-voice-in-thai-grammar/)) |
| `notification_settings_warning` | `แจ้งเตือนเตือน` | **`เตือน`이 두 번 겹친 중복** — 프랑스어 `Alertes d'alerte`, 스페인어 `Alertas de alerta`, 이탈리아어 `Avvisi di avviso`와 같은 유형 |
| `noti_resolved_body` | `การตรวจสอบ**สุขภาพ**` | "건강검진"으로 오역 |
| `gs_enable_dialog_ios_*`, `heartbeat_schedule_hint_ios` | `สัญญาณ**สุขภาพ**`, `พุช**สุขภาพ**` | 같은 오역 — "건강 신호/건강 푸시" |

### A급 — "안부" 명사 7중 혼용 (20개 언어 중 최다)

`ความเป็นอยู่`(생활 형편, 주) / `ความสบายดี`(모드 선택) / `ความปลอดภัย`(안전) / `สุขภาวะ`(웰빙) / `ความสุขสบาย`(편안함) / `สัญญาณดูแลสุขภาพ`(건강 돌봄 신호) / `สวัสดิภาพ`(`subject_home_manual_report_sent`)

→ `onboarding_gs_switch_title`(`ความสุขสบาย`)과 바로 아래 `_desc`(`สุขภาวะ`)가 **같은 스텝에서 다른 단어**

### B급
- `common_pm`: `บ่าย`는 오후 13~16시만 가리킴(저녁 `เย็น`·밤 `กลางคืน`과 구분). `h24`라 현재 노출되지 않음
- `app_guardian_title`만 `ผู้ปกป้อง`, 나머지는 `ผู้ดูแล`
- `notifications_level_urgent_desc`: `โดยด่วนทันที` — "긴급히 즉시" 의미 중복

## 힌디어 (hi_IN)

### S급

| 키 | 현재 | 문제 |
|---|---|---|
| `guardian_error_load_step_history` | `**चरण** इतिहास` | **`चरण`은 "(절차의) 단계"**. 걸음수는 `कदम` — 같은 파일의 `guardian_chart_y_axis_steps`·`notifications_activity_note`는 모두 `कदम`을 씀 |
| `guardian_today_summary` | `आज **की** कुशलता सारांश` | **성 불일치** — `सारांश`은 남성명사라 `आज का …सारांश` 또는 `आज की कुशलता का सारांश` |
| `gs_enable_dialog_ios_*` | `**वेलनेस** संकेत`, `वेलनेस पुश सूचना` | **영어 `wellness` 음차** — 다른 곳은 전부 힌디어 고유어를 쓰는데 여기만 |
| `noti_urgent_body` | `@days **दिनों** से` | `दिनों`은 복수 사선격 → **@days=1일 때 문법 오류** |

### A급 — "안부" 명사 5중

`कुशलता`(주) / `कुशल-क्षेम`(`safety_net_dialog_*`, 구독 만료) / `सलामती`(`stability_battery_dialog_message`, `permission_hibernation_message`) / `वेलनेस`(영어 차용) / `सुरक्षा संकेत`(`notifications_activity_note`)

> ⚠️ **이 절은 수정 *전* 상태의 기록이다.** 1차로 다수형인 `कुशलता`에 통일했으나, 사전 확인 결과 그 단어의 1순위 의미가
> "숙련·능력"이라 최종적으로 **`खैरियत`으로 재수정**했다. 최종 결론은 문서 말미 "힌디어 안부 용어 재수정" 절을 볼 것.

대상자: `संरक्षित व्यक्ति`(주) ↔ `देखभाल प्राप्तकर्ता`(`emergency_map_subject_label`, `add_subject_error_self`)

### B급
- `common_time_style`이 `h24`인데 DND 기본값만 `रात 10:00`/`सुबह 7:00` (12시간제) — 같은 화면에서 형식 불일치. 인도는 12시간제가 일반적이라 `pre12` 전환도 검토 대상
- `subject_home_manual_report_sent`: `आपका **संदेश**…` — "메시지" 오역(단, 수신자는 `अभिभावकों`으로 올바름)

## 아랍어 (ar_SA)

### S급 — 호칭이 원문 의도와 다른 관계를 뜻함

| 개념 | 현재 | 문제 |
|---|---|---|
| 보호자 | **`حارس`**(주) | "**경비원·보디가드**". 가족·지인 보호자 문맥에 부적절 |
| 〃 | `وصي`(`onboarding_role_guardian_subject`, `subject_home_emergency_*`, `gs_enable_dialog_body`) | **법적 후견인**(미성년 후견) |
| 〃 | `مقدم الرعاية`(`safety_net_dialog_*`) / `جهات الاتصال`(`subject_home_manual_report_sent`) | 요양 제공자 / 연락처 — 4중 혼용 |
| 대상자 | **`متابَع`**(주) | "**추적·관찰당하는 자**" — 터키어 `Takip Edilen`, 프랑스어 `Personne surveillée`와 같은 감시 뉘앙스이며 **주 표현** |
| 〃 | `الشخص المحمي` / `الشخص المستفيد`(수혜자) / `شخص مشمول بالرعاية` | 4중 혼용 |

### B급
- `subject_home_manual_report_sent`: `تم إرسال **رسالة** سلامتك إلى **جهات الاتصال**` — 동일 오역 패턴
- `guardian_last_check_days`: `منذ @days **يوم**` — 아랍어 수 일치상 3~10일은 `أيام`(복수)여야 함
- `guardian_today_summary`: `ملخص اليوم` — "안부"가 빠진 "오늘의 요약"(독일어·프랑스어와 동일)

## 인도네시아어 (id_ID)

| 등급 | 키 | 현재 | 문제 |
|---|---|---|---|
| **S** | `stability_battery_dialog_message` | `※ **Pelafalan** tepatnya dapat bervariasi…` | **`Pelafalan`은 "발음"** — 원문은 "표기·문구". `Istilah`/`Teks`여야 함. 명백한 오역 |
| **S** | `notification_settings_warning` | `Peringatan Waspada` | "경고 경계" — 의미 중복(다른 5개 언어와 같은 유형) |
| **A** | 보호자 5중 | `Penjaga`(주 — "**경비원·파수꾼**") / `wali`(법적 후견인 — `subject_home_emergency_desc`) / `pelindung`(`permission_location_desc`) / `pengasuh`(보모·간병인 — `safety_net_dialog_body`, `stability_battery_dialog_message`) / `kontak` | `pelindung`이 문맥상 가장 적합한데 주 표현은 `Penjaga` |
| **B** | `add_subject_error_self` | `orang yang **dipantau**` | "감시당하는 사람" — 나머지는 `Orang yang Dilindungi`로 일관 |
| **B** | `subject_home_manual_report_sent` | `Pesan… ke **kontak** Anda` | 동일 오역 패턴 |

> 대상자 호칭 `Orang yang Dilindungi`는 일관됨 ✅

## 중국어 번체 (zh_TW) — 간체 문제 + 두 파일 간 불일치

간체(§2)의 `安否`·`對象者`·`安康訊號`·용어 혼용 문제를 그대로 공유한다. 추가로 **간체와 번체가 서로 다르게 번역된 키**가 있어, 같은 앱이 두 중국어권에서 다른 의미를 전달한다.

| 키 | 간체 | 번체 | 비고 |
|---|---|---|---|
| `subject_home_manual_report_sent` | 已向**监护人**发送问候 | 已向**守護者**傳送問候 | 번체가 더 적절(`守護者`가 앱 주 표현) |
| `safety_net_dialog_body` | …发送给**监护人** | …傳送給**守護者** | 두 파일 간 호칭 불일치 |
| `noti_resolved_body` | 被监护人的**健康状况**已正常确认 | 被監護人的**安全狀況**已正常確認 | 간체만 "건강 상태"로 오역 |

> 번체 `notification_settings_warning`은 `警告通知`로 **중복 없음** ✅ (프랑스어·스페인어·이탈리아어·태국어·인도네시아어의 "경고의 경고" 문제 없음)

---

# 【전 언어 공통 결함】 요약

정독 결과, 20개 언어에 **같은 원인에서 나온 결함**이 반복된다.

### 1. `subject_home_manual_report_sent` — 10개 언어 동일 오역
"보호자에게 안부를 전했습니다" → "당신의 **메시지**가 **연락처**로 전송되었습니다"
독일어·프랑스어·스페인어·이탈리아어·네덜란드어·포르투갈어·스웨덴어·폴란드어·터키어·아랍어·인도네시아어·힌디어·러시아어. 앱의 다른 곳은 모두 "보호자"를 쓰는데 이 키만 "연락처".

### 2. `notification_settings_warning` — 6개 언어 "경고의 경고" 중복
프랑스어 `Alertes d'alerte` / 스페인어 `Alertas de alerta` / 이탈리아어 `Avvisi di avviso` / 태국어 `แจ้งเตือนเตือน` / 인도네시아어 `Peringatan Waspada` / 포르투갈어 `Alertas de aviso`

### 3. "안부 확인"을 **의료 검진**으로 오역 — 7개 언어
프랑스어 `bilan de santé` / 러시아어 `проверка здоровья` / 터키어 `sağlık kontrolü` / 베트남어 `kiểm tra sức khỏe` / 태국어 `การตรวจสอบสุขภาพ` / 중국어 간체 `健康状况` / 스웨덴어 `hälsokontroll`
→ **특히 터키어·베트남어는 `local_alarm_title`(매일 뜨는 알림 제목)이 "건강검진이 필요합니다"로 읽힘**

### 4. 대상자 호칭에 **감시 뉘앙스** — 5개 언어
터키어 `Takip Edilen`(주 표현) / 아랍어 `متابَع`(주 표현) / 프랑스어 `Personne surveillée` / 베트남어 `người được theo dõi` / 인도네시아어 `orang yang dipantau`

### 5. 보호자를 **법적 후견인·경비원·간병인**으로 번역 — 8개 언어
네덜란드어 `voogd`·`Bewaker` / 아랍어 `حارس`(경비원)·`وصي` / 스웨덴어 `vårdnadshavare` / 인도네시아어 `Penjaga`(경비원)·`wali` / 터키어 `bakıcı`(보모) / 베트남어 `người giám hộ` / 중국어 `监护人` / 이탈리아어 `tutore`

### 6. 온보딩 화면만 반말 — 4개 언어
독일어(`du`) / 이탈리아어(`tu`) / 스페인어(`tú`) / 터키어(`sen`). 네덜란드어는 화면 무관하게 `u`/`je` 뒤섞임.

### 7. "안부" 명사가 언어마다 4~7가지로 분산
태국어 7가지, 독일어 6가지, 폴란드어·스웨덴어·중국어 5가지, 러시아어·힌디어·터키어·베트남어 4가지

---

# 【확정 용어표】 프레이밍: "가족·지인이 서로 챙김"

법적 후견(voogd/وصي/vårdnadshavare/监护人/Vormund)과 감시(Takip Edilen/متابَع/surveillée/theo dõi/dipantau) 어감을 **전 언어에서 제거**한다.

| 언어 | 보호자 | 대상자 | 안부(명사) | 안전 코드 |
|---|---|---|---|---|
| 한국어 | 보호자 | 보호 대상자 | 안부 | 안전 코드 |
| 영어 | Guardian | Subject | wellness check | safety code |
| 일본어 | 見守り人 | 見守り対象者 | 安否確認 | 安全コード |
| 중국어 간체 | 守护者 | 被守护者 | 平安 | 安全码 |
| 중국어 번체 | 守護者 | 被守護者 | 平安 | 安全碼 |
| 독일어 | Betreuer | betreute Person | Wohlbefinden | Sicherheitscode |
| 프랑스어 | Protecteur | Personne protégée | bien-être | code de sécurité |
| 스페인어 | Protector | Persona protegida | bienestar | código de seguridad |
| 이탈리아어 | Guardiano | Assistito | benessere | codice di sicurezza |
| 네덜란드어 | Beschermer | beschermeling | welzijn | veiligheidscode |
| 포르투갈어 | Guardião | Protegido | bem-estar | código de segurança |
| 러시아어 | Опекун | Подопечный | самочувствие | код безопасности |
| 아랍어 | مُرافِق | الشخص المحمي | اطمئنان | رمز الأمان |
| 터키어 | Koruyucu | Korunan kişi | hal hatır | güvenlik kodu |
| 폴란드어 | Opiekun | Podopieczny | samopoczucie | kod bezpieczeństwa |
| 베트남어 | Người bảo vệ | Người được bảo vệ | bình an | mã an toàn |
| 태국어 | ผู้ดูแล | ผู้ได้รับการดูแล | ความเป็นอยู่ | รหัสความปลอดภัย |
| 힌디어 | अभिभावक | संरक्षित व्यक्ति | **खैरियत** (속격으로 씀 — `खैरियत की जांच`) | सुरक्षा कोड |
| 스웨덴어 | Vårdare | Skyddad person | välmående | säkerhetskod |
| 인도네시아어 | **Pelindung** | Orang yang dilindungi | kesejahteraan | kode keamanan |

## 폐기되는 단어 (전 언어)

**보호자 자리에서 제거**: `保護者`(일) · `监护人`(중) · `Gardien`(프) · `Guardián`·`cuidador`(스) · `tutore`·`familiare`(이) · `Bewaker`·`voogd`·`verzorger`·`begeleider`(네) · `cuidador`·`responsável`·`protetor`(포) · `vårdnadshavare`·`vårdgivare`·`anhörig`(스웨) · `حارس`·`وصي`·`مقدم الرعاية`(아) · `bakıcı`·`bakım vereni`(터) · `người giám hộ`·`người bảo hộ`(베) · `Penjaga`·`wali`·`pengasuh`(인) · 전 언어의 `연락처(contacts/kontakter/kişileriniz/جهات الاتصال…)`

**대상자 자리에서 제거**: `Takip Edilen`(터) · `متابَع`(아) · `Personne surveillée`(프) · `người được theo dõi`(베) · `orang yang dipantau`(인) · `ผู้ถูกดูแล`(태) · `Hulpbehoevende`(네) · `对象者`(중) · `Schutzperson`(독 — 보호자 타이틀과 충돌)

**안부 자리에서 제거**: `安否`(중) · `Wellness`(독·힌) · `bilan de santé`(프) · `sağlık kontrolü`(터) · `sức khỏe`(베) · `สุขภาพ`(태) · `hälsokontroll`(스웨) · `проверка здоровья`(러) · `pomyślność`(폴) · `安康`(중) · `Lebenszeichen`·`Statusmeldung`(독) · `livstecken`·`statuskontroll`(스웨)

## 호칭을 바꾸지 않는 언어와 이유

- **러시아어 `Опекун`/`Подопечный`** — `опекать`(돌보다) 파생이라 일상어에서 따뜻한 어감을 함께 가지며, 이미 전 파일 일관. 교체 이득보다 대량 수정 위험이 큼
- **힌디어 `अभिभावक`**, **폴란드어 `Opiekun`**, **터키어 `Koruyucu`**, **일본어 `見守り人`** — 각 언어에서 감시·법적 어감 없이 "돌보는 사람"으로 읽힘. 일본어 `見守り`는 고령자 안부확인 서비스의 표준어라 프레이밍과 정확히 일치
- **인도네시아어만 주 표현 교체** — `Penjaga`(경비원)를 이미 파일에 등장하는 `Pelindung`(보호자)으로 승격

## 존칭 정책 (사용자 결정: 온보딩을 존칭으로 상향)

독일어 `Sie`, 이탈리아어 `Lei`, 스페인어 `usted`, 터키어 `siz`, 네덜란드어 `u`로 **앱 전체 통일**. 온보딩 6~30곳이 대상.

---

# 실기기(iOS 시뮬레이터) 검증 — 2026-08-14

정적 검사로는 잡히지 않는 두 부류(**하드코딩 문자열**, **레이아웃 오버플로**)를 확인하기 위해
iPhone 16 Plus 시뮬레이터에서 언어를 바꿔가며 보호자 대시보드를 렌더링했다.

검증 언어: 폴란드어 · 베트남어 · **아랍어(RTL)** · **태국어** · **힌디어** · **독일어**

| 발견 | 성격 | 조치 |
|---|---|---|
| AppBar 제목이 `'Anbu Guardian'` 리터럴 — 번역 키가 있는데 아무도 쓰지 않음 → **20개 언어 전부 영어 노출** | 기존 결함 | `'app_guardian_title'.tr`로 교체 |
| 주의 카드 활동 라벨이 3줄이 되어 세로 오버플로 (카드 `200.h` 고정) | 기존 결함 | 9개 언어 문구 단축 + `maxLines: 2` + `ellipsis`. **카드 높이는 유지** |
| 베트남어 짧은 문자열 14건의 성조 누락 (`Chu y`, `Huy`, `Xoa`…) | **내 복원 작업의 누락** — 12자 이상만 검사했음 | 길이 필터 없이 재검사 후 수정 |
| 폴·스웨 큰따옴표 다중행 값 7건 미적용 | **내 치환 정규식의 누락** — 작은따옴표만 매칭 | 패턴 확장 후 수정 |
| `api_connect.dart`의 401 복구 스낵바가 한국어 리터럴 | 기존 결함 | `common_session_expired` 키 신설(20개 언어) 후 `.tr` 적용 |

RTL(아랍어)·결합문자(태국어 `ผู้`/힌디어 `क्षि`)·긴 합성어(독일어 `Wohlbefindens-Übersicht`) 모두 정상 렌더링, 오버플로 없음.

## 시각 표기 override 실측

`time_utils.dart`의 "기기 24시간제가 언어 설정보다 우선" 규칙을 임시 로그로 실제 코드 경로에서 확인:

```
locale=hi_IN  device24h=false  style=post12  18:00->6:00 PM  07:00->7:00 AM  00:00->12:00 AM
locale=el_GR  device24h=true   style=post12  18:00->18:00    07:00->07:00    00:00->00:00
```

두 번째 줄이 이 변경의 근거다 — **미지원 언어(그리스어)는 GetX가 en_US(`post12`)로 폴백**하는데,
기기가 24시간제면 override가 걸려 `6:00 PM`이 아니라 `18:00`이 나온다. (검증 후 로그 코드는 제거)

## 최종 검증 결과

| 항목 | 결과 |
|---|---|
| 키 파리티 | 20개 파일 × **363키** 완전 일치, 중복 없음 |
| 자리표시자 | 한국어와 완전 일치 (ASCII 경계로 비교 — `@count명`을 한 토큰으로 읽으면 거짓 양성) |
| 한글 잔존 / 빈 값 | 없음 |
| `flutter analyze` | No issues found |
| averic-lab 101키 계약 | `extract_strings.py` **직접 실행** → `exit 0`, "문제 없음" (삭제한 2키는 계약 밖) |

---

# 남은 항목 (이번 범위 밖 — 원어민/별도 작업 필요)

| 항목 | 왜 지금 손대지 않는가 |
|---|---|
| ~~힌디어 `कुशलता`(안부)~~ | **2026-08-14 검색으로 확인 후 수정 완료** — 아래 별도 절 참조 |
| Android 알림 채널명 하드코딩 (`fcm_service.dart:265`) | 채널은 앱 초기화 시점에 생성돼 `.tr`이 동작하지 않는다. 채널명 변경은 삭제 후 재생성이 필요해 별도 설계 필요 |
| `api_error.dart`의 한글-키 사용 | `printLog()` 경로 전용으로 확인됨 — 사용자에게 보이지 않음 |
| 미사용 키 37개 | 미구현 기능(G+S 해제 다이얼로그, iOS heartbeat 라벨 등)의 흔적. 기능 구현 시 사용될 수 있어 삭제하지 않음 |
| 복수형 `Tag(en)`/`व्यक्ति(यों)` 괄호 표기 | GetX는 복수형 분기를 미지원하고, 해당 키들은 averic-lab 계약 키라 자리표시자 추가가 금지됨 |

---

# 힌디어 "안부" 용어 재수정 — `कुशलता` → `खैरियत` (2026-08-14)

## 왜 뒤집었나

1차 통일에서 파일 내 **다수형**인 `कुशलता`로 5중 혼용을 정리했다. 다수를 택한 것이지 옳은 것을 택한 게 아니었고,
**"검증할 방법이 없다"고 문서에 적었지만 실제로는 검색해 보지 않았다.** 사용자 지적으로 검색한 결과:

- **`कुशलता`** — 사전 1순위 번역이 *skill, adroitness, craft; capacity to do something well*. **"안부"가 아니라 "능력·숙련"이다.**
  `कुशलता जांच`는 원어민에게 "능력 검사"로 읽힐 수 있다 — 이번 감사가 없애려던 바로 그 부류의 오역
- **`खैरियत`** — **여성명사**(संज्ञा स्त्री॰), 뜻이 `कुशल क्षेम, राजीखुशी, भलाई`. 관용구 `खैरियत पूछना`가 정확히 "안부를 묻다"

## 왜 처음에 "못 한다"고 판단했고, 그게 왜 틀렸나

`कुशल-क्षेम`은 **남성**이라 ~40곳의 성 일치(`की`→`के`)를 함께 바꿔야 한다고 봤다. 그런데 실제 문맥을 보면

- `की` 6곳 → 전부 `कुशलता` 자신(여성)과 일치
- `का` 여러 곳 → 전부 **뒤따르는 남성 핵어**(`संकेत`, `संदेश`, `सारांश`)와 일치. `कुशलता`와 무관

`खैरियत`도 여성이므로 **성 일치 변경은 0곳**이다. 막힌다고 본 근거 자체가 성립하지 않았다.

## 후보 비교

| 후보 | 성 | 판정 |
|---|---|---|
| `कुशल-क्षेम` | 남성 | 일치 40곳 변경 필요 |
| `सलामती` | 여성 | 앱이 이미 쓰는 `सुरक्षा`(안전)와 의미 충돌 + 종교적 축원 register |
| **`खैरियत`** | **여성** | 충돌 없음, 일치 변경 없음 ✅ |

## 맨 복합어 대신 속격을 쓴 이유

`खैरियत जांच` 같은 **맨 명사-명사 복합**은 근거를 찾지 못했다(검색에서 확인된 용례는 `खैरियत की खबर`·`खैरियत पूछना` 등 속격/동사구).
힌디에서 산스크리트계 명사는 맨 결합이 자유롭지만(`सुरक्षा जांच`) 페르시아·아랍 차용어는 속격을 요구하는 경우가 많다.
**속격은 맨 복합이 허용되든 아니든 항상 문법적**이므로, 44개 구 전부를 속격으로 재구성했다.

- `कुशलता जांच` → `खैरियत की जांच`
- `कुशलता संकेत` → `खैरियत का संकेत`
- `आपका कुशलता संकेत` → **`आपकी` खैरियत का संकेत** (소유격이 이제 `संकेत`이 아니라 `खैरियत`을 수식)
- `कुशलता अलर्ट`(알림 채널명) → `खैरियत की सूचनाएं`
- 형용사형 `कुशल संकेत` 2곳도 함께 정리 — 안 하면 2중 분기가 다시 생긴다

## 적용 범위와 검증

- 앱 `hi_in.dart` **44개 구**, 각 치환은 `count == 1`(유일 매칭)을 강제해 오치환 불가. `कुशल` 잔존 **0**
- 서버 `i18n/messages.py` 힌디 **3건** 동기화 — 안 하면 푸시는 `कुशलता`, 인앱은 `खैरियत`로 갈라진다
- 키 파리티 363 × 20 ✅ / 자리표시자 일치 ✅ / `permission_hibernation_highlight` 부분문자열 관계 유지 ✅
- `flutter analyze` 통과, `extract_strings.py` `exit 0`
