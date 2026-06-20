abstract class SvSe {
  static const Map<String, String> translations = {
    // ── Allmant ──
    'common_confirm': 'Bekrafta',
    'common_cancel': 'Avbryt',
    'common_continue': 'Fortsätt',
    'common_save': 'Spara',
    'common_delete': 'Radera',
    'common_close': 'Stang',
    'common_next': 'Nasta',
    'common_previous': 'Foregaende',
    'common_start': 'Kom igang',
    'common_skip': 'Hoppa over',
    'common_later': 'Senare',
    'common_loading': 'Laddar...',
    'common_error': 'Fel',
    'common_complete': 'Klart',
    'common_notice': 'Meddelande',
    'common_unlink': 'Koppla fran',
    'common_am': 'fm',
    'common_pm': 'em',
    'common_normal': 'Normal',
    'common_connected': 'Ansluten',
    'common_disconnected': 'Ej ansluten',

    // ── Appvarumarke ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Kontrollerar ditt valmaende.',
    'app_service_desc': 'Automatisk valmaendekontroll',
    'app_guardian_title': 'Anbu-vardare',
    'app_copyright': '© 2026 Averic Lab',

    // ── Splash ──
    'splash_loading': 'Kontrollerar valmaende...',

    // ── Uppdatering ──
    'update_required_title': 'Uppdatering kravs',
    'update_required_message': 'Uppdatera till version @version for att fortsatta anvanda appen.',
    'update_button': 'Uppdatera',
    'update_available_title': 'Uppdatering tillganglig',
    'update_available_message': 'Version @version ar tillganglig.',
    'update_later_button': 'Senare',

    // ── Valj lage ──
    'mode_select_title': 'Hur vill du börja?',
    'mode_select_subtitle': 'Berätta om du hör av dig eller tar emot livstecken',
    'mode_subject_title': 'Jag vill bara höra av mig',
    'mode_subject_button': 'Hör av mig →',
    'mode_guardian_title': 'Jag vill vaka over\nnagon jag bryr mig om',
    'mode_guardian_button': 'Ta emot livstecken →',
    'mode_recommend_badge': 'Rekommenderas',
    'mode_select_notice': 'Skarmlayout och aviseringar anpassas efter ditt val',

    // ── Behorigheter ──
    'permission_title': 'Behorigheter kravs\nfor att anvanda appen',
    'permission_notification': 'Aviseringsbehorighet',
    'permission_notification_subject_desc': 'Kravs for att ta emot valmaendeaviseringar',
    'permission_notification_guardian_desc':
        'Kravs for att ta emot sakerhetsaviseringar for dina skyddspersoner',
    'permission_activity': 'Aktivitetsigenkanning',
    'permission_activity_desc': 'Anvands for att upptacka steg och bekrafta aktivitet',
    'permission_location': 'Plats',
    'permission_location_desc': 'Delas med anhoriga endast vid en nodbegaran om hjalp',
    'permission_tracking': 'Annonsspårning',
    'permission_tracking_desc': 'Används för personanpassad reklam',
    'location_permission_warning': 'Platsen skickas inte vid en nodbegaran. Tryck for att tillata.',
    'location_permission_settings_title': 'Platsbehorighet kravs',
    'location_permission_settings_body_ios':
        "Hitta och valj 'Anbu', valj sedan 'Nar appen anvands' under 'Plats'.",
    'location_permission_settings_body_android':
        "Valj 'Behorigheter' → 'Plats' och valj sedan 'Tillat endast medan appen anvands'.",
    'permission_activity_dialog_title': 'Info om aktivitetsbehorighet',
    'permission_activity_dialog_message':
        'Anvands for att upptacka steg och bekrafta aktivitet.\nTryck pa "Tillat" pa nasta skarm.',
    'permission_notification_required_title': 'Aviseringsbehorighet kravs',
    'permission_notification_required_message':
        'Aviseringsbehorighet kravs for valmaendetjansten.\nAktivera den i Installningar.',
    'permission_go_to_settings': 'Ga till Installningar',
    'permission_activity_denied_title': 'Behörighet för fysisk aktivitet krävs',
    'permission_activity_denied_message':
        'Behörighet för fysisk aktivitet krävs för att upptäcka steg och verifiera din säkerhet.\n\nUtan denna behörighet skickas ingen steginformation till vårdnadshavare.\n\nAktivera behörigheten "Fysisk aktivitet" i appinställningarna.',
    'permission_battery': 'Undantag från batterioptimering',
    'permission_battery_desc':
        'Utesluter appen från batterioptimering så att dagliga välmåendekontroller inte missas vid den schemalagda tiden',
    'permission_hibernation_title': 'Stäng av automatisk borttagning av behörigheter',
    'permission_hibernation_highlight': 'automatisk borttagning av behörigheter',
    'permission_hibernation_message':
        'Android tar automatiskt bort behörigheter från appar du inte har använt på länge. Anbu körs vanligtvis utan att öppnas, så den här funktionen kan göra att behörigheterna försvinner efter ett tag och att välmående-signalen slutar skickas.\n\nTryck på [Öppna inställningar] nedan — den aktuella skärmen med reglaget visas direkt. Stäng av reglaget.\n\n※ Den exakta texten kan variera beroende på enhetstillverkare.',
    'permission_hibernation_go_to_settings': 'Öppna inställningar',
    'stability_battery_warning_short': 'Batterianvändningsbegränsning måste inaktiveras',
    'stability_battery_dialog_title': 'Inaktivera batterianvändningsbegränsning',
    'stability_battery_dialog_message':
        'När telefonen går in i energisparläge kan välmående-signaler till din vårdgivare komma försenade eller missas.\n\nTryck på [Öppna inställningar] nedan och ställ in "Batteri" → "Obegränsad". Då skickas välmående-signaler tillförlitligt vid den planerade tiden varje dag.\n\n※ Den exakta texten kan variera beroende på enhetstillverkare.',

    // ── Introduktion ──
    'onboarding_title_1': 'Någon du älskar bor ensam\natt höra av sig varje dag är inte lätt',
    'onboarding_desc_1': 'Långt borta, och du undrar\nom de har det bra idag.\nAnbu förmedlar det åt dig.',
    'onboarding_title_2': 'Ett ord som når fram\nutan att uttalas',
    'onboarding_desc_2':
        'Din vardag är\nviktig information för\ndem som tänker på dig.',
    'onboarding_title_3': 'Dela omtanke\nmed dina narstaende',
    'onboarding_desc_3': 'Dagliga tecken blir\nett lugn för er båda.\nHör av dig bara när det räknas.',
    'onboarding_title_4': 'Nära i hjärtat, men\ninte i varje detalj',
    'onboarding_desc_4': 'Bara en signal levereras:\n"Jag mar bra."',
    'onboarding_role_subject': 'Skyddsperson',
    'onboarding_role_guardian': 'Vardare',
    'onboarding_role_guardian_subject': 'Vårdare och skyddad',
    'onboarding_already_registered_title': 'Enheten ar redan registrerad',
    'onboarding_already_registered_message':
        'Denna enhet ar redan registrerad i "@roleLabel"-lage.\nFortsatt som "@roleLabel"?\n\nEller byt till "@newRoleLabel"-lage?\nByte raderar all befintlig data.',
    'onboarding_already_registered_message_gs':
        'Denna enhet är redan registrerad i "@roleLabel"-läge.\nAtt byta till "@newRoleLabel"-läge raderar alla vårdare- och skyddaddata.',
    'onboarding_registration_failed_title': 'Registrering misslyckades',
    'onboarding_registration_failed_message': 'Kan inte ansluta till servern. Forsok igen senare.',

    // ── Skyddspersonens startsida ──
    'subject_home_share_title': 'Dela din sakerhetskod',
    'subject_home_guardian_count': 'Anslutna vardare: @count',
    'subject_home_check_title_last': 'Senaste kontrollen',
    'subject_home_check_title_scheduled': 'Schemalagd kontrolltid',
    'subject_home_check_title_checking': 'Kontrollerar valmaende',
    'subject_home_check_body_reported': 'Rapporterad kl. @time',
    'subject_home_check_body_scheduled': 'Schemalagd kl. @time',
    'subject_home_check_body_waiting': 'Vantar sedan @time',
    'subject_home_battery_status': 'Batteristatus',
    'subject_home_battery_charging': 'Laddar',
    'subject_home_battery_full': 'Fullt',
    'subject_home_battery_low': 'Lagt batteri',
    'subject_home_connectivity_status': 'Anslutning',
    'subject_home_report_loading': 'Rapporterar...',
    'subject_home_report_button': 'Rapportera sakerhet nu',
    'subject_home_report_desc': 'Lat din vardare veta att du mar bra',
    'subject_home_emergency_button': 'Jag behöver hjälp',
    'subject_home_emergency_desc': 'Skickar ett nödlarm till dina vårdgivare',
    'subject_home_emergency_loading': 'Skickar nödlarm...',
    'subject_home_emergency_sent': 'Nödlarmet har skickats',
    'subject_home_emergency_failed': 'Det gick inte att skicka nödlarmet',
    'subject_home_manual_report_limit_reached':
        'Du har redan skickat dagens säkerhetsrapport. Försök igen imorgon.',
    'subject_home_manual_report_sent': 'Ditt meddelande har skickats till dina kontakter.',
    'safety_net_dialog_title': 'Statuskontroll skickad',
    'safety_net_dialog_body':
        'Dagens statuskontroll har skickats till din anhörig.',
    'safety_net_dialog_already_body':
        'Dagens statuskontroll har redan skickats till din anhörig kl. @time.',
    'subject_home_emergency_confirm_title': 'Nödhjälpbegäran',
    'subject_home_emergency_confirm_body':
        'Ett nödlarm kommer att skickas till alla vårdgivare.\nDin nuvarande plats delas också.\nVill du verkligen be om hjälp?',
    'emergency_sent_with_location': 'Nödlarmet har skickats (med plats)',
    'emergency_sent_without_location': 'Nödlarmet har skickats',
    'notifications_view_location': '🗺️ Visa plats',
    'emergency_map_title': 'Nödplats',
    'emergency_map_subject_label': 'Skyddad person',
    'emergency_map_captured_at_label': 'Tidpunkt för insamling',
    'emergency_map_accuracy_label': 'Noggrannhet',
    'emergency_map_open_external': 'Öppna i extern kartapp',
    'emergency_map_no_location': 'Ingen platsinformation',
    'emergency_location_permission_denied_snackbar': 'Nödlarm skickat utan platsåtkomst',
    'subject_home_emergency_confirm_send': 'Skicka nödbegäran',
    'subject_home_share_text': 'Anslut till mig via Anbu-appen.\nAnslutningskod: @code',
    'subject_home_share_subject': 'Anbu-anslutningskod',
    'subject_home_code_copied': 'Koden kopierad',

    // ── Skyddspersonens meny ──
    'drawer_light_mode': 'Ljust lage',
    'drawer_dark_mode': 'Morkt lage',
    'drawer_privacy_policy': 'Integritetspolicy',
    'drawer_terms': 'Anvandarvillkor',
    'drawer_withdraw': 'Radera konto',
    'drawer_withdraw_message': 'Ditt konto och all data raderas.\nAr du saker?',

    // ── Vardarens instrumentpanel ──
    'guardian_status_normal': 'Saker',
    'guardian_status_caution': 'Forsiktighet',
    'guardian_status_warning': 'Varning',
    'guardian_status_urgent': 'Bradskande',
    'guardian_status_confirmed': '✅ Saker',
    'guardian_subscription_expired': 'Prenumeration kravs',
    'guardian_subscription_expired_message':
        'De dagliga livstecknen har upphort.\nFor priset av en lunch vakar du over din narstaende hela aret.',
    'guardian_subscribe': 'Prenumerera',
    'guardian_payment_preparing': 'Betalningsfunktionen kommer snart.',
    'guardian_today_summary': 'Dagens valmaendesammanfattning',
    'guardian_no_subjects': 'Inga anslutna skyddspersoner.',
    'guardian_checking_subjects': 'Kontrollerar for narvarande\n@count skyddsperson(er).',
    'guardian_subject_list': 'Lista over skyddspersoner',
    'guardian_call_now': 'Ring nu',
    'guardian_confirm_safety': 'Bekrafta sakerhet',
    'guardian_no_check_history': 'Ingen kontrollhistorik',
    'guardian_last_check_now': 'Senaste kontroll: just nu',
    'guardian_last_check_minutes': 'Senaste kontroll: @minutes min sedan',
    'guardian_last_check_hours': 'Senaste kontroll: @hours tim sedan',
    'guardian_last_check_days': 'Senaste kontroll: @days dag(ar) sedan',
    'guardian_activity_stable': 'Aktivitet: Stabil',
    'guardian_activity_prefix': 'Aktivitet',
    'guardian_activity_very_active': 'Mycket aktiv',
    'guardian_activity_active': 'Aktiv',
    'guardian_activity_needs_exercise': 'Behöver motion',
    'guardian_activity_collecting': 'Samlar data',
    'guardian_error_load_step_history': 'Kunde inte ladda stegshistorik',
    'guardian_chart_y_axis_steps': 'Steg',
    'guardian_chart_x_axis_last_7_days': 'Senaste 7 dagarna',
    'guardian_chart_x_axis_last_30_days': 'Senaste 30 dagarna',
    'guardian_chart_today': 'Idag',
    'guardian_safety_needed': 'Sakerhetskontroll behovs',
    'guardian_error_load_subjects': 'Kunde inte ladda skyddspersoner.',
    'guardian_safety_confirmed': 'Säkerhet bekräftad.',
    'guardian_error_clear_alerts': 'Kunde inte rensa aviseringar.',

    // ── Lagg till skyddsperson ──
    'add_subject_title': 'Anslut skyddsperson',
    'add_subject_guide_title': 'Ange skyddspersonens unika kod och ett alias.',
    'add_subject_guide_subtitle':
        'Anslut en skyddspersons app for att overvaka halsa och aktivitet i realtid.',
    'add_subject_code_label': 'Unik kod (7 siffror)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info': 'Den unika koden finns i skyddspersonens app.',
    'add_subject_alias_label': 'Skyddspersonens alias',
    'add_subject_alias_hint': 't.ex. Mamma, Pappa',
    'add_subject_connect': 'Anslut',
    'add_subject_error_login': 'Inloggning kravs.',
    'add_subject_success': 'Skyddsperson ansluten.',
    'add_subject_error_invalid_code': 'Ogiltig kod.',
    'add_subject_error_self': 'Du kan inte lägga till din egen kod som en person att bevaka.',
    'add_subject_error_limit': 'Du kan registrera upp till @max personer.',
    'add_subject_error_already_connected': 'Redan ansluten.',
    'add_subject_error_failed': 'Anslutningen misslyckades. Forsok igen.',
    'add_subject_button': 'Lagg till ny skyddsperson',

    // ── Vardarens installningar ──
    'settings_title': 'Installningar',
    'settings_light_mode': 'Ljust lage',
    'settings_dark_mode': 'Morkt lage',
    'settings_connection_management': 'Anslutningshantering',
    'settings_managed_subjects': 'Antal skyddspersoner',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'Prenumeration och tjanst',
    'settings_current_membership': 'Nuvarande medlemskap',
    'settings_premium': 'Premium aktivt',
    'guardian_go_to_settings': 'Gå till Inställningar',
    'settings_expired': 'Prenumeration kravs',
    'settings_days_until_renewal': 'D-@days',
    'settings_days_until_trial_end': 'D-@days',
    'settings_free_trial': 'Gratis provperiod',
    'settings_manage_subscription': 'Hantera prenumeration',
    'settings_notification': 'Aviseringsinstellningar',
    'settings_terms_section': 'Juridiskt',
    'settings_privacy_policy': 'Integritetspolicy',
    'settings_terms': 'Anvandarvillkor',
    'settings_ad_consent': 'Hantera annonsmedgivande',
    'settings_app_version': 'Version: v@version',

    // ── App-köp (årlig $9.99-prenumeration för vårdgivare) ──
    'subscription_subscribe': 'Prenumerera',
    'trial_ended_noti_title': 'Anbu',
    'trial_ended_noti_body': 'Din kostnadsfria provperiod har avslutats. Prenumerera för att fortsätta.',
    'subscription_restore': 'Återställ köp',
    'subscription_store_unavailable': 'Butiken är inte tillgänglig',
    'subscription_product_unavailable': 'Prenumeration ej tillgänglig',
    'subscription_purchase_failed': 'Köpet misslyckades',
    'subscription_verify_failed': 'Verifiering av prenumeration misslyckades',
    'subscription_restore_failed': 'Återställning misslyckades',
    'subscription_restore_nothing': 'Ingen prenumeration att återställa',
    'subscription_restore_success': 'Prenumeration återställd',
    'subscription_purchase_success': 'Prenumeration startad',
    'subscription_period_annual': 'år',

    // ── G+S (Vårdare + Skyddad) ──
    'gs_enable_button': 'Få hälsoskydd också',
    'gs_safety_code_button': 'Visa min säkerhetskod',
    'gs_safety_code_title': 'Min säkerhetskod',
    'gs_enable_dialog_title': 'Aktivera hälsoskydd',
    'gs_enable_dialog_body':
        'Du kan få hälsoskydd samtidigt som du behåller dina vårdarfunktioner.\nEn säkerhetskod utfärdas — dela den med andra vårdare.',
    'gs_enable_dialog_ios_warning_title': '⚠ Hur din hälsosignal skickas',
    'gs_enable_dialog_ios_warning_body':
        'En "hälso-pushavisering" visas varje dag vid den schemalagda tiden. Du måste trycka på aviseringen eller själv öppna appen vid den tidpunkten för att din hälsosignal ska skickas. Om du inte öppnar appen kan dina vårdare få en varning om missad kontroll.',
    'gs_enable_dialog_ios_confirm': 'Jag förstår, aktivera',
    'gs_enable_confirm': 'Aktivera',
    'gs_enabled_message': 'Hälsoskydd har aktiverats',
    'gs_enable_failed': 'Kunde inte aktivera hälsoskydd',
    'gs_disable_dialog_title': 'Inaktivera hälsoskydd',
    'gs_disable_dialog_body':
        'Att inaktivera raderar din säkerhetskod och stoppar hälsokontroller till anslutna vårdare.',
    'gs_disable_confirm': 'Inaktivera',
    'gs_disabled_message': 'Hälsoskydd har inaktiverats',
    'gs_disable_failed': 'Kunde inte inaktivera hälsoskydd',
    'gs_activity_permission_denied_warning':
        'Stegräknartillstånd nekat. Tryck här för att tillåta.',
    'gs_activity_permission_settings_title': 'Behörighet krävs',
    'gs_activity_permission_settings_body':
        'Tillåt behörighet för Fysisk aktivitet (Rörelse och kondition) i appinställningarna.',
    'gs_activity_permission_settings_go': 'Gå till inställningar',

    // ── Vårdare → G+S växling (Drawer/Dialog) ──
    'drawer_enable_guardian': 'Hantera även familjens välmående',
    's_to_gs_dialog_title': 'Lägg till vårdare-funktion',
    's_to_gs_dialog_body':
        'Lägg till vårdare-funktionen så att du även kan följa familjens eller nära och käras välmående.\n(Observera: vårdare-funktionen är gratis i 3 månader och övergår sedan till en betald prenumeration.)\n\nDin egen säkerhetskod och den välmåendesignal du skickar idag förblir oförändrade och fortsatt gratis att använda.',
    's_to_gs_dialog_confirm': 'Fortsätt',
    's_to_gs_switch_failed': 'Kunde inte aktivera vårdare-funktionen',

    // ── Vardarens aviseringar ──
    'notifications_title': 'Aviseringar',
    'notifications_today': 'Dagens aviseringar',
    'notifications_empty': 'Inga aviseringar idag',
    'notifications_delete_all_title': 'Radera alla aviseringar',
    'notifications_auto_delete_notice':
        'Dagens aviseringar raderas automatiskt vid midnatt (0:00).',
    'notifications_delete_all_message': 'Radera alla dagens aviseringar?',
    'notifications_delete_failed': 'Kunde inte radera aviseringar.',
    'notifications_guide_title': 'Guide for aviseringsniva',
    'notifications_level_health': 'Normal',
    'notifications_level_health_desc': 'Skyddspersonens valmaende ar normalt bekraftat',
    'notifications_level_caution': 'Forsiktighet',
    'notifications_level_caution_desc': 'Ingen välmåendesignal eller aktivitetsregistrering ännu',
    'notifications_level_warning': 'Varning',
    'notifications_level_warning_desc':
        'Ingen välmåendesignal eller aktivitetsregistrering flera dagar i rad',
    'notifications_level_urgent': 'Bradskande',
    'notifications_level_urgent_desc': 'Omedelbar kontroll krävs',
    'notifications_level_info': 'Info',
    'notifications_level_info_desc': 'Steg, låg batterinivå och andra aviseringar',
    'notifications_activity_note':
        '※ Stegräknaren visar kumulativa steg från midnatt till tidpunkten då säkerhetssignalen skickades.',

    // ── Vardarens aviseringsinstellningar ──
    'notification_settings_title': 'Aviseringsinstellningar',
    'notification_settings_push': 'Push-aviseringar',
    'notification_settings_all': 'Alla aviseringar',
    'notification_settings_all_desc':
        'Aktivera eller inaktivera alla aviseringskategorier samtidigt.',
    'notification_settings_level_section': 'Nivainstellningar',
    'notification_settings_urgent': 'Bradskande aviseringar',
    'notification_settings_urgent_desc': 'Bradskande aviseringar kan inte inaktiveras',
    'notification_settings_warning': 'Varningsaviseringar',
    'notification_settings_warning_desc': 'Avisering vid utebliven kontroll 2 dagar i rad',
    'notification_settings_caution': 'Forsiktighetsaviseringar',
    'notification_settings_caution_desc': 'Avisering nar dagens kontroll saknas',
    'notification_settings_info': 'Informationsaviseringar',
    'notification_settings_info_desc': 'Allmanna aviseringar som stegantal och batteristatus',
    'notification_settings_dnd': 'Stor ej',
    'notification_settings_dnd_start': 'Starttid',
    'notification_settings_dnd_end': 'Sluttid',
    'notification_settings_dnd_note': '※ Bradskande aviseringar levereras aven under Stor ej',
    'notification_settings_dnd_start_default': '22:00',
    'notification_settings_dnd_end_default': '07:00',

    // ── Vardarens anslutningshantering ──
    'connection_title': 'Anslutningshantering',
    'connection_managed_count': 'Antal skyddspersoner ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Anslutna skyddspersoner',
    'connection_reorder_hint': 'Tryck och håll på ett kort nedan för att ändra ordning',
    'connection_empty': 'Inga anslutna skyddspersoner',
    'connection_unlink_warning': 'Frankopling raderar skyddspersonens data.',
    'connection_unlink_warning_detail':
        'Tidigare poster kan inte aterstallas efter ateranslutning. Du behover ange skyddspersonens kod igen.',
    'connection_heartbeat_schedule': 'Dagligen kl. @time',
    'connection_heartbeat_report_time': 'Valmaenderapporttid: ',
    'connection_subject_label': 'Skyddsperson',
    'connection_change_only_in_app': 'kan bara andras i appen',
    'connection_edit_title': 'Redigera skyddsperson',
    'connection_alias_label': 'Alias',
    'connection_unlink_title': 'Koppla fran',
    'connection_unlink_confirm': 'Koppla fran @alias?',
    'connection_unlink_success': 'Frankoppling lyckades.',
    'connection_unlink_failed': 'Frankoppling misslyckades.',
    'connection_load_failed': 'Kunde inte ladda listan.',

    // ── Vardarens nedre navigation ──
    'nav_home': 'Hem',
    'nav_connection': 'Anslut',
    'nav_notification': 'Aviseringar',
    'nav_settings': 'Installningar',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'Andra kontrolltid',
    'heartbeat_schedule_title_ios': 'Tid för hälso-pushavisering',
    'heartbeat_schedule_change_title_ios': 'Ändra tid för hälso-pushavisering',
    'heartbeat_schedule_hint_ios':
        'En hälso-pushavisering kommer varje dag vid denna tid. Tryck på aviseringen eller öppna appen vid den tidpunkten för att skicka din hälsosignal.',
    'heartbeat_daily_time': 'Dagligen kl. @time',
    'heartbeat_scheduled_today':
        'Din valmaendesignal skickas till dina vardare varje dag kl. @time.',
    'heartbeat_change_failed_title': 'Tidandring misslyckades',
    'heartbeat_change_failed_message': 'Kunde inte uppdatera pa servern.',

    // ── Lokala aviseringar ──
    'local_notification_channel': 'Valmaendeaviseringar',
    'local_notification_channel_desc': 'Aviseringar for valmaendetjansten',

    // ── Ovrigt ──
    'back_press_exit': 'Tryck tillbaka igen for att avsluta.',

    // ── API-fel ──
    'error_unknown': 'Ett okant fel uppstod.',
    'error_timeout': 'Forfragan tog for lang tid.',
    'error_network': 'Kontrollera din natverksanslutning.',
    'error_unauthorized': 'Autentisering kravs.',

    // ── Aviseringsinnehall ──
    'noti_auto_report_body': 'Valmaendekontrollen mottogs utan problem.',
    'noti_manual_report_body': 'Den skyddade personen skickade manuellt en valmaendekontroll.',
    'noti_battery_low_body': 'Telefonens batteri ar under 20%. Laddning kan behovas.',
    'noti_battery_dead_body':
        'Telefonen verkar ha stangts av pa grund av tomt batteri. Senaste batteriniva: @battery_level%. Den aterstalls efter laddning.',
    'noti_caution_suspicious_body':
        'En valmaendesignal mottogs men ingen aktivitetsregistrering har upptackts idag. Kontrollera personligen.',
    'noti_caution_missing_body':
        'Dagens schemalagda valmaendekontroll har inte mottagits an. Kontrollera personligen.',
    'noti_warning_body': 'Valmaendekontroller har missats i foljd. Verifiera personligen.',
    'noti_warning_suspicious_body':
        'Ingen aktivitetsregistrering har upptackts i foljd. Personlig verifiering kravs.',
    'noti_urgent_body': 'Ingen valmaendekontroll pa @days dag(ar). Omedelbar verifiering kravs.',
    'noti_urgent_suspicious_body':
        'Ingen aktivitetsregistrering pa @days dag(ar). Omedelbar verifiering kravs.',
    'noti_steps_body': '@steps steg gått idag.',
    'noti_emergency_body': 'Den skyddade personen har direkt begärt hjälp. Kontrollera omedelbart.',
    'noti_resolved_body':
        'Hälsokontrollen för den skyddade personen har återgått till det normala.',
    'noti_cleared_by_guardian_title': '✅ Säkerhet bekräftad',
    'noti_cleared_by_guardian_body': 'En av vårdnadshavarna har personligen bekräftat säkerheten.',

    // ── Lokala aviseringar ──
    'local_alarm_title': '💗 Välmåendekontroll behövs',
    'local_alarm_body': 'Vänligen tryck på denna avisering.',
    'wellbeing_check_title': '💛 Välmåendekontroll',
    'wellbeing_check_body': 'Mår du bra? Vänligen tryck på denna avisering.',
    'noti_channel_name': 'Anbu-aviseringar',
    'notification_send_failed_title': '📶 Kontrollera din internetanslutning',
    'notification_send_failed_body': 'Tryck på det här meddelandet för att skicka igen automatiskt.',
  };
}
