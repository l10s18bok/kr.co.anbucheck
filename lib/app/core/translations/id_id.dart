abstract class IdId {
  static const Map<String, String> translations = {
    // ── Umum ──
    'common_confirm': 'Konfirmasi',
    'common_cancel': 'Batal',
    'common_continue': 'Lanjutkan',
    'common_save': 'Simpan',
    'common_delete': 'Hapus',
    'common_close': 'Tutup',
    'common_next': 'Berikutnya',
    'common_previous': 'Sebelumnya',
    'common_start': 'Mulai',
    'common_skip': 'Lewati',
    'common_later': 'Nanti',
    'common_loading': 'Memuat...',
    'common_error': 'Kesalahan',
    'common_complete': 'Selesai',
    'common_notice': 'Pemberitahuan',
    'common_unlink': 'Putuskan',
    'common_am': 'pagi',
    'common_pm': 'sore',
    'common_normal': 'Normal',
    'common_connected': 'Terhubung',
    'common_disconnected': 'Tidak terhubung',

    // ── Merek Aplikasi ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Memantau kesejahteraan Anda.',
    'app_service_desc': 'Layanan pemeriksaan kesejahteraan otomatis',
    'app_guardian_title': 'Penjaga Anbu',
    'app_copyright': '© 2024 TNS Inc.',

    // ── Splash ──
    'splash_loading': 'Memeriksa kesejahteraan...',

    // ── Pembaruan ──
    'update_required_title': 'Pembaruan diperlukan',
    'update_required_message':
        'Silakan perbarui ke versi @version untuk melanjutkan menggunakan aplikasi.',
    'update_button': 'Perbarui',
    'update_available_title': 'Pembaruan tersedia',
    'update_available_message': 'Versi @version tersedia.',

    // ── Pilih Mode ──
    'mode_select_title': 'Pilih peran Anda',
    'mode_select_subtitle':
        'Ini membantu kami menyiapkan fitur yang tepat untuk Anda',
    'mode_subject_title': 'Saya ingin keselamatan saya\ndipantau',
    'mode_subject_button': 'Dilindungi →',
    'mode_guardian_title': 'Saya ingin menjaga\norang yang saya sayangi',
    'mode_guardian_button': 'Mulai sebagai penjaga →',
    'mode_select_notice':
        'Tampilan layar dan notifikasi akan berbeda berdasarkan pilihan Anda',

    // ── Izin ──
    'permission_title': 'Izin diperlukan\nuntuk menggunakan aplikasi',
    'permission_notification': 'Izin Notifikasi',
    'permission_notification_subject_desc':
        'Diperlukan untuk menerima notifikasi pemeriksaan kesejahteraan',
    'permission_notification_guardian_desc':
        'Diperlukan untuk menerima notifikasi status keselamatan orang yang dilindungi',
    'permission_activity': 'Pengenalan Aktivitas',
    'permission_activity_desc':
        'Digunakan untuk mendeteksi langkah dan memastikan aktivitas',
    'permission_activity_dialog_title': 'Info Izin Aktivitas',
    'permission_activity_dialog_message':
        'Digunakan untuk mendeteksi langkah dan memastikan aktivitas.\nSilakan ketuk "Izinkan" di layar berikutnya.',
    'permission_notification_required_title': 'Izin Notifikasi Diperlukan',
    'permission_notification_required_message':
        'Izin notifikasi diperlukan untuk layanan pemeriksaan kesejahteraan.\nSilakan aktifkan di Pengaturan.',
    'permission_go_to_settings': 'Buka Pengaturan',
    'permission_activity_denied_title': 'Izin Aktivitas Fisik Diperlukan',
    'permission_activity_denied_message':
        'Izin aktivitas fisik diperlukan untuk mendeteksi langkah dan memverifikasi keselamatan Anda.\n\nTanpa izin ini, informasi langkah tidak akan dikirim ke wali.\n\nSilakan aktifkan izin "Aktivitas Fisik" di pengaturan aplikasi.',
    'permission_battery': 'Pengecualian Pengoptimalan Baterai',
    'permission_battery_desc':
        'Mengecualikan aplikasi dari pengoptimalan baterai agar pemeriksaan kesejahteraan harian tidak terlewat pada waktu yang dijadwalkan',
    'permission_battery_required_title': 'Harap atur Baterai ke "Tidak Dibatasi"',
    'permission_battery_required_message':
        'Jika diatur ke "Pengoptimalan Baterai" atau "Penghemat Baterai",\npemeriksaan kesejahteraan harian dapat tertunda atau terlewat.\n\nSetelah mengetuk [Buka Pengaturan]:\n1. Pilih "Baterai"\n2. Ubah menjadi "Tidak Dibatasi"',
    'permission_battery_go_to_settings': 'Buka Pengaturan',

    // ── Onboarding ──
    'onboarding_title_1': 'Khawatir tentang seseorang\nyang tinggal sendiri?',
    'onboarding_desc_1':
        'Meski dari jauh,\nAnda ingin tahu apakah mereka baik-baik saja.\nAnbu ada bersama Anda.',
    'onboarding_title_2': 'Pemeriksaan kesejahteraan\ntanpa sepatah kata pun',
    'onboarding_desc_2':
        'Cukup dengan menggunakan smartphone,\nsinyal kesejahteraan harian\ndikirim secara otomatis.',
    'onboarding_title_3': 'Bagikan kepedulian\ndengan orang tersayang',
    'onboarding_desc_3':
        'Pemeriksaan harian membangun\nketenangan pikiran yang berkelanjutan.\nMari mulai.',
    'onboarding_title_4':
        'Tanpa nama, tanpa nomor telepon\n— tidak ada yang dikumpulkan',
    'onboarding_desc_4':
        'Hanya satu sinyal yang dikirim:\n"Saya baik-baik saja."\nInformasi Anda tetap aman.',
    'onboarding_role_subject': 'Orang yang Dilindungi',
    'onboarding_role_guardian': 'Penjaga',
    'onboarding_role_guardian_subject': 'Penjaga dan yang dilindungi',
    'onboarding_already_registered_title': 'Perangkat Sudah Terdaftar',
    'onboarding_already_registered_message':
        'Perangkat ini sudah terdaftar dalam mode "@roleLabel".\nLanjutkan sebagai "@roleLabel"?\n\nAtau beralih ke mode "@newRoleLabel"?\nBeralih akan menghapus semua data yang ada.',
    'onboarding_already_registered_message_gs':
        'Perangkat ini sudah terdaftar dalam mode "@roleLabel".\nBeralih ke mode "@newRoleLabel" akan menghapus semua data penjaga dan yang dilindungi.',
    'onboarding_registration_failed_title': 'Pendaftaran Gagal',
    'onboarding_registration_failed_message':
        'Tidak dapat terhubung ke server. Silakan coba lagi nanti.',

    // ── Beranda Orang yang Dilindungi ──
    'subject_home_share_title': 'Bagikan kode keselamatan Anda',
    'subject_home_guardian_count': 'Penjaga terhubung: @count',
    'subject_home_check_title_last': 'Pemeriksaan terakhir',
    'subject_home_check_title_scheduled': 'Waktu pemeriksaan terjadwal',
    'subject_home_check_title_checking': 'Memeriksa kesejahteraan',
    'subject_home_check_body_reported': 'Dilaporkan pada @time',
    'subject_home_check_body_scheduled': 'Dijadwalkan pada @time',
    'subject_home_check_body_waiting': 'Menunggu sejak @time',
    'subject_home_battery_status': 'Status Baterai',
    'subject_home_battery_charging': 'Mengisi daya',
    'subject_home_battery_full': 'Penuh',
    'subject_home_battery_low': 'Baterai Lemah',
    'subject_home_connectivity_status': 'Konektivitas',
    'subject_home_report_loading': 'Melaporkan...',
    'subject_home_report_button': 'Laporkan Keselamatan Sekarang',
    'subject_home_report_desc':
        'Beritahu penjaga Anda bahwa Anda baik-baik saja',
    'subject_home_emergency_button': 'Saya butuh bantuan',
    'subject_home_emergency_desc': 'Mengirim peringatan darurat ke wali Anda',
    'subject_home_emergency_loading': 'Mengirim peringatan darurat...',
    'subject_home_emergency_sent': 'Peringatan darurat telah dikirim',
    'subject_home_emergency_failed': 'Gagal mengirim peringatan darurat',
    'subject_home_emergency_confirm_title': 'Permintaan bantuan darurat',
    'subject_home_emergency_confirm_body': 'Peringatan darurat akan dikirim ke semua wali Anda.\nApakah Anda yakin ingin meminta bantuan?',
    'subject_home_emergency_confirm_send': 'Kirim permintaan darurat',
    'subject_home_share_text':
        'Pantau kesejahteraan saya melalui aplikasi Anbu!\nKode undangan: @code',
    'subject_home_share_subject': 'Kode Undangan Anbu',
    'subject_home_code_copied': 'Kode disalin',

    // ── Drawer Orang yang Dilindungi ──
    'drawer_light_mode': 'Mode Terang',
    'drawer_dark_mode': 'Mode Gelap',
    'drawer_privacy_policy': 'Kebijakan Privasi',
    'drawer_terms': 'Ketentuan Layanan',
    'drawer_withdraw': 'Hapus Akun',
    'drawer_withdraw_message':
        'Akun dan semua data Anda akan dihapus.\nApakah Anda yakin?',

    // ── Dashboard Penjaga ──
    'guardian_status_normal': 'Normal',
    'guardian_status_caution': 'Perhatian',
    'guardian_status_warning': 'Peringatan',
    'guardian_status_urgent': 'Mendesak',
    'guardian_status_confirmed': 'Keselamatan Dikonfirmasi',
    'guardian_subscription_expired': 'Langganan kedaluwarsa',
    'guardian_subscription_expired_message':
        'Notifikasi peringatan tidak terkirim.\nPerpanjang langganan untuk melanjutkan perlindungan.',
    'guardian_subscribe': 'Berlangganan',
    'guardian_payment_preparing': 'Fitur pembayaran segera hadir.',
    'guardian_today_summary': 'Ringkasan Kesejahteraan Hari Ini',
    'guardian_no_subjects': 'Belum ada orang yang dilindungi.',
    'guardian_checking_subjects':
        'Sedang memeriksa\n@count orang yang dilindungi.',
    'guardian_subject_list': 'Daftar Orang yang Dilindungi',
    'guardian_call_now': 'Telepon Sekarang',
    'guardian_confirm_safety': 'Konfirmasi Keselamatan',
    'guardian_no_check_history': 'Tidak ada riwayat pemeriksaan',
    'guardian_last_check_now': 'Pemeriksaan terakhir: baru saja',
    'guardian_last_check_minutes':
        'Pemeriksaan terakhir: @minutes menit lalu',
    'guardian_last_check_hours': 'Pemeriksaan terakhir: @hours jam lalu',
    'guardian_last_check_days': 'Pemeriksaan terakhir: @days hari lalu',
    'guardian_activity_stable': 'Aktivitas: Stabil',
    'guardian_safety_needed': 'Pemeriksaan keselamatan diperlukan',
    'guardian_error_load_subjects':
        'Gagal memuat daftar orang yang dilindungi.',
    'guardian_error_clear_alerts': 'Gagal menghapus peringatan.',

    // ── Penjaga Tambah Orang yang Dilindungi ──
    'add_subject_title': 'Hubungkan Orang yang Dilindungi',
    'add_subject_guide_title':
        'Masukkan kode unik orang yang dilindungi dan alias.',
    'add_subject_guide_subtitle':
        'Hubungkan aplikasi orang yang dilindungi untuk memantau kesehatan dan aktivitas secara real-time.',
    'add_subject_code_label': 'Kode Unik (7 digit)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info':
        'Kode unik dapat ditemukan di aplikasi orang yang dilindungi.',
    'add_subject_alias_label': 'Alias Orang yang Dilindungi',
    'add_subject_alias_hint': 'contoh: Ibu, Ayah',
    'add_subject_connect': 'Hubungkan',
    'add_subject_error_login': 'Login diperlukan.',
    'add_subject_success': 'Orang yang dilindungi berhasil terhubung.',
    'add_subject_error_invalid_code': 'Kode tidak valid.',
    'add_subject_error_already_connected': 'Sudah terhubung.',
    'add_subject_error_failed':
        'Koneksi gagal. Silakan coba lagi.',
    'add_subject_button': 'Tambah Orang yang Dilindungi Baru',

    // ── Pengaturan Penjaga ──
    'settings_title': 'Pengaturan',
    'settings_light_mode': 'Mode Terang',
    'settings_dark_mode': 'Mode Gelap',
    'settings_connection_management': 'Manajemen Koneksi',
    'settings_managed_subjects': 'Orang yang Dilindungi',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'Langganan & Layanan',
    'settings_current_membership': 'Keanggotaan Saat Ini',
    'settings_premium': 'Premium Aktif',
    'settings_free_trial': 'Uji Coba Gratis',
    'settings_days_remaining': 'Sisa @days hari',
    'settings_manage_subscription': 'Kelola Langganan',
    'settings_notification': 'Pengaturan Notifikasi',
    'settings_terms_section': 'Hukum',
    'settings_privacy_policy': 'Kebijakan Privasi',
    'settings_terms': 'Ketentuan Layanan',
    'settings_app_version': 'Versi: v@version',

    // ── G+S (Penjaga + Yang Dilindungi) ──
    'gs_enable_button': 'Terima perlindungan juga',
    'gs_safety_code_button': 'Lihat kode keamanan saya',
    'gs_safety_code_title': 'Kode keamanan saya',
    'gs_enable_dialog_title': 'Aktifkan perlindungan',
    'gs_enable_dialog_body':
        'Anda dapat menerima perlindungan sambil mempertahankan fungsi penjaga.\nKode keamanan akan diterbitkan — bagikan kepada penjaga lain.',
    'gs_enable_confirm': 'Aktifkan',
    'gs_enabled_message': 'Perlindungan telah diaktifkan',
    'gs_enable_failed': 'Gagal mengaktifkan perlindungan',
    'gs_disable_dialog_title': 'Nonaktifkan perlindungan',
    'gs_disable_dialog_body':
        'Menonaktifkan akan menghapus kode keamanan Anda dan menghentikan pengiriman pemeriksaan kesehatan ke penjaga yang terhubung.',
    'gs_disable_confirm': 'Nonaktifkan',
    'gs_disabled_message': 'Perlindungan telah dinonaktifkan',
    'gs_disable_failed': 'Gagal menonaktifkan perlindungan',

    // ── Notifikasi Penjaga ──
    'notifications_title': 'Notifikasi',
    'notifications_today': 'Notifikasi Hari Ini',
    'notifications_empty': 'Tidak ada notifikasi hari ini',
    'notifications_delete_all_title': 'Hapus Semua Notifikasi',
    'notifications_delete_all_message':
        'Hapus semua notifikasi hari ini?',
    'notifications_delete_failed': 'Gagal menghapus notifikasi.',
    'notifications_guide_title': 'Panduan Tingkat Notifikasi',
    'notifications_level_health': 'Normal',
    'notifications_level_health_desc':
        'Kesejahteraan orang yang dilindungi dikonfirmasi normal',
    'notifications_level_caution': 'Perhatian',
    'notifications_level_caution_desc':
        'Salah satu dari berikut:\n1. Pemeriksaan terjadwal hari ini belum ada\n2. Pemeriksaan diterima tapi tidak ada penggunaan telepon',
    'notifications_level_warning': 'Peringatan',
    'notifications_level_warning_desc':
        'Salah satu dari berikut:\n1. Tidak ada pemeriksaan selama 2 hari berturut-turut\n2. Tidak ada penggunaan telepon selama 2 hari berturut-turut',
    'notifications_level_urgent': 'Mendesak',
    'notifications_level_urgent_desc':
        'Tidak ada pemeriksaan dalam waktu lama,\natau tidak ada penggunaan telepon selama 3+ hari',
    'notifications_level_info': 'Info',
    'notifications_level_info_desc':
        'Notifikasi referensi seperti\njumlah langkah atau baterai lemah',
    'notifications_activity_note':
        '※ Info aktivitas mungkin tidak ditampilkan jika data langkah tidak dapat dikumpulkan.',

    // ── Pengaturan Notifikasi Penjaga ──
    'notification_settings_title': 'Pengaturan Notifikasi',
    'notification_settings_push': 'Notifikasi Push',
    'notification_settings_all': 'Semua Notifikasi',
    'notification_settings_all_desc':
        'Aktifkan atau nonaktifkan semua kategori notifikasi sekaligus.',
    'notification_settings_level_section': 'Pengaturan Tingkat',
    'notification_settings_urgent': 'Peringatan Mendesak',
    'notification_settings_urgent_desc':
        'Peringatan mendesak tidak dapat dinonaktifkan',
    'notification_settings_warning': 'Peringatan Waspada',
    'notification_settings_warning_desc':
        'Peringatan saat tidak ada pemeriksaan 2 hari berturut-turut',
    'notification_settings_caution': 'Peringatan Perhatian',
    'notification_settings_caution_desc':
        'Peringatan saat pemeriksaan hari ini belum ada',
    'notification_settings_info': 'Peringatan Info',
    'notification_settings_info_desc':
        'Peringatan umum seperti jumlah langkah dan status baterai',
    'notification_settings_dnd': 'Jangan Ganggu',
    'notification_settings_dnd_start': 'Waktu Mulai',
    'notification_settings_dnd_end': 'Waktu Selesai',
    'notification_settings_dnd_note':
        '※ Peringatan mendesak tetap terkirim saat Jangan Ganggu aktif',
    'notification_settings_dnd_start_default': '22:00',
    'notification_settings_dnd_end_default': '07:00',

    // ── Manajemen Koneksi Penjaga ──
    'connection_title': 'Manajemen Koneksi',
    'connection_managed_count': 'Orang yang Dilindungi ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Orang yang Dilindungi Terhubung',
    'connection_empty': 'Tidak ada orang yang dilindungi terhubung',
    'connection_unlink_warning':
        'Memutuskan koneksi akan menghapus data orang yang dilindungi.',
    'connection_unlink_warning_detail':
        'Catatan sebelumnya tidak dapat dipulihkan setelah menghubungkan ulang. Anda perlu memasukkan kembali kode orang yang dilindungi.',
    'connection_heartbeat_schedule': 'Setiap hari pukul @time',
    'connection_heartbeat_report_time': 'Waktu laporan kesejahteraan: ',
    'connection_subject_label': 'Orang yang Dilindungi',
    'connection_change_only_in_app': 'hanya dapat diubah di aplikasi',
    'connection_edit_title': 'Edit Orang yang Dilindungi',
    'connection_alias_label': 'Alias',
    'connection_unlink_title': 'Putuskan',
    'connection_unlink_confirm': 'Putuskan @alias?',
    'connection_unlink_success': 'Berhasil diputuskan.',
    'connection_unlink_failed': 'Gagal memutuskan.',
    'connection_load_failed': 'Gagal memuat daftar.',

    // ── Navigasi Bawah Penjaga ──
    'nav_home': 'Beranda',
    'nav_connection': 'Koneksi',
    'nav_notification': 'Peringatan',
    'nav_settings': 'Pengaturan',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'Ubah Waktu Pemeriksaan',
    'heartbeat_daily_time': 'Setiap hari pukul @time',
    'heartbeat_scheduled_today':
        'Pemeriksaan kesejahteraan dijadwalkan pukul @time hari ini.',
    'heartbeat_change_failed_title': 'Perubahan Waktu Gagal',
    'heartbeat_change_failed_message':
        'Tidak dapat memperbarui di server.',

    // ── Notifikasi Lokal ──
    'local_notification_channel': 'Peringatan Kesejahteraan',
    'local_notification_channel_desc':
        'Notifikasi layanan pemeriksaan kesejahteraan',

    // ── Lain-lain ──
    'back_press_exit': 'Tekan kembali sekali lagi untuk keluar.',

    // ── Kesalahan API ──
    'error_unknown': 'Terjadi kesalahan yang tidak diketahui.',
    'error_timeout': 'Waktu permintaan habis.',
    'error_network': 'Silakan periksa koneksi jaringan Anda.',
    'error_unauthorized': 'Autentikasi diperlukan.',

    // ── Isi Notifikasi ──
    'noti_auto_report_body':
        'Pemeriksaan kesejahteraan terjadwal telah diterima hari ini.',
    'noti_manual_report_body':
        'Orang yang dilindungi mengirim pemeriksaan kesejahteraan secara manual.',
    'noti_battery_low_body':
        'Baterai ponsel di bawah 20%. Mungkin perlu diisi daya.',
    'noti_battery_dead_body':
        'Ponsel tampaknya mati karena baterai habis. Level baterai terakhir: @battery_level%. Akan pulih setelah diisi daya.',
    'noti_caution_suspicious_body':
        'Sinyal kesejahteraan diterima, tetapi tidak ada tanda penggunaan ponsel. Silakan periksa langsung.',
    'noti_caution_missing_body':
        'Pemeriksaan kesejahteraan terjadwal hari ini belum diterima. Silakan periksa langsung.',
    'noti_warning_body':
        'Pemeriksaan kesejahteraan terlewat berturut-turut. Silakan verifikasi langsung.',
    'noti_urgent_body':
        'Tidak ada pemeriksaan kesejahteraan selama @days hari. Verifikasi segera diperlukan.',
    'noti_steps_body':
        '@from_time ~ @to_time: @steps langkah.',
    'noti_emergency_body': 'Orang yang dilindungi langsung meminta bantuan. Harap segera periksa.',
    'noti_resolved_body': 'Pemeriksaan kesejahteraan orang yang dilindungi telah kembali normal.',
    'noti_cleared_by_guardian_title': '✅ Keamanan dikonfirmasi',
    'noti_cleared_by_guardian_body': 'Salah satu pelindung telah memastikan keamanan secara langsung.',

    // ── Notifikasi lokal ──
    'local_alarm_title': '📱 Pemeriksaan kesejahteraan diperlukan',
    'local_alarm_body': 'Silakan ketuk notifikasi ini.',
    'wellbeing_check_title': '💛 Pemeriksaan Kesejahteraan',
    'wellbeing_check_body':
        'Apakah Anda baik-baik saja? Silakan ketuk notifikasi ini.',
    'noti_channel_name': 'Peringatan Anbu',
  };
}
