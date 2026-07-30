import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/modules/guardian_notifications/controllers/guardian_notifications_controller.dart';
import 'package:anbucheck/app/core/utils/back_press_handler.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/core/widgets/guardian_bottom_nav.dart';
import 'package:anbucheck/app/routes/app_pages.dart';

/// 보호자 알림 목록 페이지 — 당일 알림만 표시 (서버 API 기반)
class GuardianNotificationsPage
    extends GetWidget<GuardianNotificationsController> {
  const GuardianNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) BackPressHandler.onBackPressed();
      },
      child: Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.notifications_rounded, size: 22.w, color: AppColors.onSurface),
            SizedBox(width: 8.w),
            Flexible(child: Text('notifications_title'.tr, style: AppTextTheme.headlineSmall(), overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          Obx(() => IconButton(
            icon: Icon(Icons.refresh_rounded,
                color: controller.isLoading
                    ? const Color(0xFF4355B9).withValues(alpha: 0.4)
                    : const Color(0xFF4355B9),
                size: 24.w),
            onPressed: controller.isLoading ? null : controller.load,
          )),
          // 전체 삭제 — 지울 알림이 있을 때만 노출한다.
          // 숨길 때도 Visibility(maintainSize)로 자리를 남겨, 알림이 들어오거나
          // 전부 지워질 때 옆의 새로고침 아이콘이 좌우로 튀지 않게 한다.
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.horizontalMargin - 12.w),
            child: Obx(() => Visibility(
              visible: controller.notifications.isNotEmpty,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    size: 24.w,
                    color: controller.isLoading
                        ? const Color(0xFFE53935).withValues(alpha: 0.4)
                        : const Color(0xFFE53935)),
                onPressed:
                    controller.isLoading ? null : () => _confirmDeleteAll(context),
              ),
            )),
          ),
        ],
      ),
      body: Obx(() {
        // 구독 만료 시에는 로드가 컨트롤러에서 차단되어(통신 차단) 목록이 비고,
        // 아래 빈 상태(_EmptyState)가 표시된다.
        final items = controller.notifications;

        // 헤더("오늘 받은 알림" + 자정 삭제 안내 + 등급 안내 [?])는 알림 유무와
        // 무관하게 항상 표시한다 — 알림이 없을 때도 "왜 비어 있는지"(자정 자동 삭제)와
        // 등급 안내 진입점이 사라지지 않아야 한다.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              // 우측 마진을 IconButton 내부 여백(12)만큼 당겨, 48dp 터치 영역을 주면서도
              // 아이콘이 좌측 텍스트와 같은 수평 마진에 맞춰 보이도록 한다(AppBar 액션과 동일 패턴).
              padding: EdgeInsets.only(
                left: AppSpacing.horizontalMargin,
                right: AppSpacing.horizontalMargin - 12.w,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('notifications_today'.tr,
                      style: AppTextTheme.labelMedium(
                          color: const Color(0xFF4355B9), fw: FontWeight.w600)),
                  IconButton(
                    icon: Icon(Icons.help_outline_rounded,
                        size: 24.w,
                        color: AppColors.textTertiary),
                    onPressed: () => _showAlertLevelGuide(context),
                    // 디자인 시스템 최소 터치 영역 48×48dp 확보
                    constraints: BoxConstraints(minWidth: 48.w, minHeight: 48.w),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
              child: Text(
                'notifications_auto_delete_notice'.tr,
                style: AppTextTheme.bodySmall(
                  color: const Color(0xFFE53935).withValues(alpha: 0.7),
                ).copyWith(fontSize: 11.sp),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Expanded(
              child: items.isEmpty && !controller.isLoading
                  ? const _EmptyState()
                  : Stack(
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.horizontalMargin),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...items.map((item) => _NotificationCard(item: item)),
                              SizedBox(height: AppSpacing.sp6),
                            ],
                          ),
                        ),
                        if (controller.isLoading)
                          Container(
                            color: Colors.black.withValues(alpha: 0.1),
                            child: const Center(
                              child: CircularProgressIndicator(color: Color(0xFF4355B9)),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        );
      }),
      bottomNavigationBar: const GuardianBottomNav(currentIndex: 2),
    ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('notifications_delete_all_title'.tr, style: AppTextTheme.headlineSmall(color: const Color(0xFF1A1C1C))),
        content: Text('notifications_delete_all_message'.tr, style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common_cancel'.tr, style: AppTextTheme.bodyLarge(color: const Color(0xFF9E9E9E))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteAll();
            },
            child: Text('common_delete'.tr, style: AppTextTheme.bodyLarge(color: const Color(0xFFE53935), fw: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showAlertLevelGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('notifications_guide_title'.tr, style: AppTextTheme.headlineSmall(color: const Color(0xFF1A1C1C))),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _alertGuideItem(
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF4CAF50),
                title: 'notifications_level_health'.tr,
                description: 'notifications_level_health_desc'.tr,
              ),
              SizedBox(height: AppSpacing.lg),
              _alertGuideItem(
                icon: Icons.info_rounded,
                color: const Color(0xFFFFC107),
                title: 'notifications_level_caution'.tr,
                description: 'notifications_level_caution_desc'.tr,
              ),
              SizedBox(height: AppSpacing.lg),
              _alertGuideItem(
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFFF9800),
                title: 'notifications_level_warning'.tr,
                description: 'notifications_level_warning_desc'.tr,
              ),
              SizedBox(height: AppSpacing.lg),
              _alertGuideItem(
                icon: Icons.error_rounded,
                color: const Color(0xFFE53935),
                title: 'notifications_level_urgent'.tr,
                description: 'notifications_level_urgent_desc'.tr,
              ),
              SizedBox(height: AppSpacing.lg),
              const Divider(color: Color(0xFFE0E0E0)),
              SizedBox(height: AppSpacing.md),
              _alertGuideItem(
                icon: Icons.notifications_rounded,
                color: const Color(0xFF4355B9),
                title: 'notifications_level_info'.tr,
                description: 'notifications_level_info_desc'.tr,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'notifications_activity_note'.tr,
                style: AppTextTheme.bodySmall(color: const Color(0xFF9E9E9E)).copyWith(fontSize: 11.sp),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common_confirm'.tr, style: AppTextTheme.bodyLarge(color: const Color(0xFF4355B9), fw: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _alertGuideItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22.w, color: color),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextTheme.bodyLarge(fw: FontWeight.w600, color: const Color(0xFF1A1C1C))),
              SizedBox(height: 2.h),
              Text(description, style: AppTextTheme.bodySmall(color: const Color(0xFF3F4948))),
            ],
          ),
        ),
      ],
    );
  }

}

// ─── 알림 카드 ─────────────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationEntity item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        width: double.infinity,
        // 1단(아이콘 행)은 36 아이콘 배지가 높이를 잡아 이미 두툼하므로 위쪽 여백만
        // 한 단계 줄인다(lg 16 → md 12). 좌우·아래는 본문 기준이라 lg 유지.
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
          bottom: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        // 2단 구조 — 1단: 아이콘 · 등급 라벨 · 시각(같은 라인, 상하 중앙 정렬)
        //            2단: 알림 본문(카드 좌우 패딩에 그대로 맞춰 전체 폭 사용)
        //
        // 이전에는 아이콘이 좌측에 서고 라벨·시각·본문이 그 오른쪽 열에 들어가서,
        // (a) 아이콘이 카드 상단에 붙어 보이고 (b) 본문의 좌측 시작점이 아이콘 폭만큼
        // 밀려 카드 좌측 패딩과 어긋나 보였다. 등급별로 다른 건 색·아이콘·라벨뿐이므로
        // 이 구조는 모든 알림 카드(정상/정보/주의/경고/긴급)에 동일하게 적용된다.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: _iconColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon, size: 20.w, color: _iconColor),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  // 등급 라벨은 1단의 주인공 — labelSmall(11sp)로는 아이콘 옆에서
                  // 너무 작게 읽혀 labelMedium(14sp) + w900(최대 굵기)으로 올린다.
                  child: Text(
                    _levelLabel,
                    style: AppTextTheme.labelMedium(
                        color: _iconColor, fw: FontWeight.w900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.messageKey != 'steps')
                  // 시각은 보조 정보 — 크기는 라벨과 맞추되 굵기를 낮춰 위계를 유지한다.
                  Text(
                    _formatTime(item.receivedAt),
                    style: AppTextTheme.labelMedium(
                        color: const Color(0xFF4355B9), fw: FontWeight.w500),
                  ),
              ],
            ),
            // 1단 아래 여백은 sm(8) — 구분선 위쪽을 좁혀 1단을 더 조이고,
            // 선 아래는 md(12)로 두어 본문이 선에 붙지 않게 한다(의도적 비대칭).
            SizedBox(height: AppSpacing.sm),
            // 1단/2단 구분선 — 중립 회색 대신 **등급 색을 옅게** 깐다.
            // 카드 배경이 이미 등급 계열 톤이라 회색 실선은 이물감이 크고,
            // 아이콘 배지(alpha 0.15)와 같은 계열을 쓰면 카드 안에 자연스럽게 녹는다.
            // 높이는 screenutil로 스케일하지 않는다 — 헤어라인은 기기가 커져도
            // 굵어지면 안 된다.
            Container(height: 1, color: _iconColor.withValues(alpha: 0.2)),
            SizedBox(height: AppSpacing.md),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${item.displayName} - ',
                    style: AppTextTheme.bodyMedium(fw: FontWeight.w600),
                  ),
                  TextSpan(
                    text: _localizedBody,
                    style: AppTextTheme.bodyMedium(),
                  ),
                ],
              ),
            ),
            if (item.messageKey == 'emergency' && item.hasLocation) ...[
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    Get.toNamed(
                      AppRoutes.guardianEmergencyMap,
                      arguments: {
                        'lat': item.locationLat,
                        'lng': item.locationLng,
                        'accuracy': item.locationAccuracy,
                        'capturedAt': item.locationCapturedAt ?? item.receivedAt,
                        'subjectNickname': item.nickname ?? '',
                        'inviteCode': item.inviteCode ?? '',
                      },
                    );
                  },
                  style: TextButton.styleFrom(
                    // 좌측 패딩 0 — 본문 텍스트와 좌측 시작점을 맞춘다.
                    padding: EdgeInsets.only(right: 12.w, top: 6.h, bottom: 6.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: const Color(0xFF4355B9),
                  ),
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: Text('notifications_view_location'.tr),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) => formatTimeOfDay(dt.hour, dt.minute);

  /// message_key 기반 로컬 번역 본문 (없으면 서버 제공 body 사용)
  String get _localizedBody {
    final key = item.messageKey;
    final p = item.messageParams ?? {};
    if (key == null) return item.body;
    return switch (key) {
      'auto_report'         => 'noti_auto_report_body'.tr,
      'manual_report'       => 'noti_manual_report_body'.tr,
      'battery_low'         => 'noti_battery_low_body'.tr,
      'battery_dead'        => 'noti_battery_dead_body'.trParams({'battery_level': '${p['battery_level'] ?? ''}'}),
      'caution_suspicious'  => 'noti_caution_suspicious_body'.tr,
      'caution_missing'     => 'noti_caution_missing_body'.tr,
      'warning'             => 'noti_warning_body'.tr,
      'warning_suspicious'  => 'noti_warning_suspicious_body'.tr,
      'urgent'              => 'noti_urgent_body'.trParams({'days': '${p['days'] ?? ''}'}),
      'urgent_suspicious'   => 'noti_urgent_suspicious_body'.trParams({'days': '${p['days'] ?? ''}'}),
      'steps'               => 'noti_steps_body'.trParams({
                                  'steps': '${p['steps'] ?? ''}',
                                }),
      'emergency'           => (p['note'] as String?)?.trim().isNotEmpty == true
                                  ? (p['note'] as String).trim()
                                  : 'noti_emergency_body'.tr,
      'resolved'            => 'noti_resolved_body'.tr,
      'cleared_by_guardian' => 'noti_cleared_by_guardian_body'.tr,
      _                     => item.body,
    };
  }

  /// 알림 카드 표시 등급 — 서버 alert_level은 모든 정보성 알림을 'info'로 묶지만,
  /// UX상 "안부 정상 확인"과 "참고용 정보(걸음수/배터리)"를 분리해서 표시한다.
  /// message_key 기준으로 normal / info를 구분하고, 나머지는 alert_level fallback.
  _DisplayLevel get _displayLevel {
    switch (item.messageKey) {
      case 'auto_report':
      case 'manual_report':
      case 'resolved':
      case 'cleared_by_guardian':
        return _DisplayLevel.normal;
      case 'battery_low':
      case 'battery_dead':
      case 'steps':
        return _DisplayLevel.info;
    }
    return switch (item.level) {
      AlertLevel.urgent  => _DisplayLevel.urgent,
      AlertLevel.warning => _DisplayLevel.warning,
      AlertLevel.caution => _DisplayLevel.caution,
      AlertLevel.info    => _DisplayLevel.info,
      AlertLevel.health  => _DisplayLevel.info,
    };
  }

  Color get _backgroundColor {
    final dark = AppColors.isDark;
    return switch (_displayLevel) {
      _DisplayLevel.urgent  => dark ? const Color(0xFF4E0000) : const Color(0xFFFFEBEE),
      _DisplayLevel.warning => dark ? const Color(0xFF4E2000) : const Color(0xFFFFE0B2),
      _DisplayLevel.caution => dark ? const Color(0xFF2E2E00) : const Color(0xFFFFF9C4),
      _DisplayLevel.info    => item.isBatteryRelated
          ? (dark ? const Color(0xFF2A1540) : const Color(0xFFEDE7F6))
          : (dark ? const Color(0xFF1A2540) : const Color(0xFFE3F2FD)),
      _DisplayLevel.normal  => dark ? const Color(0xFF0A3A2A) : const Color(0xFFE8F5E9),
    };
  }

  Color get _iconColor => switch (_displayLevel) {
        _DisplayLevel.urgent  => const Color(0xFFE53935),
        _DisplayLevel.warning => const Color(0xFFFF9800),
        _DisplayLevel.caution => const Color(0xFFFFC107),
        _DisplayLevel.info    => item.isBatteryRelated
            ? const Color(0xFF7B1FA2)
            : const Color(0xFF4355B9),
        _DisplayLevel.normal  => const Color(0xFF43A047),
      };

  IconData get _icon {
    if (item.messageKey == 'steps') return Icons.directions_walk_rounded;
    return switch (_displayLevel) {
      _DisplayLevel.urgent  => Icons.error_rounded,
      _DisplayLevel.warning => Icons.warning_amber_rounded,
      _DisplayLevel.caution => Icons.info_rounded,
      _DisplayLevel.info    => item.isBatteryRelated
          ? Icons.battery_alert_rounded
          : Icons.notifications_rounded,
      _DisplayLevel.normal  => Icons.check_circle_rounded,
    };
  }

  String get _levelLabel => switch (_displayLevel) {
        _DisplayLevel.urgent  => 'notifications_level_urgent'.tr,
        _DisplayLevel.warning => 'notifications_level_warning'.tr,
        _DisplayLevel.caution => 'notifications_level_caution'.tr,
        _DisplayLevel.info    => 'notifications_level_info'.tr,
        // 다이얼로그 안내의 "정상" 라벨과 통일 (notifications_level_health = "정상")
        _DisplayLevel.normal  => 'notifications_level_health'.tr,
      };
}

enum _DisplayLevel { normal, info, caution, warning, urgent }

// ─── 빈 상태 ──────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 80.w,
            color: AppColors.textTertiary.withValues(alpha: 0.4),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'notifications_empty'.tr,
            style: AppTextTheme.bodyLarge(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
