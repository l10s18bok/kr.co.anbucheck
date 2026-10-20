import 'package:anbucheck/app/core/utils/app_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/modules/guardian_emergency_map/controllers/guardian_emergency_map_controller.dart';

class GuardianEmergencyMapPage extends GetWidget<GuardianEmergencyMapController> {
  const GuardianEmergencyMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('emergency_map_title'.tr),
        backgroundColor: AppColors.guardianPrimary,
        foregroundColor: AppColors.guardianOnPrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 20.w),
          onPressed: () => AppNav.back(),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (!controller.hasLocation) {
            return Center(
              child: Text(
                'emergency_map_no_location'.tr,
                style: AppTextTheme.bodyLarge(color: AppColors.textSecondary),
              ),
            );
          }
          final position = controller.latLng!;
          return Column(
            children: [
              Expanded(
                child: _ResumeSafeMap(
                  controller: controller,
                  position: position,
                  title: controller.displayName.isEmpty
                      ? 'emergency_map_subject_label'.tr
                      : controller.displayName,
                  snippet: _formatCapturedAt(controller.capturedAt.value),
                ),
              ),
              _BottomInfoCard(controller: controller),
            ],
          );
        }),
      ),
    );
  }

  static String _formatCapturedAt(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _BottomInfoCard extends StatelessWidget {
  final GuardianEmergencyMapController controller;
  const _BottomInfoCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: AppColors.surfaceContainerHigh, width: 1),
        ),
      ),
      child: Obx(() {
        final name = controller.displayName;
        final acc = controller.accuracy.value;
        final captured = controller.capturedAt.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _infoRow(
              label: 'emergency_map_subject_label'.tr,
              value: name.isEmpty ? '—' : name,
            ),
            SizedBox(height: 6.h),
            _infoRow(
              label: 'emergency_map_captured_at_label'.tr,
              value: _formatCaptured(captured),
            ),
            if (acc != null) ...[
              SizedBox(height: 6.h),
              _infoRow(
                label: 'emergency_map_accuracy_label'.tr,
                value: '±${acc.toStringAsFixed(0)}m',
              ),
            ],
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.guardianPrimary,
                  foregroundColor: AppColors.guardianOnPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                onPressed: controller.openExternalMap,
                icon: const Icon(Icons.map_outlined),
                label: Text('emergency_map_open_external'.tr),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _infoRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: AppTextTheme.bodyMedium(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextTheme.bodyMedium(
              color: AppColors.textPrimary,
              fw: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatCaptured(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    final y = local.year.toString();
    final mo = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi';
  }
}

/// 외부 지도 앱 등으로 갔다 돌아오면(앱 resume) GoogleMap의 플랫폼 뷰가 타일을 그리지 못하고 빈 회색으로
/// 남는 경우가 있다(안드로이드 폴드 에뮬레이터 실측: 구글 로고만 보이고 지도·마커 없음).
/// resume 때마다 키를 바꿔 지도를 새로 만든다 — 위치·마커는 컨트롤러 값에서 다시 그려진다.
class _ResumeSafeMap extends StatefulWidget {
  const _ResumeSafeMap({
    required this.controller,
    required this.position,
    required this.title,
    required this.snippet,
  });

  final GuardianEmergencyMapController controller;
  final LatLng position;
  final String title;
  final String snippet;

  @override
  State<_ResumeSafeMap> createState() => _ResumeSafeMapState();
}

class _ResumeSafeMapState extends State<_ResumeSafeMap> with WidgetsBindingObserver {
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() => _generation++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      key: ValueKey(_generation),
      initialCameraPosition: CameraPosition(target: widget.position, zoom: 16),
      markers: {
        Marker(
          markerId: const MarkerId('emergency_subject'),
          position: widget.position,
          infoWindow: InfoWindow(title: widget.title, snippet: widget.snippet),
        ),
      },
      onMapCreated: widget.controller.onMapCreated,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    );
  }
}
