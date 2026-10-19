import 'package:anbucheck/app/core/widgets/split_shell.dart';
import 'package:anbucheck/app/core/utils/app_nav.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:anbucheck/app/core/widgets/resume_replay_mixin.dart';
import 'package:anbucheck/app/core/utils/back_press_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/modules/guardian_dashboard/controllers/guardian_dashboard_controller.dart';
import 'package:anbucheck/app/core/utils/phone_utils.dart';
import 'package:anbucheck/app/core/widgets/add_subject_button.dart';
import 'package:anbucheck/app/core/widgets/banner_ad_widget.dart';
import 'package:anbucheck/app/core/widgets/guardian_bottom_nav.dart';
import 'package:anbucheck/app/routes/app_pages.dart';
import 'package:anbucheck/app/core/utils/number_text.dart';
import 'package:anbucheck/app/core/utils/label_separator.dart';
import 'package:anbucheck/app/core/utils/layout_breakpoints.dart';
import 'package:anbucheck/app/core/services/fold_state_service.dart';

/// 보호자 대시보드 — 시안 _5 기준
/// 폴더블을 접은 상태인가. 서비스가 없거나(테스트 등) 폰이면 false.
/// 넓은 화면이거나 폴더블 접힘이면 컴팩트 배치.
/// ⚠️ `wide || _isFolded(context)`로 쓰면 wide=true에서 단락 평가로 Rx를 읽지 않아 Obx가
/// "improper use of a GetX" 예외를 던진다 — 항상 접힘 상태를 먼저 읽는다.
bool _compact(BuildContext context, bool wide) {
  final folded = _isFolded(context);
  return wide || folded;
}

bool _isFolded(BuildContext context) {
  // 분할 화면의 왼쪽 pane도 접힘과 같은 컴팩트 배치(폭 절반 · 높이 그대로).
  final inSplit = SplitLeftScope.of(context);
  final folded = Get.isRegistered<FoldStateService>() &&
      Get.find<FoldStateService>().posture.value == FoldPosture.folded;
  return inSplit || folded;
}

/// 대상자 카드 한 칸(카드 + 오른쪽 여백) 고정 폭 — 폭 ≥ 600dp에서 한 줄 표시 판단용(논리 px, `.w` 아님:
/// 큰 화면에서 designSize 확대로 `.w`가 늘어나도 카드는 폰 카드와 같은 크기를 유지해야 한다).
const double _kFixedCardSlotWidth = 348;

class GuardianDashboardPage extends GetView<GuardianDashboardController> {
  const GuardianDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 분할 화면 셸 — 펼친 폴더블에서 오른쪽 pane을 붙인다. 폰·접힘은 child 그대로.
    // Builder: 셸이 덮어쓴 MediaQuery(pane 폭)를 아래 `wide` 판정이 읽도록 새 context로 한 번 더 빌드.
    return SplitShell(child: Builder(builder: (context) {
    // 넓은 화면(폴더블 펼침·태블릿): 추가 박스를 제목 줄의 작은 버튼으로 줄여 세로 공간 확보(광고 노출).
    final wide = MediaQuery.sizeOf(context).width >= kLargeScreenBreakpoint;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) BackPressHandler.onBackPressed();
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        // Obx는 PreferredSizeWidget이 아니라 appBar에 직접 넣을 수 없어 PreferredSize로 감싼다.
        // [내 걸음수] 버튼 노출 여부에 따라 제목 정렬이 바뀌어야 하므로 AppBar 전체가 반응형이다.
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Obx(() {
            // 버튼 노출 조건 3가지 — 안전 코드가 있어야(G+S) 자기 걸음수가 존재하고,
            // 구독이 만료되면 대시보드 시각화 전체가 마스킹되므로(PRD §9.8) 함께 숨긴다.
            // ⚠️ 이 게이팅은 "보호자 대시보드의 시각화"에 대한 것이지 heartbeat 경로가
            // 아니다 — 대상자 본인의 안부 전송은 구독과 무관하게 계속 동작한다.
            final showMySteps = controller.isAlsoSubject.value &&
                controller.inviteCode.value.isNotEmpty &&
                controller.isSubscriptionActive.value;
            return AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              // centerTitle 기본값은 플랫폼마다 다르다(iOS 중앙 / Android 좌측). 이 화면의
              // title은 아이콘 없는 순수 Text라 그 차이가 그대로 드러나므로 명시적으로 고정한다.
              // 버튼이 뜨면 좌측 정렬로 바꿔 우측에 버튼 자리를 온전히 내준다.
              centerTitle: !showMySteps,
              // 우측 최악등급 배지는 제거됨 — 본문 "오늘의 안부 요약" 아래 등급별 카운터가
              // 최악 등급을 포함한 전체 분포를 더 정확히 알려주므로 중복이었다.
              // ⚠️ 하드코딩 금지 — 과거 'Anbu Guardian' 리터럴이라 20개 언어 전부에서
              // 영어가 그대로 노출됐다(번역 키는 있는데 아무도 쓰지 않는 상태였다).
              //
              // ellipsis: 제목은 브랜드 장식이고 버튼은 기능이라, 폭이 모자라면 제목이
              // 잘려야 한다(베트남어 "Người bảo vệ Anbu" 등 긴 로케일 대비).
              title: Text(
                'app_guardian_title'.tr,
                style: AppTextTheme.headlineSmall(),
                overflow: TextOverflow.ellipsis,
              ),
              actions: showMySteps
                  ? [
                      Padding(
                        padding: EdgeInsets.only(right: 4.w),
                        child: TextButton.icon(
                          onPressed: () => _openMyStepsChart(context, controller),
                          icon: Icon(Icons.directions_walk_rounded, size: 18.w),
                          label: Text(
                            'guardian_my_steps'.tr,
                            style: AppTextTheme.labelMedium(
                                color: AppColors.textPrimary, fw: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          // 색은 제목과 같은 테마 인지 색(AppBar action 관례). 고정
                          // guardianPrimary(#4355B9)를 쓰면 다크 배경(#121212)에서
                          // 대비가 떨어진다.
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            minimumSize: Size(0, 48.h),
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ]
                  : null,
            );
          }),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),

              // 구독 만료 안내 카드 — 만료 시 대상자 카드는 보이되 '정상+걸음수 0'으로
              // 마스킹(_mapSubjects)되며, 이 카드가 만료 안내 + 구독 동선을 제공한다.
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
                          Expanded(
                            child: Text(
                              'guardian_subscription_expired'.tr,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextTheme.bodyMedium(
                                color: const Color(0xFFE65100),
                                fw: FontWeight.w700,
                              ),
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
                          // IAP 결제 + [구독 복원] 흐름은 Settings 페이지가 단독
                          // 책임 (IapService 직접 호출, purchaseStream 구독 등).
                          // Dashboard에서 결제를 직접 호출하면:
                          //  1) IAP 로직 중복 — 두 곳 유지 부담
                          //  2) [구독 복원] 접근성 누락 → Apple Review 3.1.1 위배 가능
                          //  3) 사용자 정보(days, plan 등) 풍부히 못 보여줌
                          // → Settings 탭으로 이동 후 거기서 [구독하기]/[구독 복원]
                          //   선택하도록 가이드.
                          onPressed: () => AppNav.offNamed(AppRoutes.guardianSettings),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE65100),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            'guardian_go_to_settings'.tr,
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

              // 요약 텍스트
              Obx(() {
                final count = controller.subjects.length;
                final text = count == 0
                    ? 'guardian_no_subjects'.tr
                    : NumberText.tr('guardian_checking_subjects', 'count', count);
                // 넓은 화면은 가로 여유가 있어 두 줄(\n) 제목을 한 줄로 합쳐 세로 공간을 아낀다.
                // 일본어·중국어·태국어는 단어 사이 공백이 없으므로 공백 없이 잇는다.
                final lang = Get.locale?.languageCode;
                final joiner = (lang == 'ja' || lang == 'zh' || lang == 'th') ? '' : ' ';
                return Text(
                  wide ? text.replaceAll('\n', joiner) : text,
                  style: AppTextTheme.headlineMedium(fw: FontWeight.w700),
                );
              }),

              // "오늘의 안부 요약" 라벨 + 등급별 인원 카운터
              //
              // 라벨을 헤드라인 위 eyebrow로 두지 않고 **카운터 바로 위**에 붙인다 —
              // 헤드라인("현재 N명의 안부를 확인 중입니다")은 연결된 대상자 수라 오늘과
              // 무관해서 "오늘의 요약"이라는 라벨과 맞지 않았다. 등급 분포 위에 놓이면
              // 라벨이 실제 내용과 일치한다.
              //
              // 카운터는 전체 폭을 쓰는 독립 행이다. 등급 개수(1~4) × 언어 조합으로 폭이
              // 크게 변해(러시아어 4등급이면 가용 폭의 약 2배) 어떤 행에 얹어도 한 줄
              // 보장이 불가능하므로, Wrap으로 두 줄까지 자연스럽게 접히게 둔다.
              // (FittedBox 축소는 쓰지 않는다 — 장식인 라벨을 지키려고 정보인 카운터를
              //  같이 줄이게 되고, OS 글자 크기 설정도 무력화한다.)
              //
              // 표시할 등급이 없으면(대상자 0명) 라벨까지 함께 숨긴다 — 라벨만 덩그러니
              // 남으면 아래에 아무것도 없는 빈 제목이 된다.
              //
              // 넓은 화면(폴더블 펼침 등)은 세로 공간이 부족해(가로로 넓어 창 높이가 낮음)
              // 하단 광고 배너가 스크롤 밖으로 밀리므로 이 요약 블록을 숨긴다.
              if (!wide)
              Obx(() {
                // 폴더블을 접은 상태(외부 화면)도 세로 공간이 부족해 숨긴다. 폰·비폴더블은
                // posture가 항상 unknown이라 영향 없음.
                if (_isFolded(context)) return const SizedBox.shrink();
                final subjects = controller.subjects;
                // 표시 순서: 긴급 → 경고 → 주의 → 안전 (대상자 리스트 정렬과 동일)
                final counts = {
                  'urgent': subjects.where((s) => s.alertLevel == 'urgent').length,
                  'warning': subjects.where((s) => s.alertLevel == 'warning').length,
                  'caution': subjects.where((s) => s.alertLevel == 'caution').length,
                  'normal': subjects
                      .where((s) => s.alertLevel == 'normal' || s.alertLevel == 'info')
                      .length,
                };
                final colors = {
                  // 다크 모드에서는 어두운 배경에 묻히지 않도록 안전(초록) 점을 밝게
                  'normal': AppColors.isDark ? const Color(0xFF2DD4BF) : const Color(0xFF00685E),
                  'caution': const Color(0xFFF59E0B),
                  'warning': const Color(0xFFE65100),
                  'urgent': const Color(0xFFE53935),
                };
                final labels = {
                  'normal': 'guardian_status_normal'.tr,
                  'caution': 'guardian_status_caution'.tr,
                  'warning': 'guardian_status_warning'.tr,
                  'urgent': 'guardian_status_urgent'.tr,
                };
                final items = counts.entries.where((e) => e.value > 0).toList();
                if (items.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(top: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'guardian_today_summary'.tr,
                        style: AppTextTheme.labelMedium(
                          color: AppColors.textTertiary,
                          fw: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 4.h,
                        children: items
                            .map(
                              (e) => _LegendDot(
                                color: colors[e.key]!,
                                label: '${labels[e.key]}${labelSeparator()}${e.value}',
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                );
              }),
              Obx(() => SizedBox(
                    height: _compact(context, wide) ? AppSpacing.lg : AppSpacing.sp6,
                  )),

              // 대상자 리스트 헤더 — 우측에 있던 등급별 카운터는 위 "오늘의 안부 요약"
              // 블록으로 옮겼다. 헤더와 한 줄을 공유하던 탓에 등급이 3종 이상 섞이면
              // Wrap이 두 줄로 늘어 헤더 높이가 흔들렸기 때문이다.
              // 세로 공간이 부족한 화면(폭 ≥600dp이거나 폴더블을 접은 상태)에서는 추가 박스를
              // 제목 줄의 작은 버튼으로 줄인다. 접힘 상태는 변할 수 있어 Obx로 감싼다.
              Obx(() {
                final compact = _compact(context, wide);
                if (!compact) {
                  return Text(
                    'guardian_subject_list'.tr,
                    style: AppTextTheme.bodyLarge(fw: FontWeight.w600),
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        'guardian_subject_list'.tr,
                        style: AppTextTheme.bodyLarge(fw: FontWeight.w600),
                      ),
                    ),
                    // 새 번역 키 없이 기존 'add_subject_button'(새로운 보호 대상자 추가)을 재사용.
                    // 광고 자리에 추가 박스가 보이는 동안은 중복이라 숨긴다.
                    Obx(
                      () => controller.adFallbackShown.value
                          ? const SizedBox.shrink()
                          : TextButton.icon(
                              onPressed: controller.goToAddSubject,
                              // 기본 좌우 패딩(12) 중 오른쪽만 제거 — 버튼 글자가 화면 여백선(오른쪽 끝)에 맞도록
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.only(left: 12),
                              ),
                              icon: const Icon(Icons.add_rounded, size: 20),
                              label: Text(
                                'add_subject_button'.tr,
                                style: AppTextTheme.bodyMedium(fw: FontWeight.w600),
                              ),
                            ),
                    ),
                  ],
                );
              }),
              SizedBox(height: AppSpacing.md),

              // 대상자 카드 — 좁은 화면(폰)은 슬라이드, 넓은 화면(폴더블 펼침 등)에서
              // 고정 크기 카드가 한 줄에 모두 들어가면 한 줄 표시, 넘치면 슬라이드로 폴백.
              Obx(() {
                final items = controller.subjects;
                if (items.isEmpty) return const SizedBox.shrink();

                // 카드 하나를 만든다. [forceActive]는 한 줄 표시(슬라이드가 없어 "현재 카드"
                // 개념이 없을 때)에서 모든 카드의 차트 진입 애니메이션을 켜기 위한 것.
                Widget buildCard(int i, {bool forceActive = false}) {
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
                  final isActiveCard =
                      forceActive || controller.currentCardIndex.value == i;
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
                    isActive: isActiveCard,
                    phone: subject.phone,
                    onCall: () => controller.onCallTapped(subject.inviteCode),
                    onConfirmSafety: () =>
                        controller.confirmSafety(subject.inviteCode, subject.alias),
                    batteryLevel: isNormal ? subject.batteryLevel : null,
                    steps: steps,
                    onOpenFullChart: () async {
                      // 중복 오픈 방지 — 로드 대기 중/다이얼로그 열린 동안 재탭 무시.
                      // 데이터 로드가 느릴 때 두 번 탭하면 다이얼로그가 2개 뜨던 문제 차단.
                      if (controller.isChartDialogBusy) return;
                      controller.isChartDialogBusy = true;
                      try {
                        final ok = await controller.loadMonthlyStepsIfNeeded(subject);
                        if (!ok) return;
                        if (!context.mounted) return;
                        // 차트가 작게 시작해 튀어나오는 느낌 — scale(0.7→1.0, easeOutBack) + fade
                        final monthly = controller
                                .monthlyStepsCache[subject.inviteCode] ??
                            const <int?>[];
                        await _showStepsChartDialog(
                          context,
                          title: subject.alias,
                          subtitle: subject.activityLabelFor(monthly),
                          steps: monthly,
                        );
                      } finally {
                        controller.isChartDialogBusy = false;
                      }
                    },
                  );
                });
                }

                // Obx 안(추적 범위)에서 읽어야 접힘 상태 변화에 다시 그려진다 — LayoutBuilder 콜백은
                // Obx 추적 밖이라 거기서 읽으면 갱신되지 않을 수 있다.
                final folded = _isFolded(context);

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // 분기는 창 폭(MediaQuery)으로 — 폰(<600dp)은 기존 슬라이드 그대로.
                    final wide = MediaQuery.sizeOf(context).width >= kLargeScreenBreakpoint;
                    final needed = items.length * _kFixedCardSlotWidth;
                    // 카드 높이: 폰은 기존 200.h. 넓은 화면은 designSize 확대로 `.w`가 ≥1.0이고
                    // `.h`/`.sp`는 창 높이에 따라 <1.0이 될 수 있어(가로로 넓은 Duo 펼침에서
                    // 높이 비 0.82) 200.h로는 내용(.w 크기 아이콘·버튼 포함)이 넘쳤다
                    // (BOTTOM OVERFLOWED BY 15 PIXELS). 최소 1.0배 이상을 보장한다.
                    //
                    // 폴더블을 접은 외부 화면(폭 <600dp)도 같다 — 설계 비율(375×812)보다 가로로
                    // 넓고 낮아 `.w` 크기 요소가 `.h` 예산을 넘는다(BOTTOM OVERFLOWED BY 13 PIXELS).
                    // 접힘 상태일 때만 보정하므로 일반 폰은 그대로다.
                    final double cardHeight = (wide || folded)
                        ? 200.0 * math.max(ScreenUtil().scaleHeight, 1.0)
                        : 200.h;
                    if (wide && needed <= constraints.maxWidth) {
                      return SizedBox(
                        height: cardHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < items.length; i++)
                              SizedBox(
                                width: _kFixedCardSlotWidth,
                                child: buildCard(i, forceActive: true),
                              ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        SizedBox(
                          height: cardHeight,
                          child: PageView.builder(
                            clipBehavior: Clip.none,
                            padEnds: false,
                            itemCount: items.length,
                            // 넓은 화면은 카드 폭을 고정(한 칸 = _kFixedCardSlotWidth)하고 옆 카드가 이어서 보이는
                            // 스트립으로 — viewportFraction을 칸 폭/가용 폭으로 둔다. 폰은 기존 0.92.
                            controller: PageController(
                              viewportFraction: wide
                                  ? (_kFixedCardSlotWidth / constraints.maxWidth).clamp(0.1, 1.0)
                                  : (items.length > 1 ? 0.92 : 1.0),
                            ),
                            onPageChanged: (i) => controller.currentCardIndex.value = i,
                            // 넓은 화면은 여러 장이 동시에 보이므로 모두 활성(차트 진입 애니메이션)
                            itemBuilder: (_, i) => buildCard(i, forceActive: wide),
                          ),
                        ),

                        // 페이지 인디케이터 — 넓은 화면은 카드와의 간격을 넓힌다(20 논리 px)
                        if (items.length > 1) ...[
                          SizedBox(height: wide ? 20 : 10.h),
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
                  },
                );
              }),
              // 카드와 광고 사이 — 넓은 화면도 원래 간격(sp6)을 유지(광고가 카드에 붙어 보이지 않게)
              SizedBox(height: AppSpacing.sp6),

              // 다른 대상자 추가 버튼 — 넓은 화면은 제목 줄의 작은 버튼으로 대체
              Obx(
                () => _compact(context, wide)
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          AddSubjectButton(onTap: controller.goToAddSubject),
                          SizedBox(height: AppSpacing.sp6),
                        ],
                      ),
              ),

              Obx(
                () => BannerAdWidget(
                  // 세로 공간이 부족한 화면(넓은 화면·폴더블 접힘)에서만: 광고가 없으면
                  // (프리미엄·권한/동의 거부·로드 실패) 같은 자리에 기존 디자인의 추가 박스(컴팩트)를
                  // 보인다. 폰은 fallback 없음 → 기존 동작.
                  fallback: _compact(context, wide)
                      ? AddSubjectButton(onTap: controller.goToAddSubject, compact: true)
                      : null,
                  onFallbackChanged: (shown) => controller.adFallbackShown.value = shown,
                ),
              ),
              SizedBox(height: AppSpacing.sp6),
            ],
          ),
        ),
        bottomNavigationBar: const GuardianBottomNav(currentIndex: 0),
      ),
    );
    }));
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

  /// PageView에서 현재 보이는 카드인지 — 차트 막대 애니메이션 재생 트리거.
  final bool isActive;
  final VoidCallback? onCall;
  final VoidCallback? onConfirmSafety;
  final int? batteryLevel;

  /// 보호자가 대상자 추가 시 직접 입력한 연락처 (선택). 없으면 전화 버튼 탭 시
  /// 시스템 연락처 선택 화면으로 폴백.
  final String? phone;

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
    this.isActive = true,
    this.onCall,
    this.onConfirmSafety,
    this.batteryLevel,
    this.phone,
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

  /// 배터리 아이콘 색 — 다크 모드에서는 어두운 배경에서도 눈에 띄도록
  /// 정상(>30%)은 형광 초록, 부족(≤30%)은 밝은 주황, 매우 부족(≤15%)은 밝은 빨강.
  Color _getBatteryIconColor(int level) {
    if (!AppColors.isDark) return _getBatteryColor(level);
    if (level <= 15) return const Color(0xFFFF4D4D);
    if (level <= 30) return const Color(0xFFFFA726);
    return const Color(0xFF39FF14);
  }

  Color _getBatteryColor(int level) {
    if (level <= 15) return const Color(0xFFD32F2F);
    if (level <= 30) return const Color(0xFFFF9800);
    return const Color(0xFF43A047);
  }

  /// 30일 전체 차트 다이얼로그를 여는 달력 아이콘 버튼. 정상/경고 카드 공통 사용.
  /// 주의/경고/긴급 카드의 강조색. 다크 모드에서는 어두운 카드 배경에 묻히지 않도록
  /// 등급색을 한 단계 밝은 같은 계열로 올린다(라이트 모드는 등급색 그대로).
  Color get _emphasisColor {
    if (!AppColors.isDark) return widget.statusColor;
    if (widget.statusColor == const Color(0xFFF59E0B)) return const Color(0xFFFFD54F);
    if (widget.statusColor == const Color(0xFFE65100)) return const Color(0xFFFF9E40);
    if (widget.statusColor == const Color(0xFFE53935)) return const Color(0xFFFF7B72);
    return widget.statusColor;
  }

  /// "마지막 확인: 값"의 값 색 — 정상·주의·경고·긴급 카드 공통.
  Color get _lastCheckValueColor =>
      Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF8B4513);

  Widget _buildFullChartButton() {
    if (widget.onOpenFullChart == null) return const SizedBox.shrink();
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: widget.onOpenFullChart,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: SizedBox(
          width: 22.w,
          height: 22.w,
          // 달력 모양: 상단 색 띠(월 표시줄) + 링 2개 + 흰 본문에 날짜 숫자
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 3.w),
                // 테두리: 라이트=회색 계열, 다크=해당 카드 등급색
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.isDark ? _emphasisColor : const Color(0xFF9E9E9E),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(height: 7.w, color: const Color(0xFF4355B9)),
                    Expanded(
                      child: Center(
                        child: Text(
                          '30',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1C1C),
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              for (final dx in [-7.0, 7.0])
                Positioned(
                  top: 0,
                  left: 11.w + dx.w * 0.7 - 1.w,
                  child: Container(
                    width: 2.w,
                    height: 5.w,
                    color: const Color(0xFF2E3A8C),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                          color: _getBatteryIconColor(widget.batteryLevel!),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '${widget.batteryLevel}%',
                          style: AppTextTheme.labelSmall(
                            color: AppColors.isDark
                                ? Colors.white
                                : _getBatteryColor(widget.batteryLevel!),
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
                    style: AppTextTheme.labelSmall(
                      // 다크 모드의 '안전'(정상) 뱃지만 흰색 — 어두운 초록이 배경에 묻힌다
                      color: AppColors.isDark && !widget.showActionButtons
                          ? Colors.white
                          : widget.statusColor,
                      fw: FontWeight.w600,
                    ),
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
                      child: _LabelValueText(
                        text: widget.activityLabel!,
                        labelColor: AppColors.textSecondary,
                        valueColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : null,
                      ),
                    )
                  else
                    const Spacer(),
                  _buildFullChartButton(),
                ],
              ),
              Expanded(
                child: _StepsBarChart(
                  steps: widget.steps,
                  isShowing30Days: false,
                  animate: true,
                  active: widget.isActive,
                ),
              ),
            ],

            // 경고: 활동 라벨 (왼쪽 정렬, 닉네임-버튼 수직 중앙) + 달력 토글 (정상 카드와 동일 위치)
            if (widget.showActionButtons && widget.activityLabel != null) ...[
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18.w, color: _emphasisColor),
                  SizedBox(width: 6.w),
                  Expanded(
                    // ⚠️ 카드 높이가 200.h 고정이라 이 라벨이 3줄이 되면 세로 오버플로가 난다.
                    // 번역문 길이는 언어마다 크게 달라(한국어 "안전 확인이 필요합니다" 대비
                    // 태국어는 2.5배) 문구 단축만으로는 재발을 막을 수 없어 2줄로 제한한다.
                    child: Text(
                      widget.activityLabel!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextTheme.bodyLarge(color: _emphasisColor, fw: FontWeight.w700),
                    ),
                  ),
                  _buildFullChartButton(),
                ],
              ),
              const Spacer(),
            ],

            // 정상: 마지막 확인 시간 (차트 아래)
            if (!widget.showActionButtons) ...[
              SizedBox(height: 0.h),
              _LabelValueText(
                text: widget.lastCheck,
                labelColor: AppColors.textTertiary,
                valueColor: _lastCheckValueColor,
              ),
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
                      final phone = widget.phone?.trim();
                      if (phone != null && phone.isNotEmpty) {
                        PhoneUtils.callDirectly(phone);
                      } else {
                        PhoneUtils.pickContactAndCall();
                      }
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
                          Flexible(
                            child: Text(
                              'guardian_call_now'.tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextTheme.labelSmall(
                                color: Colors.white,
                                fw: FontWeight.w600,
                              ),
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
                        border: Border.all(color: _emphasisColor.withValues(alpha: 0.7), width: 1.5),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Text(
                          'guardian_confirm_safety'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextTheme.labelSmall(
                            color: _emphasisColor,
                            fw: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              _LabelValueText(
                text: widget.lastCheck,
                labelColor: AppColors.textTertiary,
                valueColor: _lastCheckValueColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 걸음수 막대 차트 — 3상태(null/0/>0) 구분 렌더링.
/// · null = 등록 전 날짜: 연회색 낮은 막대
/// · 0    = heartbeat 없음: 연회색 짧은 막대
/// · >0   = 실제 걸음수. 오늘 막대는 주황(`_todayColor`)으로 강조, 그 외는 파랑(`_chartColor` alpha 0.7)
class _StepsBarChart extends StatefulWidget {
  final List<int?> steps;
  final bool isShowing30Days;

  /// true면 막대가 왼쪽부터 차례로 솟아오른다 — 30일 다이얼로그(대상자 달력 아이콘·[내 걸음수] 공용)에서만 켠다.
  final bool animate;

  /// animate=true일 때, 이 차트가 화면에 보이는 상태인가. false→true로 바뀔 때마다 처음부터 다시 재생한다
  /// (대상자 카드 PageView에서 해당 카드가 현재 페이지가 될 때). 다이얼로그는 항상 true.
  final bool active;

  const _StepsBarChart({
    required this.steps,
    required this.isShowing30Days,
    this.animate = false,
    this.active = true,
  });

  @override
  State<_StepsBarChart> createState() => _StepsBarChartState();
}

class _StepsBarChartState extends State<_StepsBarChart>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, ResumeReplayMixin {
  static const Color _todayColor = Color(0xFFFB8C00); // 오늘 강조 (Orange 600)

  /// 막대 하나가 솟는 구간 / 시작 시차가 퍼지는 구간 (전체 시간 대비 비율, 합 1.0).
  static const double _riseSpan = 0.4;
  static const double _staggerSpan = 0.6;

  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (!widget.animate) {
      _ctrl.value = 1;
    } else if (widget.active) {
      // 다이얼로그 scale 전환(300ms)이 끝난 뒤 시작해야 솟는 모습이 보인다.
      Future<void>.delayed(const Duration(milliseconds: 300), () {
        if (mounted && widget.active) _ctrl.forward();
      });
    }
  }

  @override
  void replayOnResume() {
    if (widget.animate && widget.active) _ctrl.forward(from: 0);
  }

  @override
  void didUpdateWidget(_StepsBarChart old) {
    super.didUpdateWidget(old);
    if (!widget.animate) return;
    if (widget.active && !old.active) {
      _ctrl.forward(from: 0);
    } else if (!widget.active && old.active) {
      _ctrl.value = 0; // 다시 활성화될 때 처음부터 재생되도록 비워 둔다.
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// 막대 i의 진행도 0~1 (왼쪽 막대부터 시차를 두고 시작).
  double _progress(int i, int n) {
    final start = i / n * _staggerSpan;
    final t = ((_ctrl.value - start) / _riseSpan).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.steps;
    final isShowing30Days = widget.isShowing30Days;
    if (steps.isEmpty) return const SizedBox.shrink();

    // 다크모드에서는 진한 파랑이 잘 보이지 않으므로 Cyan으로 전환
    // 다크 모드(7일 카드·30일 다이얼로그 공통)는 막대·글자 모두 형광 초록으로 — 어두운 배경에서 또렷하게.
    final neon = AppColors.isDark;
    const neonColor = Color(0xFF39FF14);
    final chartColor = neon
        ? neonColor
        : AppColors.isDark
            ? const Color(0xFF00BCD4) // Cyan 500
            : const Color(0xFF1A237E); // Indigo 900
    final chartTextColor = neon ? neonColor : AppColors.textTertiary;
    // 축 이름(걸음수 / 지난 30일)은 형광 주황 — 막대·수치(형광 초록)와 구분
    // x/y 축 선: 다크 모드는 반투명 흰색
    final axisLineColor = neon
        ? Colors.white.withValues(alpha: 0.5)
        : AppColors.textTertiary.withValues(alpha: 0.4);
    final axisTextColor = neon ? const Color(0xFFFF8C1A) : AppColors.textTertiary;

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

    // 0걸음 막대 — 다크 모드에서는 배경에 묻히지 않도록 밝은 반투명 흰색
    final emptyColor = neon
        ? Colors.white.withValues(alpha: 0.4)
        : AppColors.textTertiary.withValues(alpha: 0.25);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => BarChart(
      // 매 프레임 값을 직접 넣으므로 fl_chart 자체 보간은 끈다(이중 보간 방지).
      duration: Duration.zero,
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
                AppTextTheme.labelSmall(color: chartTextColor, fw: FontWeight.w600),
              );
            },
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: axisLineColor, width: 1),
            bottom: BorderSide(color: axisLineColor, width: 1),
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
              style: AppTextTheme.labelSmall(color: axisTextColor),
            ),
            sideTitles: const SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            axisNameSize: 16,
            axisNameWidget: Align(
              alignment: Alignment.center,
              child: Text(
                isShowing30Days
                    ? 'guardian_chart_x_axis_last_30_days'.tr
                    : 'guardian_chart_x_axis_last_7_days'.tr,
                style: AppTextTheme.labelSmall(color: axisTextColor),
              ),
            ),
            sideTitles: const SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          // 최댓값 막대 위에만 걸음수 표시 (쉼표 포함). fitInside로 차트
          // 좌우 끝 막대라도 라벨이 잘리지 않고 안쪽으로 정렬됨.
          // 최댓값 막대 라벨만 차트 상단에 표시. 1000 이하 막대는
          // showingTooltipIndicators로 막대 바로 위에 붙인다.
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: maxIdx >= 0,
              reservedSize: 16,
              getTitlesWidget: (value, meta) {
                if (value.toInt() != maxIdx) return const SizedBox.shrink();
                // 최댓값 막대가 다 솟은 뒤에 라벨을 띄운다.
                if (_progress(maxIdx, steps.length) < 1) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                  child: Text(
                    _formatSteps(maxVal),
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    // 최댓값 숫자는 막대(형광 초록)와 구분되도록 형광 청록
                    style: AppTextTheme.labelSmall(
                      color: neon ? const Color(0xFF00E5FF) : chartColor,
                      fw: FontWeight.w700,
                    ),
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
              // 7일 카드에서만 1000 이하 양수 막대 라벨을 막대 바로 위에 표시
              showingTooltipIndicators:
                  (!isShowing30Days && steps[i] != null && steps[i]! > 0 && steps[i]! <= 1000 && i != maxIdx)
                  ? [0]
                  : [],
              barRods: [
                BarChartRodData(
                  toY: _rodHeight(steps[i], maxY) * _progress(i, steps.length),
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
    return isToday ? _todayColor : active.withValues(alpha: active == const Color(0xFF39FF14) ? 0.9 : 0.7);
  }

  double _rodWidth(int n) {
    if (n <= 7) return 24;
    if (n <= 14) return 14;
    return 8;
  }

  /// 1234567 → "1,234,567" (천단위 쉼표, 로케일 의존성 없이 구현)
  String _formatSteps(int value) {
    return NumberText.format(value);
  }
}

/// 30일 차트 다이얼로그 표시 — 대상자 카드(달력 아이콘)와 [내 걸음수] 버튼이 공유한다.
/// 차트가 작게 시작해 튀어나오는 느낌 — scale(0.7→1.0, easeOutBack) + fade.
Future<void> _showStepsChartDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  required List<int?> steps,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'dismiss',
    barrierColor: AppColors.isDark ? Colors.black87 : Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _, _) =>
        _StepsChartDialog(title: title, subtitle: subtitle, steps: steps),
    transitionBuilder: (_, anim, _, child) {
      final scale = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInBack,
      );
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1.0).animate(scale),
          child: child,
        ),
      );
    },
  );
}

/// [내 걸음수] 탭 — 지금까지의 당일 걸음수를 서버에 올린 뒤 30일 차트를 연다.
///
/// ⚠️ 이 경로는 **안부 보고가 아니다** — `syncMyStepsAndLoad`가 heartbeat 전송 경로를
/// 타지 않고 걸음수 전용 엔드포인트만 호출한다(컨트롤러 주석 참조).
/// 걸음수 권한이 없으면 전송 없이 권한 요청 다이얼로그만 뜨고 차트는 열리지 않는다.
Future<void> _openMyStepsChart(
  BuildContext context,
  GuardianDashboardController controller,
) async {
  // 대상자 차트와 같은 가드를 공유 — 서버 왕복 중 재탭으로 다이얼로그가 2개 뜨는 것 차단.
  if (controller.isChartDialogBusy) return;
  controller.isChartDialogBusy = true;
  try {
    final ok = await controller.syncMyStepsAndLoad();
    if (!ok) return;
    if (!context.mounted) return;
    final steps =
        controller.monthlyStepsCache[GuardianDashboardController.myStepsCacheKey] ??
            const <int?>[];
    await _showStepsChartDialog(
      context,
      title: 'guardian_my_steps'.tr,
      // 본인 카드에는 경고 등급 개념이 없으므로 걸음수만으로 활동량 라벨을 만든다.
      subtitle: activityLabelFromSteps(steps),
      steps: steps,
    );
  } finally {
    controller.isChartDialogBusy = false;
  }
}

/// 달력 아이콘 탭 시 뜨는 확대 차트 다이얼로그 (30일 고정).
/// · scale + fade transition으로 "튀어나오는" 느낌 (showGeneralDialog 경로에서 적용)
/// · 닉네임 Row 오른쪽 X 아이콘 탭 또는 barrier 탭으로 닫힘
class _StepsChartDialog extends StatelessWidget {
  /// 상단 제목 — 대상자 별칭 또는 [내 걸음수].
  final String title;

  /// 제목 아래 한 줄 — 활동량 라벨.
  final String subtitle;

  /// 30일 걸음수 배열.
  final List<int?> steps;

  const _StepsChartDialog({
    required this.title,
    required this.subtitle,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // 다크 모드에서 흰 배경에 밝은 글자가 묻히던 문제 — 어두운 배경으로
      backgroundColor: AppColors.isDark ? const Color(0xFF1E2022) : null,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: AppTextTheme.bodyLarge(fw: FontWeight.w700)),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Get.back<void>(),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.close_rounded,
                      size: 22.w,
                      color: AppColors.isDark ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            // "활동량 : 값" — 값만 bold, 다크 모드에서는 형광 핑크
            _LabelValueText(
              text: subtitle,
              labelColor: AppColors.textSecondary,
              valueColor: AppColors.isDark ? const Color(0xFFFF8AE8) : null,
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 280.h,
              child: _StepsBarChart(steps: steps, isShowing30Days: true, animate: true),
            ),
          ],
        ),
      ),
    );
  }
}


/// "라벨: 값" 문장에서 첫 구분자(':' 또는 전각 '：') 뒤의 값 부분만 bold 처리한다.
/// 구분자가 없으면(예: "확인 기록 없음") 전체를 라벨 스타일로 그린다.
/// 번역 키를 라벨/값으로 쪼개지 않고 완성된 문장에서 나누므로 20개 언어에 그대로 적용된다.
class _LabelValueText extends StatelessWidget {
  final String text;
  final Color labelColor;
  final Color? valueColor;

  const _LabelValueText({
    required this.text,
    required this.labelColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final idx = text.indexOf(RegExp(r'[:：]'));
    final labelStyle = AppTextTheme.bodySmall(color: labelColor);
    if (idx < 0) return Text(text, style: labelStyle);
    final head = text.substring(0, idx + 1);
    final tail = text.substring(idx + 1);
    final leading = tail.length - tail.trimLeft().length;
    return Text.rich(
      TextSpan(
        style: labelStyle,
        children: [
          TextSpan(text: head + tail.substring(0, leading)),
          TextSpan(
            text: tail.substring(leading),
            style: AppTextTheme.bodySmall(
              color: valueColor ?? labelColor,
              fw: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 등급별 인원 카운터의 항목 하나 — 색 점 + "등급: N".
///
/// 색만으로 의미를 전달하지 않도록 등급명을 글자로 함께 적는다(색각 이상 대응).
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
        SizedBox(width: 4.w),
        Text(
          label,
          style: AppTextTheme.labelSmall(
            color: AppColors.isDark ? Colors.white : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
