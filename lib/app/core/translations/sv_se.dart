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
    'app_copyright': '© 2026 Averic SB Inc.',

    // ── Splash ──
    'splash_loading': 'Kontrollerar valmaende...',

    // ── Uppdatering ──
    'update_required_title': 'Uppdatering kravs',
    'update_required_message': 'Uppdatera till version @version for att fortsatta anvanda appen.',
    'update_button': 'Uppdatera',
    'update_available_title': 'Uppdatering tillganglig',
    'update_available_message': 'Version @version ar tillganglig.',

    // ── Valj lage ──
    'mode_select_title': 'Valj din roll',
    'mode_select_subtitle': 'Detta hjalper oss att stalla in ratt funktioner for dig',
    'mode_subject_title': 'Jag vill att min sakerhet\novervakas',
    'mode_subject_button': 'Bli skyddad →',
    'mode_guardian_title': 'Jag vill vaka over\nnagon jag bryr mig om',
    'mode_guardian_button': 'Borja som vardare →',
    'mode_select_notice': 'Skarmlayout och aviseringar anpassas efter ditt val',

    // ── Behorigheter ──
    'permission_title': 'Behorigheter kravs\nfor att anvanda appen',
    'permission_notification': 'Aviseringsbehorighet',
    'permission_notification_subject_desc': 'Kravs for att ta emot valmaendeaviseringar',
    'permission_notification_guardian_desc':
        'Kravs for att ta emot sakerhetsaviseringar for dina skyddspersoner',
    'permission_activity': 'Aktivitetsigenkanning',
    'permission_activity_desc': 'Anvands for att upptacka steg och bekrafta aktivitet',
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
    'permission_battery_required_title': 'Ställ in batteriet på "Obegränsat"',
    'permission_battery_required_message':
        'Om det är inställt på "Batterioptimering" eller "Batterisparläge" kan dagliga välmåendekontroller fördröjas eller missas.\n\nEfter att du tryckt på [Ga till Installningar]:\n1. Välj "Batteri"\n2. Ändra till "Obegränsat"',
    'permission_battery_go_to_settings': 'Ga till Installningar',
    'permission_hibernation_title': 'Stäng av "Pausa oanvända appar"',
    'permission_hibernation_highlight': 'Pausa oanvända appar',
    'permission_hibernation_message':
        'Om du inte öppnar appen på flera månader kan Android stoppa den automatiskt och avbryta välmåendekontroller.\n\nTryck på [Öppna appinställningar] och stäng av "Pausa oanvända appar".',
    'permission_hibernation_go_to_settings': 'Öppna appinställningar',

    // ── Introduktion ──
    'onboarding_title_1': 'Orolig for nagon\nsom bor ensam?',
    'onboarding_desc_1': 'Aven pa avstand\nundrar du om allt ar bra.\nAnbu finns har for dig.',
    'onboarding_title_2': 'Valmaendekontroll\nutan ett enda ord',
    'onboarding_desc_2':
        'Bara genom att anvanda sin smartphone\nskickas en daglig signal\nautomatiskt.',
    'onboarding_title_3': 'Dela omtanke\nmed dina narstaende',
    'onboarding_desc_3': 'Dagliga kontroller bygger\nvaraktig trygghet.\nLat oss borja.',
    'onboarding_title_4': 'Inga namn, inga telefonnummer\n— inget samlas in',
    'onboarding_desc_4': 'Bara en signal levereras:\n"Jag mar bra."\nDin information ar trygg.',
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
    'subject_home_emergency_confirm_title': 'Nödhjälpbegäran',
    'subject_home_emergency_confirm_body':
        'Ett nödlarm skickas till alla dina vårdgivare.\nÄr du säker på att du vill begära hjälp?',
    'subject_home_emergency_confirm_send': 'Skicka nödbegäran',
    'subject_home_share_text': 'Kolla in pa mig med Anbu-appen!\nInbjudningskod: @code',
    'subject_home_share_subject': 'Anbu-inbjudningskod',
    'subject_home_code_copied': 'Koden kopierad',

    // ── Skyddspersonens meny ──
    'drawer_light_mode': 'Ljust lage',
    'drawer_dark_mode': 'Morkt lage',
    'drawer_privacy_policy': 'Integritetspolicy',
    'drawer_terms': 'Anvandarvillkor',
    'drawer_withdraw': 'Radera konto',
    'drawer_withdraw_message': 'Ditt konto och all data raderas.\nAr du saker?',

    // ── Vardarens instrumentpanel ──
    'guardian_status_normal': 'Normal',
    'guardian_status_caution': 'Forsiktighet',
    'guardian_status_warning': 'Varning',
    'guardian_status_urgent': 'Bradskande',
    'guardian_status_confirmed': 'Sakerhet bekraftad',
    'guardian_subscription_expired': 'Prenumerationen har gatt ut',
    'guardian_subscription_expired_message':
        'Aviseringar skickas inte.\nFornya prenumerationen for att fortsatta skyddet.',
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
    'guardian_safety_needed': 'Sakerhetskontroll behovs',
    'guardian_error_load_subjects': 'Kunde inte ladda skyddspersoner.',
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
    'settings_free_trial': 'Gratis provperiod',
    'settings_days_remaining': '@days dagar kvar',
    'settings_manage_subscription': 'Hantera prenumeration',
    'settings_notification': 'Aviseringsinstellningar',
    'settings_terms_section': 'Juridiskt',
    'settings_privacy_policy': 'Integritetspolicy',
    'settings_terms': 'Anvandarvillkor',
    'settings_app_version': 'Version: v@version',

    // ── G+S (Vårdare + Skyddad) ──
    'gs_enable_button': 'Få hälsoskydd också',
    'gs_safety_code_button': 'Visa min säkerhetskod',
    'gs_safety_code_title': 'Min säkerhetskod',
    'gs_enable_dialog_title': 'Aktivera hälsoskydd',
    'gs_enable_dialog_body':
        'Du kan få hälsoskydd samtidigt som du behåller dina vårdarfunktioner.\nEn säkerhetskod utfärdas — dela den med andra vårdare.',
    'gs_enable_dialog_ios_warning_title': '⚠ iOS fungerar annorlunda än Android',
    'gs_enable_dialog_ios_warning_body':
        'På iOS visas en "hälso-pushavisering" varje dag vid den schemalagda tiden. Du måste trycka på aviseringen eller själv öppna appen vid den tidpunkten för att din hälsosignal ska skickas. Om du inte öppnar appen kan dina vårdare få en varning om missad kontroll.',
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
    'gs_activity_permission_denied_warning': 'Stegräknartillstånd nekat. Tryck här för att tillåta.',
    'gs_activity_permission_settings_title': 'Behörighet krävs',
    'gs_activity_permission_settings_body': 'Tillåt behörighet för Fysisk aktivitet (Rörelse och kondition) i appinställningarna.',
    'gs_activity_permission_settings_go': 'Gå till inställningar',

    // ── Vardarens aviseringar ──
    'notifications_title': 'Aviseringar',
    'notifications_today': 'Dagens aviseringar',
    'notifications_empty': 'Inga aviseringar idag',
    'notifications_delete_all_title': 'Radera alla aviseringar',
    'notifications_delete_all_message': 'Radera alla dagens aviseringar?',
    'notifications_delete_failed': 'Kunde inte radera aviseringar.',
    'notifications_guide_title': 'Guide for aviseringsniva',
    'notifications_level_health': 'Normal',
    'notifications_level_health_desc': 'Skyddspersonens valmaende ar normalt bekraftat',
    'notifications_level_caution': 'Forsiktighet',
    'notifications_level_caution_desc': 'Ingen välmåendesignal eller telefonanvändning ännu',
    'notifications_level_warning': 'Varning',
    'notifications_level_warning_desc': 'Ingen välmåendesignal eller telefonanvändning flera dagar i rad',
    'notifications_level_urgent': 'Bradskande',
    'notifications_level_urgent_desc': 'Omedelbar kontroll krävs',
    'notifications_level_info': 'Info',
    'notifications_level_info_desc': 'Steg, låg batterinivå och andra aviseringar',
    'notifications_activity_note':
        '※ Aktivitetsinformation kanske inte visas om stegdata inte kunde samlas in.',

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
    'heartbeat_scheduled_today': 'Valmaendekontroll schemalagd kl. @time idag.',
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
    'noti_auto_report_body': 'Den schemalagda valmaendekontrollen mottogs idag.',
    'noti_manual_report_body': 'Den skyddade personen skickade manuellt en valmaendekontroll.',
    'noti_battery_low_body': 'Telefonens batteri ar under 20%. Laddning kan behovas.',
    'noti_battery_dead_body':
        'Telefonen verkar ha stangts av pa grund av tomt batteri. Senaste batteriniva: @battery_level%. Den aterstalls efter laddning.',
    'noti_caution_suspicious_body':
        'En valmaendesignal mottogs men inga tecken pa telefonanvandning. Kontrollera personligen.',
    'noti_caution_missing_body':
        'Dagens schemalagda valmaendekontroll har inte mottagits an. Kontrollera personligen.',
    'noti_warning_body': 'Valmaendekontroller har missats i foljd. Verifiera personligen.',
    'noti_warning_suspicious_body':
        'Inga tecken pa telefonanvandning har upptackts i foljd. Personlig verifiering kravs.',
    'noti_urgent_body': 'Ingen valmaendekontroll pa @days dag(ar). Omedelbar verifiering kravs.',
    'noti_urgent_suspicious_body':
        'Inga tecken pa telefonanvandning pa @days dag(ar). Omedelbar verifiering kravs.',
    'noti_steps_body': '@from_time ~ @to_time: @steps steg.',
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
  };
}
