abstract class SvSe {
  static const Map<String, String> translations = {
    // ── Allmant ──
    'common_confirm': 'Bekräfta',
    'common_cancel': 'Avbryt',
    'common_continue': 'Fortsätt',
    'common_save': 'Spara',
    'common_delete': 'Radera',
    'common_close': 'Stäng',
    'common_next': 'Nästa',
    'common_previous': 'Föregående',
    'common_start': 'Kom igång',
    'common_skip': 'Hoppa över',
    'common_later': 'Senare',
    'common_loading': 'Laddar...',
    'common_error': 'Fel',
    'common_session_expired': 'Dina kontouppgifter har upphört att gälla. Registrera dig igen.',
    'common_complete': 'Klart',
    'common_notice': 'Meddelande',
    'common_unlink': 'Koppla från',
    'common_am': 'fm',
    'common_pm': 'em',
    'common_time_style': 'h24',
    'common_normal': 'Normal',
    'common_connected': 'Ansluten',
    'common_disconnected': 'Ej ansluten',

    // ── Appvarumarke ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Kontrollerar ditt välmående.',
    'app_service_desc': 'Automatisk välmåendekontroll',
    'app_guardian_title': 'Anbu-vårdare',
    'app_copyright': '© 2026 Averic Lab',

    // ── Splash ──
    'splash_loading': 'Kontrollerar välmående...',

    // ── Uppdatering ──
    'update_required_title': 'Uppdatering krävs',
    'update_required_message': 'Uppdatera till version @version för att fortsatta använda appen.',
    'update_button': 'Uppdatera',
    'update_available_title': 'Uppdatering tillgänglig',
    'update_available_message': 'Version @version är tillgänglig.',
    'update_later_button': 'Senare',

    // ── Valj lage ──
    'mode_select_title': 'Hur vill du börja?',
    'mode_select_subtitle': 'Berätta om du hör av dig eller tar emot välmåendesignaler',
    'mode_subject_title': 'Jag vill bara höra av mig',
    'mode_subject_desc': 'En mycket enkel skärm med bara det nödvändiga',
    'mode_subject_button': 'Hör av mig →',
    'mode_guardian_title': 'Vaka över flera personer samtidigt',
    'mode_guardian_desc': 'Vid behov kan du senare även höra av dig själv',
    'mode_guardian_button': 'Ta emot välmåendesignaler →',
    'mode_subject_badge': 'Senior',
    'mode_guardian_badge': 'Vårdare',
    'mode_select_notice': 'Skärmlayouten anpassas efter ditt val',

    // ── Behorigheter ──
    'permission_title': 'Behörigheter krävs\nför att använda appen',
    'permission_notification': 'Aviseringsbehörighet',
    'permission_notification_subject_desc': 'Krävs för att ta emot välmåendeaviseringar',
    'permission_notification_guardian_desc':
        'Krävs för att ta emot säkerhetsaviseringar för dina skyddade personer',
    'permission_activity': 'Aktivitetsigenkänning',
    'permission_activity_desc': 'Används för att upptäcka steg och bekräfta aktivitet',
    'permission_location': 'Plats',
    'permission_location_desc': 'Delas med dina vårdare endast vid en nödbegäran om hjälp',
    'permission_tracking': 'Annonsspårning',
    'permission_tracking_desc': 'Används för personanpassad reklam',
    'location_permission_warning': 'Platsen skickas inte vid en nödbegäran. Tryck för att tillåta.',
    'location_permission_settings_title': 'Platsbehörighet krävs',
    'location_permission_settings_body_ios':
        "Hitta och välj 'Anbu', välj sedan 'När appen används' under 'Plats'.",
    'location_permission_settings_body_android':
        "Välj 'Behörigheter' → 'Plats' och välj sedan 'Tillåt endast medan appen används'.",
    'permission_activity_dialog_title': 'Info om aktivitetsbehörighet',
    'permission_activity_dialog_message':
        'Används för att upptäcka steg och bekräfta aktivitet.\nTryck på "Tillåt" på nästa skärm.',
    'permission_notification_required_title': 'Aviseringsbehörighet krävs',
    'permission_notification_required_message':
        'Aviseringsbehörighet krävs för välmåendetjänsten.\nAktivera den i Inställningar.',
    'permission_go_to_settings': 'Gå till Inställningar',
    'permission_activity_denied_title': 'Behörighet för fysisk aktivitet krävs',
    'permission_activity_denied_message':
        'Behörighet för fysisk aktivitet krävs för att upptäcka steg och verifiera din säkerhet.\n\nUtan denna behörighet skickas ingen steginformation till dina vårdare.\n\nAktivera behörigheten "Fysisk aktivitet" i appinställningarna.',
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
        'När telefonen går in i energisparläge kan välmåendesignaler till din vårdare komma försenade eller missas.\n\nTryck på [Öppna inställningar] nedan och ställ in "Batteri" → "Obegränsad". Då skickas välmåendesignaler tillförlitligt vid den planerade tiden varje dag.\n\n※ Den exakta texten kan variera beroende på enhetstillverkare.',

    // ── Introduktion ──
    'onboarding_safety_code_title': 'Din säkerhetskod skapas automatiskt',
    'onboarding_safety_code_desc':
        'Dela koden med din vårdare för att ansluta —\ndin välmåendesignal skickas då automatiskt.',
    'onboarding_emergency_title': 'När du vill berätta om ditt nuvarande tillstånd (Brådskande) och plats',
    'onboarding_emergency_desc':
        'Tryck på knappen så når det\nomedelbart alla dina vårdare',
    'onboarding_gs_switch_title': 'Ta hand om familjens välmående också',
    'onboarding_gs_switch_desc':
        'Tryck på [Hantera även familjens välmående] i menyn\nför att även använda vårdarrollen',
    'onboarding_add_subject_title': 'Anslut till någon du bryr dig om',
    'onboarding_add_subject_desc':
        'Ange koden du fått och ett smeknamn\nför att ansluta direkt',
    'onboarding_notifications_title': 'Så här ser välmåendeaviseringar ut',
    'onboarding_notifications_desc':
        'Vanligtvis ser du aktivitetsinfo som antal steg. Om ingen signal kommer in eller ingen aktivitet upptäcks får du en avisering som ovan',
    'onboarding_push_now': 'Nu',
    'onboarding_gs_enable_title': 'Aktivera din egen säkerhetskod',
    'onboarding_gs_enable_desc':
        'Tryck i Inställningar på [Skapa min säkerhetskod]\nså når ditt välmående även dina vårdare',
    'onboarding_role_subject': 'Skyddad person',
    'onboarding_role_guardian': 'Vårdare',
    'onboarding_role_guardian_subject': 'Vårdare och skyddad',
    'onboarding_already_registered_title': 'Enheten är redan registrerad',
    'onboarding_already_registered_message':
        'Denna enhet är redan registrerad i "@roleLabel"-läge.\nFortsätt som "@roleLabel"?\n\nEller byt till "@newRoleLabel"-läge?\nByte raderar all befintlig data.',
    'onboarding_already_registered_message_gs':
        'Denna enhet är redan registrerad i "@roleLabel"-läge.\nAtt byta till "@newRoleLabel"-läge raderar alla vårdare- och skyddaddata.',
    'onboarding_registration_failed_title': 'Registrering misslyckades',
    'onboarding_registration_failed_message': 'Kan inte ansluta till servern. Försök igen senare.',

    // ── Skyddspersonens startsida ──
    'subject_home_share_title': 'Dela din säkerhetskod',
    'subject_home_guardian_count': 'Anslutna vårdare: @count',
    'subject_home_check_title_last': 'Senaste kontrollen',
    'subject_home_check_title_scheduled': 'Schemalagd kontrolltid',
    'subject_home_check_title_checking': 'Kontrollerar välmående',
    'subject_home_check_body_reported': 'Rapporterad kl. @time',
    'subject_home_check_body_scheduled': 'Schemalagd kl. @time',
    'subject_home_check_body_waiting': 'Väntar sedan @time',
    'subject_home_battery_status': 'Batteristatus',
    'subject_home_battery_charging': 'Laddar',
    'subject_home_battery_full': 'Fullt',
    'subject_home_battery_low': 'Lågt batteri',
    'subject_home_connectivity_status': 'Anslutning',
    'subject_home_report_loading': 'Rapporterar...',
    'subject_home_report_button': 'Rapportera säkerhet nu',
    'subject_home_report_desc': 'Låt din vårdare veta att du mår bra',
    'subject_home_emergency_button': 'Jag behöver hjälp',
    'subject_home_emergency_desc': 'Skickar ett nödlarm till dina vårdare',
    'subject_home_emergency_loading': 'Skickar nödlarm...',
    'subject_home_emergency_sent': 'Nödlarmet har skickats',
    'subject_home_emergency_failed': 'Det gick inte att skicka nödlarmet',
    'subject_home_manual_report_limit_reached':
        'Du har redan skickat dagens säkerhetsrapport. Försök igen imorgon.',
    'subject_home_manual_report_sent': 'Din välmåendesignal har skickats till dina vårdare.',
    'safety_net_dialog_title': 'Välmåendekontroll skickad',
    'safety_net_dialog_body':
        'Dagens välmåendekontroll har skickats till dina vårdare.',
    'safety_net_dialog_already_body':
        'Dagens välmåendekontroll har redan skickats till dina vårdare kl. @time.',
    'subject_home_emergency_confirm_title': 'Nödhjälpbegäran',
    'subject_home_emergency_confirm_body':
        'Ett nödlarm kommer att skickas till alla dina vårdare.\nDin nuvarande plats delas också.\nVill du verkligen be om hjälp?',
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
    'emergency_message_hint': 'Lägg till ett meddelande (valfritt)',
    'subject_home_share_text': 'Anslut till mig via Anbu-appen.\nAnslutningskod: @code',
    'subject_home_share_subject': 'Anbu-anslutningskod',
    'subject_home_code_copied': 'Koden kopierad',

    // ── Skyddspersonens meny ──
    'drawer_light_mode': 'Ljust läge',
    'drawer_dark_mode': 'Mörkt läge',
    'drawer_privacy_policy': 'Integritetspolicy',
    'drawer_terms': 'Användarvillkor',
    'drawer_withdraw': 'Radera konto',
    'drawer_withdraw_message': 'Ditt konto och all data raderas.\nÄr du säker?',

    // ── Vardarens instrumentpanel ──
    'guardian_status_normal': 'Säker',
    'guardian_status_caution': 'Försiktighet',
    'guardian_status_warning': 'Varning',
    'guardian_status_urgent': 'Brådskande',
    'guardian_status_confirmed': '✅ Säker',
    'guardian_subscription_expired': 'Prenumeration krävs',
    'guardian_subscription_expired_message':
        'De dagliga välmåendesignalerna har upphört.\nFör priset av en lunch vakar du över din närstående hela året.',
    'guardian_subscribe': 'Prenumerera',
    'guardian_payment_preparing': 'Betalningsfunktionen kommer snart.',
    'guardian_today_summary': 'Dagens välmåendesammanfattning',
    'guardian_no_subjects': 'Inga anslutna skyddade personer.',
    'guardian_checking_subjects': 'Kontrollerar för närvarande\n@count skyddsperson(er).',
    'guardian_subject_list': 'Lista över skyddade personer',
    'guardian_call_now': 'Ring nu',
    'phone_call_failed': 'Det gick inte att ringa samtalet.',
    'guardian_confirm_safety': 'Bekräfta',
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
    'guardian_error_load_step_history': 'Kunde inte ladda steghistorik',
    'guardian_chart_y_axis_steps': 'Steg',
    'guardian_chart_x_axis_last_7_days': 'Senaste 7 dagarna',
    'guardian_chart_x_axis_last_30_days': 'Senaste 30 dagarna',
    'guardian_chart_today': 'Idag',
    'guardian_safety_needed': 'Säkerhetskontroll behövs',
    'guardian_error_load_subjects': 'Kunde inte ladda skyddade personer.',
    'guardian_safety_confirmed': 'Säkerhet bekräftad.',
    'guardian_error_clear_alerts': 'Kunde inte rensa aviseringar.',

    // ── Lagg till skyddsperson ──
    'add_subject_title': 'Anslut skyddad person',
    'add_subject_guide_title': 'Ange den skyddade personens unika kod och ett alias.',
    'add_subject_guide_subtitle':
        'Anslut en skyddad persons app för att övervaka hälsa och aktivitet i realtid.',
    'add_subject_code_label': 'Unik kod (7 siffror)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info': 'Den unika koden finns i den skyddade personens app.',
    'add_subject_alias_label': 'Den skyddade personens alias',
    'add_subject_alias_hint': 't.ex. Mamma, Pappa',
    'add_subject_phone_label': 'Telefonnummer (valfritt)',
    'add_subject_phone_info': 'Om det anges ringer samtalsknappen direkt till detta nummer. Om du lämnar det tomt måste du välja kontakten från din kontaktlista.',
    'add_subject_phone_hint': '0701234567',
    'add_subject_connect': 'Anslut',
    'add_subject_error_login': 'Inloggning krävs.',
    'add_subject_success': 'Skyddad person ansluten.',
    'add_subject_error_invalid_code': 'Ogiltig kod.',
    'add_subject_error_self': 'Du kan inte lägga till din egen kod som skyddad person.',
    'add_subject_error_limit': 'Du kan registrera upp till @max personer.',
    'add_subject_error_already_connected': 'Redan ansluten.',
    'add_subject_error_failed': 'Anslutningen misslyckades. Försök igen.',
    'add_subject_button': 'Lägg till ny skyddad person',

    // ── Vardarens installningar ──
    'settings_title': 'Inställningar',
    'settings_light_mode': 'Ljust läge',
    'settings_dark_mode': 'Mörkt läge',
    'settings_connection_management': 'Anslutningshantering',
    'settings_managed_subjects': 'Antal skyddade personer',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'Prenumeration och tjänst',
    'settings_current_membership': 'Nuvarande medlemskap',
    'settings_premium': 'Premium aktivt',
    'guardian_go_to_settings': 'Gå till Inställningar',
    'settings_expired': 'Prenumeration krävs',
    'settings_days_until_renewal': 'D-@days',
    'settings_days_until_trial_end': 'D-@days',
    'settings_free_trial': 'Gratis provperiod',
    'settings_manage_subscription': 'Hantera prenumeration',
    'settings_notification': 'Aviseringsinställningar',
    'settings_terms_section': 'Juridiskt',
    'settings_privacy_policy': 'Integritetspolicy',
    'settings_terms': 'Användarvillkor',
    'settings_ad_consent': 'Hantera annonsmedgivande',
    'settings_app_version': 'Version: v@version',

    // ── App-köp (årlig $9.99-prenumeration för vårdare) ──
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
    'gs_enable_button': 'Skapa min säkerhetskod',
    'gs_safety_code_button': 'Visa min säkerhetskod',
    'gs_enable_button_desc': 'Din familj kan också se till dig',
    'gs_safety_code_button_desc': 'Dela kod · Rapport · Nödläge',
    'gs_safety_code_title': 'Min säkerhetskod',
    'gs_enable_dialog_title': 'Skapa min säkerhetskod',
    'gs_enable_dialog_body':
        'En säkerhetskod utfärdas — dela den med andra vårdare.',
    'gs_enable_dialog_ios_warning_title': '⚠ Hur din välmåendesignal skickas',
    'gs_enable_dialog_ios_warning_body':
        'En "välmåendeavisering" visas varje dag vid den schemalagda tiden. Du måste trycka på aviseringen eller själv öppna appen vid den tidpunkten för att din välmåendesignal ska skickas. Om du inte öppnar appen kan dina vårdare få en varning om missad kontroll.',
    'gs_enable_dialog_ios_confirm': 'Jag förstår, aktivera',
    'gs_enable_confirm': 'Skapa',
    'gs_enabled_message': 'Välmåendeskydd har aktiverats',
    'gs_enable_failed': 'Kunde inte aktivera välmåendeskydd',
    'gs_disable_dialog_title': 'Inaktivera välmåendeskydd',
    'gs_disable_dialog_body':
        'Att inaktivera raderar din säkerhetskod och stoppar välmåendekontroller till anslutna vårdare.',
    'gs_disable_confirm': 'Inaktivera',
    'gs_disabled_message': 'Välmåendeskydd har inaktiverats',
    'gs_disable_failed': 'Kunde inte inaktivera välmåendeskydd',
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
    'notifications_guide_title': 'Guide för aviseringsniva',
    'notifications_level_health': 'Normal',
    'notifications_level_health_desc': 'Den skyddade personens välmående är normalt bekräftat',
    'notifications_level_caution': 'Försiktighet',
    'notifications_level_caution_desc': 'Ingen välmåendesignal eller aktivitetsregistrering ännu',
    'notifications_level_warning': 'Varning',
    'notifications_level_warning_desc':
        'Ingen välmåendesignal eller aktivitetsregistrering flera dagar i rad',
    'notifications_level_urgent': 'Brådskande',
    'notifications_level_urgent_desc': 'Omedelbar kontroll krävs',
    'notifications_level_info': 'Info',
    'notifications_level_info_desc': 'Steg, låg batterinivå och andra aviseringar',
    'notifications_activity_note':
        '※ Stegräknaren visar kumulativa steg från midnatt till tidpunkten då välmåendesignalen skickades.',

    // ── Vardarens aviseringsinstellningar ──
    'notification_settings_title': 'Aviseringsinställningar',
    'notification_settings_push': 'Push-aviseringar',
    'notification_settings_all': 'Alla aviseringar',
    'notification_settings_all_desc':
        'Aktivera eller inaktivera alla aviseringskategorier samtidigt.',
    'notification_settings_level_section': 'Nivåinställningar',
    'notification_settings_urgent': 'Brådskande aviseringar',
    'notification_settings_urgent_desc': 'Brådskande aviseringar kan inte inaktiveras',
    'notification_settings_warning': 'Varningsaviseringar',
    'notification_settings_warning_desc': 'Avisering vid utebliven kontroll 2 dagar i rad',
    'notification_settings_caution': 'Försiktighetsaviseringar',
    'notification_settings_caution_desc': 'Avisering när dagens kontroll saknas',
    'notification_settings_info': 'Informationsaviseringar',
    'notification_settings_info_desc': 'Allmänna aviseringar som stegantal och batteristatus',
    'notification_settings_dnd': 'Stör ej',
    'notification_settings_dnd_start': 'Starttid',
    'notification_settings_dnd_end': 'Sluttid',
    'notification_settings_dnd_note': '※ Brådskande aviseringar levereras även under Stör ej',

    // ── Vardarens anslutningshantering ──
    'connection_title': 'Anslutningshantering',
    'connection_managed_count': 'Antal skyddade personer ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Anslutna skyddade personer',
    'connection_reorder_hint': 'Tryck och håll på ett kort nedan för att ändra ordning',
    'connection_empty': 'Inga anslutna skyddade personer',
    'connection_unlink_warning': 'Frånkoppling raderar den skyddade personens data.',
    'connection_unlink_warning_detail':
        'Tidigare poster kan inte återställas efter återanslutning. Du behöver ange den skyddade personens kod igen.',
    'connection_heartbeat_schedule': 'Dagligen kl. @time',
    'connection_heartbeat_report_time': 'Välmåenderapporttid: ',
    'connection_subject_label': 'Skyddad person',
    'connection_change_only_in_app': 'kan bara ändras i appen',
    'connection_edit_title': 'Redigera skyddad person',
    'connection_alias_label': 'Alias',
    'connection_unlink_title': 'Koppla från',
    'connection_unlink_confirm': 'Koppla från @alias?',
    'connection_unlink_success': 'Frånkoppling lyckades.',
    'connection_unlink_failed': 'Frånkoppling misslyckades.',
    'connection_load_failed': 'Kunde inte ladda listan.',

    // ── Vardarens nedre navigation ──
    'nav_home': 'Hem',
    'nav_connection': 'Anslut',
    'nav_notification': 'Aviseringar',
    'nav_settings': 'Inställningar',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'Ändra välmåendetid',
    'heartbeat_schedule_title_ios': 'Välmåendetid',
    'heartbeat_schedule_change_title_ios': 'Ändra välmåendetid',
    'heartbeat_schedule_hint_ios':
        'En välmåendeavisering kommer varje dag vid denna tid. Tryck på aviseringen eller öppna appen vid den tidpunkten för att skicka din välmåendesignal.',
    'heartbeat_daily_time': 'Dagligen kl. @time',
    'heartbeat_scheduled_today':
        'Din välmåendesignal skickas till dina vårdare varje dag kl. @time.',
    'heartbeat_change_failed_title': 'Tidändring misslyckades',
    'heartbeat_change_failed_message': 'Kunde inte uppdatera på servern.',
    'heartbeat_picker_help': 'Välj en tid före @limit',
    'heartbeat_range_limit_title': 'Tiden är inte tillgänglig',
    'heartbeat_range_limit_message':
        'Tiden för välmåendekontrollen måste vara före @limit.',

    // ── Lokala aviseringar ──
    'local_notification_channel': 'Välmåendeaviseringar',
    'local_notification_channel_desc': 'Aviseringar för välmåendetjänsten',

    // ── Ovrigt ──
    'back_press_exit': 'Tryck tillbaka igen för att avsluta.',

    // ── API-fel ──
    'error_unknown': 'Ett okänt fel uppstod.',
    'error_timeout': 'Förfrågan tog för lång tid.',
    'error_network': 'Kontrollera din nätverksanslutning.',
    'error_unauthorized': 'Autentisering krävs.',

    // ── Aviseringsinnehall ──
    'noti_auto_report_body': 'Välmåendekontrollen mottogs utan problem.',
    'noti_manual_report_body': 'Den skyddade personen skickade en manuell välmåendekontroll.',
    'noti_battery_low_body': 'Telefonens batteri är under 20%. Laddning kan behövas.',
    'noti_battery_dead_body':
        'Telefonen verkar ha stängts av på grund av tomt batteri. Senaste batterinivå: @battery_level%. Den återställs efter laddning.',
    'noti_caution_suspicious_body':
        'En välmåendesignal mottogs men ingen aktivitetsregistrering har upptäckts idag. Kontrollera personligen.',
    'noti_caution_missing_body':
        'Dagens schemalagda välmåendekontroll har ännu inte mottagits. Kontrollera personligen.',
    'noti_warning_body': 'Välmåendekontroller saknas i följd. Personlig verifiering krävs.',
    'noti_warning_suspicious_body':
        'Ingen aktivitetsregistrering har upptäckts i följd. Personlig verifiering krävs.',
    'noti_urgent_body': 'Ingen välmåendekontroll på @days dag(ar). Omedelbar verifiering krävs.',
    'noti_urgent_suspicious_body':
        'Ingen aktivitetsregistrering på @days dag(ar). Omedelbar verifiering krävs.',
    'noti_steps_body': '@steps steg gått idag.',
    'noti_emergency_body': 'Den skyddade personen har direkt begärt hjälp. Kontrollera omedelbart.',
    'noti_resolved_body':
        'Den skyddade personens välmående har bekräftats igen.',
    'noti_cleared_by_guardian_title': '✅ Säkerhet bekräftad',
    'noti_cleared_by_guardian_body': 'En av vårdarna har personligen bekräftat säkerheten.',

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
