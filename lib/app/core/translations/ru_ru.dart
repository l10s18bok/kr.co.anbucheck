abstract class RuRu {
  static const Map<String, String> translations = {
    // ── Общие ──
    'common_confirm': 'Подтвердить',
    'common_cancel': 'Отмена',
    'common_continue': 'Продолжить',
    'common_save': 'Сохранить',
    'common_delete': 'Удалить',
    'common_close': 'Закрыть',
    'common_next': 'Далее',
    'common_previous': 'Назад',
    'common_start': 'Начать',
    'common_skip': 'Пропустить',
    'common_later': 'Позже',
    'common_loading': 'Загрузка...',
    'common_error': 'Ошибка',
    'common_complete': 'Готово',
    'common_notice': 'Уведомление',
    'common_unlink': 'Отвязать',
    'common_am': 'ДП',
    'common_pm': 'ПП',
    'common_normal': 'Норма',
    'common_connected': 'Подключено',
    'common_disconnected': 'Нет связи',

    // ── Бренд приложения ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Проверяем, что у вас всё хорошо.',
    'app_service_desc': 'Автоматическая проверка самочувствия',
    'app_guardian_title': 'Anbu Опекун',
    'app_copyright': '© 2026 Ark SB Inc.',

    // ── Заставка ──
    'splash_loading': 'Проверяем самочувствие...',

    // ── Обновление ──
    'update_required_title': 'Требуется обновление',
    'update_required_message':
        'Для продолжения использования приложения необходимо обновиться до версии @version.',
    'update_button': 'Обновить',
    'update_available_title': 'Доступно обновление',
    'update_available_message': 'Доступна версия @version.',

    // ── Выбор режима ──
    'mode_select_title': 'Выберите вашу роль',
    'mode_select_subtitle': 'Это поможет настроить подходящие для вас функции',
    'mode_subject_title': 'Хочу, чтобы за моей\nбезопасностью следили',
    'mode_subject_button': 'Быть под защитой →',
    'mode_guardian_title': 'Хочу присматривать за\nблизким человеком',
    'mode_guardian_button': 'Стать опекуном →',
    'mode_select_notice': 'Интерфейс и уведомления будут зависеть от вашего выбора',

    // ── Разрешения ──
    'permission_title': 'Для работы приложения\nнеобходимы разрешения',
    'permission_notification': 'Разрешение на уведомления',
    'permission_notification_subject_desc':
        'Необходимо для получения уведомлений о проверке самочувствия',
    'permission_notification_guardian_desc':
        'Необходимо для получения уведомлений о состоянии подопечных',
    'permission_activity': 'Распознавание активности',
    'permission_activity_desc': 'Используется для подсчёта шагов и подтверждения активности',
    'permission_location': 'Геолокация',
    'permission_location_desc': 'Передаётся опекунам только при отправке экстренного запроса',
    'location_permission_warning':
        'Геолокация не будет отправлена с экстренным запросом. Нажмите, чтобы разрешить.',
    'location_permission_settings_title': 'Требуется разрешение геолокации',
    'location_permission_settings_body_ios':
        'Найдите и выберите «Anbu», затем в разделе «Геопозиция» выберите «При использовании приложения».',
    'location_permission_settings_body_android':
        'Выберите «Разрешения» → «Геолокация», затем выберите «Разрешить только во время использования приложения».',
    'permission_activity_dialog_title': 'Информация о разрешении',
    'permission_activity_dialog_message':
        'Используется для подсчёта шагов и подтверждения активности.\nПожалуйста, нажмите «Разрешить» на следующем экране.',
    'permission_notification_required_title': 'Требуется разрешение на уведомления',
    'permission_notification_required_message':
        'Для работы сервиса проверки самочувствия необходимо разрешение на уведомления.\nПожалуйста, включите его в настройках.',
    'permission_go_to_settings': 'Перейти в настройки',
    'permission_activity_denied_title': 'Требуется разрешение на физическую активность',
    'permission_activity_denied_message':
        'Используется для подсчёта шагов и повышения точности проверки самочувствия.\nПожалуйста, включите разрешение в настройках.',
    'permission_battery': 'Исключение из оптимизации батареи',
    'permission_battery_desc':
        'Исключает приложение из оптимизации батареи, чтобы ежедневные проверки самочувствия не пропускались',
    'permission_hibernation_title': 'Отключите "Приостанавливать, если не используется"',
    'permission_hibernation_highlight': 'Приостанавливать, если не используется',
    'permission_hibernation_message':
        'Если вы не открываете приложение несколько месяцев, Android может автоматически остановить его, прервав проверки благополучия.\n\nНажмите [Открыть настройки приложения] и отключите "Приостанавливать, если не используется".',
    'permission_hibernation_go_to_settings': 'Открыть настройки приложения',

    // ── Онбординг ──
    'onboarding_title_1': 'Беспокоитесь о близком\nчеловеке, живущем одном?',
    'onboarding_desc_1':
        'Даже на расстоянии\nвы хотите знать, всё ли у них хорошо.\nAnbu — рядом с вами.',
    'onboarding_title_2': 'Проверка самочувствия\nбез единого слова',
    'onboarding_desc_2':
        'Просто пользуясь смартфоном,\nкаждый день автоматически\nотправляется сигнал о самочувствии.',
    'onboarding_title_3': 'Делитесь новостями\nс близкими людьми',
    'onboarding_desc_3':
        'Ежедневные проверки создают\nвзаимное спокойствие.\nНачните прямо сейчас.',
    'onboarding_title_4': 'Ни имён, ни номеров телефонов\n— ничего не собираем',
    'onboarding_desc_4':
        'Передаётся только один сигнал:\n«У меня всё хорошо.»\nВаши данные в безопасности.',
    'onboarding_role_subject': 'Подопечный',
    'onboarding_role_guardian': 'Опекун',
    'onboarding_role_guardian_subject': 'Опекун и подопечный',
    'onboarding_already_registered_title': 'Устройство уже зарегистрировано',
    'onboarding_already_registered_message':
        'Это устройство уже зарегистрировано в режиме "@roleLabel".\nПродолжить как "@roleLabel"?\n\nИли переключиться в режим "@newRoleLabel"?\nПри переключении все данные будут удалены.',
    'onboarding_already_registered_message_gs':
        'Это устройство уже зарегистрировано в режиме «@roleLabel».\nПереключение на режим «@newRoleLabel» удалит все данные опекуна и подопечного.',
    'onboarding_registration_failed_title': 'Ошибка регистрации',
    'onboarding_registration_failed_message':
        'Не удалось подключиться к серверу. Пожалуйста, попробуйте позже.',

    // ── Главная подопечного ──
    'subject_home_share_title': 'Поделитесь вашим кодом безопасности',
    'subject_home_guardian_count': 'Подключённые опекуны: @count',
    'subject_home_check_title_last': 'Последняя проверка',
    'subject_home_check_title_scheduled': 'Запланированное время',
    'subject_home_check_title_checking': 'Проверка самочувствия',
    'subject_home_check_body_reported': 'Отчёт в @time',
    'subject_home_check_body_scheduled': 'Запланировано на @time',
    'subject_home_check_body_waiting': 'Ожидание с @time',
    'subject_home_battery_status': 'Состояние батареи',
    'subject_home_battery_charging': 'Заряжается',
    'subject_home_battery_full': 'Полностью заряжено',
    'subject_home_battery_low': 'Низкий заряд',
    'subject_home_connectivity_status': 'Состояние связи',
    'subject_home_report_loading': 'Отправка отчёта...',
    'subject_home_report_button': 'Сообщить, что всё хорошо',
    'subject_home_report_desc': 'Сообщите опекуну, что у вас всё в порядке',
    'subject_home_emergency_button': 'Мне нужна помощь',
    'subject_home_emergency_desc': 'Отправляет экстренное оповещение вашим опекунам',
    'subject_home_emergency_loading': 'Отправка экстренного оповещения...',
    'subject_home_emergency_sent': 'Экстренное оповещение отправлено',
    'subject_home_emergency_failed': 'Не удалось отправить экстренное оповещение',
    'subject_home_manual_report_limit_reached':
        'Вы уже отправили сегодняшний отчёт о безопасности. Попробуйте завтра снова.',
    'subject_home_manual_report_sent': 'Ваше сообщение о благополучии отправлено контактам.',
    'subject_home_emergency_confirm_title': 'Запрос экстренной помощи',
    'subject_home_emergency_confirm_body':
        'Экстренное оповещение будет отправлено всем опекунам.\nТакже будет передано ваше текущее местоположение.\nВы действительно хотите запросить помощь?',
    'emergency_sent_with_location': 'Экстренное оповещение отправлено (с местоположением)',
    'emergency_sent_without_location': 'Экстренное оповещение отправлено',
    'notifications_view_location': '🗺️ Показать местоположение',
    'emergency_map_title': 'Экстренное местоположение',
    'emergency_map_subject_label': 'Подопечный',
    'emergency_map_captured_at_label': 'Время получения',
    'emergency_map_accuracy_label': 'Точность',
    'emergency_map_open_external': 'Открыть во внешнем приложении карт',
    'emergency_map_no_location': 'Нет информации о местоположении',
    'emergency_location_permission_denied_snackbar':
        'Экстренное оповещение отправлено без разрешения на местоположение',
    'subject_home_emergency_confirm_send': 'Отправить экстренный запрос',
    'subject_home_share_text':
        'Проверяйте моё самочувствие через приложение Anbu!\nКод приглашения: @code',
    'subject_home_share_subject': 'Код приглашения Anbu',
    'subject_home_code_copied': 'Код скопирован',

    // ── Боковое меню подопечного ──
    'drawer_light_mode': 'Светлая тема',
    'drawer_dark_mode': 'Тёмная тема',
    'drawer_privacy_policy': 'Политика конфиденциальности',
    'drawer_terms': 'Условия использования',
    'drawer_withdraw': 'Удалить аккаунт',
    'drawer_withdraw_message': 'Ваш аккаунт и все данные будут удалены.\nВы уверены?',

    // ── Панель опекуна ──
    'guardian_status_normal': 'Безопасно',
    'guardian_status_caution': 'Внимание',
    'guardian_status_warning': 'Предупреждение',
    'guardian_status_urgent': 'Срочно',
    'guardian_status_confirmed': '✅ Безопасно',
    'guardian_subscription_expired': 'Подписка истекла',
    'guardian_subscription_expired_message':
        'Уведомления о тревогах не отправляются.\nПродлите подписку для продолжения защиты.',
    'guardian_subscribe': 'Подписаться',
    'guardian_payment_preparing': 'Функция оплаты скоро будет доступна.',
    'guardian_today_summary': 'Сводка за сегодня',
    'guardian_no_subjects': 'Нет подключённых подопечных.',
    'guardian_checking_subjects': 'В настоящее время проверяется\n@count подопечный(ых).',
    'guardian_subject_list': 'Список подопечных',
    'guardian_call_now': 'Позвонить сейчас',
    'guardian_confirm_safety': 'Подтвердить безопасность',
    'guardian_no_check_history': 'Нет истории проверок',
    'guardian_last_check_now': 'Последняя проверка: только что',
    'guardian_last_check_minutes': 'Последняя проверка: @minutes мин назад',
    'guardian_last_check_hours': 'Последняя проверка: @hours ч назад',
    'guardian_last_check_days': 'Последняя проверка: @days дн назад',
    'guardian_activity_stable': 'Активность: стабильная',
    'guardian_activity_prefix': 'Активность',
    'guardian_activity_very_active': 'Очень активен',
    'guardian_activity_active': 'Активен',
    'guardian_activity_needs_exercise': 'Нужны упражнения',
    'guardian_activity_collecting': 'Сбор данных',
    'guardian_error_load_step_history': 'Не удалось загрузить историю шагов',
    'guardian_chart_y_axis_steps': 'Шаги',
    'guardian_chart_x_axis_last_7_days': 'Последние 7 дней',
    'guardian_chart_x_axis_last_30_days': 'Последние 30 дней',
    'guardian_chart_today': 'Сегодня',
    'guardian_safety_needed': 'Необходима проверка безопасности',
    'guardian_error_load_subjects': 'Не удалось загрузить список подопечных.',
    'guardian_safety_confirmed': 'Безопасность подтверждена.',
    'guardian_error_clear_alerts': 'Не удалось сбросить тревоги.',

    // ── Добавление подопечного ──
    'add_subject_title': 'Привязка подопечного',
    'add_subject_guide_title': 'Введите уникальный код подопечного и задайте имя.',
    'add_subject_guide_subtitle':
        'Привяжите приложение подопечного для отслеживания состояния здоровья и активности.',
    'add_subject_code_label': 'Уникальный код (7 символов)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info': 'Уникальный код можно найти в приложении подопечного.',
    'add_subject_alias_label': 'Имя подопечного',
    'add_subject_alias_hint': 'Напр.: мама, папа',
    'add_subject_connect': 'Привязать',
    'add_subject_error_login': 'Требуется авторизация.',
    'add_subject_success': 'Подопечный успешно подключён.',
    'add_subject_error_invalid_code': 'Недействительный код.',
    'add_subject_error_already_connected': 'Уже подключён.',
    'add_subject_error_failed': 'Не удалось подключить. Пожалуйста, попробуйте позже.',
    'add_subject_button': 'Добавить подопечного',

    // ── Настройки опекуна ──
    'settings_title': 'Настройки',
    'settings_light_mode': 'Светлая тема',
    'settings_dark_mode': 'Тёмная тема',
    'settings_connection_management': 'Управление подключениями',
    'settings_managed_subjects': 'Количество подопечных',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'Подписка и сервис',
    'settings_current_membership': 'Текущая подписка',
    'settings_premium': 'Премиум активна',
    'settings_free_trial': 'Бесплатный период',
    'settings_days_remaining': 'Осталось @days дн.',
    'settings_manage_subscription': 'Управление подпиской',
    'settings_notification': 'Настройки уведомлений',
    'settings_terms_section': 'Правовая информация',
    'settings_privacy_policy': 'Политика конфиденциальности',
    'settings_terms': 'Условия использования',
    'settings_app_version': 'Версия: v@version',

    // ── G+S (Опекун + Подопечный) ──
    'gs_enable_button': 'Получать защиту тоже',
    'gs_safety_code_button': 'Проверить мой код безопасности',
    'gs_safety_code_title': 'Мой код безопасности',
    'gs_enable_dialog_title': 'Включить защиту',
    'gs_enable_dialog_body':
        'Вы можете получать защиту, сохраняя функции опекуна.\nБудет выдан код безопасности — поделитесь им с другими опекунами.',
    'gs_enable_dialog_ios_warning_title': '⚠ iOS работает иначе, чем Android',
    'gs_enable_dialog_ios_warning_body':
        'На iOS каждый день в установленное время появляется «push-уведомление о благополучии». Вы должны нажать на уведомление или сами открыть приложение в это время, чтобы ваш сигнал благополучия был отправлен. Если вы не откроете приложение, опекуны могут получить предупреждение о пропущенной проверке.',
    'gs_enable_dialog_ios_confirm': 'Понятно, включить',
    'gs_enable_confirm': 'Включить',
    'gs_enabled_message': 'Защита включена',
    'gs_enable_failed': 'Не удалось включить защиту',
    'gs_disable_dialog_title': 'Отключить защиту',
    'gs_disable_dialog_body':
        'При отключении ваш код безопасности будет удалён, и проверки для связанных опекунов прекратятся.',
    'gs_disable_confirm': 'Отключить',
    'gs_disabled_message': 'Защита отключена',
    'gs_disable_failed': 'Не удалось отключить защиту',
    'gs_activity_permission_denied_warning':
        'Разрешение на шагомер отклонено. Нажмите здесь, чтобы разрешить.',
    'gs_activity_permission_settings_title': 'Требуется разрешение',
    'gs_activity_permission_settings_body':
        'Разрешите доступ к физической активности (Движение и фитнес) в настройках приложения.',
    'gs_activity_permission_settings_go': 'Перейти к настройкам',

    // ── Режим опекуна → G+S (Drawer/Диалог) ──
    'drawer_enable_guardian': 'Также следить за близкими',
    's_to_gs_dialog_title': 'Добавить функцию опекуна',
    's_to_gs_dialog_body':
        'Добавьте функцию опекуна, чтобы также следить за самочувствием родных и близких.\n(Внимание: функция опекуна бесплатна в течение 3 месяцев, затем переходит на платную подписку.)\n\nВаш собственный код безопасности и используемая сейчас отправка сигналов о самочувствии сохраняются без изменений и остаются бесплатными.',
    's_to_gs_dialog_confirm': 'Продолжить',
    's_to_gs_switch_failed': 'Не удалось включить функцию опекуна',

    // ── Уведомления опекуна ──
    'notifications_title': 'Уведомления',
    'notifications_today': 'Сегодняшние уведомления',
    'notifications_empty': 'Сегодня уведомлений нет',
    'notifications_delete_all_title': 'Удалить все уведомления',
    'notifications_auto_delete_notice':
        'Сегодняшние уведомления автоматически удаляются в полночь (0:00).',
    'notifications_delete_all_message': 'Удалить все сегодняшние уведомления?',
    'notifications_delete_failed': 'Не удалось удалить уведомления.',
    'notifications_guide_title': 'Уровни уведомлений',
    'notifications_level_health': 'Норма',
    'notifications_level_health_desc': 'Самочувствие подопечного подтверждено',
    'notifications_level_caution': 'Внимание',
    'notifications_level_caution_desc': 'Пока нет сигнала благополучия или записи активности',
    'notifications_level_warning': 'Предупреждение',
    'notifications_level_warning_desc':
        'Нет сигнала благополучия или записи активности несколько дней подряд',
    'notifications_level_urgent': 'Срочно',
    'notifications_level_urgent_desc': 'Требуется немедленная проверка',
    'notifications_level_info': 'Информация',
    'notifications_level_info_desc': 'Шаги, низкий заряд и другие уведомления',
    'notifications_activity_note':
        '※ Информация об активности может не отображаться, если данные о шагах недоступны.',

    // ── Настройки уведомлений опекуна ──
    'notification_settings_title': 'Настройки уведомлений',
    'notification_settings_push': 'Push-уведомления',
    'notification_settings_all': 'Все уведомления',
    'notification_settings_all_desc':
        'Включить или отключить все категории уведомлений одновременно.',
    'notification_settings_level_section': 'Настройки по уровням',
    'notification_settings_urgent': 'Срочные тревоги',
    'notification_settings_urgent_desc': 'Срочные тревоги невозможно отключить',
    'notification_settings_warning': 'Предупреждения',
    'notification_settings_warning_desc': 'Уведомление при отсутствии проверки 2 дня подряд',
    'notification_settings_caution': 'Уведомления «Внимание»',
    'notification_settings_caution_desc': 'Уведомление при отсутствии сегодняшней проверки',
    'notification_settings_info': 'Информационные уведомления',
    'notification_settings_info_desc': 'Общие уведомления: шаги, состояние батареи и т.д.',
    'notification_settings_dnd': 'Режим «Не беспокоить»',
    'notification_settings_dnd_start': 'Начало',
    'notification_settings_dnd_end': 'Окончание',
    'notification_settings_dnd_note':
        '※ Срочные тревоги доставляются даже в режиме «Не беспокоить»',
    'notification_settings_dnd_start_default': '22:00',
    'notification_settings_dnd_end_default': '07:00',

    // ── Управление подключениями опекуна ──
    'connection_title': 'Управление подключениями',
    'connection_managed_count': 'Количество подопечных ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Подключённые подопечные',
    'connection_empty': 'Нет подключённых подопечных',
    'connection_unlink_warning': 'При отвязке данные подопечного будут удалены.',
    'connection_unlink_warning_detail':
        'Предыдущие записи не подлежат восстановлению. Вам потребуется заново ввести код подопечного.',
    'connection_heartbeat_schedule': 'Ежедневно в @time',
    'connection_heartbeat_report_time': 'Время отчёта о самочувствии — ',
    'connection_subject_label': 'Подопечный',
    'connection_change_only_in_app': 'можно изменить только в приложении',
    'connection_edit_title': 'Редактировать подопечного',
    'connection_alias_label': 'Имя',
    'connection_unlink_title': 'Отвязать',
    'connection_unlink_confirm': 'Отвязать @alias?',
    'connection_unlink_success': 'Успешно отвязано.',
    'connection_unlink_failed': 'Не удалось отвязать.',
    'connection_load_failed': 'Не удалось загрузить список.',

    // ── Нижняя навигация опекуна ──
    'nav_home': 'Главная',
    'nav_connection': 'Связи',
    'nav_notification': 'Тревоги',
    'nav_settings': 'Настройки',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'Изменить время проверки',
    'heartbeat_schedule_title_ios': 'Время push-уведомления о благополучии',
    'heartbeat_schedule_change_title_ios': 'Изменить время push-уведомления о благополучии',
    'heartbeat_schedule_hint_ios':
        'Push-уведомление о благополучии приходит каждый день в это время. Нажмите на уведомление или откройте приложение в это время, чтобы отправить сигнал благополучия.',
    'heartbeat_daily_time': 'Ежедневно в @time',
    'heartbeat_scheduled_today':
        'Ваш сигнал благополучия будет отправляться опекунам каждый день в @time.',
    'heartbeat_change_failed_title': 'Ошибка изменения времени',
    'heartbeat_change_failed_message': 'Не удалось сохранить изменения на сервере.',

    // ── Локальные уведомления ──
    'local_notification_channel': 'Уведомления о самочувствии',
    'local_notification_channel_desc': 'Уведомления сервиса проверки самочувствия',

    // ── Разное ──
    'back_press_exit': 'Нажмите «Назад» ещё раз для выхода.',

    // ── Ошибки API ──
    'error_unknown': 'Произошла неизвестная ошибка.',
    'error_timeout': 'Время ожидания истекло.',
    'error_network': 'Пожалуйста, проверьте подключение к сети.',
    'error_unauthorized': 'Требуется авторизация.',

    // ── Текст уведомлений ──
    'noti_auto_report_body': 'Проверка самочувствия успешно получена.',
    'noti_manual_report_body': 'Подопечный вручную отправил проверку самочувствия.',
    'noti_battery_low_body': 'Заряд батареи телефона ниже 20 %. Может потребоваться зарядка.',
    'noti_battery_dead_body':
        'Телефон, похоже, выключился из-за разряженной батареи. Последний уровень заряда: @battery_level %. Восстановится после зарядки.',
    'noti_caution_suspicious_body':
        'Сигнал самочувствия получен, но сегодня запись активности не обнаружена. Пожалуйста, проверьте лично.',
    'noti_caution_missing_body':
        'Запланированная на сегодня проверка самочувствия ещё не получена. Пожалуйста, проверьте лично.',
    'noti_warning_body': 'Проверки самочувствия пропущены подряд. Необходима личная проверка.',
    'noti_warning_suspicious_body':
        'Записи активности нет несколько раз подряд. Требуется личная проверка.',
    'noti_urgent_body': 'Нет проверки самочувствия @days дн. Требуется немедленная проверка.',
    'noti_urgent_suspicious_body':
        'Нет записи активности уже @days дн. Требуется немедленная проверка.',
    'noti_steps_body': 'Сегодня пройдено @steps шагов.',
    'noti_emergency_body': 'Подопечный лично запросил помощь. Пожалуйста, проверьте немедленно.',
    'noti_resolved_body': 'Проверка здоровья подопечного вернулась в норму.',
    'noti_cleared_by_guardian_title': '✅ Проверка подтверждена',
    'noti_cleared_by_guardian_body': 'Один из опекунов лично подтвердил безопасность подопечного.',

    // ── Локальные уведомления ──
    'local_alarm_title': '💗 Требуется проверка самочувствия',
    'local_alarm_body': 'Пожалуйста, нажмите на это уведомление.',
    'wellbeing_check_title': '💛 Проверка самочувствия',
    'wellbeing_check_body': 'У вас всё хорошо? Пожалуйста, нажмите на это уведомление.',
    'noti_channel_name': 'Уведомления Anbu',
    'notification_send_failed_title': '📶 Проверьте интернет-соединение',
    'notification_send_failed_body':
        'Откройте приложение, чтобы повторно отправить отчёт о самочувствии.',
  };
}
