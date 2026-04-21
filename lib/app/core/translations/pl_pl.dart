abstract class PlPl {
  static const Map<String, String> translations = {
    // ── Ogolne ──
    'common_confirm': 'Potwierdz',
    'common_cancel': 'Anuluj',
    'common_continue': 'Kontynuuj',
    'common_save': 'Zapisz',
    'common_delete': 'Usun',
    'common_close': 'Zamknij',
    'common_next': 'Dalej',
    'common_previous': 'Wstecz',
    'common_start': 'Rozpocznij',
    'common_skip': 'Pomin',
    'common_later': 'Pozniej',
    'common_loading': 'Ladowanie...',
    'common_error': 'Blad',
    'common_complete': 'Gotowe',
    'common_notice': 'Informacja',
    'common_unlink': 'Odlacz',
    'common_am': 'rano',
    'common_pm': 'po poludniu',
    'common_normal': 'Normalny',
    'common_connected': 'Polaczono',
    'common_disconnected': 'Brak polaczenia',

    // ── Marka aplikacji ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Sprawdzamy, czy wszystko u Ciebie w porzadku.',
    'app_service_desc': 'Automatyczna usluga sprawdzania samopoczucia',
    'app_guardian_title': 'Opiekun Anbu',
    'app_copyright': '© 2026 Averic SB Inc.',

    // ── Splash ──
    'splash_loading': 'Sprawdzanie samopoczucia...',

    // ── Aktualizacja ──
    'update_required_title': 'Wymagana aktualizacja',
    'update_required_message':
        'Prosze zaktualizowac do wersji @version, aby kontynuowac korzystanie z aplikacji.',
    'update_button': 'Aktualizuj',
    'update_available_title': 'Dostepna aktualizacja',
    'update_available_message': 'Dostepna jest wersja @version.',

    // ── Wybor trybu ──
    'mode_select_title': 'Wybierz swoja role',
    'mode_select_subtitle': 'To pomoze nam skonfigurowac odpowiednie funkcje dla Ciebie',
    'mode_subject_title': 'Chce, aby ktos\nczuwal nad moim bezpieczenstwem',
    'mode_subject_button': 'Chce byc pod opieka →',
    'mode_guardian_title': 'Chce czuwac nad bezpieczenstwem\nbliskiej osoby',
    'mode_guardian_button': 'Zacznij jako opiekun →',
    'mode_select_notice': 'Uklad ekranu i powiadomienia beda sie roznic w zaleznosci od wyboru',

    // ── Uprawnienia ──
    'permission_title': 'Do korzystania z aplikacji\nwymagane sa uprawnienia',
    'permission_notification': 'Uprawnienie do powiadomien',
    'permission_notification_subject_desc': 'Wymagane do otrzymywania powiadomien o samopoczuciu',
    'permission_notification_guardian_desc':
        'Wymagane do otrzymywania powiadomien o bezpieczenstwie podopiecznych',
    'permission_activity': 'Rozpoznawanie aktywnosci',
    'permission_activity_desc': 'Sluzy do wykrywania krokow i potwierdzania aktywnosci',
    'permission_activity_dialog_title': 'Informacja o uprawnieniu aktywnosci',
    'permission_activity_dialog_message':
        'Sluzy do wykrywania krokow i potwierdzania aktywnosci.\nProsze wybrac "Zezwol" na nastepnym ekranie.',
    'permission_notification_required_title': 'Wymagane uprawnienie do powiadomien',
    'permission_notification_required_message':
        'Uprawnienie do powiadomien jest wymagane dla uslugi sprawdzania samopoczucia.\nProsze wlaczyc je w Ustawieniach.',
    'permission_go_to_settings': 'Przejdz do Ustawien',
    'permission_activity_denied_title': 'Wymagane uprawnienie aktywności fizycznej',
    'permission_activity_denied_message':
        'Uprawnienie aktywności fizycznej jest wymagane do wykrywania kroków i weryfikacji Twojego bezpieczeństwa.\n\nBez tego uprawnienia informacje o krokach nie będą wysyłane do opiekunów.\n\nWłącz uprawnienie "Aktywność fizyczna" w ustawieniach aplikacji.',
    'permission_battery': 'Wyłączenie z optymalizacji baterii',
    'permission_battery_desc':
        'Wyłącza aplikację z optymalizacji baterii, aby codzienne sprawdzanie samopoczucia nie było pomijane o zaplanowanej godzinie',
    'permission_battery_required_title': 'Ustaw baterię na "Bez ograniczeń"',
    'permission_battery_required_message':
        'Jeśli ustawione jest "Optymalizacja baterii" lub "Oszczędzanie baterii", codzienne sprawdzanie samopoczucia może być opóźnione lub pominięte.\n\nPo naciśnięciu [Przejdź do Ustawień]:\n1. Wybierz "Bateria"\n2. Zmień na "Bez ograniczeń"',
    'permission_battery_go_to_settings': 'Przejdź do Ustawień',
    'permission_hibernation_title': 'Wyłącz "Wstrzymaj nieużywane aplikacje"',
    'permission_hibernation_highlight': 'Wstrzymaj nieużywane aplikacje',
    'permission_hibernation_message':
        'Jeśli nie otworzysz aplikacji przez kilka miesięcy, Android może ją automatycznie zatrzymać, przerywając sprawdzanie dobrostanu.\n\nDotknij [Otwórz ustawienia aplikacji] i wyłącz "Wstrzymaj nieużywane aplikacje".',
    'permission_hibernation_go_to_settings': 'Otwórz ustawienia aplikacji',

    // ── Onboarding ──
    'onboarding_title_1': 'Martwisz sie o kogos,\nkto mieszka sam?',
    'onboarding_desc_1':
        'Nawet z daleka\nzastanawiasz sie, czy wszystko w porzadku.\nAnbu jest tu z Toba.',
    'onboarding_title_2': 'Sprawdzanie samopoczucia\nbez jednego slowa',
    'onboarding_desc_2':
        'Wystarczy korzystac ze smartfona,\naby codziennie automatycznie\nwyslac sygnal o samopoczuciu.',
    'onboarding_title_3': 'Podziel sie troska\nz bliskimi osobami',
    'onboarding_desc_3': 'Codzienne sprawdzanie buduje\ntrwaly spokoj ducha.\nZacznijmy.',
    'onboarding_title_4': 'Zadnych imion, zadnych numerow\ntelefonow — nic nie zbieramy',
    'onboarding_desc_4':
        'Przekazujemy tylko jeden sygnal:\n"Wszystko u mnie dobrze."\nTwoje dane sa bezpieczne.',
    'onboarding_role_subject': 'Podopieczny',
    'onboarding_role_guardian': 'Opiekun',
    'onboarding_role_guardian_subject': 'Opiekun i podopieczny',
    'onboarding_already_registered_title': 'Urzadzenie juz zarejestrowane',
    'onboarding_already_registered_message':
        'To urzadzenie jest juz zarejestrowane w trybie "@roleLabel".\nKontynuowac jako "@roleLabel"?\n\nCzy przejsc na tryb "@newRoleLabel"?\nZmiana usunie wszystkie istniejace dane.',
    'onboarding_already_registered_message_gs':
        'To urządzenie jest już zarejestrowane w trybie „@roleLabel".\nPrzełączenie na tryb „@newRoleLabel" usunie wszystkie dane opiekuna i podopiecznego.',
    'onboarding_registration_failed_title': 'Rejestracja nie powiodla sie',
    'onboarding_registration_failed_message':
        'Nie mozna polaczyc z serwerem. Prosze sprobowac ponownie pozniej.',

    // ── Strona glowna podopiecznego ──
    'subject_home_share_title': 'Udostepnij swoj kod bezpieczenstwa',
    'subject_home_guardian_count': 'Polaczeni opiekunowie: @count',
    'subject_home_check_title_last': 'Ostatnie sprawdzenie',
    'subject_home_check_title_scheduled': 'Zaplanowany czas sprawdzenia',
    'subject_home_check_title_checking': 'Sprawdzanie samopoczucia',
    'subject_home_check_body_reported': 'Zgloszone o @time',
    'subject_home_check_body_scheduled': 'Zaplanowane na @time',
    'subject_home_check_body_waiting': 'Oczekiwanie od @time',
    'subject_home_battery_status': 'Stan baterii',
    'subject_home_battery_charging': 'Ladowanie',
    'subject_home_battery_full': 'Pelna',
    'subject_home_battery_low': 'Niski poziom baterii',
    'subject_home_connectivity_status': 'Stan polaczenia',
    'subject_home_report_loading': 'Zglaszanie...',
    'subject_home_report_button': 'Zglos bezpieczenstwo teraz',
    'subject_home_report_desc': 'Powiadom opiekuna, ze wszystko w porzadku',
    'subject_home_emergency_button': 'Potrzebuję pomocy',
    'subject_home_emergency_desc': 'Wysyła alarm awaryjny do opiekunów',
    'subject_home_emergency_loading': 'Wysyłanie alarmu awaryjnego...',
    'subject_home_emergency_sent': 'Alarm awaryjny został wysłany',
    'subject_home_emergency_failed': 'Nie udało się wysłać alarmu awaryjnego',
    'subject_home_manual_report_limit_reached': 'Wysłałeś już dzisiejszy raport bezpieczeństwa. Spróbuj ponownie jutro.',
    'subject_home_emergency_confirm_title': 'Prośba o pomoc awaryjną',
    'subject_home_emergency_confirm_body':
        'Alarm awaryjny zostanie wysłany do wszystkich opiekunów.\nTwoja obecna lokalizacja również zostanie udostępniona.\nCzy na pewno chcesz poprosić o pomoc?',
    'emergency_sent_with_location': 'Alarm awaryjny wysłany (z lokalizacją)',
    'emergency_sent_without_location': 'Alarm awaryjny wysłany',
    'notifications_view_location': '🗺️ Pokaż lokalizację',
    'emergency_map_title': 'Lokalizacja alarmowa',
    'emergency_map_subject_label': 'Podopieczny',
    'emergency_map_captured_at_label': 'Czas uzyskania',
    'emergency_map_accuracy_label': 'Dokładność',
    'emergency_map_open_external': 'Otwórz w zewnętrznej aplikacji map',
    'emergency_map_no_location': 'Brak informacji o lokalizacji',
    'emergency_location_permission_denied_snackbar': 'Alarm awaryjny wysłany bez uprawnień do lokalizacji',
    'subject_home_emergency_confirm_send': 'Wyślij prośbę awaryjną',
    'subject_home_share_text':
        'Sprawdz moje samopoczucie w aplikacji Anbu!\nKod zaproszenia: @code',
    'subject_home_share_subject': 'Kod zaproszenia Anbu',
    'subject_home_code_copied': 'Kod skopiowany',

    // ── Szuflada podopiecznego ──
    'drawer_light_mode': 'Tryb jasny',
    'drawer_dark_mode': 'Tryb ciemny',
    'drawer_privacy_policy': 'Polityka prywatnosci',
    'drawer_terms': 'Regulamin',
    'drawer_withdraw': 'Usun konto',
    'drawer_withdraw_message': 'Twoje konto i wszystkie dane zostana usuniete.\nCzy na pewno?',

    // ── Panel opiekuna ──
    'guardian_status_normal': 'Normalny',
    'guardian_status_caution': 'Uwaga',
    'guardian_status_warning': 'Ostrzezenie',
    'guardian_status_urgent': 'Pilne',
    'guardian_status_confirmed': 'Bezpieczenstwo potwierdzone',
    'guardian_subscription_expired': 'Subskrypcja wygasla',
    'guardian_subscription_expired_message':
        'Powiadomienia o alertach nie sa wysylane.\nOdnow subskrypcje, aby kontynuowac ochrone.',
    'guardian_subscribe': 'Subskrybuj',
    'guardian_payment_preparing': 'Funkcja platnosci wkrotce dostepna.',
    'guardian_today_summary': 'Dzisiejsze podsumowanie',
    'guardian_no_subjects': 'Brak polaczonych podopiecznych.',
    'guardian_checking_subjects': 'Aktualnie sprawdzamy\n@count podopiecznego(-ych).',
    'guardian_subject_list': 'Lista podopiecznych',
    'guardian_call_now': 'Zadzwon teraz',
    'guardian_confirm_safety': 'Potwierdz bezpieczenstwo',
    'guardian_no_check_history': 'Brak historii sprawdzen',
    'guardian_last_check_now': 'Ostatnie sprawdzenie: wlasnie teraz',
    'guardian_last_check_minutes': 'Ostatnie sprawdzenie: @minutes min temu',
    'guardian_last_check_hours': 'Ostatnie sprawdzenie: @hours godz. temu',
    'guardian_last_check_days': 'Ostatnie sprawdzenie: @days dni temu',
    'guardian_activity_stable': 'Aktywnosc: Stabilna',
    'guardian_activity_prefix': 'Aktywnosc',
    'guardian_activity_very_active': 'Bardzo aktywny',
    'guardian_activity_active': 'Aktywny',
    'guardian_activity_needs_exercise': 'Potrzeba ruchu',
    'guardian_activity_collecting': 'Zbieranie danych',
    'guardian_error_load_step_history': 'Nie udało się wczytać historii kroków',
    'guardian_chart_y_axis_steps': 'Kroki',
    'guardian_chart_x_axis_last_7_days': 'Ostatnie 7 dni',
    'guardian_chart_x_axis_last_30_days': 'Ostatnie 30 dni',
    'guardian_chart_today': 'Dziś',
    'guardian_safety_needed': 'Wymagane sprawdzenie bezpieczenstwa',
    'guardian_error_load_subjects': 'Nie udalo sie zaladowac listy podopiecznych.',
    'guardian_error_clear_alerts': 'Nie udalo sie usunac alertow.',

    // ── Dodawanie podopiecznego ──
    'add_subject_title': 'Polacz podopiecznego',
    'add_subject_guide_title': 'Wprowadz unikalny kod podopiecznego i alias.',
    'add_subject_guide_subtitle':
        'Polacz aplikacje podopiecznego, aby monitorowac jego zdrowie i aktywnosc w czasie rzeczywistym.',
    'add_subject_code_label': 'Unikalny kod (7 znakow)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info': 'Unikalny kod mozna znalezc w aplikacji podopiecznego.',
    'add_subject_alias_label': 'Alias podopiecznego',
    'add_subject_alias_hint': 'np. Mama, Tata',
    'add_subject_connect': 'Polacz',
    'add_subject_error_login': 'Wymagane logowanie.',
    'add_subject_success': 'Podopieczny zostal polaczony.',
    'add_subject_error_invalid_code': 'Nieprawidlowy kod.',
    'add_subject_error_already_connected': 'Juz polaczony.',
    'add_subject_error_failed': 'Polaczenie nie powiodlo sie. Prosze sprobowac ponownie.',
    'add_subject_button': 'Dodaj nowego podopiecznego',

    // ── Ustawienia opiekuna ──
    'settings_title': 'Ustawienia',
    'settings_light_mode': 'Tryb jasny',
    'settings_dark_mode': 'Tryb ciemny',
    'settings_connection_management': 'Zarzadzanie polaczeniami',
    'settings_managed_subjects': 'Liczba podopiecznych',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'Subskrypcja i uslugi',
    'settings_current_membership': 'Obecne czlonkostwo',
    'settings_premium': 'Aktywna subskrypcja Premium',
    'settings_free_trial': 'Okres probny',
    'settings_days_remaining': 'Pozostalo @days dni',
    'settings_manage_subscription': 'Zarzadzaj subskrypcja',
    'settings_notification': 'Ustawienia powiadomien',
    'settings_terms_section': 'Prawne',
    'settings_privacy_policy': 'Polityka prywatnosci',
    'settings_terms': 'Regulamin',
    'settings_app_version': 'Wersja: v@version',

    // ── G+S (Opiekun + Podopieczny) ──
    'gs_enable_button': 'Otrzymuj też ochronę',
    'gs_safety_code_button': 'Sprawdź mój kod bezpieczeństwa',
    'gs_safety_code_title': 'Mój kod bezpieczeństwa',
    'gs_enable_dialog_title': 'Włącz ochronę',
    'gs_enable_dialog_body':
        'Możesz otrzymywać ochronę, zachowując funkcje opiekuna.\nZostanie wydany kod bezpieczeństwa — udostępnij go innym opiekunom.',
    'gs_enable_dialog_ios_warning_title': '⚠ iOS działa inaczej niż Android',
    'gs_enable_dialog_ios_warning_body':
        'W systemie iOS codziennie o ustalonej godzinie pojawia się "powiadomienie push o pomyślności". Aby Twój sygnał pomyślności został wysłany, musisz dotknąć powiadomienia lub samodzielnie otworzyć aplikację o tej porze. Jeśli nie otworzysz aplikacji, Twoi opiekunowie mogą otrzymać alert o nieudanej kontroli.',
    'gs_enable_dialog_ios_confirm': 'Rozumiem, włącz',
    'gs_enable_confirm': 'Włącz',
    'gs_enabled_message': 'Ochrona została włączona',
    'gs_enable_failed': 'Nie udało się włączyć ochrony',
    'gs_disable_dialog_title': 'Wyłącz ochronę',
    'gs_disable_dialog_body':
        'Wyłączenie ochrony usunie twój kod bezpieczeństwa i zatrzyma wysyłanie kontroli do połączonych opiekunów.',
    'gs_disable_confirm': 'Wyłącz',
    'gs_disabled_message': 'Ochrona została wyłączona',
    'gs_disable_failed': 'Nie udało się wyłączyć ochrony',
    'gs_activity_permission_denied_warning': 'Uprawnienie krokomierza odrzucone. Dotknij tutaj, aby zezwolić.',
    'gs_activity_permission_settings_title': 'Wymagane uprawnienie',
    'gs_activity_permission_settings_body': 'Zezwól na uprawnienie Aktywność fizyczna (Ruch i sprawność) w ustawieniach aplikacji.',
    'gs_activity_permission_settings_go': 'Przejdź do Ustawień',

    // ── Tryb opiekuna → G+S (Szuflada/Dialog) ──
    'drawer_enable_guardian': 'Zarządzaj też dobrostanem rodziny',
    's_to_gs_dialog_title': 'Dodaj funkcję opiekuna',
    's_to_gs_dialog_body':
        'Dodaj funkcję opiekuna, aby móc również czuwać nad dobrostanem rodziny lub bliskich.\n(Uwaga: funkcja opiekuna jest bezpłatna przez 3 miesiące, po czym przechodzi w płatną subskrypcję.)\n\nTwój własny kod bezpieczeństwa i obecnie używane wysyłanie sygnałów o samopoczuciu pozostaną bez zmian i nadal będą bezpłatne.',
    's_to_gs_dialog_confirm': 'Kontynuuj',
    's_to_gs_switch_failed': 'Nie udało się włączyć funkcji opiekuna',

    // ── Powiadomienia opiekuna ──
    'notifications_title': 'Powiadomienia',
    'notifications_today': 'Dzisiejsze powiadomienia',
    'notifications_empty': 'Brak powiadomien na dzisiaj',
    'notifications_delete_all_title': 'Usun wszystkie powiadomienia',
    'notifications_delete_all_message': 'Usunac wszystkie dzisiejsze powiadomienia?',
    'notifications_delete_failed': 'Nie udalo sie usunac powiadomien.',
    'notifications_guide_title': 'Przewodnik po poziomach powiadomien',
    'notifications_level_health': 'Normalny',
    'notifications_level_health_desc': 'Samopoczucie podopiecznego potwierdzone prawidlowo',
    'notifications_level_caution': 'Uwaga',
    'notifications_level_caution_desc': 'Brak sygnału o samopoczuciu lub aktywności telefonu',
    'notifications_level_warning': 'Ostrzezenie',
    'notifications_level_warning_desc': 'Brak sygnału o samopoczuciu lub aktywności telefonu przez kilka dni z rzędu',
    'notifications_level_urgent': 'Pilne',
    'notifications_level_urgent_desc': 'Natychmiastowa kontrola wymagana',
    'notifications_level_info': 'Informacja',
    'notifications_level_info_desc': 'Kroki, niski poziom baterii i inne powiadomienia',
    'notifications_activity_note':
        '※ Informacje o aktywnosci moga nie byc wyswietlane, jesli nie udalo sie zebrac danych o krokach.',

    // ── Ustawienia powiadomien opiekuna ──
    'notification_settings_title': 'Ustawienia powiadomien',
    'notification_settings_push': 'Powiadomienia push',
    'notification_settings_all': 'Wszystkie powiadomienia',
    'notification_settings_all_desc':
        'Wlacz lub wylacz wszystkie kategorie powiadomien jednoczesnie.',
    'notification_settings_level_section': 'Ustawienia poziomow',
    'notification_settings_urgent': 'Alerty pilne',
    'notification_settings_urgent_desc': 'Alertow pilnych nie mozna wylaczyc',
    'notification_settings_warning': 'Alerty ostrzegawcze',
    'notification_settings_warning_desc': 'Alert przy braku sprawdzenia przez 2 kolejne dni',
    'notification_settings_caution': 'Alerty uwagi',
    'notification_settings_caution_desc': 'Alert przy braku dzisiejszego sprawdzenia',
    'notification_settings_info': 'Alerty informacyjne',
    'notification_settings_info_desc': 'Ogolne alerty, takie jak liczba krokow i stan baterii',
    'notification_settings_dnd': 'Nie przeszkadzac',
    'notification_settings_dnd_start': 'Czas rozpoczecia',
    'notification_settings_dnd_end': 'Czas zakonczenia',
    'notification_settings_dnd_note':
        '※ Alerty pilne sa dostarczane nawet w trybie Nie przeszkadzac',
    'notification_settings_dnd_start_default': '22:00',
    'notification_settings_dnd_end_default': '7:00',

    // ── Zarzadzanie polaczeniami opiekuna ──
    'connection_title': 'Zarzadzanie polaczeniami',
    'connection_managed_count': 'Liczba podopiecznych ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Polaczeni podopieczni',
    'connection_empty': 'Brak połączonych podopiecznych',
    'connection_unlink_warning': 'Odlaczenie spowoduje usuniecie danych podopiecznego.',
    'connection_unlink_warning_detail':
        'Poprzednich zapisow nie mozna odzyskac po ponownym polaczeniu. Bedzie trzeba ponownie wprowadzic kod podopiecznego.',
    'connection_heartbeat_schedule': 'Codziennie o @time',
    'connection_heartbeat_report_time': 'Czas raportu samopoczucia: ',
    'connection_subject_label': 'Podopieczny',
    'connection_change_only_in_app': 'mozna zmienic tylko w aplikacji',
    'connection_edit_title': 'Edytuj podopiecznego',
    'connection_alias_label': 'Alias',
    'connection_unlink_title': 'Odlacz',
    'connection_unlink_confirm': 'Odlaczyc @alias?',
    'connection_unlink_success': 'Odlaczono pomyslnie.',
    'connection_unlink_failed': 'Nie udalo sie odlaczyc.',
    'connection_load_failed': 'Nie udalo sie zaladowac listy.',

    // ── Dolna nawigacja opiekuna ──
    'nav_home': 'Glowna',
    'nav_connection': 'Polaczenia',
    'nav_notification': 'Alerty',
    'nav_settings': 'Ustawienia',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'Zmien czas sprawdzenia',
    'heartbeat_schedule_title_ios': 'Czas powiadomienia push o pomyślności',
    'heartbeat_schedule_change_title_ios': 'Zmień czas powiadomienia push o pomyślności',
    'heartbeat_schedule_hint_ios':
        'Powiadomienie push o pomyślności przychodzi codziennie o tej godzinie. Dotknij powiadomienia lub otwórz aplikację o tej porze, aby wysłać sygnał pomyślności.',
    'heartbeat_daily_time': 'Codziennie o @time',
    'heartbeat_scheduled_today': 'Twój sygnał pomyślności będzie codziennie wysyłany do Twoich opiekunów o @time.',
    'heartbeat_change_failed_title': 'Zmiana czasu nie powiodla sie',
    'heartbeat_change_failed_message': 'Nie udalo sie zaktualizowac na serwerze.',

    // ── Powiadomienia lokalne ──
    'local_notification_channel': 'Alerty samopoczucia',
    'local_notification_channel_desc': 'Powiadomienia uslugi sprawdzania samopoczucia',

    // ── Inne ──
    'back_press_exit': 'Nacisnij ponownie, aby wyjsc.',

    // ── Bledy API ──
    'error_unknown': 'Wystapil nieznany blad.',
    'error_timeout': 'Uplynal czas zadania.',
    'error_network': 'Prosze sprawdzic polaczenie sieciowe.',
    'error_unauthorized': 'Wymagane uwierzytelnienie.',

    // ── Tresci powiadomien ──
    'noti_auto_report_body': 'Zaplanowane sprawdzenie samopoczucia zostalo odebrane dzisiaj.',
    'noti_manual_report_body': 'Osoba chroniona reczne wyslala sprawdzenie samopoczucia.',
    'noti_battery_low_body': 'Bateria telefonu ponizej 20%. Moze byc potrzebne ladowanie.',
    'noti_battery_dead_body':
        'Telefon wydaje sie byc wylaczony z powodu rozladowanej baterii. Ostatni poziom baterii: @battery_level%. Przywroci sie po naladowaniu.',
    'noti_caution_suspicious_body':
        'Odebrano sygnal samopoczucia, ale brak oznak korzystania z telefonu. Prosze sprawdzic osobiscie.',
    'noti_caution_missing_body':
        'Zaplanowane na dzisiaj sprawdzenie samopoczucia nie zostalo jeszcze odebrane. Prosze sprawdzic osobiscie.',
    'noti_warning_body':
        'Sprawdzenia samopoczucia zostaly pominiete z rzedu. Prosze zweryfikowac osobiscie.',
    'noti_warning_suspicious_body':
        'Nie wykryto kolejno oznak uzycia telefonu. Wymagana osobista weryfikacja.',
    'noti_urgent_body':
        'Brak sprawdzenia samopoczucia od @days dni. Wymagana natychmiastowa weryfikacja.',
    'noti_urgent_suspicious_body':
        'Brak oznak uzycia telefonu od @days dni. Wymagana natychmiastowa weryfikacja.',
    'noti_steps_body': 'Dzisiaj wykonano @steps krokow.',
    'noti_emergency_body':
        'Osoba pod opieką bezpośrednio poprosiła o pomoc. Proszę natychmiast sprawdzić.',
    'noti_resolved_body': 'Kontrola dobrostanu podopiecznego wróciła do normy.',
    'noti_cleared_by_guardian_title': '✅ Bezpieczeństwo potwierdzone',
    'noti_cleared_by_guardian_body': 'Jeden z opiekunów osobiście potwierdził bezpieczeństwo.',

    // ── Powiadomienia lokalne ──
    'local_alarm_title': '💗 Wymagane sprawdzenie samopoczucia',
    'local_alarm_body': 'Proszę dotknąć tego powiadomienia.',
    'wellbeing_check_title': '💛 Sprawdzenie samopoczucia',
    'wellbeing_check_body': 'Czy wszystko w porządku? Proszę dotknąć tego powiadomienia.',
    'noti_channel_name': 'Powiadomienia Anbu',
    'notification_send_failed_title': '📶 Sprawdź połączenie internetowe',
    'notification_send_failed_body': 'Otwórz aplikację, aby ponownie wysłać raport zdrowia.',
  };
}
