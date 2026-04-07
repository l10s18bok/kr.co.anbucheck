abstract class ZhCn {
  static const Map<String, String> translations = {
    // ── 通用 ──
    'common_confirm': '确认',
    'common_cancel': '取消',
    'common_continue': '继续',
    'common_save': '保存',
    'common_delete': '删除',
    'common_close': '关闭',
    'common_next': '下一步',
    'common_previous': '上一步',
    'common_start': '开始使用',
    'common_skip': '跳过',
    'common_later': '稍后',
    'common_loading': '加载中...',
    'common_error': '错误',
    'common_complete': '完成',
    'common_notice': '提示',
    'common_unlink': '解除',
    'common_am': '上午',
    'common_pm': '下午',
    'common_normal': '正常',
    'common_connected': '已连接',
    'common_disconnected': '未连接',

    // ── 应用品牌 ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': '关心您的平安',
    'app_service_desc': '自动问安服务',
    'app_guardian_title': 'Anbu 守护者',
    'app_copyright': '© 2024 TNS Inc.',

    // ── 启动页 ──
    'splash_loading': '正在确认平安...',

    // ── 更新 ──
    'update_required_title': '需要更新',
    'update_required_message': '请更新到版本 @version 以继续使用应用。',
    'update_button': '更新',
    'update_available_title': '有新版本',
    'update_available_message': '新版本 @version 已发布。',

    // ── 模式选择 ──
    'mode_select_title': '请选择您的角色',
    'mode_select_subtitle': '我们将根据您的选择配置相应功能',
    'mode_subject_title': '我希望有人关注我的安全',
    'mode_subject_button': '成为被守护者 →',
    'mode_guardian_title': '我想守护家人的安全',
    'mode_guardian_button': '成为守护者 →',
    'mode_select_notice': '界面布局和通知设置将根据您的选择有所不同',

    // ── 权限请求 ──
    'permission_title': '使用应用\n需要以下权限',
    'permission_notification': '通知权限',
    'permission_notification_subject_desc': '接收问安提醒时需要此权限',
    'permission_notification_guardian_desc': '接收被守护者安全状态提醒时需要此权限',
    'permission_activity': '身体活动权限',
    'permission_activity_desc': '用于检测步数以确认活动状态',
    'permission_activity_dialog_title': '身体活动权限说明',
    'permission_activity_dialog_message':
        '用于检测步数以确认活动状态。\n请在下一个界面中选择"允许"。',
    'permission_notification_required_title': '需要通知权限',
    'permission_notification_required_message':
        '问安服务需要通知权限。\n请在设置中开启通知权限。',
    'permission_go_to_settings': '前往设置',

    // ── 引导页 ──
    'onboarding_title_1': '担心独居的亲人\n过得好不好？',
    'onboarding_desc_1': '即使相隔万里，\n也牵挂着他们是否安好。\nAnbu 与您同在。',
    'onboarding_title_2': '不用说一句话，\n平安自然传达',
    'onboarding_desc_2': '只要使用手机，\n每天自动发送一次\n平安信号。',
    'onboarding_title_3': '与亲人\n互报平安',
    'onboarding_desc_3': '每天的问安汇聚成\n彼此的安心。\n现在就开始吧。',
    'onboarding_title_4': '不收集姓名，\n也不收集电话号码',
    'onboarding_desc_4':
        '只传递一个信号：\n「我一切安好。」\n您的信息绝对安全。',
    'onboarding_role_subject': '被守护者',
    'onboarding_role_guardian': '守护者',
    'onboarding_already_registered_title': '设备已注册',
    'onboarding_already_registered_message':
        '此设备已注册为 "@roleLabel" 模式。\n是否继续使用 "@roleLabel" 模式？\n\n或者切换到 "@newRoleLabel" 模式？\n切换后所有已有数据将被删除。',
    'onboarding_registration_failed_title': '注册失败',
    'onboarding_registration_failed_message': '无法连接到服务器，请稍后再试。',

    // ── 被守护者首页 ──
    'subject_home_share_title': '请分享您的安全码',
    'subject_home_guardian_count': '已连接守护者：@count 人',
    'subject_home_check_title_last': '上次问安',
    'subject_home_check_title_scheduled': '预定报告时间',
    'subject_home_check_title_checking': '正在确认平安',
    'subject_home_check_body_reported': '@time 已正常报告',
    'subject_home_check_body_scheduled': '@time 预定报告',
    'subject_home_check_body_waiting': '@time 等待报告中',
    'subject_home_battery_status': '电池状态',
    'subject_home_battery_charging': '充电中',
    'subject_home_battery_full': '已充满',
    'subject_home_battery_low': '电量不足',
    'subject_home_connectivity_status': '网络连接状态',
    'subject_home_report_loading': '正在报告平安...',
    'subject_home_report_button': '立即报告安全',
    'subject_home_report_desc': '让守护者知道您一切安好',
    'subject_home_emergency_button': '我需要帮助',
    'subject_home_emergency_desc': '向监护人发送紧急警报',
    'subject_home_emergency_loading': '正在发送紧急警报...',
    'subject_home_emergency_sent': '紧急警报已发送',
    'subject_home_emergency_failed': '紧急警报发送失败',
    'subject_home_emergency_confirm_title': '紧急求助',
    'subject_home_emergency_confirm_body': '将向所有监护人发送紧急警报。\n确定要请求帮助吗？',
    'subject_home_emergency_confirm_send': '发送紧急请求',
    'subject_home_share_text': '请用 Anbu 应用查看我的平安！\n邀请码：@code',
    'subject_home_share_subject': 'Anbu 邀请码',
    'subject_home_code_copied': '邀请码已复制',

    // ── 被守护者侧边栏 ──
    'drawer_light_mode': '浅色模式',
    'drawer_dark_mode': '深色模式',
    'drawer_privacy_policy': '隐私政策',
    'drawer_terms': '使用条款',
    'drawer_withdraw': '注销账户',
    'drawer_withdraw_message': '账户及所有数据将被删除。\n确定要注销吗？',

    // ── 守护者仪表盘 ──
    'guardian_status_normal': '正常',
    'guardian_status_caution': '注意',
    'guardian_status_warning': '警告',
    'guardian_status_urgent': '紧急',
    'guardian_status_confirmed': '安全已确认',
    'guardian_subscription_expired': '订阅已过期',
    'guardian_subscription_expired_message':
        '警报通知已停止发送。\n请续订以继续守护服务。',
    'guardian_subscribe': '订阅',
    'guardian_payment_preparing': '支付功能正在准备中。',
    'guardian_today_summary': '今日问安总结',
    'guardian_no_subjects': '暂无已连接的被守护者。',
    'guardian_checking_subjects': '正在关注\n@count 位被守护者的平安。',
    'guardian_subject_list': '被守护者列表',
    'guardian_call_now': '立即拨打电话',
    'guardian_confirm_safety': '确认安全',
    'guardian_no_check_history': '暂无确认记录',
    'guardian_last_check_now': '上次确认：刚刚',
    'guardian_last_check_minutes': '上次确认：@minutes 分钟前',
    'guardian_last_check_hours': '上次确认：@hours 小时前',
    'guardian_last_check_days': '上次确认：@days 天前',
    'guardian_activity_stable': '活动量：稳定',
    'guardian_safety_needed': '需要确认安全',
    'guardian_error_load_subjects': '加载被守护者列表失败。',
    'guardian_error_clear_alerts': '解除警报失败。',

    // ── 守护者添加被守护者 ──
    'add_subject_title': '连接被守护者',
    'add_subject_guide_title': '请输入被守护者的专属码\n和别名。',
    'add_subject_guide_subtitle': '连接被守护者的应用后，\n可以实时查看其健康状态和活动情况。',
    'add_subject_code_label': '专属码（7位）',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info': '专属码可在被守护者的应用中找到。',
    'add_subject_alias_label': '被守护者别名',
    'add_subject_alias_hint': '例如：妈妈、爸爸',
    'add_subject_connect': '连接',
    'add_subject_error_login': '请先登录。',
    'add_subject_success': '被守护者已成功连接。',
    'add_subject_error_invalid_code': '无效的邀请码。',
    'add_subject_error_already_connected': '该被守护者已连接。',
    'add_subject_error_failed': '连接失败，请稍后再试。',
    'add_subject_button': '添加新的被守护者',

    // ── 守护者设置 ──
    'settings_title': '设置',
    'settings_light_mode': '浅色模式',
    'settings_dark_mode': '深色模式',
    'settings_connection_management': '连接管理',
    'settings_managed_subjects': '管理的被守护者人数',
    'settings_managed_subjects_count': '@current / @max 人',
    'settings_subscription_service': '订阅与服务',
    'settings_current_membership': '当前会员',
    'settings_premium': '高级订阅中',
    'settings_free_trial': '免费试用中',
    'settings_manage_subscription': '管理订阅',
    'settings_notification': '通知设置',
    'settings_terms_section': '条款',
    'settings_privacy_policy': '隐私政策',
    'settings_terms': '使用条款',
    'settings_app_version': '应用版本：v@version',

    // ── 守护者通知 ──
    'notifications_title': '通知',
    'notifications_today': '今日通知',
    'notifications_empty': '今天没有通知',
    'notifications_delete_all_title': '删除全部通知',
    'notifications_delete_all_message': '确定要删除今天的所有通知吗？',
    'notifications_delete_failed': '删除通知失败。',
    'notifications_guide_title': '通知等级说明',
    'notifications_level_health': '正常',
    'notifications_level_health_desc': '被守护者的平安已正常确认',
    'notifications_level_caution': '注意',
    'notifications_level_caution_desc':
        '以下情况之一：\n1. 今天预定的问安尚未收到\n2. 已收到问安但未检测到手机使用痕迹',
    'notifications_level_warning': '警告',
    'notifications_level_warning_desc':
        '以下情况之一：\n1. 连续2天未收到问安\n2. 连续2天未检测到手机使用',
    'notifications_level_urgent': '紧急',
    'notifications_level_urgent_desc': '长时间未收到问安，\n或连续3天以上未使用手机',
    'notifications_level_info': '信息',
    'notifications_level_info_desc': '步数、电量不足等参考性通知\n一般状态信息',
    'notifications_activity_note':
        '※ 如果无法采集步数数据，活动信息可能不会显示。',

    // ── 守护者通知设置 ──
    'notification_settings_title': '通知设置',
    'notification_settings_push': '推送通知',
    'notification_settings_all': '接收全部通知',
    'notification_settings_all_desc': '一键开启或关闭所有类别的通知。',
    'notification_settings_level_section': '按等级设置通知',
    'notification_settings_urgent': '紧急通知',
    'notification_settings_urgent_desc': '紧急通知无法关闭',
    'notification_settings_warning': '警告通知',
    'notification_settings_warning_desc': '连续2天未确认平安时通知',
    'notification_settings_caution': '注意通知',
    'notification_settings_caution_desc': '当天未确认平安时通知',
    'notification_settings_info': '信息通知',
    'notification_settings_info_desc': '步数、电池状态等一般通知',
    'notification_settings_dnd': '免打扰时间设置',
    'notification_settings_dnd_start': '开始时间',
    'notification_settings_dnd_end': '结束时间',
    'notification_settings_dnd_note': '※ 紧急通知在免打扰模式下仍会送达',
    'notification_settings_dnd_start_default': '晚上 10:00',
    'notification_settings_dnd_end_default': '早上 7:00',

    // ── 守护者连接管理 ──
    'connection_title': '连接管理',
    'connection_managed_count': '管理的被守护者人数 ',
    'connection_managed_count_value': '@current / @max 人',
    'connection_connected_subjects': '已连接的被守护者',
    'connection_empty': '没有连接的保护对象',
    'connection_unlink_warning':
        '解除连接后，该被守护者的数据将被删除。',
    'connection_unlink_warning_detail':
        '重新连接后无法恢复之前的记录，\n需要重新输入被守护者的邀请码。',
    'connection_heartbeat_schedule': '每天 @time',
    'connection_heartbeat_report_time': '问安报告时间为 ',
    'connection_subject_label': '被守护者',
    'connection_change_only_in_app': '仅可在应用中更改',
    'connection_edit_title': '编辑被守护者',
    'connection_alias_label': '别名',
    'connection_unlink_title': '解除连接',
    'connection_unlink_confirm': '确定要解除与 @alias 的连接吗？',
    'connection_unlink_success': '已成功解除连接。',
    'connection_unlink_failed': '解除连接失败。',
    'connection_load_failed': '加载列表失败。',

    // ── 守护者底部导航 ──
    'nav_home': '首页',
    'nav_connection': '连接',
    'nav_notification': '通知',
    'nav_settings': '设置',

    // ── Heartbeat 相关 ──
    'heartbeat_schedule_change': '更改问安时间',
    'heartbeat_daily_time': '每天 @time',
    'heartbeat_scheduled_today': '今天 @time 已预约问安。',
    'heartbeat_change_failed_title': '更改时间失败',
    'heartbeat_change_failed_message': '未能同步到服务器。',

    // ── 本地通知 ──
    'local_notification_channel': '问安通知',
    'local_notification_channel_desc': '问安服务通知',

    // ── 其他 ──
    'back_press_exit': '再按一次返回键退出应用。',

    // ── API 错误 ──
    'error_unknown': '发生了未知错误。',
    'error_timeout': '请求超时。',
    'error_network': '请检查网络连接。',
    'error_unauthorized': '需要验证身份。',

    // ── 通知正文 ──
    'noti_auto_report_body': '今天的定时问安已正常收到。',
    'noti_manual_report_body': '对象者手动发送了问安。',
    'noti_battery_low_body': '手机电量低于20%，可能需要充电。',
    'noti_battery_dead_body':
        '手机似乎因电量耗尽而关机。最后电量：@battery_level%。充电后将自动恢复。',
    'noti_caution_suspicious_body':
        '已收到问安信号，但未检测到手机使用痕迹。请亲自确认。',
    'noti_caution_missing_body':
        '今天预定的问安尚未收到。请亲自确认。',
    'noti_warning_body': '问安已连续未收到。请亲自核实。',
    'noti_urgent_body': '已@days天未收到问安。需要立即确认。',
    'noti_steps_body': '@from_time ~ @to_time：走了@steps步。',
    'noti_emergency_body': '被监护人直接请求了帮助。请立即确认。',
    'noti_resolved_body': '已恢复正常。被监护人的健康状况已正常确认。',

    // ── 本地通知 ──
    'local_alarm_title': '📱 需要确认安否',
    'local_alarm_body': '请点击此通知。',
    'wellbeing_check_title': '💛 安否确认',
    'wellbeing_check_body': '您还好吗？请点击此通知。',
    'noti_channel_name': 'Anbu提醒',
  };
}
