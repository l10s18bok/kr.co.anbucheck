abstract class ItIt {
  static const Map<String, String> translations = {
    // ── Comune ──
    'common_confirm': 'Conferma',
    'common_cancel': 'Annulla',
    'common_continue': 'Continua',
    'common_save': 'Salva',
    'common_delete': 'Elimina',
    'common_close': 'Chiudi',
    'common_next': 'Avanti',
    'common_previous': 'Indietro',
    'common_start': 'Inizia',
    'common_skip': 'Salta',
    'common_later': 'Dopo',
    'common_loading': 'Caricamento...',
    'common_error': 'Errore',
    'common_complete': 'Fatto',
    'common_notice': 'Avviso',
    'common_unlink': 'Scollega',
    'common_am': 'AM',
    'common_pm': 'PM',
    'common_normal': 'Normale',
    'common_connected': 'Connesso',
    'common_disconnected': 'Non connesso',

    // ── Brand dell'app ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Verifichiamo il Suo benessere.',
    'app_service_desc': 'Servizio automatico di verifica del benessere',
    'app_guardian_title': 'Anbu Guardiano',
    'app_copyright': '© 2026 Ark SB Inc.',

    // ── Splash ──
    'splash_loading': 'Verifica in corso...',

    // ── Aggiornamento ──
    'update_required_title': 'Aggiornamento necessario',
    'update_required_message': "Per continuare a usare l'app, aggiorni alla versione @version.",
    'update_button': 'Aggiorna',
    'update_available_title': 'Aggiornamento disponibile',
    'update_available_message': 'La versione @version è disponibile.',

    // ── Selezione modalità ──
    'mode_select_title': 'Scelga il Suo ruolo',
    'mode_select_subtitle': 'Questo ci aiuta a configurare le funzionalità più adatte a Lei',
    'mode_subject_title': 'Desidero che la mia\nsicurezza venga monitorata',
    'mode_subject_button': 'Voglio essere protetto →',
    'mode_guardian_title': 'Desidero vegliare su\nuna persona cara',
    'mode_guardian_button': 'Inizia come guardiano →',
    'mode_select_notice':
        'La disposizione dello schermo e le notifiche varieranno in base alla Sua scelta',

    // ── Permessi ──
    'permission_title': "Per utilizzare l'app\nsono necessari dei permessi",
    'permission_notification': 'Permesso notifiche',
    'permission_notification_subject_desc':
        'Necessario per ricevere gli avvisi di verifica del benessere',
    'permission_notification_guardian_desc':
        'Necessario per ricevere le notifiche sullo stato di sicurezza dei Suoi assistiti',
    'permission_activity': 'Riconoscimento attività',
    'permission_activity_desc': "Utilizzato per rilevare i passi e verificare l'attività",
    'permission_location': 'Posizione',
    'permission_location_desc':
        'Condivisa con i tutori solo durante una richiesta di aiuto urgente',
    'location_permission_warning':
        "La posizione non verrà inviata con la richiesta di emergenza. Tocca per consentire.",
    'location_permission_settings_title': 'Autorizzazione alla posizione richiesta',
    'location_permission_settings_body_ios':
        "Cerca e seleziona 'Anbu', poi in 'Posizione' scegli 'Mentre uso l'app'.",
    'location_permission_settings_body_android':
        "Seleziona 'Autorizzazioni' → 'Posizione', poi scegli 'Consenti solo durante l'uso dell'app'.",
    'permission_activity_dialog_title': 'Informazioni sul permesso attività',
    'permission_activity_dialog_message':
        'Utilizzato per rilevare i passi e verificare l\'attività.\nSelezioni "Consenti" nella schermata successiva.',
    'permission_notification_required_title': 'Permesso notifiche necessario',
    'permission_notification_required_message':
        'Il permesso notifiche è necessario per il servizio di verifica del benessere.\nLo abiliti nelle Impostazioni.',
    'permission_go_to_settings': 'Vai alle Impostazioni',
    'permission_activity_denied_title': 'Autorizzazione attività fisica richiesta',
    'permission_activity_denied_message':
        'Viene utilizzata per rilevare i passi e migliorare la precisione del controllo del benessere.\nAbilita l\'autorizzazione attività fisica nelle Impostazioni.',
    'permission_battery': 'Esclusione ottimizzazione batteria',
    'permission_battery_desc':
        'Esclude l\'app dall\'ottimizzazione della batteria affinché il controllo giornaliero del benessere non venga perso',
    'permission_battery_required_title': 'Imposta la batteria su "Senza restrizioni"',
    'permission_battery_required_message':
        'Se è impostata su "Ottimizzazione batteria" o "Risparmio energetico", il controllo giornaliero del benessere potrebbe essere ritardato o perso.\n\nDopo aver toccato [Vai alle Impostazioni]:\n1. Seleziona "Batteria"\n2. Cambia in "Senza restrizioni"',
    'permission_battery_go_to_settings': 'Vai alle Impostazioni',
    'permission_hibernation_title': 'Disattiva "Sospendi attività se non usata"',
    'permission_hibernation_highlight': 'Sospendi attività se non usata',
    'permission_hibernation_message':
        'Se non apri l\'app per diversi mesi, Android potrebbe interromperla automaticamente, interrompendo i controlli di benessere.\n\nTocca [Apri impostazioni app] e disattiva "Sospendi attività se non usata".',
    'permission_hibernation_go_to_settings': 'Apri impostazioni app',

    // ── Onboarding ──
    'onboarding_title_1': 'Si preoccupa per qualcuno\nche vive da solo?',
    'onboarding_desc_1': 'Anche da lontano,\nsi chiede se stia bene.\nAnbu è qui per Lei.',
    'onboarding_title_2': 'La verifica del benessere\navviene senza una parola',
    'onboarding_desc_2':
        'Semplicemente usando lo smartphone,\nun segnale giornaliero\nviene inviato automaticamente.',
    'onboarding_title_3': 'Condivida il benessere\ncon i Suoi cari',
    'onboarding_desc_3':
        'I controlli quotidiani si accumulano\nin una tranquillità duratura.\nIniziamo.',
    'onboarding_title_4': 'Nessun nome, nessun numero\ndi telefono raccolto',
    'onboarding_desc_4':
        'Viene trasmesso un solo segnale:\n"Sto bene."\nLe Sue informazioni sono al sicuro.',
    'onboarding_role_subject': 'Assistito',
    'onboarding_role_guardian': 'Guardiano',
    'onboarding_role_guardian_subject': 'Guardiano e protetto',
    'onboarding_already_registered_title': 'Dispositivo già registrato',
    'onboarding_already_registered_message':
        'Questo dispositivo è già registrato in modalità "@roleLabel".\nDesidera continuare come "@roleLabel"?\n\nOppure passare alla modalità "@newRoleLabel"?\nIl cambio eliminerà tutti i dati esistenti.',
    'onboarding_already_registered_message_gs':
        'Questo dispositivo è già registrato in modalità "@roleLabel".\nPassare a "@newRoleLabel" eliminerà tutti i dati di guardiano e protetto.',
    'onboarding_registration_failed_title': 'Registrazione non riuscita',
    'onboarding_registration_failed_message':
        'Impossibile connettersi al server. Riprovi più tardi.',

    // ── Home assistito ──
    'subject_home_share_title': 'Condivida il Suo codice di sicurezza',
    'subject_home_guardian_count': 'Guardiani connessi: @count',
    'subject_home_check_title_last': 'Ultima verifica',
    'subject_home_check_title_scheduled': 'Prossima verifica prevista',
    'subject_home_check_title_checking': 'Verifica in corso',
    'subject_home_check_body_reported': 'Segnalato alle @time',
    'subject_home_check_body_scheduled': 'Previsto alle @time',
    'subject_home_check_body_waiting': 'In attesa dalle @time',
    'subject_home_battery_status': 'Stato batteria',
    'subject_home_battery_charging': 'In carica',
    'subject_home_battery_full': 'Carica completa',
    'subject_home_battery_low': 'Batteria scarica',
    'subject_home_connectivity_status': 'Connettività',
    'subject_home_report_loading': 'Invio segnalazione...',
    'subject_home_report_button': 'Segnala ora che sta bene',
    'subject_home_report_desc': 'Faccia sapere al Suo guardiano che sta bene',
    'subject_home_emergency_button': 'Ho bisogno di aiuto',
    'subject_home_emergency_desc': "Invia un'allerta di emergenza ai tuoi tutori",
    'subject_home_emergency_loading': "Invio dell'allerta di emergenza...",
    'subject_home_emergency_sent': "L'allerta di emergenza è stata inviata",
    'subject_home_emergency_failed': "Invio dell'allerta di emergenza fallito",
    'subject_home_manual_report_limit_reached':
        'Hai già inviato il rapporto di sicurezza di oggi. Riprova domani.',
    'subject_home_manual_report_sent': 'Il tuo messaggio è stato inviato ai tuoi contatti.',
    'subject_home_emergency_confirm_title': 'Richiesta di aiuto di emergenza',
    'subject_home_emergency_confirm_body':
        "Un'allerta di emergenza sarà inviata a tutti i tutori.\nAnche la tua posizione attuale sarà condivisa.\nVuoi davvero richiedere aiuto?",
    'emergency_sent_with_location': 'Allerta di emergenza inviata (con posizione)',
    'emergency_sent_without_location': 'Allerta di emergenza inviata',
    'notifications_view_location': '🗺️ Visualizza posizione',
    'emergency_map_title': 'Posizione di emergenza',
    'emergency_map_subject_label': 'Persona assistita',
    'emergency_map_captured_at_label': 'Acquisito alle',
    'emergency_map_accuracy_label': 'Precisione',
    'emergency_map_open_external': "Apri in un'app di mappe esterna",
    'emergency_map_no_location': 'Nessuna informazione sulla posizione',
    'emergency_location_permission_denied_snackbar':
        'Allerta di emergenza inviata senza autorizzazione alla posizione',
    'subject_home_emergency_confirm_send': 'Invia richiesta di emergenza',
    'subject_home_share_text': "Controlli come sto con l'app Anbu!\nCodice invito: @code",
    'subject_home_share_subject': 'Codice invito Anbu',
    'subject_home_code_copied': 'Codice copiato',

    // ── Drawer assistito ──
    'drawer_light_mode': 'Modalità chiara',
    'drawer_dark_mode': 'Modalità scura',
    'drawer_privacy_policy': 'Informativa sulla privacy',
    'drawer_terms': 'Termini di servizio',
    'drawer_withdraw': 'Elimina account',
    'drawer_withdraw_message': 'Il Suo account e tutti i dati verranno eliminati.\nÈ sicuro/a?',

    // ── Dashboard guardiano ──
    'guardian_status_normal': 'Sicuro',
    'guardian_status_caution': 'Attenzione',
    'guardian_status_warning': 'Avviso',
    'guardian_status_urgent': 'Urgente',
    'guardian_status_confirmed': '✅ Sicuro',
    'guardian_subscription_expired': 'Abbonamento scaduto',
    'guardian_subscription_expired_message':
        'Le notifiche di avviso non vengono inviate.\nRinnovi il Suo abbonamento per continuare la protezione.',
    'guardian_subscribe': 'Abbonati',
    'guardian_payment_preparing': 'La funzione di pagamento sarà disponibile a breve.',
    'guardian_today_summary': 'Riepilogo benessere di oggi',
    'guardian_no_subjects': 'Nessun assistito connesso.',
    'guardian_checking_subjects': 'Attualmente monitoriamo\n@count assistito/i.',
    'guardian_subject_list': 'Lista assistiti',
    'guardian_call_now': 'Chiama ora',
    'guardian_confirm_safety': 'Conferma sicurezza',
    'guardian_no_check_history': 'Nessun controllo registrato',
    'guardian_last_check_now': 'Ultimo controllo: adesso',
    'guardian_last_check_minutes': 'Ultimo controllo: @minutes min fa',
    'guardian_last_check_hours': 'Ultimo controllo: @hours ore fa',
    'guardian_last_check_days': 'Ultimo controllo: @days giorno/i fa',
    'guardian_activity_stable': 'Attività: stabile',
    'guardian_activity_prefix': 'Attività',
    'guardian_activity_very_active': 'Molto attivo',
    'guardian_activity_active': 'Attivo',
    'guardian_activity_needs_exercise': 'Necessita esercizio',
    'guardian_activity_collecting': 'Raccolta dati in corso',
    'guardian_error_load_step_history': 'Impossibile caricare la cronologia dei passi',
    'guardian_chart_y_axis_steps': 'Passi',
    'guardian_chart_x_axis_last_7_days': 'Ultimi 7 giorni',
    'guardian_chart_x_axis_last_30_days': 'Ultimi 30 giorni',
    'guardian_chart_today': 'Oggi',
    'guardian_safety_needed': 'Verifica di sicurezza necessaria',
    'guardian_error_load_subjects': 'Impossibile caricare la lista degli assistiti.',
    'guardian_safety_confirmed': 'Sicurezza confermata.',
    'guardian_error_clear_alerts': 'Impossibile cancellare gli avvisi.',

    // ── Aggiunta assistito ──
    'add_subject_title': 'Collega assistito',
    'add_subject_guide_title': "Inserisca il codice univoco dell'assistito e un soprannome.",
    'add_subject_guide_subtitle':
        "Colleghi l'app dell'assistito per monitorare la sua salute e attività in tempo reale.",
    'add_subject_code_label': 'Codice univoco (7 cifre)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info': "Il codice univoco si trova nell'app dell'assistito.",
    'add_subject_alias_label': "Soprannome dell'assistito",
    'add_subject_alias_hint': 'Es: Mamma, Papà',
    'add_subject_connect': 'Collega',
    'add_subject_error_login': 'Accesso necessario.',
    'add_subject_success': 'Assistito collegato con successo.',
    'add_subject_error_invalid_code': 'Codice non valido.',
    'add_subject_error_already_connected': 'Già collegato.',
    'add_subject_error_failed': 'Collegamento non riuscito. Riprovi più tardi.',
    'add_subject_button': 'Aggiungi nuovo assistito',

    // ── Impostazioni guardiano ──
    'settings_title': 'Impostazioni',
    'settings_light_mode': 'Modalità chiara',
    'settings_dark_mode': 'Modalità scura',
    'settings_connection_management': 'Gestione connessioni',
    'settings_managed_subjects': 'Assistiti gestiti',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'Abbonamento e servizio',
    'settings_current_membership': 'Abbonamento attuale',
    'settings_premium': 'Premium attivo',
    'settings_free_trial': 'Prova gratuita',
    'settings_days_remaining': '@days giorni rimasti',
    'settings_manage_subscription': "Gestisci l'abbonamento",
    'settings_notification': 'Impostazioni notifiche',
    'settings_terms_section': 'Legale',
    'settings_privacy_policy': 'Informativa sulla privacy',
    'settings_terms': 'Termini di servizio',
    'settings_app_version': 'Versione: v@version',

    // ── G+S (Guardiano e protetto) ──
    'gs_enable_button': 'Ricevi anche la protezione',
    'gs_safety_code_button': 'Verifica il mio codice di sicurezza',
    'gs_safety_code_title': 'Il mio codice di sicurezza',
    'gs_enable_dialog_title': 'Attiva protezione',
    'gs_enable_dialog_body':
        'Puoi ricevere protezione mantenendo le funzioni di guardiano.\nVerrà emesso un codice di sicurezza — condividilo con altri guardiani.',
    'gs_enable_dialog_ios_warning_title': '⚠ iOS funziona diversamente da Android',
    'gs_enable_dialog_ios_warning_body':
        'Su iOS appare ogni giorno all\'orario programmato una "notifica push di benessere". Devi toccare la notifica o aprire l\'app tu stesso in quel momento affinché il tuo segnale di benessere venga inviato. Se non apri l\'app, i tuoi guardiani potrebbero ricevere un avviso di verifica mancata.',
    'gs_enable_dialog_ios_confirm': 'Ho capito, attiva',
    'gs_enable_confirm': 'Attiva',
    'gs_enabled_message': 'La protezione è stata attivata',
    'gs_enable_failed': 'Attivazione della protezione fallita',
    'gs_disable_dialog_title': 'Disattiva protezione',
    'gs_disable_dialog_body':
        'Disattivando verrà eliminato il codice di sicurezza e verranno interrotte le verifiche ai guardiani collegati.',
    'gs_disable_confirm': 'Disattiva',
    'gs_disabled_message': 'La protezione è stata disattivata',
    'gs_disable_failed': 'Disattivazione della protezione fallita',
    'gs_activity_permission_denied_warning':
        'Autorizzazione contapassi negata. Tocca qui per consentire.',
    'gs_activity_permission_settings_title': 'Autorizzazione richiesta',
    'gs_activity_permission_settings_body':
        'Consenti l\'autorizzazione Attività fisica (Movimento e Fitness) nelle impostazioni dell\'app.',
    'gs_activity_permission_settings_go': 'Vai alle impostazioni',

    // ── Modalità Guardiano → G+S (Drawer/Dialog) ──
    'drawer_enable_guardian': 'Gestisci anche il benessere dei familiari',
    's_to_gs_dialog_title': 'Aggiungi funzione Guardiano',
    's_to_gs_dialog_body':
        'Aggiungi la funzione Guardiano per monitorare anche il benessere di familiari o persone care.\n(Nota: la funzione Guardiano è gratuita per 3 mesi, poi passa a un abbonamento a pagamento.)\n\nIl tuo codice di sicurezza e l\'invio dei segnali di benessere attualmente in uso restano invariati e continueranno ad essere gratuiti.',
    's_to_gs_dialog_confirm': 'Continua',
    's_to_gs_switch_failed': 'Attivazione della funzione Guardiano fallita',

    // ── Notifiche guardiano ──
    'notifications_title': 'Notifiche',
    'notifications_today': 'Notifiche di oggi',
    'notifications_empty': 'Nessuna notifica oggi',
    'notifications_delete_all_title': 'Elimina tutte le notifiche',
    'notifications_auto_delete_notice':
        'Le notifiche di oggi vengono eliminate automaticamente a mezzanotte (0:00).',
    'notifications_delete_all_message': 'Eliminare tutte le notifiche di oggi?',
    'notifications_delete_failed': 'Impossibile eliminare le notifiche.',
    'notifications_guide_title': 'Guida ai livelli di notifica',
    'notifications_level_health': 'Normale',
    'notifications_level_health_desc': "Il benessere dell'assistito è stato confermato normalmente",
    'notifications_level_caution': 'Attenzione',
    'notifications_level_caution_desc': 'Nessun segnale di benessere né attività del telefono',
    'notifications_level_warning': 'Avviso',
    'notifications_level_warning_desc':
        'Nessun segnale di benessere né attività del telefono per più giorni',
    'notifications_level_urgent': 'Urgente',
    'notifications_level_urgent_desc': 'Verifica immediata necessaria',
    'notifications_level_info': 'Info',
    'notifications_level_info_desc': 'Passi, batteria scarica e altri avvisi',
    'notifications_activity_note':
        "※ Le informazioni sull'attività potrebbero non essere visualizzate se i dati dei passi non sono stati raccolti.",

    // ── Impostazioni notifiche guardiano ──
    'notification_settings_title': 'Impostazioni notifiche',
    'notification_settings_push': 'Notifiche push',
    'notification_settings_all': 'Tutte le notifiche',
    'notification_settings_all_desc':
        'Attiva o disattiva tutte le categorie di notifica contemporaneamente.',
    'notification_settings_level_section': 'Impostazioni per livello',
    'notification_settings_urgent': 'Avvisi urgenti',
    'notification_settings_urgent_desc': 'Gli avvisi urgenti non possono essere disattivati',
    'notification_settings_warning': 'Avvisi di avviso',
    'notification_settings_warning_desc':
        'Avviso quando non ci sono controlli per 2 giorni consecutivi',
    'notification_settings_caution': 'Avvisi di attenzione',
    'notification_settings_caution_desc':
        'Avviso quando il controllo di oggi non è stato effettuato',
    'notification_settings_info': 'Avvisi informativi',
    'notification_settings_info_desc':
        'Avvisi generali come numero di passi e stato della batteria',
    'notification_settings_dnd': 'Non disturbare',
    'notification_settings_dnd_start': 'Ora di inizio',
    'notification_settings_dnd_end': 'Ora di fine',
    'notification_settings_dnd_note':
        '※ Gli avvisi urgenti vengono recapitati anche durante la modalità Non disturbare',
    'notification_settings_dnd_start_default': '22:00',
    'notification_settings_dnd_end_default': '07:00',

    // ── Gestione connessioni guardiano ──
    'connection_title': 'Gestione connessioni',
    'connection_managed_count': 'Assistiti gestiti ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Assistiti connessi',
    'connection_empty': 'Nessuna persona protetta collegata',
    'connection_unlink_warning': "Lo scollegamento eliminerà i dati dell'assistito.",
    'connection_unlink_warning_detail':
        "I dati precedenti non potranno essere recuperati dopo un nuovo collegamento. Dovrà reinserire il codice dell'assistito.",
    'connection_heartbeat_schedule': 'Ogni giorno alle @time',
    'connection_heartbeat_report_time': "L'orario di segnalazione del benessere è ",
    'connection_subject_label': 'Assistito',
    'connection_change_only_in_app': "può essere modificato solo nell'app",
    'connection_edit_title': 'Modifica assistito',
    'connection_alias_label': 'Soprannome',
    'connection_unlink_title': 'Scollega',
    'connection_unlink_confirm': 'Scollegare @alias?',
    'connection_unlink_success': 'Scollegamento riuscito.',
    'connection_unlink_failed': 'Scollegamento non riuscito.',
    'connection_load_failed': 'Impossibile caricare la lista.',

    // ── Navigazione inferiore guardiano ──
    'nav_home': 'Home',
    'nav_connection': 'Connessioni',
    'nav_notification': 'Avvisi',
    'nav_settings': 'Impostazioni',

    // ── Heartbeat ──
    'heartbeat_schedule_change': "Cambia l'orario di verifica",
    'heartbeat_schedule_title_ios': 'Orario notifica push di benessere',
    'heartbeat_schedule_change_title_ios': 'Cambia orario notifica push di benessere',
    'heartbeat_schedule_hint_ios':
        'Una notifica push di benessere arriva ogni giorno a quest\'ora. Tocca la notifica o apri l\'app in quel momento per inviare il tuo segnale di benessere.',
    'heartbeat_daily_time': 'Ogni giorno alle @time',
    'heartbeat_scheduled_today':
        'Il tuo segnale di benessere sarà inviato ai tuoi guardiani ogni giorno alle @time.',
    'heartbeat_change_failed_title': "Modifica dell'orario non riuscita",
    'heartbeat_change_failed_message': 'Impossibile aggiornare sul server.',

    // ── Notifiche locali ──
    'local_notification_channel': 'Avvisi benessere',
    'local_notification_channel_desc': 'Notifiche del servizio di verifica del benessere',

    // ── Varie ──
    'back_press_exit': 'Prema di nuovo indietro per uscire.',

    // ── Errori API ──
    'error_unknown': 'Si è verificato un errore sconosciuto.',
    'error_timeout': 'La richiesta è scaduta.',
    'error_network': 'Verifichi la connessione di rete.',
    'error_unauthorized': 'Autenticazione necessaria.',

    // ── Corpo delle notifiche ──
    'noti_auto_report_body': 'La verifica di benessere è stata ricevuta con successo.',
    'noti_manual_report_body':
        'La persona protetta ha inviato manualmente una verifica di benessere.',
    'noti_battery_low_body':
        'La batteria del telefono è inferiore al 20 %. Potrebbe essere necessario ricaricare.',
    'noti_battery_dead_body':
        'Il telefono sembra essersi spento per batteria scarica. Ultimo livello batteria: @battery_level %. Si ripristinerà dopo la ricarica.',
    'noti_caution_suspicious_body':
        'È stato ricevuto un segnale di benessere, ma non ci sono segni di utilizzo del telefono. Verifichi di persona.',
    'noti_caution_missing_body':
        'La verifica di benessere prevista per oggi non è ancora arrivata. Verifichi di persona.',
    'noti_warning_body':
        'Le verifiche di benessere sono state mancate consecutivamente. È necessaria una verifica di persona.',
    'noti_warning_suspicious_body':
        'Nessun segno di utilizzo del telefono rilevato consecutivamente. È necessaria una verifica di persona.',
    'noti_urgent_body':
        'Nessuna verifica di benessere da @days giorno/i. È necessaria una verifica immediata.',
    'noti_urgent_suspicious_body':
        'Nessun segno di utilizzo del telefono da @days giorno/i. È necessaria una verifica immediata.',
    'noti_steps_body': '@steps passi percorsi oggi.',
    'noti_emergency_body':
        "La persona assistita ha richiesto direttamente aiuto. Verificare immediatamente.",
    'noti_resolved_body': 'Il controllo benessere dell\'assistito è tornato nella norma.',
    'noti_cleared_by_guardian_title': '✅ Verifica confermata',
    'noti_cleared_by_guardian_body': 'Uno dei tutori ha confermato personalmente la sicurezza.',

    // ── Notifiche locali ──
    'local_alarm_title': '💗 Verifica di benessere necessaria',
    'local_alarm_body': 'Per favore, tocca questa notifica.',
    'wellbeing_check_title': '💛 Verifica di benessere',
    'wellbeing_check_body': 'Come sta? Per favore, tocca questa notifica.',
    'noti_channel_name': 'Avvisi Anbu',
    'notification_send_failed_title': '📶 Controlla la tua connessione Internet',
    'notification_send_failed_body':
        'Apri l\'app per inviare di nuovo il tuo controllo di benessere.',
  };
}
