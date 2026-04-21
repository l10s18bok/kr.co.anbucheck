abstract class EsEs {
  static const Map<String, String> translations = {
    // ── General ──
    'common_confirm': 'Confirmar',
    'common_cancel': 'Cancelar',
    'common_continue': 'Continuar',
    'common_save': 'Guardar',
    'common_delete': 'Eliminar',
    'common_close': 'Cerrar',
    'common_next': 'Siguiente',
    'common_previous': 'Anterior',
    'common_start': 'Comenzar',
    'common_skip': 'Omitir',
    'common_later': 'Más tarde',
    'common_loading': 'Cargando...',
    'common_error': 'Error',
    'common_complete': 'Listo',
    'common_notice': 'Aviso',
    'common_unlink': 'Desvincular',
    'common_am': 'AM',
    'common_pm': 'PM',
    'common_normal': 'Normal',
    'common_connected': 'Conectado',
    'common_disconnected': 'Sin conexión',

    // ── Marca ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Velamos por su bienestar.',
    'app_service_desc': 'Servicio automático de verificación de bienestar',
    'app_guardian_title': 'Protector Anbu',
    'app_copyright': '© 2026 Averic SB Inc.',

    // ── Splash ──
    'splash_loading': 'Verificando bienestar...',

    // ── Actualización ──
    'update_required_title': 'Actualización necesaria',
    'update_required_message': 'Actualice a la versión @version para seguir usando la aplicación.',
    'update_button': 'Actualizar',
    'update_available_title': 'Actualización disponible',
    'update_available_message': 'La versión @version está disponible.',

    // ── Selección de modo ──
    'mode_select_title': 'Elija su función',
    'mode_select_subtitle':
        'Esta elección nos ayuda a configurar las funciones adecuadas para usted',
    'mode_subject_title': 'Quiero que alguien\nvele por mi seguridad',
    'mode_subject_button': 'Recibir protección →',
    'mode_guardian_title': 'Quiero cuidar\nde un ser querido',
    'mode_guardian_button': 'Ser protector →',
    'mode_select_notice': 'La interfaz y las notificaciones serán diferentes según su elección',

    // ── Permisos ──
    'permission_title': 'Se necesitan permisos\npara usar la aplicación',
    'permission_notification': 'Notificaciones',
    'permission_notification_subject_desc': 'Necesario para recibir alertas de bienestar',
    'permission_notification_guardian_desc':
        'Necesario para recibir alertas sobre la seguridad de sus protegidos',
    'permission_activity': 'Reconocimiento de actividad',
    'permission_activity_desc': 'Se utiliza para detectar pasos y confirmar la actividad',
    'permission_location': 'Ubicación',
    'permission_location_desc': 'Se comparte con los protectores solo al enviar una solicitud de emergencia',
    'location_permission_warning':
        'No se enviará la ubicación en las solicitudes de emergencia. Toca para permitir.',
    'location_permission_settings_title': 'Permiso de ubicación requerido',
    'location_permission_settings_body_ios':
        "Busca y selecciona 'Anbu', luego en 'Ubicación' elige 'Al usar la app'.",
    'location_permission_settings_body_android':
        "Selecciona 'Permisos' → 'Ubicación', luego elige 'Permitir solo mientras uso la app'.",
    'permission_activity_dialog_title': 'Información sobre el permiso de actividad',
    'permission_activity_dialog_message':
        'Se utiliza para detectar pasos y confirmar la actividad.\nPulse "Permitir" en la siguiente pantalla.',
    'permission_notification_required_title': 'Permiso de notificaciones necesario',
    'permission_notification_required_message':
        'Se necesita el permiso de notificaciones para el servicio de bienestar.\nActívelo en Ajustes.',
    'permission_go_to_settings': 'Ir a Ajustes',
    'permission_activity_denied_title': 'Se requiere permiso de actividad física',
    'permission_activity_denied_message':
        'Se utiliza para detectar pasos y mejorar la precisión de la verificación de bienestar.\nActive el permiso de actividad física en Ajustes.',
    'permission_battery': 'Exclusión de optimización de batería',
    'permission_battery_desc':
        'Excluye la aplicación de la optimización de batería para que las verificaciones diarias de bienestar no se pierdan',
    'permission_battery_required_title': 'Configure la batería como "Sin restricciones"',
    'permission_battery_required_message':
        'Si está configurada como "Optimización de batería" o "Ahorro de batería", las verificaciones diarias de bienestar pueden retrasarse o perderse.\n\nDespués de tocar [Ir a Ajustes]:\n1. Seleccione "Batería"\n2. Cambie a "Sin restricciones"',
    'permission_battery_go_to_settings': 'Ir a Ajustes',
    'permission_hibernation_title': 'Desactive "Pausar actividad si no se usa"',
    'permission_hibernation_highlight': 'Pausar actividad si no se usa',
    'permission_hibernation_message':
        'Si no abre la aplicación durante varios meses, Android puede detenerla automáticamente e interrumpir las verificaciones de bienestar.\n\nToque [Abrir ajustes de la app] y desactive "Pausar actividad si no se usa".',
    'permission_hibernation_go_to_settings': 'Abrir ajustes de la app',

    // ── Presentación ──
    'onboarding_title_1': '¿Le preocupa alguien\nque vive solo?',
    'onboarding_desc_1':
        'Aunque esté lejos,\nuno se pregunta si todo va bien.\nAnbu está aquí para usted.',
    'onboarding_title_2': 'El bienestar se comparte\nsin decir una palabra',
    'onboarding_desc_2':
        'Con solo usar el teléfono,\nse envía automáticamente\nuna señal diaria de bienestar.',
    'onboarding_title_3': 'Comparta el bienestar\ncon sus seres queridos',
    'onboarding_desc_3':
        'Las verificaciones diarias generan\ntranquilidad duradera.\nComience ahora.',
    'onboarding_title_4': 'Sin nombres ni números\nde teléfono — no se recopila nada',
    'onboarding_desc_4': 'Solo se transmite una señal:\n«Estoy bien».\nSu información está segura.',
    'onboarding_role_subject': 'Persona protegida',
    'onboarding_role_guardian': 'Protector',
    'onboarding_role_guardian_subject': 'Guardián y protegido',
    'onboarding_already_registered_title': 'Dispositivo ya registrado',
    'onboarding_already_registered_message':
        'Este dispositivo ya está registrado en modo "@roleLabel".\n¿Desea continuar como "@roleLabel"?\n\n¿O cambiar al modo "@newRoleLabel"?\nAl cambiar se eliminarán todos los datos existentes.',
    'onboarding_already_registered_message_gs':
        'Este dispositivo ya está registrado en modo "@roleLabel".\nCambiar a modo "@newRoleLabel" eliminará todos los datos de guardián y protegido.',
    'onboarding_registration_failed_title': 'Error de registro',
    'onboarding_registration_failed_message':
        'No se pudo conectar con el servidor. Inténtelo de nuevo más tarde.',

    // ── Inicio (Persona protegida) ──
    'subject_home_share_title': 'Comparta su código de seguridad',
    'subject_home_guardian_count': 'Protectores conectados: @count',
    'subject_home_check_title_last': 'Última verificación',
    'subject_home_check_title_scheduled': 'Próxima verificación prevista',
    'subject_home_check_title_checking': 'Verificando bienestar',
    'subject_home_check_body_reported': 'Reportado a las @time',
    'subject_home_check_body_scheduled': 'Previsto a las @time',
    'subject_home_check_body_waiting': 'En espera desde las @time',
    'subject_home_battery_status': 'Nivel de batería',
    'subject_home_battery_charging': 'Cargando',
    'subject_home_battery_full': 'Completa',
    'subject_home_battery_low': 'Batería baja',
    'subject_home_connectivity_status': 'Estado de conexión',
    'subject_home_report_loading': 'Enviando reporte...',
    'subject_home_report_button': 'Reportar bienestar ahora',
    'subject_home_report_desc': 'Haga saber a su protector que se encuentra bien',
    'subject_home_emergency_button': 'Necesito ayuda',
    'subject_home_emergency_desc': 'Envía una alerta de emergencia a sus guardianes',
    'subject_home_emergency_loading': 'Enviando alerta de emergencia...',
    'subject_home_emergency_sent': 'La alerta de emergencia ha sido enviada',
    'subject_home_emergency_failed': 'Error al enviar la alerta de emergencia',
    'subject_home_manual_report_limit_reached': 'Ya has enviado el informe de seguridad de hoy. Por favor, inténtalo de nuevo mañana.',
    'subject_home_manual_report_sent': 'Tu mensaje ha sido enviado a tus contactos.',
    'subject_home_emergency_confirm_title': 'Solicitud de ayuda de emergencia',
    'subject_home_emergency_confirm_body':
        'Se enviará una alerta de emergencia a todos los cuidadores.\nTambién se compartirá tu ubicación actual.\n¿Realmente quieres solicitar ayuda?',
    'emergency_sent_with_location': 'Alerta de emergencia enviada (con ubicación)',
    'emergency_sent_without_location': 'Alerta de emergencia enviada',
    'notifications_view_location': '🗺️ Ver ubicación',
    'emergency_map_title': 'Ubicación de emergencia',
    'emergency_map_subject_label': 'Persona protegida',
    'emergency_map_captured_at_label': 'Hora de captura',
    'emergency_map_accuracy_label': 'Precisión',
    'emergency_map_open_external': 'Abrir en la aplicación de mapas externa',
    'emergency_map_no_location': 'No hay información de ubicación',
    'emergency_location_permission_denied_snackbar': 'Alerta de emergencia enviada sin permiso de ubicación',
    'subject_home_emergency_confirm_send': 'Enviar solicitud de emergencia',
    'subject_home_share_text': '¡Cuide de mí con la aplicación Anbu!\nCódigo de invitación: @code',
    'subject_home_share_subject': 'Código de invitación Anbu',
    'subject_home_code_copied': 'Código copiado',

    // ── Menú lateral (Persona protegida) ──
    'drawer_light_mode': 'Modo claro',
    'drawer_dark_mode': 'Modo oscuro',
    'drawer_privacy_policy': 'Política de privacidad',
    'drawer_terms': 'Términos de uso',
    'drawer_withdraw': 'Eliminar cuenta',
    'drawer_withdraw_message': 'Su cuenta y todos sus datos serán eliminados.\n¿Está seguro/a?',

    // ── Panel del protector ──
    'guardian_status_normal': 'Seguro',
    'guardian_status_caution': 'Precaución',
    'guardian_status_warning': 'Alerta',
    'guardian_status_urgent': 'Urgente',
    'guardian_status_confirmed': '✅ Seguro',
    'guardian_subscription_expired': 'Suscripción vencida',
    'guardian_subscription_expired_message':
        'Las alertas ya no se están enviando.\nRenueve su suscripción para mantener la protección.',
    'guardian_subscribe': 'Suscribirse',
    'guardian_payment_preparing': 'La función de pago estará disponible próximamente.',
    'guardian_today_summary': 'Resumen del día',
    'guardian_no_subjects': 'No hay personas protegidas conectadas.',
    'guardian_checking_subjects': 'Actualmente se vigila el bienestar\nde @count persona(s).',
    'guardian_subject_list': 'Lista de personas protegidas',
    'guardian_call_now': 'Llamar ahora',
    'guardian_confirm_safety': 'Confirmar seguridad',
    'guardian_no_check_history': 'Sin historial',
    'guardian_last_check_now': 'Última verif.: hace un momento',
    'guardian_last_check_minutes': 'Última verif.: hace @minutes min',
    'guardian_last_check_hours': 'Última verif.: hace @hours h',
    'guardian_last_check_days': 'Última verif.: hace @days día(s)',
    'guardian_activity_stable': 'Actividad: estable',
    'guardian_activity_prefix': 'Actividad',
    'guardian_activity_very_active': 'Muy activo',
    'guardian_activity_active': 'Activo',
    'guardian_activity_needs_exercise': 'Necesita ejercicio',
    'guardian_activity_collecting': 'Recopilando datos',
    'guardian_error_load_step_history': 'No se pudo cargar el historial de pasos',
    'guardian_chart_y_axis_steps': 'Pasos',
    'guardian_chart_x_axis_last_7_days': 'Últimos 7 días',
    'guardian_chart_x_axis_last_30_days': 'Últimos 30 días',
    'guardian_chart_today': 'Hoy',
    'guardian_safety_needed': 'Se necesita verificación de seguridad',
    'guardian_error_load_subjects': 'No se pudo cargar la lista de personas protegidas.',
    'guardian_safety_confirmed': 'Seguridad confirmada.',
    'guardian_error_clear_alerts': 'No se pudieron eliminar las alertas.',

    // ── Agregar persona protegida ──
    'add_subject_title': 'Vincular persona protegida',
    'add_subject_guide_title': 'Introduzca el código único y un apodo.',
    'add_subject_guide_subtitle':
        'Vincule la aplicación de un ser querido para seguir su estado en tiempo real.',
    'add_subject_code_label': 'Código único (7 caracteres)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info':
        'El código único se encuentra en la aplicación de la persona protegida.',
    'add_subject_alias_label': 'Apodo',
    'add_subject_alias_hint': 'ej.: Mamá, Papá',
    'add_subject_connect': 'Vincular',
    'add_subject_error_login': 'Inicio de sesión necesario.',
    'add_subject_success': 'Persona protegida vinculada correctamente.',
    'add_subject_error_invalid_code': 'Código no válido.',
    'add_subject_error_already_connected': 'Ya está vinculado/a.',
    'add_subject_error_failed': 'Error de vinculación. Inténtelo de nuevo.',
    'add_subject_button': 'Agregar nueva persona protegida',

    // ── Ajustes (Protector) ──
    'settings_title': 'Ajustes',
    'settings_light_mode': 'Modo claro',
    'settings_dark_mode': 'Modo oscuro',
    'settings_connection_management': 'Gestión de conexiones',
    'settings_managed_subjects': 'Personas protegidas gestionadas',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'Suscripción y servicio',
    'settings_current_membership': 'Membresía actual',
    'settings_premium': 'Premium activo',
    'settings_free_trial': 'Prueba gratuita',
    'settings_days_remaining': '@days días restantes',
    'settings_manage_subscription': 'Gestionar suscripción',
    'settings_notification': 'Ajustes de notificación',
    'settings_terms_section': 'Legal',
    'settings_privacy_policy': 'Política de privacidad',
    'settings_terms': 'Términos de uso',
    'settings_app_version': 'Versión: v@version',

    // ── G+S (Guardián y protegido) ──
    'gs_enable_button': 'Recibir protección también',
    'gs_safety_code_button': 'Ver mi código de seguridad',
    'gs_safety_code_title': 'Mi código de seguridad',
    'gs_enable_dialog_title': 'Activar protección',
    'gs_enable_dialog_body':
        'Puedes recibir protección mientras mantienes tus funciones de guardián.\nSe emitirá un código de seguridad — compártelo con otros guardianes.',
    'gs_enable_dialog_ios_warning_title': '⚠ iOS funciona de forma diferente a Android',
    'gs_enable_dialog_ios_warning_body':
        'En iOS aparece cada día a la hora programada una "notificación push de bienestar". Debes tocar la notificación o abrir la aplicación tú mismo en ese momento para que se envíe tu señal de bienestar. Si no abres la aplicación, tus guardianes pueden recibir una alerta de comprobación perdida.',
    'gs_enable_dialog_ios_confirm': 'Entendido, activar',
    'gs_enable_confirm': 'Activar',
    'gs_enabled_message': 'La protección ha sido activada',
    'gs_enable_failed': 'Error al activar la protección',
    'gs_disable_dialog_title': 'Desactivar protección',
    'gs_disable_dialog_body':
        'Al desactivar se eliminará tu código de seguridad y se dejará de enviar verificaciones a los guardianes conectados.',
    'gs_disable_confirm': 'Desactivar',
    'gs_disabled_message': 'La protección ha sido desactivada',
    'gs_disable_failed': 'Error al desactivar la protección',
    'gs_activity_permission_denied_warning': 'Permiso de podómetro denegado. Toque aquí para permitir.',
    'gs_activity_permission_settings_title': 'Permiso necesario',
    'gs_activity_permission_settings_body': 'Permita el permiso Actividad física (Movimiento y Estado Físico) en la configuración de la aplicación.',
    'gs_activity_permission_settings_go': 'Ir a Configuración',

    // ── Modo Protector → G+S (Drawer/Diálogo) ──
    'drawer_enable_guardian': 'Gestionar también el bienestar familiar',
    's_to_gs_dialog_title': 'Añadir función de Protector',
    's_to_gs_dialog_body':
        'Añade la función de Protector para también velar por el bienestar de tu familia o seres queridos.\n(Nota: la función de Protector es gratuita durante 3 meses y luego pasa a ser una suscripción de pago.)\n\nTu propio código de seguridad y el envío de señales de bienestar actuales se mantienen sin cambios y seguirán siendo gratuitos.',
    's_to_gs_dialog_confirm': 'Continuar',
    's_to_gs_switch_failed': 'No se pudo activar la función de Protector',

    // ── Notificaciones (Protector) ──
    'notifications_title': 'Notificaciones',
    'notifications_today': 'Notificaciones de hoy',
    'notifications_empty': 'No hay notificaciones hoy',
    'notifications_delete_all_title': 'Eliminar todas las notificaciones',
    'notifications_auto_delete_notice': 'Las notificaciones de hoy se eliminan automáticamente a medianoche (0:00).',
    'notifications_delete_all_message': '¿Eliminar todas las notificaciones de hoy?',
    'notifications_delete_failed': 'No se pudieron eliminar las notificaciones.',
    'notifications_guide_title': 'Guía de niveles de notificación',
    'notifications_level_health': 'Normal',
    'notifications_level_health_desc': 'El bienestar de la persona protegida ha sido confirmado',
    'notifications_level_caution': 'Precaución',
    'notifications_level_caution_desc': 'Aún no hay señal de bienestar ni actividad del teléfono',
    'notifications_level_warning': 'Alerta',
    'notifications_level_warning_desc': 'Sin señal de bienestar ni actividad del teléfono durante varios días',
    'notifications_level_urgent': 'Urgente',
    'notifications_level_urgent_desc': 'Se requiere verificación inmediata',
    'notifications_level_info': 'Información',
    'notifications_level_info_desc': 'Pasos, batería baja y otros avisos',
    'notifications_activity_note':
        '※ Los datos de actividad pueden no mostrarse si no se pudieron obtener los pasos.',

    // ── Ajustes de notificación (Protector) ──
    'notification_settings_title': 'Ajustes de notificación',
    'notification_settings_push': 'Notificaciones push',
    'notification_settings_all': 'Todas las notificaciones',
    'notification_settings_all_desc':
        'Activar o desactivar todas las categorías de notificación a la vez.',
    'notification_settings_level_section': 'Ajustes por nivel',
    'notification_settings_urgent': 'Alertas urgentes',
    'notification_settings_urgent_desc': 'Las alertas urgentes no se pueden desactivar',
    'notification_settings_warning': 'Alertas de alerta',
    'notification_settings_warning_desc':
        'Alerta cuando no hay verificación durante 2 días consecutivos',
    'notification_settings_caution': 'Alertas de precaución',
    'notification_settings_caution_desc': 'Alerta cuando falta la verificación de hoy',
    'notification_settings_info': 'Alertas informativas',
    'notification_settings_info_desc': 'Alertas generales como número de pasos y nivel de batería',
    'notification_settings_dnd': 'No molestar',
    'notification_settings_dnd_start': 'Hora de inicio',
    'notification_settings_dnd_end': 'Hora de fin',
    'notification_settings_dnd_note':
        '※ Las alertas urgentes se envían incluso en modo «No molestar»',
    'notification_settings_dnd_start_default': '22:00',
    'notification_settings_dnd_end_default': '07:00',

    // ── Gestión de conexiones ──
    'connection_title': 'Gestión de conexiones',
    'connection_managed_count': 'Personas protegidas gestionadas ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Personas protegidas conectadas',
    'connection_empty': 'No hay personas protegidas conectadas',
    'connection_unlink_warning': 'Al desvincular se eliminarán los datos de esta persona.',
    'connection_unlink_warning_detail':
        'Los registros anteriores no se podrán recuperar tras una nueva vinculación. Deberá introducir de nuevo el código de la persona.',
    'connection_heartbeat_schedule': 'Cada día a las @time',
    'connection_heartbeat_report_time': 'La hora de reporte es ',
    'connection_subject_label': 'Persona protegida',
    'connection_change_only_in_app': 'solo se puede cambiar en la aplicación',
    'connection_edit_title': 'Editar persona protegida',
    'connection_alias_label': 'Apodo',
    'connection_unlink_title': 'Desvincular',
    'connection_unlink_confirm': '¿Desvincular a @alias?',
    'connection_unlink_success': 'Desvinculación completada.',
    'connection_unlink_failed': 'Error al desvincular.',
    'connection_load_failed': 'No se pudo cargar la lista.',

    // ── Navegación inferior ──
    'nav_home': 'Inicio',
    'nav_connection': 'Conexión',
    'nav_notification': 'Alertas',
    'nav_settings': 'Ajustes',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'Cambiar hora de verificación',
    'heartbeat_schedule_title_ios': 'Hora de notificación push de bienestar',
    'heartbeat_schedule_change_title_ios': 'Cambiar hora de notificación push de bienestar',
    'heartbeat_schedule_hint_ios':
        'Una notificación push de bienestar llega cada día a esta hora. Toca la notificación o abre la aplicación en ese momento para enviar tu señal de bienestar.',
    'heartbeat_daily_time': 'Cada día a las @time',
    'heartbeat_scheduled_today': 'Tu señal de bienestar se enviará a tus protectores cada día a las @time.',
    'heartbeat_change_failed_title': 'Error al cambiar la hora',
    'heartbeat_change_failed_message': 'No se pudo guardar en el servidor.',

    // ── Notificaciones locales ──
    'local_notification_channel': 'Alertas de bienestar',
    'local_notification_channel_desc': 'Notificaciones del servicio de bienestar',

    // ── Otros ──
    'back_press_exit': 'Pulse de nuevo para salir de la aplicación.',

    // ── Errores API ──
    'error_unknown': 'Se ha producido un error desconocido.',
    'error_timeout': 'La solicitud ha expirado.',
    'error_network': 'Compruebe su conexión a internet.',
    'error_unauthorized': 'Se requiere autenticación.',

    // ── Cuerpo de notificaciones ──
    'noti_auto_report_body': 'La verificación de bienestar programada se recibió hoy.',
    'noti_manual_report_body':
        'La persona protegida envió manualmente una verificación de bienestar.',
    'noti_battery_low_body':
        'La batería del teléfono está por debajo del 20 %. Puede ser necesario cargarlo.',
    'noti_battery_dead_body':
        'El teléfono parece haberse apagado por batería agotada. Último nivel de batería: @battery_level %. Se recuperará después de cargar.',
    'noti_caution_suspicious_body':
        'Se recibió una señal de bienestar, pero no hay indicios de uso del teléfono. Por favor, verifique en persona.',
    'noti_caution_missing_body':
        'La verificación de bienestar programada para hoy aún no se ha recibido. Por favor, verifique en persona.',
    'noti_warning_body':
        'Las verificaciones de bienestar se han perdido consecutivamente. Por favor, verifique en persona.',
    'noti_warning_suspicious_body':
        'No se detecta uso del teléfono de forma consecutiva. Se requiere verificación en persona.',
    'noti_urgent_body':
        'Sin verificación de bienestar durante @days día(s). Se requiere verificación inmediata.',
    'noti_urgent_suspicious_body':
        'Sin señales de uso del teléfono durante @days día(s). Se requiere verificación inmediata.',
    'noti_steps_body': '@steps pasos caminados hoy.',
    'noti_emergency_body':
        'La persona protegida ha solicitado ayuda directamente. Por favor, verifique de inmediato.',
    'noti_resolved_body': 'La verificación de bienestar del protegido ha vuelto a la normalidad.',
    'noti_cleared_by_guardian_title': '✅ Verificación confirmada',
    'noti_cleared_by_guardian_body':
        'Uno de los protectores ha confirmado personalmente la seguridad.',

    // ── Notificaciones locales ──
    'local_alarm_title': '💗 Verificación de bienestar necesaria',
    'local_alarm_body': 'Por favor, toque esta notificación.',
    'wellbeing_check_title': '💛 Verificación de bienestar',
    'wellbeing_check_body': '¿Se encuentra bien? Por favor, toque esta notificación.',
    'noti_channel_name': 'Alertas Anbu',
    'notification_send_failed_title': '📶 Verifique su conexión a Internet',
    'notification_send_failed_body': 'Abra la aplicación para reenviar su reporte de bienestar.',
  };
}
