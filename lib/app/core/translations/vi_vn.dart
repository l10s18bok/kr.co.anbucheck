abstract class ViVn {
  static const Map<String, String> translations = {
    // ── Chung ──
    'common_confirm': 'Xác nhận',
    'common_cancel': 'Hủy',
    'common_continue': 'Tiếp tục',
    'common_save': 'Lưu',
    'common_delete': 'Xóa',
    'common_close': 'Đóng',
    'common_next': 'Tiếp theo',
    'common_previous': 'Quay lại',
    'common_start': 'Bắt đầu',
    'common_skip': 'Bỏ qua',
    'common_later': 'Để sau',
    'common_loading': 'Đang tải...',
    'common_error': 'Lỗi',
    'common_session_expired': 'Thông tin tài khoản đã hết hạn. Vui lòng đăng ký lại.',
    'common_complete': 'Hoàn thành',
    'common_notice': 'Thông báo',
    'common_unlink': 'Ngắt kết nối',
    'common_am': 'SA',
    'common_pm': 'CH',
    'common_time_style': 'h24',
    'common_normal': 'Bình thường',
    'common_connected': 'Đã kết nối',
    'common_disconnected': 'Mất kết nối',

    // ── Thuong hieu ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Kiểm tra bình an của bạn.',
    'app_service_desc': 'Dịch vụ kiểm tra bình an tự động',
    'app_guardian_title': 'Người bảo vệ Anbu',
    'app_copyright': '© 2026 Averic Lab',

    // ── Splash ──
    'splash_loading': 'Đang kiểm tra bình an...',

    // ── Cap nhat ──
    'update_required_title': 'Cần cập nhật',
    'update_required_message':
        'Vui lòng cập nhật lên phiên bản @version để tiếp tục sử dụng ứng dụng.',
    'update_button': 'Cập nhật',
    'update_available_title': 'Có bản cập nhật mới',
    'update_available_message': 'Phiên bản @version đã có sẵn.',
    'update_later_button': 'Để sau',

    // ── Chon che do ──
    'mode_select_title': 'Bạn muốn bắt đầu thế nào?',
    'mode_select_subtitle': 'Cho chúng tôi biết bạn báo tin bình an hay nhận tin',
    'mode_subject_title': 'Tôi chỉ muốn báo tin bình an',
    'mode_subject_desc': 'Màn hình rất đơn giản, chỉ gồm những gì cần thiết',
    'mode_subject_button': 'Báo tin bình an →',
    'mode_guardian_title': 'Có thể trông nom nhiều người cùng lúc',
    'mode_guardian_desc': 'Khi cần, bạn cũng có thể báo tin bình an của mình sau',
    'mode_guardian_button': 'Nhận tin bình an →',
    'mode_subject_badge': 'Người cao tuổi',
    'mode_guardian_badge': 'Người bảo vệ',
    'mode_select_notice': 'Giao diện sẽ khác nhau tùy theo lựa chọn của bạn',

    // ── Quyen ──
    'permission_title': 'Cần cấp quyền\nđể sử dụng ứng dụng',
    'permission_notification': 'Quyền thông báo',
    'permission_notification_subject_desc': 'Cần thiết để nhận thông báo kiểm tra bình an',
    'permission_notification_guardian_desc':
        'Cần thiết để nhận thông báo về tình trạng an toàn của người được bảo vệ',
    'permission_activity': 'Nhận diện hoạt động',
    'permission_activity_desc': 'Dùng để phát hiện bước chân và xác nhận hoạt động',
    'permission_location': 'Vị trí',
    'permission_location_desc': 'Chỉ gửi vị trí đến người bảo vệ khi yêu cầu cứu giúp khẩn cấp',
    'permission_tracking': 'Theo dõi quảng cáo',
    'permission_tracking_desc': 'Dùng để hiển thị quảng cáo cá nhân hóa',
    'location_permission_warning':
        'Vị trí sẽ không được gửi khi yêu cầu cứu giúp khẩn cấp. Chạm để cho phép.',
    'location_permission_settings_title': 'Cần quyền vị trí',
    'location_permission_settings_body_ios':
        "Tìm và chọn 'Anbu', sau đó trong mục 'Vị trí' chọn 'Khi đang sử dụng ứng dụng'.",
    'location_permission_settings_body_android':
        "Chọn 'Quyền' → 'Vị trí', sau đó chọn 'Chỉ cho phép khi đang sử dụng ứng dụng'.",
    'permission_activity_dialog_title': 'Thông tin quyền hoạt động',
    'permission_activity_dialog_message':
        'Dùng để phát hiện bước chân và xác nhận hoạt động.\nVui lòng nhấn "Cho phép" trên màn hình tiếp theo.',
    'permission_notification_required_title': 'Cần quyền thông báo',
    'permission_notification_required_message':
        'Quyền thông báo là bắt buộc cho dịch vụ kiểm tra bình an.\nVui lòng bật trong Cài đặt.',
    'permission_go_to_settings': 'Đi đến Cài đặt',
    'permission_activity_denied_title': 'Cần quyền hoạt động thể chất',
    'permission_activity_denied_message':
        'Quyền hoạt động thể chất cần thiết để phát hiện bước chân và xác minh sự an toàn của bạn.\n\nNếu không có quyền này, thông tin bước chân sẽ không được gửi đến người bảo vệ.\n\nVui lòng bật quyền "Hoạt động thể chất" trong cài đặt ứng dụng.',
    'permission_battery': 'Loại trừ tối ưu hóa pin',
    'permission_battery_desc':
        'Loại trừ ứng dụng khỏi tối ưu hóa pin để kiểm tra bình an hàng ngày không bị bỏ lỡ vào giờ đã định',
    'permission_hibernation_title': 'Hãy tắt tính năng tự động xóa quyền',
    'permission_hibernation_highlight': 'tự động xóa quyền',
    'permission_hibernation_message':
        'Android tự động xóa quyền của các ứng dụng bạn không sử dụng trong thời gian dài. Anbu thường hoạt động mà không cần bạn mở, nên tính năng này có thể khiến quyền biến mất sau một thời gian và làm ngưng việc gửi tín hiệu bình an.\n\nNhấn [Mở cài đặt] bên dưới — màn hình công tắc tương ứng sẽ xuất hiện trực tiếp. Hãy tắt công tắc.\n\n※ Cách hiển thị có thể khác nhau tùy theo nhà sản xuất thiết bị.',
    'permission_hibernation_go_to_settings': 'Mở cài đặt',
    'stability_battery_warning_short': 'Cần tắt giới hạn sử dụng pin',
    'stability_battery_dialog_title': 'Tắt giới hạn sử dụng pin',
    'stability_battery_dialog_message':
        'Khi điện thoại của bạn vào chế độ tiết kiệm pin, tín hiệu bình an gửi đến người bảo vệ có thể đến muộn hoặc bị mất.\n\nSau khi nhấn [Mở cài đặt] bên dưới, hãy đặt "Pin" → "Không giới hạn". Khi đó, tín hiệu bình an sẽ được gửi một cách đáng tin cậy vào giờ đã định mỗi ngày.\n\n※ Cách hiển thị có thể khác nhau tùy theo nhà sản xuất thiết bị.',

    // ── Gioi thieu ──
    'onboarding_safety_code_title': 'Mã an toàn được tạo tự động',
    'onboarding_safety_code_desc':
        'Chia sẻ mã này với người bảo vệ để kết nối —\ntín hiệu bình an của bạn sẽ được gửi tự động.',
    'onboarding_emergency_title': 'Khi bạn muốn báo tình trạng (Khẩn cấp) và vị trí hiện tại',
    'onboarding_emergency_desc': 'Nhấn nút này, tin sẽ được gửi\nngay đến tất cả người bảo vệ',
    'onboarding_gs_switch_title': 'Hãy cùng chăm sóc sự bình an của gia đình',
    'onboarding_gs_switch_desc':
        'Nhấn [Quản lý cả sự bình an của gia đình] trong menu\nđể dùng luôn vai trò người bảo vệ',
    'onboarding_add_subject_title': 'Kết nối với người bạn quan tâm',
    'onboarding_add_subject_desc': 'Nhập mã đã nhận và một biệt danh\nlà kết nối xong ngay',
    'onboarding_notifications_title': 'Thông báo bình an hiển thị như thế này',
    'onboarding_notifications_desc':
        'Bình thường sẽ hiện thông tin hoạt động như số bước chân, còn khi tín hiệu không đến hoặc không phát hiện hoạt động thì bạn sẽ nhận được thông báo như trên',
    'onboarding_push_now': 'Bây giờ',
    'onboarding_gs_enable_title': 'Kích hoạt mã an toàn của riêng bạn',
    'onboarding_gs_enable_desc':
        'Trong Cài đặt, nhấn [Tạo mã an toàn của tôi]\nđể bình an của bạn cũng được gửi đến người bảo vệ',
    'onboarding_role_subject': 'Người được bảo vệ',
    'onboarding_role_guardian': 'Người bảo vệ',
    'onboarding_role_guardian_subject': 'Người bảo vệ và người được bảo vệ',
    'onboarding_already_registered_title': 'Thiết bị đã được đăng ký',
    'onboarding_already_registered_message':
        'Thiết bị này đã được đăng ký ở chế độ "@roleLabel".\nTiếp tục với "@roleLabel"?\n\nHay chuyển sang chế độ "@newRoleLabel"?\nChuyển đổi sẽ xóa tất cả dữ liệu hiện có.',
    'onboarding_already_registered_message_gs':
        'Thiết bị này đã được đăng ký ở chế độ "@roleLabel".\nChuyển sang chế độ "@newRoleLabel" sẽ xóa tất cả dữ liệu người bảo vệ và người được bảo vệ.',
    'onboarding_registration_failed_title': 'Đăng ký thất bại',
    'onboarding_registration_failed_message':
        'Không thể kết nối đến máy chủ. Vui lòng thử lại sau.',

    // ── Trang chu nguoi duoc bao ve ──
    'subject_home_share_title': 'Chia sẻ mã an toàn của bạn',
    'subject_home_guardian_count': 'Người bảo vệ đã kết nối: @count',
    'subject_home_check_title_last': 'Lần kiểm tra cuối',
    'subject_home_check_title_scheduled': 'Thời gian kiểm tra đã lên lịch',
    'subject_home_check_title_checking': 'Đang kiểm tra bình an',
    'subject_home_check_body_reported': 'Đã báo cáo lúc @time',
    'subject_home_check_body_scheduled': 'Đã lên lịch lúc @time',
    'subject_home_check_body_waiting': 'Đang chờ từ @time',
    'subject_home_battery_status': 'Tình trạng pin',
    'subject_home_battery_charging': 'Đang sạc',
    'subject_home_battery_full': 'Đầy',
    'subject_home_battery_low': 'Pin yếu',
    'subject_home_connectivity_status': 'Kết nối',
    'subject_home_report_loading': 'Đang báo cáo...',
    'subject_home_report_button': 'Báo cáo an toàn ngay',
    'subject_home_report_desc': 'Cho người bảo vệ biết bạn vẫn khỏe',
    'subject_home_emergency_button': 'Tôi cần giúp đỡ',
    'subject_home_emergency_desc': 'Gửi cảnh báo khẩn cấp đến người bảo vệ',
    'subject_home_emergency_loading': 'Đang gửi cảnh báo khẩn cấp...',
    'subject_home_emergency_sent': 'Cảnh báo khẩn cấp đã được gửi',
    'subject_home_emergency_failed': 'Gửi cảnh báo khẩn cấp thất bại',
    'subject_home_manual_report_limit_reached':
        'Bạn đã gửi báo cáo an toàn hôm nay. Vui lòng thử lại vào ngày mai.',
    'subject_home_manual_report_sent': 'Đã gửi thông báo bình an đến người bảo vệ của bạn.',
    'safety_net_dialog_title': 'Đã gửi thông báo bình an',
    'safety_net_dialog_body':
        'Thông báo bình an hôm nay đã được gửi đến người bảo vệ.',
    'safety_net_dialog_already_body':
        'Thông báo bình an hôm nay đã được gửi đến người bảo vệ vào lúc @time.',
    'subject_home_emergency_confirm_title': 'Yêu cầu trợ giúp khẩn cấp',
    'subject_home_emergency_confirm_body':
        'Cảnh báo khẩn cấp sẽ được gửi đến tất cả người bảo vệ.\nVị trí hiện tại của bạn cũng sẽ được chia sẻ.\nBạn có thực sự muốn yêu cầu trợ giúp không?',
    'emergency_sent_with_location': 'Đã gửi cảnh báo khẩn cấp (kèm vị trí)',
    'emergency_sent_without_location': 'Đã gửi cảnh báo khẩn cấp',
    'notifications_view_location': '🗺️ Xem vị trí',
    'emergency_map_title': 'Vị trí khẩn cấp',
    'emergency_map_subject_label': 'Người được bảo vệ',
    'emergency_map_captured_at_label': 'Thời gian ghi nhận',
    'emergency_map_accuracy_label': 'Độ chính xác',
    'emergency_map_open_external': 'Mở trong ứng dụng bản đồ bên ngoài',
    'emergency_map_no_location': 'Không có thông tin vị trí',
    'emergency_location_permission_denied_snackbar':
        'Đã gửi cảnh báo khẩn cấp mà không có quyền vị trí',
    'subject_home_emergency_confirm_send': 'Gửi yêu cầu khẩn cấp',
    'emergency_message_hint': 'Thêm lời nhắn (tùy chọn)',
    'subject_home_share_text': 'Hãy kết nối với tôi trên ứng dụng Anbu.\nMã kết nối: @code',
    'subject_home_share_subject': 'Mã kết nối Anbu',
    'subject_home_code_copied': 'Đã sao chép mã',

    // ── Ngon keo nguoi duoc bao ve ──
    'drawer_light_mode': 'Chế độ sáng',
    'drawer_dark_mode': 'Chế độ tối',
    'drawer_privacy_policy': 'Chính sách bảo mật',
    'drawer_terms': 'Điều khoản sử dụng',
    'drawer_withdraw': 'Xóa tài khoản',
    'drawer_withdraw_message': 'Tài khoản và tất cả dữ liệu sẽ bị xóa.\nBạn có chắc không?',
    'drawer_withdraw_message_trial': 'Thời gian dùng thử miễn phí sẽ không bắt đầu lại nếu bạn đăng ký lại.',

    // ── Bang dieu khien nguoi bao ve ──
    'guardian_status_normal': 'An toàn',
    'guardian_status_caution': 'Chú ý',
    'guardian_status_warning': 'Cảnh báo',
    'guardian_status_urgent': 'Khẩn cấp',
    'guardian_status_confirmed': '✅ An toàn',
    'guardian_subscription_expired': 'Cần đăng ký',
    'guardian_subscription_expired_message':
        'Tin bình an mỗi ngày nay đã dừng lại.\nChỉ với giá một bữa trưa, hãy ở bên người thân suốt cả năm.',
    'guardian_subscribe': 'Đăng ký',
    'guardian_payment_preparing': 'Tính năng thanh toán sắp có.',
    'guardian_today_summary': 'Tóm tắt bình an hôm nay',
    'guardian_no_subjects': 'Chưa có người được bảo vệ nào.',
    'guardian_checking_subjects': 'Đang kiểm tra\n@count người được bảo vệ.',
    'guardian_subject_list': 'Danh sách người được bảo vệ',
    'guardian_call_now': 'Gọi ngay',
    'phone_call_failed': 'Không thể thực hiện cuộc gọi.',
    'guardian_confirm_safety': 'Xác nhận an toàn',
    'guardian_no_check_history': 'Chưa có lịch sử kiểm tra',
    'guardian_last_check_now': 'Lần kiểm tra cuối: vừa xong',
    'guardian_last_check_minutes': 'Lần kiểm tra cuối: @minutes phút trước',
    'guardian_last_check_hours': 'Lần kiểm tra cuối: @hours giờ trước',
    'guardian_last_check_days': 'Lần kiểm tra cuối: @days ngày trước',
    'guardian_activity_stable': 'Hoạt động: Ổn định',
    'guardian_activity_prefix': 'Hoạt động',
    'guardian_activity_very_active': 'Rất năng động',
    'guardian_activity_active': 'Năng động',
    'guardian_activity_needs_exercise': 'Cần vận động',
    'guardian_activity_collecting': 'Đang thu thập dữ liệu',
    'guardian_error_load_step_history': 'Không thể tải lịch sử bước',
    'guardian_my_steps': 'Bước chân của tôi',
    'guardian_chart_y_axis_steps': 'Bước',
    'guardian_chart_x_axis_last_7_days': '7 ngày qua',
    'guardian_chart_x_axis_last_30_days': '30 ngày qua',
    'guardian_chart_today': 'Hôm nay',
    'guardian_safety_needed': 'Cần kiểm tra an toàn',
    'guardian_error_load_subjects': 'Không thể tải danh sách người được bảo vệ.',
    'guardian_safety_confirmed': 'Đã xác nhận an toàn.',
    'guardian_error_clear_alerts': 'Không thể xóa cảnh báo.',

    // ── Them nguoi duoc bao ve ──
    'add_subject_title': 'Kết nối người được bảo vệ',
    'add_subject_guide_title': 'Nhập mã duy nhất của người được bảo vệ và tên gọi.',
    'add_subject_guide_subtitle':
        'Kết nối ứng dụng của người được bảo vệ để theo dõi tình trạng và hoạt động theo thời gian thực.',
    'add_subject_code_label': 'Mã duy nhất (7 ký tự)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info': 'Mã duy nhất có thể tìm thấy trong ứng dụng của người được bảo vệ.',
    'add_subject_alias_label': 'Tên gọi người được bảo vệ',
    'add_subject_alias_hint': 'VD: Mẹ, Bố',
    'add_subject_phone_label': 'Số điện thoại (tùy chọn)',
    'add_subject_phone_info': 'Nếu nhập, nút gọi sẽ gọi trực tiếp đến số này. Nếu để trống, bạn phải tự chọn số trong danh bạ để gọi.',
    'add_subject_phone_hint': '0912345678',
    'add_subject_connect': 'Kết nối',
    'add_subject_error_login': 'Cần đăng nhập.',
    'add_subject_success': 'Kết nối người được bảo vệ thành công.',
    'add_subject_error_invalid_code': 'Mã không hợp lệ.',
    'add_subject_error_self': 'Bạn không thể thêm mã của chính mình làm người được bảo vệ.',
    'add_subject_error_limit': 'Bạn có thể đăng ký tối đa @max người.',
    'add_subject_error_already_connected': 'Đã kết nối rồi.',
    'add_subject_error_failed': 'Kết nối thất bại. Vui lòng thử lại.',
    'add_subject_button': 'Thêm người được bảo vệ mới',

    // ── Cai dat nguoi bao ve ──
    'settings_title': 'Cài đặt',
    'settings_light_mode': 'Chế độ sáng',
    'settings_dark_mode': 'Chế độ tối',
    'settings_connection_management': 'Quản lý kết nối',
    'settings_managed_subjects': 'Số người được bảo vệ',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'Đăng ký & Dịch vụ',
    'settings_current_membership': 'Thành viên hiện tại',
    'settings_premium': 'Premium đang hoạt động',
    'guardian_go_to_settings': 'Đến trang Cài đặt',
    'settings_expired': 'Cần đăng ký',
    'settings_days_until_renewal': 'D-@days',
    'settings_days_until_trial_end': 'D-@days',
    'settings_free_trial': 'Dùng thử miễn phí',
    'settings_manage_subscription': 'Quản lý đăng ký',
    'settings_notification': 'Cài đặt thông báo',
    'settings_terms_section': 'Pháp lý',
    'settings_privacy_policy': 'Chính sách bảo mật',
    'settings_terms': 'Điều khoản sử dụng',
    'settings_ad_consent': 'Cài đặt đồng ý quảng cáo',
    'settings_app_version': 'Phiên bản: v@version',

    // ── Mua trong ứng dụng (gói đăng ký hằng năm $9.99 của Người giám hộ) ──
    'subscription_subscribe': 'Đăng ký',
    'trial_ended_noti_title': 'Anbu',
    'trial_ended_noti_body': 'Bản dùng thử miễn phí đã kết thúc. Vui lòng đăng ký để tiếp tục.',
    'subscription_restore': 'Khôi phục mua hàng',
    'subscription_store_unavailable': 'Không thể kết nối cửa hàng',
    'subscription_product_unavailable': 'Không thể tải thông tin gói',
    'subscription_purchase_failed': 'Thanh toán thất bại',
    'subscription_verify_failed': 'Xác minh đăng ký thất bại',
    'subscription_restore_failed': 'Khôi phục thất bại',
    'subscription_restore_nothing': 'Không có gói đăng ký để khôi phục',
    'subscription_restore_success': 'Đã khôi phục đăng ký',
    'subscription_purchase_success': 'Đã bắt đầu đăng ký',
    'subscription_period_annual': 'năm',

    // ── G+S (Người giám hộ + Được bảo vệ) ──
    'gs_enable_button': 'Tạo mã an toàn của tôi',
    'gs_safety_code_button': 'Xem mã an toàn của tôi',
    'gs_enable_button_desc': 'Gia đình cũng có thể kiểm tra bạn',
    'gs_safety_code_button_desc': 'Chia sẻ mã · Báo cáo · Khẩn cấp',
    'gs_safety_code_title': 'Mã an toàn của tôi',
    'gs_enable_dialog_title': 'Tạo mã an toàn của tôi',
    'gs_enable_dialog_body':
        'Mã an toàn sẽ được cấp — hãy chia sẻ với người bảo vệ khác.',
    'gs_enable_dialog_ios_warning_title': '⚠ Cách gửi tín hiệu bình an của bạn',
    'gs_enable_dialog_ios_warning_body':
        '"Thông báo đẩy bình an" sẽ hiển thị mỗi ngày vào thời điểm đã định. Bạn phải chạm vào thông báo hoặc tự mở ứng dụng quanh thời điểm đó để tín hiệu bình an được gửi đi. Nếu bạn không mở ứng dụng, người bảo vệ của bạn có thể nhận được cảnh báo bỏ lỡ kiểm tra.',
    'gs_enable_dialog_ios_confirm': 'Đã hiểu, kích hoạt',
    'gs_enable_confirm': 'Tạo',
    'gs_enabled_message': 'Bảo vệ đã được kích hoạt',
    'gs_enable_failed': 'Không thể kích hoạt bảo vệ',
    'gs_disable_dialog_title': 'Tắt bảo vệ',
    'gs_disable_dialog_body':
        'Tắt bảo vệ sẽ xóa mã an toàn của bạn và ngừng gửi kiểm tra bình an cho người bảo vệ đã kết nối.',
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
    'drawer_enable_guardian': 'Quản lý cả sự bình an của gia đình',
    's_to_gs_dialog_title': 'Thêm tính năng Người bảo vệ',
    's_to_gs_dialog_body':
        'Thêm tính năng Người bảo vệ để cũng có thể theo dõi sự bình an của gia đình hoặc những người thân yêu.\n(Lưu ý: Tính năng Người bảo vệ miễn phí trong 3 tháng, sau đó chuyển sang gói đăng ký trả phí.)\n\nMã an toàn của bạn và việc gửi tín hiệu bình an hiện đang sử dụng sẽ được giữ nguyên và vẫn miễn phí.',
    's_to_gs_dialog_confirm': 'Tiếp tục',
    's_to_gs_switch_failed': 'Không thể bật tính năng Người bảo vệ',

    // ── Thong bao nguoi bao ve ──
    'notifications_title': 'Thông báo',
    'notifications_today': 'Thông báo hôm nay',
    'notifications_empty': 'Không có thông báo hôm nay',
    'notifications_delete_all_title': 'Xóa tất cả thông báo',
    'notifications_auto_delete_notice': 'Thông báo hôm nay sẽ tự động bị xóa vào nửa đêm (0:00).',
    'notifications_delete_all_message': 'Xóa tất cả thông báo hôm nay?',
    'notifications_delete_failed': 'Không thể xóa thông báo.',
    'notifications_guide_title': 'Hướng dẫn cấp độ thông báo',
    'notifications_level_health': 'Bình thường',
    'notifications_level_health_desc':
        'Bình an của người được bảo vệ đã được xác nhận',
    'notifications_level_caution': 'Chú ý',
    'notifications_level_caution_desc': 'Chưa có tín hiệu an toàn hoặc bản ghi hoạt động',
    'notifications_level_warning': 'Cảnh báo',
    'notifications_level_warning_desc':
        'Không có tín hiệu an toàn hoặc bản ghi hoạt động trong nhiều ngày liên tiếp',
    'notifications_level_urgent': 'Khẩn cấp',
    'notifications_level_urgent_desc': 'Cần kiểm tra ngay bây giờ',
    'notifications_level_info': 'Thông tin',
    'notifications_level_info_desc': 'Số bước, pin yếu và thông báo tham khảo khác',
    'notifications_activity_note':
        '※ Số bước là tổng số bước tích lũy từ nửa đêm đến thời điểm gửi tín hiệu bình an.',

    // ── Cai dat thong bao nguoi bao ve ──
    'notification_settings_title': 'Cài đặt thông báo',
    'notification_settings_push': 'Thông báo đẩy',
    'notification_settings_all': 'Tất cả thông báo',
    'notification_settings_all_desc': 'Bật hoặc tắt tất cả các loại thông báo cùng một lúc.',
    'notification_settings_level_section': 'Cài đặt theo cấp độ',
    'notification_settings_urgent': 'Cảnh báo khẩn cấp',
    'notification_settings_urgent_desc': 'Không thể tắt cảnh báo khẩn cấp',
    'notification_settings_warning': 'Cảnh báo mức độ cao',
    'notification_settings_warning_desc': 'Cảnh báo khi không kiểm tra trong 2 ngày liên tiếp',
    'notification_settings_caution': 'Cảnh báo chú ý',
    'notification_settings_caution_desc': 'Cảnh báo khi chưa kiểm tra hôm nay',
    'notification_settings_info': 'Thông báo thông tin',
    'notification_settings_info_desc': 'Thông báo chung như số bước chân và tình trạng pin',
    'notification_settings_dnd': 'Không làm phiền',
    'notification_settings_dnd_start': 'Thời gian bắt đầu',
    'notification_settings_dnd_end': 'Thời gian kết thúc',
    'notification_settings_dnd_note':
        '※ Cảnh báo khẩn cấp vẫn được gửi trong chế độ Không làm phiền',

    // ── Quan ly ket noi nguoi bao ve ──
    'connection_title': 'Quản lý kết nối',
    'connection_managed_count': 'Số người được bảo vệ ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Người được bảo vệ đã kết nối',
    'connection_reorder_hint': 'Nhấn giữ thẻ bên dưới để sắp xếp lại',
    'connection_empty': 'Không có người được bảo vệ nào được kết nối',
    'connection_unlink_warning': 'Ngắt kết nối sẽ xóa dữ liệu của người được bảo vệ.',
    'connection_unlink_warning_detail':
        'Các bản ghi trước đó không thể khôi phục sau khi kết nối lại. Bạn sẽ cần nhập lại mã của người được bảo vệ.',
    'connection_heartbeat_schedule': 'Hằng ngày lúc @time',
    'connection_heartbeat_report_time': 'Thời gian báo cáo bình an: ',
    'connection_subject_label': 'Người được bảo vệ',
    'connection_change_only_in_app': 'chỉ có thể thay đổi trong ứng dụng',
    'connection_edit_title': 'Chỉnh sửa người được bảo vệ',
    'connection_alias_label': 'Tên gọi',
    'connection_unlink_title': 'Ngắt kết nối',
    'connection_unlink_confirm': 'Ngắt kết nối @alias?',
    'connection_unlink_success': 'Đã ngắt kết nối thành công.',
    'connection_unlink_failed': 'Không thể ngắt kết nối.',
    'connection_load_failed': 'Không thể tải danh sách.',

    // ── Thanh dieu huong duoi nguoi bao ve ──
    'nav_home': 'Trang chủ',
    'nav_connection': 'Kết nối',
    'nav_notification': 'Cảnh báo',
    'nav_settings': 'Cài đặt',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'Đổi giờ báo bình an',
    'heartbeat_schedule_title_ios': 'Giờ báo bình an',
    'heartbeat_schedule_change_title_ios': 'Đổi giờ báo bình an',
    'heartbeat_schedule_hint_ios':
        'Thông báo đẩy bình an sẽ đến vào thời điểm này mỗi ngày. Chạm vào thông báo hoặc mở ứng dụng quanh thời điểm đó để gửi tín hiệu bình an.',
    'heartbeat_daily_time': 'Hằng ngày lúc @time',
    'heartbeat_scheduled_today':
        'Tín hiệu bình an của bạn sẽ được gửi đến người bảo vệ mỗi ngày lúc @time.',
    'heartbeat_change_failed_title': 'Đổi thời gian thất bại',
    'heartbeat_change_failed_message': 'Không thể cập nhật trên máy chủ.',
    'heartbeat_picker_help': 'Chọn thời gian trước @limit',
    'heartbeat_range_limit_title': 'Thời gian không khả dụng',
    'heartbeat_range_limit_message':
        'Thời gian kiểm tra phải trước @limit.',

    // ── Thong bao cuc bo ──
    'local_notification_channel_desc': 'Thông báo dịch vụ kiểm tra bình an',

    // ── Khac ──
    'back_press_exit': 'Nhấn lại để thoát.',

    // ── Loi API ──
    'error_unknown': 'Đã xảy ra lỗi không xác định.',
    'error_timeout': 'Yêu cầu đã hết thời gian.',
    'error_network': 'Vui lòng kiểm tra kết nối mạng.',
    'error_unauthorized': 'Cần xác thực.',

    // ── Noi dung thong bao ──
    'noti_auto_report_body': 'Kiểm tra bình an đã được nhận thành công.',
    'noti_manual_report_body': 'Người được bảo vệ đã gửi kiểm tra bình an thủ công.',
    'noti_battery_low_body': 'Pin điện thoại dưới 20%. Có thể cần sạc.',
    'noti_battery_dead_body':
        'Điện thoại có vẻ đã tắt do hết pin. Mức pin cuối: @battery_level%. Sẽ phục hồi sau khi sạc.',
    'noti_caution_suspicious_body':
        'Đã nhận tín hiệu bình an nhưng hôm nay không phát hiện bản ghi hoạt động. Vui lòng kiểm tra trực tiếp.',
    'noti_caution_missing_body':
        'Kiểm tra bình an theo lịch hôm nay chưa được nhận. Vui lòng kiểm tra trực tiếp.',
    'noti_warning_body': 'Kiểm tra bình an đã bị bỏ lỡ liên tiếp. Vui lòng xác minh trực tiếp.',
    'noti_warning_suspicious_body':
        'Không phát hiện bản ghi hoạt động liên tiếp. Cần kiểm tra trực tiếp.',
    'noti_urgent_body': 'Không có kiểm tra bình an trong @days ngày. Cần xác minh ngay lập tức.',
    'noti_urgent_suspicious_body':
        'Không phát hiện bản ghi hoạt động trong @days ngày. Cần xác minh ngay lập tức.',
    'noti_steps_body': 'Hôm nay đã đi @steps bước.',
    'noti_emergency_body':
        'Người được bảo vệ đã trực tiếp yêu cầu giúp đỡ. Vui lòng kiểm tra ngay.',
    'noti_resolved_body': 'Bình an của người được bảo vệ đã trở lại bình thường.',
    'noti_cleared_by_guardian_title': '✅ Xác nhận an toàn',
    'noti_cleared_by_guardian_body': 'Một trong các người bảo vệ đã trực tiếp xác nhận sự an toàn.',

    // ── Thông báo cục bộ ──
    'local_alarm_title': '💗 Cần kiểm tra bình an',
    'local_alarm_body': 'Vui lòng chạm vào thông báo này.',
    // ── iOS 확장 전송 결과 / 오프라인 폴백 ──
    'nse_delivered_title': '✅ Đã gửi thông tin an toàn',
    'nse_delivered_body': 'Thông tin an toàn hôm nay đã được gửi đến người thân của bạn.',
    'offline_alarm_title': '💗 Thông tin hôm nay chưa được gửi',
    'offline_alarm_body': 'Hãy chạm vào thông báo này một lần.\nKhi chạm, thông tin sẽ được gửi đến người thân của bạn.',
    'wellbeing_check_title': '💛 Kiểm tra bình an',
    'wellbeing_check_body': 'Bạn có khỏe không? Vui lòng chạm vào thông báo này.',
    'noti_channel_name': 'Cảnh báo Anbu',
    'notification_send_failed_title': '📶 Vui lòng kiểm tra kết nối Internet',
    'notification_send_failed_body': 'Chạm vào tin nhắn này để gửi lại tự động.',
  };
}
