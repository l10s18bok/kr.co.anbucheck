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
    'app_copyright': '© 2026 Averic SB Inc.',

    // ── Splash ──
    'splash_loading': 'Welzijn wordt gecontroleerd...',

    // ── Update ──
    'update_required_title': 'Update vereist',
    'update_required_message': 'Werk bij naar versie @version om de app te blijven gebruiken.',
    'update_button': 'Bijwerken',
    'update_available_title': 'Update beschikbaar',
    'update_available_message': 'Versie @version is beschikbaar.',

    // ── Modusselectie ──
    'mode_select_title': 'Kies uw rol',
    'mode_select_subtitle': 'Dit helpt ons de juiste functies voor u in te stellen',
    'mode_subject_title': 'Ik wil dat mijn veiligheid\nwordt bewaakt',
    'mode_subject_button': 'Ik wil beschermd worden →',
    'mode_guardian_title': 'Ik wil over iemand\nwaken die ik liefheb',
    'mode_guardian_button': 'Start als beschermer →',
    'mode_select_notice': 'De indeling en meldingen zullen verschillen op basis van uw keuze',

    // ── Machtigingen ──
    'permission_title': 'Er zijn machtigingen nodig\nom de app te gebruiken',
    'permission_notification': 'Meldingstoestemming',
    'permission_notification_subject_desc': 'Vereist om welzijnsmeldingen te ontvangen',
    'permission_notification_guardian_desc':
        'Vereist om veiligheidsmeldingen over uw beschermelingen te ontvangen',
    'permission_activity': 'Activiteitsherkenning',
    'permission_activity_desc':
        'Wordt gebruikt om stappen te detecteren en activiteit te bevestigen',
    'permission_location': 'Locatie',
    'permission_location_desc':
        'Wordt alleen bij een noodoproep met uw beschermers gedeeld',
    'location_permission_warning':
        'Bij een noodoproep wordt geen locatie verzonden. Tik om toe te staan.',
    'location_permission_settings_title': 'Locatietoestemming vereist',
    'location_permission_settings_body_ios':
        "Zoek en selecteer 'Anbu', kies vervolgens bij 'Locatie' de optie 'Bij gebruik van de app'.",
    'location_permission_settings_body_android':
        "Selecteer 'Rechten' → 'Locatie' en kies 'Alleen toestaan bij gebruik van de app'.",
    'permission_activity_dialog_title': 'Informatie over activiteitstoestemming',
    'permission_activity_dialog_message':
        'Wordt gebruikt om stappen te detecteren en activiteit te bevestigen.\nSelecteer "Toestaan" op het volgende scherm.',
    'permission_notification_required_title': 'Meldingstoestemming vereist',
    'permission_notification_required_message':
        'De welzijnscontrole vereist meldingstoestemming.\nSchakel deze in via Instellingen.',
    'permission_go_to_settings': 'Ga naar Instellingen',
    'permission_activity_denied_title': 'Toestemming voor fysieke activiteit vereist',
    'permission_activity_denied_message':
        'Wordt gebruikt om stappen te detecteren en de nauwkeurigheid van de welzijnscontrole te verbeteren.\nSchakel de toestemming in via Instellingen.',
    'permission_battery': 'Uitsluiting van batterijoptimalisatie',
    'permission_battery_desc':
        'Sluit de app uit van batterijoptimalisatie zodat dagelijkse welzijnscontroles niet worden gemist',
    'permission_battery_required_title': 'Stel de batterij in op "Onbeperkt"',
    'permission_battery_required_message':
        'Als "Batterijoptimalisatie" of "Batterijbesparing" is ingeschakeld, kunnen dagelijkse welzijnscontroles worden vertraagd of gemist.\n\nNa het tikken op [Ga naar Instellingen]:\n1. Selecteer "Batterij"\n2. Wijzig naar "Onbeperkt"',
    'permission_battery_go_to_settings': 'Ga naar Instellingen',
    'permission_hibernation_title': 'Schakel "App pauzeren bij niet-gebruik" uit',
    'permission_hibernation_highlight': 'App pauzeren bij niet-gebruik',
    'permission_hibernation_message':
        'Als u de app enkele maanden niet opent, kan Android deze automatisch stoppen, waardoor welzijnscontroles worden onderbroken.\n\nTik op [App-instellingen openen] en schakel "App pauzeren bij niet-gebruik" uit.',
    'permission_hibernation_go_to_settings': 'App-instellingen openen',

    // ── Onboarding ──
    'onboarding_title_1': 'Maakt u zich zorgen om iemand\ndie alleen woont?',
    'onboarding_desc_1':
        'Zelfs van ver weg\nvraagt u zich af of het goed gaat.\nAnbu is er voor u.',
    'onboarding_title_2': 'Welzijnscontrole\nzonder een woord',
    'onboarding_desc_2':
        'Gewoon door de smartphone te gebruiken\nwordt dagelijks automatisch\neen welzijnssignaal verzonden.',
    'onboarding_title_3': 'Deel welzijn\nmet uw dierbaren',
    'onboarding_desc_3':
        'Dagelijkse controles groeien uit\ntot blijvende gemoedsrust.\nLaten we beginnen.',
    'onboarding_title_4': 'Geen namen, geen telefoonnummers\n— niets wordt verzameld',
    'onboarding_desc_4':
        'Er wordt slechts één signaal verzonden:\n"Het gaat goed met mij."\nUw gegevens zijn veilig.',
    'onboarding_role_subject': 'Beschermeling',
    'onboarding_role_guardian': 'Beschermer',
    'onboarding_role_guardian_subject': 'Bewaker en beschermde',
    'onboarding_already_registered_title': 'Apparaat al geregistreerd',
    'onboarding_already_registered_message':
        'Dit apparaat is al geregistreerd in "@roleLabel"-modus.\nDoorgaan als "@roleLabel"?\n\nOf wisselen naar "@newRoleLabel"-modus?\nBij het wisselen worden alle bestaande gegevens verwijderd.',
    'onboarding_already_registered_message_gs':
        'Dit apparaat is al geregistreerd in "@roleLabel"-modus.\nOverschakelen naar "@newRoleLabel" verwijdert alle bewaker- en beschermdegegevens.',
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
    'subject_home_report_desc': 'Laat uw beschermer weten dat het goed met u gaat',
    'subject_home_emergency_button': 'Ik heb hulp nodig',
    'subject_home_emergency_desc': 'Stuurt een noodmelding naar uw beschermers',
    'subject_home_emergency_loading': 'Noodmelding wordt verzonden...',
    'subject_home_emergency_sent': 'Noodmelding is verzonden',
    'subject_home_emergency_failed': 'Noodmelding kon niet worden verzonden',
    'subject_home_manual_report_limit_reached': 'U heeft het veiligheidsrapport van vandaag al verzonden. Probeer het morgen opnieuw.',
    'subject_home_manual_report_sent': 'Uw bericht is verzonden naar uw contacten.',
    'subject_home_emergency_confirm_title': 'Noodhulpverzoek',
    'subject_home_emergency_confirm_body':
        'Een noodmelding wordt naar alle voogden verzonden.\nOok uw huidige locatie wordt gedeeld.\nWilt u echt om hulp vragen?',
    'emergency_sent_with_location': 'Noodmelding verzonden (met locatie)',
    'emergency_sent_without_location': 'Noodmelding verzonden',
    'notifications_view_location': '🗺️ Locatie bekijken',
    'emergency_map_title': 'Noodlocatie',
    'emergency_map_subject_label': 'Hulpbehoevende',
    'emergency_map_captured_at_label': 'Vastgelegd op',
    'emergency_map_accuracy_label': 'Nauwkeurigheid',
    'emergency_map_open_external': 'Open in externe kaart-app',
    'emergency_map_no_location': 'Geen locatie-informatie',
    'emergency_location_permission_denied_snackbar': 'Noodmelding verzonden zonder locatierechten',
    'subject_home_emergency_confirm_send': 'Noodverzoek verzenden',
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
    'drawer_withdraw_message': 'Uw account en alle gegevens worden verwijderd.\nWeet u het zeker?',

    // ── Dashboard beschermer ──
    'guardian_status_normal': 'Veilig',
    'guardian_status_caution': 'Let op',
    'guardian_status_warning': 'Waarschuwing',
    'guardian_status_urgent': 'Dringend',
    'guardian_status_confirmed': '✅ Veilig',
    'guardian_subscription_expired': 'Abonnement verlopen',
    'guardian_subscription_expired_message':
        'Waarschuwingsmeldingen worden niet verzonden.\nVerleng uw abonnement om de bescherming voort te zetten.',
    'guardian_subscribe': 'Abonneren',
    'guardian_payment_preparing': 'De betaalfunctie is binnenkort beschikbaar.',
    'guardian_today_summary': 'Welzijnsoverzicht van vandaag',
    'guardian_no_subjects': 'Geen beschermelingen verbonden.',
    'guardian_checking_subjects': 'Momenteel controleren we\n@count beschermeling(en).',
    'guardian_subject_list': 'Lijst beschermelingen',
    'guardian_call_now': 'Nu bellen',
    'guardian_confirm_safety': 'Veiligheid bevestigen',
    'guardian_no_check_history': 'Geen controlegeschiedenis',
    'guardian_last_check_now': 'Laatste controle: zojuist',
    'guardian_last_check_minutes': 'Laatste controle: @minutes min geleden',
    'guardian_last_check_hours': 'Laatste controle: @hours uur geleden',
    'guardian_last_check_days': 'Laatste controle: @days dag(en) geleden',
    'guardian_activity_stable': 'Activiteit: stabiel',
    'guardian_activity_prefix': 'Activiteit',
    'guardian_activity_very_active': 'Zeer actief',
    'guardian_activity_active': 'Actief',
    'guardian_activity_needs_exercise': 'Beweging nodig',
    'guardian_activity_collecting': 'Gegevens verzamelen',
    'guardian_error_load_step_history': 'Stappenhistorie laden mislukt',
    'guardian_chart_y_axis_steps': 'Stappen',
    'guardian_chart_x_axis_last_7_days': 'Afgelopen 7 dagen',
    'guardian_chart_x_axis_last_30_days': 'Afgelopen 30 dagen',
    'guardian_chart_today': 'Vandaag',
    'guardian_safety_needed': 'Veiligheidscontrole nodig',
    'guardian_error_load_subjects': 'Kan de lijst met beschermelingen niet laden.',
    'guardian_safety_confirmed': 'Veiligheid bevestigd.',
    'guardian_error_clear_alerts': 'Kan waarschuwingen niet wissen.',

    // ── Beschermeling toevoegen ──
    'add_subject_title': 'Beschermeling koppelen',
    'add_subject_guide_title': 'Voer de unieke code van de beschermeling en een bijnaam in.',
    'add_subject_guide_subtitle':
        'Koppel de app van een beschermeling om gezondheid en activiteit in realtime te volgen.',
    'add_subject_code_label': 'Unieke code (7 cijfers)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info': 'De unieke code is te vinden in de app van de beschermeling.',
    'add_subject_alias_label': 'Bijnaam beschermeling',
    'add_subject_alias_hint': 'Bijv. Mama, Papa',
    'add_subject_connect': 'Verbinden',
    'add_subject_error_login': 'Inloggen vereist.',
    'add_subject_success': 'Beschermeling succesvol verbonden.',
    'add_subject_error_invalid_code': 'Ongeldige code.',
    'add_subject_error_already_connected': 'Al verbonden.',
    'add_subject_error_failed': 'Verbinding mislukt. Probeer het later opnieuw.',
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
    'settings_days_remaining': 'Nog @days dagen',
    'settings_manage_subscription': 'Abonnement beheren',
    'settings_notification': 'Meldingsinstellingen',
    'settings_terms_section': 'Juridisch',
    'settings_privacy_policy': 'Privacybeleid',
    'settings_terms': 'Gebruiksvoorwaarden',
    'settings_app_version': 'Versie: v@version',

    // ── G+S (Bewaker en beschermde) ──
    'gs_enable_button': 'Ook welzijnsbescherming ontvangen',
    'gs_safety_code_button': 'Mijn veiligheidscode bekijken',
    'gs_safety_code_title': 'Mijn veiligheidscode',
    'gs_enable_dialog_title': 'Welzijnsbescherming activeren',
    'gs_enable_dialog_body':
        'U kunt welzijnsbescherming ontvangen terwijl u uw bewakerfuncties behoudt.\nEr wordt een veiligheidscode uitgegeven — deel deze met andere bewakers.',
    'gs_enable_dialog_ios_warning_title': '⚠ iOS werkt anders dan Android',
    'gs_enable_dialog_ios_warning_body':
        'Op iOS verschijnt elke dag op het ingestelde tijdstip een "welzijns-pushmelding". U moet de melding aantikken of de app rond dat tijdstip zelf openen om uw welzijnssignaal te verzenden. Als u de app niet opent, kunnen uw bewakers een waarschuwing voor een gemiste controle ontvangen.',
    'gs_enable_dialog_ios_confirm': 'Begrepen, activeren',
    'gs_enable_confirm': 'Activeren',
    'gs_enabled_message': 'Welzijnsbescherming is geactiveerd',
    'gs_enable_failed': 'Welzijnsbescherming activeren mislukt',
    'gs_disable_dialog_title': 'Welzijnsbescherming deactiveren',
    'gs_disable_dialog_body':
        'Bij deactivering wordt uw veiligheidscode verwijderd en worden welzijnscontroles aan verbonden bewakers gestopt.',
    'gs_disable_confirm': 'Deactiveren',
    'gs_disabled_message': 'Welzijnsbescherming is gedeactiveerd',
    'gs_disable_failed': 'Welzijnsbescherming deactiveren mislukt',
    'gs_activity_permission_denied_warning': 'Stappenteller-toestemming geweigerd. Tik hier om toe te staan.',
    'gs_activity_permission_settings_title': 'Toestemming vereist',
    'gs_activity_permission_settings_body': 'Sta de machtiging Fysieke activiteit (Beweging en Fitness) toe in de app-instellingen.',
    'gs_activity_permission_settings_go': 'Ga naar Instellingen',

    // ── Beschermer → G+S omschakeling (Drawer/Dialoog) ──
    'drawer_enable_guardian': 'Ook gezinswelzijn beheren',
    's_to_gs_dialog_title': 'Beschermer-functie toevoegen',
    's_to_gs_dialog_body':
        'Voeg de beschermer-functie toe om ook het welzijn van familie of dierbaren te volgen.\n(Let op: de beschermer-functie is 3 maanden gratis en wordt daarna een betaald abonnement.)\n\nJe eigen veiligheidscode en de huidige verzending van welzijnssignalen blijven ongewijzigd en blijven gratis te gebruiken.',
    's_to_gs_dialog_confirm': 'Doorgaan',
    's_to_gs_switch_failed': 'Inschakelen van de beschermer-functie mislukt',

    // ── Meldingen beschermer ──
    'notifications_title': 'Meldingen',
    'notifications_today': 'Meldingen van vandaag',
    'notifications_empty': 'Geen meldingen vandaag',
    'notifications_delete_all_title': 'Alle meldingen verwijderen',
    'notifications_auto_delete_notice': 'De meldingen van vandaag worden automatisch verwijderd om middernacht (0:00).',
    'notifications_delete_all_message': 'Alle meldingen van vandaag verwijderen?',
    'notifications_delete_failed': 'Kan meldingen niet verwijderen.',
    'notifications_guide_title': 'Gids meldingsniveaus',
    'notifications_level_health': 'Normaal',
    'notifications_level_health_desc': 'Het welzijn van de beschermeling is normaal bevestigd',
    'notifications_level_caution': 'Let op',
    'notifications_level_caution_desc': 'Nog geen welzijnssignaal of telefoonactiviteit gedetecteerd',
    'notifications_level_warning': 'Waarschuwing',
    'notifications_level_warning_desc': 'Meerdere dagen geen welzijnssignaal of telefoonactiviteit',
    'notifications_level_urgent': 'Dringend',
    'notifications_level_urgent_desc': 'Onmiddellijke controle nodig',
    'notifications_level_info': 'Info',
    'notifications_level_info_desc': 'Stappen, lage batterij en andere meldingen',
    'notifications_activity_note':
        '※ Activiteitsinformatie wordt mogelijk niet getoond als stapgegevens niet konden worden verzameld.',

    // ── Meldingsinstellingen beschermer ──
    'notification_settings_title': 'Meldingsinstellingen',
    'notification_settings_push': 'Pushmeldingen',
    'notification_settings_all': 'Alle meldingen',
    'notification_settings_all_desc': 'Schakel alle meldingscategorieën tegelijk in of uit.',
    'notification_settings_level_section': 'Niveau-instellingen',
    'notification_settings_urgent': 'Dringende meldingen',
    'notification_settings_urgent_desc': 'Dringende meldingen kunnen niet worden uitgeschakeld',
    'notification_settings_warning': 'Waarschuwingsmeldingen',
    'notification_settings_warning_desc': 'Melding wanneer 2 dagen achtereen geen controle',
    'notification_settings_caution': 'Let op-meldingen',
    'notification_settings_caution_desc': 'Melding wanneer de controle van vandaag ontbreekt',
    'notification_settings_info': 'Infomeldingen',
    'notification_settings_info_desc': 'Algemene meldingen zoals aantal stappen en batterijstatus',
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
    'connection_empty': 'Geen verbonden beschermden',
    'connection_unlink_warning':
        'Bij ontkoppeling worden de gegevens van de beschermeling verwijderd.',
    'connection_unlink_warning_detail':
        'Eerdere gegevens kunnen na opnieuw koppelen niet worden hersteld. U moet de code van de beschermeling opnieuw invoeren.',
    'connection_heartbeat_schedule': 'Dagelijks om @time',
    'connection_heartbeat_report_time': 'De welzijnsrapportagetijd is ',
    'connection_subject_label': 'Beschermeling',
    'connection_change_only_in_app': 'kan alleen in de app worden gewijzigd',
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
    'heartbeat_schedule_title_ios': 'Tijd welzijns-pushmelding',
    'heartbeat_schedule_change_title_ios': 'Tijd welzijns-pushmelding wijzigen',
    'heartbeat_schedule_hint_ios':
        'Een welzijns-pushmelding komt elke dag op deze tijd binnen. Tik op de melding of open de app rond dat tijdstip om uw welzijnssignaal te verzenden.',
    'heartbeat_daily_time': 'Dagelijks om @time',
    'heartbeat_scheduled_today': 'Uw welzijnssignaal wordt elke dag om @time naar uw beschermers gestuurd.',
    'heartbeat_change_failed_title': 'Tijdswijziging mislukt',
    'heartbeat_change_failed_message': 'Kan niet bijwerken op de server.',

    // ── Lokale meldingen ──
    'local_notification_channel': 'Welzijnsmeldingen',
    'local_notification_channel_desc': 'Meldingen van de welzijnscontroleservice',

    // ── Overig ──
    'back_press_exit': 'Druk nogmaals op terug om af te sluiten.',

    // ── API-fouten ──
    'error_unknown': 'Er is een onbekende fout opgetreden.',
    'error_timeout': 'Het verzoek is verlopen.',
    'error_network': 'Controleer uw netwerkverbinding.',
    'error_unauthorized': 'Authenticatie vereist.',

    // ── Meldingsteksten ──
    'noti_auto_report_body': 'De geplande welzijnscontrole is vandaag ontvangen.',
    'noti_manual_report_body':
        'De beschermde persoon heeft handmatig een welzijnscontrole verzonden.',
    'noti_battery_low_body': 'De batterij van de telefoon is onder 20 %. Opladen kan nodig zijn.',
    'noti_battery_dead_body':
        'De telefoon lijkt uitgeschakeld door een lege batterij. Laatste batterijniveau: @battery_level %. Het herstelt automatisch na opladen.',
    'noti_caution_suspicious_body':
        'Er is een welzijnssignaal ontvangen, maar er zijn geen tekenen van telefoongebruik. Controleer persoonlijk.',
    'noti_caution_missing_body':
        'De geplande welzijnscontrole van vandaag is nog niet ontvangen. Controleer persoonlijk.',
    'noti_warning_body': 'Welzijnscontroles zijn achtereenvolgens gemist. Controleer persoonlijk.',
    'noti_warning_suspicious_body':
        'Er zijn achtereenvolgens geen tekenen van telefoongebruik gedetecteerd. Persoonlijke controle is nodig.',
    'noti_urgent_body':
        'Geen welzijnscontrole gedurende @days dag(en). Onmiddellijke controle vereist.',
    'noti_urgent_suspicious_body':
        'Geen tekenen van telefoongebruik gedurende @days dag(en). Onmiddellijke controle vereist.',
    'noti_steps_body': '@steps stappen gelopen vandaag.',
    'noti_emergency_body':
        'De beschermde persoon heeft rechtstreeks om hulp gevraagd. Controleer onmiddellijk.',
    'noti_resolved_body': 'De welzijnscontrole van de beschermde persoon is weer normaal.',
    'noti_cleared_by_guardian_title': '✅ Controle bevestigd',
    'noti_cleared_by_guardian_body':
        'Een van de beschermers heeft de veiligheid persoonlijk bevestigd.',

    // ── Lokale meldingen ──
    'local_alarm_title': '💗 Welzijnscontrole nodig',
    'local_alarm_body': 'Tik op deze melding.',
    'wellbeing_check_title': '💛 Welzijnscontrole',
    'wellbeing_check_body': 'Gaat het goed met u? Tik op deze melding.',
    'noti_channel_name': 'Anbu-meldingen',
    'notification_send_failed_title': '📶 Controleer je internetverbinding',
    'notification_send_failed_body': 'Open de app om je welzijnscheck opnieuw te versturen.',
  };
}
