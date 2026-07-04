import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/services/theme_service.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/modules/safety_home/widgets/emergency_button.dart';
import 'package:anbucheck/app/modules/safety_home/widgets/invite_code_share_card.dart';

/// 온보딩 목업 위젯 모음.
/// 실제 화면(safety_home / guardian_add_subject / guardian_settings / drawer)의
/// 위젯을 그대로 재사용하거나 동일한 스타일로 복제한 "정지 화면"이다.
/// 어떤 항목도 실제 동작(복사·공유·전송·연결·입력)을 수행하지 않으며,
/// 탭·포커스·커서가 절대 발생하지 않도록 IgnorePointer로 감싼다.

void _noop() {}

/// 실제 OS 푸시 알림 배너 디자인을 그대로 재현한 목업(앱 아이콘+앱명+시각, 굵은 제목, 본문).
/// 앱 내부 카드들과 달리 OS 알림 배너는 실제로 그림자/부유 형태이므로 여기서만 그림자를 허용한다.
class PushNotificationMockup extends StatelessWidget {
  final String title;
  final String body;

  const PushNotificationMockup({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.w,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF4355B9),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(Icons.favorite_rounded, size: 13.w, color: Colors.white),
              ),
              SizedBox(width: 6.w),
              Text('app_name'.tr,
                  style: AppTextTheme.labelSmall(
                      color: AppColors.textTertiary, fw: FontWeight.w600)),
              SizedBox(width: 6.w),
              Text('지금', style: AppTextTheme.labelSmall(color: AppColors.textTertiary)),
            ],
          ),
          SizedBox(height: 4.h),
          Text(title, style: AppTextTheme.bodyLarge(fw: FontWeight.w700)),
          SizedBox(height: 2.h),
          Text(
            body,
            style: AppTextTheme.bodyMedium(color: AppColors.onSurfaceVariant),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// ① 안전코드 카드 — safety_home의 InviteCodeShareCard 그대로 재사용
class SafetyCodeMockup extends StatelessWidget {
  const SafetyCodeMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: InviteCodeShareCard(
        inviteCode: 'EF4-PVGJ',
        isDark: Get.find<ThemeService>().isDarkMode.value,
        onCopy: _noop,
        onShare: _noop,
      ),
    );
  }
}

/// ② "도움이 필요해요" 버튼 — safety_home의 EmergencyButton 그대로 재사용
class EmergencyButtonMockup extends StatelessWidget {
  const EmergencyButtonMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: EmergencyButton(
        isSending: false,
        enabled: true,
        onPressed: _noop,
      ),
    );
  }
}

/// ③ Drawer "가족 안부도 관리하기" 메뉴 항목 복제 (S → G+S 전환)
class GsSwitchMockup extends StatelessWidget {
  const GsSwitchMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(Icons.family_restroom_rounded,
              size: 22.w, color: const Color(0xFF4355B9)),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'drawer_enable_guardian'.tr,
              style: AppTextTheme.bodyLarge(color: const Color(0xFF4355B9)),
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              size: 22.w, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }
}

/// ④ 대상자 추가 화면 복제 — 고유 코드 입력 + 별칭 입력 + 연결하기 버튼
/// guardian_add_subject_page.dart와 동일한 InputDecoration/버튼 스타일.
/// 실제 TextField/ElevatedButton을 사용하되 IgnorePointer + readOnly로
/// 절대 포커스·커서·탭이 발생하지 않도록 이중 차단한다.
class AddSubjectMockup extends StatelessWidget {
  const AddSubjectMockup({super.key});

  InputDecoration _decoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextTheme.bodyLarge(color: AppColors.textTertiary),
      filled: true,
      fillColor: AppColors.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'add_subject_code_label'.tr,
            style: AppTextTheme.labelMedium(color: AppColors.onSurface, fw: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.sm),
          TextField(
            readOnly: true,
            style: AppTextTheme.bodyLarge(),
            decoration: _decoration(hintText: '123-4567'),
          ),
          SizedBox(height: AppSpacing.sp6),
          Text(
            'add_subject_alias_label'.tr,
            style: AppTextTheme.labelMedium(color: AppColors.onSurface, fw: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.sm),
          TextField(
            readOnly: true,
            style: AppTextTheme.bodyLarge(),
            decoration: _decoration(hintText: 'add_subject_alias_hint'.tr),
          ),
          SizedBox(height: AppSpacing.sp8),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: _noop,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4355B9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link_rounded, size: 20.w),
                  SizedBox(width: 8.w),
                  Text('add_subject_connect'.tr, style: AppTextTheme.labelLarge()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ⑥ 보호자 알림 목록 화면 헤더("알림" 아이콘+타이틀, guardian_notifications_page의 AppBar title Row와
/// 동일) + 주의 등급 카드·걸음수 활동 정보 카드 복제 (guardian_notifications_page._NotificationCard와
/// 동일한 배경색·아이콘·라벨 스타일). 카드 두 개는 각각 애니메이션이 걸리므로 정적 목업만 노출하고
/// 진입 애니메이션(순차 슬라이드다운)은 이 위젯 자체가 StatefulWidget으로 소유한다 — 다른 스텝처럼
/// OnboardingIllustration에서 단일 진입 애니메이션으로 감싸는 방식으로는 두 카드의 시간차를 표현할 수
/// 없기 때문.
class NotificationsPreviewMockup extends StatefulWidget {
  const NotificationsPreviewMockup({super.key});

  @override
  State<NotificationsPreviewMockup> createState() => _NotificationsPreviewMockupState();
}

class _NotificationsPreviewMockupState extends State<NotificationsPreviewMockup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _cautionProgress;
  late final Animation<double> _stepsProgress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _cautionProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );
    _stepsProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notifications_rounded, size: 22.w, color: AppColors.onSurface),
            SizedBox(width: 8.w),
            Text('notifications_title'.tr, style: AppTextTheme.headlineSmall()),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => _slideDown(_cautionProgress.value,
              child: const _MiniNotificationCard(
                labelKey: 'notifications_level_caution',
                bodyKey: 'noti_caution_suspicious_body',
                icon: Icons.info_rounded,
                color: Color(0xFFFFC107),
                backgroundColor: Color(0xFFFFF9C4),
              )),
        ),
        SizedBox(height: AppSpacing.md),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => _slideDown(_stepsProgress.value,
              child: const _MiniNotificationCard(
                labelKey: 'notifications_level_info',
                bodyKey: 'noti_steps_body',
                bodyParams: {'steps': '3,482'},
                icon: Icons.directions_walk_rounded,
                color: Color(0xFF4355B9),
                backgroundColor: Color(0xFFE3F2FD),
              )),
        ),
      ],
    );
  }

  Widget _slideDown(double progress, {required Widget child}) {
    return Opacity(
      opacity: progress,
      child: Transform.translate(
        offset: Offset(0, -24.h * (1 - progress)),
        child: child,
      ),
    );
  }
}

class _MiniNotificationCard extends StatelessWidget {
  final String labelKey;
  final String bodyKey;
  final Map<String, String>? bodyParams;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _MiniNotificationCard({
    required this.labelKey,
    required this.bodyKey,
    this.bodyParams,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18.w, color: color),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labelKey.tr,
                  style: AppTextTheme.labelSmall(color: color, fw: FontWeight.w700),
                ),
                SizedBox(height: 2.h),
                Text(
                  bodyParams != null ? bodyKey.trParams(bodyParams!) : bodyKey.tr,
                  style: AppTextTheme.bodyMedium(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ⑤ 보호자 설정 화면 헤더("설정" 아이콘+타이틀, guardian_settings_page의 AppBar title Row와 동일)
/// + "나도 안부 보호 받기" 버튼 복제 (guardian_settings_page._buildGsButton).
/// 버튼이 설정 화면 안에 있다는 맥락을 보여주기 위해 실제 헤더를 함께 표시한다.
class GsEnableMockup extends StatelessWidget {
  const GsEnableMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.settings_rounded, size: 22.w, color: AppColors.onSurface),
            SizedBox(width: 8.w),
            Text('settings_title'.tr, style: AppTextTheme.headlineSmall()),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_rounded, size: 22.w, color: AppColors.onSurfaceVariant),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text('gs_enable_button'.tr,
                    style: AppTextTheme.bodyLarge(fw: FontWeight.w600)),
              ),
              Icon(Icons.chevron_right_rounded, size: 22.w, color: AppColors.onSurfaceVariant),
            ],
          ),
        ),
      ],
    );
  }
}
