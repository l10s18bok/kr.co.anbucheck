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
    'common_session_expired': "Le informazioni dell'account sono scadute. Registrati di nuovo.",
    'common_complete': 'Fatto',
    'common_notice': 'Avviso',
    'common_unlink': 'Scollega',
    'common_am': 'AM',
    'common_pm': 'PM',
    'common_time_style': 'h24',
    'common_normal': 'Normale',
    'common_connected': 'Connesso',
    'common_disconnected': 'Non connesso',

    // ── Brand dell'app ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Verifichiamo il Suo benessere.',
    'app_service_desc': 'Servizio automatico di verifica del benessere',
    'app_guardian_title': 'Anbu Guardiano',
    'app_copyright': '© 2026 Averic Lab',

    // ── Splash ──
    'splash_loading': 'Verifica in corso...',

    // ── Aggiornamento ──
    'update_required_title': 'Aggiornamento necessario',
    'update_required_message':
        "Per continuare a usare l'app, aggiorni alla versione @version.",
    'update_button': 'Aggiorna',
    'update_available_title': 'Aggiornamento disponibile',
    'update_available_message': 'La versione @version è disponibile.',
    'update_later_button': 'Più tardi',

    // ── Selezione modalità ──
    'mode_select_title': 'Come vuole iniziare?',
    'mode_select_subtitle':
        'Ci dica se vuole far sapere che sta bene o riceverne notizia',
    'mode_subject_title': 'Voglio solo far sapere che sto bene',
    'mode_subject_desc': 'Una schermata molto semplice, solo l\'essenziale',
    'mode_subject_button': 'Far sapere che sto bene →',
    'mode_guardian_title': 'Può vegliare su più persone',
    'mode_guardian_desc':
        'Se necessario, in seguito potrà inviare anche le Sue notizie',
    'mode_guardian_button': 'Ricevere notizie →',
    'mode_subject_badge': 'Anziano',
    'mode_guardian_badge': 'Guardiano',
    'mode_select_notice': 'La schermata sarà diversa in base alla Sua scelta',

    // ── Permessi ──
    'permission_title': "Per utilizzare l'app\nsono necessari dei permessi",
    'permission_notification': 'Permesso notifiche',
    'permission_notification_subject_desc':
        'Necessario per ricevere gli avvisi di verifica del benessere',
    'permission_notification_guardian_desc':
        'Necessario per ricevere le notifiche sullo stato di sicurezza dei Suoi assistiti',
    'permission_activity': 'Riconoscimento attività',
    'permission_activity_desc':
        "Utilizzato per rilevare i passi e verificare l'attività",
    'permission_location': 'Posizione',
    'permission_location_desc':
        'Condivisa con i guardiani solo durante una richiesta di aiuto urgente',
    'permission_tracking': 'Tracciamento annunci',
    'permission_tracking_desc': 'Usato per mostrare annunci personalizzati',
    'location_permission_warning':
        'La posizione non verrà inviata con la richiesta di emergenza. Tocchi per consentire.',
    'location_permission_settings_title':
        'Autorizzazione alla posizione richiesta',
    'location_permission_settings_body_ios':
        'Cerchi e selezioni "Anbu", poi in "Posizione" scelga "Mentre uso l\'app".',
    'location_permission_settings_body_android':
        'Selezioni "Autorizzazioni" → "Posizione", poi scelga "Consenti solo durante l\'uso dell\'app".',
    'permission_activity_dialog_title': 'Informazioni sul permesso attività',
    'permission_activity_dialog_message':
        'Utilizzato per rilevare i passi e verificare l\'attività.\nSelezioni "Consenti" nella schermata successiva.',
    'permission_notification_required_title': 'Permesso notifiche necessario',
    'permission_notification_required_message':
        'Il permesso notifiche è necessario per il servizio di verifica del benessere.\nLo abiliti nelle Impostazioni.',
    'permission_go_to_settings': 'Vai alle Impostazioni',
    'permission_activity_denied_title':
        'Autorizzazione attività fisica richiesta',
    'permission_activity_denied_message':
        "Viene utilizzata per rilevare i passi e migliorare la precisione del controllo del benessere.\nAbiliti l'autorizzazione attività fisica nelle Impostazioni.",
    'permission_battery': 'Esclusione ottimizzazione batteria',
    'permission_battery_desc':
        'Esclude l\'app dall\'ottimizzazione della batteria affinché il controllo giornaliero del benessere non venga perso',
    'permission_hibernation_title':
        'Disattivi la rimozione automatica dei permessi',
    'permission_hibernation_highlight': 'rimozione automatica dei permessi',
    'permission_hibernation_message':
        "Android rimuove automaticamente i permessi delle app non utilizzate da molto tempo. Anbu di solito funziona senza essere aperta, quindi questa funzione può far scomparire i permessi dopo un po' e interrompere l'invio del segnale di benessere.\n\nTocchi [Apri impostazioni] qui sotto — verrà mostrata direttamente la schermata dell'interruttore. Disattivi l'interruttore.\n\n※ La dicitura esatta può variare a seconda del produttore del dispositivo.",
    'permission_hibernation_go_to_settings': 'Apri impostazioni',
    'stability_battery_warning_short':
        'È necessario disattivare la limitazione di utilizzo della batteria',
    'stability_battery_dialog_title':
        'Disattivare la limitazione di utilizzo della batteria',
    'stability_battery_dialog_message':
        'Quando il telefono entra in modalità di risparmio energetico, i segnali di benessere inviati al Suo guardiano possono arrivare in ritardo o andare persi.\n\nDopo aver toccato [Apri impostazioni] qui sotto, imposti "Batteria" → "Senza restrizioni". In questo modo i segnali di benessere vengono inviati in modo affidabile all\'orario previsto ogni giorno.\n\n※ La dicitura esatta può variare a seconda del produttore del dispositivo.',

    // ── Onboarding ──
    'onboarding_safety_code_title':
        'Il Suo codice di sicurezza viene generato automaticamente',
    'onboarding_safety_code_desc':
        'Condivida questo codice con il Suo guardiano per collegarvi —\nil Suo segnale di benessere verrà inviato automaticamente.',
    'onboarding_emergency_title':
        'Quando vuole comunicare il Suo stato (Urgente) e la Sua posizione attuali',
    'onboarding_emergency_desc':
        'Tocchi questo pulsante e verrà inviato\nsubito a tutti i Suoi guardiani',
    'onboarding_gs_switch_title':
        'Si prenda cura anche del benessere della Sua famiglia',
    'onboarding_gs_switch_desc':
        'Tocchi [Gestisci anche il benessere dei familiari] nel menu\nper usare anche il ruolo di guardiano',
    'onboarding_add_subject_title': 'Si connetta con una persona cara',
    'onboarding_add_subject_desc':
        'Inserisca il codice ricevuto e un soprannome\nper collegarvi subito',
    'onboarding_notifications_title':
        'Ecco come appaiono le notifiche di benessere',
    'onboarding_notifications_desc':
        "Di norma vedrà informazioni sull'attività come i passi. Se il segnale non arriva o non viene rilevata attività, riceverà una notifica come sopra",
    'onboarding_push_now': 'Ora',
    'onboarding_gs_enable_title': 'Attivi il Suo codice di sicurezza',
    'onboarding_gs_enable_desc':
        'In Impostazioni, tocchi [Crea il mio codice di sicurezza]\nper inviare il Suo benessere anche ai Suoi guardiani',
    'onboarding_role_subject': 'Assistito',
    'onboarding_role_guardian': 'Guardiano',
    'onboarding_role_guardian_subject': 'Guardiano e assistito',
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
    'subject_home_emergency_desc':
        "Invia un'allerta di emergenza ai Suoi guardiani",
    'subject_home_emergency_loading': "Invio dell'allerta di emergenza...",
    'subject_home_emergency_sent': "L'allerta di emergenza è stata inviata",
    'subject_home_emergency_failed': "Invio dell'allerta di emergenza fallito",
    'subject_home_manual_report_limit_reached':
        'Ha già inviato la verifica di benessere di oggi. Riprovi domani.',
    'subject_home_manual_report_sent':
        'Il Suo segnale di benessere è stato inviato ai Suoi guardiani.',
    'safety_net_dialog_title': 'Verifica inviata',
    'safety_net_dialog_body':
        'La verifica di benessere di oggi è stata inviata ai Suoi guardiani.',
    'safety_net_dialog_already_body':
        'La verifica di benessere di oggi è già stata inviata ai Suoi guardiani alle @time.',
    'subject_home_emergency_confirm_title': 'Richiesta di aiuto di emergenza',
    'subject_home_emergency_confirm_body':
        "Un'allerta di emergenza sarà inviata a tutti i Suoi guardiani.\nAnche la Sua posizione attuale sarà condivisa.\nVuole davvero richiedere aiuto?",
    'emergency_sent_with_location':
        'Allerta di emergenza inviata (con posizione)',
    'emergency_sent_without_location': 'Allerta di emergenza inviata',
    'notifications_view_location': '🗺️ Visualizza posizione',
    'emergency_map_title': 'Posizione di emergenza',
    'emergency_map_subject_label': 'Assistito',
    'emergency_map_captured_at_label': 'Acquisito alle',
    'emergency_map_accuracy_label': 'Precisione',
    'emergency_map_open_external': "Apri in un'app di mappe esterna",
    'emergency_map_no_location': 'Nessuna informazione sulla posizione',
    'emergency_location_permission_denied_snackbar':
        'Allerta di emergenza inviata senza autorizzazione alla posizione',
    'subject_home_emergency_confirm_send': 'Invia richiesta di emergenza',
    'emergency_message_hint': 'Aggiungi un messaggio (facoltativo)',
    'subject_home_share_text':
        "Collegati con me sull'app Anbu.\nCodice di collegamento: @code",
    'subject_home_share_subject': 'Codice di collegamento Anbu',
    'subject_home_code_copied': 'Codice copiato',

    // ── Drawer assistito ──
    'drawer_light_mode': 'Modalità chiara',
    'drawer_dark_mode': 'Modalità scura',
    'drawer_privacy_policy': 'Informativa sulla privacy',
    'drawer_terms': 'Termini di servizio',
    'drawer_withdraw': 'Elimina account',
    'drawer_withdraw_message':
        'Il Suo account e tutti i dati verranno eliminati.\nÈ sicuro/a?',

    // ── Dashboard guardiano ──
    'guardian_status_normal': 'Normale',
    'guardian_status_caution': 'Attenzione',
    'guardian_status_warning': 'Avviso',
    'guardian_status_urgent': 'Urgente',
    'guardian_status_confirmed': '✅ Normale',
    'guardian_subscription_expired': 'Abbonamento necessario',
    'guardian_subscription_expired_message':
        "Gli aggiornamenti quotidiani si sono fermati.\nAl prezzo di un pranzo, vegli sui Suoi cari tutto l'anno.",
    'guardian_subscribe': 'Abbonati',
    'guardian_payment_preparing':
        'La funzione di pagamento sarà disponibile a breve.',
    'guardian_today_summary': 'Riepilogo benessere di oggi',
    'guardian_no_subjects': 'Nessun assistito connesso.',
    'guardian_checking_subjects':
        'Attualmente monitoriamo\nassistiti: @count',
    'guardian_subject_list': 'Lista assistiti',
    'guardian_call_now': 'Chiama ora',
    'phone_call_failed': 'Impossibile effettuare la chiamata.',
    'guardian_confirm_safety': 'Conferma',
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
    'guardian_error_load_step_history':
        'Impossibile caricare la cronologia dei passi',
    'guardian_my_steps': 'I miei passi',
    'guardian_chart_y_axis_steps': 'Passi',
    'guardian_chart_x_axis_last_7_days': 'Ultimi 7 giorni',
    'guardian_chart_x_axis_last_30_days': 'Ultimi 30 giorni',
    'guardian_chart_today': 'Oggi',
    'guardian_safety_needed': 'Verifica necessaria',
    'guardian_error_load_subjects':
        'Impossibile caricare la lista degli assistiti.',
    'guardian_safety_confirmed': 'Sicurezza confermata.',
    'guardian_error_clear_alerts': 'Impossibile cancellare gli avvisi.',

    // ── Aggiunta assistito ──
    'add_subject_title': 'Collega assistito',
    'add_subject_guide_title':
        "Inserisca il codice univoco dell'assistito e un soprannome.",
    'add_subject_guide_subtitle':
        "Colleghi l'app dell'assistito per monitorare la sua salute e attività in tempo reale.",
    'add_subject_code_label': 'Codice univoco (7 cifre)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info':
        "Il codice univoco si trova nell'app dell'assistito.",
    'add_subject_alias_label': "Soprannome dell'assistito",
    'add_subject_alias_hint': 'Es: Mamma, Papà',
    'add_subject_phone_label': 'Numero di telefono (facoltativo)',
    'add_subject_phone_info': 'Se inserito, il pulsante di chiamata compone direttamente questo numero. Altrimenti dovrà scegliere il contatto dalla rubrica.',
    'add_subject_phone_hint': '3331234567',
    'add_subject_connect': 'Collega',
    'add_subject_error_login': 'Accesso necessario.',
    'add_subject_success': 'Assistito collegato con successo.',
    'add_subject_error_invalid_code': 'Codice non valido.',
    'add_subject_error_self':
        'Non può aggiungere il Suo codice come persona da assistere.',
    'add_subject_error_limit': 'Può registrare fino a @max persone.',
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
    'guardian_go_to_settings': 'Vai alle impostazioni',
    'settings_expired': 'Abbonamento necessario',
    'settings_days_until_renewal': 'D-@days',
    'settings_days_until_trial_end': 'D-@days',
    'settings_free_trial': 'Prova gratuita',
    'settings_manage_subscription': "Gestisci l'abbonamento",
    'settings_notification': 'Impostazioni notifiche',
    'settings_terms_section': 'Legale',
    'settings_privacy_policy': 'Informativa sulla privacy',
    'settings_terms': 'Termini di servizio',
    'settings_ad_consent': 'Impostazioni consenso annunci',
    'settings_app_version': 'Versione: v@version',

    // ── Acquisti in-app (abbonamento annuale Tutore $9.99) ──
    'subscription_subscribe': 'Abbonati',
    'trial_ended_noti_title': 'Anbu',
    'trial_ended_noti_body':
        'La tua prova gratuita è terminata. Abbonati per continuare.',
    'subscription_restore': 'Ripristina acquisto',
    'subscription_store_unavailable': 'Store non disponibile',
    'subscription_product_unavailable': 'Abbonamento non disponibile',
    'subscription_purchase_failed': 'Acquisto non riuscito',
    'subscription_verify_failed': 'Verifica dell\'abbonamento non riuscita',
    'subscription_restore_failed': 'Ripristino non riuscito',
    'subscription_restore_nothing': 'Nessun abbonamento da ripristinare',
    'subscription_restore_success': 'Abbonamento ripristinato',
    'subscription_purchase_success': 'Abbonamento avviato',
    'subscription_period_annual': 'anno',

    // ── G+S (Guardiano e protetto) ──
    'gs_enable_button': 'Crea il mio codice di sicurezza',
    'gs_safety_code_button': 'Verifica il mio codice di sicurezza',
    'gs_enable_button_desc': 'Anche la Sua famiglia può controllare come sta',
    'gs_safety_code_button_desc': 'Condividi · Segnala · Emergenza',
    'gs_safety_code_title': 'Il mio codice di sicurezza',
    'gs_enable_dialog_title': 'Crea il mio codice di sicurezza',
    'gs_enable_dialog_body':
        'Verrà emesso un codice di sicurezza — lo condivida con gli altri guardiani.',
    'gs_enable_dialog_ios_warning_title':
        '⚠ Come viene inviato il Suo segnale di benessere',
    'gs_enable_dialog_ios_warning_body':
        'Ogni giorno all\'orario programmato appare una "notifica push di benessere". Deve toccare la notifica o aprire l\'app in quel momento affinché il Suo segnale di benessere venga inviato. Se non apre l\'app, i Suoi guardiani potrebbero ricevere un avviso di verifica mancata.',
    'gs_enable_dialog_ios_confirm': 'Ho capito, attiva',
    'gs_enable_confirm': 'Crea',
    'gs_enabled_message': 'La protezione è stata attivata',
    'gs_enable_failed': 'Attivazione della protezione fallita',
    'gs_disable_dialog_title': 'Disattiva protezione',
    'gs_disable_dialog_body':
        'Disattivando verrà eliminato il Suo codice di sicurezza e verranno interrotte le verifiche ai guardiani collegati.',
    'gs_disable_confirm': 'Disattiva',
    'gs_disabled_message': 'La protezione è stata disattivata',
    'gs_disable_failed': 'Disattivazione della protezione fallita',
    'gs_activity_permission_denied_warning':
        'Autorizzazione contapassi negata. Tocchi qui per consentire.',
    'gs_activity_permission_settings_title': 'Autorizzazione richiesta',
    'gs_activity_permission_settings_body':
        "Consenta l'autorizzazione Attività fisica (Movimento e Fitness) nelle impostazioni dell'app.",
    'gs_activity_permission_settings_go': 'Vai alle impostazioni',

    // ── Modalità Guardiano → G+S (Drawer/Dialog) ──
    'drawer_enable_guardian': 'Gestisci anche il benessere dei familiari',
    's_to_gs_dialog_title': 'Aggiungi funzione Guardiano',
    's_to_gs_dialog_body':
        "Aggiunga la funzione Guardiano per monitorare anche il benessere di familiari o persone care.\n(Nota: la funzione Guardiano è gratuita per 3 mesi, poi passa a un abbonamento a pagamento.)\n\nIl Suo codice di sicurezza e l'invio dei segnali di benessere attualmente in uso restano invariati e continueranno ad essere gratuiti.",
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
    'notifications_level_health_desc':
        "Il benessere dell'assistito è stato confermato normalmente",
    'notifications_level_caution': 'Attenzione',
    'notifications_level_caution_desc':
        'Nessun segnale di benessere né registro di attività',
    'notifications_level_warning': 'Avviso',
    'notifications_level_warning_desc':
        'Nessun segnale di benessere né registro di attività per più giorni',
    'notifications_level_urgent': 'Urgente',
    'notifications_level_urgent_desc': 'Verifica immediata necessaria',
    'notifications_level_info': 'Info',
    'notifications_level_info_desc': 'Passi, batteria scarica e altri avvisi',
    'notifications_activity_note':
        '※ Il conteggio dei passi rappresenta i passi accumulati dalla mezzanotte fino all\'ora di invio del segnale di benessere.',

    // ── Impostazioni notifiche guardiano ──
    'notification_settings_title': 'Impostazioni notifiche',
    'notification_settings_push': 'Notifiche push',
    'notification_settings_all': 'Tutte le notifiche',
    'notification_settings_all_desc':
        'Attiva o disattiva tutte le categorie di notifica contemporaneamente.',
    'notification_settings_level_section': 'Impostazioni per livello',
    'notification_settings_urgent': 'Avvisi urgenti',
    'notification_settings_urgent_desc':
        'Gli avvisi urgenti non possono essere disattivati',
    'notification_settings_warning': 'Avvisi di allerta',
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

    // ── Gestione connessioni guardiano ──
    'connection_title': 'Gestione connessioni',
    'connection_managed_count': 'Assistiti gestiti ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Assistiti connessi',
    'connection_reorder_hint': 'Tenga premuta una scheda qui sotto per riordinare',
    'connection_empty': 'Nessun assistito collegato',
    'connection_unlink_warning':
        "Lo scollegamento eliminerà i dati dell'assistito.",
    'connection_unlink_warning_detail':
        "I dati precedenti non potranno essere recuperati dopo un nuovo collegamento. Dovrà reinserire il codice dell'assistito.",
    'connection_heartbeat_schedule': 'Ogni giorno alle @time',
    'connection_heartbeat_report_time':
        "L'orario di segnalazione del benessere è ",
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
    'heartbeat_schedule_change': 'Modifica orario di controllo',
    'heartbeat_schedule_title_ios': 'Orario di controllo',
    'heartbeat_schedule_change_title_ios': 'Modifica orario di controllo',
    'heartbeat_schedule_hint_ios':
        'Una notifica push di benessere arriva ogni giorno a quest\'ora. Tocca la notifica o apri l\'app in quel momento per inviare il tuo segnale di benessere.',
    'heartbeat_daily_time': 'Ogni giorno alle @time',
    'heartbeat_scheduled_today':
        'Il tuo segnale di benessere sarà inviato ai tuoi guardiani ogni giorno alle @time.',
    'heartbeat_change_failed_title': "Modifica dell'orario non riuscita",
    'heartbeat_change_failed_message': 'Impossibile aggiornare sul server.',
    'heartbeat_picker_help': 'Scegli un orario prima delle @limit',
    'heartbeat_range_limit_title': 'Orario non disponibile',
    'heartbeat_range_limit_message':
        'Il controllo di benessere deve essere impostato prima delle @limit.',

    // ── Notifiche locali ──
    'local_notification_channel_desc':
        'Notifiche del servizio di verifica del benessere',

    // ── Varie ──
    'back_press_exit': 'Prema di nuovo indietro per uscire.',

    // ── Errori API ──
    'error_unknown': 'Si è verificato un errore sconosciuto.',
    'error_timeout': 'La richiesta è scaduta.',
    'error_network': 'Verifichi la connessione di rete.',
    'error_unauthorized': 'Autenticazione necessaria.',

    // ── Corpo delle notifiche ──
    'noti_auto_report_body':
        'La verifica di benessere è stata ricevuta con successo.',
    'noti_manual_report_body':
        "L'assistito ha inviato manualmente una verifica di benessere.",
    'noti_battery_low_body':
        'La batteria del telefono è inferiore al 20 %. Potrebbe essere necessario ricaricare.',
    'noti_battery_dead_body':
        'Il telefono sembra essersi spento per batteria scarica. Ultimo livello batteria: @battery_level %. Si ripristinerà dopo la ricarica.',
    'noti_caution_suspicious_body':
        'È stato ricevuto un segnale di benessere, ma oggi non è stato rilevato alcun registro di attività. Verifichi di persona.',
    'noti_caution_missing_body':
        'La verifica di benessere prevista per oggi non è ancora arrivata. Verifichi di persona.',
    'noti_warning_body':
        'Le verifiche di benessere sono state mancate consecutivamente. È necessaria una verifica di persona.',
    'noti_warning_suspicious_body':
        'Nessun registro di attività rilevato consecutivamente. È necessaria una verifica di persona.',
    'noti_urgent_body':
        'Nessuna verifica di benessere da @days giorno/i. È necessaria una verifica immediata.',
    'noti_urgent_suspicious_body':
        'Nessun registro di attività da @days giorno/i. È necessaria una verifica immediata.',
    'noti_steps_body': '@steps passi percorsi oggi.',
    'noti_emergency_body':
        "L'assistito ha richiesto direttamente aiuto. Verifichi immediatamente.",
    'noti_resolved_body':
        'Il controllo benessere dell\'assistito è tornato nella norma.',
    'noti_cleared_by_guardian_title': '✅ Verifica confermata',
    'noti_cleared_by_guardian_body':
        'Uno dei guardiani ha confermato personalmente la sicurezza.',

    // ── Notifiche locali ──
    'local_alarm_title': '💗 Verifica di benessere necessaria',
    'local_alarm_body': 'Per favore, tocca questa notifica.',
    // ── iOS 확장 전송 결과 / 오프라인 폴백 ──
    'nse_delivered_title': '✅ Segnale di benessere inviato',
    'nse_delivered_body': 'Il segnale di benessere di oggi è stato inviato al tuo referente.',
    'offline_alarm_title': '💗 Il segnale di oggi non è ancora stato inviato',
    'offline_alarm_body': 'Tocca questa notifica una volta.\nIl tuo segnale verrà inviato al tuo referente.',
    'wellbeing_check_title': '💛 Verifica di benessere',
    'wellbeing_check_body': 'Come sta? Per favore, tocca questa notifica.',
    'noti_channel_name': 'Avvisi Anbu',
    'notification_send_failed_title':
        '📶 Controlli la Sua connessione Internet',
    'notification_send_failed_body':
        'Tocca questo messaggio per reinviare automaticamente.',
  };
}
