import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:anbucheck/app/core/utils/constants.dart';
import 'package:anbucheck/app/core/utils/back_press_handler.dart';
import 'package:anbucheck/app/core/services/ad_service.dart';
import 'package:anbucheck/app/core/services/iap_service.dart';
import 'package:anbucheck/app/core/services/theme_service.dart';
import 'package:anbucheck/app/modules/guardian_dashboard/controllers/guardian_dashboard_controller.dart';
import 'package:anbucheck/app/modules/guardian_settings/controllers/guardian_settings_controller.dart';
import 'package:anbucheck/app/modules/safety_home/widgets/solid_action_button.dart';
import 'package:anbucheck/app/core/widgets/guardian_bottom_nav.dart';

/// 보호자 설정 페이지 — v2: G+S 통합 카드 포함
class GuardianSettingsPage extends GetWidget<GuardianSettingsController> {
  const GuardianSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) BackPressHandler.onBackPressed();
      },
      child: Obx(() {
        Get.find<ThemeService>().isDarkMode.value;
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Icon(Icons.settings_rounded, size: 22.w, color: AppColors.onSurface),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    'settings_title'.tr,
                    style: AppTextTheme.headlineSmall(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              // 다크모드 토글 (AppBar 오른쪽)
              Obx(() {
                final themeSvc = Get.find<ThemeService>();
                final isDark = themeSvc.isDarkMode.value;
                return IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    size: 24.w,
                    color: AppColors.onSurfaceVariant,
                  ),
                  onPressed: themeSvc.toggle,
                );
              }),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
            // ⚠️ 이 Column은 Obx로 감싸지 않는다 — 연결 관리 카드(삭제됨)의
            // `subjects`/`maxSubjects`가 유일한 관찰 대상이었고, 관찰 대상이 하나도 없는
            // Obx는 런타임에 ObxError를 던진다(analyze로는 안 잡힘).
            // 반응형 영역(구독 카드·G+S 버튼·앱 버전)은 각자 Obx를 갖고 있다.
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.lg),

                  // G+S 버튼: 비활성 → 활성화 / 활성 → 안전 코드 확인 페이지 이동
                  // 화면 최상단(구 연결 관리 카드 자리)으로 올려 첫 화면에서 바로 보이게 한다.
                  _buildGsButton(),
                  SizedBox(height: AppSpacing.sp6),

                  // 구독 및 서비스 섹션
                  Text(
                    'settings_subscription_service'.tr,
                    style: AppTextTheme.labelMedium(
                      color: AppColors.textTertiary,
                      fw: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // 구독 카드
                  _buildSubscriptionCard(),
                  SizedBox(height: AppSpacing.lg),

                  // 알림 설정
                  GestureDetector(
                    onTap: controller.goToNotificationSettings,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications_rounded,
                            size: 22.w,
                            color: AppColors.onSurfaceVariant,
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'settings_notification'.tr,
                              style: AppTextTheme.bodyLarge(fw: FontWeight.w600),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 22.w,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.sp6),

                  // 약관 섹션
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 20.w,
                              color: AppColors.onSurfaceVariant,
                            ),
                            SizedBox(width: AppSpacing.md),
                            Text(
                              'settings_terms_section'.tr,
                              style: AppTextTheme.bodyLarge(fw: FontWeight.w600),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.lg),
                        GestureDetector(
                          onTap: () => launchUrl(
                            Uri.parse(AppConstants.privacyPolicyUrl),
                            mode: LaunchMode.externalApplication,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'settings_privacy_policy'.tr,
                                style: AppTextTheme.bodyMedium(color: AppColors.textSecondary),
                              ),
                              Icon(
                                Icons.open_in_new_rounded,
                                size: 18.w,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppSpacing.md),
                        GestureDetector(
                          onTap: () => launchUrl(
                            Uri.parse(AppConstants.termsOfServiceUrl),
                            mode: LaunchMode.externalApplication,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'settings_terms'.tr,
                                style: AppTextTheme.bodyMedium(color: AppColors.textSecondary),
                              ),
                              Icon(
                                Icons.open_in_new_rounded,
                                size: 18.w,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                        // EEA/UK/스위스 사용자에게만 광고 동의 관리 진입점 표시
                        // (PrivacyOptionsRequirementStatus.required 일 때만 노출)
                        FutureBuilder<bool>(
                          future: Get.isRegistered<AdService>()
                              ? AdService.to.isPrivacyOptionsRequired()
                              : Future.value(false),
                          builder: (context, snapshot) {
                            if (snapshot.data != true) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                SizedBox(height: AppSpacing.md),
                                GestureDetector(
                                  onTap: () => AdService.to.showPrivacyOptionsForm(),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'settings_ad_consent'.tr,
                                        style: AppTextTheme.bodyMedium(
                                            color: AppColors.textSecondary),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14.w,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.sp8),

                  // 하단: 앱 버전 + 브랜드 + 회사 링크(저작권 라인) + 탈퇴(아래)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          'settings_app_version'.trParams({
                            'version': controller.appVersion.value,
                          }),
                          style: AppTextTheme.labelSmall(color: AppColors.textTertiary),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'ANBU GUARD NETWORK',
                        style: AppTextTheme.labelSmall(
                          color: AppColors.textTertiary,
                          fw: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      // 회사 웹사이트 링크를 저작권 라인으로 이동 — ANBU GUARD NETWORK
                      // 라인에 두면 영어권 탈퇴 텍스트 폭에 밀려 오버플로됨
                      Row(
                        children: [
                          Text(
                            'app_copyright'.tr,
                            style: AppTextTheme.labelSmall(color: AppColors.textTertiary),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => launchUrl(
                              Uri.parse(AppConstants.companyWebsiteUrl),
                              mode: LaunchMode.externalApplication,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppConstants.companyWebsiteLabel,
                                  style: AppTextTheme.labelSmall(
                                    color: AppColors.guardianPrimary,
                                    fw: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.open_in_new_rounded,
                                  size: 14.w,
                                  color: AppColors.guardianPrimary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xl),
                      // 탈퇴를 저작권 라인 우측에서 아래 단독 라인으로 이동
                      GestureDetector(
                        onTap: () => _showDeleteConfirm(),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: Text(
                            'drawer_withdraw'.tr,
                            style: AppTextTheme.labelSmall(color: AppColors.error),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sp6),
                ],
              ),
          ),
          bottomNavigationBar: const GuardianBottomNav(currentIndex: 3),
        );
      }),
    );
  }

  // ── G+S 버튼 (안전 홈과 동일한 솔리드 액션 버튼 언어) ──

  /// 설정 화면에서 유일하게 "누르는 것"으로 읽혀야 하는 요소라, 조용한 흰 카드 행
  /// 대신 안전 홈의 [SolidActionButton]을 그대로 쓴다 — 톤 채움 + 테두리 + 아이콘
  /// 배지 + 설명 한 줄.
  ///
  /// 색은 **Teal 톤**이다. 바로 위 구독 카드가 인디고/회색 그라데이션이라 여기에
  /// 또 그라데이션을 얹으면 둘 다 CTA로 읽히지 않고, 이 버튼이 데려가는 곳이
  /// 보호자(Indigo) 기능이 아니라 대상자(Teal) 기능인 안전 홈이기 때문이다.
  /// 안전 홈의 안전 보고·시간 변경 버튼과 같은 `tonal*` 팔레트를 공유한다.
  ///
  /// 아래 [알림 설정] 행은 조용한 흰 카드로 남겨 둔다 — 둘 다 강조하면 대비가
  /// 사라져 이 버튼이 눈에 띄지 않는다.
  Widget _buildGsButton() {
    final dashboard = Get.find<GuardianDashboardController>();
    return Obx(() {
      final isGS = dashboard.isAlsoSubject.value;
      final enabling = dashboard.isEnabling.value;
      final isDark = Get.find<ThemeService>().isDarkMode.value;
      final fill = SolidActionButton.tonalFill(isDark);
      final accent = SolidActionButton.tonalAccent(isDark);

      return SolidActionButton(
        icon: Icons.shield_rounded,
        label: isGS ? 'gs_safety_code_button'.tr : 'gs_enable_button'.tr,
        description: isGS ? 'gs_safety_code_button_desc'.tr : 'gs_enable_button_desc'.tr,
        gradient: [fill, fill],
        borderColor: accent.withValues(alpha: 0.45),
        foregroundColor: accent,
        iconBackgroundColor: SolidActionButton.tonalBadge(isDark),
        iconColor: accent,
        // 활성화 진행 중에는 isBusy가 탭을 막고 스피너로 바꾼다(회색 톤으로 떨어지는
        // 것은 안전 홈 안전 보고 버튼과 동일한 동작).
        isBusy: enabling,
        enabled: true,
        onPressed: isGS ? dashboard.goToSafetyCode : () => _showEnableConfirm(),
      );
    });
  }

  /// G+S 활성화 확인 — **플랫폼 분기 없음**(2026-08-31 통합).
  ///
  /// 예전에는 iOS만 별도 다이얼로그에 "알림을 탭하거나 직접 앱을 열어야 안부가
  /// 전송됩니다"라는 경고 카드를 띄웠다. 2026-08-22 NSE 트리거 + 08-29 피기백으로
  /// **iOS도 탭 없이 자동 전송**되면서 그 경고는 사실이 아니게 됐고, 겁을 주는 문구가
  /// 잔존율이 가장 높은 모드(G+S)의 진입을 막고 있었다.
  ///
  /// ⚠️ `gs_enable_dialog_ios_warning_title`/`_body`/`gs_enable_dialog_ios_confirm`
  /// 세 키는 **번역 파일에서 지우지 말 것** — 웹(`averic-lab/_faq-build/extract_strings.py`)의
  /// 추출 키 목록에 있어 지우면 페이지 빌드가 exit 1로 실패한다. 코드에서 쓰지 않을 뿐이다.
  void _showEnableConfirm() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'gs_enable_dialog_title'.tr,
          style: AppTextTheme.headlineSmall(fw: FontWeight.w700, color: const Color(0xFF1A1C1C)),
        ),
        content: Text(
          'gs_enable_dialog_body'.tr,
          style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'common_cancel'.tr,
              style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948)),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.find<GuardianDashboardController>().enableSubjectFeature();
            },
            child: Text(
              'gs_enable_confirm'.tr,
              style: AppTextTheme.bodyMedium(color: const Color(0xFF4355B9), fw: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ── 탈퇴 확인 다이얼로그 ──

  void _showDeleteConfirm() {
    Get.dialog(
      AlertDialog(
        title: Text('drawer_withdraw'.tr, style: AppTextTheme.headlineSmall(fw: FontWeight.w700)),
        content: Text(
          // 체험 안내는 **보호자 경로에만** 붙인다. safety_home의 탈퇴 다이얼로그는
          // Drawer가 isSubject일 때만 생성되므로 순수 대상자만 보게 되고,
          // 체험이 없는 사용자에게는 무관한 문장이 된다.
          // 재등록 시 잔여 기간은 그대로 복원되지만 90일이 새로 시작되지는 않는다
          // (서버 trial_grants — PRD-BackEnd §4.2.1). 손해 경고가 아니라
          // "탈퇴하면 초기화되니 체험도 다시 받겠지"라는 오해를 막기 위한 고지다.
          '${'drawer_withdraw_message'.tr}\n\n${'drawer_withdraw_message_trial'.tr}',
          style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'common_cancel'.tr,
              style: AppTextTheme.bodyMedium(color: const Color(0xFF3F4948)),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAccount();
            },
            child: Text(
              'drawer_withdraw'.tr,
              style: AppTextTheme.bodyMedium(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  // ── 구독 카드 ──

  Widget _buildSubscriptionCard() {
    return Obx(() {
      final plan = controller.subscriptionPlan.value;
      final isActive = controller.isSubscriptionActive.value;
      // 3-state 분기:
      //  · yearly + is_active=true  → 인디고 카드 + 흰 텍스트 + [구독 관리]
      //  · expired OR (yearly + is_active=false) → 만료 카드 (Dashboard 만료 배너와 동일 톤 #FFF3E0 + #E65100) + [구독하기]
      //    서버 안전망 활용: expires_at < now면 is_active=false 응답이므로
      //    RTDN(EXPIRED) 누락·지연 상황에서 plan='yearly'가 잔존해도 만료로 인식.
      //    plan만 보면 RTDN을 안 보낸 sandbox 환경 + production grace period 등에서
      //    "프리미엄 구독 중" 영구 표시되는 production hole 차단.
      //  · free_trial / '' → 회색 카드 + 흰 텍스트 + [구독하기] + [구독 복원]
      final isPremium = plan == 'yearly' && isActive;
      final isExpired = plan == 'expired' || (plan == 'yearly' && !isActive);
      final iap = Get.isRegistered<IapService>() ? Get.find<IapService>() : null;
      final iapAvailable = iap?.isAvailable.value ?? false;
      final processing = iap?.isProcessing.value ?? false;
      // 에러 스낵바 표시는 GuardianSettingsController의 ever 워커가 담당
      // (Obx 안 postFrameCallback + 상태 재설정 패턴은 self-rebuild 트리거로 fragile).

      // expired는 light 배경 + 주황 강조 (Dashboard와 동일 톤). 다른 상태와
      // 색 체계가 크게 달라 별도 분기로 전체 카드를 분리한다.
      if (isExpired) {
        return _buildExpiredCard(iap: iap, iapAvailable: iapAvailable, processing: processing);
      }

      // 색상 그라데이션 (yearly / free_trial)
      final List<Color> gradient = isPremium
          ? [const Color(0xFF4355B9), const Color(0xFF5C6BC0)] // 인디고
          : [const Color(0xFF607D8B), const Color(0xFF90A4AE)]; // 회색

      // 타이틀 + 아이콘
      final iconData = isPremium ? Icons.verified_rounded : Icons.card_giftcard_rounded;
      final titleKey = isPremium ? 'settings_premium' : 'settings_free_trial';

      // 일수 배지: 0보다 큰 경우만 표시. 라벨도 plan별로 분리.
      final days = controller.subscriptionDaysRemaining.value;
      final bool showDaysBadge = days > 0;
      final String daysLabelKey = isPremium
          ? 'settings_days_until_renewal'
          : 'settings_days_until_trial_end';

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.sp4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  iconData,
                  size: 18.w,
                  color: Colors.white70,
                ),
                SizedBox(width: 6.w),
                Text(
                  'settings_current_membership'.tr,
                  style: AppTextTheme.labelSmall(color: Colors.white70, fw: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  // 긴 언어(독일어 "Kostenlose Testphase", 폴란드어 27자 등)는 한 줄
                  // 폭을 넘어 줄바꿈되므로, FittedBox로 폭에 맞게 자동 축소해 한 줄 유지.
                  // 짧은 언어는 넘치지 않으면 원래 크기 그대로(scaleDown은 축소만 함).
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      titleKey.tr,
                      maxLines: 1,
                      style: AppTextTheme.headlineMedium(color: Colors.white, fw: FontWeight.w700),
                    ),
                  ),
                ),
                if (showDaysBadge)
                  Padding(
                    // left: 제목과 배지의 최소 보장 간격 (긴 언어에선 제목이 폭을
                    // 꽉 채워 이 값이 둘 사이 유일한 여백이 됨)
                    padding: EdgeInsets.only(bottom: 4.h, left: 12.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        daysLabelKey.trParams({'days': '$days'}),
                        style: AppTextTheme.labelSmall(color: Colors.white, fw: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            if (isPremium) ...[
              _PremiumButton(
                label: 'settings_manage_subscription'.tr,
                filled: false,
                onTap: () => launchUrl(
                  Uri.parse(
                    GetPlatform.isIOS
                        ? 'https://apps.apple.com/account/subscriptions'
                        : 'https://play.google.com/store/account/subscriptions',
                  ),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              // 이용약관 + 개인정보처리방침 링크 (Apple 3.1.2(c) 요건 — iOS 전용)
              // 프리미엄 상태에서도 구독 UI에 인접하게 표시
              if (Platform.isIOS) _buildLegalLinks(darkBg: true),
            ]
            else if (!iapAvailable || iap?.productDetails.value == null) ...[
              // 스토어 미가용 또는 상품 미등록 (Play Console anbu_yearly 등록 전,
              // 일시 네트워크 장애로 queryProductDetails 실패 등) — 두 버튼 모두
              // 숨기고 안내 텍스트만 표시. 버튼 노출 후 클릭만 실패하는 UX 회피.
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Text(
                  'subscription_store_unavailable'.tr,
                  style: AppTextTheme.bodySmall(color: Colors.white70),
                ),
              ),
            ] else ...[
              // 가격 + 기간 표시 (Apple 3.1.2(c) 요건)
              if (iap?.productDetails.value != null)
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    '${iap!.productDetails.value!.price} / ${'subscription_period_annual'.tr}',
                    style: AppTextTheme.bodySmall(color: Colors.white70),
                  ),
                ),
              _PremiumButton(
                label: 'subscription_subscribe'.tr,
                filled: true,
                loading: processing,
                onTap: processing ? null : controller.startSubscribe,
              ),
              SizedBox(height: AppSpacing.sm),
              _PremiumButton(
                label: 'subscription_restore'.tr,
                filled: false,
                loading: processing,
                onTap: processing ? null : controller.restoreSubscription,
              ),
              // 이용약관 + 개인정보처리방침 링크 (Apple 3.1.2(c) 요건 — iOS 전용)
              if (Platform.isIOS) _buildLegalLinks(darkBg: true),
            ],
          ],
        ),
      );
    });
  }

  /// expired 전용 카드 — Dashboard 만료 배너와 색상/버튼 디자인 일치.
  /// 배경 #FFF3E0 + 보더 #E65100 30% 알파 + 텍스트 #E65100/#4E2C00 +
  /// ElevatedButton 스타일의 [구독하기] (filled #E65100, 흰 텍스트, 10.r 코너).
  Widget _buildExpiredCard({
    required IapService? iap,
    required bool iapAvailable,
    required bool processing,
  }) {
    const accent = Color(0xFFE65100);   // 강조 (Dashboard 만료 배너 #E65100)
    const accentLight = Color(0xFFFFF3E0); // 배경 (Dashboard 만료 배너 #FFF3E0)
    const bodyText = Color(0xFF4E2C00);  // 본문 (Dashboard 만료 배너 #4E2C00)

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.sp4),
      decoration: BoxDecoration(
        color: accentLight,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 18.w, color: accent),
              SizedBox(width: 6.w),
              Text(
                'settings_current_membership'.tr,
                style: AppTextTheme.labelSmall(color: accent, fw: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'settings_expired'.tr,
            style: AppTextTheme.headlineMedium(color: accent, fw: FontWeight.w700),
          ),
          SizedBox(height: AppSpacing.lg),
          if (!iapAvailable || iap?.productDetails.value == null) ...[
            // 스토어 미가용 — 안내만 노출 (다른 상태와 동일 폴백 톤)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Text(
                'subscription_store_unavailable'.tr,
                style: AppTextTheme.bodySmall(color: bodyText),
              ),
            ),
          ] else ...[
            // 가격 + 기간 표시 (Apple 3.1.2(c) 요건)
            if (iap?.productDetails.value != null)
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  '${iap!.productDetails.value!.price} / ${'subscription_period_annual'.tr}',
                  style: AppTextTheme.bodySmall(color: bodyText),
                ),
              ),
            // [구독하기] — Dashboard 만료 배너와 동일한 ElevatedButton 스타일
            SizedBox(
              width: double.infinity,
              height: 40.h,
              child: ElevatedButton(
                onPressed: processing
                    ? null
                    : controller.startSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: accent.withValues(alpha: 0.6),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: processing
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'subscription_subscribe'.tr,
                        style: AppTextTheme.labelMedium(
                          color: Colors.white,
                          fw: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            // [구독 복원] — outline 스타일 (보조 액션, accent 강조)
            SizedBox(
              width: double.infinity,
              height: 40.h,
              child: OutlinedButton(
                onPressed: processing
                    ? null
                    : controller.restoreSubscription,
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  disabledForegroundColor: accent.withValues(alpha: 0.6),
                  side: BorderSide(color: accent.withValues(alpha: 0.6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: processing
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                        ),
                      )
                    : Text(
                        'subscription_restore'.tr,
                        style: AppTextTheme.labelMedium(
                          color: accent,
                          fw: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            // 이용약관 + 개인정보처리방침 링크 (Apple 3.1.2(c) 요건 — iOS 전용)
            if (Platform.isIOS) _buildLegalLinks(darkBg: false),
          ],
        ],
      ),
    );
  }

  /// 이용약관 + 개인정보처리방침 링크 (Apple Guideline 3.1.2(c) 요건).
  /// Wrap 사용 — 긴 언어(태국어·러시아어 등)에서 Row overflow 방지.
  /// [darkBg]: true면 흰색 텍스트(그라디언트 카드), false면 어두운 텍스트(만료 카드).
  Widget _buildLegalLinks({required bool darkBg}) {
    final textColor = darkBg ? Colors.white70 : const Color(0xFF4E2C00);
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.sm),
      child: Wrap(
        spacing: 6.w,
        runSpacing: 2.h,
        children: [
          GestureDetector(
            onTap: () => launchUrl(
              Uri.parse(AppConstants.termsOfServiceUrl),
              mode: LaunchMode.externalApplication,
            ),
            child: Text(
              'settings_terms'.tr,
              style: AppTextTheme.labelSmall(
                color: textColor,
                fw: FontWeight.w600,
              ),
            ),
          ),
          Text('·', style: AppTextTheme.labelSmall(color: textColor)),
          GestureDetector(
            onTap: () => launchUrl(
              Uri.parse(AppConstants.privacyPolicyUrl),
              mode: LaunchMode.externalApplication,
            ),
            child: Text(
              'settings_privacy_policy'.tr,
              style: AppTextTheme.labelSmall(
                color: textColor,
                fw: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumButton extends StatelessWidget {
  final String label;
  final bool filled;
  final bool loading;
  final VoidCallback? onTap;

  const _PremiumButton({
    required this.label,
    required this.filled,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    // 로딩 중에는 불투명도 유지 (스피너가 명확히 보이도록).
    // 단순 disabled(!iapAvailable 등)에서만 흐려짐.
    final opacity = (disabled && !loading) ? 0.6 : 1.0;
    final contentColor = filled ? const Color(0xFF4355B9) : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: filled ? Colors.white : Colors.transparent,
            border: filled ? null : Border.all(color: Colors.white54),
            borderRadius: BorderRadius.circular(24.r),
          ),
          alignment: Alignment.center,
          // Stack으로 텍스트가 항상 layout 자리를 차지하게 해 로딩 전후 버튼
          // 높이가 흔들리지 않도록 한다 (스피너는 텍스트보다 작아 그대로 두면
          // 컨테이너 높이가 줄어듦).
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: loading ? 0 : 1,
                child: Text(
                  label,
                  style: AppTextTheme.bodyMedium(
                    color: contentColor,
                    fw: FontWeight.w700,
                  ),
                ),
              ),
              if (loading)
                SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(contentColor),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
