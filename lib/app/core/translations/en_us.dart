abstract class EnUs {
  static const Map<String, String> translations = {
    // ── Common ──
    'common_confirm': 'Confirm',
    'common_cancel': 'Cancel',
    'common_continue': 'Continue',
    'common_save': 'Save',
    'common_delete': 'Delete',
    'common_close': 'Close',
    'common_next': 'Next',
    'common_previous': 'Previous',
    'common_start': 'Get Started',
    'common_skip': 'Skip',
    'common_later': 'Later',
    'common_loading': 'Loading...',
    'common_error': 'Error',
    'common_complete': 'Done',
    'common_notice': 'Notice',
    'common_unlink': 'Unlink',
    'common_am': 'AM',
    'common_pm': 'PM',
    'common_normal': 'Normal',
    'common_connected': 'Connected',
    'common_disconnected': 'Disconnected',

    // ── App Brand ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Checking your wellbeing.',
    'app_service_desc': 'Automatic wellness check service',
    'app_guardian_title': 'Anbu Guardian',
    'app_copyright': '© 2024 Averic SB Inc.',

    // ── Splash ──
    'splash_loading': 'Checking in...',

    // ── Update ──
    'update_required_title': 'Update Required',
    'update_required_message': 'Please update to version @version to continue using the app.',
    'update_button': 'Update',
    'update_available_title': 'Update Available',
    'update_available_message': 'Version @version is available.',

    // ── Mode Select ──
    'mode_select_title': 'Choose your role',
    'mode_select_subtitle': 'This helps us set up the right features for you',
    'mode_subject_title': 'I want my safety\nto be monitored',
    'mode_subject_button': 'Be protected →',
    'mode_guardian_title': 'I want to watch over\nsomeone I care about',
    'mode_guardian_button': 'Start as guardian →',
    'mode_select_notice': 'Screen layout and notifications will differ based on your choice',

    // ── Permission ──
    'permission_title': 'Permissions needed\nto use the app',
    'permission_notification': 'Notification Permission',
    'permission_notification_subject_desc': 'Required to receive wellness check alerts',
    'permission_notification_guardian_desc':
        'Required to receive safety status alerts for your subjects',
    'permission_activity': 'Activity Recognition',
    'permission_activity_desc': 'Used to detect steps and confirm activity',
    'permission_activity_dialog_title': 'Activity Permission Info',
    'permission_activity_dialog_message':
        'Used to detect steps and confirm activity.\nPlease tap "Allow" on the next screen.',
    'permission_notification_required_title': 'Notification Permission Required',
    'permission_notification_required_message':
        'Notification permission is required for the wellness check service.\nPlease enable it in Settings.',
    'permission_go_to_settings': 'Go to Settings',
    'permission_activity_denied_title': 'Physical Activity Permission Required',
    'permission_activity_denied_message':
        'This is used to detect steps and improve wellness check accuracy.\nPlease enable physical activity permission in Settings.',
    'permission_battery': 'Battery Optimization Exclusion',
    'permission_battery_desc':
        'Excludes the app from battery optimization so that daily wellness checks are not missed at the scheduled time',
    'permission_battery_required_title': 'Please set Battery to "Unrestricted"',
    'permission_battery_required_message':
        'If set to "Battery Optimized" or "Battery Saver", daily wellness checks may be delayed or missed.\n\nAfter tapping [Go to Settings]:\n1. Select "Battery"\n2. Change it to "Unrestricted"',
    'permission_battery_go_to_settings': 'Go to Settings',
    'permission_hibernation_title': 'Please turn off "Pause app activity if unused"',
    'permission_hibernation_highlight': 'Pause app activity if unused',
    'permission_hibernation_message':
        'If you don\'t open the app for several months, Android may automatically stop it and interrupt wellness checks.\n\nTap [Open App Settings], then find and turn off "Pause app activity if unused".',
    'permission_hibernation_go_to_settings': 'Open App Settings',

    // ── Onboarding ──
    'onboarding_title_1': 'Worried about someone\nliving alone?',
    'onboarding_desc_1':
        'Even from far away,\nyou wonder if they\'re okay.\nAnbu is here with you.',
    'onboarding_title_2': 'Wellness checks\nwithout a single word',
    'onboarding_desc_2':
        'Just by using their smartphone,\na daily wellness signal\nis sent automatically.',
    'onboarding_title_3': 'Share wellness\nwith your loved ones',
    'onboarding_desc_3':
        'Daily check-ins build up\ninto lasting peace of mind.\nLet\'s get started.',
    'onboarding_title_4': 'No names, no phone numbers\n— nothing collected',
    'onboarding_desc_4':
        'Only one signal is delivered:\n"I\'m doing fine."\nYour information stays safe.',
    'onboarding_role_subject': 'Subject',
    'onboarding_role_guardian': 'Guardian',
    'onboarding_role_guardian_subject': 'Guardian & Subject',
    'onboarding_already_registered_title': 'Device Already Registered',
    'onboarding_already_registered_message':
        'This device is already registered in "@roleLabel" mode.\nContinue as "@roleLabel"?\n\nOr switch to "@newRoleLabel" mode?\nSwitching will delete all existing data.',
    'onboarding_already_registered_message_gs':
        'This device is already registered in "@roleLabel" mode.\nSwitching to "@newRoleLabel" mode will delete both guardian and subject data.',
    'onboarding_registration_failed_title': 'Registration Failed',
    'onboarding_registration_failed_message': 'Cannot connect to server. Please try again later.',

    // ── Subject Home ──
    'subject_home_share_title': 'Share your safety code',
    'subject_home_guardian_count': 'Connected guardians: @count',
    'subject_home_check_title_last': 'Last wellness check',
    'subject_home_check_title_scheduled': 'Scheduled check time',
    'subject_home_check_title_checking': 'Checking wellness',
    'subject_home_check_body_reported': 'Reported at @time',
    'subject_home_check_body_scheduled': 'Scheduled at @time',
    'subject_home_check_body_waiting': 'Waiting since @time',
    'subject_home_battery_status': 'Battery Status',
    'subject_home_battery_charging': 'Charging',
    'subject_home_battery_full': 'Full',
    'subject_home_battery_low': 'Low Battery',
    'subject_home_connectivity_status': 'Connectivity',
    'subject_home_report_loading': 'Reporting...',
    'subject_home_report_button': 'Report Safety Now',
    'subject_home_report_desc': 'Let your guardian know you\'re okay',
    'subject_home_emergency_button': 'I need help',
    'subject_home_emergency_desc': 'Sends an emergency alert to your guardians',
    'subject_home_emergency_loading': 'Sending emergency alert...',
    'subject_home_emergency_sent': 'Emergency alert has been sent',
    'subject_home_emergency_failed': 'Failed to send emergency alert',
    'subject_home_emergency_confirm_title': 'Emergency Help Request',
    'subject_home_emergency_confirm_body':
        'An emergency alert will be sent to all your guardians.\nAre you sure you want to request help?',
    'subject_home_emergency_confirm_send': 'Send Emergency Request',
    'subject_home_share_text': 'Check on me with the Anbu app!\nInvite code: @code',
    'subject_home_share_subject': 'Anbu Invite Code',
    'subject_home_code_copied': 'Code copied',

    // ── Subject Drawer ──
    'drawer_light_mode': 'Light Mode',
    'drawer_dark_mode': 'Dark Mode',
    'drawer_privacy_policy': 'Privacy Policy',
    'drawer_terms': 'Terms of Service',
    'drawer_withdraw': 'Delete Account',
    'drawer_withdraw_message': 'Your account and all data will be deleted.\nAre you sure?',

    // ── Guardian Dashboard ──
    'guardian_status_normal': 'Normal',
    'guardian_status_caution': 'Caution',
    'guardian_status_warning': 'Warning',
    'guardian_status_urgent': 'Urgent',
    'guardian_status_confirmed': 'Safety Confirmed',
    'guardian_subscription_expired': 'Subscription expired',
    'guardian_subscription_expired_message':
        'Alert notifications are not being sent.\nRenew your subscription to continue protection.',
    'guardian_subscribe': 'Subscribe',
    'guardian_payment_preparing': 'Payment feature coming soon.',
    'guardian_today_summary': 'Today\'s Wellness Summary',
    'guardian_no_subjects': 'No subjects connected.',
    'guardian_checking_subjects': 'Currently checking on\n@count subject(s).',
    'guardian_subject_list': 'Subject List',
    'guardian_call_now': 'Call Now',
    'guardian_confirm_safety': 'Confirm Safety',
    'guardian_no_check_history': 'No check history',
    'guardian_last_check_now': 'Last check: just now',
    'guardian_last_check_minutes': 'Last check: @minutes min ago',
    'guardian_last_check_hours': 'Last check: @hours hr ago',
    'guardian_last_check_days': 'Last check: @days day(s) ago',
    'guardian_activity_stable': 'Activity: Stable',
    'guardian_safety_needed': 'Safety check needed',
    'guardian_error_load_subjects': 'Failed to load subjects.',
    'guardian_error_clear_alerts': 'Failed to clear alerts.',

    // ── Guardian Add Subject ──
    'add_subject_title': 'Link Subject',
    'add_subject_guide_title': 'Enter the subject\'s unique code and an alias.',
    'add_subject_guide_subtitle':
        'Link a subject\'s app to monitor their health and activity in real-time.',
    'add_subject_code_label': 'Unique Code (7 digits)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info': 'The unique code can be found in the subject\'s app.',
    'add_subject_alias_label': 'Subject Alias',
    'add_subject_alias_hint': 'e.g., Mom, Dad',
    'add_subject_connect': 'Connect',
    'add_subject_error_login': 'Login required.',
    'add_subject_success': 'Subject connected successfully.',
    'add_subject_error_invalid_code': 'Invalid code.',
    'add_subject_error_already_connected': 'Already connected.',
    'add_subject_error_failed': 'Connection failed. Please try again.',
    'add_subject_button': 'Add New Subject',

    // ── Guardian Settings ──
    'settings_title': 'Settings',
    'settings_light_mode': 'Light Mode',
    'settings_dark_mode': 'Dark Mode',
    'settings_connection_management': 'Connection Management',
    'settings_managed_subjects': 'Managed Subjects',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'Subscription & Service',
    'settings_current_membership': 'Current Membership',
    'settings_premium': 'Premium Active',
    'settings_free_trial': 'Free Trial',
    'settings_days_remaining': '@days days left',
    'settings_manage_subscription': 'Manage Subscription',
    'settings_notification': 'Notification Settings',
    'settings_terms_section': 'Legal',
    'settings_privacy_policy': 'Privacy Policy',
    'settings_terms': 'Terms of Service',
    'settings_app_version': 'Version: v@version',

    // ── G+S (Guardian + Subject) ──
    'gs_enable_button': 'Get Wellness Protection Too',
    'gs_safety_code_button': 'Check My Safety Code',
    'gs_safety_code_title': 'My Safety Code',
    'gs_enable_dialog_title': 'Enable Wellness Protection',
    'gs_enable_dialog_body':
        'You can receive wellness protection while keeping your guardian features.\nA safety code will be issued — please share it with other guardians.',
    'gs_enable_dialog_ios_warning_title': '⚠ iOS works differently from Android',
    'gs_enable_dialog_ios_warning_body':
        'On iOS, a "wellness push notification" appears every day at the scheduled time. You must tap the notification or open the app yourself around that time for your wellness signal to be sent. If you do not open the app, your guardians may receive a missed-check alert.',
    'gs_enable_dialog_ios_confirm': 'I understand, enable',
    'gs_enable_confirm': 'Enable',
    'gs_enabled_message': 'Wellness protection has been enabled',
    'gs_enable_failed': 'Failed to enable wellness protection',
    'gs_disable_dialog_title': 'Disable Wellness Protection',
    'gs_disable_dialog_body':
        'Disabling wellness protection will delete your safety code and stop sending wellness checks to connected guardians.',
    'gs_disable_confirm': 'Disable',
    'gs_disabled_message': 'Wellness protection has been disabled',
    'gs_disable_failed': 'Failed to disable wellness protection',

    // ── Guardian Notifications ──
    'notifications_title': 'Notifications',
    'notifications_today': 'Today\'s Notifications',
    'notifications_empty': 'No notifications today',
    'notifications_delete_all_title': 'Delete All Notifications',
    'notifications_delete_all_message': 'Delete all today\'s notifications?',
    'notifications_delete_failed': 'Failed to delete notifications.',
    'notifications_guide_title': 'Notification Level Guide',
    'notifications_level_health': 'Normal',
    'notifications_level_health_desc': 'Subject\'s wellness confirmed normally',
    'notifications_level_caution': 'Caution',
    'notifications_level_caution_desc': 'No wellness signal today yet',
    'notifications_level_warning': 'Warning',
    'notifications_level_warning_desc': 'No wellness confirmation for multiple days',
    'notifications_level_urgent': 'Urgent',
    'notifications_level_urgent_desc': 'Immediate check needed now',
    'notifications_level_info': 'Info',
    'notifications_level_info_desc': 'Steps, low battery, and other reference alerts',
    'notifications_activity_note':
        '※ Activity info may not be shown if step data could not be collected.',

    // ── Guardian Notification Settings ──
    'notification_settings_title': 'Notification Settings',
    'notification_settings_push': 'Push Notifications',
    'notification_settings_all': 'All Notifications',
    'notification_settings_all_desc': 'Enable or disable all notification categories at once.',
    'notification_settings_level_section': 'Level Settings',
    'notification_settings_urgent': 'Urgent Alerts',
    'notification_settings_urgent_desc': 'Urgent alerts cannot be disabled',
    'notification_settings_warning': 'Warning Alerts',
    'notification_settings_warning_desc': 'Alert when no check for 2 consecutive days',
    'notification_settings_caution': 'Caution Alerts',
    'notification_settings_caution_desc': 'Alert when today\'s check is missing',
    'notification_settings_info': 'Info Alerts',
    'notification_settings_info_desc': 'General alerts like step count and battery status',
    'notification_settings_dnd': 'Do Not Disturb',
    'notification_settings_dnd_start': 'Start Time',
    'notification_settings_dnd_end': 'End Time',
    'notification_settings_dnd_note': '※ Urgent alerts are delivered even during DND',
    'notification_settings_dnd_start_default': '10:00 PM',
    'notification_settings_dnd_end_default': '7:00 AM',

    // ── Guardian Connection Management ──
    'connection_title': 'Connection Management',
    'connection_managed_count': 'Managed Subjects ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Connected Subjects',
    'connection_empty': 'No connected subjects',
    'connection_unlink_warning': 'Unlinking will delete the subject\'s data.',
    'connection_unlink_warning_detail':
        'Previous records cannot be recovered after relinking. You will need to re-enter the subject\'s code.',
    'connection_heartbeat_schedule': 'Daily at @time',
    'connection_heartbeat_report_time': 'Wellness report time is ',
    'connection_subject_label': 'Subject',
    'connection_change_only_in_app': 'can only be changed in the app',
    'connection_edit_title': 'Edit Subject',
    'connection_alias_label': 'Alias',
    'connection_unlink_title': 'Unlink',
    'connection_unlink_confirm': 'Unlink @alias?',
    'connection_unlink_success': 'Unlinked successfully.',
    'connection_unlink_failed': 'Failed to unlink.',
    'connection_load_failed': 'Failed to load list.',

    // ── Guardian Bottom Navigation ──
    'nav_home': 'Home',
    'nav_connection': 'Connect',
    'nav_notification': 'Alerts',
    'nav_settings': 'Settings',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'Change Check Time',
    'heartbeat_schedule_title_ios': 'Wellness Push Time',
    'heartbeat_schedule_change_title_ios': 'Change Wellness Push Time',
    'heartbeat_schedule_hint_ios':
        'A wellness push notification arrives at this time every day. Tap the notification or open the app around then to send your wellness signal.',
    'heartbeat_daily_time': 'Daily at @time',
    'heartbeat_scheduled_today': 'Wellness check scheduled at @time today.',
    'heartbeat_change_failed_title': 'Time Change Failed',
    'heartbeat_change_failed_message': 'Could not update on server.',

    // ── Local Notifications ──
    'local_notification_channel': 'Wellness Alerts',
    'local_notification_channel_desc': 'Wellness check service notifications',

    // ── Misc ──
    'back_press_exit': 'Press back again to exit.',

    // ── API Errors ──
    'error_unknown': 'An unknown error occurred.',
    'error_timeout': 'Request timed out.',
    'error_network': 'Please check your network connection.',
    'error_unauthorized': 'Authentication required.',

    // ── Notification Bodies ──
    'noti_auto_report_body': 'Scheduled wellness check was received today.',
    'noti_manual_report_body': 'The subject sent a manual wellness check.',
    'noti_battery_low_body': 'Phone battery is below 20%. Charging may be needed.',
    'noti_battery_dead_body':
        'Phone appears to have shut down due to a dead battery. Last battery level: @battery_level%. It will recover after charging.',
    'noti_caution_suspicious_body':
        'A wellness signal was received, but there are no signs of phone usage. Please check in person.',
    'noti_caution_missing_body':
        "Today's scheduled wellness check has not been received yet. Please check in person.",
    'noti_warning_body': 'Wellness checks have been missed consecutively. Please verify in person.',
    'noti_urgent_body': 'No wellness check for @days day(s). Immediate verification is required.',
    'noti_steps_body': '@from_time ~ @to_time: @steps steps walked.',
    'noti_emergency_body': 'The subject has directly requested help. Please check immediately.',
    'noti_resolved_body': 'The subject\'s wellness check has returned to normal.',
    'noti_cleared_by_guardian_title': '✅ Wellness Check Confirmed',
    'noti_cleared_by_guardian_body':
        'One of the guardians has personally confirmed the subject\'s safety.',

    // ── Local Notifications ──
    'local_alarm_title': '💗 Wellness check needed',
    'local_alarm_body': 'Please tap this notification.',
    'wellbeing_check_title': '💛 Wellness Check',
    'wellbeing_check_body': 'Are you doing well? Please tap this notification.',
    'noti_channel_name': 'Anbu Alerts',
  };
}
