import 'package:flutter/material.dart';
import 'package:anbucheck/app/core/utils/back_press_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/modules/guardian_dashboard/controllers/guardian_dashboard_controller.dart';
import 'package:anbucheck/app/routes/app_pages.dart';
import 'package:anbucheck/app/core/utils/phone_utils.dart';
import 'package:anbucheck/app/core/widgets/add_subject_button.dart';

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
        title: Obx(() => Text(
              'Anbu Guardian (${controller.subjects.length})',
              style: AppTextTheme.headlineSmall(),
            )),
        actions: [
          Obx(() {
            if (controller.subjects.isEmpty) return const SizedBox.shrink();
            final level = controller.highestAlertLevel;
            final color = switch (level) {
              'caution' => const Color(0xFFF59E0B),
              'warning' => const Color(0xFFE65100),
              'urgent'  => const Color(0xFFE53935),
              _         => const Color(0xFF00685E),
            };
            final bgColor = switch (level) {
              'caution' => const Color(0xFFFFFDE7),
              'warning' => const Color(0xFFFFF3E0),
              'urgent'  => const Color(0xFFFFEBEE),
              _         => const Color(0xFFE8F5E9),
            };
            final label = switch (level) {
              'caution' => '주의',
              'warning' => '경고',
              'urgent'  => '긴급',
              _         => '정상',
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
                    Text(label,
                        style: AppTextTheme.labelSmall(
                            color: color, fw: FontWeight.w600)),
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

            // 상단 레이블
            Text(
              '오늘의 안부 요약',
              style: AppTextTheme.labelMedium(
                color: AppColors.textTertiary,
                fw: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6.h),

            // 요약 텍스트
            Obx(() {
              final count = controller.subjects.length;
              final text = count == 0
                  ? '연결된 보호 대상자가 없습니다.'
                  : '현재 $count명의 안부를\n확인 중입니다.';
              return Text(
                text,
                style: AppTextTheme.headlineMedium(fw: FontWeight.w700),
              );
            }),
            SizedBox(height: AppSpacing.sp6),

            // 대상자 리스트 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('보호 대상자 리스트',
                    style: AppTextTheme.bodyLarge(fw: FontWeight.w600)),
                Obx(() {
                  final subjects = controller.subjects;
                  final counts = {
                    'normal': subjects.where((s) => s.alertLevel == 'normal' || s.alertLevel == 'info').length,
                    'caution': subjects.where((s) => s.alertLevel == 'caution').length,
                    'warning': subjects.where((s) => s.alertLevel == 'warning').length,
                    'urgent': subjects.where((s) => s.alertLevel == 'urgent').length,
                  };
                  const colors = {
                    'normal':  Color(0xFF00685E),
                    'caution': Color(0xFFF59E0B),
                    'warning': Color(0xFFE65100),
                    'urgent':  Color(0xFFE53935),
                  };
                  const labels = {
                    'normal':  '정상',
                    'caution': '주의',
                    'warning': '경고',
                    'urgent':  '긴급',
                  };
                  final items = counts.entries
                      .where((e) => e.value > 0)
                      .toList();
                  if (items.isEmpty) return const SizedBox.shrink();
                  return Row(
                    children: items.expand((e) => [
                      _LegendDot(
                        color: colors[e.key]!,
                        label: '${labels[e.key]}: ${e.value}',
                      ),
                      SizedBox(width: 8.w),
                    ]).toList()..removeLast(),
                  );
                }),
              ],
            ),
            SizedBox(height: AppSpacing.md),

            // 대상자 카드 리스트 (동적)
            Obx(() => Column(
              children: controller.subjects.map((subject) {
                // 정보(info)는 normal과 동일하게 표시
                final level = subject.alertLevel == 'info'
                    ? 'normal'
                    : subject.alertLevel;
                final isNormal = level == 'normal';

                final statusColor = switch (level) {
                  'caution' => const Color(0xFFF59E0B),
                  'warning' => const Color(0xFFE65100),
                  'urgent'  => const Color(0xFFE53935),
                  _         => const Color(0xFF00685E),
                };
                final bgColor = switch (level) {
                  'caution' => const Color(0xFFFFFDE7).withValues(alpha: 0.6),
                  'warning' => const Color(0xFFFFF3E0).withValues(alpha: 0.6),
                  'urgent'  => const Color(0xFFFFEBEE).withValues(alpha: 0.6),
                  _         => const Color(0xFFE8F5E9).withValues(alpha: 0.5),
                };
                final statusLabel = switch (level) {
                  'caution' => '주의',
                  'warning' => '경고',
                  'urgent'  => '긴급',
                  _         => '안전확인',
                };

                return Obx(() {
                  final isHighlighted =
                      controller.highlightedInviteCode.value ==
                          subject.inviteCode;
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: _SubjectCard(
                      key: ValueKey(subject.inviteCode),
                      name: subject.alias,
                      status: statusLabel,
                      statusColor: statusColor,
                      borderColor: statusColor,
                      backgroundColor: bgColor,
                      activityLabel: subject.activityLabel,
                      lastCheck: subject.lastCheck,
                      showChart: isNormal,
                      showActionButtons: !isNormal,
                      isHighlighted: isHighlighted,
                      onCall: () => controller.onCallTapped(subject.inviteCode),
                      onConfirmSafety: () =>
                          controller.confirmSafety(subject.inviteCode),
                    ),
                  );
                });
              }).toList(),
            )),
            SizedBox(height: AppSpacing.sp6),

            // 다른 대상자 추가 버튼
            AddSubjectButton(onTap: controller.goToAddSubject),
            SizedBox(height: AppSpacing.sp6),

            // 프리미엄 배너
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PREMIUM SERVICE',
                          style: AppTextTheme.labelSmall(
                            color: AppColors.textTertiary,
                            fw: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '실버 케어 전문가와\n실시간 상담하세요',
                          style: AppTextTheme.bodyMedium(fw: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.headset_mic_rounded,
                        size: 24.w, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.sp6),
          ],
        ),
      ),
      // 하단 네비게이션
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surfaceContainerLowest,
        selectedItemColor: const Color(0xFF4355B9),
        unselectedItemColor: AppColors.onSurfaceVariant,
        elevation: 0,
        selectedFontSize: 12.sp,
        unselectedFontSize: 12.sp,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '홈'),
          BottomNavigationBarItem(
              icon: Icon(Icons.link_rounded), label: '연결'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_rounded), label: '알림'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded), label: '설정'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Get.offNamed(AppRoutes.guardianConnectionManagement);
              break;
            case 2:
              Get.offNamed(AppRoutes.guardianNotifications);
              break;
            case 3:
              Get.offNamed(AppRoutes.guardianSettings);
              break;
          }
        },
      ),
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

  const _SubjectCard({
    super.key,
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
  });

  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border(
          left: BorderSide(color: widget.borderColor, width: 4.w),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이름 + 상태 뱃지
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.name,
                    style: AppTextTheme.bodyLarge(fw: FontWeight.w700)),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: widget.statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    widget.status,
                    style: AppTextTheme.labelSmall(
                      color: widget.statusColor,
                      fw: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // 활동량 라벨
            if (widget.activityLabel != null) ...[
              SizedBox(height: 6.h),
              Text(widget.activityLabel!,
                  style:
                      AppTextTheme.bodySmall(color: AppColors.textSecondary)),
            ],

            // 활동 차트
            if (widget.showChart) ...[
              SizedBox(height: 8.h),
              SizedBox(
                height: 28.h,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(14, (i) {
                    final heights = [
                      0.4, 0.6, 0.5, 0.8, 0.55, 0.9, 0.7,
                      0.85, 0.5, 0.75, 0.65, 0.95, 0.8, 1.0
                    ];
                    final h = heights[i] * 28.h;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                        height: h,
                        decoration: BoxDecoration(
                          color: widget.statusColor
                              .withValues(alpha: 0.25 + heights[i] * 0.4),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],

            SizedBox(height: 6.h),

            // 마지막 확인 시간
            Text(widget.lastCheck,
                style: AppTextTheme.bodySmall(color: AppColors.textTertiary)),

            // 주의 상태 — 액션 버튼
            if (widget.showActionButtons) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  // 전화 버튼
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        widget.onCall?.call();
                        PhoneUtils.pickContactAndCall();
                      },
                      child: Container(
                        height: 40.h,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: widget.statusColor.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone_rounded,
                                size: 15.w, color: widget.statusColor),
                            SizedBox(width: 4.w),
                            Text(
                              '지금 바로 전화',
                              style: AppTextTheme.labelSmall(
                                color: widget.statusColor,
                                fw: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // 안전확인 완료 버튼 — 강조 애니메이션
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _animCtrl,
                      builder: (_, child) => Transform.scale(
                        scale: _scale.value,
                        child: Container(
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: widget.statusColor,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color: widget.statusColor
                                    .withValues(alpha: _glow.value),
                                blurRadius: 12.r,
                                spreadRadius: 2.r,
                              ),
                            ],
                          ),
                          child: child,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: widget.onConfirmSafety,
                        child: Center(
                          child: Text(
                            '안전확인 완료',
                            style: AppTextTheme.labelSmall(
                              color: Colors.white,
                              fw: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4.w),
        Text(label, style: AppTextTheme.bodySmall(color: AppColors.textTertiary)),
      ],
    );
  }
}
