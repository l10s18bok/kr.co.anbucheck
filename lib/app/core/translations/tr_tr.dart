abstract class TrTr {
  static const Map<String, String> translations = {
    // ── Genel ──
    'common_confirm': 'Onayla',
    'common_cancel': 'İptal',
    'common_continue': 'Devam',
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
    'common_session_expired': 'Hesap bilgilerinizin süresi doldu. Lütfen yeniden kaydolun.',
    'common_complete': 'Tamam',
    'common_notice': 'Bildirim',
    'common_unlink': 'Bağlantıyı kes',
    'common_am': 'ÖÖ',
    'common_pm': 'ÖS',
    'common_time_style': 'h24',
    'common_normal': 'Normal',
    'common_connected': 'Bağlı',
    'common_disconnected': 'Bağlantı yok',

    // ── Uygulama Markası ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'Hal hatır soruyoruz.',
    'app_service_desc': 'Otomatik hal hatır sorgulama hizmeti',
    'app_guardian_title': 'Anbu Koruyucu',
    'app_copyright': '© 2026 Averic Lab',

    // ── Açılış Ekranı ──
    'splash_loading': 'Hal hatır soruluyor...',

    // ── Güncelleme ──
    'update_required_title': 'Güncelleme Gerekli',
    'update_required_message':
        'Uygulamayı kullanmaya devam etmek için lütfen @version sürümüne güncelleyin.',
    'update_button': 'Güncelle',
    'update_available_title': 'Güncelleme Mevcut',
    'update_available_message': '@version sürümü mevcut.',
    'update_later_button': 'Daha sonra',

    // ── Mod Seçimi ──
    'mode_select_title': 'Nasıl başlamak istersiniz?',
    'mode_select_subtitle': 'İyi olduğunuzu siz mi bildiriyorsunuz yoksa siz mi alıyorsunuz, söyleyin',
    'mode_subject_title': 'Sadece iyi olduğumu bildirmek istiyorum',
    'mode_subject_desc': 'Yalnızca gerekli özellikleri içeren çok sade bir ekran',
    'mode_subject_button': 'İyi olduğumu bildir →',
    'mode_guardian_title': 'Birden fazla kişiyi gözetebilirsiniz',
    'mode_guardian_desc': 'Gerekirse daha sonra kendi durumunuzu da bildirebilirsiniz',
    'mode_guardian_button': 'Haber al →',
    'mode_subject_badge': 'Yaşlılar',
    'mode_guardian_badge': 'Koruyucu',
    'mode_select_notice': 'Ekran düzeni seçiminize göre değişecektir',

    // ── İzinler ──
    'permission_title': 'Uygulamanın çalışması için\nizinler gereklidir',
    'permission_notification': 'Bildirim İzni',
    'permission_notification_subject_desc': 'Hal hatır bildirimlerini almak için gereklidir',
    'permission_notification_guardian_desc':
        'Korunan kişilerin güvenlik durumu bildirimlerini almak için gereklidir',
    'permission_activity': 'Aktivite Tanıma',
    'permission_activity_desc': 'Adım sayısını tespit edip aktiviteyi doğrulamak için kullanılır',
    'permission_location': 'Konum',
    'permission_location_desc': 'Yalnızca acil yardım talebinde koruyuculara iletilir',
    'permission_tracking': 'Reklam Takibi',
    'permission_tracking_desc': 'Kişiselleştirilmiş reklamlar için kullanılır',
    'location_permission_warning':
        'Acil yardım talebinde konum gönderilmeyecek. İzin vermek için dokunun.',
    'location_permission_settings_title': 'Konum İzni Gerekli',
    'location_permission_settings_body_ios':
        "'Anbu'yu bulup seçin, ardından 'Konum' altında 'Uygulamayı kullanırken' seçeneğini seçin.",
    'location_permission_settings_body_android':
        "'İzinler' → 'Konum' seçin, ardından 'Yalnızca uygulamayı kullanırken izin ver' seçeneğini seçin.",
    'permission_activity_dialog_title': 'Aktivite İzni Bilgisi',
    'permission_activity_dialog_message':
        'Adım sayısını tespit edip aktiviteyi doğrulamak için kullanılır.\nLütfen sonraki ekranda "İzin Ver"e dokunun.',
    'permission_notification_required_title': 'Bildirim İzni Gerekli',
    'permission_notification_required_message':
        'Hal hatır hizmeti için bildirim izni gereklidir.\nLütfen Ayarlar\'dan etkinleştirin.',
    'permission_go_to_settings': 'Ayarlara Git',
    'permission_activity_denied_title': 'Fiziksel Aktivite İzni Gerekli',
    'permission_activity_denied_message':
        'Adım sayınızı algılamak ve güvenliğinizi doğrulamak için fiziksel aktivite izni gereklidir.\n\nBu izin olmadan adım bilgileri koruyuculara gönderilmeyecektir.\n\nLütfen uygulama ayarlarından "Fiziksel Aktivite" iznini etkinleştirin.',
    'permission_battery': 'Pil Optimizasyonu Hariç Tutma',
    'permission_battery_desc':
        'Günlük hal hatır kontrollerinin belirlenen saatte kaçırılmaması için uygulamayı pil optimizasyonundan hariç tutar',
    'permission_hibernation_title': 'Otomatik izin kaldırmayı kapatın',
    'permission_hibernation_highlight': 'Otomatik izin kaldırma',
    'permission_hibernation_message':
        'Android, uzun süre kullanılmayan uygulamaların izinlerini otomatik olarak kaldırır. Anbu genellikle açılmadan çalıştığı için, bu özellik bir süre sonra izinlerin kaybolmasına ve hal hatır sinyalinin gönderilmemesine neden olabilir.\n\nAşağıdaki [Ayarları Aç] düğmesine dokunduğunuzda, ilgili anahtar ekranı doğrudan açılır. Anahtarı kapatın.\n\n※ Tam ifade cihaz üreticisine göre değişebilir.',
    'permission_hibernation_go_to_settings': 'Ayarları Aç',
    'stability_battery_warning_short': 'Pil kullanım kısıtlaması kapatılmalı',
    'stability_battery_dialog_title': 'Pil kullanım kısıtlamasını kaldırma',
    'stability_battery_dialog_message':
        'Telefonunuz güç tasarrufu moduna girdiğinde, koruyucunuza giden hal hatır sinyalleri gecikebilir veya kaybolabilir.\n\nAşağıdaki [Ayarları Aç] düğmesine dokunduktan sonra "Pil" → "Kısıtlama yok" ayarlayın. Böylece hal hatır sinyalleri her gün belirlenen saatte güvenilir bir şekilde iletilir.\n\n※ Tam ifade cihaz üreticisine göre değişebilir.',

    // ── Tanıtım ──
    'onboarding_safety_code_title': 'Güvenlik kodunuz otomatik olarak oluşturulur',
    'onboarding_safety_code_desc':
        'Bu kodu koruyucunuzla paylaşarak bağlanın —\nhal hatır sinyaliniz otomatik olarak gönderilir.',
    'onboarding_emergency_title': 'Şu anki durumunuzu (Acil) ve konumunuzu bildirmek istediğinizde',
    'onboarding_emergency_desc': 'Bu düğmeye basın, mesaj hemen\ntüm koruyucularınıza ulaşır',
    'onboarding_gs_switch_title': 'Ailenizin hal hatırını da birlikte gözetin',
    'onboarding_gs_switch_desc':
        'Menüden [Ailenin hal hatırını da takip et] düğmesine basarak\nkoruyucu rolünü de kullanabilirsiniz',
    'onboarding_add_subject_title': 'Sevdiğiniz biriyle bağlanın',
    'onboarding_add_subject_desc':
        'Aldığınız kodu ve bir takma ad girerek\nhemen bağlanın',
    'onboarding_notifications_title': 'Hal hatır bildirimleri böyle görünür',
    'onboarding_notifications_desc':
        'Normalde adım sayısı gibi aktivite bilgilerini görürsünüz. Sinyal gelmez veya aktivite algılanmazsa yukarıdaki gibi bildirim alırsınız',
    'onboarding_push_now': 'Şimdi',
    'onboarding_gs_enable_title': 'Kendi güvenlik kodunuzu etkinleştirin',
    'onboarding_gs_enable_desc':
        "Ayarlar'da [Güvenlik kodumu oluştur] düğmesine basarak\nhal hatırınızı koruyucularınıza da iletin",
    'onboarding_role_subject': 'Korunan kişi',
    'onboarding_role_guardian': 'Koruyucu',
    'onboarding_role_guardian_subject': 'Koruyucu ve korunan kişi',
    'onboarding_already_registered_title': 'Cihaz Zaten Kayıtlı',
    'onboarding_already_registered_message':
        'Bu cihaz zaten "@roleLabel" modunda kayıtlı.\n"@roleLabel" olarak devam etmek ister misiniz?\n\nYoksa "@newRoleLabel" moduna geçmek mi?\nGeçiş yaparsanız tüm veriler silinecektir.',
    'onboarding_already_registered_message_gs':
        'Bu cihaz zaten "@roleLabel" modunda kayıtlı.\n"@newRoleLabel" moduna geçmek hem koruyucu hem korunan verilerini silecektir.',
    'onboarding_registration_failed_title': 'Kayıt Başarısız',
    'onboarding_registration_failed_message':
        'Sunucuya bağlanılamadı. Lütfen daha sonra tekrar deneyin.',

    // ── Korunan Kişi Ana Sayfa ──
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
    'subject_home_emergency_button': 'Yardıma ihtiyacım var',
    'subject_home_emergency_desc': 'Koruyucularınıza acil durum uyarısı gönderir',
    'subject_home_emergency_loading': 'Acil durum uyarısı gönderiliyor...',
    'subject_home_emergency_sent': 'Acil durum uyarısı gönderildi',
    'subject_home_emergency_failed': 'Acil durum uyarısı gönderilemedi',
    'subject_home_manual_report_limit_reached':
        'Bugünün güvenlik raporunu zaten gönderdiniz. Lütfen yarın tekrar deneyin.',
    'subject_home_manual_report_sent': 'Hal hatır bilginiz koruyucularınıza iletildi.',
    'safety_net_dialog_title': 'Hal hatır bilgisi gönderildi',
    'safety_net_dialog_body': 'Bugünün hal hatır bilgisi koruyucularınıza iletildi.',
    'safety_net_dialog_already_body':
        'Bugünün hal hatır bilgisi saat @time itibarıyla koruyucularınıza zaten iletildi.',
    'subject_home_emergency_confirm_title': 'Acil yardım talebi',
    'subject_home_emergency_confirm_body':
        'Tüm koruyucularınıza bir acil durum uyarısı gönderilecek.\nMevcut konumunuz da paylaşılacak.\nGerçekten yardım istemek istiyor musunuz?',
    'emergency_sent_with_location': 'Acil durum uyarısı gönderildi (konumla birlikte)',
    'emergency_sent_without_location': 'Acil durum uyarısı gönderildi',
    'notifications_view_location': '🗺️ Konumu görüntüle',
    'emergency_map_title': 'Acil durum konumu',
    'emergency_map_subject_label': 'Korunan kişi',
    'emergency_map_captured_at_label': 'Yakalanma zamanı',
    'emergency_map_accuracy_label': 'Doğruluk',
    'emergency_map_open_external': 'Harici harita uygulamasında aç',
    'emergency_map_no_location': 'Konum bilgisi yok',
    'emergency_location_permission_denied_snackbar':
        'Konum izni olmadan acil durum uyarısı gönderildi',
    'subject_home_emergency_confirm_send': 'Acil talep gönder',
    'emergency_message_hint': 'Mesaj ekle (isteğe bağlı)',
    'subject_home_share_text': 'Anbu uygulamasında benimle bağlantı kurun.\nBağlantı kodu: @code',
    'subject_home_share_subject': 'Anbu Bağlantı Kodu',
    'subject_home_code_copied': 'Kod kopyalandı',

    // ── Korunan Kişi Yan Menü ──
    'drawer_light_mode': 'Açık Tema',
    'drawer_dark_mode': 'Koyu Tema',
    'drawer_privacy_policy': 'Gizlilik Politikası',
    'drawer_terms': 'Kullanım Koşulları',
    'drawer_withdraw': 'Hesabı Sil',
    'drawer_withdraw_message': 'Hesabınız ve tüm verileriniz silinecektir.\nEmin misiniz?',

    // ── Koruyucu Paneli ──
    'guardian_status_normal': 'Güvende',
    'guardian_status_caution': 'Dikkat',
    'guardian_status_warning': 'Uyarı',
    'guardian_status_urgent': 'Acil',
    'guardian_status_confirmed': '✅ Güvende',
    'guardian_subscription_expired': 'Abonelik gerekli',
    'guardian_subscription_expired_message':
        'Her gün gelen hal hatır haberleri artık kesildi.\nBir öğle yemeği fiyatına, sevdiğinize tüm yıl göz kulak olun.',
    'guardian_subscribe': 'Abone Ol',
    'guardian_payment_preparing': 'Ödeme özelliği yakında kullanıma sunulacak.',
    'guardian_today_summary': 'Bugünün Özeti',
    'guardian_no_subjects': 'Bağlı korunan kişi yok.',
    'guardian_checking_subjects': 'Şu anda @count kişi\ntakip ediliyor.',
    'guardian_subject_list': 'Korunan Kişiler Listesi',
    'guardian_call_now': 'Şimdi Ara',
    'phone_call_failed': 'Arama başlatılamadı.',
    'guardian_confirm_safety': 'Onayla',
    'guardian_no_check_history': 'Kontrol geçmişi yok',
    'guardian_last_check_now': 'Son kontrol: az önce',
    'guardian_last_check_minutes': 'Son kontrol: @minutes dk önce',
    'guardian_last_check_hours': 'Son kontrol: @hours sa önce',
    'guardian_last_check_days': 'Son kontrol: @days gün önce',
    'guardian_activity_stable': 'Aktivite: Stabil',
    'guardian_activity_prefix': 'Aktivite',
    'guardian_activity_very_active': 'Çok aktif',
    'guardian_activity_active': 'Aktif',
    'guardian_activity_needs_exercise': 'Egzersiz gerekli',
    'guardian_activity_collecting': 'Veri toplanıyor',
    'guardian_error_load_step_history': 'Adım geçmişi yüklenemedi',
    'guardian_my_steps': 'Adımlarım',
    'guardian_chart_y_axis_steps': 'Adım',
    'guardian_chart_x_axis_last_7_days': 'Son 7 gün',
    'guardian_chart_x_axis_last_30_days': 'Son 30 gün',
    'guardian_chart_today': 'Bugün',
    'guardian_safety_needed': 'Güvenlik kontrolü gerekli',
    'guardian_error_load_subjects': 'Korunan kişiler listesi yüklenemedi.',
    'guardian_safety_confirmed': 'Güvenlik onaylandı.',
    'guardian_error_clear_alerts': 'Uyarılar temizlenemedi.',

    // ── Korunan Kişi Ekleme ──
    'add_subject_title': 'Korunan Kişi Bağla',
    'add_subject_guide_title': 'Korunan kişinin benzersiz kodunu ve bir takma ad girin.',
    'add_subject_guide_subtitle':
        'Sağlık durumunu ve aktivitesini gerçek zamanlı izlemek için bağlayın.',
    'add_subject_code_label': 'Benzersiz Kod (7 hane)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info': 'Benzersiz kod, korunan kişinin uygulamasında bulunabilir.',
    'add_subject_alias_label': 'Korunan Kişi Adı',
    'add_subject_alias_hint': 'Örn: Annem, Babam',
    'add_subject_phone_label': 'Telefon Numarası (isteğe bağlı)',
    'add_subject_phone_info': 'Girilirse arama düğmesi doğrudan bu numarayı arar. Boş bırakılırsa kişiyi rehberinizden kendiniz seçmeniz gerekir.',
    'add_subject_phone_hint': '05321234567',
    'add_subject_connect': 'Bağla',
    'add_subject_error_login': 'Giriş yapmanız gerekli.',
    'add_subject_success': 'Korunan kişi başarıyla bağlandı.',
    'add_subject_error_invalid_code': 'Geçersiz kod.',
    'add_subject_error_self': 'Kendi kodunuzu korunan kişi olarak ekleyemezsiniz.',
    'add_subject_error_limit': 'En fazla @max kişi kaydedebilirsiniz.',
    'add_subject_error_already_connected': 'Zaten bağlı.',
    'add_subject_error_failed': 'Bağlantı başarısız. Lütfen tekrar deneyin.',
    'add_subject_button': 'Yeni Korunan Kişi Ekle',

    // ── Koruyucu Ayarları ──
    'settings_title': 'Ayarlar',
    'settings_light_mode': 'Açık Tema',
    'settings_dark_mode': 'Koyu Tema',
    'settings_connection_management': 'Bağlantı Yönetimi',
    'settings_managed_subjects': 'Korunan Kişi Sayısı',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'Abonelik ve Hizmet',
    'settings_current_membership': 'Mevcut Üyelik',
    'settings_premium': 'Premium Aktif',
    'guardian_go_to_settings': 'Ayarlara git',
    'settings_expired': 'Abonelik gerekli',
    'settings_days_until_renewal': 'D-@days',
    'settings_days_until_trial_end': 'D-@days',
    'settings_free_trial': 'Ücretsiz Deneme',
    'settings_manage_subscription': 'Aboneliği Yönet',
    'settings_notification': 'Bildirim Ayarları',
    'settings_terms_section': 'Yasal',
    'settings_privacy_policy': 'Gizlilik Politikası',
    'settings_terms': 'Kullanım Koşulları',
    'settings_ad_consent': 'Reklam Onay Ayarları',
    'settings_app_version': 'Sürüm: v@version',

    // ── Uygulama içi satın alma (Bakıcı yıllık $9.99 aboneliği) ──
    'subscription_subscribe': 'Abone Ol',
    'trial_ended_noti_title': 'Anbu',
    'trial_ended_noti_body': 'Ücretsiz deneme süreniz sona erdi. Devam etmek için abone olun.',
    'subscription_restore': 'Satın Alımı Geri Yükle',
    'subscription_store_unavailable': 'Mağaza kullanılamıyor',
    'subscription_product_unavailable': 'Abonelik kullanılamıyor',
    'subscription_purchase_failed': 'Satın alma başarısız',
    'subscription_verify_failed': 'Abonelik doğrulanamadı',
    'subscription_restore_failed': 'Geri yükleme başarısız',
    'subscription_restore_nothing': 'Geri yüklenecek abonelik yok',
    'subscription_restore_success': 'Abonelik geri yüklendi',
    'subscription_purchase_success': 'Abonelik başlatıldı',
    'subscription_period_annual': 'yıl',

    // ── G+S (Koruyucu + Korunan) ──
    'gs_enable_button': 'Güvenlik kodumu oluştur',
    'gs_safety_code_button': 'Güvenlik kodumu kontrol et',
    'gs_enable_button_desc': 'Aileniz de sizin hal hatırınızı öğrenebilir',
    'gs_safety_code_button_desc': 'Kod paylaş · Bildir · Acil',
    'gs_safety_code_title': 'Güvenlik kodum',
    'gs_enable_dialog_title': 'Güvenlik kodumu oluştur',
    'gs_enable_dialog_body':
        'Bir güvenlik kodu verilecektir — lütfen diğer koruyucularla paylaşın.',
    'gs_enable_dialog_ios_warning_title': '⚠ Hal hatır sinyaliniz nasıl gönderilir',
    'gs_enable_dialog_ios_warning_body':
        'Her gün belirlenen saatte bir "hal hatır bildirimi" görünür. Hal hatır sinyalinizin gönderilmesi için bildirime dokunmanız veya o sırada uygulamayı kendiniz açmanız gerekir. Uygulamayı açmazsanız koruyucularınız kaçırılan kontrol uyarısı alabilir.',
    'gs_enable_dialog_ios_confirm': 'Anladım, etkinleştir',
    'gs_enable_confirm': 'Oluştur',
    'gs_enabled_message': 'Koruma etkinleştirildi',
    'gs_enable_failed': 'Koruma etkinleştirilemedi',
    'gs_disable_dialog_title': 'Korumayı devre dışı bırak',
    'gs_disable_dialog_body':
        'Korumayı devre dışı bırakmak güvenlik kodunuzu silecek ve bağlı koruyuculara kontrol gönderimini durduracaktır.',
    'gs_disable_confirm': 'Devre dışı bırak',
    'gs_disabled_message': 'Koruma devre dışı bırakıldı',
    'gs_disable_failed': 'Koruma devre dışı bırakılamadı',
    'gs_activity_permission_denied_warning':
        'Adım sayar izni reddedildi. İzin vermek için buraya dokunun.',
    'gs_activity_permission_settings_title': 'İzin Gerekli',
    'gs_activity_permission_settings_body':
        'Lütfen uygulama ayarlarından Fiziksel aktivite (Hareket ve Fitness) iznine izin verin.',
    'gs_activity_permission_settings_go': 'Ayarlara Git',

    // ── Koruyucu modunda G+S geçişi (Drawer/Diyalog) ──
    'drawer_enable_guardian': 'Ailenin hal hatırını da takip et',
    's_to_gs_dialog_title': 'Koruyucu Özelliğini Ekle',
    's_to_gs_dialog_body':
        'Aile bireylerinizin veya sevdiklerinizin hal hatırını da takip edebilmek için koruyucu özelliğini ekleyin.\n(Not: Koruyucu özelliği 3 ay boyunca ücretsizdir, ardından ücretli aboneliğe geçer.)\n\nKendi güvenlik kodunuz ve şu anda kullandığınız hal hatır bildirimleri aynı şekilde devam eder ve ücretsiz kalır.',
    's_to_gs_dialog_confirm': 'Devam Et',
    's_to_gs_switch_failed': 'Koruyucu özelliği etkinleştirilemedi',

    // ── Koruyucu Bildirimler ──
    'notifications_title': 'Bildirimler',
    'notifications_today': 'Bugünkü Bildirimler',
    'notifications_empty': 'Bugün bildirim yok',
    'notifications_delete_all_title': 'Tüm Bildirimleri Sil',
    'notifications_auto_delete_notice':
        'Bugünkü bildirimler gece yarısı (0:00) otomatik olarak silinir.',
    'notifications_delete_all_message': 'Bugünkü tüm bildirimler silinsin mi?',
    'notifications_delete_failed': 'Bildirimler silinemedi.',
    'notifications_guide_title': 'Bildirim Seviyeleri Rehberi',
    'notifications_level_health': 'Normal',
    'notifications_level_health_desc': 'Korunan kişinin hal hatırı normal şekilde onaylandı',
    'notifications_level_caution': 'Dikkat',
    'notifications_level_caution_desc': 'Henüz hal hatır sinyali veya aktivite kaydı yok',
    'notifications_level_warning': 'Uyarı',
    'notifications_level_warning_desc': 'Birkaç gündür hal hatır sinyali veya aktivite kaydı yok',
    'notifications_level_urgent': 'Acil',
    'notifications_level_urgent_desc': 'Hemen kontrol gerekli',
    'notifications_level_info': 'Bilgi',
    'notifications_level_info_desc': 'Adım, düşük pil ve diğer bilgi uyarıları',
    'notifications_activity_note':
        '※ Adım sayısı, gece yarısından hal hatır sinyalinin gönderildiği zamana kadar biriken adımları yansıtır.',

    // ── Koruyucu Bildirim Ayarları ──
    'notification_settings_title': 'Bildirim Ayarları',
    'notification_settings_push': 'Anlık Bildirimler',
    'notification_settings_all': 'Tüm Bildirimler',
    'notification_settings_all_desc':
        'Tüm bildirim kategorilerini toplu olarak etkinleştirin veya devre dışı bırakın.',
    'notification_settings_level_section': 'Seviye Ayarları',
    'notification_settings_urgent': 'Acil Uyarılar',
    'notification_settings_urgent_desc': 'Acil uyarılar devre dışı bırakılamaz',
    'notification_settings_warning': 'Uyarı Bildirimleri',
    'notification_settings_warning_desc': 'Ardışık 2 gün kontrol yapılmadığında bildirim',
    'notification_settings_caution': 'Dikkat Bildirimleri',
    'notification_settings_caution_desc': 'Bugünkü kontrol yapılmadığında bildirim',
    'notification_settings_info': 'Bilgi Bildirimleri',
    'notification_settings_info_desc': 'Adım sayısı ve pil durumu gibi genel bildirimler',
    'notification_settings_dnd': 'Rahatsız Etmeyin',
    'notification_settings_dnd_start': 'Başlangıç Saati',
    'notification_settings_dnd_end': 'Bitiş Saati',
    'notification_settings_dnd_note': '※ Acil uyarılar, Rahatsız Etmeyin modunda bile iletilir',

    // ── Koruyucu Bağlantı Yönetimi ──
    'connection_title': 'Bağlantı Yönetimi',
    'connection_managed_count': 'Korunan Kişi Sayısı ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'Bağlı Korunan Kişiler',
    'connection_reorder_hint': 'Sıralamayı değiştirmek için aşağıdaki karta uzun basın',
    'connection_empty': 'Bağlı korunan kişi yok',
    'connection_unlink_warning': 'Bağlantıyı kesmek korunan kişinin verilerini silecektir.',
    'connection_unlink_warning_detail':
        'Yeniden bağlandıktan sonra önceki kayıtlar kurtarılamaz. Korunan kişinin kodunu tekrar girmeniz gerekecektir.',
    'connection_heartbeat_schedule': 'Her gün @time',
    'connection_heartbeat_report_time': 'Hal hatır rapor zamanı: ',
    'connection_subject_label': 'Korunan kişi',
    'connection_change_only_in_app': 'yalnızca uygulamadan değiştirilebilir',
    'connection_edit_title': 'Korunan Kişiyi Düzenle',
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
    'heartbeat_schedule_change': 'Bildirim saatini değiştir',
    'heartbeat_schedule_title_ios': 'Bildirim saati',
    'heartbeat_schedule_change_title_ios': 'Bildirim saatini değiştir',
    'heartbeat_schedule_hint_ios':
        'Her gün bu saatte hal hatır bildirimi gelir. Bildirime dokunun veya o sırada uygulamayı açın, böylece hal hatır sinyaliniz gönderilir.',
    'heartbeat_daily_time': 'Her gün @time',
    'heartbeat_scheduled_today':
        'Hal hatır sinyaliniz her gün @time saatinde koruyucularınıza iletilecek.',
    'heartbeat_change_failed_title': 'Saat Değişikliği Başarısız',
    'heartbeat_change_failed_message': 'Sunucuda güncellenemedi.',
    'heartbeat_picker_help': '@limit saatinden önce bir saat seçin',
    'heartbeat_range_limit_title': 'Kullanılamayan saat',
    'heartbeat_range_limit_message':
        'Kontrol saati @limit saatinden önce olmalıdır.',

    // ── Yerel Bildirimler ──
    'local_notification_channel_desc': 'Hal hatır sorgulama hizmeti bildirimleri',

    // ── Diğer ──
    'back_press_exit': 'Çıkmak için geri tuşuna tekrar basın.',

    // ── API Hataları ──
    'error_unknown': 'Bilinmeyen bir hata oluştu.',
    'error_timeout': 'İstek zaman aşımına uğradı.',
    'error_network': 'Lütfen ağ bağlantınızı kontrol edin.',
    'error_unauthorized': 'Kimlik doğrulama gerekli.',

    // ── Bildirim Metinleri ──
    'noti_auto_report_body': 'Hal hatır kontrolü başarıyla alındı.',
    'noti_manual_report_body': 'Korunan kişi manuel olarak hal hatır kontrolü gönderdi.',
    'noti_battery_low_body': 'Telefon pili %20\'nin altında. Şarj etmek gerekebilir.',
    'noti_battery_dead_body':
        'Telefon pil bitmesi nedeniyle kapanmış görünüyor. Son pil seviyesi: %@battery_level. Şarj edildikten sonra otomatik olarak düzelecektir.',
    'noti_caution_suspicious_body':
        'Hal hatır sinyali alındı ancak bugün aktivite kaydı tespit edilmedi. Lütfen bizzat kontrol edin.',
    'noti_caution_missing_body':
        'Bugün planlanan hal hatır kontrolü henüz alınmadı. Lütfen bizzat kontrol edin.',
    'noti_warning_body': 'Hal hatır kontrolleri art arda kaçırıldı. Lütfen bizzat doğrulayın.',
    'noti_warning_suspicious_body':
        'Aktivite kaydı art arda tespit edilmedi. Bizzat doğrulama gereklidir.',
    'noti_urgent_body': '@days gündür hal hatır kontrolü yok. Acil doğrulama gerekli.',
    'noti_urgent_suspicious_body':
        '@days gündür aktivite kaydı tespit edilmedi. Acil doğrulama gereklidir.',
    'noti_steps_body': 'Bugün @steps adım atıldı.',
    'noti_emergency_body': 'Korunan kişi doğrudan yardım istedi. Lütfen hemen kontrol edin.',
    'noti_resolved_body': 'Korunan kişinin hal hatır kontrolü normale döndü.',
    'noti_cleared_by_guardian_title': '✅ Güvenlik onaylandı',
    'noti_cleared_by_guardian_body': 'Koruyuculardan biri güvenliğini bizzat doğruladı.',

    // ── Yerel bildirimler ──
    'local_alarm_title': '💗 Hal hatır kontrolü gerekli',
    'local_alarm_body': 'Lütfen bu bildirime dokunun.',
    // ── iOS 확장 전송 결과 / 오프라인 폴백 ──
    'nse_delivered_title': '✅ İyilik bildirimi gönderildi',
    'nse_delivered_body': 'Bugünkü iyilik bildiriminiz bakıcınıza iletildi.',
    'offline_alarm_title': '💗 Bugünkü bildiriminiz henüz gönderilmedi',
    'offline_alarm_body': 'Bu bildirime bir kez dokunun.\nDokununca bildiriminiz bakıcınıza gönderilir.',
    'wellbeing_check_title': '💛 Hal Hatır Kontrolü',
    'wellbeing_check_body': 'İyi misiniz? Lütfen bu bildirime dokunun.',
    'noti_channel_name': 'Anbu Uyarıları',
    'notification_send_failed_title': '📶 İnternet bağlantınızı kontrol edin',
    'notification_send_failed_body': 'Otomatik olarak yeniden göndermek için bu mesaja dokunun.',
  };
}
