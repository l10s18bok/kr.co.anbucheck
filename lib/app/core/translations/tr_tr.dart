abstract class TrTr {
  static const Map<String, String> translations = {
    // ── Genel ──
    'common_confirm': 'Onayla',
    'common_cancel': 'İptal',
    'common_save': 'Kaydet',
    'common_delete': 'Sil',
    'common_close': 'Kapat',
    'common_next': 'İleri',
    'common_previous': 'Geri',
    'common_start': 'Başla',
    'common_skip': 'Atla',
    'common_later': 'Sonra',
    'common_loading': 'Yükleniyor...',
    'common_error': 'Hata',
    'common_complete': 'Tamam',
    'common_notice': 'Bildirim',
    'common_unlink': 'Bağlantıyı kes',
    'common_am': 'ÖÖ',
    'common_pm': 'ÖS',
    'common_normal': 'Normal',
    'common_connected': 'Bağlı',
    'common_disconnected': 'Bağlantı yok',

    // ── Uygulama Markası ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Hal hatır soruyoruz.',
    'app_service_desc': 'Otomatik hal hatır sorgulama hizmeti',
    'app_guardian_title': 'Anbu Koruyucu',
    'app_copyright': '© 2024 TNS Inc.',

    // ── Açılış Ekranı ──
    'splash_loading': 'Hal hatır soruluyor...',

    // ── Güncelleme ──
    'update_required_title': 'Güncelleme Gerekli',
    'update_required_message':
        'Uygulamayı kullanmaya devam etmek için lütfen @version sürümüne güncelleyin.',
    'update_button': 'Güncelle',
    'update_available_title': 'Güncelleme Mevcut',
    'update_available_message': '@version sürümü mevcut.',

    // ── Mod Seçimi ──
    'mode_select_title': 'Rolünüzü seçin',
    'mode_select_subtitle':
        'Bu seçim, size uygun özellikleri ayarlamamıza yardımcı olur',
    'mode_subject_title': 'Güvenliğimin\ntakip edilmesini istiyorum',
    'mode_subject_button': 'Korunmak istiyorum →',
    'mode_guardian_title': 'Sevdiğim birini\ngözetlemek istiyorum',
    'mode_guardian_button': 'Koruyucu ol →',
    'mode_select_notice':
        'Ekran düzeni ve bildirimler seçiminize göre değişecektir',

    // ── İzinler ──
    'permission_title': 'Uygulamanın çalışması için\nizinler gereklidir',
    'permission_notification': 'Bildirim İzni',
    'permission_notification_subject_desc':
        'Hal hatır bildirimlerini almak için gereklidir',
    'permission_notification_guardian_desc':
        'Takip edilenlerin güvenlik durumu bildirimlerini almak için gereklidir',
    'permission_activity': 'Aktivite Tanıma',
    'permission_activity_desc':
        'Adım sayısını tespit edip aktiviteyi doğrulamak için kullanılır',
    'permission_activity_dialog_title': 'Aktivite İzni Bilgisi',
    'permission_activity_dialog_message':
        'Adım sayısını tespit edip aktiviteyi doğrulamak için kullanılır.\nLütfen sonraki ekranda "İzin Ver"e dokunun.',
    'permission_notification_required_title': 'Bildirim İzni Gerekli',
    'permission_notification_required_message':
        'Hal hatır hizmeti için bildirim izni gereklidir.\nLütfen Ayarlar\'dan etkinleştirin.',
    'permission_go_to_settings': 'Ayarlara Git',

    // ── Tanıtım ──
    'onboarding_title_1': 'Yalnız yaşayan birisi için\nendişeleniyor musunuz?',
    'onboarding_desc_1':
        'Uzakta olsanız bile\niyi olup olmadığını merak edersiniz.\nAnbu yanınızda.',
    'onboarding_title_2': 'Hal hatır sormak için\nbir kelime bile gerekmez',
    'onboarding_desc_2':
        'Akıllı telefonu kullanmak yeterli,\nher gün otomatik olarak\nbir hal hatır sinyali gönderilir.',
    'onboarding_title_3': 'Sevdiklerinizle\nhal hatır paylaşın',
    'onboarding_desc_3':
        'Günlük kontroller biriktikçe\nkalıcı bir huzur oluşur.\nHemen başlayın.',
    'onboarding_title_4': 'İsim yok, telefon numarası yok\n— hiçbir şey toplanmaz',
    'onboarding_desc_4':
        'Yalnızca tek bir sinyal iletilir:\n"İyiyim."\nBilgileriniz güvende.',
    'onboarding_role_subject': 'Takip Edilen',
    'onboarding_role_guardian': 'Koruyucu',
    'onboarding_already_registered_title': 'Cihaz Zaten Kayıtlı',
    'onboarding_already_registered_message':
        'Bu cihaz zaten "@roleLabel" modunda kayıtlı.\n"@roleLabel" olarak devam etmek ister misiniz?\n\nYoksa "@newRoleLabel" moduna geçmek mi?\nGeçiş yaparsanız tüm veriler silinecektir.',
    'onboarding_change_mode': '"@newRoleLabel" moduna geç',
    'onboarding_continue_mode': '"@roleLabel" olarak devam et',
    'onboarding_registration_failed_title': 'Kayıt Başarısız',
    'onboarding_registration_failed_message':
        'Sunucuya bağlanılamadı. Lütfen daha sonra tekrar deneyin.',

    // ── Takip Edilen Ana Sayfa ──
    'subject_home_share_title': 'Güvenlik kodunuzu paylaşın',
    'subject_home_guardian_count': 'Bağlı koruyucular: @count',
    'subject_home_check_title_last': 'Son hal hatır kontrolü',
    'subject_home_check_title_scheduled': 'Planlanan kontrol zamanı',
    'subject_home_check_title_checking': 'Hal hatır kontrol ediliyor',
    'subject_home_check_body_reported': '@time itibarıyla bildirildi',
    'subject_home_check_body_scheduled': '@time için planlandı',
    'subject_home_check_body_waiting': '@time\'dan beri bekleniyor',
    'subject_home_battery_status': 'Pil Durumu',
    'subject_home_battery_charging': 'Şarj oluyor',
    'subject_home_battery_full': 'Tam dolu',
    'subject_home_battery_low': 'Düşük pil',
    'subject_home_connectivity_status': 'Bağlantı Durumu',
    'subject_home_report_loading': 'Bildiriliyor...',
    'subject_home_report_button': 'Şimdi Güvenliğini Bildir',
    'subject_home_report_desc': 'Koruyucunuza iyi olduğunuzu bildirin',
    'subject_home_share_text':
        'Anbu uygulamasıyla hal hatırımı sorun!\nDavet kodu: @code',
    'subject_home_share_subject': 'Anbu Davet Kodu',
    'subject_home_code_copied': 'Kod kopyalandı',

    // ── Takip Edilen Yan Menü ──
    'drawer_light_mode': 'Açık Tema',
    'drawer_dark_mode': 'Koyu Tema',
    'drawer_privacy_policy': 'Gizlilik Politikası',
    'drawer_terms': 'Kullanım Koşulları',
    'drawer_withdraw': 'Hesabı Sil',
    'drawer_withdraw_message':
        'Hesabınız ve tüm verileriniz silinecektir.\nEmin misiniz?',

    // ── Koruyucu Paneli ──
    'guardian_status_normal': 'Normal',
    'guardian_status_caution': 'Dikkat',
    'guardian_status_warning': 'Uyarı',
    'guardian_status_urgent': 'Acil',
    'guardian_status_confirmed': 'Güvenlik Onaylandı',
    'guardian_subscription_expired': 'Abonelik sona erdi',
    'guardian_subscription_expired_message':
        'Uyarı bildirimleri gönderilmiyor.\nKoruma hizmetine devam etmek için aboneliğinizi yenileyin.',
    'guardian_subscribe': 'Abone Ol',
    'guardian_payment_preparing': 'Ödeme özelliği yakında kullanıma sunulacak.',
    'guardian_today_summary': 'Bugünün Özeti',
    'guardian_no_subjects': 'Bağlı takip edilen yok.',
    'guardian_checking_subjects':
        'Şu anda @count kişi\ntakip ediliyor.',
    'guardian_subject_list': 'Takip Edilenler Listesi',
    'guardian_call_now': 'Şimdi Ara',
    'guardian_confirm_safety': 'Güvenliği Onayla',
    'guardian_no_check_history': 'Kontrol geçmişi yok',
    'guardian_last_check_now': 'Son kontrol: az önce',
    'guardian_last_check_minutes': 'Son kontrol: @minutes dk önce',
    'guardian_last_check_hours': 'Son kontrol: @hours sa önce',
    'guardian_last_check_days': 'Son kontrol: @days gün önce',
    'guardian_activity_stable': 'Aktivite: Stabil',
    'guardian_safety_needed': 'Güvenlik kontrolü gerekli',
    'guardian_error_load_subjects':
        'Takip edilenler listesi yüklenemedi.',
    'guardian_error_clear_alerts': 'Uyarılar temizlenemedi.',

    // ── Takip Edilen Ekleme ──
    'add_subject_title': 'Takip Edilen Bağla',
    'add_subject_guide_title':
        'Takip edilenin benzersiz kodunu\nve bir takma ad girin.',
    'add_subject_guide_subtitle':
        'Sağlık durumunu ve aktivitesini\ngerçek zamanlı izlemek için bağlayın.',
    'add_subject_code_label': 'Benzersiz Kod (7 hane)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info':
        'Benzersiz kod, takip edilenin uygulamasında bulunabilir.',
    'add_subject_alias_label': 'Takip Edilen Adı',
    'add_subject_alias_hint': 'Örn: Annem, Babam',
    'add_subject_connect': 'Bağla',
    'add_subject_error_login': 'Giriş yapmanız gerekli.',
    'add_subject_success': 'Takip edilen başarıyla bağlandı.',
    'add_subject_error_invalid_code': 'Geçersiz kod.',
    'add_subject_error_already_connected': 'Zaten bağlı.',
    'add_subject_error_failed':
        'Bağlantı başarısız. Lütfen tekrar deneyin.',
    'add_subject_button': 'Yeni Takip Edilen Ekle',

    // ── Koruyucu Ayarları ──
    'settings_title': 'Ayarlar',
    'settings_light_mode': 'Açık Tema',
    'settings_dark_mode': 'Koyu Tema',
    'settings_connection_management': 'Bağlantı Yönetimi',
    'settings_managed_subjects': 'Takip Edilen Sayısı',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'Abonelik ve Hizmet',
    'settings_current_membership': 'Mevcut Üyelik',
    'settings_premium': 'Premium Aktif',
    'settings_free_trial': 'Ücretsiz Deneme',
    'settings_manage_subscription': 'Aboneliği Yönet',
    'settings_notification': 'Bildirim Ayarları',
    'settings_terms_section': 'Yasal',
    'settings_privacy_policy': 'Gizlilik Politikası',
    'settings_terms': 'Kullanım Koşulları',
    'settings_app_version': 'Sürüm: v@version',

    // ── Koruyucu Bildirimler ──
    'notifications_title': 'Bildirimler',
    'notifications_today': 'Bugünkü Bildirimler',
    'notifications_empty': 'Bugün bildirim yok',
    'notifications_delete_all_title': 'Tüm Bildirimleri Sil',
    'notifications_delete_all_message':
        'Bugünkü tüm bildirimler silinsin mi?',
    'notifications_delete_failed': 'Bildirimler silinemedi.',
    'notifications_guide_title': 'Bildirim Seviyeleri Rehberi',
    'notifications_level_health': 'Normal',
    'notifications_level_health_desc':
        'Takip edilenin hal hatırı normal şekilde onaylandı',
    'notifications_level_caution': 'Dikkat',
    'notifications_level_caution_desc':
        'Aşağıdakilerden biri:\n1. Bugünkü planlanan kontrol yapılmadı\n2. Kontrol alındı ancak telefon kullanımı tespit edilmedi',
    'notifications_level_warning': 'Uyarı',
    'notifications_level_warning_desc':
        'Aşağıdakilerden biri:\n1. Ardışık 2 gündür kontrol yok\n2. Ardışık 2 gündür telefon kullanımı yok',
    'notifications_level_urgent': 'Acil',
    'notifications_level_urgent_desc':
        'Uzun süredir kontrol yok\nveya 3 günden fazla telefon kullanımı yok',
    'notifications_level_info': 'Bilgi',
    'notifications_level_info_desc':
        'Adım sayısı veya düşük pil gibi\nreferans bildirimler',
    'notifications_activity_note':
        '※ Adım verileri toplanamadıysa aktivite bilgisi gösterilmeyebilir.',

    // ── Koruyucu Bildirim Ayarları ──
    'notification_settings_title': 'Bildirim Ayarları',
    'notification_settings_push': 'Anlık Bildirimler',
    'notification_settings_all': 'Tüm Bildirimler',
    'notification_settings_all_desc':
        'Tüm bildirim kategorilerini toplu olarak etkinleştirin veya devre dışı bırakın.',
    'notification_settings_level_section': 'Seviye Ayarları',
    'notification_settings_urgent': 'Acil Uyarılar',
    'notification_settings_urgent_desc':
        'Acil uyarılar devre dışı bırakılamaz',
    'notification_settings_warning': 'Uyarı Bildirimleri',
    'notification_settings_warning_desc':
        'Ardışık 2 gün kontrol yapılmadığında bildirim',
    'notification_settings_caution': 'Dikkat Bildirimleri',
    'notification_settings_caution_desc':
        'Bugünkü kontrol yapılmadığında bildirim',
    'notification_settings_info': 'Bilgi Bildirimleri',
    'notification_settings_info_desc':
        'Adım sayısı ve pil durumu gibi genel bildirimler',
    'notification_settings_dnd': 'Rahatsız Etmeyin',
    'notification_settings_dnd_start': 'Başlangıç Saati',
    'notification_settings_dnd_end': 'Bitiş Saati',
    'notification_settings_dnd_note':
        '※ Acil uyarılar, Rahatsız Etmeyin modunda bile iletilir',
    'notification_settings_dnd_start_default': '22:00',
    'notification_settings_dnd_end_default': '07:00',

    // ── Koruyucu Bağlantı Yönetimi ──
    'connection_title': 'Bağlantı Yönetimi',
    'connection_managed_count': 'Takip Edilen Sayısı ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Bağlı Takip Edilenler',
    'connection_unlink_warning':
        'Bağlantıyı kesmek takip edilenin verilerini silecektir.',
    'connection_unlink_warning_detail':
        'Yeniden bağlandıktan sonra önceki kayıtlar kurtarılamaz.\nTakip edilenin kodunu tekrar girmeniz gerekecektir.',
    'connection_heartbeat_schedule': 'Her gün @time',
    'connection_heartbeat_report_time': 'Hal hatır rapor zamanı: ',
    'connection_subject_label': 'Takip Edilen',
    'connection_change_only_in_app': 'yalnızca uygulamadan değiştirilebilir',
    'connection_edit_title': 'Takip Edileni Düzenle',
    'connection_alias_label': 'Takma Ad',
    'connection_unlink_title': 'Bağlantıyı Kes',
    'connection_unlink_confirm': '@alias bağlantısı kesilsin mi?',
    'connection_unlink_success': 'Bağlantı başarıyla kesildi.',
    'connection_unlink_failed': 'Bağlantı kesilemedi.',
    'connection_load_failed': 'Liste yüklenemedi.',

    // ── Koruyucu Alt Gezinme ──
    'nav_home': 'Ana Sayfa',
    'nav_connection': 'Bağlantı',
    'nav_notification': 'Uyarılar',
    'nav_settings': 'Ayarlar',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'Kontrol Saatini Değiştir',
    'heartbeat_daily_time': 'Her gün @time',
    'heartbeat_scheduled_today':
        'Bugün @time için hal hatır kontrolü planlandı.',
    'heartbeat_change_failed_title': 'Saat Değişikliği Başarısız',
    'heartbeat_change_failed_message': 'Sunucuda güncellenemedi.',

    // ── Yerel Bildirimler ──
    'local_notification_channel': 'Hal Hatır Bildirimleri',
    'local_notification_channel_desc':
        'Hal hatır sorgulama hizmeti bildirimleri',

    // ── Diğer ──
    'back_press_exit': 'Çıkmak için geri tuşuna tekrar basın.',

    // ── API Hataları ──
    'error_unknown': 'Bilinmeyen bir hata oluştu.',
    'error_timeout': 'İstek zaman aşımına uğradı.',
    'error_network': 'Lütfen ağ bağlantınızı kontrol edin.',
    'error_unauthorized': 'Kimlik doğrulama gerekli.',

    // ── Bildirim Metinleri ──
    'noti_auto_report_body':
        'Planlanan hal hatır kontrolü bugün alındı.',
    'noti_manual_report_body':
        'Korunan kişi manuel olarak hal hatır kontrolü gönderdi.',
    'noti_battery_low_body':
        'Telefon pili %20\'nin altında. Şarj etmek gerekebilir.',
    'noti_battery_dead_body':
        'Telefon pil bitmesi nedeniyle kapanmış görünüyor. Son pil seviyesi: %@battery_level. Şarj edildikten sonra otomatik olarak düzelecektir.',
    'noti_caution_suspicious_body':
        'Hal hatır sinyali alındı ancak telefon kullanım belirtisi yok. Lütfen bizzat kontrol edin.',
    'noti_caution_missing_body':
        'Bugün planlanan hal hatır kontrolü henüz alınmadı. Lütfen bizzat kontrol edin.',
    'noti_warning_body':
        'Hal hatır kontrolleri art arda kaçırıldı. Lütfen bizzat doğrulayın.',
    'noti_urgent_body':
        '@days gündür hal hatır kontrolü yok. Acil doğrulama gerekli.',
    'noti_steps_body':
        '@from_time ~ @to_time: @steps adım atıldı.',

    // ── Yerel bildirimler ──
    'local_alarm_title': '📱 Sağlık kontrolü gerekli',
    'local_alarm_body': 'Lütfen bu bildirime dokunun.',
    'wellbeing_check_title': '💛 Sağlık Kontrolü',
    'wellbeing_check_body':
        'İyi misiniz? Lütfen bu bildirime dokunun.',
    'noti_channel_name': 'Anbu Uyarıları',
  };
}
