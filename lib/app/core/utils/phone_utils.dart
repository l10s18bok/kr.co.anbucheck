import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:url_launcher/url_launcher.dart';

/// 연락처 선택 후 전화 걸기
/// 1. 시스템 연락처 선택 화면 열기 (권한 불필요)
/// 2. 사용자가 연락처 선택 → 해당 번호로 전화 앱 실행
class PhoneUtils {
  static final _contactPicker = FlutterNativeContactPicker();

  /// 연락처 선택 → 전화 걸기
  static Future<void> pickContactAndCall() async {
    final contact = await _contactPicker.selectContact();

    if (contact == null) return;

    final phoneNumbers = contact.phoneNumbers;
    if (phoneNumbers == null || phoneNumbers.isEmpty) return;

    final number = phoneNumbers.first.replaceAll(RegExp(r'[^0-9+]'), '');
    if (number.isEmpty) return;

    final uri = Uri.parse('tel:$number');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
