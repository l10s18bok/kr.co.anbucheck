abstract class ThTh {
  static const Map<String, String> translations = {
    // ── ทั่วไป ──
    'common_confirm': 'ยืนยัน',
    'common_cancel': 'ยกเลิก',
    'common_continue': 'ดำเนินต่อ',
    'common_save': 'บันทึก',
    'common_delete': 'ลบ',
    'common_close': 'ปิด',
    'common_next': 'ถัดไป',
    'common_previous': 'ก่อนหน้า',
    'common_start': 'เริ่มต้นใช้งาน',
    'common_skip': 'ข้าม',
    'common_later': 'ภายหลัง',
    'common_loading': 'กำลังโหลด...',
    'common_error': 'ข้อผิดพลาด',
    'common_complete': 'เสร็จสิ้น',
    'common_notice': 'แจ้งเตือน',
    'common_unlink': 'ยกเลิกการเชื่อมต่อ',
    'common_am': 'เช้า',
    'common_pm': 'บ่าย',
    'common_normal': 'ปกติ',
    'common_connected': 'เชื่อมต่อแล้ว',
    'common_disconnected': 'ไม่ได้เชื่อมต่อ',

    // ── แบรนด์แอป ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'ตรวจสอบความเป็นอยู่ของคุณ',
    'app_service_desc': 'บริการตรวจสอบความเป็นอยู่อัตโนมัติ',
    'app_guardian_title': 'ผู้ปกป้อง Anbu',
    'app_copyright': '© 2024 TNS Inc.',

    // ── Splash ──
    'splash_loading': 'กำลังตรวจสอบความเป็นอยู่...',

    // ── อัปเดต ──
    'update_required_title': 'จำเป็นต้องอัปเดต',
    'update_required_message':
        'กรุณาอัปเดตเป็นเวอร์ชัน @version เพื่อใช้งานแอปต่อไป',
    'update_button': 'อัปเดต',
    'update_available_title': 'มีอัปเดตใหม่',
    'update_available_message': 'เวอร์ชัน @version พร้อมใช้งาน',

    // ── เลือกโหมด ──
    'mode_select_title': 'เลือกบทบาทของคุณ',
    'mode_select_subtitle':
        'การเลือกนี้จะช่วยตั้งค่าฟีเจอร์ที่เหมาะสมสำหรับคุณ',
    'mode_subject_title': 'ฉันต้องการให้ดูแล\nความปลอดภัยของฉัน',
    'mode_subject_button': 'รับการดูแล →',
    'mode_guardian_title': 'ฉันต้องการดูแล\nคนที่ห่วงใย',
    'mode_guardian_button': 'เริ่มเป็นผู้ดูแล →',
    'mode_select_notice':
        'หน้าจอและการแจ้งเตือนจะแตกต่างกันตามการเลือกของคุณ',

    // ── สิทธิ์ ──
    'permission_title': 'จำเป็นต้องอนุญาต\nเพื่อใช้งานแอป',
    'permission_notification': 'สิทธิ์การแจ้งเตือน',
    'permission_notification_subject_desc':
        'จำเป็นเพื่อรับการแจ้งเตือนตรวจสอบความเป็นอยู่',
    'permission_notification_guardian_desc':
        'จำเป็นเพื่อรับการแจ้งเตือนสถานะความปลอดภัยของผู้อยู่ในการดูแล',
    'permission_activity': 'การรับรู้กิจกรรม',
    'permission_activity_desc':
        'ใช้ในการตรวจจับก้าวเดินและยืนยันกิจกรรม',
    'permission_activity_dialog_title': 'ข้อมูลสิทธิ์กิจกรรม',
    'permission_activity_dialog_message':
        'ใช้ในการตรวจจับก้าวเดินและยืนยันกิจกรรม\nกรุณาแตะ "อนุญาต" ในหน้าจอถัดไป',
    'permission_notification_required_title': 'จำเป็นต้องอนุญาตการแจ้งเตือน',
    'permission_notification_required_message':
        'สิทธิ์การแจ้งเตือนจำเป็นสำหรับบริการตรวจสอบความเป็นอยู่\nกรุณาเปิดในการตั้งค่า',
    'permission_go_to_settings': 'ไปที่การตั้งค่า',
    'permission_activity_denied_title': 'ต้องการสิทธิ์กิจกรรมทางกาย',
    'permission_activity_denied_message':
        'สิทธิ์กิจกรรมทางกายจำเป็นสำหรับการตรวจจับก้าวเดินและยืนยันความปลอดภัยของคุณ\n\nหากไม่มีสิทธิ์นี้ ข้อมูลก้าวเดินจะไม่ถูกส่งไปยังผู้ดูแล\n\nกรุณาเปิดสิทธิ์ "กิจกรรมทางกาย" ในการตั้งค่าแอป',
    'permission_battery': 'ยกเว้นการเพิ่มประสิทธิภาพแบตเตอรี่',
    'permission_battery_desc':
        'ยกเว้นแอปจากการเพิ่มประสิทธิภาพแบตเตอรี่เพื่อไม่ให้การตรวจสอบความเป็นอยู่ประจำวันถูกพลาดในเวลาที่กำหนด',
    'permission_battery_required_title': 'กรุณาตั้งค่าแบตเตอรี่เป็น "ไม่จำกัด"',
    'permission_battery_required_message':
        'หากตั้งค่าเป็น "เพิ่มประสิทธิภาพแบตเตอรี่" หรือ "ประหยัดแบตเตอรี่" การตรวจสอบความเป็นอยู่ประจำวันอาจล่าช้าหรือถูกพลาด\n\nหลังจากแตะ [ไปที่การตั้งค่า]:\n1. เลือก "แบตเตอรี่"\n2. เปลี่ยนเป็น "ไม่จำกัด"',
    'permission_battery_go_to_settings': 'ไปที่การตั้งค่า',

    // ── การแนะนำ ──
    'onboarding_title_1': 'เป็นห่วงคนที่คุณรัก\nที่อยู่คนเดียวหรือเปล่า?',
    'onboarding_desc_1':
        'แม้อยู่ไกล\nก็ยังอยากรู้ว่าเขาสบายดีไหม\nAnbu อยู่เคียงข้างคุณ',
    'onboarding_title_2': 'ตรวจสอบความเป็นอยู่\nโดยไม่ต้องพูดสักคำ',
    'onboarding_desc_2':
        'เพียงแค่ใช้สมาร์ทโฟน\nทุกวันสัญญาณความเป็นอยู่\nจะถูกส่งอัตโนมัติ',
    'onboarding_title_3': 'แบ่งปันความห่วงใย\nกับคนที่คุณรัก',
    'onboarding_desc_3':
        'การตรวจสอบทุกวันสะสม\nเป็นความอุ่นใจที่ยั่งยืน\nเริ่มต้นกันเลย',
    'onboarding_title_4':
        'ไม่เก็บชื่อ ไม่เก็บเบอร์โทร\n— ไม่เก็บข้อมูลใดเลย',
    'onboarding_desc_4':
        'ส่งสัญญาณเดียวเท่านั้น:\n"ฉันสบายดี"\nข้อมูลของคุณปลอดภัย',
    'onboarding_role_subject': 'ผู้อยู่ในการดูแล',
    'onboarding_role_guardian': 'ผู้ดูแล',
    'onboarding_role_guardian_subject': 'ผู้ดูแลและผู้ได้รับการดูแล',
    'onboarding_already_registered_title': 'อุปกรณ์ลงทะเบียนแล้ว',
    'onboarding_already_registered_message':
        'อุปกรณ์นี้ลงทะเบียนในโหมด "@roleLabel" แล้ว\nดำเนินต่อเป็น "@roleLabel"?\n\nหรือเปลี่ยนเป็นโหมด "@newRoleLabel"?\nการเปลี่ยนจะลบข้อมูลทั้งหมด',
    'onboarding_already_registered_message_gs':
        'อุปกรณ์นี้ลงทะเบียนในโหมด "@roleLabel" แล้ว\nการเปลี่ยนเป็นโหมด "@newRoleLabel" จะลบข้อมูลทั้งผู้ดูแลและผู้ได้รับการดูแล',
    'onboarding_registration_failed_title': 'การลงทะเบียนล้มเหลว',
    'onboarding_registration_failed_message':
        'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาลองใหม่ภายหลัง',

    // ── หน้าแรกผู้อยู่ในการดูแล ──
    'subject_home_share_title': 'แชร์รหัสความปลอดภัยของคุณ',
    'subject_home_guardian_count': 'ผู้ดูแลที่เชื่อมต่อ: @count',
    'subject_home_check_title_last': 'การตรวจสอบครั้งล่าสุด',
    'subject_home_check_title_scheduled': 'เวลาตรวจสอบที่กำหนด',
    'subject_home_check_title_checking': 'กำลังตรวจสอบความเป็นอยู่',
    'subject_home_check_body_reported': 'รายงานเมื่อ @time',
    'subject_home_check_body_scheduled': 'กำหนดเวลา @time',
    'subject_home_check_body_waiting': 'รอตั้งแต่ @time',
    'subject_home_battery_status': 'สถานะแบตเตอรี่',
    'subject_home_battery_charging': 'กำลังชาร์จ',
    'subject_home_battery_full': 'เต็ม',
    'subject_home_battery_low': 'แบตเตอรี่ต่ำ',
    'subject_home_connectivity_status': 'การเชื่อมต่อ',
    'subject_home_report_loading': 'กำลังรายงาน...',
    'subject_home_report_button': 'รายงานความปลอดภัยตอนนี้',
    'subject_home_report_desc':
        'แจ้งผู้ดูแลว่าคุณสบายดี',
    'subject_home_emergency_button': 'ฉันต้องการความช่วยเหลือ',
    'subject_home_emergency_desc': 'ส่งการแจ้งเตือนฉุกเฉินไปยังผู้ดูแล',
    'subject_home_emergency_loading': 'กำลังส่งการแจ้งเตือนฉุกเฉิน...',
    'subject_home_emergency_sent': 'ส่งการแจ้งเตือนฉุกเฉินแล้ว',
    'subject_home_emergency_failed': 'ไม่สามารถส่งการแจ้งเตือนฉุกเฉินได้',
    'subject_home_emergency_confirm_title': 'ขอความช่วยเหลือฉุกเฉิน',
    'subject_home_emergency_confirm_body': 'การแจ้งเตือนฉุกเฉินจะถูกส่งไปยังผู้ดูแลทั้งหมด\nคุณแน่ใจหรือไม่ที่จะขอความช่วยเหลือ?',
    'subject_home_emergency_confirm_send': 'ส่งคำขอฉุกเฉิน',
    'subject_home_share_text':
        'ตรวจสอบความเป็นอยู่ของฉันผ่านแอป Anbu!\nรหัสเชิญ: @code',
    'subject_home_share_subject': 'รหัสเชิญ Anbu',
    'subject_home_code_copied': 'คัดลอกรหัสแล้ว',

    // ── ลิ้นชักผู้อยู่ในการดูแล ──
    'drawer_light_mode': 'โหมดสว่าง',
    'drawer_dark_mode': 'โหมดมืด',
    'drawer_privacy_policy': 'นโยบายความเป็นส่วนตัว',
    'drawer_terms': 'ข้อกำหนดการใช้งาน',
    'drawer_withdraw': 'ลบบัญชี',
    'drawer_withdraw_message':
        'บัญชีและข้อมูลทั้งหมดจะถูกลบ\nคุณแน่ใจหรือไม่?',

    // ── แดชบอร์ดผู้ดูแล ──
    'guardian_status_normal': 'ปกติ',
    'guardian_status_caution': 'ระวัง',
    'guardian_status_warning': 'เตือน',
    'guardian_status_urgent': 'เร่งด่วน',
    'guardian_status_confirmed': 'ยืนยันความปลอดภัยแล้ว',
    'guardian_subscription_expired': 'การสมัครหมดอายุแล้ว',
    'guardian_subscription_expired_message':
        'การแจ้งเตือนไม่ได้ถูกส่ง\nต่ออายุการสมัครเพื่อดูแลต่อ',
    'guardian_subscribe': 'สมัครสมาชิก',
    'guardian_payment_preparing': 'ฟีเจอร์การชำระเงินเร็วๆ นี้',
    'guardian_today_summary': 'สรุปความเป็นอยู่วันนี้',
    'guardian_no_subjects': 'ยังไม่มีผู้อยู่ในการดูแล',
    'guardian_checking_subjects':
        'กำลังตรวจสอบ\nผู้อยู่ในการดูแล @count คน',
    'guardian_subject_list': 'รายชื่อผู้อยู่ในการดูแล',
    'guardian_call_now': 'โทรเลย',
    'guardian_confirm_safety': 'ยืนยันความปลอดภัย',
    'guardian_no_check_history': 'ไม่มีประวัติการตรวจสอบ',
    'guardian_last_check_now': 'ตรวจสอบล่าสุด: เมื่อสักครู่',
    'guardian_last_check_minutes': 'ตรวจสอบล่าสุด: @minutes นาทีที่แล้ว',
    'guardian_last_check_hours': 'ตรวจสอบล่าสุด: @hours ชั่วโมงที่แล้ว',
    'guardian_last_check_days': 'ตรวจสอบล่าสุด: @days วันที่แล้ว',
    'guardian_activity_stable': 'กิจกรรม: คงที่',
    'guardian_safety_needed': 'จำเป็นต้องตรวจสอบความปลอดภัย',
    'guardian_error_load_subjects':
        'ไม่สามารถโหลดรายชื่อผู้อยู่ในการดูแล',
    'guardian_error_clear_alerts': 'ไม่สามารถล้างการแจ้งเตือน',

    // ── เพิ่มผู้อยู่ในการดูแล ──
    'add_subject_title': 'เชื่อมต่อผู้อยู่ในการดูแล',
    'add_subject_guide_title':
        'กรอกรหัสเฉพาะของผู้อยู่ในการดูแลและชื่อเล่น',
    'add_subject_guide_subtitle':
        'เชื่อมต่อแอปของผู้อยู่ในการดูแลเพื่อติดตามสุขภาพและกิจกรรมแบบเรียลไทม์',
    'add_subject_code_label': 'รหัสเฉพาะ (7 หลัก)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info':
        'รหัสเฉพาะสามารถพบได้ในแอปของผู้อยู่ในการดูแล',
    'add_subject_alias_label': 'ชื่อเล่นผู้อยู่ในการดูแล',
    'add_subject_alias_hint': 'เช่น แม่, พ่อ',
    'add_subject_connect': 'เชื่อมต่อ',
    'add_subject_error_login': 'จำเป็นต้องเข้าสู่ระบบ',
    'add_subject_success': 'เชื่อมต่อผู้อยู่ในการดูแลสำเร็จ',
    'add_subject_error_invalid_code': 'รหัสไม่ถูกต้อง',
    'add_subject_error_already_connected': 'เชื่อมต่อแล้ว',
    'add_subject_error_failed':
        'การเชื่อมต่อล้มเหลว กรุณาลองใหม่',
    'add_subject_button': 'เพิ่มผู้อยู่ในการดูแลใหม่',

    // ── การตั้งค่าผู้ดูแล ──
    'settings_title': 'การตั้งค่า',
    'settings_light_mode': 'โหมดสว่าง',
    'settings_dark_mode': 'โหมดมืด',
    'settings_connection_management': 'จัดการการเชื่อมต่อ',
    'settings_managed_subjects': 'จำนวนผู้อยู่ในการดูแล',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'การสมัครสมาชิกและบริการ',
    'settings_current_membership': 'สมาชิกปัจจุบัน',
    'settings_premium': 'พรีเมียมใช้งานอยู่',
    'settings_free_trial': 'ทดลองใช้ฟรี',
    'settings_days_remaining': 'เหลือ @days วัน',
    'settings_manage_subscription': 'จัดการการสมัครสมาชิก',
    'settings_notification': 'การตั้งค่าการแจ้งเตือน',
    'settings_terms_section': 'กฎหมาย',
    'settings_privacy_policy': 'นโยบายความเป็นส่วนตัว',
    'settings_terms': 'ข้อกำหนดการใช้งาน',
    'settings_app_version': 'เวอร์ชัน: v@version',

    // ── G+S (ผู้ดูแล + ผู้ได้รับการดูแล) ──
    'gs_enable_button': 'รับการดูแลสุขภาพด้วย',
    'gs_safety_code_button': 'ตรวจสอบรหัสความปลอดภัย',
    'gs_safety_code_title': 'รหัสความปลอดภัยของฉัน',
    'gs_enable_dialog_title': 'เปิดใช้งานการดูแล',
    'gs_enable_dialog_body':
        'คุณสามารถรับการดูแลในขณะที่ยังคงฟังก์ชันผู้ดูแลไว้\nรหัสความปลอดภัยจะถูกออก — กรุณาแชร์ให้ผู้ดูแลคนอื่น',
    'gs_enable_dialog_ios_warning_title': '⚠ iOS ทำงานต่างจาก Android',
    'gs_enable_dialog_ios_warning_body':
        'บน iOS จะมี "การแจ้งเตือนพุชสุขภาพ" ปรากฏทุกวันตามเวลาที่กำหนด คุณต้องแตะที่การแจ้งเตือนหรือเปิดแอปด้วยตัวเองในช่วงเวลานั้น สัญญาณสุขภาพของคุณจึงจะถูกส่ง หากคุณไม่เปิดแอป ผู้ดูแลของคุณอาจได้รับการแจ้งเตือนการตรวจสอบที่พลาดไป',
    'gs_enable_dialog_ios_confirm': 'เข้าใจแล้ว เปิดใช้งาน',
    'gs_enable_confirm': 'เปิดใช้งาน',
    'gs_enabled_message': 'เปิดใช้งานการดูแลแล้ว',
    'gs_enable_failed': 'ไม่สามารถเปิดใช้งานการดูแลได้',
    'gs_disable_dialog_title': 'ปิดใช้งานการดูแล',
    'gs_disable_dialog_body':
        'การปิดใช้งานจะลบรหัสความปลอดภัยและหยุดส่งการตรวจสอบสุขภาพไปยังผู้ดูแลที่เชื่อมต่อ',
    'gs_disable_confirm': 'ปิดใช้งาน',
    'gs_disabled_message': 'ปิดใช้งานการดูแลแล้ว',
    'gs_disable_failed': 'ไม่สามารถปิดใช้งานการดูแลได้',

    // ── การแจ้งเตือนผู้ดูแล ──
    'notifications_title': 'การแจ้งเตือน',
    'notifications_today': 'การแจ้งเตือนวันนี้',
    'notifications_empty': 'ไม่มีการแจ้งเตือนวันนี้',
    'notifications_delete_all_title': 'ลบการแจ้งเตือนทั้งหมด',
    'notifications_delete_all_message':
        'ลบการแจ้งเตือนทั้งหมดวันนี้?',
    'notifications_delete_failed': 'ไม่สามารถลบการแจ้งเตือน',
    'notifications_guide_title': 'คู่มือระดับการแจ้งเตือน',
    'notifications_level_health': 'ปกติ',
    'notifications_level_health_desc':
        'ยืนยันความเป็นอยู่ของผู้อยู่ในการดูแลเป็นปกติ',
    'notifications_level_caution': 'ระวัง',
    'notifications_level_caution_desc':
        'หนึ่งในกรณีต่อไปนี้:\n1. ยังไม่มีการตรวจสอบตามกำหนดวันนี้\n2. ได้รับการตรวจสอบแต่ไม่พบการใช้โทรศัพท์',
    'notifications_level_warning': 'เตือน',
    'notifications_level_warning_desc':
        'หนึ่งในกรณีต่อไปนี้:\n1. ไม่มีการตรวจสอบ 2 วันติดต่อกัน\n2. ไม่มีการใช้โทรศัพท์ 2 วันติดต่อกัน',
    'notifications_level_urgent': 'เร่งด่วน',
    'notifications_level_urgent_desc':
        'ไม่มีการตรวจสอบเป็นเวลานาน\nหรือไม่มีการใช้โทรศัพท์ 3 วันขึ้นไป',
    'notifications_level_info': 'ข้อมูล',
    'notifications_level_info_desc':
        'การแจ้งเตือนอ้างอิง เช่น\nจำนวนก้าวหรือแบตเตอรี่ต่ำ',
    'notifications_activity_note':
        '※ ข้อมูลกิจกรรมอาจไม่แสดงหากไม่สามารถเก็บข้อมูลก้าวเดินได้',

    // ── การตั้งค่าการแจ้งเตือนผู้ดูแล ──
    'notification_settings_title': 'การตั้งค่าการแจ้งเตือน',
    'notification_settings_push': 'การแจ้งเตือนแบบพุช',
    'notification_settings_all': 'การแจ้งเตือนทั้งหมด',
    'notification_settings_all_desc':
        'เปิดหรือปิดการแจ้งเตือนทุกประเภทพร้อมกัน',
    'notification_settings_level_section': 'การตั้งค่าตามระดับ',
    'notification_settings_urgent': 'แจ้งเตือนเร่งด่วน',
    'notification_settings_urgent_desc':
        'ไม่สามารถปิดการแจ้งเตือนเร่งด่วนได้',
    'notification_settings_warning': 'แจ้งเตือนเตือน',
    'notification_settings_warning_desc':
        'แจ้งเตือนเมื่อไม่มีการตรวจสอบ 2 วันติดต่อกัน',
    'notification_settings_caution': 'แจ้งเตือนระวัง',
    'notification_settings_caution_desc':
        'แจ้งเตือนเมื่อยังไม่มีการตรวจสอบวันนี้',
    'notification_settings_info': 'แจ้งเตือนข้อมูล',
    'notification_settings_info_desc':
        'การแจ้งเตือนทั่วไป เช่น จำนวนก้าวและสถานะแบตเตอรี่',
    'notification_settings_dnd': 'ห้ามรบกวน',
    'notification_settings_dnd_start': 'เวลาเริ่ม',
    'notification_settings_dnd_end': 'เวลาสิ้นสุด',
    'notification_settings_dnd_note':
        '※ การแจ้งเตือนเร่งด่วนจะส่งแม้ในโหมดห้ามรบกวน',
    'notification_settings_dnd_start_default': '22:00',
    'notification_settings_dnd_end_default': '7:00',

    // ── การจัดการการเชื่อมต่อผู้ดูแล ──
    'connection_title': 'การจัดการการเชื่อมต่อ',
    'connection_managed_count': 'จำนวนผู้อยู่ในการดูแล ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'ผู้อยู่ในการดูแลที่เชื่อมต่อ',
    'connection_empty': 'ไม่มีผู้ได้รับการดูแลที่เชื่อมต่อ',
    'connection_unlink_warning':
        'การยกเลิกเชื่อมต่อจะลบข้อมูลของผู้อยู่ในการดูแล',
    'connection_unlink_warning_detail':
        'ไม่สามารถกู้คืนบันทึกก่อนหน้าหลังจากเชื่อมต่อใหม่ คุณจะต้องกรอกรหัสผู้อยู่ในการดูแลอีกครั้ง',
    'connection_heartbeat_schedule': 'ทุกวันเวลา @time',
    'connection_heartbeat_report_time': 'เวลารายงานความเป็นอยู่: ',
    'connection_subject_label': 'ผู้อยู่ในการดูแล',
    'connection_change_only_in_app': 'เปลี่ยนได้เฉพาะในแอปเท่านั้น',
    'connection_edit_title': 'แก้ไขผู้อยู่ในการดูแล',
    'connection_alias_label': 'ชื่อเล่น',
    'connection_unlink_title': 'ยกเลิกเชื่อมต่อ',
    'connection_unlink_confirm': 'ยกเลิกเชื่อมต่อ @alias?',
    'connection_unlink_success': 'ยกเลิกเชื่อมต่อสำเร็จ',
    'connection_unlink_failed': 'ไม่สามารถยกเลิกเชื่อมต่อ',
    'connection_load_failed': 'ไม่สามารถโหลดรายชื่อ',

    // ── แถบนำทางด้านล่างผู้ดูแล ──
    'nav_home': 'หน้าแรก',
    'nav_connection': 'เชื่อมต่อ',
    'nav_notification': 'แจ้งเตือน',
    'nav_settings': 'ตั้งค่า',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'เปลี่ยนเวลาตรวจสอบ',
    'heartbeat_schedule_title_ios': 'เวลาแจ้งเตือนพุชสุขภาพ',
    'heartbeat_schedule_change_title_ios': 'เปลี่ยนเวลาแจ้งเตือนพุชสุขภาพ',
    'heartbeat_schedule_hint_ios': 'การแจ้งเตือนพุชสุขภาพจะมาถึงทุกวันในเวลานี้ แตะที่การแจ้งเตือนหรือเปิดแอปในช่วงเวลานั้นเพื่อส่งสัญญาณสุขภาพของคุณ',
    'heartbeat_daily_time': 'ทุกวันเวลา @time',
    'heartbeat_scheduled_today':
        'การตรวจสอบความเป็นอยู่กำหนดเวลา @time วันนี้',
    'heartbeat_change_failed_title': 'เปลี่ยนเวลาไม่สำเร็จ',
    'heartbeat_change_failed_message':
        'ไม่สามารถอัปเดตบนเซิร์ฟเวอร์ได้',

    // ── การแจ้งเตือนในเครื่อง ──
    'local_notification_channel': 'การแจ้งเตือนความเป็นอยู่',
    'local_notification_channel_desc':
        'การแจ้งเตือนบริการตรวจสอบความเป็นอยู่',

    // ── อื่นๆ ──
    'back_press_exit': 'กดย้อนกลับอีกครั้งเพื่อออก',

    // ── ข้อผิดพลาด API ──
    'error_unknown': 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ',
    'error_timeout': 'หมดเวลาคำขอ',
    'error_network': 'กรุณาตรวจสอบการเชื่อมต่อเครือข่าย',
    'error_unauthorized': 'จำเป็นต้องยืนยันตัวตน',

    // ── เนื้อหาการแจ้งเตือน ──
    'noti_auto_report_body':
        'การตรวจสอบความเป็นอยู่ตามกำหนดได้รับแล้ววันนี้',
    'noti_manual_report_body':
        'ผู้ได้รับการดูแลส่งการตรวจสอบความเป็นอยู่ด้วยตนเอง',
    'noti_battery_low_body':
        'แบตเตอรี่โทรศัพท์ต่ำกว่า 20% อาจจำเป็นต้องชาร์จ',
    'noti_battery_dead_body':
        'โทรศัพท์ดูเหมือนปิดเนื่องจากแบตเตอรี่หมด ระดับแบตเตอรี่ล่าสุด: @battery_level% จะกลับมาเป็นปกติหลังชาร์จ',
    'noti_caution_suspicious_body':
        'ได้รับสัญญาณความเป็นอยู่ แต่ไม่มีสัญญาณการใช้โทรศัพท์ กรุณาตรวจสอบด้วยตนเอง',
    'noti_caution_missing_body':
        'การตรวจสอบความเป็นอยู่ที่กำหนดไว้วันนี้ยังไม่ได้รับ กรุณาตรวจสอบด้วยตนเอง',
    'noti_warning_body':
        'การตรวจสอบความเป็นอยู่ถูกพลาดติดต่อกัน กรุณายืนยันด้วยตนเอง',
    'noti_urgent_body':
        'ไม่มีการตรวจสอบความเป็นอยู่เป็นเวลา @days วัน จำเป็นต้องยืนยันทันที',
    'noti_steps_body':
        '@from_time ~ @to_time: เดิน @steps ก้าว',
    'noti_emergency_body': 'ผู้ถูกดูแลขอความช่วยเหลือโดยตรง กรุณาตรวจสอบทันที',
    'noti_resolved_body': 'การตรวจสอบสุขภาพของผู้ได้รับการดูแลกลับสู่ปกติแล้ว',
    'noti_cleared_by_guardian_title': '✅ ยืนยันความปลอดภัย',
    'noti_cleared_by_guardian_body': 'ผู้ดูแลท่านหนึ่งได้ยืนยันความปลอดภัยด้วยตนเอง',

    // ── การแจ้งเตือนในเครื่อง ──
    'local_alarm_title': '💗 ต้องตรวจสอบความเป็นอยู่',
    'local_alarm_body': 'กรุณาแตะที่การแจ้งเตือนนี้',
    'wellbeing_check_title': '💛 ตรวจสอบความเป็นอยู่',
    'wellbeing_check_body':
        'คุณสบายดีไหม? กรุณาแตะที่การแจ้งเตือนนี้',
    'noti_channel_name': 'การแจ้งเตือน Anbu',
  };
}
