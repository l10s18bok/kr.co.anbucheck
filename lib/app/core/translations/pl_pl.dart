abstract class PlPl {
  static const Map<String, String> translations = {
    // ── Ogolne ──
    'common_confirm': 'Potwierdź',
    'common_cancel': 'Anuluj',
    'common_continue': 'Kontynuuj',
    'common_save': 'Zapisz',
    'common_delete': 'Usuń',
    'common_close': 'Zamknij',
    'common_next': 'Dalej',
    'common_previous': 'Wstecz',
    'common_start': 'Rozpocznij',
    'common_skip': 'Pomiń',
    'common_later': 'Później',
    'common_loading': 'Ładowanie...',
    'common_error': 'Błąd',
    'common_session_expired': 'Dane konta wygasły. Proszę zarejestrować się ponownie.',
    'common_complete': 'Gotowe',
    'common_notice': 'Informacja',
    'common_unlink': 'Odłącz',
    'common_am': 'AM',
    'common_pm': 'PM',
    'common_time_style': 'h24',
    'common_normal': 'Normalny',
    'common_connected': 'Połączono',
    'common_disconnected': 'Brak połączenia',

    // ── Marka aplikacji ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Sprawdzamy, czy wszystko u Ciebie w porządku.',
    'app_service_desc': 'Automatyczna usługa sprawdzania samopoczucia',
    'app_guardian_title': 'Opiekun Anbu',
    'app_copyright': '© 2026 Averic Lab',

    // ── Splash ──
    'splash_loading': 'Sprawdzanie samopoczucia...',

    // ── Aktualizacja ──
    'update_required_title': 'Wymagana aktualizacja',
    'update_required_message':
        'Proszę zaktualizować do wersji @version, aby kontynuować korzystanie z aplikacji.',
    'update_button': 'Aktualizuj',
    'update_available_title': 'Dostępna aktualizacja',
    'update_available_message': 'Dostępna jest wersja @version.',
    'update_later_button': 'Później',

    // ── Wybor trybu ──
    'mode_select_title': 'Jak chcesz zacząć?',
    'mode_select_subtitle': 'Powiedz, czy dajesz znak życia, czy go odbierasz',
    'mode_subject_title': 'Chcę tylko dać znak życia',
    'mode_subject_desc': 'Bardzo prosty ekran, tylko to, co niezbędne',
    'mode_subject_button': 'Daj znak życia →',
    'mode_guardian_title': 'Możesz czuwać nad kilkoma osobami',
    'mode_guardian_desc': 'W razie potrzeby później możesz też dawać znak życia',
    'mode_guardian_button': 'Odbieraj znaki →',
    'mode_subject_badge': 'Senior',
    'mode_guardian_badge': 'Opiekun',
    'mode_select_notice': 'Układ ekranu będzie się różnić w zależności od wyboru',

    // ── Uprawnienia ──
    'permission_title': 'Do korzystania z aplikacji\nwymagane są uprawnienia',
    'permission_notification': 'Uprawnienie do powiadomień',
    'permission_notification_subject_desc': 'Wymagane do otrzymywania powiadomień o samopoczuciu',
    'permission_notification_guardian_desc':
        'Wymagane do otrzymywania powiadomień o bezpieczeństwie podopiecznych',
    'permission_activity': 'Rozpoznawanie aktywności',
    'permission_activity_desc': 'Służy do wykrywania kroków i potwierdzania aktywności',
    'permission_location': 'Lokalizacja',
    'permission_location_desc': 'Udostepniana opiekunom tylko przy wysłaniu wezwania pomocy',
    'permission_tracking': 'Śledzenie reklam',
    'permission_tracking_desc': 'Używane do wyświetlania spersonalizowanych reklam',
    'location_permission_warning':
        'Lokalizacja nie zostanie wysłana przy wezwaniu pomocy. Dotknij, aby zezwolić.',
    'location_permission_settings_title': 'Wymagane uprawnienie lokalizacji',
    'location_permission_settings_body_ios':
        "Znajdź i wybierz 'Anbu', a następnie w 'Lokalizacja' wybierz 'Podczas korzystania z aplikacji'.",
    'location_permission_settings_body_android':
        "Wybierz 'Uprawnienia' → 'Lokalizacja', a następnie 'Zezwalaj tylko podczas korzystania z aplikacji'.",
    'permission_activity_dialog_title': 'Informacja o uprawnieniu aktywności',
    'permission_activity_dialog_message':
        'Służy do wykrywania kroków i potwierdzania aktywności.\nProszę wybrać "Zezwól" na następnym ekranie.',
    'permission_notification_required_title': 'Wymagane uprawnienie do powiadomień',
    'permission_notification_required_message':
        'Uprawnienie do powiadomień jest wymagane dla usługi sprawdzania samopoczucia.\nProszę włączyć je w Ustawieniach.',
    'permission_go_to_settings': 'Przejdź do Ustawień',
    'permission_activity_denied_title': 'Wymagane uprawnienie aktywności fizycznej',
    'permission_activity_denied_message':
        'Uprawnienie aktywności fizycznej jest wymagane do wykrywania kroków i weryfikacji Twojego bezpieczeństwa.\n\nBez tego uprawnienia informacje o krokach nie będą wysyłane do opiekunów.\n\nWłącz uprawnienie "Aktywność fizyczna" w ustawieniach aplikacji.',
    'permission_battery': 'Wyłączenie z optymalizacji baterii',
    'permission_battery_desc':
        'Wyłącza aplikację z optymalizacji baterii, aby codzienne sprawdzanie samopoczucia nie było pomijane o zaplanowanej godzinie',
    'permission_hibernation_title': 'Wyłącz automatyczne usuwanie uprawnień',
    'permission_hibernation_highlight': 'automatyczne usuwanie uprawnień',
    'permission_hibernation_message':
        'Android automatycznie usuwa uprawnienia aplikacji, których nie używasz przez dłuższy czas. Anbu zazwyczaj działa bez Twojego otwierania, więc ta funkcja może spowodować, że po pewnym czasie uprawnienia znikną, a sygnał samopoczucia przestanie być wysyłany.\n\nDotknij [Otwórz ustawienia] poniżej — odpowiedni ekran z przełącznikiem pojawi się od razu. Wyłącz przełącznik.\n\n※ Dokładne sformułowania mogą się różnić w zależności od producenta urządzenia.',
    'permission_hibernation_go_to_settings': 'Otwórz ustawienia',
    'stability_battery_warning_short': 'Wymagane wyłączenie ograniczeń użycia baterii',
    'stability_battery_dialog_title': 'Wyłączenie ograniczeń użycia baterii',
    'stability_battery_dialog_message':
        'Gdy telefon przechodzi w tryb oszczędzania energii, sygnały samopoczucia wysyłane do Twojego opiekuna mogą docierać z opóźnieniem lub być utracone.\n\nPo dotknięciu [Otwórz ustawienia] poniżej ustaw "Bateria" → "Bez ograniczeń". Dzięki temu sygnały samopoczucia będą codziennie niezawodnie wysyłane o zaplanowanej godzinie.\n\n※ Dokładne sformułowania mogą się różnić w zależności od producenta urządzenia.',

    // ── Onboarding ──
    'onboarding_safety_code_title': 'Twój kod bezpieczeństwa jest tworzony automatycznie',
    'onboarding_safety_code_desc':
        'Udostępnij ten kod opiekunowi, aby się połączyć —\ntwój sygnał dobrego samopoczucia będzie wysyłany automatycznie.',
    'onboarding_emergency_title': 'Gdy chcesz przekazać swój aktualny stan (Pilne) i lokalizację',
    'onboarding_emergency_desc':
        'Dotknij tego przycisku, a wiadomość dotrze\nnatychmiast do wszystkich Twoich opiekunów',
    'onboarding_gs_switch_title': 'Zadbaj też o samopoczucie swojej rodziny',
    'onboarding_gs_switch_desc':
        'Dotknij [Zarządzaj też samopoczuciem rodziny] w menu,\naby korzystać także z roli opiekuna',
    'onboarding_add_subject_title': 'Połącz się z bliską osobą',
    'onboarding_add_subject_desc':
        'Wpisz otrzymany kod i pseudonim,\naby połączyć się od razu',
    'onboarding_notifications_title': 'Tak wyglądają powiadomienia o samopoczuciu',
    'onboarding_notifications_desc':
        'Zwykle widzisz informacje o aktywności, np. liczbę kroków. Gdy sygnał nie dotrze lub nie wykryto aktywności, otrzymasz powiadomienie jak powyżej',
    'onboarding_push_now': 'Teraz',
    'onboarding_gs_enable_title': 'Aktywuj własny kod bezpieczeństwa',
    'onboarding_gs_enable_desc':
        'W Ustawieniach dotknij [Utwórz mój kod bezpieczeństwa],\naby Twoje samopoczucie trafiało też do opiekunów',
    'onboarding_role_subject': 'Podopieczny',
    'onboarding_role_guardian': 'Opiekun',
    'onboarding_role_guardian_subject': 'Opiekun i podopieczny',
    'onboarding_already_registered_title': 'Urządzenie już zarejestrowane',
    'onboarding_already_registered_message':
        'To urządzenie jest już zarejestrowane w trybie "@roleLabel".\nKontynuować jako "@roleLabel"?\n\nCzy przejść na tryb "@newRoleLabel"?\nZmiana usunie wszystkie istniejące dane.',
    'onboarding_already_registered_message_gs':
        'To urządzenie jest już zarejestrowane w trybie „@roleLabel".\nPrzełączenie na tryb „@newRoleLabel" usunie wszystkie dane opiekuna i podopiecznego.',
    'onboarding_registration_failed_title': 'Rejestracja nie powiodła się',
    'onboarding_registration_failed_message':
        'Nie można połączyć z serwerem. Proszę spróbować ponownie później.',

    // ── Strona glowna podopiecznego ──
    'subject_home_share_title': 'Udostepnij swój kod bezpieczeństwa',
    'subject_home_guardian_count': 'Połączeni opiekunowie: @count',
    'subject_home_check_title_last': 'Ostatnie sprawdzenie',
    'subject_home_check_title_scheduled': 'Zaplanowany czas sprawdzenia',
    'subject_home_check_title_checking': 'Sprawdzanie samopoczucia',
    'subject_home_check_body_reported': 'Zgłoszone o @time',
    'subject_home_check_body_scheduled': 'Zaplanowane na @time',
    'subject_home_check_body_waiting': 'Oczekiwanie od @time',
    'subject_home_battery_status': 'Stan baterii',
    'subject_home_battery_charging': 'Ładowanie',
    'subject_home_battery_full': 'Pełna',
    'subject_home_battery_low': 'Niski poziom baterii',
    'subject_home_connectivity_status': 'Stan połączenia',
    'subject_home_report_loading': 'Zgłaszanie...',
    'subject_home_report_button': 'Zgłoś bezpieczeństwo teraz',
    'subject_home_report_desc': 'Powiadom opiekuna, że wszystko w porządku',
    'subject_home_emergency_button': 'Potrzebuję pomocy',
    'subject_home_emergency_desc': 'Wysyła alarm awaryjny do opiekunów',
    'subject_home_emergency_loading': 'Wysyłanie alarmu awaryjnego...',
    'subject_home_emergency_sent': 'Alarm awaryjny został wysłany',
    'subject_home_emergency_failed': 'Nie udało się wysłać alarmu awaryjnego',
    'subject_home_manual_report_limit_reached':
        'Wysłałeś już dzisiejszy raport bezpieczeństwa. Spróbuj ponownie jutro.',
    'subject_home_manual_report_sent': 'Twój sygnał samopoczucia został wysłany do opiekunów.',
    'safety_net_dialog_title': 'Sprawdzenie wysłane',
    'safety_net_dialog_body':
        'Dzisiejsze sprawdzenie samopoczucia zostało wysłane do opiekunów.',
    'safety_net_dialog_already_body':
        'Dzisiejsze sprawdzenie samopoczucia zostało już wysłane do opiekunów o @time.',
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
    'emergency_location_permission_denied_snackbar':
        'Alarm awaryjny wysłany bez uprawnień do lokalizacji',
    'subject_home_emergency_confirm_send': 'Wyślij prośbę awaryjną',
    'emergency_message_hint': 'Dodaj wiadomość (opcjonalnie)',
    'subject_home_share_text':
        'Połącz się że mną w aplikacji Anbu.\nKod połączenia: @code',
    'subject_home_share_subject': 'Kod połączenia Anbu',
    'subject_home_code_copied': 'Kod skopiowany',

    // ── Szuflada podopiecznego ──
    'drawer_light_mode': 'Tryb jasny',
    'drawer_dark_mode': 'Tryb ciemny',
    'drawer_privacy_policy': 'Polityka prywatności',
    'drawer_terms': 'Regulamin',
    'drawer_withdraw': 'Usuń konto',
    'drawer_withdraw_message': 'Twoje konto i wszystkie dane zostaną usunięte.\nCzy na pewno?',

    // ── Panel opiekuna ──
    'guardian_status_normal': 'W porządku',
    'guardian_status_caution': 'Uwaga',
    'guardian_status_warning': 'Ostrzeżenie',
    'guardian_status_urgent': 'Pilne',
    'guardian_status_confirmed': '✅ W porządku',
    'guardian_subscription_expired': 'Wymagana subskrypcja',
    'guardian_subscription_expired_message':
        'Codzienne wiadomości o bliskich ustały.\nZa cenę jednego obiadu czuwaj nad bliską osobą przez cały rok.',
    'guardian_subscribe': 'Subskrybuj',
    'guardian_payment_preparing': 'Funkcja płatności wkrotce dostępna.',
    'guardian_today_summary': 'Dzisiejsze podsumowanie',
    'guardian_no_subjects': 'Brak połączonych podopiecznych.',
    'guardian_checking_subjects': 'Aktualnie sprawdzamy\npodopiecznych: @count',
    'guardian_subject_list': 'Lista podopiecznych',
    'guardian_call_now': 'Zadzwoń teraz',
    'phone_call_failed': 'Nie można nawiązać połączenia.',
    'guardian_confirm_safety': 'Potwierdź',
    'guardian_no_check_history': 'Brak historii sprawdzeń',
    'guardian_last_check_now': 'Ostatnie sprawdzenie: właśnie teraz',
    'guardian_last_check_minutes': 'Ostatnie sprawdzenie: @minutes min temu',
    'guardian_last_check_hours': 'Ostatnie sprawdzenie: @hours godz. temu',
    'guardian_last_check_days': 'Ostatnie sprawdzenie: @days dni temu',
    'guardian_activity_stable': 'Aktywność: Stabilna',
    'guardian_activity_prefix': 'Aktywność',
    'guardian_activity_very_active': 'Bardzo aktywny',
    'guardian_activity_active': 'Aktywny',
    'guardian_activity_needs_exercise': 'Potrzeba ruchu',
    'guardian_activity_collecting': 'Zbieranie danych',
    'guardian_error_load_step_history': 'Nie udało się wczytać historii kroków',
    'guardian_chart_y_axis_steps': 'Kroki',
    'guardian_chart_x_axis_last_7_days': 'Ostatnie 7 dni',
    'guardian_chart_x_axis_last_30_days': 'Ostatnie 30 dni',
    'guardian_chart_today': 'Dziś',
    'guardian_safety_needed': 'Wymagane sprawdzenie',
    'guardian_error_load_subjects': 'Nie udalo się załadować listy podopiecznych.',
    'guardian_safety_confirmed': 'Bezpieczeństwo potwierdzone.',
    'guardian_error_clear_alerts': 'Nie udalo się usunąć alertow.',

    // ── Dodawanie podopiecznego ──
    'add_subject_title': 'Połącz podopiecznego',
    'add_subject_guide_title': 'Wprowadź unikalny kod podopiecznego i alias.',
    'add_subject_guide_subtitle':
        'Połącz aplikacje podopiecznego, aby monitorować jego zdrowie i aktywność w czasie rzeczywistym.',
    'add_subject_code_label': 'Unikalny kod (7 znaków)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info': 'Unikalny kod można znaleźć w aplikacji podopiecznego.',
    'add_subject_alias_label': 'Alias podopiecznego',
    'add_subject_alias_hint': 'np. Mama, Tata',
    'add_subject_phone_label': 'Numer telefonu (opcjonalnie)',
    'add_subject_phone_info': 'Jesli podasz numer, przycisk połączenia zadzwoni bezpośrednio na niego. Jesli zostawisz puste, kontakt trzeba wybrać z listy ręcznie.',
    'add_subject_phone_hint': '512345678',
    'add_subject_connect': 'Połącz',
    'add_subject_error_login': 'Wymagane logowanie.',
    'add_subject_success': 'Podopieczny został połączony.',
    'add_subject_error_invalid_code': 'Nieprawidłowy kod.',
    'add_subject_error_self': 'Nie możesz dodać własnego kodu jako podopiecznego.',
    'add_subject_error_limit': 'Możesz zarejestrować maksymalnie @max osób.',
    'add_subject_error_already_connected': 'Już połączony.',
    'add_subject_error_failed': 'Połączenie nie powiodło się. Proszę spróbować ponownie.',
    'add_subject_button': 'Dodaj nowego podopiecznego',

    // ── Ustawienia opiekuna ──
    'settings_title': 'Ustawienia',
    'settings_light_mode': 'Tryb jasny',
    'settings_dark_mode': 'Tryb ciemny',
    'settings_connection_management': 'Zarządzanie połączeniami',
    'settings_managed_subjects': 'Liczba podopiecznych',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'Subskrypcja i usługi',
    'settings_current_membership': 'Obecne członkostwo',
    'settings_premium': 'Aktywna subskrypcja Premium',
    'guardian_go_to_settings': 'Przejdź do ustawień',
    'settings_expired': 'Wymagana subskrypcja',
    'settings_days_until_renewal': 'D-@days',
    'settings_days_until_trial_end': 'D-@days',
    'settings_free_trial': 'Okres próbny',
    'settings_manage_subscription': 'Zarządzaj subskrypcja',
    'settings_notification': 'Ustawienia powiadomień',
    'settings_terms_section': 'Prawne',
    'settings_privacy_policy': 'Polityka prywatności',
    'settings_terms': 'Regulamin',
    'settings_ad_consent': 'Ustawienia zgody na reklamy',
    'settings_app_version': 'Wersja: v@version',

    // ── Zakupy w aplikacji (roczna subskrypcja Opiekuna $9.99) ──
    'subscription_subscribe': 'Subskrybuj',
    'trial_ended_noti_title': 'Anbu',
    'trial_ended_noti_body': 'Twój bezpłatny okres próbny dobiegł końca. Subskrybuj, aby kontynuować.',
    'subscription_restore': 'Przywróć zakup',
    'subscription_store_unavailable': 'Sklep niedostępny',
    'subscription_product_unavailable': 'Subskrypcja niedostępna',
    'subscription_purchase_failed': 'Zakup nie powiódł się',
    'subscription_verify_failed': 'Weryfikacja subskrypcji nie powiodła się',
    'subscription_restore_failed': 'Przywracanie nie powiodło się',
    'subscription_restore_nothing': 'Brak subskrypcji do przywrócenia',
    'subscription_restore_success': 'Subskrypcja przywrócona',
    'subscription_purchase_success': 'Subskrypcja rozpoczęta',
    'subscription_period_annual': 'rok',

    // ── G+S (Opiekun + Podopieczny) ──
    'gs_enable_button': 'Utwórz mój kod bezpieczeństwa',
    'gs_safety_code_button': 'Sprawdź mój kod bezpieczeństwa',
    'gs_enable_button_desc': 'Bliscy też mogą sprawdzić, jak się masz',
    'gs_safety_code_button_desc': 'Kod · Zgłoszenie · Alarm',
    'gs_safety_code_title': 'Mój kod bezpieczeństwa',
    'gs_enable_dialog_title': 'Utwórz mój kod bezpieczeństwa',
    'gs_enable_dialog_body':
        'Zostanie wydany kod bezpieczeństwa — udostępnij go innym opiekunom.',
    'gs_enable_dialog_ios_warning_title': '⚠ Jak wysyłany jest sygnał samopoczucia',
    'gs_enable_dialog_ios_warning_body':
        'Codziennie o ustalonej godzinie pojawia się "powiadomienie push o samopoczuciu". Aby Twój sygnał samopoczucia został wysłany, musisz dotknąć powiadomienia lub samodzielnie otworzyć aplikację o tej porze. Jeśli nie otworzysz aplikacji, Twoi opiekunowie mogą otrzymać alert o nieudanej kontroli.',
    'gs_enable_dialog_ios_confirm': 'Rozumiem, włącz',
    'gs_enable_confirm': 'Utwórz',
    'gs_enabled_message': 'Ochrona została włączona',
    'gs_enable_failed': 'Nie udało się włączyć ochrony',
    'gs_disable_dialog_title': 'Wyłącz ochronę',
    'gs_disable_dialog_body':
        'Wyłączenie ochrony usunie twój kod bezpieczeństwa i zatrzyma wysyłanie kontroli do połączonych opiekunów.',
    'gs_disable_confirm': 'Wyłącz',
    'gs_disabled_message': 'Ochrona została wyłączona',
    'gs_disable_failed': 'Nie udało się wyłączyć ochrony',
    'gs_activity_permission_denied_warning':
        'Uprawnienie krokomierza odrzucone. Dotknij tutaj, aby zezwolić.',
    'gs_activity_permission_settings_title': 'Wymagane uprawnienie',
    'gs_activity_permission_settings_body':
        'Zezwól na uprawnienie Aktywność fizyczna (Ruch i sprawność) w ustawieniach aplikacji.',
    'gs_activity_permission_settings_go': 'Przejdź do Ustawień',

    // ── Tryb opiekuna → G+S (Szuflada/Dialog) ──
    'drawer_enable_guardian': 'Zarządzaj też samopoczuciem rodziny',
    's_to_gs_dialog_title': 'Dodaj funkcję opiekuna',
    's_to_gs_dialog_body':
        'Dodaj funkcję opiekuna, aby móc również czuwać nad samopoczuciem rodziny lub bliskich.\n(Uwaga: funkcja opiekuna jest bezpłatna przez 3 miesiące, po czym przechodzi w płatną subskrypcję.)\n\nTwój własny kod bezpieczeństwa i obecnie używane wysyłanie sygnałów samopoczucia pozostaną bez zmian i nadal będą bezpłatne.',
    's_to_gs_dialog_confirm': 'Kontynuuj',
    's_to_gs_switch_failed': 'Nie udało się włączyć funkcji opiekuna',

    // ── Powiadomienia opiekuna ──
    'notifications_title': 'Powiadomienia',
    'notifications_today': 'Dzisiejsze powiadomienia',
    'notifications_empty': 'Brak powiadomień na dzisiaj',
    'notifications_delete_all_title': 'Usuń wszystkie powiadomienia',
    'notifications_auto_delete_notice':
        'Dzisiejsze powiadomienia są automatycznie usuwane o północy (0:00).',
    'notifications_delete_all_message': 'Usunąć wszystkie dzisiejsze powiadomienia?',
    'notifications_delete_failed': 'Nie udalo się usunąć powiadomień.',
    'notifications_guide_title': 'Przewodnik po poziomach powiadomień',
    'notifications_level_health': 'Normalny',
    'notifications_level_health_desc': 'Samopoczucie podopiecznego potwierdzone prawidłowo',
    'notifications_level_caution': 'Uwaga',
    'notifications_level_caution_desc': 'Brak sygnału o samopoczuciu lub zapisu aktywności',
    'notifications_level_warning': 'Ostrzeżenie',
    'notifications_level_warning_desc':
        'Brak sygnału o samopoczuciu lub zapisu aktywności przez kilka dni z rzędu',
    'notifications_level_urgent': 'Pilne',
    'notifications_level_urgent_desc': 'Natychmiastowa kontrola wymagana',
    'notifications_level_info': 'Informacja',
    'notifications_level_info_desc': 'Kroki, niski poziom baterii i inne powiadomienia',
    'notifications_activity_note':
        '※ Liczba kroków to kroki skumulowane od północy do czasu wysłania sygnału samopoczucia.',

    // ── Ustawienia powiadomien opiekuna ──
    'notification_settings_title': 'Ustawienia powiadomień',
    'notification_settings_push': 'Powiadomienia push',
    'notification_settings_all': 'Wszystkie powiadomienia',
    'notification_settings_all_desc':
        'Włącz lub wyłącz wszystkie kategorie powiadomień jednocześnie.',
    'notification_settings_level_section': 'Ustawienia poziomów',
    'notification_settings_urgent': 'Alerty pilne',
    'notification_settings_urgent_desc': 'Alertów pilnych nie można wyłączyć',
    'notification_settings_warning': 'Alerty ostrzegawcze',
    'notification_settings_warning_desc': 'Alert przy braku sprawdzenia przez 2 kolejne dni',
    'notification_settings_caution': 'Alerty uwagi',
    'notification_settings_caution_desc': 'Alert przy braku dzisiejszego sprawdzenia',
    'notification_settings_info': 'Alerty informacyjne',
    'notification_settings_info_desc': 'Ogólne alerty, takie jak liczba kroków i stan baterii',
    'notification_settings_dnd': 'Nie przeszkadzać',
    'notification_settings_dnd_start': 'Czas rozpoczęcia',
    'notification_settings_dnd_end': 'Czas zakończenia',
    'notification_settings_dnd_note':
        '※ Alerty pilne są dostarczane nawet w trybie Nie przeszkadzać',

    // ── Zarzadzanie polaczeniami opiekuna ──
    'connection_title': 'Zarządzanie połączeniami',
    'connection_managed_count': 'Liczba podopiecznych ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Połączeni podopieczni',
    'connection_reorder_hint': 'Przytrzymaj kartę poniżej, aby zmienić kolejność',
    'connection_empty': 'Brak połączonych podopiecznych',
    'connection_unlink_warning': 'Odłączenie spowoduje usunięcie danych podopiecznego.',
    'connection_unlink_warning_detail':
        'Poprzednich zapisów nie można odzyskać po ponownym połączeniu. Będzie trzeba ponownie wprowadzić kod podopiecznego.',
    'connection_heartbeat_schedule': 'Codziennie o @time',
    'connection_heartbeat_report_time': 'Czas raportu samopoczucia: ',
    'connection_subject_label': 'Podopieczny',
    'connection_change_only_in_app': 'można zmienić tylko w aplikacji',
    'connection_edit_title': 'Edytuj podopiecznego',
    'connection_alias_label': 'Alias',
    'connection_unlink_title': 'Odłącz',
    'connection_unlink_confirm': 'Odłączyć @alias?',
    'connection_unlink_success': 'Odłączono pomyślnie.',
    'connection_unlink_failed': 'Nie udalo się odłączyć.',
    'connection_load_failed': 'Nie udalo się załadować listy.',

    // ── Dolna nawigacja opiekuna ──
    'nav_home': 'Główna',
    'nav_connection': 'Połączenia',
    'nav_notification': 'Alerty',
    'nav_settings': 'Ustawienia',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'Zmień godzinę potwierdzenia',
    'heartbeat_schedule_title_ios': 'Godzina potwierdzenia',
    'heartbeat_schedule_change_title_ios': 'Zmień godzinę potwierdzenia',
    'heartbeat_schedule_hint_ios':
        'Powiadomienie push o samopoczuciu przychodzi codziennie o tej godzinie. Dotknij powiadomienia lub otwórz aplikację o tej porze, aby wysłać sygnał samopoczucia.',
    'heartbeat_daily_time': 'Codziennie o @time',
    'heartbeat_scheduled_today':
        'Twój sygnał samopoczucia będzie codziennie wysyłany do Twoich opiekunów o @time.',
    'heartbeat_change_failed_title': 'Zmiana czasu nie powiodła się',
    'heartbeat_change_failed_message': 'Nie udalo się zaktualizować na serwerze.',
    'heartbeat_picker_help': 'Wybierz godzinę przed @limit',
    'heartbeat_range_limit_title': 'Niedostępna godzina',
    'heartbeat_range_limit_message':
        'Godzina sprawdzenia musi być wcześniejsza niż @limit.',

    // ── Powiadomienia lokalne ──
    'local_notification_channel_desc': 'Powiadomienia usługi sprawdzania samopoczucia',

    // ── Inne ──
    'back_press_exit': 'Naciśnij ponownie, aby wyjść.',

    // ── Bledy API ──
    'error_unknown': 'Wystąpił nieznany błąd.',
    'error_timeout': 'Upłynął czas zadania.',
    'error_network': 'Proszę sprawdzić połączenie sieciowe.',
    'error_unauthorized': 'Wymagane uwierzytelnienie.',

    // ── Tresci powiadomien ──
    'noti_auto_report_body': 'Sprawdzenie samopoczucia zostało odebrane pomyślnie.',
    'noti_manual_report_body': 'Podopieczny ręcznie wysłał sprawdzenie samopoczucia.',
    'noti_battery_low_body': 'Bateria telefonu poniżej 20%. Może być potrzebne ładowanie.',
    'noti_battery_dead_body':
        'Telefon wydaje się być wyłączony z powodu rozładowanej baterii. Ostatni poziom baterii: @battery_level%. Przywróci się po naładowaniu.',
    'noti_caution_suspicious_body':
        'Odebrano sygnał samopoczucia, ale dziś nie wykryto zapisu aktywności. Proszę sprawdzić osobiście.',
    'noti_caution_missing_body':
        'Zaplanowane na dzisiaj sprawdzenie samopoczucia nie zostało jeszcze odebrane. Proszę sprawdzić osobiście.',
    'noti_warning_body':
        'Sprawdzenia samopoczucia zostały pominięte z rzędu. Proszę zweryfikować osobiście.',
    'noti_warning_suspicious_body':
        'Nie wykryto kolejno zapisu aktywności. Wymagana osobista weryfikacja.',
    'noti_urgent_body':
        'Brak sprawdzenia samopoczucia od @days dni. Wymagana natychmiastowa weryfikacja.',
    'noti_urgent_suspicious_body':
        'Brak zapisu aktywności od @days dni. Wymagana natychmiastowa weryfikacja.',
    'noti_steps_body': 'Dzisiaj wykonano @steps kroków.',
    'noti_emergency_body':
        'Podopieczny bezpośrednio poprosił o pomoc. Proszę natychmiast sprawdzić.',
    'noti_resolved_body': 'Samopoczucie podopiecznego wróciło do normy.',
    'noti_cleared_by_guardian_title': '✅ Bezpieczeństwo potwierdzone',
    'noti_cleared_by_guardian_body': 'Jeden z opiekunów osobiście potwierdził bezpieczeństwo.',

    // ── Powiadomienia lokalne ──
    'local_alarm_title': '💗 Wymagane sprawdzenie samopoczucia',
    'local_alarm_body': 'Proszę dotknąć tego powiadomienia.',
    // ── iOS 확장 전송 결과 / 오프라인 폴백 ──
    'nse_delivered_title': '✅ Sygnał o samopoczuciu wysłany',
    'nse_delivered_body': 'Dzisiejszy sygnał o samopoczuciu został przekazany opiekunowi.',
    'offline_alarm_title': '📶 Sprawdź połączenie z internetem',
    'offline_alarm_body': 'Dotknij tego powiadomienia, gdy wrócisz do sieci.\nW przeciwnym razie dzisiejszy sygnał nie zostanie wysłany.',
    'wellbeing_check_title': '💛 Sprawdzenie samopoczucia',
    'wellbeing_check_body': 'Czy wszystko w porządku? Proszę dotknąć tego powiadomienia.',
    'noti_channel_name': 'Powiadomienia Anbu',
    'notification_send_failed_title': '📶 Sprawdź połączenie internetowe',
    'notification_send_failed_body': 'Dotknij tej wiadomości, aby ponownie wysłać automatycznie.',
  };
}
