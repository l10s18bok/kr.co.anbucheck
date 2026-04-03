abstract class KoKr {
  static const Map<String, String> translations = {
    // 공통
    '확인': '확인',
    '취소': '취소',
    '저장': '저장',
    '삭제': '삭제',
    '닫기': '닫기',
    '로딩중': '로딩중...',
    '다음': '다음',
    '이전': '이전',
    '시작하기': '시작하기',
    '건너뛰기': '건너뛰기',

    // 앱
    'app_name': '안부',
    'app_tagline': '소중한 사람의 안부를 확인하세요',

    // 스플래시
    'splash_loading': '안부를 확인하는 중...',

    // 모드 선택
    'mode_select_title': '안부에 오신 것을\n환영합니다',
    'mode_select_subtitle': '어떤 모드로 사용하시겠어요?',
    'mode_subject': '나의 안전을\n확인받고 싶어요',
    'mode_subject_desc': '매일 자동으로 안부 확인이\n전송됩니다',
    'mode_guardian': '소중한 사람을\n지켜보고 싶어요',
    'mode_guardian_desc': '보호 대상자의 안전 상태를\n실시간으로 확인합니다',
    'mode_select_notice': '모드는 나중에 변경할 수 없습니다',

    // 권한 요청
    'permission_title': '앱 사용을 위해\n권한이 필요합니다',
    'permission_notification': '알림 권한',
    'permission_notification_desc': '안부 확인 결과와 긴급 알림을\n받기 위해 필요합니다',
    'permission_battery': '배터리 최적화 제외',
    'permission_battery_desc': '백그라운드에서 안정적으로\nheartbeat를 전송하기 위해 필요합니다',
    'permission_allow': '권한 허용하기',

    // 대상자 온보딩 (4스텝: 공감 → 해결 → 연결 → 신뢰)
    'onboarding_title_1': '혼자 사는 소중한 사람,\n걱정되시나요?',
    'onboarding_desc_1': '멀리 떨어져 있어도\n괜찮은지 궁금한 그 마음.\n안부가 함께합니다.',
    'onboarding_title_2': '안부는\n말없이도 전해집니다',
    'onboarding_desc_2': '스마트폰을 사용하는 것만으로\n하루 한 번, 자동으로\n안부 신호를 보냅니다.',
    'onboarding_title_3': '소중한 사람과\n안부를 나누세요',
    'onboarding_desc_3': '매일의 안부가 쌓여\n서로의 안심이 됩니다.\n지금 시작해 보세요.',
    'onboarding_title_4': '이름도, 전화번호도\n수집하지 않습니다',
    'onboarding_desc_4': '오직 \'잘 지내고 있다\'는\n안부 신호 하나만 전달합니다.\n당신의 정보는 안전합니다.',

    // 대상자 홈
    'subject_home_greeting': '오늘도 안녕하세요',
    'subject_home_status_ok': '정상 작동 중',
    'subject_home_status_pending': '확인 대기 중',
    'subject_home_last_heartbeat': '마지막 안부 전송',
    'subject_home_next_heartbeat': '다음 안부 전송',
    'subject_home_invite_code': '고유 코드',
    'subject_home_invite_code_desc': '보호자에게 이 코드를 알려주세요',
    'subject_home_copy_code': '코드 복사',
    'subject_home_code_copied': '코드가 복사되었습니다',
    'subject_home_guardian_count': '연결된 보호자수 : @count명',

    // 보호자 대시보드
    'guardian_dashboard_title': '대시보드',
    'guardian_dashboard_empty': '아직 연결된 보호 대상자가 없습니다',
    'guardian_dashboard_add': '보호 대상자 추가',
    'guardian_dashboard_status_normal': '정상',
    'guardian_dashboard_status_caution': '주의',
    'guardian_dashboard_status_warning': '경고',
    'guardian_dashboard_status_urgent': '긴급',
    'guardian_add_subject_title': '보호 대상자 추가',
    'guardian_add_subject_code_hint': '고유 코드를 입력하세요',
    'guardian_add_subject_alias_hint': '별칭을 입력하세요 (예: 어머니)',
    'guardian_add_subject_connect': '연결하기',

    // 설정
    'settings_title': '설정',
    'settings_heartbeat_time': 'heartbeat 시각',
    'settings_notification': '알림 설정',
    'settings_subscription': '구독 관리',
    'settings_restore': '구독 복원',
    'settings_app_version': '앱 버전',

    // API 에러
    '알수없는 에러': '알수없는 에러가 발생했습니다.',
    '타임아웃 에러': '요청 시간이 초과되었습니다.',
    '연결 에러': '네트워크 연결을 확인해주세요.',
    '비승인 사용자': '인증이 필요합니다.',
  };
}
