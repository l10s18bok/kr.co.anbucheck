abstract class EnUs {
  static const Map<String, String> translations = {
    // Common
    '확인': 'Confirm',
    '취소': 'Cancel',
    '저장': 'Save',
    '삭제': 'Delete',
    '닫기': 'Close',
    '로딩중': 'Loading...',
    '다음': 'Next',
    '이전': 'Previous',
    '시작하기': 'Get Started',
    '건너뛰기': 'Skip',

    // App
    'app_name': 'Anbu',
    'app_tagline': 'Check on your loved ones',

    // Splash
    'splash_loading': 'Checking in...',

    // Mode Select
    'mode_select_title': 'Welcome to\nAnbu',
    'mode_select_subtitle': 'How would you like to use the app?',
    'mode_subject': 'I want my safety\nto be monitored',
    'mode_subject_desc': 'Daily automatic survival\ncheck will be sent',
    'mode_guardian': 'I want to watch over\nsomeone I care about',
    'mode_guardian_desc': 'Monitor the safety status\nof your loved ones in real-time',
    'mode_select_notice': 'Mode cannot be changed later',

    // Permission
    'permission_title': 'Permissions needed\nto use the app',
    'permission_notification': 'Notification Permission',
    'permission_notification_desc': 'Required to receive survival check\nresults and emergency alerts',
    'permission_allow': 'Allow Permissions',

    // Subject Onboarding (4 steps: Empathy → Solution → Connection → Trust)
    'onboarding_title_1': 'Worried about someone\nliving alone?',
    'onboarding_desc_1': 'Even from far away,\nyou wonder if they\'re okay.\nAnbu is here with you.',
    'onboarding_title_2': 'Wellness checks\nwithout a single word',
    'onboarding_desc_2': 'Just by using their smartphone,\na daily wellness signal\nis sent automatically.',
    'onboarding_title_3': 'Share wellness\nwith your loved ones',
    'onboarding_desc_3': 'Daily check-ins build up\ninto lasting peace of mind.\nLet\'s get started.',
    'onboarding_title_4': 'No names, no phone numbers\n— nothing collected',
    'onboarding_desc_4': 'Only one signal is delivered:\n"I\'m doing fine."\nYour information stays safe.',

    // Subject Home
    'subject_home_greeting': 'Hello, good day',
    'subject_home_status_ok': 'Operating normally',
    'subject_home_status_pending': 'Awaiting check',
    'subject_home_last_heartbeat': 'Last check-in sent',
    'subject_home_next_heartbeat': 'Next check-in',
    'subject_home_invite_code': 'Unique Code',
    'subject_home_invite_code_desc': 'Share this code with your guardian',
    'subject_home_copy_code': 'Copy Code',
    'subject_home_code_copied': 'Code copied',
    'subject_home_guardian_count': 'Connected guardians : @count',

    // Guardian Dashboard
    'guardian_dashboard_title': 'Dashboard',
    'guardian_dashboard_empty': 'No subjects connected yet',
    'guardian_dashboard_add': 'Add Subject',
    'guardian_dashboard_status_normal': 'Normal',
    'guardian_dashboard_status_caution': 'Caution',
    'guardian_dashboard_status_warning': 'Warning',
    'guardian_dashboard_status_urgent': 'Urgent',
    'guardian_add_subject_title': 'Add Subject',
    'guardian_add_subject_code_hint': 'Enter unique code',
    'guardian_add_subject_alias_hint': 'Enter alias (e.g., Mom)',
    'guardian_add_subject_connect': 'Connect',

    // Settings
    'settings_title': 'Settings',
    'settings_heartbeat_time': 'Heartbeat Time',
    'settings_notification': 'Notification Settings',
    'settings_subscription': 'Manage Subscription',
    'settings_restore': 'Restore Subscription',
    'settings_app_version': 'App Version',

    // API Errors
    '알수없는 에러': 'An unknown error occurred.',
    '타임아웃 에러': 'Request timed out.',
    '연결 에러': 'Please check your network connection.',
    '비승인 사용자': 'Authentication required.',
  };
}
