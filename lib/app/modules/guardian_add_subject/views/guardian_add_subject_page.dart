import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/modules/guardian_add_subject/controllers/guardian_add_subject_controller.dart';
import 'package:anbucheck/app/core/widgets/guardian_bottom_nav.dart';

/// 보호자 대상자 연결 페이지 — 시안 _1 기준
/// 인디고 테마, 고유코드(8자리)+별칭 입력, 하단 네비게이션
class GuardianAddSubjectPage extends GetWidget<GuardianAddSubjectController> {
  const GuardianAddSubjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.onSurface, size: 24.w),
          onPressed: () => Get.back(),
        ),
        title: Text('보호 대상자 연결', style: AppTextTheme.headlineSmall()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.sp6),

            // 안내 문구
            Text(
              '연결할 보호 대상자의 고유 코드\n와 별칭을 입력해주세요.',
              style: AppTextTheme.headlineLarge(),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              '보호 대상자의 앱을 연결하여 실시간 건강 상태\n및 활동을 확인할 수 있습니다.',
              style: AppTextTheme.bodyMedium(color: AppColors.textTertiary),
            ),
            SizedBox(height: AppSpacing.sp8),

            // 고유 코드 입력
            Text(
              '고유 코드 (8자리)',
              style: AppTextTheme.labelMedium(
                color: AppColors.onSurface,
                fw: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            TextField(
              controller: controller.codeController,
              onChanged: controller.onCodeChanged,
              style: AppTextTheme.bodyLarge(),
              keyboardType: TextInputType.visiblePassword,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                TextInputFormatter.withFunction((old, next) =>
                    next.copyWith(text: next.text.toUpperCase())),
              ],
              decoration: InputDecoration(
                hintText: '1234-5678',
                hintStyle: AppTextTheme.bodyLarge(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    color: Color(0xFF4355B9),
                    width: 2,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),

            // 코드 안내
            Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14.w, color: AppColors.textTertiary),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    '고유 코드는 보호 대상자의 앱에서 확인할 수 있습니다.',
                    style: AppTextTheme.bodySmall(),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sp6),

            // 대상자 별칭
            Text(
              '보호 대상자 별칭',
              style: AppTextTheme.labelMedium(
                color: AppColors.onSurface,
                fw: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            TextField(
              controller: controller.aliasController,
              style: AppTextTheme.bodyLarge(),
              decoration: InputDecoration(
                hintText: '예: 어머니, 아버지',
                hintStyle: AppTextTheme.bodyLarge(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    color: Color(0xFF4355B9),
                    width: 2,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sp8),

            // 연결하기 버튼
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isCodeValid
                        ? controller.connectSubject
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4355B9),
                      disabledBackgroundColor:
                          const Color(0xFF4355B9).withValues(alpha: 0.3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.link_rounded, size: 20.w),
                        SizedBox(width: 8.w),
                        Text(
                          '연결하기',
                          style: AppTextTheme.labelLarge(),
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const GuardianBottomNav(currentIndex: 1),
    );
  }
}
