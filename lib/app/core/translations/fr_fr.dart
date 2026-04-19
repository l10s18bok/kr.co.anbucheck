abstract class FrFr {
  static const Map<String, String> translations = {
    // ── Commun ──
    'common_confirm': 'Confirmer',
    'common_cancel': 'Annuler',
    'common_continue': 'Continuer',
    'common_save': 'Enregistrer',
    'common_delete': 'Supprimer',
    'common_close': 'Fermer',
    'common_next': 'Suivant',
    'common_previous': 'Précédent',
    'common_start': 'Commencer',
    'common_skip': 'Passer',
    'common_later': 'Plus tard',
    'common_loading': 'Chargement...',
    'common_error': 'Erreur',
    'common_complete': 'Terminé',
    'common_notice': 'Information',
    'common_unlink': 'Dissocier',
    'common_am': 'AM',
    'common_pm': 'PM',
    'common_normal': 'Normal',
    'common_connected': 'Connecté',
    'common_disconnected': 'Déconnecté',

    // ── Marque ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Nous veillons sur votre bien-être.',
    'app_service_desc': 'Service automatique de suivi du bien-être',
    'app_guardian_title': 'Protecteur Anbu',
    'app_copyright': '© 2026 Averic SB Inc.',

    // ── Splash ──
    'splash_loading': 'Vérification du bien-être...',

    // ── Mise à jour ──
    'update_required_title': 'Mise à jour requise',
    'update_required_message':
        'Veuillez mettre à jour vers la version @version pour continuer à utiliser l\'application.',
    'update_button': 'Mettre à jour',
    'update_available_title': 'Mise à jour disponible',
    'update_available_message': 'La version @version est disponible.',

    // ── Choix du mode ──
    'mode_select_title': 'Choisissez votre rôle',
    'mode_select_subtitle':
        'Ce choix nous permet de configurer les fonctionnalités adaptées à votre situation',
    'mode_subject_title': 'Je souhaite que l\'on\nveille sur moi',
    'mode_subject_button': 'Être protégé(e) →',
    'mode_guardian_title': 'Je souhaite veiller\nsur un proche',
    'mode_guardian_button': 'Devenir protecteur →',
    'mode_select_notice': 'L\'interface et les notifications seront adaptées selon votre choix',

    // ── Autorisations ──
    'permission_title': 'Des autorisations sont\nnécessaires',
    'permission_notification': 'Notifications',
    'permission_notification_subject_desc': 'Nécessaire pour recevoir les alertes de bien-être',
    'permission_notification_guardian_desc':
        'Nécessaire pour recevoir les alertes sur la sécurité de vos proches',
    'permission_activity': 'Reconnaissance d\'activité',
    'permission_activity_desc': 'Utilisée pour détecter les pas et confirmer l\'activité',
    'permission_activity_dialog_title': 'À propos de l\'autorisation d\'activité',
    'permission_activity_dialog_message':
        'Utilisée pour détecter les pas et confirmer l\'activité.\nVeuillez appuyer sur « Autoriser » à l\'écran suivant.',
    'permission_notification_required_title': 'Autorisation de notification requise',
    'permission_notification_required_message':
        'L\'autorisation de notification est nécessaire pour le service de bien-être.\nVeuillez l\'activer dans les Réglages.',
    'permission_go_to_settings': 'Ouvrir les Réglages',
    'permission_activity_denied_title': 'Autorisation d\'activité physique requise',
    'permission_activity_denied_message':
        'Utilisée pour détecter les pas et améliorer la précision de la vérification du bien-être.\nVeuillez activer l\'autorisation d\'activité physique dans les Réglages.',
    'permission_battery': 'Exclusion de l\'optimisation de la batterie',
    'permission_battery_desc':
        'Exclut l\'application de l\'optimisation de la batterie afin que les vérifications quotidiennes de bien-être ne soient pas manquées',
    'permission_battery_required_title': 'Veuillez définir la batterie sur "Sans restriction"',
    'permission_battery_required_message':
        'Si elle est définie sur "Optimisation de la batterie" ou "Économiseur de batterie", les vérifications quotidiennes de bien-être peuvent être retardées ou manquées.\n\nAprès avoir appuyé sur [Ouvrir les Réglages] :\n1. Sélectionnez "Batterie"\n2. Changez sur "Sans restriction"',
    'permission_battery_go_to_settings': 'Ouvrir les Réglages',
    'permission_hibernation_title': 'Veuillez désactiver "Suspendre l\'activité si inutilisée"',
    'permission_hibernation_highlight': 'Suspendre l\'activité si inutilisée',
    'permission_hibernation_message':
        'Si vous n\'ouvrez pas l\'application pendant plusieurs mois, Android peut l\'arrêter automatiquement et interrompre les vérifications de bien-être.\n\nAppuyez sur [Ouvrir les paramètres de l\'application], puis désactivez "Suspendre l\'activité si inutilisée".',
    'permission_hibernation_go_to_settings': 'Ouvrir les paramètres de l\'application',

    // ── Présentation ──
    'onboarding_title_1': 'Vous vous inquiétez pour\nquelqu\'un qui vit seul ?',
    'onboarding_desc_1': 'Même à distance,\non se demande si tout va bien.\nAnbu est là pour vous.',
    'onboarding_title_2': 'Le bien-être se transmet\nsans un mot',
    'onboarding_desc_2':
        'Rien qu\'en utilisant son smartphone,\nun signal quotidien de bien-être\nest envoyé automatiquement.',
    'onboarding_title_3': 'Partagez le bien-être\navec vos proches',
    'onboarding_desc_3':
        'Les vérifications quotidiennes\ncréent une tranquillité d\'esprit durable.\nCommencez dès maintenant.',
    'onboarding_title_4': 'Ni nom, ni numéro de téléphone\n— rien n\'est collecté',
    'onboarding_desc_4':
        'Un seul signal est transmis :\n« Je vais bien. »\nVos données restent en sécurité.',
    'onboarding_role_subject': 'Personne protégée',
    'onboarding_role_guardian': 'Protecteur',
    'onboarding_role_guardian_subject': 'Gardien et protégé',
    'onboarding_already_registered_title': 'Appareil déjà enregistré',
    'onboarding_already_registered_message':
        'Cet appareil est déjà enregistré en mode "@roleLabel".\nSouhaitez-vous continuer en "@roleLabel" ?\n\nOu passer en mode "@newRoleLabel" ?\nLe changement supprimera toutes les données existantes.',
    'onboarding_already_registered_message_gs':
        'Cet appareil est déjà enregistré en mode « @roleLabel ».\nPasser en mode « @newRoleLabel » supprimera toutes les données de gardien et de protégé.',
    'onboarding_registration_failed_title': 'Échec de l\'inscription',
    'onboarding_registration_failed_message':
        'Impossible de se connecter au serveur. Veuillez réessayer plus tard.',

    // ── Accueil (Personne protégée) ──
    'subject_home_share_title': 'Partagez votre code de sécurité',
    'subject_home_guardian_count': 'Protecteurs connectés : @count',
    'subject_home_check_title_last': 'Dernière vérification',
    'subject_home_check_title_scheduled': 'Prochaine vérification prévue',
    'subject_home_check_title_checking': 'Vérification en cours',
    'subject_home_check_body_reported': 'Signalé à @time',
    'subject_home_check_body_scheduled': 'Prévu à @time',
    'subject_home_check_body_waiting': 'En attente depuis @time',
    'subject_home_battery_status': 'Niveau de batterie',
    'subject_home_battery_charging': 'En charge',
    'subject_home_battery_full': 'Pleine',
    'subject_home_battery_low': 'Batterie faible',
    'subject_home_connectivity_status': 'État de la connexion',
    'subject_home_report_loading': 'Envoi en cours...',
    'subject_home_report_button': 'Signaler mon bien-être maintenant',
    'subject_home_report_desc': 'Rassurez votre protecteur en lui montrant que vous allez bien',
    'subject_home_emergency_button': "J'ai besoin d'aide",
    'subject_home_emergency_desc': "Envoie une alerte d'urgence à vos protecteurs",
    'subject_home_emergency_loading': "Envoi de l'alerte d'urgence...",
    'subject_home_emergency_sent': "L'alerte d'urgence a été envoyée",
    'subject_home_emergency_failed': "Échec de l'envoi de l'alerte d'urgence",
    'subject_home_manual_report_limit_reached': "Vous avez déjà envoyé le rapport de sécurité d'aujourd'hui. Veuillez réessayer demain.",
    'subject_home_emergency_confirm_title': "Demande d'aide d'urgence",
    'subject_home_emergency_confirm_body':
        "Une alerte d'urgence sera envoyée à tous les gardiens.\nVotre position actuelle sera également partagée.\nVoulez-vous vraiment demander de l'aide ?",
    'emergency_sent_with_location': "Alerte d'urgence envoyée (avec position)",
    'emergency_sent_without_location': "Alerte d'urgence envoyée",
    'notifications_view_location': '🗺️ Voir la position',
    'emergency_map_title': "Position d'urgence",
    'emergency_map_subject_label': 'Personne surveillée',
    'emergency_map_captured_at_label': 'Horodatage',
    'emergency_map_accuracy_label': 'Précision',
    'emergency_map_open_external': "Ouvrir dans l'application de cartes externe",
    'emergency_map_no_location': 'Aucune information de position',
    'emergency_location_permission_denied_snackbar': "Alerte d'urgence envoyée sans autorisation de localisation",
    'subject_home_emergency_confirm_send': "Envoyer la demande d'urgence",
    'subject_home_share_text':
        'Veillez sur moi avec l\'application Anbu !\nCode d\'invitation : @code',
    'subject_home_share_subject': 'Code d\'invitation Anbu',
    'subject_home_code_copied': 'Code copié',

    // ── Menu latéral (Personne protégée) ──
    'drawer_light_mode': 'Mode clair',
    'drawer_dark_mode': 'Mode sombre',
    'drawer_privacy_policy': 'Politique de confidentialité',
    'drawer_terms': 'Conditions d\'utilisation',
    'drawer_withdraw': 'Supprimer le compte',
    'drawer_withdraw_message':
        'Votre compte et toutes vos données seront supprimés.\nÊtes-vous sûr(e) ?',

    // ── Tableau de bord (Protecteur) ──
    'guardian_status_normal': 'Normal',
    'guardian_status_caution': 'Attention',
    'guardian_status_warning': 'Alerte',
    'guardian_status_urgent': 'Urgent',
    'guardian_status_confirmed': 'Sécurité confirmée',
    'guardian_subscription_expired': 'Abonnement expiré',
    'guardian_subscription_expired_message':
        'Les alertes ne sont plus envoyées.\nRenouvelez votre abonnement pour maintenir la protection.',
    'guardian_subscribe': 'S\'abonner',
    'guardian_payment_preparing': 'La fonctionnalité de paiement sera bientôt disponible.',
    'guardian_today_summary': 'Résumé du jour',
    'guardian_no_subjects': 'Aucune personne protégée connectée.',
    'guardian_checking_subjects': 'Suivi en cours pour\n@count personne(s).',
    'guardian_subject_list': 'Liste des personnes protégées',
    'guardian_call_now': 'Appeler maintenant',
    'guardian_confirm_safety': 'Confirmer la sécurité',
    'guardian_no_check_history': 'Aucun historique',
    'guardian_last_check_now': 'Dernière vérif. : à l\'instant',
    'guardian_last_check_minutes': 'Dernière vérif. : il y a @minutes min',
    'guardian_last_check_hours': 'Dernière vérif. : il y a @hours h',
    'guardian_last_check_days': 'Dernière vérif. : il y a @days jour(s)',
    'guardian_activity_stable': 'Activité : stable',
    'guardian_activity_very_active': 'Très actif',
    'guardian_activity_active': 'Actif',
    'guardian_activity_needs_exercise': "Besoin d'exercice",
    'guardian_activity_collecting': 'Collecte en cours',
    'guardian_error_load_step_history': "Échec du chargement de l'historique des pas",
    'guardian_chart_y_axis_steps': 'Pas',
    'guardian_chart_x_axis_last_7_days': '7 derniers jours',
    'guardian_chart_x_axis_last_30_days': '30 derniers jours',
    'guardian_chart_today': 'Today',
    'guardian_safety_needed': 'Vérification de sécurité nécessaire',
    'guardian_error_load_subjects': 'Impossible de charger la liste des personnes protégées.',
    'guardian_error_clear_alerts': 'Impossible de lever les alertes.',

    // ── Ajouter une personne protégée ──
    'add_subject_title': 'Associer une personne protégée',
    'add_subject_guide_title': 'Saisissez le code unique et un surnom.',
    'add_subject_guide_subtitle':
        'Associez l\'application d\'un proche pour suivre son état en temps réel.',
    'add_subject_code_label': 'Code unique (7 caractères)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info':
        'Le code unique se trouve dans l\'application de la personne protégée.',
    'add_subject_alias_label': 'Surnom',
    'add_subject_alias_hint': 'ex. : Maman, Papa',
    'add_subject_connect': 'Associer',
    'add_subject_error_login': 'Connexion requise.',
    'add_subject_success': 'Personne protégée associée avec succès.',
    'add_subject_error_invalid_code': 'Code non valide.',
    'add_subject_error_already_connected': 'Déjà associé(e).',
    'add_subject_error_failed': 'Échec de l\'association. Veuillez réessayer.',
    'add_subject_button': 'Ajouter une personne protégée',

    // ── Paramètres (Protecteur) ──
    'settings_title': 'Paramètres',
    'settings_light_mode': 'Mode clair',
    'settings_dark_mode': 'Mode sombre',
    'settings_connection_management': 'Gestion des connexions',
    'settings_managed_subjects': 'Personnes protégées suivies',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'Abonnement & service',
    'settings_current_membership': 'Abonnement actuel',
    'settings_premium': 'Premium actif',
    'settings_free_trial': 'Essai gratuit',
    'settings_days_remaining': '@days jours restants',
    'settings_manage_subscription': 'Gérer l\'abonnement',
    'settings_notification': 'Paramètres de notification',
    'settings_terms_section': 'Mentions légales',
    'settings_privacy_policy': 'Politique de confidentialité',
    'settings_terms': 'Conditions d\'utilisation',
    'settings_app_version': 'Version : v@version',

    // ── G+S (Gardien et protégé) ──
    'gs_enable_button': 'Recevoir aussi la protection',
    'gs_safety_code_button': 'Vérifier mon code de sécurité',
    'gs_safety_code_title': 'Mon code de sécurité',
    'gs_enable_dialog_title': 'Activer la protection',
    'gs_enable_dialog_body':
        'Vous pouvez recevoir une protection tout en gardant vos fonctions de gardien.\nUn code de sécurité sera émis — veuillez le partager avec d\'autres gardiens.',
    'gs_enable_dialog_ios_warning_title': '⚠ iOS fonctionne différemment d\'Android',
    'gs_enable_dialog_ios_warning_body':
        'Sur iOS, une « notification push de bien-être » apparaît chaque jour à l\'heure programmée. Vous devez appuyer sur la notification ou ouvrir l\'application vous-même à ce moment-là pour que votre signal de bien-être soit envoyé. Si vous n\'ouvrez pas l\'application, vos gardiens peuvent recevoir une alerte de vérification manquée.',
    'gs_enable_dialog_ios_confirm': 'Compris, activer',
    'gs_enable_confirm': 'Activer',
    'gs_enabled_message': 'La protection a été activée',
    'gs_enable_failed': 'Échec de l\'activation de la protection',
    'gs_disable_dialog_title': 'Désactiver la protection',
    'gs_disable_dialog_body':
        'La désactivation supprimera votre code de sécurité et arrêtera l\'envoi des vérifications aux gardiens connectés.',
    'gs_disable_confirm': 'Désactiver',
    'gs_disabled_message': 'La protection a été désactivée',
    'gs_disable_failed': 'Échec de la désactivation de la protection',
    'gs_activity_permission_denied_warning': 'L\'autorisation de compteur de pas est refusée. Appuyez ici pour autoriser.',
    'gs_activity_permission_settings_title': 'Autorisation requise',
    'gs_activity_permission_settings_body': 'Veuillez autoriser l\'autorisation Activité physique (Mouvement et Forme) dans les paramètres de l\'application.',
    'gs_activity_permission_settings_go': 'Aller aux paramètres',

    // ── Notifications (Protecteur) ──
    'notifications_title': 'Notifications',
    'notifications_today': 'Notifications du jour',
    'notifications_empty': 'Aucune notification aujourd\'hui',
    'notifications_delete_all_title': 'Supprimer toutes les notifications',
    'notifications_delete_all_message': 'Supprimer toutes les notifications du jour ?',
    'notifications_delete_failed': 'Impossible de supprimer les notifications.',
    'notifications_guide_title': 'Guide des niveaux de notification',
    'notifications_level_health': 'Normal',
    'notifications_level_health_desc': 'Le bien-être de la personne protégée a été confirmé',
    'notifications_level_caution': 'Attention',
    'notifications_level_caution_desc': 'Aucun signal de bien-être ni activité du téléphone détectés',
    'notifications_level_warning': 'Alerte',
    'notifications_level_warning_desc': 'Aucun signal de bien-être ni activité du téléphone depuis plusieurs jours',
    'notifications_level_urgent': 'Urgent',
    'notifications_level_urgent_desc': 'Vérification immédiate requise',
    'notifications_level_info': 'Info',
    'notifications_level_info_desc': 'Pas, batterie faible et autres informations',
    'notifications_activity_note':
        '※ Les données d\'activité peuvent ne pas s\'afficher si le nombre de pas n\'a pas pu être relevé.',

    // ── Paramètres de notification (Protecteur) ──
    'notification_settings_title': 'Paramètres de notification',
    'notification_settings_push': 'Notifications push',
    'notification_settings_all': 'Toutes les notifications',
    'notification_settings_all_desc':
        'Activer ou désactiver toutes les catégories de notification en une fois.',
    'notification_settings_level_section': 'Réglages par niveau',
    'notification_settings_urgent': 'Alertes urgentes',
    'notification_settings_urgent_desc': 'Les alertes urgentes ne peuvent pas être désactivées',
    'notification_settings_warning': 'Alertes d\'alerte',
    'notification_settings_warning_desc': 'Alerte après 2 jours consécutifs sans vérification',
    'notification_settings_caution': 'Alertes d\'attention',
    'notification_settings_caution_desc': 'Alerte en cas de vérification manquante aujourd\'hui',
    'notification_settings_info': 'Alertes d\'information',
    'notification_settings_info_desc':
        'Alertes générales comme le nombre de pas et le niveau de batterie',
    'notification_settings_dnd': 'Ne pas déranger',
    'notification_settings_dnd_start': 'Heure de début',
    'notification_settings_dnd_end': 'Heure de fin',
    'notification_settings_dnd_note':
        '※ Les alertes urgentes sont transmises même en mode « Ne pas déranger »',
    'notification_settings_dnd_start_default': '22:00',
    'notification_settings_dnd_end_default': '07:00',

    // ── Gestion des connexions ──
    'connection_title': 'Gestion des connexions',
    'connection_managed_count': 'Personnes protégées suivies ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Personnes protégées connectées',
    'connection_empty': 'Aucune personne protégée connectée',
    'connection_unlink_warning': 'La dissociation supprimera les données de cette personne.',
    'connection_unlink_warning_detail':
        'Les données précédentes ne pourront pas être récupérées après une nouvelle association. Vous devrez saisir à nouveau le code de la personne.',
    'connection_heartbeat_schedule': 'Tous les jours à @time',
    'connection_heartbeat_report_time': 'L\'heure du rapport est ',
    'connection_subject_label': 'Personne protégée',
    'connection_change_only_in_app': 'modifiable uniquement dans l\'application',
    'connection_edit_title': 'Modifier la personne protégée',
    'connection_alias_label': 'Surnom',
    'connection_unlink_title': 'Dissocier',
    'connection_unlink_confirm': 'Dissocier @alias ?',
    'connection_unlink_success': 'Dissociation réussie.',
    'connection_unlink_failed': 'Échec de la dissociation.',
    'connection_load_failed': 'Impossible de charger la liste.',

    // ── Navigation inférieure ──
    'nav_home': 'Accueil',
    'nav_connection': 'Connexion',
    'nav_notification': 'Alertes',
    'nav_settings': 'Paramètres',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'Modifier l\'heure de vérification',
    'heartbeat_schedule_title_ios': 'Heure de notification push de bien-être',
    'heartbeat_schedule_change_title_ios': 'Modifier l\'heure de notification push de bien-être',
    'heartbeat_schedule_hint_ios':
        'Une notification push de bien-être arrive chaque jour à cette heure. Appuyez sur la notification ou ouvrez l\'application à ce moment-là pour envoyer votre signal de bien-être.',
    'heartbeat_daily_time': 'Tous les jours à @time',
    'heartbeat_scheduled_today': 'Vérification du bien-être prévue aujourd\'hui à @time.',
    'heartbeat_change_failed_title': 'Échec du changement d\'heure',
    'heartbeat_change_failed_message':
        'La modification n\'a pas pu être enregistrée sur le serveur.',

    // ── Notifications locales ──
    'local_notification_channel': 'Alertes de bien-être',
    'local_notification_channel_desc': 'Notifications du service de bien-être',

    // ── Divers ──
    'back_press_exit': 'Appuyez à nouveau pour quitter l\'application.',

    // ── Erreurs API ──
    'error_unknown': 'Une erreur inconnue est survenue.',
    'error_timeout': 'La requête a expiré.',
    'error_network': 'Veuillez vérifier votre connexion internet.',
    'error_unauthorized': 'Authentification requise.',

    // ── Corps des notifications ──
    'noti_auto_report_body': 'La vérification de bien-être programmée a été reçue aujourd\'hui.',
    'noti_manual_report_body':
        'La personne protégée a envoyé manuellement une vérification de bien-être.',
    'noti_battery_low_body':
        'La batterie du téléphone est inférieure à 20 %. Une recharge peut être nécessaire.',
    'noti_battery_dead_body':
        'Le téléphone semble s\'être éteint à cause d\'une batterie déchargée. Dernier niveau de batterie : @battery_level %. Il se rétablira après la recharge.',
    'noti_caution_suspicious_body':
        'Un signal de bien-être a été reçu, mais aucun signe d\'utilisation du téléphone n\'a été détecté. Veuillez vérifier en personne.',
    'noti_caution_missing_body':
        'La vérification de bien-être prévue aujourd\'hui n\'a pas encore été reçue. Veuillez vérifier en personne.',
    'noti_warning_body':
        'Les vérifications de bien-être ont été manquées consécutivement. Veuillez vérifier en personne.',
    'noti_warning_suspicious_body':
        'Aucune utilisation du téléphone détectée de façon consécutive. Veuillez vérifier en personne.',
    'noti_urgent_body':
        'Aucune vérification de bien-être depuis @days jour(s). Une vérification immédiate est requise.',
    'noti_urgent_suspicious_body':
        'Aucune utilisation du téléphone détectée depuis @days jour(s). Une vérification immédiate est requise.',
    'noti_steps_body': "@steps pas effectués aujourd'hui.",
    'noti_emergency_body':
        "La personne protégée a directement demandé de l'aide. Veuillez vérifier immédiatement.",
    'noti_resolved_body': 'Le bilan de santé du protégé est revenu à la normale.',
    'noti_cleared_by_guardian_title': '✅ Vérification confirmée',
    'noti_cleared_by_guardian_body': "Un des protecteurs a personnellement confirmé la sécurité.",

    // ── Notifications locales ──
    'local_alarm_title': '💗 Vérification de bien-être nécessaire',
    'local_alarm_body': 'Veuillez appuyer sur cette notification.',
    'wellbeing_check_title': '💛 Vérification de bien-être',
    'wellbeing_check_body': 'Comment allez-vous ? Veuillez appuyer sur cette notification.',
    'noti_channel_name': 'Alertes Anbu',
  };
}
