abstract class HiIn {
  static const Map<String, String> translations = {
    // ── सामान्य ──
    'common_confirm': 'पुष्टि करें',
    'common_cancel': 'रद्द करें',
    'common_continue': 'जारी रखें',
    'common_save': 'सहेजें',
    'common_delete': 'हटाएं',
    'common_close': 'बंद करें',
    'common_next': 'अगला',
    'common_previous': 'पिछला',
    'common_start': 'शुरू करें',
    'common_skip': 'छोड़ें',
    'common_later': 'बाद में',
    'common_loading': 'लोड हो रहा है...',
    'common_error': 'त्रुटि',
    'common_complete': 'पूर्ण',
    'common_notice': 'सूचना',
    'common_unlink': 'अनलिंक करें',
    'common_am': 'सुबह',
    'common_pm': 'शाम',
    'common_normal': 'सामान्य',
    'common_connected': 'जुड़ा हुआ',
    'common_disconnected': 'कनेक्शन नहीं',

    // ── ऐप ब्रांड ──
    'app_name': 'Anbu',
    'app_brand': 'Anbu',
    'app_tagline': 'आपकी कुशलता की जांच।',
    'app_service_desc': 'स्वचालित कुशलता जांच सेवा',
    'app_guardian_title': 'Anbu अभिभावक',
    'app_copyright': '© 2026 Averic SB Inc.',

    // ── स्प्लैश ──
    'splash_loading': 'कुशलता जांच हो रही है...',

    // ── अपडेट ──
    'update_required_title': 'अपडेट आवश्यक',
    'update_required_message':
        'कृपया ऐप का उपयोग जारी रखने के लिए संस्करण @version में अपडेट करें।',
    'update_button': 'अपडेट करें',
    'update_available_title': 'अपडेट उपलब्ध',
    'update_available_message': 'संस्करण @version उपलब्ध है।',

    // ── मोड चयन ──
    'mode_select_title': 'अपनी भूमिका चुनें',
    'mode_select_subtitle': 'यह आपके लिए सही सुविधाएं सेट करने में मदद करता है',
    'mode_subject_title': 'मैं चाहता/चाहती हूं कि\nमेरी सुरक्षा पर नजर रखी जाए',
    'mode_subject_button': 'सुरक्षित रहें →',
    'mode_guardian_title': 'मैं अपने प्रिय व्यक्ति\nकी देखभाल करना चाहता/चाहती हूं',
    'mode_guardian_button': 'अभिभावक के रूप में शुरू करें →',
    'mode_select_notice': 'आपके चयन के अनुसार स्क्रीन लेआउट और सूचनाएं भिन्न होंगी',

    // ── अनुमतियां ──
    'permission_title': 'ऐप का उपयोग करने के लिए\nअनुमतियां आवश्यक हैं',
    'permission_notification': 'सूचना अनुमति',
    'permission_notification_subject_desc': 'कुशलता जांच सूचनाएं प्राप्त करने के लिए आवश्यक',
    'permission_notification_guardian_desc':
        'आपके संरक्षित व्यक्तियों की सुरक्षा सूचनाएं प्राप्त करने के लिए आवश्यक',
    'permission_activity': 'गतिविधि पहचान',
    'permission_activity_desc': 'कदमों की पहचान और गतिविधि की पुष्टि के लिए उपयोग किया जाता है',
    'permission_activity_dialog_title': 'गतिविधि अनुमति जानकारी',
    'permission_activity_dialog_message':
        'कदमों की पहचान और गतिविधि की पुष्टि के लिए उपयोग किया जाता है।\nकृपया अगली स्क्रीन पर "अनुमति दें" दबाएं।',
    'permission_notification_required_title': 'सूचना अनुमति आवश्यक',
    'permission_notification_required_message':
        'कुशलता जांच सेवा के लिए सूचना अनुमति आवश्यक है।\nकृपया सेटिंग्स में इसे सक्षम करें।',
    'permission_go_to_settings': 'सेटिंग्स पर जाएं',
    'permission_activity_denied_title': 'शारीरिक गतिविधि अनुमति आवश्यक',
    'permission_activity_denied_message':
        'आपके कदमों का पता लगाने और आपकी सुरक्षा सत्यापित करने के लिए शारीरिक गतिविधि अनुमति आवश्यक है।\n\nइस अनुमति के बिना, कदम की जानकारी अभिभावकों को नहीं भेजी जाएगी।\n\nकृपया ऐप सेटिंग्स में "शारीरिक गतिविधि" अनुमति सक्षम करें।',
    'permission_battery': 'बैटरी अनुकूलन अपवाद',
    'permission_battery_desc':
        'निर्धारित समय पर दैनिक कुशलता जांच छूट न जाए, इसके लिए ऐप को बैटरी अनुकूलन से बाहर रखता है',
    'permission_battery_required_title': 'कृपया बैटरी को "अप्रतिबंधित" पर सेट करें',
    'permission_battery_required_message':
        'यदि "बैटरी अनुकूलन" या "बैटरी सेवर" पर सेट है, तो दैनिक कुशलता जांच में देरी हो सकती है या छूट सकती है।\n\n[सेटिंग्स पर जाएं] टैप करने के बाद:\n1. "बैटरी" चुनें\n2. "अप्रतिबंधित" में बदलें',
    'permission_battery_go_to_settings': 'सेटिंग्स पर जाएं',
    'permission_hibernation_title': '"अप्रयुक्त ऐप्स को रोकें" बंद करें',
    'permission_hibernation_highlight': 'अप्रयुक्त ऐप्स को रोकें',
    'permission_hibernation_message':
        'यदि आप कई महीनों तक ऐप नहीं खोलते हैं, तो Android ऐप को स्वचालित रूप से रोक सकता है, जिससे कल्याण जांच बाधित हो सकती है।\n\n[ऐप सेटिंग्स खोलें] पर टैप करें और "अप्रयुक्त ऐप्स को रोकें" बंद करें।',
    'permission_hibernation_go_to_settings': 'ऐप सेटिंग्स खोलें',

    // ── ऑनबोर्डिंग ──
    'onboarding_title_1': 'अकेले रहने वाले\nप्रियजन की चिंता है?',
    'onboarding_desc_1': 'दूर रहकर भी\nआप सोचते हैं कि वे ठीक हैं या नहीं।\nAnbu आपके साथ है।',
    'onboarding_title_2': 'बिना एक शब्द कहे\nकुशलता की जांच',
    'onboarding_desc_2':
        'बस स्मार्टफोन का उपयोग करके\nरोज एक कुशलता संकेत\nस्वचालित रूप से भेजा जाता है।',
    'onboarding_title_3': 'अपने प्रियजनों के साथ\nकुशलता साझा करें',
    'onboarding_desc_3': 'रोज की जांच से\nस्थायी मानसिक शांति बनती है।\nचलिए शुरू करते हैं।',
    'onboarding_title_4': 'कोई नाम नहीं, कोई फोन नंबर नहीं\n— कुछ भी एकत्र नहीं',
    'onboarding_desc_4': 'केवल एक संकेत भेजा जाता है:\n"मैं ठीक हूं।"\nआपकी जानकारी सुरक्षित है।',
    'onboarding_role_subject': 'संरक्षित व्यक्ति',
    'onboarding_role_guardian': 'अभिभावक',
    'onboarding_role_guardian_subject': 'अभिभावक और संरक्षित',
    'onboarding_already_registered_title': 'डिवाइस पहले से पंजीकृत',
    'onboarding_already_registered_message':
        'यह डिवाइस पहले से "@roleLabel" मोड में पंजीकृत है।\n"@roleLabel" के रूप में जारी रखें?\n\nया "@newRoleLabel" मोड में बदलें?\nबदलने से सभी मौजूदा डेटा हट जाएगा।',
    'onboarding_already_registered_message_gs':
        'यह डिवाइस पहले से "@roleLabel" मोड में पंजीकृत है।\n"@newRoleLabel" मोड में बदलने पर अभिभावक और संरक्षित दोनों के डेटा हटा दिए जाएंगे।',
    'onboarding_registration_failed_title': 'पंजीकरण विफल',
    'onboarding_registration_failed_message':
        'सर्वर से कनेक्ट नहीं हो पा रहा। कृपया बाद में पुनः प्रयास करें।',

    // ── संरक्षित व्यक्ति होम ──
    'subject_home_share_title': 'अपना सुरक्षा कोड साझा करें',
    'subject_home_guardian_count': 'जुड़े अभिभावक: @count',
    'subject_home_check_title_last': 'अंतिम कुशलता जांच',
    'subject_home_check_title_scheduled': 'निर्धारित जांच समय',
    'subject_home_check_title_checking': 'कुशलता जांच हो रही है',
    'subject_home_check_body_reported': '@time पर रिपोर्ट किया गया',
    'subject_home_check_body_scheduled': '@time पर निर्धारित',
    'subject_home_check_body_waiting': '@time से प्रतीक्षा में',
    'subject_home_battery_status': 'बैटरी स्थिति',
    'subject_home_battery_charging': 'चार्ज हो रहा है',
    'subject_home_battery_full': 'पूर्ण',
    'subject_home_battery_low': 'कम बैटरी',
    'subject_home_connectivity_status': 'कनेक्टिविटी',
    'subject_home_report_loading': 'रिपोर्ट हो रही है...',
    'subject_home_report_button': 'अभी सुरक्षा रिपोर्ट करें',
    'subject_home_report_desc': 'अपने अभिभावक को बताएं कि आप ठीक हैं',
    'subject_home_emergency_button': 'मुझे मदद चाहिए',
    'subject_home_emergency_desc': 'अभिभावकों को आपातकालीन अलर्ट भेजता है',
    'subject_home_emergency_loading': 'आपातकालीन अलर्ट भेजा जा रहा है...',
    'subject_home_emergency_sent': 'आपातकालीन अलर्ट भेज दिया गया',
    'subject_home_emergency_failed': 'आपातकालीन अलर्ट भेजने में विफल',
    'subject_home_manual_report_limit_reached': 'आपने आज की सुरक्षा रिपोर्ट पहले ही भेज दी है। कृपया कल पुनः प्रयास करें।',
    'subject_home_emergency_confirm_title': 'आपातकालीन सहायता अनुरोध',
    'subject_home_emergency_confirm_body':
        'सभी अभिभावकों को आपातकालीन अलर्ट भेजा जाएगा।\nआपकी वर्तमान स्थिति भी साझा की जाएगी।\nक्या आप वास्तव में सहायता का अनुरोध करना चाहते हैं?',
    'emergency_sent_with_location': 'आपातकालीन अलर्ट भेज दिया गया (स्थान सहित)',
    'emergency_sent_without_location': 'आपातकालीन अलर्ट भेज दिया गया',
    'notifications_view_location': '🗺️ स्थान देखें',
    'emergency_map_title': 'आपातकालीन स्थान',
    'emergency_map_subject_label': 'देखभाल प्राप्तकर्ता',
    'emergency_map_captured_at_label': 'प्राप्त समय',
    'emergency_map_accuracy_label': 'सटीकता',
    'emergency_map_open_external': 'बाहरी मानचित्र ऐप में खोलें',
    'emergency_map_no_location': 'कोई स्थान जानकारी उपलब्ध नहीं',
    'emergency_location_permission_denied_snackbar': 'स्थान अनुमति के बिना आपातकालीन अलर्ट भेजा गया',
    'subject_home_emergency_confirm_send': 'आपातकालीन अनुरोध भेजें',
    'subject_home_share_text': 'Anbu ऐप से मेरी कुशलता जांचें!\nआमंत्रण कोड: @code',
    'subject_home_share_subject': 'Anbu आमंत्रण कोड',
    'subject_home_code_copied': 'कोड कॉपी किया गया',

    // ── संरक्षित व्यक्ति ड्रॉअर ──
    'drawer_light_mode': 'लाइट मोड',
    'drawer_dark_mode': 'डार्क मोड',
    'drawer_privacy_policy': 'गोपनीयता नीति',
    'drawer_terms': 'सेवा की शर्तें',
    'drawer_withdraw': 'खाता हटाएं',
    'drawer_withdraw_message': 'आपका खाता और सभी डेटा हटा दिया जाएगा।\nक्या आप सुनिश्चित हैं?',

    // ── अभिभावक डैशबोर्ड ──
    'guardian_status_normal': 'सामान्य',
    'guardian_status_caution': 'सावधानी',
    'guardian_status_warning': 'चेतावनी',
    'guardian_status_urgent': 'अत्यावश्यक',
    'guardian_status_confirmed': 'सुरक्षा पुष्ट',
    'guardian_subscription_expired': 'सदस्यता समाप्त हो गई',
    'guardian_subscription_expired_message':
        'चेतावनी सूचनाएं नहीं भेजी जा रही हैं।\nसुरक्षा जारी रखने के लिए सदस्यता नवीनीकृत करें।',
    'guardian_subscribe': 'सदस्यता लें',
    'guardian_payment_preparing': 'भुगतान सुविधा जल्द आ रही है।',
    'guardian_today_summary': 'आज की कुशलता सारांश',
    'guardian_no_subjects': 'कोई संरक्षित व्यक्ति जुड़ा नहीं है।',
    'guardian_checking_subjects': 'वर्तमान में @count संरक्षित व्यक्ति(यों)\nकी जांच हो रही है।',
    'guardian_subject_list': 'संरक्षित व्यक्ति सूची',
    'guardian_call_now': 'अभी कॉल करें',
    'guardian_confirm_safety': 'सुरक्षा पुष्ट करें',
    'guardian_no_check_history': 'कोई जांच इतिहास नहीं',
    'guardian_last_check_now': 'अंतिम जांच: अभी',
    'guardian_last_check_minutes': 'अंतिम जांच: @minutes मिनट पहले',
    'guardian_last_check_hours': 'अंतिम जांच: @hours घंटे पहले',
    'guardian_last_check_days': 'अंतिम जांच: @days दिन पहले',
    'guardian_activity_stable': 'गतिविधि: स्थिर',
    'guardian_activity_very_active': 'बहुत सक्रिय',
    'guardian_activity_active': 'सक्रिय',
    'guardian_activity_needs_exercise': 'व्यायाम आवश्यक',
    'guardian_activity_collecting': 'डेटा एकत्र हो रहा है',
    'guardian_error_load_step_history': 'चरण इतिहास लोड नहीं हो सका',
    'guardian_chart_y_axis_steps': 'कदम',
    'guardian_chart_x_axis_last_7_days': 'पिछले 7 दिन',
    'guardian_chart_x_axis_last_30_days': 'पिछले 30 दिन',
    'guardian_chart_today': 'आज',
    'guardian_safety_needed': 'सुरक्षा जांच आवश्यक',
    'guardian_error_load_subjects': 'संरक्षित व्यक्तियों की सूची लोड करने में विफल।',
    'guardian_error_clear_alerts': 'चेतावनियां हटाने में विफल।',

    // ── अभिभावक संरक्षित व्यक्ति जोड़ें ──
    'add_subject_title': 'संरक्षित व्यक्ति जोड़ें',
    'add_subject_guide_title': 'संरक्षित व्यक्ति का अनोखा कोड और उपनाम दर्ज करें।',
    'add_subject_guide_subtitle':
        'संरक्षित व्यक्ति के ऐप को जोड़कर उनके स्वास्थ्य और गतिविधि पर नजर रखें।',
    'add_subject_code_label': 'अनोखा कोड (7 अंक)',
    'add_subject_code_hint': '123-4567',
    'add_subject_code_info': 'अनोखा कोड संरक्षित व्यक्ति के ऐप में मिल सकता है।',
    'add_subject_alias_label': 'संरक्षित व्यक्ति का उपनाम',
    'add_subject_alias_hint': 'जैसे: मां, पिताजी',
    'add_subject_connect': 'जोड़ें',
    'add_subject_error_login': 'लॉगिन आवश्यक।',
    'add_subject_success': 'संरक्षित व्यक्ति सफलतापूर्वक जुड़ गया।',
    'add_subject_error_invalid_code': 'अमान्य कोड।',
    'add_subject_error_already_connected': 'पहले से जुड़ा हुआ।',
    'add_subject_error_failed': 'कनेक्शन विफल। कृपया पुनः प्रयास करें।',
    'add_subject_button': 'नया संरक्षित व्यक्ति जोड़ें',

    // ── अभिभावक सेटिंग्स ──
    'settings_title': 'सेटिंग्स',
    'settings_light_mode': 'लाइट मोड',
    'settings_dark_mode': 'डार्क मोड',
    'settings_connection_management': 'कनेक्शन प्रबंधन',
    'settings_managed_subjects': 'प्रबंधित संरक्षित व्यक्ति',
    'settings_managed_subjects_count': '@current / @max',
    'settings_subscription_service': 'सदस्यता और सेवा',
    'settings_current_membership': 'वर्तमान सदस्यता',
    'settings_premium': 'प्रीमियम सक्रिय',
    'settings_free_trial': 'मुफ्त परीक्षण',
    'settings_days_remaining': '@days दिन शेष',
    'settings_manage_subscription': 'सदस्यता प्रबंधित करें',
    'settings_notification': 'सूचना सेटिंग्स',
    'settings_terms_section': 'कानूनी',
    'settings_privacy_policy': 'गोपनीयता नीति',
    'settings_terms': 'सेवा की शर्तें',
    'settings_app_version': 'संस्करण: v@version',

    // ── G+S (अभिभावक + संरक्षित) ──
    'gs_enable_button': 'मेरी भी सुरक्षा करें',
    'gs_safety_code_button': 'मेरा सुरक्षा कोड देखें',
    'gs_safety_code_title': 'मेरा सुरक्षा कोड',
    'gs_enable_dialog_title': 'सुरक्षा सक्रिय करें',
    'gs_enable_dialog_body':
        'आप अभिभावक कार्यक्षमता बनाए रखते हुए सुरक्षा प्राप्त कर सकते हैं।\nएक सुरक्षा कोड जारी किया जाएगा — कृपया इसे अन्य अभिभावकों के साथ साझा करें।',
    'gs_enable_dialog_ios_warning_title': '⚠ iOS, Android से अलग तरीके से काम करता है',
    'gs_enable_dialog_ios_warning_body':
        'iOS पर, हर दिन निर्धारित समय पर एक "वेलनेस पुश सूचना" दिखाई देती है। आपका वेलनेस संकेत भेजने के लिए आपको सूचना पर टैप करना होगा या उस समय के आसपास स्वयं ऐप खोलना होगा। यदि आप ऐप नहीं खोलते हैं, तो आपके अभिभावकों को जांच छूटने का अलर्ट मिल सकता है।',
    'gs_enable_dialog_ios_confirm': 'समझ गया, सक्रिय करें',
    'gs_enable_confirm': 'सक्रिय करें',
    'gs_enabled_message': 'सुरक्षा सक्रिय हो गई',
    'gs_enable_failed': 'सुरक्षा सक्रिय करने में विफल',
    'gs_disable_dialog_title': 'सुरक्षा निष्क्रिय करें',
    'gs_disable_dialog_body':
        'सुरक्षा निष्क्रिय करने पर आपका सुरक्षा कोड हटा दिया जाएगा और जुड़े अभिभावकों को जाँच भेजना बंद हो जाएगा।',
    'gs_disable_confirm': 'निष्क्रिय करें',
    'gs_disabled_message': 'सुरक्षा निष्क्रिय हो गई',
    'gs_disable_failed': 'सुरक्षा निष्क्रिय करने में विफल',
    'gs_activity_permission_denied_warning': 'कदम गिनने की अनुमति अस्वीकार की गई। अनुमति देने के लिए यहां टैप करें।',
    'gs_activity_permission_settings_title': 'अनुमति आवश्यक',
    'gs_activity_permission_settings_body': 'कृपया ऐप सेटिंग्स में शारीरिक गतिविधि (गति और फ़िटनेस) अनुमति दें।',
    'gs_activity_permission_settings_go': 'सेटिंग्स पर जाएं',

    // ── अभिभावक सूचनाएं ──
    'notifications_title': 'सूचनाएं',
    'notifications_today': 'आज की सूचनाएं',
    'notifications_empty': 'आज कोई सूचना नहीं',
    'notifications_delete_all_title': 'सभी सूचनाएं हटाएं',
    'notifications_delete_all_message': 'आज की सभी सूचनाएं हटाएं?',
    'notifications_delete_failed': 'सूचनाएं हटाने में विफल।',
    'notifications_guide_title': 'सूचना स्तर मार्गदर्शिका',
    'notifications_level_health': 'सामान्य',
    'notifications_level_health_desc': 'संरक्षित व्यक्ति की कुशलता सामान्य रूप से पुष्ट',
    'notifications_level_caution': 'सावधानी',
    'notifications_level_caution_desc': 'अभी तक कोई कुशल संकेत या फोन उपयोग नहीं मिला',
    'notifications_level_warning': 'चेतावनी',
    'notifications_level_warning_desc': 'कई दिनों से कोई कुशल संकेत या फोन उपयोग नहीं मिला',
    'notifications_level_urgent': 'अत्यावश्यक',
    'notifications_level_urgent_desc': 'अभी तुरंत जाँच आवश्यक',
    'notifications_level_info': 'जानकारी',
    'notifications_level_info_desc': 'कदम, बैटरी कम और अन्य सूचनाएँ',
    'notifications_activity_note':
        '※ यदि कदम डेटा एकत्र नहीं हो सका तो गतिविधि जानकारी नहीं दिख सकती।',

    // ── अभिभावक सूचना सेटिंग्स ──
    'notification_settings_title': 'सूचना सेटिंग्स',
    'notification_settings_push': 'पुश सूचनाएं',
    'notification_settings_all': 'सभी सूचनाएं',
    'notification_settings_all_desc': 'सभी सूचना श्रेणियों को एक साथ सक्षम या अक्षम करें।',
    'notification_settings_level_section': 'स्तर सेटिंग्स',
    'notification_settings_urgent': 'अत्यावश्यक अलर्ट',
    'notification_settings_urgent_desc': 'अत्यावश्यक अलर्ट अक्षम नहीं किए जा सकते',
    'notification_settings_warning': 'चेतावनी अलर्ट',
    'notification_settings_warning_desc': 'लगातार 2 दिन जांच न होने पर अलर्ट',
    'notification_settings_caution': 'सावधानी अलर्ट',
    'notification_settings_caution_desc': 'आज की जांच गायब होने पर अलर्ट',
    'notification_settings_info': 'जानकारी अलर्ट',
    'notification_settings_info_desc': 'सामान्य अलर्ट जैसे कदम संख्या और बैटरी स्थिति',
    'notification_settings_dnd': 'परेशान न करें',
    'notification_settings_dnd_start': 'शुरू का समय',
    'notification_settings_dnd_end': 'समाप्ति का समय',
    'notification_settings_dnd_note': '※ अत्यावश्यक अलर्ट परेशान न करें मोड में भी आते हैं',
    'notification_settings_dnd_start_default': 'रात 10:00',
    'notification_settings_dnd_end_default': 'सुबह 7:00',

    // ── अभिभावक कनेक्शन प्रबंधन ──
    'connection_title': 'कनेक्शन प्रबंधन',
    'connection_managed_count': 'प्रबंधित संरक्षित व्यक्ति ',
    'connection_managed_count_value': '@current / @max',
    'connection_connected_subjects': 'जुड़े संरक्षित व्यक्ति',
    'connection_empty': 'कोई जुड़ा हुआ संरक्षित व्यक्ति नहीं',
    'connection_unlink_warning': 'अनलिंक करने से संरक्षित व्यक्ति का डेटा हट जाएगा।',
    'connection_unlink_warning_detail':
        'पुनः जोड़ने के बाद पिछले रिकॉर्ड पुनर्प्राप्त नहीं किए जा सकते। आपको संरक्षित व्यक्ति का कोड फिर से दर्ज करना होगा।',
    'connection_heartbeat_schedule': 'रोज @time पर',
    'connection_heartbeat_report_time': 'कुशलता रिपोर्ट समय: ',
    'connection_subject_label': 'संरक्षित व्यक्ति',
    'connection_change_only_in_app': 'केवल ऐप में बदला जा सकता है',
    'connection_edit_title': 'संरक्षित व्यक्ति संपादित करें',
    'connection_alias_label': 'उपनाम',
    'connection_unlink_title': 'अनलिंक करें',
    'connection_unlink_confirm': '@alias को अनलिंक करें?',
    'connection_unlink_success': 'सफलतापूर्वक अनलिंक किया।',
    'connection_unlink_failed': 'अनलिंक करने में विफल।',
    'connection_load_failed': 'सूची लोड करने में विफल।',

    // ── अभिभावक नीचे नेविगेशन ──
    'nav_home': 'होम',
    'nav_connection': 'कनेक्ट',
    'nav_notification': 'अलर्ट',
    'nav_settings': 'सेटिंग्स',

    // ── Heartbeat ──
    'heartbeat_schedule_change': 'जांच समय बदलें',
    'heartbeat_schedule_title_ios': 'वेलनेस पुश सूचना समय',
    'heartbeat_schedule_change_title_ios': 'वेलनेस पुश सूचना समय बदलें',
    'heartbeat_schedule_hint_ios':
        'हर दिन इस समय एक वेलनेस पुश सूचना आती है। अपना वेलनेस संकेत भेजने के लिए सूचना पर टैप करें या उस समय के आसपास ऐप खोलें।',
    'heartbeat_daily_time': 'रोज @time पर',
    'heartbeat_scheduled_today': 'आज @time पर कुशलता जांच निर्धारित है।',
    'heartbeat_change_failed_title': 'समय बदलना विफल',
    'heartbeat_change_failed_message': 'सर्वर पर अपडेट नहीं हो सका।',

    // ── स्थानीय सूचनाएं ──
    'local_notification_channel': 'कुशलता अलर्ट',
    'local_notification_channel_desc': 'कुशलता जांच सेवा सूचनाएं',

    // ── अन्य ──
    'back_press_exit': 'बाहर निकलने के लिए फिर से दबाएं।',

    // ── API त्रुटियां ──
    'error_unknown': 'एक अज्ञात त्रुटि हुई।',
    'error_timeout': 'अनुरोध का समय समाप्त हो गया।',
    'error_network': 'कृपया अपना नेटवर्क कनेक्शन जांचें।',
    'error_unauthorized': 'प्रमाणीकरण आवश्यक है।',

    // ── सूचना सामग्री ──
    'noti_auto_report_body': 'आज की निर्धारित कुशलता जांच प्राप्त हुई।',
    'noti_manual_report_body': 'संरक्षित व्यक्ति ने मैन्युअल रूप से कुशलता जांच भेजी।',
    'noti_battery_low_body': 'फोन की बैटरी 20% से कम है। चार्जिंग की आवश्यकता हो सकती है।',
    'noti_battery_dead_body':
        'फोन बैटरी खत्म होने से बंद हो गया लगता है। अंतिम बैटरी स्तर: @battery_level%। चार्ज करने के बाद स्वतः ठीक हो जाएगा।',
    'noti_caution_suspicious_body':
        'कुशलता संकेत प्राप्त हुआ, लेकिन फोन उपयोग के कोई संकेत नहीं हैं। कृपया व्यक्तिगत रूप से जांचें।',
    'noti_caution_missing_body':
        'आज की निर्धारित कुशलता जांच अभी तक प्राप्त नहीं हुई है। कृपया व्यक्तिगत रूप से जांचें।',
    'noti_warning_body': 'कुशलता जांच लगातार छूट रही है। कृपया व्यक्तिगत रूप से सत्यापित करें।',
    'noti_warning_suspicious_body':
        'लगातार फोन उपयोग के संकेत नहीं मिले। व्यक्तिगत सत्यापन आवश्यक है।',
    'noti_urgent_body': '@days दिनों से कुशलता जांच नहीं हुई। तत्काल सत्यापन आवश्यक है।',
    'noti_urgent_suspicious_body':
        '@days दिनों से फोन उपयोग के कोई संकेत नहीं। तत्काल सत्यापन आवश्यक है।',
    'noti_steps_body': 'आज @steps कदम चले।',
    'noti_emergency_body': 'संरक्षित व्यक्ति ने सीधे मदद का अनुरोध किया है। कृपया तुरंत जांचें।',
    'noti_resolved_body': 'संरक्षित व्यक्ति की स्वास्थ्य जाँच सामान्य हो गई है।',
    'noti_cleared_by_guardian_title': '✅ सुरक्षा पुष्टि',
    'noti_cleared_by_guardian_body': 'एक अभिभावक ने व्यक्तिगत रूप से सुरक्षा की पुष्टि की है।',

    // ── स्थानीय सूचनाएँ ──
    'local_alarm_title': '💗 कुशलता जांच आवश्यक है',
    'local_alarm_body': 'कृपया इस सूचना पर टैप करें।',
    'wellbeing_check_title': '💛 कुशलता जांच',
    'wellbeing_check_body': 'क्या आप ठीक हैं? कृपया इस सूचना पर टैप करें।',
    'noti_channel_name': 'Anbu सूचनाएँ',
  };
}
