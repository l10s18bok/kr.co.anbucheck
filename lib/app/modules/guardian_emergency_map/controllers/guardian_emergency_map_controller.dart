import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:anbucheck/app/core/base/base_controller.dart';

/// 긴급 도움 요청 위치 지도 페이지 컨트롤러
/// arguments로 { lat, lng, accuracy, capturedAt, subjectNickname, inviteCode } 수신
class GuardianEmergencyMapController extends BaseController {
  final Rx<double?> lat = Rx<double?>(null);
  final Rx<double?> lng = Rx<double?>(null);
  final Rx<double?> accuracy = Rx<double?>(null);
  final Rx<DateTime?> capturedAt = Rx<DateTime?>(null);
  final RxString subjectNickname = ''.obs;
  final RxString inviteCode = ''.obs;

  GoogleMapController? _mapController;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      lat.value = _parseDouble(args['lat']);
      lng.value = _parseDouble(args['lng']);
      accuracy.value = _parseDouble(args['accuracy']);
      final raw = args['capturedAt'];
      if (raw is DateTime) {
        capturedAt.value = raw;
      } else if (raw is String && raw.isNotEmpty) {
        capturedAt.value = DateTime.tryParse(raw);
      }
      subjectNickname.value = (args['subjectNickname'] as String?) ?? '';
      inviteCode.value = (args['inviteCode'] as String?) ?? '';
    }
  }

  double? _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  bool get hasLocation => lat.value != null && lng.value != null;

  LatLng? get latLng =>
      hasLocation ? LatLng(lat.value!, lng.value!) : null;

  String get displayName {
    final n = subjectNickname.value;
    if (n.isNotEmpty) return n;
    return inviteCode.value;
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  void onClose() {
    _mapController?.dispose();
    super.onClose();
  }

  Future<void> openExternalMap() async {
    final pos = latLng;
    if (pos == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/?q=${pos.latitude},${pos.longitude}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
