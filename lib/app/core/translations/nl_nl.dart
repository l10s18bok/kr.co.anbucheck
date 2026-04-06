abstract class NlNl {
  static const Map<String, String> translations = {
    // ── Algemeen ──
    'common_confirm': 'Bevestigen',
    'common_cancel': 'Annuleren',
    'common_continue': 'Doorgaan',
    'common_save': 'Opslaan',
    'common_delete': 'Verwijderen',
    'common_close': 'Sluiten',
    'common_next': 'Volgende',
    'common_previous': 'Vorige',
    'common_start': 'Beginnen',
    'common_skip': 'Overslaan',
    'common_later': 'Later',
    'common_loading': 'Laden...',
    'common_error': 'Fout',
    'common_complete': 'Gereed',
    'common_notice': 'Melding',
    'common_unlink': 'Ontkoppelen',
    'common_am': 'AM',
    'common_pm': 'PM',
    'common_normal': 'Normaal',
    'common_connected': 'Verbonden',
    'common_disconnected': 'Niet verbonden',

    // ── App-merk ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Wij controleren uw welzijn.',
    'app_service_desc': 'Automatische welzijnscontrole',
    'app_guardian_title': 'Anbu Beschermer',
    'app_copyright': '© 2024 TNS Inc.',

    // ── Splash ──
    'splash_loading': 'Welzijn wordt gecontroleerd...',

    // ── Update ──
    'update_required_title': 'Update vereist',
    'update_required_message':
        'Werk bij naar versie @version om de app te blijven gebruiken.',
    'update_button': 'Bijwerken',
    'update_available_title': 'Update beschikbaar',
    'update_available_message': 'Versie @version is beschikbaar.',

    // ── Modusselectie ──
    'mode_select_title': 'Kies uw rol',
    'mode_select_subtitle':
        'Dit helpt ons de juiste functies voor u in te stellen',
    'mode_subject_title':
        'Ik wil dat mijn veiligheid\nwordt bewaakt',
    'mode_subject_button': 'Ik wil beschermd worden →',
    'mode_guardian_title':
        'Ik wil over iemand\nwaken die ik liefheb',
    'mode_guardian_button': 'Start als beschermer →',
    'mode_select_notice':
        'De indeling en meldingen zullen verschillen op basis van uw keuze',

    // ── Machtigingen ──
    'permission_title':
        'Er zijn machtigingen nodig\nom de app te gebruiken',
    'permission_notification': 'Meldingstoestemming',
    'permission_notification_subject_desc':
        'Vereist om welzijnsmeldingen te ontvangen',
    'permission_notification_guardian_desc':
        'Vereist om veiligheidsmeldingen over uw beschermelingen te ontvangen',
    'permission_activity': 'Activiteitsherkenning',
    'permission_activity_desc':
        'Wordt gebruikt om stappen te detecteren en activiteit te bevestigen',
    'permission_activity_dialog_title':
        'Informatie over activiteitstoestemming',
    'permission_activity_dialog_message':
        'Wordt gebruikt om stappen te detecteren en activiteit te bevestigen.\nSelecteer "Toestaan" op het volgende scherm.',
    'permission_notification_required_title':
        'Meldingstoestemming vereist',
    'permission_notification_required_message':
        'De welzijnscontrole vereist meldingstoestemming.\nSchakel deze in via Instellingen.',
    'permission_go_to_settings': 'Ga naar Instellingen',

    // ── Onboarding ──
    'onboarding_title_1':
        'Maakt u zich zorgen om iemand\ndie alleen woont?',
    'onboarding_desc_1':
        'Zelfs van ver weg\nvraagt u zich af of het goed gaat.\nAnbu is er voor u.',
    'onboarding_title_2':
        'Welzijnscontrole\nzonder een woord',
    'onboarding_desc_2':
        'Gewoon door de smartphone te gebruiken\nwordt dagelijks automatisch\neen welzijnssignaal verzonden.',
    'onboarding_title_3':
        'Deel welzijn\nmet uw dierbaren',
    'onboarding_desc_3':
        'Dagelijkse controles groeien uit\ntot blijvende gemoedsrust.\nLaten we beginnen.',
    'onboarding_title_4':
        'Geen namen, geen telefoonnummers\n— niets wordt verzameld',
    'onboarding_desc_4':
        'Er wordt slechts één signaal verzonden:\n"Het gaat goed met mij."\nUw gegevens zijn veilig.',
    'onboarding_role_subject': 'Beschermeling',
    'onboarding_role_guardian': 'Beschermer',
    'onboarding_already_registered_title': 'Apparaat al geregistreerd',
    'onboarding_already_registered_message':
        'Dit apparaat is al geregistreerd in "@roleLabel"-modus.\nDoorgaan als "@roleLabel"?\n\nOf wisselen naar "@newRoleLabel"-modus?\nBij het wisselen worden alle bestaande gegevens verwijderd.',
    'onboarding_registration_failed_title': 'Registratie mislukt',
    'onboarding_registration_failed_message':
        'Kan geen verbinding maken met de server. Probeer het later opnieuw.',

    // ── Home beschermeling ──
    'subject_home_share_title': 'Deel uw veiligheidscode',
    'subject_home_guardian_count': 'Verbonden beschermers: @count',
    'subject_home_check_title_last': 'Laatste welzijnscontrole',
    'subject_home_check_title_scheduled': 'Geplande controle',
    'subject_home_check_title_checking': 'Welzijn wordt gecontroleerd',
    'subject_home_check_body_reported': 'Gemeld om @time',
    'subject_home_check_body_scheduled': 'Gepland om @time',
    'subject_home_check_body_waiting': 'Wacht sinds @time',
    'subject_home_battery_status': 'Batterijstatus',
    'subject_home_battery_charging': 'Opladen',
    'subject_home_battery_full': 'Vol',
    'subject_home_battery_low': 'Batterij bijna leeg',
    'subject_home_connectivity_status': 'Verbinding',
    'subject_home_report_loading': 'Wordt gemeld...',
    'subject_home_report_button': 'Meld nu dat het goed gaat',
    'subject_home_report_desc':
        'Laat uw beschermer weten dat het goed met u gaat',
    'subject_home_share_text':
        'Controleer hoe het met me gaat via de Anbu-app!\nUitnodigingscode: @code',
    'subject_home_share_subject': 'Anbu-uitnodigingscode',
    'subject_home_code_copied': 'Code gekopieerd',

    // ── Drawer beschermeling ──
    'drawer_light_mode': 'Lichte modus',
    'drawer_dark_mode': 'Donkere modus',
    'drawer_privacy_policy': 'Privacybeleid',
    'drawer_terms': 'Gebruiksvoorwaarden',
    'drawer_withdraw': 'Account verwijderen',
    'drawer_withdraw_message':
        'Uw account en alle gegevens worden verwijderd.\nWeet u het zeker?',

    // ── Dashboard beschermer ──
    'guardian_status_normal': 'Normaal',
    'guardian_status_caution': 'Let op',
    'guardian_status_warning': 'Waarschuwing',
    'guardian_status_urgent': 'Dringend',
    'guardian_status_confirmed': 'Veiligheid bevestigd',
    'guardian_subscription_expired': 'Abonnement verlopen',
    'guardian_subscription_expired_message':
        'Waarschuwingsmeldingen worden niet verzonden.\nVerleng uw abonnement om de bescherming voort te zetten.',
    'guardian_subscribe': 'Abonneren',
    'guardian_payment_preparing':
        'De betaalfunctie is binnenkort beschikbaar.',
    'guardian_today_summary': 'Welzijnsoverzicht van vandaag',
    'guardian_no_subjects': 'Geen beschermelingen verbonden.',
    'guardian_checking_subjects':
        'Momenteel controleren we\n@count beschermeling(en).',
    'guardian_subject_list': 'Lijst beschermelingen',
    'guardian_call_now': 'Nu bellen',
    'guardian_confirm_safety': 'Veiligheid bevestigen',
    'guardian_no_check_history': 'Geen controlegeschiedenis',
    'guardian_last_check_now': 'Laatste controle: zojuist',
    'guardian_last_check_minutes': 'Laatste controle: @minutes min geleden',
    'guardian_last_check_hours': 'Laatste controle: @hours uur geleden',
    'guardian_last_check_days': 'Laatste controle: @days dag(en) geleden',
    'guardian_activity_stable': 'Activiteit: stabiel',
    'guardian_safety_needed': 'Veiligheidscontrole nodig',
    'guardian_error_load_subjects':
        'Kan de lijst met beschermelingen niet laden.',
    'guardian_error_clear_alerts':
        'Kan waarschuwingen niet wissen.',

    // ── Beschermeling toevoegen ──
    'add_subject_title': 'Beschermeling koppelen',
    'add_subject_guide_title':
        'Voer de unieke code van de beschermeling\nen een bijnaam in.',
    'add_subject_guide_subtitle':
        'Koppel de app van een beschermeling om\ngezondheid en activiteit in realtime te volgen.',
    'add_subject_code_label': 'Unieke code (7 cijfers)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info':
        'De unieke code is te vinden in de app van de beschermeling.',
    'add_subject_alias_label': 'Bijnaam beschermeling',
    'add_subject_alias_hint': 'Bijv. Mama, Papa',
    'add_subject_connect': 'Verbinden',
    'add_subject_error_login': 'Inloggen vereist.',
    'add_subject_success': 'Beschermeling succesvol verbonden.',
    'add_subject_error_invalid_code': 'Ongeldige code.',
    'add_subject_error_already_connected': 'Al verbonden.',
    'add_subject_error_failed':
        'Verbinding mislukt. Probeer het later opnieuw.',
    'add_subject_button': 'Nieuwe beschermeling toevoegen',

    // ── Instellingen beschermer ──
    'settings_title': 'Instellingen',
    'settings_light_mode': 'Lichte modus',
    'settings_dark_mode': 'Donkere modus',
    'settings_connection_management': 'Verbindingsbeheer',
    'settings_managed_subjects': 'Beheerde beschermelingen',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'Abonnement en service',
    'settings_current_membership': 'Huidig lidmaatschap',
    'settings_premium': 'Premium actief',
    'settings_free_trial': 'Gratis proefperiode',
    'settings_manage_subscription': 'Abonnement beheren',
    'settings_notification': 'Meldingsinstellingen',
    'settings_terms_section': 'Juridisch',
    'settings_privacy_policy': 'Privacybeleid',
    'settings_terms': 'Gebruiksvoorwaarden',
    'settings_app_version': 'Versie: v@version',

    // ── Meldingen beschermer ──
    'notifications_title': 'Meldingen',
    'notifications_today': 'Meldingen van vandaag',
    'notifications_empty': 'Geen meldingen vandaag',
    'notifications_delete_all_title': 'Alle meldingen verwijderen',
    'notifications_delete_all_message':
        'Alle meldingen van vandaag verwijderen?',
    'notifications_delete_failed':
        'Kan meldingen niet verwijderen.',
    'notifications_guide_title': 'Gids meldingsniveaus',
    'notifications_level_health': 'Normaal',
    'notifications_level_health_desc':
        'Het welzijn van de beschermeling is normaal bevestigd',
    'notifications_level_caution': 'Let op',
    'notifications_level_caution_desc':
        'Een van de volgende:\n1. De geplande controle van vandaag ontbreekt\n2. Controle ontvangen maar geen telefoongebruik gedetecteerd',
    'notifications_level_warning': 'Waarschuwing',
    'notifications_level_warning_desc':
        'Een van de volgende:\n1. Geen controle gedurende 2 opeenvolgende dagen\n2. Geen telefoongebruik gedurende 2 opeenvolgende dagen',
    'notifications_level_urgent': 'Dringend',
    'notifications_level_urgent_desc':
        'Langdurig geen controle,\nof geen telefoongebruik gedurende meer dan 3 dagen',
    'notifications_level_info': 'Info',
    'notifications_level_info_desc':
        'Informatieve meldingen zoals\naantal stappen of lage batterij',
    'notifications_activity_note':
        '※ Activiteitsinformatie wordt mogelijk niet getoond als stapgegevens niet konden worden verzameld.',

    // ── Meldingsinstellingen beschermer ──
    'notification_settings_title': 'Meldingsinstellingen',
    'notification_settings_push': 'Pushmeldingen',
    'notification_settings_all': 'Alle meldingen',
    'notification_settings_all_desc':
        'Schakel alle meldingscategorieën tegelijk in of uit.',
    'notification_settings_level_section': 'Niveau-instellingen',
    'notification_settings_urgent': 'Dringende meldingen',
    'notification_settings_urgent_desc':
        'Dringende meldingen kunnen niet worden uitgeschakeld',
    'notification_settings_warning': 'Waarschuwingsmeldingen',
    'notification_settings_warning_desc':
        'Melding wanneer 2 dagen achtereen geen controle',
    'notification_settings_caution': 'Let op-meldingen',
    'notification_settings_caution_desc':
        'Melding wanneer de controle van vandaag ontbreekt',
    'notification_settings_info': 'Infomeldingen',
    'notification_settings_info_desc':
        'Algemene meldingen zoals aantal stappen en batterijstatus',
    'notification_settings_dnd': 'Niet storen',
    'notification_settings_dnd_start': 'Begintijd',
    'notification_settings_dnd_end': 'Eindtijd',
    'notification_settings_dnd_note':
        '※ Dringende meldingen worden ook tijdens Niet storen bezorgd',
    'notification_settings_dnd_start_default': '22:00',
    'notification_settings_dnd_end_default': '07:00',

    // ── Verbindingsbeheer beschermer ──
    'connection_title': 'Verbindingsbeheer',
    'connection_managed_count': 'Beheerde beschermelingen ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Verbonden beschermelingen',
    'connection_unlink_warning':
        'Bij ontkoppeling worden de gegevens van de beschermeling verwijderd.',
    'connection_unlink_warning_detail':
        'Eerdere gegevens kunnen na opnieuw koppelen niet worden hersteld.\nU moet de code van de beschermeling opnieuw invoeren.',
    'connection_heartbeat_schedule': 'Dagelijks om @time',
    'connection_heartbeat_report_time':
        'De welzijnsrapportagetijd is ',
    'connection_subject_label': 'Beschermeling',
    'connection_change_only_in_app':
        'kan alleen in de app worden gewijzigd',
    'connection_edit_title': 'Beschermeling bewerken',
    'connection_alias_label': 'Bijnaam',
    'connection_unlink_title': 'Ontkoppelen',
    'connection_unlink_confirm': '@alias ontkoppelen?',
    'connection_unlink_success': 'Ontkoppeling geslaagd.',
    'connection_unlink_failed': 'Ontkoppeling mislukt.',
    'connection_load_failed': 'Kan de lijst niet laden.',

    // ── Navigatie beschermer ──
    'nav_home': 'Home',
    'nav_connection': 'Verbinding',
    'nav_notification': 'Meldingen',
    'nav_settings': 'Instellingen',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'Controletijd wijzigen',
    'heartbeat_daily_time': 'Dagelijks om @time',
    'heartbeat_scheduled_today':
        'Welzijnscontrole gepland om @time vandaag.',
    'heartbeat_change_failed_title': 'Tijdswijziging mislukt',
    'heartbeat_change_failed_message':
        'Kan niet bijwerken op de server.',

    // ── Lokale meldingen ──
    'local_notification_channel': 'Welzijnsmeldingen',
    'local_notification_channel_desc':
        'Meldingen van de welzijnscontroleservice',

    // ── Overig ──
    'back_press_exit': 'Druk nogmaals op terug om af te sluiten.',

    // ── API-fouten ──
    'error_unknown': 'Er is een onbekende fout opgetreden.',
    'error_timeout': 'Het verzoek is verlopen.',
    'error_network': 'Controleer uw netwerkverbinding.',
    'error_unauthorized': 'Authenticatie vereist.',

    // ── Meldingsteksten ──
    'noti_auto_report_body':
        'De geplande welzijnscontrole is vandaag ontvangen.',
    'noti_manual_report_body':
        'De beschermde persoon heeft handmatig een welzijnscontrole verzonden.',
    'noti_battery_low_body':
        'De batterij van de telefoon is onder 20 %. Opladen kan nodig zijn.',
    'noti_battery_dead_body':
        'De telefoon lijkt uitgeschakeld door een lege batterij. Laatste batterijniveau: @battery_level %. Het herstelt automatisch na opladen.',
    'noti_caution_suspicious_body':
        'Er is een welzijnssignaal ontvangen, maar er zijn geen tekenen van telefoongebruik. Controleer persoonlijk.',
    'noti_caution_missing_body':
        'De geplande welzijnscontrole van vandaag is nog niet ontvangen. Controleer persoonlijk.',
    'noti_warning_body':
        'Welzijnscontroles zijn achtereenvolgens gemist. Controleer persoonlijk.',
    'noti_urgent_body':
        'Geen welzijnscontrole gedurende @days dag(en). Onmiddellijke controle vereist.',
    'noti_steps_body':
        '@from_time ~ @to_time: @steps stappen gelopen.',

    // ── Lokale meldingen ──
    'local_alarm_title': '📱 Welzijnscontrole nodig',
    'local_alarm_body': 'Tik op deze melding.',
    'wellbeing_check_title': '💛 Welzijnscontrole',
    'wellbeing_check_body':
        'Gaat het goed met u? Tik op deze melding.',
    'noti_channel_name': 'Anbu-meldingen',
  };
}
