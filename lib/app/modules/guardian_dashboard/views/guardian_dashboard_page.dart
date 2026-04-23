import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:anbucheck/app/core/utils/back_press_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/utils/app_snackbar.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/modules/guardian_dashboard/controllers/guardian_dashboard_controller.dart';
import 'package:anbucheck/app/core/utils/phone_utils.dart';
import 'package:anbucheck/app/core/widgets/add_subject_button.dart';
import 'package:anbucheck/app/core/widgets/banner_ad_widget.dart';
import 'package:anbucheck/app/core/widgets/guardian_bottom_nav.dart';

/// 보호자 대시보드 — 시안 _5 기준
class GuardianDashboardPage extends GetView<GuardianDashboardController> {
  const GuardianDashboardPage({super.key});

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
          title: Text('Anbu Guardian', style: AppTextTheme.headlineSmall()),
          actions: [
            Obx(() {
              if (controller.subjects.isEmpty) return const SizedBox.shrink();
              final level = controller.highestAlertLevel;
              final color = switch (level) {
                'caution' => const Color(0xFFF59E0B),
                'warning' => const Color(0xFFE65100),
                'urgent' => const Color(0xFFE53935),
                _ => const Color(0xFF00685E),
              };
              final bgColor = switch (level) {
                'caution' => const Color(0xFFFFFDE7),
                'warning' => const Color(0xFFFFF3E0),
                'urgent' => const Color(0xFFFFEBEE),
                _ => const Color(0xFFE8F5E9),
              };
              final label = switch (level) {
                'caution' => 'guardian_status_caution'.tr,
                'warning' => 'guardian_status_warning'.tr,
                'urgent' => 'guardian_status_urgent'.tr,
                _ => 'guardian_status_normal'.tr,
              };
              return Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 14.w, color: color),
                      SizedBox(width: 3.w),
                      Flexible(
                        child: Text(
                          label,
                          style: AppTextTheme.labelSmall(color: color, fw: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),

              // 구독 만료 안내 배너
              Obx(() {
                if (controller.isSubscriptionActive.value) {
                  return const SizedBox.shrink();
                }
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: AppSpacing.md),
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE65100).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 18.w,
                            color: const Color(0xFFE65100),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'guardian_subscription_expired'.tr,
                            style: AppTextTheme.bodyMedium(
                              color: const Color(0xFFE65100),
                              fw: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'guardian_subscription_expired_message'.tr,
                        style: AppTextTheme.bodySmall(color: const Color(0xFF4E2C00)),
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        width: double.infinity,
                        height: 40.h,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: 인앱 결제 SDK 연동 후 구현
                            AppSnackbar.show('common_notice'.tr, 'guardian_payment_preparing'.tr);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE65100),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            'guardian_subscribe'.tr,
                            style: AppTextTheme.labelMedium(
                              color: Colors.white,
                              fw: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // 상단 레이블
              Text(
                'guardian_today_summary'.tr,
                style: AppTextTheme.labelMedium(color: AppColors.textTertiary, fw: FontWeight.w500),
              ),
              SizedBox(height: 6.h),

              // 요약 텍스트
              Obx(() {
                final count = controller.subjects.length;
                final text = count == 0
                    ? 'guardian_no_subjects'.tr
                    : 'guardian_checking_subjects'.trParams({'count': count.toString()});
                return Text(text, style: AppTextTheme.headlineMedium(fw: FontWeight.w700));
              }),
              SizedBox(height: AppSpacing.sp6),

              // 대상자 리스트 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'guardian_subject_list'.tr,
                    style: AppTextTheme.bodyLarge(fw: FontWeight.w600),
                  ),
                  Flexible(
                    child: Obx(() {
                      final subjects = controller.subjects;
                      final counts = {
                        'normal': subjects
                            .where((s) => s.alertLevel == 'normal' || s.alertLevel == 'info')
                            .length,
                        'caution': subjects.where((s) => s.alertLevel == 'caution').length,
                        'warning': subjects.where((s) => s.alertLevel == 'warning').length,
                        'urgent': subjects.where((s) => s.alertLevel == 'urgent').length,
                      };
                      const colors = {
                        'normal': Color(0xFF00685E),
                        'caution': Color(0xFFF59E0B),
                        'warning': Color(0xFFE65100),
                        'urgent': Color(0xFFE53935),
                      };
                      final labels = {
                        'normal': 'guardian_status_normal'.tr,
                        'caution': 'guardian_status_caution'.tr,
                        'warning': 'guardian_status_warning'.tr,
                        'urgent': 'guardian_status_urgent'.tr,
                      };
                      final items = counts.entries.where((e) => e.value > 0).toList();
                      if (items.isEmpty) return const SizedBox.shrink();
                      return Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 6.w,
                        runSpacing: 4.h,
                        children: items
                            .map(
                              (e) => _LegendDot(
                                color: colors[e.key]!,
                                label: '${labels[e.key]}: ${e.value}',
                              ),
                            )
                            .toList(),
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),

              // 대상자 카드 슬라이드
              Obx(() {
                final items = controller.subjects;
                if (items.isEmpty) return const SizedBox.shrink();

                return Column(
                  children: [
                    SizedBox(
                      height: 180.h,
                      child: PageView.builder(
                        clipBehavior: Clip.none,
                        padEnds: false,
                        itemCount: items.length,
                        controller: PageController(viewportFraction: items.length > 1 ? 0.92 : 1.0),
                        onPageChanged: (i) => controller.currentCardIndex.value = i,
                        itemBuilder: (_, i) {
                          final subject = items[i];
                          final level = subject.alertLevel == 'info'
                              ? 'normal'
                              : subject.alertLevel;
                          final isNormal = level == 'normal';

                          final statusColor = switch (level) {
                            'caution' => const Color(0xFFF59E0B),
                            'warning' => const Color(0xFFE65100),
                            'urgent' => const Color(0xFFE53935),
                            _ => const Color(0xFF00685E),
                          };
                          final dark = AppColors.isDark;
                          final bgColor = switch (level) {
                            'caution' =>
                              dark
                                  ? const Color(0xFF2E2E00).withValues(alpha: 0.6)
                                  : const Color(0xFFFFF9C4).withValues(alpha: 0.6),
                            'warning' =>
                              dark
                                  ? const Color(0xFF4E2000).withValues(alpha: 0.6)
                                  : const Color(0xFFFFE0B2).withValues(alpha: 0.6),
                            'urgent' =>
                              dark
                                  ? const Color(0xFF4E0000).withValues(alpha: 0.6)
                                  : const Color(0xFFFFEBEE).withValues(alpha: 0.6),
                            _ =>
                              dark
                                  ? const Color(0xFF0A3A2A).withValues(alpha: 0.5)
                                  : const Color(0xFFE8F5E9).withValues(alpha: 0.5),
                          };
                          final statusLabel = switch (level) {
                            'caution' => 'guardian_status_caution'.tr,
                            'warning' => 'guardian_status_warning'.tr,
                            'urgent' => 'guardian_status_urgent'.tr,
                            _ => 'guardian_status_confirmed'.tr,
                          };

                          return Obx(() {
                            final isHighlighted =
                                controller.highlightedInviteCode.value == subject.inviteCode;
                            final steps = subject.weeklySteps;
                            return _SubjectCard(
                              key: ValueKey(subject.inviteCode),
                              inviteCode: subject.inviteCode,
                              name: subject.alias,
                              status: statusLabel,
                              statusColor: statusColor,
                              borderColor: statusColor,
                              backgroundColor: bgColor,
                              activityLabel: subject.activityLabelFor(steps),
                              lastCheck: subject.lastCheck,
                              showChart: isNormal,
                              showActionButtons: !isNormal,
                              isHighlighted: isHighlighted,
                              onCall: () => controller.onCallTapped(subject.inviteCode),
                              onConfirmSafety: () => controller.confirmSafety(subject.inviteCode, subject.alias),
                              batteryLevel: isNormal ? subject.batteryLevel : null,
                              steps: steps,
                              onOpenFullChart: () async {
                                final ok = await controller
                                    .loadMonthlyStepsIfNeeded(subject);
                                if (!ok) return;
                                if (!context.mounted) return;
                                // 차트가 작게 시작해 튀어나오는 느낌 — scale(0.7→1.0, easeOutBack) + fade
                                await showGeneralDialog<void>(
                                  context: context,
                                  barrierDismissible: true,
                                  barrierLabel: 'dismiss',
                                  barrierColor: Colors.black54,
                                  transitionDuration:
                                      const Duration(milliseconds: 300),
                                  pageBuilder: (_, _, _) =>
                                      _StepsChartDialog(subject: subject),
                                  transitionBuilder: (_, anim, _, child) {
                                    final scale = CurvedAnimation(
                                      parent: anim,
                                      curve: Curves.easeOutBack,
                                      reverseCurve: Curves.easeInBack,
                                    );
                                    return FadeTransition(
                                      opacity: anim,
                                      child: ScaleTransition(
                                        scale: Tween<double>(
                                                begin: 0.7, end: 1.0)
                                            .animate(scale),
                                        child: child,
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          });
                        },
                      ),
                    ),

                    // 페이지 인디케이터
                    if (items.length > 1) ...[
                      SizedBox(height: 10.h),
                      Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(items.length, (i) {
                            final isActive = controller.currentCardIndex.value == i;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: EdgeInsets.symmetric(horizontal: 3.w),
                              width: isActive ? 20.w : 6.w,
                              height: 6.w,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF4355B9)
                                    : const Color(0xFF4355B9).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ],
                );
              }),
              SizedBox(height: AppSpacing.sp6),

              // 다른 대상자 추가 버튼
              AddSubjectButton(onTap: controller.goToAddSubject),
              SizedBox(height: AppSpacing.sp6),

              const BannerAdWidget(),
              SizedBox(height: AppSpacing.sp6),
            ],
          ),
        ),
        bottomNavigationBar: const GuardianBottomNav(currentIndex: 0),
      ),
    );
  }
}

/// 대상자 상태 카드 — PNG _5 디자인 기준
/// 왼쪽 컬러 보더 + 이름/상태 뱃지 + 활동 차트 + 상태 메시지
class _SubjectCard extends StatefulWidget {
  final String name;
  final String status;
  final Color statusColor;
  final Color borderColor;
  final Color backgroundColor;
  final String? activityLabel;
  final String lastCheck;
  final bool showChart;
  final bool showActionButtons;
  final bool isHighlighted;
  final VoidCallback? onCall;
  final VoidCallback? onConfirmSafety;
  final int? batteryLevel;

  /// 차트에 표시할 걸음수 배열 (카드는 항상 7일). null=등록 전, 0=heartbeat 없음, >0=활동량.
  final List<int?> steps;
  /// 달력 아이콘 탭 → 30일 전체 차트 다이얼로그 오픈.
  final VoidCallback? onOpenFullChart;
  /// Hero 태그 구성용 (다이얼로그와 매칭).
  final String inviteCode;

  const _SubjectCard({
    super.key,
    required this.inviteCode,
    required this.name,
    required this.status,
    required this.statusColor,
    required this.borderColor,
    required this.backgroundColor,
    this.activityLabel,
    required this.lastCheck,
    this.showChart = false,
    this.showActionButtons = false,
    this.isHighlighted = false,
    this.onCall,
    this.onConfirmSafety,
    this.batteryLevel,
    this.steps = const [],
    this.onOpenFullChart,
  });

  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard> with TickerProviderStateMixin {
  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    if (widget.isHighlighted) _animCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_SubjectCard old) {
    super.didUpdateWidget(old);
    if (widget.isHighlighted && !old.isHighlighted) {
      _animCtrl.repeat(reverse: true);
    } else if (!widget.isHighlighted && old.isHighlighted) {
      _animCtrl.stop();
      _animCtrl.animateTo(0);
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  IconData _getBatteryIcon(int level) {
    if (level >= 90) return Icons.battery_full_rounded;
    if (level >= 70) return Icons.battery_6_bar_rounded;
    if (level >= 50) return Icons.battery_5_bar_rounded;
    if (level >= 30) return Icons.battery_3_bar_rounded;
    if (level >= 15) return Icons.battery_2_bar_rounded;
    return Icons.battery_alert_rounded;
  }

  Color _getBatteryColor(int level) {
    if (level <= 15) return const Color(0xFFD32F2F);
    if (level <= 30) return const Color(0xFFFF9800);
    return const Color(0xFF43A047);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
        width: double.infinity,
        margin: EdgeInsets.only(right: 8.w),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border(
            left: BorderSide(color: widget.borderColor, width: 4.w),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이름 + 상태 뱃지
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.name,
                          style: AppTextTheme.bodyLarge(fw: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.batteryLevel != null) ...[
                        SizedBox(width: 6.w),
                        Icon(
                          _getBatteryIcon(widget.batteryLevel!),
                          size: 18.w,
                          color: _getBatteryColor(widget.batteryLevel!),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '${widget.batteryLevel}%',
                          style: AppTextTheme.labelSmall(
                            color: _getBatteryColor(widget.batteryLevel!),
                            fw: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: widget.statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    widget.status,
                    style: AppTextTheme.labelSmall(color: widget.statusColor, fw: FontWeight.w600),
                  ),
                ),
              ],
            ),

            // 정상: 활동량 라벨 + 달력 토글 + 걸음수 막대 차트
            if (widget.showChart) ...[
              SizedBox(height: 0.h),
              Row(
                children: [
                  if (widget.activityLabel != null)
                    Expanded(
                      child: Text(
                        widget.activityLabel!,
                        style: AppTextTheme.bodySmall(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    const Spacer(),
                  if (widget.onOpenFullChart != null)
                    InkWell(
                      borderRadius: BorderRadius.circular(8.r),
                      onTap: widget.onOpenFullChart,
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          size: 18.w,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: _StepsBarChart(
                  steps: widget.steps,
                  isShowing30Days: false,
                ),
              ),
            ],

            // 경고: 활동 라벨 (왼쪽 정렬, 닉네임-버튼 수직 중앙)
            if (widget.showActionButtons && widget.activityLabel != null) ...[
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18.w, color: widget.statusColor),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      widget.activityLabel!,
                      style: AppTextTheme.bodyLarge(color: widget.statusColor, fw: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],

            // 정상: 마지막 확인 시간 (차트 아래)
            if (!widget.showActionButtons) ...[
              SizedBox(height: 0.h),
              Text(widget.lastCheck, style: AppTextTheme.bodySmall(color: AppColors.textTertiary)),
            ],

            // 주의 상태 — 액션 버튼
            if (widget.showActionButtons) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 전화 버튼
                  GestureDetector(
                    onTap: () {
                      widget.onCall?.call();
                      PhoneUtils.pickContactAndCall();
                    },
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: widget.statusColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_rounded, size: 15.w, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(
                            'guardian_call_now'.tr,
                            style: AppTextTheme.labelSmall(
                              color: Colors.white,
                              fw: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // 안전확인 완료 버튼
                  GestureDetector(
                    onTap: widget.onConfirmSafety,
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: widget.statusColor.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Text(
                          'guardian_confirm_safety'.tr,
                          style: AppTextTheme.labelSmall(
                            color: widget.statusColor,
                            fw: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(widget.lastCheck, style: AppTextTheme.bodySmall(color: AppColors.textTertiary)),
            ],
          ],
        ),
        ),
        ),
        if (widget.onOpenFullChart != null && !widget.showActionButtons)
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onOpenFullChart,
              behavior: HitTestBehavior.opaque,
            ),
          ),
      ],
    );
  }
}

/// 걸음수 막대 차트 — 3상태(null/0/>0) 구분 렌더링.
/// · null = 등록 전 날짜: 연회색 낮은 막대
/// · 0    = heartbeat 없음: 연회색 짧은 막대
/// · >0   = 실제 걸음수. 오늘 막대는 주황(`_todayColor`)으로 강조, 그 외는 파랑(`_chartColor` alpha 0.7)
class _StepsBarChart extends StatelessWidget {
  static const Color _todayColor = Color(0xFFFB8C00); // 오늘 강조 (Orange 600)

  final List<int?> steps;
  final bool isShowing30Days;

  const _StepsBarChart({required this.steps, required this.isShowing30Days});

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();

    // 다크모드에서는 진한 파랑이 잘 보이지 않으므로 Cyan으로 전환
    final chartColor = AppColors.isDark
        ? const Color(0xFF00BCD4) // Cyan 500
        : const Color(0xFF1A237E); // Indigo 900

    // null 제외 최댓값. 모두 null/0이면 1로 대체해 나눗셈 방지.
    final values = steps.whereType<int>().toList();
    final maxVal = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);
    final maxY = (maxVal <= 0 ? 1 : maxVal).toDouble();

    // 최댓값 인덱스 — 동률이면 가장 최근 날짜 우선
    int maxIdx = -1;
    if (maxVal > 0) {
      for (int i = 0; i < steps.length; i++) {
        if (steps[i] == maxVal) maxIdx = i;
      }
    }

    final emptyColor = AppColors.textTertiary.withValues(alpha: 0.25);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: 0,
        // 터치 시 해당 막대의 걸음수 툴팁 표시.
        // 배경은 투명(Colors.transparent) — 텍스트만 막대 위에 떠 있는 형태.
        // 최대값 막대는 상단 상시 라벨과 중복이라 제외, null/0 막대는 표시할 값이 없어 제외.
        barTouchData: BarTouchData(
          enabled: true,
          // 30일 보기에서 막대 폭이 8px로 좁기 때문에 감지 반경을 여유 있게 확장.
          touchExtraThreshold: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 4,
            getTooltipColor: (_) => Colors.transparent,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex == maxIdx) return null;
              final v = steps[groupIndex];
              if (v == null || v == 0) return null;
              return BarTooltipItem(
                _formatSteps(v),
                AppTextTheme.labelSmall(color: chartColor, fw: FontWeight.w700),
              );
            },
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: AppColors.textTertiary.withValues(alpha: 0.4), width: 1),
            bottom: BorderSide(color: AppColors.textTertiary.withValues(alpha: 0.4), width: 1),
            top: BorderSide.none,
            right: BorderSide.none,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(
            axisNameSize: 16,
            axisNameWidget: Text(
              'guardian_chart_y_axis_steps'.tr,
              style: AppTextTheme.labelSmall(color: AppColors.textTertiary),
            ),
            sideTitles: const SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            axisNameSize: 16,
            axisNameWidget: Text(
              isShowing30Days
                  ? 'guardian_chart_x_axis_last_30_days'.tr
                  : 'guardian_chart_x_axis_last_7_days'.tr,
              style: AppTextTheme.labelSmall(color: AppColors.textTertiary),
            ),
            sideTitles: const SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          // 최댓값 막대 위에만 걸음수 표시 (쉼표 포함). fitInside로 차트
          // 좌우 끝 막대라도 라벨이 잘리지 않고 안쪽으로 정렬됨.
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: maxIdx >= 0,
              reservedSize: 16,
              getTitlesWidget: (value, meta) {
                if (value.toInt() != maxIdx) return const SizedBox.shrink();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                  child: Text(
                    _formatSteps(maxVal),
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: AppTextTheme.labelSmall(color: chartColor, fw: FontWeight.w700),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (int i = 0; i < steps.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: _rodHeight(steps[i], maxY),
                  width: _rodWidth(steps.length),
                  color: _rodColor(
                    steps[i],
                    chartColor,
                    emptyColor,
                    isToday: i == steps.length - 1,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// null / 0 은 시각적으로 작은 높이(5%)로 표시하되, maxY 대비 균일하게.
  double _rodHeight(int? value, double maxY) {
    if (value == null || value == 0) return maxY * 0.06;
    return value.toDouble();
  }

  /// null = 등록 전 → 더 연한 색. 0 = 빈 heartbeat → 연회색.
  /// >0 + isToday → 주황(_todayColor)으로 "오늘" 강조. 그 외 >0 → 파랑 반투명.
  Color _rodColor(int? value, Color active, Color empty, {bool isToday = false}) {
    if (value == null) return empty.withValues(alpha: 0.15);
    if (value == 0) return empty;
    return isToday ? _todayColor : active.withValues(alpha: 0.7);
  }

  double _rodWidth(int n) {
    if (n <= 7) return 24;
    if (n <= 14) return 14;
    return 8;
  }

  /// 1234567 → "1,234,567" (천단위 쉼표, 로케일 의존성 없이 구현)
  String _formatSteps(int value) {
    return value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}

/// 달력 아이콘 탭 시 뜨는 확대 차트 다이얼로그 (30일 고정).
/// · scale + fade transition으로 "튀어나오는" 느낌 (showGeneralDialog 경로에서 적용)
/// · 닉네임 Row 오른쪽 X 아이콘 탭 또는 barrier 탭으로 닫힘
class _StepsChartDialog extends StatelessWidget {
  final SubjectStatus subject;

  const _StepsChartDialog({required this.subject});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuardianDashboardController>();
    final steps =
        controller.monthlyStepsCache[subject.inviteCode] ?? const <int?>[];

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    subject.alias,
                    style: AppTextTheme.bodyLarge(fw: FontWeight.w700),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Get.back<void>(),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.close_rounded,
                      size: 22.w,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              subject.activityLabelFor(steps),
              style: AppTextTheme.bodySmall(color: AppColors.textSecondary),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 280.h,
              child: _StepsBarChart(
                steps: steps,
                isShowing30Days: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 3.w),
        Flexible(
          child: Text(
            label,
            style: AppTextTheme.labelSmall(color: AppColors.textTertiary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
