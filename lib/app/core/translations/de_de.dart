abstract class DeDe {
  static const Map<String, String> translations = {
    // ── Allgemein ──
    'common_confirm': 'Bestätigen',
    'common_cancel': 'Abbrechen',
    'common_continue': 'Weiter',
    'common_save': 'Speichern',
    'common_delete': 'Löschen',
    'common_close': 'Schließen',
    'common_next': 'Weiter',
    'common_previous': 'Zurück',
    'common_start': 'Jetzt starten',
    'common_skip': 'Überspringen',
    'common_later': 'Später',
    'common_loading': 'Wird geladen...',
    'common_error': 'Fehler',
    'common_complete': 'Fertig',
    'common_notice': 'Hinweis',
    'common_unlink': 'Trennen',
    'common_am': 'AM',
    'common_pm': 'PM',
    'common_normal': 'Normal',
    'common_connected': 'Verbunden',
    'common_disconnected': 'Nicht verbunden',

    // ── App-Marke ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Wir schauen nach Ihrem Wohlbefinden.',
    'app_service_desc': 'Automatischer Wohlbefindens-Check',
    'app_guardian_title': 'Anbu Schutzperson',
    'app_copyright': '© 2026 Averic SB Inc.',

    // ── Splash ──
    'splash_loading': 'Wohlbefinden wird geprüft...',

    // ── Update ──
    'update_required_title': 'Update erforderlich',
    'update_required_message':
        'Bitte aktualisieren Sie auf Version @version, um die App weiter nutzen zu können.',
    'update_button': 'Aktualisieren',
    'update_available_title': 'Update verfügbar',
    'update_available_message': 'Version @version ist verfügbar.',

    // ── Modus-Auswahl ──
    'mode_select_title': 'Wählen Sie Ihre Rolle',
    'mode_select_subtitle':
        'Diese Auswahl hilft uns, die passenden Funktionen für Sie einzurichten',
    'mode_subject_title': 'Ich möchte, dass jemand\nnach mir schaut',
    'mode_subject_button': 'Schutz erhalten →',
    'mode_guardian_title': 'Ich möchte nach jemandem\nschauen, der mir wichtig ist',
    'mode_guardian_button': 'Als Schutzperson starten →',
    'mode_select_notice':
        'Die Bildschirmgestaltung und Benachrichtigungen unterscheiden sich je nach Auswahl',

    // ── Berechtigungen ──
    'permission_title': 'Berechtigungen werden\nbenötigt',
    'permission_notification': 'Benachrichtigungen',
    'permission_notification_subject_desc': 'Erforderlich, um Wohlbefindens-Meldungen zu erhalten',
    'permission_notification_guardian_desc':
        'Erforderlich, um Sicherheitsmeldungen über Ihre Schutzpersonen zu erhalten',
    'permission_activity': 'Aktivitätserkennung',
    'permission_activity_desc':
        'Wird verwendet, um Schritte zu erkennen und Aktivität zu bestätigen',
    'permission_location': 'Standort',
    'permission_location_desc':
        'Wird nur bei Notfallanfragen an Ihre Betreuer übermittelt',
    'permission_activity_dialog_title': 'Hinweis zur Aktivitätsberechtigung',
    'permission_activity_dialog_message':
        'Wird verwendet, um Schritte zu erkennen und Aktivität zu bestätigen.\nBitte tippen Sie im nächsten Bildschirm auf „Erlauben".',
    'permission_notification_required_title': 'Benachrichtigungsberechtigung erforderlich',
    'permission_notification_required_message':
        'Für den Wohlbefindens-Check ist die Benachrichtigungsberechtigung erforderlich.\nBitte aktivieren Sie diese in den Einstellungen.',
    'permission_go_to_settings': 'Zu den Einstellungen',
    'permission_activity_denied_title': 'Berechtigung für körperliche Aktivität erforderlich',
    'permission_activity_denied_message':
        'Wird verwendet, um Schritte zu erkennen und die Genauigkeit der Wohlbefindensprüfung zu verbessern.\nBitte aktivieren Sie die Berechtigung in den Einstellungen.',
    'permission_battery': 'Akku-Optimierung ausschließen',
    'permission_battery_desc':
        'Schließt die App von der Akku-Optimierung aus, damit der tägliche Wohlbefindens-Check zur geplanten Zeit nicht verpasst wird',
    'permission_battery_required_title': 'Bitte setzen Sie den Akku auf "Nicht eingeschränkt"',
    'permission_battery_required_message':
        'Wenn "Akku-Optimierung" oder "Energiesparmodus" aktiviert ist, kann der tägliche Wohlbefindens-Check verzögert oder verpasst werden.\n\nNach dem Tippen auf [Zu den Einstellungen]:\n1. Wählen Sie "Akku"\n2. Auf "Nicht eingeschränkt" ändern',
    'permission_battery_go_to_settings': 'Zu den Einstellungen',
    'permission_hibernation_title': 'Bitte "App bei Nichtnutzung pausieren" deaktivieren',
    'permission_hibernation_highlight': 'App bei Nichtnutzung pausieren',
    'permission_hibernation_message':
        'Wenn Sie die App mehrere Monate nicht öffnen, kann Android sie automatisch stoppen und die Wohlbefindens-Checks unterbrechen.\n\nTippen Sie auf [App-Einstellungen öffnen] und deaktivieren Sie dann "App bei Nichtnutzung pausieren".',
    'permission_hibernation_go_to_settings': 'App-Einstellungen öffnen',

    // ── Onboarding ──
    'onboarding_title_1': 'Machen Sie sich Sorgen\num jemanden, der allein lebt?',
    'onboarding_desc_1':
        'Auch aus der Ferne\nfragt man sich, ob alles in Ordnung ist.\nAnbu ist für Sie da.',
    'onboarding_title_2': 'Wohlbefindens-Checks\nganz ohne Worte',
    'onboarding_desc_2':
        'Allein durch die Smartphone-Nutzung\nwird täglich automatisch\nein Wohlbefindens-Signal gesendet.',
    'onboarding_title_3': 'Teilen Sie das Wohlbefinden\nmit Ihren Liebsten',
    'onboarding_desc_3':
        'Tägliche Meldungen schaffen\nbleibendes Vertrauen und Sicherheit.\nLegen Sie jetzt los.',
    'onboarding_title_4': 'Keine Namen, keine Telefonnummern\n— nichts wird erfasst',
    'onboarding_desc_4':
        'Es wird nur ein Signal übermittelt:\n„Mir geht es gut."\nIhre Daten bleiben sicher.',
    'onboarding_role_subject': 'Schutzperson',
    'onboarding_role_guardian': 'Betreuer',
    'onboarding_role_guardian_subject': 'Betreuer & Schützling',
    'onboarding_already_registered_title': 'Gerät bereits registriert',
    'onboarding_already_registered_message':
        'Dieses Gerät ist bereits im "@roleLabel"-Modus registriert.\nMöchten Sie als "@roleLabel" fortfahren?\n\nOder zum "@newRoleLabel"-Modus wechseln?\nBeim Wechsel werden alle vorhandenen Daten gelöscht.',
    'onboarding_already_registered_message_gs':
        'Dieses Gerät ist bereits im „@roleLabel"-Modus registriert.\nBeim Wechsel zu „@newRoleLabel" werden sowohl Betreuer- als auch Schützlingsdaten gelöscht.',
    'onboarding_registration_failed_title': 'Registrierung fehlgeschlagen',
    'onboarding_registration_failed_message':
        'Verbindung zum Server nicht möglich. Bitte versuchen Sie es später erneut.',

    // ── Startseite (Schutzperson) ──
    'subject_home_share_title': 'Teilen Sie Ihren Sicherheitscode',
    'subject_home_guardian_count': 'Verbundene Betreuer: @count',
    'subject_home_check_title_last': 'Letzter Wohlbefindens-Check',
    'subject_home_check_title_scheduled': 'Geplante Prüfzeit',
    'subject_home_check_title_checking': 'Wohlbefinden wird geprüft',
    'subject_home_check_body_reported': 'Gemeldet um @time',
    'subject_home_check_body_scheduled': 'Geplant um @time',
    'subject_home_check_body_waiting': 'Warten seit @time',
    'subject_home_battery_status': 'Akkustand',
    'subject_home_battery_charging': 'Wird geladen',
    'subject_home_battery_full': 'Voll',
    'subject_home_battery_low': 'Akku schwach',
    'subject_home_connectivity_status': 'Verbindungsstatus',
    'subject_home_report_loading': 'Wird gemeldet...',
    'subject_home_report_button': 'Jetzt Wohlbefinden melden',
    'subject_home_report_desc': 'Lassen Sie Ihren Betreuer wissen, dass es Ihnen gut geht',
    'subject_home_emergency_button': 'Ich brauche Hilfe',
    'subject_home_emergency_desc': 'Sendet einen Notruf an Ihre Betreuer',
    'subject_home_emergency_loading': 'Notruf wird gesendet...',
    'subject_home_emergency_sent': 'Notruf wurde gesendet',
    'subject_home_emergency_failed': 'Notruf konnte nicht gesendet werden',
    'subject_home_manual_report_limit_reached': 'Sie haben den heutigen Sicherheitsbericht bereits gesendet. Bitte versuchen Sie es morgen erneut.',
    'subject_home_emergency_confirm_title': 'Nothilfe anfordern',
    'subject_home_emergency_confirm_body':
        'Ein Notruf wird an alle Betreuer gesendet.\nIhr aktueller Standort wird ebenfalls geteilt.\nMöchten Sie wirklich Hilfe anfordern?',
    'emergency_sent_with_location': 'Notruf gesendet (mit Standort)',
    'emergency_sent_without_location': 'Notruf gesendet',
    'notifications_view_location': '🗺️ Standort anzeigen',
    'emergency_map_title': 'Notfallstandort',
    'emergency_map_subject_label': 'Betreute Person',
    'emergency_map_captured_at_label': 'Erfasst um',
    'emergency_map_accuracy_label': 'Genauigkeit',
    'emergency_map_open_external': 'In externer Karten-App öffnen',
    'emergency_map_no_location': 'Keine Standortdaten verfügbar',
    'emergency_location_permission_denied_snackbar': 'Notruf ohne Standortberechtigung gesendet',
    'subject_home_emergency_confirm_send': 'Notruf senden',
    'subject_home_share_text': 'Schauen Sie mit der Anbu-App nach mir!\nEinladungscode: @code',
    'subject_home_share_subject': 'Anbu Einladungscode',
    'subject_home_code_copied': 'Code kopiert',

    // ── Drawer (Schutzperson) ──
    'drawer_light_mode': 'Heller Modus',
    'drawer_dark_mode': 'Dunkler Modus',
    'drawer_privacy_policy': 'Datenschutzrichtlinie',
    'drawer_terms': 'Nutzungsbedingungen',
    'drawer_withdraw': 'Konto löschen',
    'drawer_withdraw_message': 'Ihr Konto und alle Daten werden gelöscht.\nSind Sie sicher?',

    // ── Betreuer-Dashboard ──
    'guardian_status_normal': 'Sicher',
    'guardian_status_caution': 'Achtung',
    'guardian_status_warning': 'Warnung',
    'guardian_status_urgent': 'Dringend',
    'guardian_status_confirmed': '✅ Sicher',
    'guardian_subscription_expired': 'Abo abgelaufen',
    'guardian_subscription_expired_message':
        'Warnmeldungen werden nicht mehr gesendet.\nErneuern Sie Ihr Abo, um den Schutz fortzusetzen.',
    'guardian_subscribe': 'Abonnieren',
    'guardian_payment_preparing': 'Zahlungsfunktion wird vorbereitet.',
    'guardian_today_summary': 'Heutige Zusammenfassung',
    'guardian_no_subjects': 'Keine Schutzpersonen verbunden.',
    'guardian_checking_subjects': 'Derzeit wird das Wohlbefinden\nvon @count Person(en) geprüft.',
    'guardian_subject_list': 'Liste der Schutzpersonen',
    'guardian_call_now': 'Jetzt anrufen',
    'guardian_confirm_safety': 'Sicherheit bestätigen',
    'guardian_no_check_history': 'Keine Prüfungen vorhanden',
    'guardian_last_check_now': 'Letzte Prüfung: gerade eben',
    'guardian_last_check_minutes': 'Letzte Prüfung: vor @minutes Min.',
    'guardian_last_check_hours': 'Letzte Prüfung: vor @hours Std.',
    'guardian_last_check_days': 'Letzte Prüfung: vor @days Tag(en)',
    'guardian_activity_stable': 'Aktivität: stabil',
    'guardian_activity_prefix': 'Aktivität',
    'guardian_activity_very_active': 'Sehr aktiv',
    'guardian_activity_active': 'Aktiv',
    'guardian_activity_needs_exercise': 'Bewegung nötig',
    'guardian_activity_collecting': 'Daten werden gesammelt',
    'guardian_error_load_step_history': 'Schrittverlauf konnte nicht geladen werden',
    'guardian_chart_y_axis_steps': 'Schritte',
    'guardian_chart_x_axis_last_7_days': 'Letzte 7 Tage',
    'guardian_chart_x_axis_last_30_days': 'Letzte 30 Tage',
    'guardian_chart_today': 'Heute',
    'guardian_safety_needed': 'Sicherheitsprüfung erforderlich',
    'guardian_error_load_subjects': 'Schutzpersonen konnten nicht geladen werden.',
    'guardian_error_clear_alerts': 'Warnungen konnten nicht aufgehoben werden.',

    // ── Schutzperson hinzufügen ──
    'add_subject_title': 'Schutzperson verbinden',
    'add_subject_guide_title': 'Geben Sie den Einladungscode und einen Spitznamen ein.',
    'add_subject_guide_subtitle':
        'Verbinden Sie die App einer Schutzperson, um deren Zustand in Echtzeit zu verfolgen.',
    'add_subject_code_label': 'Einladungscode (7 Zeichen)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info': 'Den Einladungscode finden Sie in der App der Schutzperson.',
    'add_subject_alias_label': 'Spitzname',
    'add_subject_alias_hint': 'z. B. Mama, Papa',
    'add_subject_connect': 'Verbinden',
    'add_subject_error_login': 'Anmeldung erforderlich.',
    'add_subject_success': 'Schutzperson erfolgreich verbunden.',
    'add_subject_error_invalid_code': 'Ungültiger Code.',
    'add_subject_error_already_connected': 'Bereits verbunden.',
    'add_subject_error_failed': 'Verbindung fehlgeschlagen. Bitte versuchen Sie es erneut.',
    'add_subject_button': 'Neue Schutzperson hinzufügen',

    // ── Betreuer-Einstellungen ──
    'settings_title': 'Einstellungen',
    'settings_light_mode': 'Heller Modus',
    'settings_dark_mode': 'Dunkler Modus',
    'settings_connection_management': 'Verbindungsverwaltung',
    'settings_managed_subjects': 'Verwaltete Schutzpersonen',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'Abo & Service',
    'settings_current_membership': 'Aktuelle Mitgliedschaft',
    'settings_premium': 'Premium aktiv',
    'settings_free_trial': 'Kostenlose Testphase',
    'settings_days_remaining': 'Noch @days Tage',
    'settings_manage_subscription': 'Abo verwalten',
    'settings_notification': 'Benachrichtigungseinstellungen',
    'settings_terms_section': 'Rechtliches',
    'settings_privacy_policy': 'Datenschutzrichtlinie',
    'settings_terms': 'Nutzungsbedingungen',
    'settings_app_version': 'Version: v@version',

    // ── G+S (Betreuer + Schützling) ──
    'gs_enable_button': 'Auch Wellness-Schutz erhalten',
    'gs_safety_code_button': 'Meinen Sicherheitscode prüfen',
    'gs_safety_code_title': 'Mein Sicherheitscode',
    'gs_enable_dialog_title': 'Wellness-Schutz aktivieren',
    'gs_enable_dialog_body':
        'Sie können Wellness-Schutz erhalten und gleichzeitig Ihre Betreuer-Funktionen behalten.\nBei Aktivierung wird ein Sicherheitscode ausgestellt — bitte teilen Sie ihn mit anderen Betreuern.',
    'gs_enable_dialog_ios_warning_title': '⚠ iOS funktioniert anders als Android',
    'gs_enable_dialog_ios_warning_body':
        'Auf iOS erscheint täglich zur festgelegten Zeit eine "Wellness-Push-Benachrichtigung". Sie müssen die Benachrichtigung antippen oder die App selbst um diese Zeit öffnen, damit Ihr Wellness-Signal gesendet wird. Wenn Sie die App nicht öffnen, erhalten Ihre Betreuer möglicherweise eine Warnung wegen ausbleibender Prüfung.',
    'gs_enable_dialog_ios_confirm': 'Verstanden, aktivieren',
    'gs_enable_confirm': 'Aktivieren',
    'gs_enabled_message': 'Wellness-Schutz wurde aktiviert',
    'gs_enable_failed': 'Wellness-Schutz konnte nicht aktiviert werden',
    'gs_disable_dialog_title': 'Wellness-Schutz deaktivieren',
    'gs_disable_dialog_body':
        'Bei Deaktivierung wird Ihr Sicherheitscode gelöscht und die Wellness-Prüfungen an verbundene Betreuer werden gestoppt.',
    'gs_disable_confirm': 'Deaktivieren',
    'gs_disabled_message': 'Wellness-Schutz wurde deaktiviert',
    'gs_disable_failed': 'Wellness-Schutz konnte nicht deaktiviert werden',
    'gs_activity_permission_denied_warning': 'Schrittzähler-Berechtigung verweigert. Hier tippen, um zu erlauben.',
    'gs_activity_permission_settings_title': 'Berechtigung erforderlich',
    'gs_activity_permission_settings_body': 'Bitte erlauben Sie die Berechtigung „Körperliche Aktivität (Bewegung & Fitness)" in den App-Einstellungen.',
    'gs_activity_permission_settings_go': 'Zu den Einstellungen',

    // ── Betreuer → G+S Umschaltung (Drawer/Dialog) ──
    'drawer_enable_guardian': 'Auch Familienwohl verwalten',
    's_to_gs_dialog_title': 'Betreuer-Funktion hinzufügen',
    's_to_gs_dialog_body':
        'Fügen Sie die Betreuer-Funktion hinzu, um auch das Wohlbefinden von Familie oder geliebten Menschen zu überwachen.\n(Hinweis: Die Betreuer-Funktion ist 3 Monate kostenlos und wird anschließend kostenpflichtig.)\n\nIhr persönlicher Sicherheitscode und die derzeitige Übermittlung Ihrer Wohlbefindenssignale bleiben unverändert und weiterhin kostenlos.',
    's_to_gs_dialog_confirm': 'Weiter',
    's_to_gs_switch_failed': 'Aktivierung der Betreuer-Funktion fehlgeschlagen',

    // ── Betreuer-Benachrichtigungen ──
    'notifications_title': 'Benachrichtigungen',
    'notifications_today': 'Heutige Benachrichtigungen',
    'notifications_empty': 'Heute keine Benachrichtigungen',
    'notifications_delete_all_title': 'Alle Benachrichtigungen löschen',
    'notifications_delete_all_message': 'Alle heutigen Benachrichtigungen löschen?',
    'notifications_delete_failed': 'Benachrichtigungen konnten nicht gelöscht werden.',
    'notifications_guide_title': 'Erklärung der Benachrichtigungsstufen',
    'notifications_level_health': 'Normal',
    'notifications_level_health_desc': 'Wohlbefinden der Schutzperson wurde bestätigt',
    'notifications_level_caution': 'Achtung',
    'notifications_level_caution_desc': 'Noch kein Wohlbefindenssignal oder keine Handynutzung erkannt',
    'notifications_level_warning': 'Warnung',
    'notifications_level_warning_desc': 'Mehrere Tage in Folge kein Wohlbefindenssignal oder keine Handynutzung erkannt',
    'notifications_level_urgent': 'Dringend',
    'notifications_level_urgent_desc': 'Sofortige Überprüfung erforderlich',
    'notifications_level_info': 'Info',
    'notifications_level_info_desc': 'Schritte, niedriger Akku und weitere Hinweise',
    'notifications_activity_note':
        '※ Aktivitätsdaten werden möglicherweise nicht angezeigt, wenn Schrittzahlen nicht erfasst werden konnten.',

    // ── Betreuer-Benachrichtigungseinstellungen ──
    'notification_settings_title': 'Benachrichtigungseinstellungen',
    'notification_settings_push': 'Push-Benachrichtigungen',
    'notification_settings_all': 'Alle Benachrichtigungen',
    'notification_settings_all_desc':
        'Alle Benachrichtigungskategorien auf einmal aktivieren oder deaktivieren.',
    'notification_settings_level_section': 'Stufeneinstellungen',
    'notification_settings_urgent': 'Dringende Meldungen',
    'notification_settings_urgent_desc': 'Dringende Meldungen können nicht deaktiviert werden',
    'notification_settings_warning': 'Warnmeldungen',
    'notification_settings_warning_desc': 'Warnung bei 2 Tagen ohne Prüfung in Folge',
    'notification_settings_caution': 'Achtung-Meldungen',
    'notification_settings_caution_desc': 'Meldung bei fehlender heutiger Prüfung',
    'notification_settings_info': 'Info-Meldungen',
    'notification_settings_info_desc': 'Allgemeine Meldungen wie Schrittzahl und Akkustand',
    'notification_settings_dnd': 'Bitte nicht stören',
    'notification_settings_dnd_start': 'Startzeit',
    'notification_settings_dnd_end': 'Endzeit',
    'notification_settings_dnd_note':
        '※ Dringende Meldungen werden auch im „Bitte nicht stören"-Modus zugestellt',
    'notification_settings_dnd_start_default': '22:00',
    'notification_settings_dnd_end_default': '07:00',

    // ── Verbindungsverwaltung ──
    'connection_title': 'Verbindungsverwaltung',
    'connection_managed_count': 'Verwaltete Schutzpersonen ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Verbundene Schutzpersonen',
    'connection_empty': 'Keine verbundenen Schutzpersonen',
    'connection_unlink_warning': 'Beim Trennen werden die Daten der Schutzperson gelöscht.',
    'connection_unlink_warning_detail':
        'Frühere Aufzeichnungen können nach erneuter Verbindung nicht wiederhergestellt werden. Sie müssen den Code der Schutzperson erneut eingeben.',
    'connection_heartbeat_schedule': 'Täglich um @time',
    'connection_heartbeat_report_time': 'Die Meldezeit ist ',
    'connection_subject_label': 'Schutzperson',
    'connection_change_only_in_app': 'kann nur in der App geändert werden',
    'connection_edit_title': 'Schutzperson bearbeiten',
    'connection_alias_label': 'Spitzname',
    'connection_unlink_title': 'Trennen',
    'connection_unlink_confirm': '@alias trennen?',
    'connection_unlink_success': 'Erfolgreich getrennt.',
    'connection_unlink_failed': 'Trennen fehlgeschlagen.',
    'connection_load_failed': 'Liste konnte nicht geladen werden.',

    // ── Untere Navigation ──
    'nav_home': 'Start',
    'nav_connection': 'Verbindung',
    'nav_notification': 'Meldungen',
    'nav_settings': 'Einstellungen',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'Prüfzeit ändern',
    'heartbeat_schedule_title_ios': 'Wellness-Push-Zeit',
    'heartbeat_schedule_change_title_ios': 'Wellness-Push-Zeit ändern',
    'heartbeat_schedule_hint_ios':
        'Eine Wellness-Push-Benachrichtigung trifft täglich zu dieser Zeit ein. Tippen Sie auf die Benachrichtigung oder öffnen Sie die App um diese Zeit, um Ihr Wellness-Signal zu senden.',
    'heartbeat_daily_time': 'Täglich um @time',
    'heartbeat_scheduled_today': 'Ihr Wohlbefindens-Signal wird täglich um @time an Ihre Betreuer gesendet.',
    'heartbeat_change_failed_title': 'Zeitänderung fehlgeschlagen',
    'heartbeat_change_failed_message': 'Konnte nicht auf dem Server aktualisiert werden.',

    // ── Lokale Benachrichtigungen ──
    'local_notification_channel': 'Wohlbefindens-Meldungen',
    'local_notification_channel_desc': 'Benachrichtigungen des Wohlbefindens-Dienstes',

    // ── Sonstiges ──
    'back_press_exit': 'Noch einmal drücken, um die App zu beenden.',

    // ── API-Fehler ──
    'error_unknown': 'Ein unbekannter Fehler ist aufgetreten.',
    'error_timeout': 'Zeitüberschreitung der Anfrage.',
    'error_network': 'Bitte überprüfen Sie Ihre Internetverbindung.',
    'error_unauthorized': 'Authentifizierung erforderlich.',

    // ── Benachrichtigungstexte ──
    'noti_auto_report_body': 'Die geplante Wohlbefindens-Prüfung wurde heute empfangen.',
    'noti_manual_report_body': 'Die Schutzperson hat manuell eine Wohlbefindens-Prüfung gesendet.',
    'noti_battery_low_body':
        'Der Akkustand des Telefons liegt unter 20 %. Aufladen könnte nötig sein.',
    'noti_battery_dead_body':
        'Das Telefon scheint wegen eines leeren Akkus ausgeschaltet zu sein. Letzter Akkustand: @battery_level %. Es wird nach dem Laden automatisch wiederhergestellt.',
    'noti_caution_suspicious_body':
        'Ein Wohlbefindens-Signal wurde empfangen, aber es gibt keine Anzeichen für Telefonnutzung. Bitte persönlich nachsehen.',
    'noti_caution_missing_body':
        'Die geplante Wohlbefindens-Prüfung für heute steht noch aus. Bitte persönlich nachsehen.',
    'noti_warning_body':
        'Wohlbefindens-Prüfungen wurden hintereinander versäumt. Bitte persönlich überprüfen.',
    'noti_warning_suspicious_body':
        'Wiederholt keine Anzeichen einer Telefonnutzung festgestellt. Bitte persönlich überprüfen.',
    'noti_urgent_body':
        'Seit @days Tag(en) keine Wohlbefindens-Prüfung. Sofortige Überprüfung erforderlich.',
    'noti_urgent_suspicious_body':
        'Seit @days Tag(en) keine Anzeichen einer Telefonnutzung. Sofortige Überprüfung erforderlich.',
    'noti_steps_body': 'Heute @steps Schritte gegangen.',
    'noti_emergency_body':
        'Die betreute Person hat direkt um Hilfe gebeten. Bitte sofort überprüfen.',
    'noti_resolved_body': 'Der Wellness-Check der betreuten Person ist wieder normal.',
    'noti_cleared_by_guardian_title': '✅ Sicherheit bestätigt',
    'noti_cleared_by_guardian_body': 'Einer der Betreuer hat die Sicherheit persönlich bestätigt.',

    // ── Lokale Benachrichtigungen ──
    'local_alarm_title': '💗 Wohlbefindens-Prüfung erforderlich',
    'local_alarm_body': 'Bitte tippen Sie auf diese Benachrichtigung.',
    'wellbeing_check_title': '💛 Wohlbefindens-Prüfung',
    'wellbeing_check_body': 'Geht es Ihnen gut? Bitte tippen Sie auf diese Benachrichtigung.',
    'noti_channel_name': 'Anbu-Benachrichtigungen',
    'notification_send_failed_title': '📶 Bitte überprüfen Sie Ihre Internetverbindung',
    'notification_send_failed_body': 'Öffnen Sie die App, um Ihre Wohlbefindensprüfung erneut zu senden.',
  };
}
