abstract class ArSa {
  static const Map<String, String> translations = {
    // ── عام ──
    'common_confirm': 'تأكيد',
    'common_cancel': 'إلغاء',
    'common_continue': 'متابعة',
    'common_save': 'حفظ',
    'common_delete': 'حذف',
    'common_close': 'إغلاق',
    'common_next': 'التالي',
    'common_previous': 'السابق',
    'common_start': 'ابدأ الآن',
    'common_skip': 'تخطي',
    'common_later': 'لاحقاً',
    'common_loading': 'جارٍ التحميل...',
    'common_error': 'خطأ',
    'common_complete': 'تم',
    'common_notice': 'إشعار',
    'common_unlink': 'إلغاء الربط',
    'common_am': 'ص',
    'common_pm': 'م',
    'common_normal': 'طبيعي',
    'common_connected': 'متصل',
    'common_disconnected': 'غير متصل',

    // ── العلامة التجارية ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'نطمئن على سلامتكم.',
    'app_service_desc': 'خدمة الاطمئنان التلقائي على السلامة',
    'app_guardian_title': 'حارس Anbu',
    'app_copyright': '© 2024 TNS Inc.',

    // ── شاشة البداية ──
    'splash_loading': 'جارٍ الاطمئنان...',

    // ── التحديث ──
    'update_required_title': 'التحديث مطلوب',
    'update_required_message':
        'يرجى التحديث إلى الإصدار @version لمتابعة استخدام التطبيق.',
    'update_button': 'تحديث',
    'update_available_title': 'تحديث متوفر',
    'update_available_message': 'الإصدار @version متوفر.',

    // ── اختيار الوضع ──
    'mode_select_title': 'اختر دورك',
    'mode_select_subtitle':
        'يساعدنا هذا في إعداد الميزات المناسبة لك',
    'mode_subject_title': 'أريد أن يُراقب\nسلامتي',
    'mode_subject_button': 'احصل على الحماية ←',
    'mode_guardian_title': 'أريد الاطمئنان على\nشخص عزيز',
    'mode_guardian_button': 'ابدأ كحارس ←',
    'mode_select_notice':
        'ستختلف واجهة التطبيق والإشعارات بناءً على اختيارك',

    // ── الأذونات ──
    'permission_title': 'يحتاج التطبيق إلى\nأذونات للعمل',
    'permission_notification': 'إذن الإشعارات',
    'permission_notification_subject_desc':
        'مطلوب لتلقي إشعارات الاطمئنان على السلامة',
    'permission_notification_guardian_desc':
        'مطلوب لتلقي إشعارات حالة سلامة المتابَعين',
    'permission_activity': 'التعرف على النشاط',
    'permission_activity_desc':
        'يُستخدم لاكتشاف الخطوات والتأكد من النشاط',
    'permission_activity_dialog_title': 'معلومات عن إذن النشاط',
    'permission_activity_dialog_message':
        'يُستخدم لاكتشاف الخطوات والتأكد من النشاط.\nيرجى الضغط على «السماح» في الشاشة التالية.',
    'permission_notification_required_title': 'إذن الإشعارات مطلوب',
    'permission_notification_required_message':
        'يتطلب عمل خدمة الاطمئنان إذن الإشعارات.\nيرجى تفعيله من الإعدادات.',
    'permission_go_to_settings': 'الذهاب إلى الإعدادات',

    // ── التهيئة الأولية ──
    'onboarding_title_1': 'هل تقلق على شخص\nعزيز يعيش بمفرده؟',
    'onboarding_desc_1':
        'حتى من بعيد،\nتتساءل هل هو بخير.\nAnbu معك.',
    'onboarding_title_2': 'الاطمئنان\nدون كلمة واحدة',
    'onboarding_desc_2':
        'بمجرد استخدام الهاتف الذكي،\nيُرسل إشعار يومي تلقائي\nعن السلامة.',
    'onboarding_title_3': 'شارك الاطمئنان\nمع أحبائك',
    'onboarding_desc_3':
        'الاطمئنان اليومي يتراكم\nليصبح طمأنينة دائمة.\nابدأ الآن.',
    'onboarding_title_4': 'لا أسماء ولا أرقام هواتف\n— لا نجمع شيئاً',
    'onboarding_desc_4':
        'نُرسل إشارة واحدة فقط:\n«أنا بخير.»\nمعلوماتك في أمان.',
    'onboarding_role_subject': 'متابَع',
    'onboarding_role_guardian': 'حارس',
    'onboarding_already_registered_title': 'الجهاز مسجل بالفعل',
    'onboarding_already_registered_message':
        'هذا الجهاز مسجل بالفعل في وضع "@roleLabel".\nهل تريد المتابعة كـ "@roleLabel"؟\n\nأم التبديل إلى وضع "@newRoleLabel"؟\nسيؤدي التبديل إلى حذف جميع البيانات.',
    'onboarding_registration_failed_title': 'فشل التسجيل',
    'onboarding_registration_failed_message':
        'تعذر الاتصال بالخادم. يرجى المحاولة لاحقاً.',

    // ── الصفحة الرئيسية للمتابَع ──
    'subject_home_share_title': 'شارك رمز السلامة الخاص بك',
    'subject_home_guardian_count': 'الحراس المتصلون: @count',
    'subject_home_check_title_last': 'آخر اطمئنان',
    'subject_home_check_title_scheduled': 'وقت الاطمئنان المقرر',
    'subject_home_check_title_checking': 'جارٍ الاطمئنان',
    'subject_home_check_body_reported': 'تم الإبلاغ في @time',
    'subject_home_check_body_scheduled': 'مقرر في @time',
    'subject_home_check_body_waiting': 'في الانتظار منذ @time',
    'subject_home_battery_status': 'حالة البطارية',
    'subject_home_battery_charging': 'قيد الشحن',
    'subject_home_battery_full': 'مشحونة بالكامل',
    'subject_home_battery_low': 'بطارية منخفضة',
    'subject_home_connectivity_status': 'حالة الاتصال',
    'subject_home_report_loading': 'جارٍ الإبلاغ...',
    'subject_home_report_button': 'أبلغ عن سلامتك الآن',
    'subject_home_report_desc': 'أخبر حارسك أنك بخير',
    'subject_home_emergency_button': 'أحتاج مساعدة',
    'subject_home_emergency_desc': 'يرسل تنبيه طوارئ إلى الأوصياء',
    'subject_home_emergency_loading': 'جاري إرسال تنبيه الطوارئ...',
    'subject_home_emergency_sent': 'تم إرسال تنبيه الطوارئ',
    'subject_home_emergency_failed': 'فشل إرسال تنبيه الطوارئ',
    'subject_home_emergency_confirm_title': 'طلب مساعدة طارئة',
    'subject_home_emergency_confirm_body': 'سيتم إرسال تنبيه طوارئ إلى جميع الأوصياء.\nهل أنت متأكد من طلب المساعدة؟',
    'subject_home_emergency_confirm_send': 'إرسال طلب الطوارئ',
    'subject_home_share_text':
        'اطمئن عليّ من خلال تطبيق Anbu!\nرمز الدعوة: @code',
    'subject_home_share_subject': 'رمز دعوة Anbu',
    'subject_home_code_copied': 'تم نسخ الرمز',

    // ── القائمة الجانبية للمتابَع ──
    'drawer_light_mode': 'الوضع الفاتح',
    'drawer_dark_mode': 'الوضع الداكن',
    'drawer_privacy_policy': 'سياسة الخصوصية',
    'drawer_terms': 'شروط الاستخدام',
    'drawer_withdraw': 'حذف الحساب',
    'drawer_withdraw_message':
        'سيتم حذف حسابك وجميع بياناتك.\nهل أنت متأكد؟',

    // ── لوحة الحارس ──
    'guardian_status_normal': 'طبيعي',
    'guardian_status_caution': 'تنبيه',
    'guardian_status_warning': 'تحذير',
    'guardian_status_urgent': 'عاجل',
    'guardian_status_confirmed': 'تم تأكيد السلامة',
    'guardian_subscription_expired': 'انتهى الاشتراك',
    'guardian_subscription_expired_message':
        'لا يتم إرسال إشعارات التنبيه.\nجدّد اشتراكك لمواصلة خدمة الحماية.',
    'guardian_subscribe': 'اشترك',
    'guardian_payment_preparing': 'ميزة الدفع قيد الإعداد.',
    'guardian_today_summary': 'ملخص اليوم',
    'guardian_no_subjects': 'لا يوجد متابَعون متصلون.',
    'guardian_checking_subjects':
        'يتم حالياً متابعة\n@count شخص/أشخاص.',
    'guardian_subject_list': 'قائمة المتابَعين',
    'guardian_call_now': 'اتصل الآن',
    'guardian_confirm_safety': 'تأكيد السلامة',
    'guardian_no_check_history': 'لا يوجد سجل اطمئنان',
    'guardian_last_check_now': 'آخر اطمئنان: الآن',
    'guardian_last_check_minutes': 'آخر اطمئنان: منذ @minutes دقيقة',
    'guardian_last_check_hours': 'آخر اطمئنان: منذ @hours ساعة',
    'guardian_last_check_days': 'آخر اطمئنان: منذ @days يوم',
    'guardian_activity_stable': 'النشاط: مستقر',
    'guardian_safety_needed': 'مطلوب التحقق من السلامة',
    'guardian_error_load_subjects': 'تعذر تحميل قائمة المتابَعين.',
    'guardian_error_clear_alerts': 'تعذر مسح التنبيهات.',

    // ── إضافة متابَع ──
    'add_subject_title': 'ربط متابَع',
    'add_subject_guide_title':
        'أدخل الرمز الفريد للمتابَع وحدد اسماً له.',
    'add_subject_guide_subtitle':
        'اربط تطبيق المتابَع لمراقبة حالته الصحية ونشاطه.',
    'add_subject_code_label': 'الرمز الفريد (7 أحرف)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info':
        'يمكن العثور على الرمز الفريد في تطبيق المتابَع.',
    'add_subject_alias_label': 'اسم المتابَع',
    'add_subject_alias_hint': 'مثال: أمي، أبي',
    'add_subject_connect': 'ربط',
    'add_subject_error_login': 'تسجيل الدخول مطلوب.',
    'add_subject_success': 'تم ربط المتابَع بنجاح.',
    'add_subject_error_invalid_code': 'رمز غير صالح.',
    'add_subject_error_already_connected': 'مرتبط بالفعل.',
    'add_subject_error_failed': 'فشل الربط. يرجى المحاولة لاحقاً.',
    'add_subject_button': 'إضافة متابَع جديد',

    // ── إعدادات الحارس ──
    'settings_title': 'الإعدادات',
    'settings_light_mode': 'الوضع الفاتح',
    'settings_dark_mode': 'الوضع الداكن',
    'settings_connection_management': 'إدارة الاتصالات',
    'settings_managed_subjects': 'عدد المتابَعين',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'الاشتراك والخدمة',
    'settings_current_membership': 'العضوية الحالية',
    'settings_premium': 'اشتراك مميز نشط',
    'settings_free_trial': 'فترة تجريبية مجانية',
    'settings_manage_subscription': 'إدارة الاشتراك',
    'settings_notification': 'إعدادات الإشعارات',
    'settings_terms_section': 'قانوني',
    'settings_privacy_policy': 'سياسة الخصوصية',
    'settings_terms': 'شروط الاستخدام',
    'settings_app_version': 'الإصدار: v@version',

    // ── إشعارات الحارس ──
    'notifications_title': 'الإشعارات',
    'notifications_today': 'إشعارات اليوم',
    'notifications_empty': 'لا توجد إشعارات اليوم',
    'notifications_delete_all_title': 'حذف جميع الإشعارات',
    'notifications_delete_all_message': 'هل تريد حذف جميع إشعارات اليوم؟',
    'notifications_delete_failed': 'تعذر حذف الإشعارات.',
    'notifications_guide_title': 'دليل مستويات الإشعارات',
    'notifications_level_health': 'طبيعي',
    'notifications_level_health_desc':
        'تم التأكد من سلامة المتابَع بشكل طبيعي',
    'notifications_level_caution': 'تنبيه',
    'notifications_level_caution_desc':
        'أحد الأسباب التالية:\n1. لم يتم تلقي اطمئنان اليوم المقرر\n2. تم تلقي الاطمئنان لكن لم يُكتشف استخدام للهاتف',
    'notifications_level_warning': 'تحذير',
    'notifications_level_warning_desc':
        'أحد الأسباب التالية:\n1. لا اطمئنان لمدة يومين متتاليين\n2. لا استخدام للهاتف لمدة يومين متتاليين',
    'notifications_level_urgent': 'عاجل',
    'notifications_level_urgent_desc':
        'غياب الاطمئنان لفترة طويلة\nأو عدم استخدام الهاتف لأكثر من 3 أيام',
    'notifications_level_info': 'معلومات',
    'notifications_level_info_desc':
        'إشعارات مرجعية مثل عدد الخطوات\nأو انخفاض البطارية',
    'notifications_activity_note':
        '※ قد لا تظهر معلومات النشاط إذا تعذر جمع بيانات الخطوات.',

    // ── إعدادات إشعارات الحارس ──
    'notification_settings_title': 'إعدادات الإشعارات',
    'notification_settings_push': 'الإشعارات الفورية',
    'notification_settings_all': 'جميع الإشعارات',
    'notification_settings_all_desc':
        'تفعيل أو تعطيل جميع فئات الإشعارات دفعة واحدة.',
    'notification_settings_level_section': 'إعدادات المستويات',
    'notification_settings_urgent': 'تنبيهات عاجلة',
    'notification_settings_urgent_desc':
        'لا يمكن تعطيل التنبيهات العاجلة',
    'notification_settings_warning': 'تنبيهات تحذيرية',
    'notification_settings_warning_desc':
        'تنبيه عند غياب الاطمئنان لمدة يومين متتاليين',
    'notification_settings_caution': 'تنبيهات انتباه',
    'notification_settings_caution_desc':
        'تنبيه عند غياب اطمئنان اليوم',
    'notification_settings_info': 'إشعارات معلوماتية',
    'notification_settings_info_desc':
        'إشعارات عامة مثل الخطوات وحالة البطارية',
    'notification_settings_dnd': 'وضع عدم الإزعاج',
    'notification_settings_dnd_start': 'وقت البداية',
    'notification_settings_dnd_end': 'وقت النهاية',
    'notification_settings_dnd_note':
        '※ التنبيهات العاجلة تصل حتى أثناء وضع عدم الإزعاج',
    'notification_settings_dnd_start_default': '10:00 م',
    'notification_settings_dnd_end_default': '7:00 ص',

    // ── إدارة اتصالات الحارس ──
    'connection_title': 'إدارة الاتصالات',
    'connection_managed_count': 'عدد المتابَعين ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'المتابَعون المتصلون',
    'connection_empty': 'لا يوجد أشخاص محميون متصلون',
    'connection_unlink_warning':
        'سيؤدي إلغاء الربط إلى حذف بيانات المتابَع.',
    'connection_unlink_warning_detail':
        'لا يمكن استعادة السجلات السابقة بعد إعادة الربط.\nسيتعين عليك إدخال رمز المتابَع مرة أخرى.',
    'connection_heartbeat_schedule': 'يومياً في @time',
    'connection_heartbeat_report_time': 'وقت تقرير الاطمئنان هو ',
    'connection_subject_label': 'متابَع',
    'connection_change_only_in_app': 'يمكن تغييره فقط من التطبيق',
    'connection_edit_title': 'تعديل المتابَع',
    'connection_alias_label': 'الاسم',
    'connection_unlink_title': 'إلغاء الربط',
    'connection_unlink_confirm': 'إلغاء ربط @alias؟',
    'connection_unlink_success': 'تم إلغاء الربط بنجاح.',
    'connection_unlink_failed': 'تعذر إلغاء الربط.',
    'connection_load_failed': 'تعذر تحميل القائمة.',

    // ── شريط التنقل السفلي ──
    'nav_home': 'الرئيسية',
    'nav_connection': 'الاتصال',
    'nav_notification': 'التنبيهات',
    'nav_settings': 'الإعدادات',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'تغيير وقت الاطمئنان',
    'heartbeat_daily_time': 'يومياً في @time',
    'heartbeat_scheduled_today': 'تم جدولة الاطمئنان اليوم في @time.',
    'heartbeat_change_failed_title': 'فشل تغيير الوقت',
    'heartbeat_change_failed_message': 'تعذر التحديث على الخادم.',

    // ── الإشعارات المحلية ──
    'local_notification_channel': 'إشعارات الاطمئنان',
    'local_notification_channel_desc': 'إشعارات خدمة الاطمئنان على السلامة',

    // ── متنوع ──
    'back_press_exit': 'اضغط رجوع مرة أخرى للخروج.',

    // ── أخطاء API ──
    'error_unknown': 'حدث خطأ غير معروف.',
    'error_timeout': 'انتهت مهلة الطلب.',
    'error_network': 'يرجى التحقق من اتصالك بالشبكة.',
    'error_unauthorized': 'المصادقة مطلوبة.',

    // ── نصوص الإشعارات ──
    'noti_auto_report_body':
        'تم استلام فحص الاطمئنان المجدول اليوم.',
    'noti_manual_report_body':
        'قام الشخص المحمي بإرسال فحص اطمئنان يدوي.',
    'noti_battery_low_body':
        'بطارية الهاتف أقل من 20%. قد يحتاج إلى الشحن.',
    'noti_battery_dead_body':
        'يبدو أن الهاتف قد انطفأ بسبب نفاد البطارية. آخر مستوى للبطارية: @battery_level%. سيتعافى بعد الشحن.',
    'noti_caution_suspicious_body':
        'تم استلام إشارة اطمئنان، لكن لا توجد علامات على استخدام الهاتف. يرجى التحقق شخصياً.',
    'noti_caution_missing_body':
        'لم يتم استلام فحص الاطمئنان المجدول لليوم بعد. يرجى التحقق شخصياً.',
    'noti_warning_body':
        'تم تفويت فحوصات الاطمئنان بشكل متتالٍ. يرجى التحقق شخصياً.',
    'noti_urgent_body':
        'لا يوجد فحص اطمئنان منذ @days يوم/أيام. التحقق الفوري مطلوب.',
    'noti_steps_body':
        '@from_time ~ @to_time: @steps خطوة.',
    'noti_emergency_body': 'طلب الشخص المحمي المساعدة مباشرة. يرجى التحقق فوراً.',
    'noti_resolved_body': 'عاد فحص سلامة الشخص المحمي إلى الوضع الطبيعي.',
    'noti_cleared_by_guardian_title': '✅ تم تأكيد السلامة',
    'noti_cleared_by_guardian_body': 'أحد الأوصياء تحقق شخصياً من سلامة الشخص المحمي.',

    // ── الإشعارات المحلية ──
    'local_alarm_title': '📱 يلزم التحقق من السلامة',
    'local_alarm_body': 'يرجى الضغط على هذا الإشعار.',
    'wellbeing_check_title': '💛 التحقق من السلامة',
    'wellbeing_check_body':
        'هل أنت بخير؟ يرجى الضغط على هذا الإشعار.',
    'noti_channel_name': 'تنبيهات Anbu',
  };
}
