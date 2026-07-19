import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';

/// 전화 연결 유틸
/// - 저장된 연락처가 있으면 바로 전화 (callDirectly)
/// - 없으면 시스템 연락처 선택 화면에서 고른 뒤 전화 (pickContactAndCall, 권한 불필요)
class PhoneUtils {
  static final _contactPicker = FlutterNativeContactPicker();

  /// 저장된 번호로 바로 전화 걸기.
  /// canLaunchUrl로 사전 체크하지 않는다 — iOS에서 Info.plist에
  /// LSApplicationQueriesSchemes로 tel을 선언하지 않으면 실기기에서도
  /// canLaunchUrl('tel:...')이 항상 false를 반환해 정상 기기에서까지
  /// 전화가 막히는 오탐이 발생한다. launchUrl 자체의 반환값만 확인한다
  /// (시뮬레이터는 Phone.app이 없어 tel: 핸들러가 없으므로 항상 실패).
  static Future<void> callDirectly(String phoneNumber) async {
    final number = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (number.isEmpty) return;
    try {
      final ok = await launchUrl(
        Uri.parse('tel:$number'),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) {
        AppSnackbar.show(
          'common_error'.tr,
          'phone_call_failed'.tr,
          type: SnackType.error,
        );
      }
    } catch (_) {
      AppSnackbar.show(
        'common_error'.tr,
        'phone_call_failed'.tr,
        type: SnackType.error,
      );
    }
  }

  /// 연락처 선택 → 전화 걸기
  static Future<void> pickContactAndCall() async {
    final contact = await _contactPicker.selectContact();

    if (contact == null) return;

    final phoneNumbers = contact.phoneNumbers;
    if (phoneNumbers == null || phoneNumbers.isEmpty) return;

    await callDirectly(phoneNumbers.first);
  }
}
