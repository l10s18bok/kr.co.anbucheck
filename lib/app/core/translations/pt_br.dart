abstract class PtBr {
  static const Map<String, String> translations = {
    // ── Comum ──
    'common_confirm': 'Confirmar',
    'common_cancel': 'Cancelar',
    'common_continue': 'Continuar',
    'common_save': 'Salvar',
    'common_delete': 'Excluir',
    'common_close': 'Fechar',
    'common_next': 'Avançar',
    'common_previous': 'Voltar',
    'common_start': 'Começar',
    'common_skip': 'Pular',
    'common_later': 'Depois',
    'common_loading': 'Carregando...',
    'common_error': 'Erro',
    'common_complete': 'Concluído',
    'common_notice': 'Aviso',
    'common_unlink': 'Desvincular',
    'common_am': 'AM',
    'common_pm': 'PM',
    'common_normal': 'Normal',
    'common_connected': 'Conectado',
    'common_disconnected': 'Desconectado',

    // ── Marca do app ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Verificando o seu bem-estar.',
    'app_service_desc': 'Serviço automático de verificação de bem-estar',
    'app_guardian_title': 'Anbu Guardião',
    'app_copyright': '© 2026 Averic SB Inc.',

    // ── Splash ──
    'splash_loading': 'Verificando...',

    // ── Atualização ──
    'update_required_title': 'Atualização necessária',
    'update_required_message': 'Atualize para a versão @version para continuar usando o app.',
    'update_button': 'Atualizar',
    'update_available_title': 'Atualização disponível',
    'update_available_message': 'A versão @version está disponível.',

    // ── Seleção de modo ──
    'mode_select_title': 'Escolha sua função',
    'mode_select_subtitle': 'Isso nos ajuda a configurar as funcionalidades certas para você',
    'mode_subject_title': 'Quero que minha segurança\nseja monitorada',
    'mode_subject_button': 'Quero ser protegido →',
    'mode_guardian_title': 'Quero cuidar de alguém\nque eu amo',
    'mode_guardian_button': 'Começar como guardião →',
    'mode_select_notice': 'O layout e as notificações serão diferentes de acordo com sua escolha',

    // ── Permissões ──
    'permission_title': 'Permissões necessárias\npara usar o app',
    'permission_notification': 'Permissão de notificações',
    'permission_notification_subject_desc':
        'Necessária para receber alertas de verificação de bem-estar',
    'permission_notification_guardian_desc':
        'Necessária para receber alertas sobre o estado de segurança dos seus protegidos',
    'permission_activity': 'Reconhecimento de atividade',
    'permission_activity_desc': 'Usado para detectar passos e confirmar atividade',
    'permission_activity_dialog_title': 'Informações sobre a permissão de atividade',
    'permission_activity_dialog_message':
        'Usado para detectar passos e confirmar atividade.\nToque em "Permitir" na próxima tela.',
    'permission_notification_required_title': 'Permissão de notificações necessária',
    'permission_notification_required_message':
        'A permissão de notificações é necessária para o serviço de verificação de bem-estar.\nAtive-a nas Configurações.',
    'permission_go_to_settings': 'Ir para Configurações',
    'permission_activity_denied_title': 'Permissão de atividade física necessária',
    'permission_activity_denied_message':
        'Usada para detectar passos e melhorar a precisão da verificação de bem-estar.\nAtive a permissão de atividade física nas Configurações.',
    'permission_battery': 'Exclusão da otimização de bateria',
    'permission_battery_desc':
        'Exclui o aplicativo da otimização de bateria para que as verificações diárias de bem-estar não sejam perdidas',
    'permission_battery_required_title': 'Defina a bateria como "Sem restrições"',
    'permission_battery_required_message':
        'Se estiver definida como "Otimização de bateria" ou "Economia de bateria", as verificações diárias de bem-estar podem ser atrasadas ou perdidas.\n\nApós tocar em [Ir para Configurações]:\n1. Selecione "Bateria"\n2. Altere para "Sem restrições"',
    'permission_battery_go_to_settings': 'Ir para Configurações',
    'permission_hibernation_title': 'Desative "Pausar atividade se não usado"',
    'permission_hibernation_highlight': 'Pausar atividade se não usado',
    'permission_hibernation_message':
        'Se você não abrir o app por vários meses, o Android pode pará-lo automaticamente, interrompendo as verificações de bem-estar.\n\nToque em [Abrir configurações do app] e desative "Pausar atividade se não usado".',
    'permission_hibernation_go_to_settings': 'Abrir configurações do app',

    // ── Onboarding ──
    'onboarding_title_1': 'Você se preocupa com alguém\nque mora sozinho?',
    'onboarding_desc_1':
        'Mesmo de longe,\nvocê se pergunta se está tudo bem.\nO Anbu está aqui para você.',
    'onboarding_title_2': 'A verificação de bem-estar\nacontece sem uma palavra',
    'onboarding_desc_2':
        'Apenas usando o smartphone,\num sinal diário de bem-estar\né enviado automaticamente.',
    'onboarding_title_3': 'Compartilhe o bem-estar\ncom quem você ama',
    'onboarding_desc_3':
        'Verificações diárias se acumulam\nem tranquilidade duradoura.\nVamos começar.',
    'onboarding_title_4': 'Sem nomes, sem números\nde telefone coletados',
    'onboarding_desc_4':
        'Apenas um sinal é transmitido:\n"Estou bem."\nSuas informações estão seguras.',
    'onboarding_role_subject': 'Protegido',
    'onboarding_role_guardian': 'Guardião',
    'onboarding_role_guardian_subject': 'Guardião e protegido',
    'onboarding_already_registered_title': 'Dispositivo já registrado',
    'onboarding_already_registered_message':
        'Este dispositivo já está registrado no modo "@roleLabel".\nDeseja continuar como "@roleLabel"?\n\nOu mudar para o modo "@newRoleLabel"?\nA mudança excluirá todos os dados existentes.',
    'onboarding_already_registered_message_gs':
        'Este dispositivo já está registrado no modo "@roleLabel".\nMudar para o modo "@newRoleLabel" excluirá todos os dados de guardião e protegido.',
    'onboarding_registration_failed_title': 'Registro falhou',
    'onboarding_registration_failed_message':
        'Não foi possível conectar ao servidor. Tente novamente mais tarde.',

    // ── Home do protegido ──
    'subject_home_share_title': 'Compartilhe seu código de segurança',
    'subject_home_guardian_count': 'Guardiões conectados: @count',
    'subject_home_check_title_last': 'Última verificação',
    'subject_home_check_title_scheduled': 'Verificação programada',
    'subject_home_check_title_checking': 'Verificando bem-estar',
    'subject_home_check_body_reported': 'Reportado às @time',
    'subject_home_check_body_scheduled': 'Programado às @time',
    'subject_home_check_body_waiting': 'Aguardando desde @time',
    'subject_home_battery_status': 'Status da bateria',
    'subject_home_battery_charging': 'Carregando',
    'subject_home_battery_full': 'Completa',
    'subject_home_battery_low': 'Bateria fraca',
    'subject_home_connectivity_status': 'Conectividade',
    'subject_home_report_loading': 'Reportando...',
    'subject_home_report_button': 'Reportar segurança agora',
    'subject_home_report_desc': 'Avise seu guardião de que você está bem',
    'subject_home_emergency_button': 'Preciso de ajuda',
    'subject_home_emergency_desc': 'Envia um alerta de emergência aos seus guardiões',
    'subject_home_emergency_loading': 'Enviando alerta de emergência...',
    'subject_home_emergency_sent': 'Alerta de emergência enviado',
    'subject_home_emergency_failed': 'Falha ao enviar alerta de emergência',
    'subject_home_manual_report_limit_reached': 'Você já enviou o relatório de segurança de hoje. Tente novamente amanhã.',
    'subject_home_emergency_confirm_title': 'Pedido de ajuda de emergência',
    'subject_home_emergency_confirm_body':
        'Um alerta de emergência será enviado a todos os guardiões.\nSua localização atual também será compartilhada.\nTem certeza de que deseja pedir ajuda?',
    'emergency_sent_with_location': 'Alerta de emergência enviado (com localização)',
    'emergency_sent_without_location': 'Alerta de emergência enviado',
    'notifications_view_location': '🗺️ Ver localização',
    'emergency_map_title': 'Localização de emergência',
    'emergency_map_subject_label': 'Pessoa protegida',
    'emergency_map_captured_at_label': 'Hora de captura',
    'emergency_map_accuracy_label': 'Precisão',
    'emergency_map_open_external': 'Abrir no app de mapas externo',
    'emergency_map_no_location': 'Sem informações de localização',
    'emergency_location_permission_denied_snackbar': 'Alerta de emergência enviado sem permissão de localização',
    'subject_home_emergency_confirm_send': 'Enviar pedido de emergência',
    'subject_home_share_text': 'Verifique como estou pelo app Anbu!\nCódigo de convite: @code',
    'subject_home_share_subject': 'Código de convite Anbu',
    'subject_home_code_copied': 'Código copiado',

    // ── Drawer do protegido ──
    'drawer_light_mode': 'Modo claro',
    'drawer_dark_mode': 'Modo escuro',
    'drawer_privacy_policy': 'Política de privacidade',
    'drawer_terms': 'Termos de uso',
    'drawer_withdraw': 'Excluir conta',
    'drawer_withdraw_message': 'Sua conta e todos os dados serão excluídos.\nTem certeza?',

    // ── Painel do guardião ──
    'guardian_status_normal': 'Seguro',
    'guardian_status_caution': 'Atenção',
    'guardian_status_warning': 'Alerta',
    'guardian_status_urgent': 'Urgente',
    'guardian_status_confirmed': '✅ Seguro',
    'guardian_subscription_expired': 'Assinatura expirada',
    'guardian_subscription_expired_message':
        'As notificações de alerta não estão sendo enviadas.\nRenove sua assinatura para continuar a proteção.',
    'guardian_subscribe': 'Assinar',
    'guardian_payment_preparing': 'A função de pagamento estará disponível em breve.',
    'guardian_today_summary': 'Resumo de bem-estar de hoje',
    'guardian_no_subjects': 'Nenhum protegido conectado.',
    'guardian_checking_subjects': 'Monitorando atualmente\n@count protegido(s).',
    'guardian_subject_list': 'Lista de protegidos',
    'guardian_call_now': 'Ligar agora',
    'guardian_confirm_safety': 'Confirmar segurança',
    'guardian_no_check_history': 'Sem histórico de verificação',
    'guardian_last_check_now': 'Última verificação: agora',
    'guardian_last_check_minutes': 'Última verificação: @minutes min atrás',
    'guardian_last_check_hours': 'Última verificação: @hours h atrás',
    'guardian_last_check_days': 'Última verificação: @days dia(s) atrás',
    'guardian_activity_stable': 'Atividade: estável',
    'guardian_activity_prefix': 'Atividade',
    'guardian_activity_very_active': 'Muito ativo',
    'guardian_activity_active': 'Ativo',
    'guardian_activity_needs_exercise': 'Precisa de exercício',
    'guardian_activity_collecting': 'Coletando dados',
    'guardian_error_load_step_history': 'Falha ao carregar histórico de passos',
    'guardian_chart_y_axis_steps': 'Passos',
    'guardian_chart_x_axis_last_7_days': 'Últimos 7 dias',
    'guardian_chart_x_axis_last_30_days': 'Últimos 30 dias',
    'guardian_chart_today': 'Hoje',
    'guardian_safety_needed': 'Verificação de segurança necessária',
    'guardian_error_load_subjects': 'Não foi possível carregar a lista de protegidos.',
    'guardian_error_clear_alerts': 'Não foi possível limpar os alertas.',

    // ── Adicionar protegido ──
    'add_subject_title': 'Vincular protegido',
    'add_subject_guide_title': 'Insira o código único do protegido e um apelido.',
    'add_subject_guide_subtitle':
        'Vincule o app do protegido para monitorar saúde e atividade em tempo real.',
    'add_subject_code_label': 'Código único (7 dígitos)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info': 'O código único pode ser encontrado no app do protegido.',
    'add_subject_alias_label': 'Apelido do protegido',
    'add_subject_alias_hint': 'Ex: Mãe, Pai',
    'add_subject_connect': 'Conectar',
    'add_subject_error_login': 'Login necessário.',
    'add_subject_success': 'Protegido conectado com sucesso.',
    'add_subject_error_invalid_code': 'Código inválido.',
    'add_subject_error_already_connected': 'Já conectado.',
    'add_subject_error_failed': 'Conexão falhou. Tente novamente mais tarde.',
    'add_subject_button': 'Adicionar novo protegido',

    // ── Configurações do guardião ──
    'settings_title': 'Configurações',
    'settings_light_mode': 'Modo claro',
    'settings_dark_mode': 'Modo escuro',
    'settings_connection_management': 'Gerenciamento de conexões',
    'settings_managed_subjects': 'Protegidos gerenciados',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'Assinatura e serviço',
    'settings_current_membership': 'Plano atual',
    'settings_premium': 'Premium ativo',
    'settings_free_trial': 'Período de teste',
    'settings_days_remaining': '@days dias restantes',
    'settings_manage_subscription': 'Gerenciar assinatura',
    'settings_notification': 'Configurações de notificação',
    'settings_terms_section': 'Jurídico',
    'settings_privacy_policy': 'Política de privacidade',
    'settings_terms': 'Termos de uso',
    'settings_app_version': 'Versão: v@version',

    // ── G+S (Guardião e protegido) ──
    'gs_enable_button': 'Receber proteção também',
    'gs_safety_code_button': 'Ver meu código de segurança',
    'gs_safety_code_title': 'Meu código de segurança',
    'gs_enable_dialog_title': 'Ativar proteção',
    'gs_enable_dialog_body':
        'Você pode receber proteção mantendo suas funções de guardião.\nUm código de segurança será emitido — compartilhe-o com outros guardiões.',
    'gs_enable_dialog_ios_warning_title': '⚠ O iOS funciona de forma diferente do Android',
    'gs_enable_dialog_ios_warning_body':
        'No iOS, uma "notificação push de bem-estar" aparece todos os dias no horário programado. Você deve tocar na notificação ou abrir o aplicativo por conta própria nesse horário para que seu sinal de bem-estar seja enviado. Se não abrir o aplicativo, seus guardiões podem receber um alerta de verificação perdida.',
    'gs_enable_dialog_ios_confirm': 'Entendi, ativar',
    'gs_enable_confirm': 'Ativar',
    'gs_enabled_message': 'A proteção foi ativada',
    'gs_enable_failed': 'Falha ao ativar a proteção',
    'gs_disable_dialog_title': 'Desativar proteção',
    'gs_disable_dialog_body':
        'Ao desativar, seu código de segurança será excluído e as verificações aos guardiões conectados serão interrompidas.',
    'gs_disable_confirm': 'Desativar',
    'gs_disabled_message': 'A proteção foi desativada',
    'gs_disable_failed': 'Falha ao desativar a proteção',
    'gs_activity_permission_denied_warning': 'Permissão de pedômetro negada. Toque aqui para permitir.',
    'gs_activity_permission_settings_title': 'Permissão necessária',
    'gs_activity_permission_settings_body': 'Permita a permissão Atividade física (Movimento e Atividade Física) nas configurações do aplicativo.',
    'gs_activity_permission_settings_go': 'Ir para Configurações',

    // ── Notificações do guardião ──
    'notifications_title': 'Notificações',
    'notifications_today': 'Notificações de hoje',
    'notifications_empty': 'Nenhuma notificação hoje',
    'notifications_delete_all_title': 'Excluir todas as notificações',
    'notifications_delete_all_message': 'Excluir todas as notificações de hoje?',
    'notifications_delete_failed': 'Não foi possível excluir as notificações.',
    'notifications_guide_title': 'Guia de níveis de notificação',
    'notifications_level_health': 'Normal',
    'notifications_level_health_desc': 'O bem-estar do protegido foi confirmado normalmente',
    'notifications_level_caution': 'Atenção',
    'notifications_level_caution_desc': 'Ainda sem sinal de bem-estar ou atividade do telefone',
    'notifications_level_warning': 'Alerta',
    'notifications_level_warning_desc': 'Sem sinal de bem-estar ou atividade do telefone por vários dias',
    'notifications_level_urgent': 'Urgente',
    'notifications_level_urgent_desc': 'Verificação imediata necessária',
    'notifications_level_info': 'Info',
    'notifications_level_info_desc': 'Passos, bateria fraca e outros avisos',
    'notifications_activity_note':
        '※ As informações de atividade podem não ser exibidas se os dados de passos não puderam ser coletados.',

    // ── Configurações de notificação do guardião ──
    'notification_settings_title': 'Configurações de notificação',
    'notification_settings_push': 'Notificações push',
    'notification_settings_all': 'Todas as notificações',
    'notification_settings_all_desc':
        'Ativa ou desativa todas as categorias de notificação de uma vez.',
    'notification_settings_level_section': 'Configurações por nível',
    'notification_settings_urgent': 'Alertas urgentes',
    'notification_settings_urgent_desc': 'Alertas urgentes não podem ser desativados',
    'notification_settings_warning': 'Alertas de aviso',
    'notification_settings_warning_desc':
        'Alerta quando não há verificação por 2 dias consecutivos',
    'notification_settings_caution': 'Alertas de atenção',
    'notification_settings_caution_desc': 'Alerta quando a verificação de hoje está ausente',
    'notification_settings_info': 'Alertas informativos',
    'notification_settings_info_desc': 'Alertas gerais como número de passos e status da bateria',
    'notification_settings_dnd': 'Não perturbe',
    'notification_settings_dnd_start': 'Hora de início',
    'notification_settings_dnd_end': 'Hora de término',
    'notification_settings_dnd_note':
        '※ Alertas urgentes são entregues mesmo durante o modo Não perturbe',
    'notification_settings_dnd_start_default': '22:00',
    'notification_settings_dnd_end_default': '07:00',

    // ── Gerenciamento de conexões do guardião ──
    'connection_title': 'Gerenciamento de conexões',
    'connection_managed_count': 'Protegidos gerenciados ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Protegidos conectados',
    'connection_empty': 'Nenhuma pessoa protegida conectada',
    'connection_unlink_warning': 'A desvinculação excluirá os dados do protegido.',
    'connection_unlink_warning_detail':
        'Os dados anteriores não poderão ser recuperados após uma nova vinculação. Você precisará inserir o código do protegido novamente.',
    'connection_heartbeat_schedule': 'Diariamente às @time',
    'connection_heartbeat_report_time': 'O horário do relatório de bem-estar é ',
    'connection_subject_label': 'Protegido',
    'connection_change_only_in_app': 'só pode ser alterado no app',
    'connection_edit_title': 'Editar protegido',
    'connection_alias_label': 'Apelido',
    'connection_unlink_title': 'Desvincular',
    'connection_unlink_confirm': 'Desvincular @alias?',
    'connection_unlink_success': 'Desvinculado com sucesso.',
    'connection_unlink_failed': 'Falha ao desvincular.',
    'connection_load_failed': 'Não foi possível carregar a lista.',

    // ── Navegação do guardião ──
    'nav_home': 'Início',
    'nav_connection': 'Conexão',
    'nav_notification': 'Alertas',
    'nav_settings': 'Configurações',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'Alterar horário de verificação',
    'heartbeat_schedule_title_ios': 'Horário da notificação push de bem-estar',
    'heartbeat_schedule_change_title_ios': 'Alterar horário da notificação push de bem-estar',
    'heartbeat_schedule_hint_ios':
        'Uma notificação push de bem-estar chega todos os dias neste horário. Toque na notificação ou abra o aplicativo nesse momento para enviar seu sinal de bem-estar.',
    'heartbeat_daily_time': 'Diariamente às @time',
    'heartbeat_scheduled_today': 'Seu sinal de bem-estar será enviado aos seus guardiões todos os dias às @time.',
    'heartbeat_change_failed_title': 'Falha ao alterar horário',
    'heartbeat_change_failed_message': 'Não foi possível atualizar no servidor.',

    // ── Notificações locais ──
    'local_notification_channel': 'Alertas de bem-estar',
    'local_notification_channel_desc': 'Notificações do serviço de verificação de bem-estar',

    // ── Diversos ──
    'back_press_exit': 'Pressione voltar novamente para sair.',

    // ── Erros de API ──
    'error_unknown': 'Ocorreu um erro desconhecido.',
    'error_timeout': 'A solicitação expirou.',
    'error_network': 'Verifique sua conexão de rede.',
    'error_unauthorized': 'Autenticação necessária.',

    // ── Corpo das notificações ──
    'noti_auto_report_body': 'A verificação de bem-estar agendada foi recebida hoje.',
    'noti_manual_report_body':
        'A pessoa protegida enviou manualmente uma verificação de bem-estar.',
    'noti_battery_low_body':
        'A bateria do celular está abaixo de 20%. Pode ser necessário carregar.',
    'noti_battery_dead_body':
        'O celular parece ter desligado por bateria esgotada. Último nível de bateria: @battery_level%. Será restaurado após o carregamento.',
    'noti_caution_suspicious_body':
        'Um sinal de bem-estar foi recebido, mas não há sinais de uso do celular. Por favor, verifique pessoalmente.',
    'noti_caution_missing_body':
        'A verificação de bem-estar agendada para hoje ainda não foi recebida. Por favor, verifique pessoalmente.',
    'noti_warning_body':
        'Verificações de bem-estar foram perdidas consecutivamente. Por favor, verifique pessoalmente.',
    'noti_warning_suspicious_body':
        'Nenhum sinal de uso do celular detectado consecutivamente. Verificação pessoal necessária.',
    'noti_urgent_body':
        'Sem verificação de bem-estar há @days dia(s). Verificação imediata necessária.',
    'noti_urgent_suspicious_body':
        'Sem sinais de uso do celular por @days dia(s). Verificação imediata necessária.',
    'noti_steps_body': '@steps passos dados hoje.',
    'noti_emergency_body': 'A pessoa protegida pediu ajuda diretamente. Verifique imediatamente.',
    'noti_resolved_body': 'A verificação de bem-estar do protegido voltou ao normal.',
    'noti_cleared_by_guardian_title': '✅ Verificação confirmada',
    'noti_cleared_by_guardian_body': 'Um dos protetores confirmou pessoalmente a segurança.',

    // ── Notificações locais ──
    'local_alarm_title': '💗 Verificação de bem-estar necessária',
    'local_alarm_body': 'Por favor, toque nesta notificação.',
    'wellbeing_check_title': '💛 Verificação de bem-estar',
    'wellbeing_check_body': 'Está tudo bem? Por favor, toque nesta notificação.',
    'noti_channel_name': 'Alertas Anbu',
    'notification_send_failed_title': '📶 Verifique sua conexão com a Internet',
    'notification_send_failed_body': 'Abra o aplicativo para reenviar seu check de bem-estar.',
  };
}
