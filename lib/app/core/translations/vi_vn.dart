abstract class ViVn {
  static const Map<String, String> translations = {
    // ── Chung ──
    'common_confirm': 'Xac nhan',
    'common_cancel': 'Huy',
    'common_continue': 'Tiep tuc',
    'common_save': 'Luu',
    'common_delete': 'Xoa',
    'common_close': 'Dong',
    'common_next': 'Tiep theo',
    'common_previous': 'Quay lai',
    'common_start': 'Bat dau',
    'common_skip': 'Bo qua',
    'common_later': 'De sau',
    'common_loading': 'Dang tai...',
    'common_error': 'Loi',
    'common_complete': 'Hoan thanh',
    'common_notice': 'Thong bao',
    'common_unlink': 'Ngat ket noi',
    'common_am': 'SA',
    'common_pm': 'CH',
    'common_normal': 'Binh thuong',
    'common_connected': 'Da ket noi',
    'common_disconnected': 'Mat ket noi',

    // ── Thuong hieu ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Kiem tra suc khoe cua ban.',
    'app_service_desc': 'Dich vu kiem tra suc khoe tu dong',
    'app_guardian_title': 'Nguoi bao ve Anbu',
    'app_copyright': '© 2026 Ark SB Inc.',

    // ── Splash ──
    'splash_loading': 'Dang kiem tra suc khoe...',

    // ── Cap nhat ──
    'update_required_title': 'Can cap nhat',
    'update_required_message':
        'Vui long cap nhat len phien ban @version de tiep tuc su dung ung dung.',
    'update_button': 'Cap nhat',
    'update_available_title': 'Co ban cap nhat moi',
    'update_available_message': 'Phien ban @version da co san.',

    // ── Chon che do ──
    'mode_select_title': 'Chon vai tro cua ban',
    'mode_select_subtitle': 'Dieu nay giup chung toi thiet lap cac tinh nang phu hop cho ban',
    'mode_subject_title': 'Toi muon su an toan cua toi\nduoc theo doi',
    'mode_subject_button': 'Duoc bao ve →',
    'mode_guardian_title': 'Toi muon theo doi\nnguoi than yeu cua toi',
    'mode_guardian_button': 'Bat dau voi tu cach nguoi bao ve →',
    'mode_select_notice': 'Giao dien va thong bao se khac nhau tuy theo lua chon cua ban',

    // ── Quyen ──
    'permission_title': 'Can cap quyen\nde su dung ung dung',
    'permission_notification': 'Quyen thong bao',
    'permission_notification_subject_desc': 'Can thiet de nhan thong bao kiem tra suc khoe',
    'permission_notification_guardian_desc':
        'Can thiet de nhan thong bao ve tinh trang an toan cua nguoi duoc bao ve',
    'permission_activity': 'Nhan dien hoat dong',
    'permission_activity_desc': 'Dung de phat hien buoc chan va xac nhan hoat dong',
    'permission_location': 'Vi tri',
    'permission_location_desc': 'Chi gui vi tri den nguoi bao ho khi yeu cau cuu giup khan cap',
    'location_permission_warning':
        'Vi tri se khong duoc gui khi yeu cau cuu giup khan cap. Cham de cho phep.',
    'location_permission_settings_title': 'Can quyen vi tri',
    'location_permission_settings_body_ios':
        "Tim va chon 'Anbu', sau do trong muc 'Vi tri' chon 'Khi dang su dung ung dung'.",
    'location_permission_settings_body_android':
        "Chon 'Quyen' → 'Vi tri', sau do chon 'Chi cho phep khi dang su dung ung dung'.",
    'permission_activity_dialog_title': 'Thong tin quyen hoat dong',
    'permission_activity_dialog_message':
        'Dung de phat hien buoc chan va xac nhan hoat dong.\nVui long nhan "Cho phep" tren man hinh tiep theo.',
    'permission_notification_required_title': 'Can quyen thong bao',
    'permission_notification_required_message':
        'Quyen thong bao la bat buoc cho dich vu kiem tra suc khoe.\nVui long bat trong Cai dat.',
    'permission_go_to_settings': 'Di den Cai dat',
    'permission_activity_denied_title': 'Can quyen hoat dong the chat',
    'permission_activity_denied_message':
        'Quyen hoat dong the chat can thiet de phat hien buoc chan va xac minh su an toan cua ban.\n\nNeu khong co quyen nay, thong tin buoc chan se khong duoc gui den nguoi bao ho.\n\nVui long bat quyen "Hoat dong the chat" trong cai dat ung dung.',
    'permission_battery': 'Loai tru toi uu hoa pin',
    'permission_battery_desc':
        'Loai tru ung dung khoi toi uu hoa pin de kiem tra suc khoe hang ngay khong bi bo lo vao gio da dinh',
    'permission_hibernation_title': 'Vui long tat "Tam dung ung dung khi khong dung"',
    'permission_hibernation_highlight': 'Tam dung ung dung khi khong dung',
    'permission_hibernation_message':
        'Neu ban khong mo ung dung trong vai thang, Android co the tu dong dung ung dung, lam gian doan viec kiem tra suc khoe.\n\nNhan [Mo cai dat ung dung] va tat "Tam dung ung dung khi khong dung".',
    'permission_hibernation_go_to_settings': 'Mo cai dat ung dung',

    // ── Gioi thieu ──
    'onboarding_title_1': 'Ban lo lang cho nguoi\nsong mot minh?',
    'onboarding_desc_1': 'Du o xa,\nban van tu hoi ho co khoe khong.\nAnbu o day cung ban.',
    'onboarding_title_2': 'Kiem tra suc khoe\nkhong can noi mot loi',
    'onboarding_desc_2':
        'Chi can su dung dien thoai,\nmoi ngay mot tin hieu suc khoe\nduoc gui tu dong.',
    'onboarding_title_3': 'Chia se su quan tam\nvoi nguoi than yeu',
    'onboarding_desc_3':
        'Nhung lan kiem tra hang ngay tich luy\nthanh su an tam lau dai.\nHay bat dau nao.',
    'onboarding_title_4': 'Khong ten, khong so dien thoai\n— khong thu thap gi ca',
    'onboarding_desc_4':
        'Chi mot tin hieu duoc gui:\n"Toi van khoe."\nThong tin cua ban luon an toan.',
    'onboarding_role_subject': 'Nguoi duoc bao ve',
    'onboarding_role_guardian': 'Nguoi bao ve',
    'onboarding_role_guardian_subject': 'Người giám hộ và được bảo vệ',
    'onboarding_already_registered_title': 'Thiet bi da duoc dang ky',
    'onboarding_already_registered_message':
        'Thiet bi nay da duoc dang ky o che do "@roleLabel".\nTiep tuc voi "@roleLabel"?\n\nHay chuyen sang che do "@newRoleLabel"?\nChuyen doi se xoa tat ca du lieu hien co.',
    'onboarding_already_registered_message_gs':
        'Thiết bị này đã được đăng ký ở chế độ "@roleLabel".\nChuyển sang chế độ "@newRoleLabel" sẽ xóa tất cả dữ liệu người giám hộ và người được bảo vệ.',
    'onboarding_registration_failed_title': 'Dang ky that bai',
    'onboarding_registration_failed_message':
        'Khong the ket noi den may chu. Vui long thu lai sau.',

    // ── Trang chu nguoi duoc bao ve ──
    'subject_home_share_title': 'Chia se ma an toan cua ban',
    'subject_home_guardian_count': 'Nguoi bao ve da ket noi: @count',
    'subject_home_check_title_last': 'Lan kiem tra cuoi',
    'subject_home_check_title_scheduled': 'Thoi gian kiem tra da len lich',
    'subject_home_check_title_checking': 'Dang kiem tra suc khoe',
    'subject_home_check_body_reported': 'Da bao cao luc @time',
    'subject_home_check_body_scheduled': 'Da len lich luc @time',
    'subject_home_check_body_waiting': 'Dang cho tu @time',
    'subject_home_battery_status': 'Tinh trang pin',
    'subject_home_battery_charging': 'Dang sac',
    'subject_home_battery_full': 'Day',
    'subject_home_battery_low': 'Pin yeu',
    'subject_home_connectivity_status': 'Ket noi',
    'subject_home_report_loading': 'Dang bao cao...',
    'subject_home_report_button': 'Bao cao an toan ngay',
    'subject_home_report_desc': 'Cho nguoi bao ve biet ban van khoe',
    'subject_home_emergency_button': 'Tôi cần giúp đỡ',
    'subject_home_emergency_desc': 'Gửi cảnh báo khẩn cấp đến người giám hộ',
    'subject_home_emergency_loading': 'Đang gửi cảnh báo khẩn cấp...',
    'subject_home_emergency_sent': 'Cảnh báo khẩn cấp đã được gửi',
    'subject_home_emergency_failed': 'Gửi cảnh báo khẩn cấp thất bại',
    'subject_home_manual_report_limit_reached':
        'Bạn đã gửi báo cáo an toàn hôm nay. Vui lòng thử lại vào ngày mai.',
    'subject_home_manual_report_sent': 'Đã gửi thông báo an toàn đến người giám hộ của bạn.',
    'subject_home_emergency_confirm_title': 'Yêu cầu trợ giúp khẩn cấp',
    'subject_home_emergency_confirm_body':
        'Cảnh báo khẩn cấp sẽ được gửi đến tất cả người giám hộ.\nVị trí hiện tại của bạn cũng sẽ được chia sẻ.\nBạn có thực sự muốn yêu cầu trợ giúp không?',
    'emergency_sent_with_location': 'Đã gửi cảnh báo khẩn cấp (kèm vị trí)',
    'emergency_sent_without_location': 'Đã gửi cảnh báo khẩn cấp',
    'notifications_view_location': '🗺️ Xem vị trí',
    'emergency_map_title': 'Vị trí khẩn cấp',
    'emergency_map_subject_label': 'Người được chăm sóc',
    'emergency_map_captured_at_label': 'Thời gian ghi nhận',
    'emergency_map_accuracy_label': 'Độ chính xác',
    'emergency_map_open_external': 'Mở trong ứng dụng bản đồ bên ngoài',
    'emergency_map_no_location': 'Không có thông tin vị trí',
    'emergency_location_permission_denied_snackbar':
        'Đã gửi cảnh báo khẩn cấp mà không có quyền vị trí',
    'subject_home_emergency_confirm_send': 'Gửi yêu cầu khẩn cấp',
    'subject_home_share_text': 'Kiem tra suc khoe cua toi qua ung dung Anbu!\nMa moi: @code',
    'subject_home_share_subject': 'Ma moi Anbu',
    'subject_home_code_copied': 'Da sao chep ma',

    // ── Ngon keo nguoi duoc bao ve ──
    'drawer_light_mode': 'Che do sang',
    'drawer_dark_mode': 'Che do toi',
    'drawer_privacy_policy': 'Chinh sach bao mat',
    'drawer_terms': 'Dieu khoan su dung',
    'drawer_withdraw': 'Xoa tai khoan',
    'drawer_withdraw_message': 'Tai khoan va tat ca du lieu se bi xoa.\nBan co chac khong?',

    // ── Bang dieu khien nguoi bao ve ──
    'guardian_status_normal': 'An toan',
    'guardian_status_caution': 'Chu y',
    'guardian_status_warning': 'Canh bao',
    'guardian_status_urgent': 'Khan cap',
    'guardian_status_confirmed': '✅ An toan',
    'guardian_subscription_expired': 'Goi dang ky da het han',
    'guardian_subscription_expired_message':
        'Thong bao canh bao khong duoc gui.\nGia han dang ky de tiep tuc bao ve.',
    'guardian_subscribe': 'Dang ky',
    'guardian_payment_preparing': 'Tinh nang thanh toan sap co.',
    'guardian_today_summary': 'Tom tat suc khoe hom nay',
    'guardian_no_subjects': 'Chua co nguoi duoc bao ve nao.',
    'guardian_checking_subjects': 'Dang kiem tra\n@count nguoi duoc bao ve.',
    'guardian_subject_list': 'Danh sach nguoi duoc bao ve',
    'guardian_call_now': 'Goi ngay',
    'guardian_confirm_safety': 'Xac nhan an toan',
    'guardian_no_check_history': 'Chua co lich su kiem tra',
    'guardian_last_check_now': 'Lan kiem tra cuoi: vua xong',
    'guardian_last_check_minutes': 'Lan kiem tra cuoi: @minutes phut truoc',
    'guardian_last_check_hours': 'Lan kiem tra cuoi: @hours gio truoc',
    'guardian_last_check_days': 'Lan kiem tra cuoi: @days ngay truoc',
    'guardian_activity_stable': 'Hoat dong: On dinh',
    'guardian_activity_prefix': 'Hoat dong',
    'guardian_activity_very_active': 'Rất năng động',
    'guardian_activity_active': 'Năng động',
    'guardian_activity_needs_exercise': 'Cần vận động',
    'guardian_activity_collecting': 'Đang thu thập dữ liệu',
    'guardian_error_load_step_history': 'Không thể tải lịch sử bước',
    'guardian_chart_y_axis_steps': 'Bước',
    'guardian_chart_x_axis_last_7_days': '7 ngày qua',
    'guardian_chart_x_axis_last_30_days': '30 ngày qua',
    'guardian_chart_today': 'Hôm nay',
    'guardian_safety_needed': 'Can kiem tra an toan',
    'guardian_error_load_subjects': 'Khong the tai danh sach nguoi duoc bao ve.',
    'guardian_safety_confirmed': 'Đã xác nhận an toàn.',
    'guardian_error_clear_alerts': 'Khong the xoa canh bao.',

    // ── Them nguoi duoc bao ve ──
    'add_subject_title': 'Ket noi nguoi duoc bao ve',
    'add_subject_guide_title': 'Nhap ma duy nhat cua nguoi duoc bao ve va ten goi.',
    'add_subject_guide_subtitle':
        'Ket noi ung dung cua nguoi duoc bao ve de theo doi suc khoe va hoat dong theo thoi gian thuc.',
    'add_subject_code_label': 'Ma duy nhat (7 ky tu)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info': 'Ma duy nhat co the tim thay trong ung dung cua nguoi duoc bao ve.',
    'add_subject_alias_label': 'Ten goi nguoi duoc bao ve',
    'add_subject_alias_hint': 'VD: Me, Bo',
    'add_subject_connect': 'Ket noi',
    'add_subject_error_login': 'Can dang nhap.',
    'add_subject_success': 'Ket noi nguoi duoc bao ve thanh cong.',
    'add_subject_error_invalid_code': 'Ma khong hop le.',
    'add_subject_error_already_connected': 'Da ket noi roi.',
    'add_subject_error_failed': 'Ket noi that bai. Vui long thu lai.',
    'add_subject_button': 'Them nguoi duoc bao ve moi',

    // ── Cai dat nguoi bao ve ──
    'settings_title': 'Cai dat',
    'settings_light_mode': 'Che do sang',
    'settings_dark_mode': 'Che do toi',
    'settings_connection_management': 'Quan ly ket noi',
    'settings_managed_subjects': 'So nguoi duoc bao ve',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'Dang ky & Dich vu',
    'settings_current_membership': 'Thanh vien hien tai',
    'settings_premium': 'Premium dang hoat dong',
    'settings_free_trial': 'Dung thu mien phi',
    'settings_days_remaining': 'Con @days ngay',
    'settings_manage_subscription': 'Quan ly dang ky',
    'settings_notification': 'Cai dat thong bao',
    'settings_terms_section': 'Phap ly',
    'settings_privacy_policy': 'Chinh sach bao mat',
    'settings_terms': 'Dieu khoan su dung',
    'settings_app_version': 'Phien ban: v@version',

    // ── G+S (Người giám hộ + Được bảo vệ) ──
    'gs_enable_button': 'Nhận bảo vệ sức khỏe',
    'gs_safety_code_button': 'Xem mã an toàn của tôi',
    'gs_safety_code_title': 'Mã an toàn của tôi',
    'gs_enable_dialog_title': 'Kích hoạt bảo vệ',
    'gs_enable_dialog_body':
        'Bạn có thể nhận bảo vệ trong khi giữ nguyên chức năng giám hộ.\nMã an toàn sẽ được cấp — hãy chia sẻ với người giám hộ khác.',
    'gs_enable_dialog_ios_warning_title': '⚠ iOS hoạt động khác Android',
    'gs_enable_dialog_ios_warning_body':
        'Trên iOS, "thông báo đẩy an toàn" sẽ hiển thị mỗi ngày vào thời điểm đã định. Bạn phải chạm vào thông báo hoặc tự mở ứng dụng quanh thời điểm đó để tín hiệu an toàn được gửi đi. Nếu bạn không mở ứng dụng, người giám hộ của bạn có thể nhận được cảnh báo bỏ lỡ kiểm tra.',
    'gs_enable_dialog_ios_confirm': 'Đã hiểu, kích hoạt',
    'gs_enable_confirm': 'Kích hoạt',
    'gs_enabled_message': 'Bảo vệ đã được kích hoạt',
    'gs_enable_failed': 'Không thể kích hoạt bảo vệ',
    'gs_disable_dialog_title': 'Tắt bảo vệ',
    'gs_disable_dialog_body':
        'Tắt bảo vệ sẽ xóa mã an toàn của bạn và ngừng gửi kiểm tra sức khỏe cho người giám hộ đã kết nối.',
    'gs_disable_confirm': 'Tắt',
    'gs_disabled_message': 'Bảo vệ đã được tắt',
    'gs_disable_failed': 'Không thể tắt bảo vệ',
    'gs_activity_permission_denied_warning':
        'Quyền đếm bước chân bị từ chối. Nhấn vào đây để cho phép.',
    'gs_activity_permission_settings_title': 'Cần cấp quyền',
    'gs_activity_permission_settings_body':
        'Vui lòng cấp quyền Hoạt động thể chất (Chuyển động và Thể hình) trong cài đặt ứng dụng.',
    'gs_activity_permission_settings_go': 'Đi đến Cài đặt',

    // ── Chế độ Người bảo vệ → G+S (Drawer/Hộp thoại) ──
    'drawer_enable_guardian': 'Quản lý cả sự an toàn của gia đình',
    's_to_gs_dialog_title': 'Thêm tính năng Người bảo vệ',
    's_to_gs_dialog_body':
        'Thêm tính năng Người bảo vệ để cũng có thể theo dõi sự an toàn của gia đình hoặc những người thân yêu.\n(Lưu ý: Tính năng Người bảo vệ miễn phí trong 3 tháng, sau đó chuyển sang gói đăng ký trả phí.)\n\nMã an toàn của bạn và việc gửi tín hiệu an toàn hiện đang sử dụng sẽ được giữ nguyên và vẫn miễn phí.',
    's_to_gs_dialog_confirm': 'Tiếp tục',
    's_to_gs_switch_failed': 'Không thể bật tính năng Người bảo vệ',

    // ── Thong bao nguoi bao ve ──
    'notifications_title': 'Thong bao',
    'notifications_today': 'Thong bao hom nay',
    'notifications_empty': 'Khong co thong bao hom nay',
    'notifications_delete_all_title': 'Xoa tat ca thong bao',
    'notifications_auto_delete_notice': 'Thông báo hôm nay sẽ tự động bị xóa vào nửa đêm (0:00).',
    'notifications_delete_all_message': 'Xoa tat ca thong bao hom nay?',
    'notifications_delete_failed': 'Khong the xoa thong bao.',
    'notifications_guide_title': 'Huong dan cap do thong bao',
    'notifications_level_health': 'Binh thuong',
    'notifications_level_health_desc':
        'Suc khoe cua nguoi duoc bao ve da duoc xac nhan binh thuong',
    'notifications_level_caution': 'Chu y',
    'notifications_level_caution_desc': 'Chưa có tín hiệu an toàn hoặc bản ghi hoạt động',
    'notifications_level_warning': 'Canh bao',
    'notifications_level_warning_desc':
        'Không có tín hiệu an toàn hoặc bản ghi hoạt động trong nhiều ngày liên tiếp',
    'notifications_level_urgent': 'Khan cap',
    'notifications_level_urgent_desc': 'Cần kiểm tra ngay bây giờ',
    'notifications_level_info': 'Thong tin',
    'notifications_level_info_desc': 'Số bước, pin yếu và thông báo tham khảo khác',
    'notifications_activity_note':
        '※ Thong tin hoat dong co the khong hien thi neu khong thu thap duoc du lieu buoc chan.',

    // ── Cai dat thong bao nguoi bao ve ──
    'notification_settings_title': 'Cai dat thong bao',
    'notification_settings_push': 'Thong bao day',
    'notification_settings_all': 'Tat ca thong bao',
    'notification_settings_all_desc': 'Bat hoac tat tat ca cac loai thong bao cung mot luc.',
    'notification_settings_level_section': 'Cai dat theo cap do',
    'notification_settings_urgent': 'Canh bao khan cap',
    'notification_settings_urgent_desc': 'Khong the tat canh bao khan cap',
    'notification_settings_warning': 'Canh bao muc do cao',
    'notification_settings_warning_desc': 'Canh bao khi khong kiem tra trong 2 ngay lien tiep',
    'notification_settings_caution': 'Canh bao chu y',
    'notification_settings_caution_desc': 'Canh bao khi chua kiem tra hom nay',
    'notification_settings_info': 'Thong bao thong tin',
    'notification_settings_info_desc': 'Thong bao chung nhu so buoc chan va tinh trang pin',
    'notification_settings_dnd': 'Khong lam phien',
    'notification_settings_dnd_start': 'Thoi gian bat dau',
    'notification_settings_dnd_end': 'Thoi gian ket thuc',
    'notification_settings_dnd_note':
        '※ Canh bao khan cap van duoc gui trong che do Khong lam phien',
    'notification_settings_dnd_start_default': '22:00',
    'notification_settings_dnd_end_default': '7:00',

    // ── Quan ly ket noi nguoi bao ve ──
    'connection_title': 'Quan ly ket noi',
    'connection_managed_count': 'So nguoi duoc bao ve ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Nguoi duoc bao ve da ket noi',
    'connection_reorder_hint': 'Nhấn giữ thẻ bên dưới để sắp xếp lại',
    'connection_empty': 'Không có đối tượng bảo vệ nào được kết nối',
    'connection_unlink_warning': 'Ngat ket noi se xoa du lieu cua nguoi duoc bao ve.',
    'connection_unlink_warning_detail':
        'Cac ban ghi truoc do khong the khoi phuc sau khi ket noi lai. Ban se can nhap lai ma cua nguoi duoc bao ve.',
    'connection_heartbeat_schedule': 'Hang ngay luc @time',
    'connection_heartbeat_report_time': 'Thoi gian bao cao suc khoe: ',
    'connection_subject_label': 'Nguoi duoc bao ve',
    'connection_change_only_in_app': 'chi co the thay doi trong ung dung',
    'connection_edit_title': 'Chinh sua nguoi duoc bao ve',
    'connection_alias_label': 'Ten goi',
    'connection_unlink_title': 'Ngat ket noi',
    'connection_unlink_confirm': 'Ngat ket noi @alias?',
    'connection_unlink_success': 'Da ngat ket noi thanh cong.',
    'connection_unlink_failed': 'Khong the ngat ket noi.',
    'connection_load_failed': 'Khong the tai danh sach.',

    // ── Thanh dieu huong duoi nguoi bao ve ──
    'nav_home': 'Trang chu',
    'nav_connection': 'Ket noi',
    'nav_notification': 'Canh bao',
    'nav_settings': 'Cai dat',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'Doi thoi gian kiem tra',
    'heartbeat_schedule_title_ios': 'Thời gian thông báo đẩy an toàn',
    'heartbeat_schedule_change_title_ios': 'Đổi thời gian thông báo đẩy an toàn',
    'heartbeat_schedule_hint_ios':
        'Thông báo đẩy an toàn sẽ đến vào thời điểm này mỗi ngày. Chạm vào thông báo hoặc mở ứng dụng quanh thời điểm đó để gửi tín hiệu an toàn.',
    'heartbeat_daily_time': 'Hang ngay luc @time',
    'heartbeat_scheduled_today':
        'Tin hieu an toan cua ban se duoc gui den nguoi bao ve moi ngay luc @time.',
    'heartbeat_change_failed_title': 'Doi thoi gian that bai',
    'heartbeat_change_failed_message': 'Khong the cap nhat tren may chu.',

    // ── Thong bao cuc bo ──
    'local_notification_channel': 'Canh bao suc khoe',
    'local_notification_channel_desc': 'Thong bao dich vu kiem tra suc khoe',

    // ── Khac ──
    'back_press_exit': 'Nhan lai de thoat.',

    // ── Loi API ──
    'error_unknown': 'Da xay ra loi khong xac dinh.',
    'error_timeout': 'Yeu cau da het thoi gian.',
    'error_network': 'Vui long kiem tra ket noi mang.',
    'error_unauthorized': 'Can xac thuc.',

    // ── Noi dung thong bao ──
    'noti_auto_report_body': 'Kiem tra suc khoe da duoc nhan thanh cong.',
    'noti_manual_report_body': 'Nguoi duoc bao ve da gui kiem tra suc khoe thu cong.',
    'noti_battery_low_body': 'Pin dien thoai duoi 20%. Co the can sac.',
    'noti_battery_dead_body':
        'Dien thoai co ve da tat do het pin. Muc pin cuoi: @battery_level%. Se phuc hoi sau khi sac.',
    'noti_caution_suspicious_body':
        'Da nhan tin hieu suc khoe nhung hom nay khong phat hien ban ghi hoat dong. Vui long kiem tra truc tiep.',
    'noti_caution_missing_body':
        'Kiem tra suc khoe theo lich hom nay chua duoc nhan. Vui long kiem tra truc tiep.',
    'noti_warning_body': 'Kiem tra suc khoe da bi bo lo lien tiep. Vui long xac minh truc tiep.',
    'noti_warning_suspicious_body':
        'Khong phat hien ban ghi hoat dong lien tiep. Can kiem tra truc tiep.',
    'noti_urgent_body': 'Khong co kiem tra suc khoe trong @days ngay. Can xac minh ngay lap tuc.',
    'noti_urgent_suspicious_body':
        'Khong phat hien ban ghi hoat dong trong @days ngay. Can xac minh ngay lap tuc.',
    'noti_steps_body': 'Hom nay da di @steps buoc.',
    'noti_emergency_body':
        'Người được bảo vệ đã trực tiếp yêu cầu giúp đỡ. Vui lòng kiểm tra ngay.',
    'noti_resolved_body': 'Kiểm tra sức khỏe của người được bảo vệ đã trở lại bình thường.',
    'noti_cleared_by_guardian_title': '✅ Xác nhận an toàn',
    'noti_cleared_by_guardian_body': 'Một trong các người bảo vệ đã trực tiếp xác nhận sự an toàn.',

    // ── Thông báo cục bộ ──
    'local_alarm_title': '💗 Cần kiểm tra sức khỏe',
    'local_alarm_body': 'Vui lòng chạm vào thông báo này.',
    'wellbeing_check_title': '💛 Kiểm tra sức khỏe',
    'wellbeing_check_body': 'Bạn có khỏe không? Vui lòng chạm vào thông báo này.',
    'noti_channel_name': 'Cảnh báo Anbu',
    'notification_send_failed_title': '📶 Vui lòng kiểm tra kết nối Internet',
    'notification_send_failed_body': 'Chạm vào tin nhắn này để gửi lại tự động.',
  };
}
