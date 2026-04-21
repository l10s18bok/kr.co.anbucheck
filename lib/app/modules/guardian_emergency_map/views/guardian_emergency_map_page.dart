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
          onPressed: () => Get.back(),
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
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: position,
                    zoom: 16,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('emergency_subject'),
                      position: position,
                      infoWindow: InfoWindow(
                        title: controller.displayName.isEmpty
                            ? 'emergency_map_subject_label'.tr
                            : controller.displayName,
                        snippet: _formatCapturedAt(
                          controller.capturedAt.value,
                        ),
                      ),
                    ),
                  },
                  onMapCreated: controller.onMapCreated,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
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
