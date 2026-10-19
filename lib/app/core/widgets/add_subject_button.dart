import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';

/// 새로운 대상자 추가 버튼 — 점선 테두리 + 원형 아이콘 + 텍스트
class AddSubjectButton extends StatelessWidget {
  final VoidCallback onTap;

  /// true면 세로를 줄인 컴팩트 형태(넓은 화면에서 광고 자리를 대신할 때). 논리 px 고정값을
  /// 써서 큰 화면의 `.h`/`.w` 스케일과 무관하게 높이가 예측되게 한다.
  final bool compact;

  const AddSubjectButton({super.key, required this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    // 다크 모드에서는 테두리·아이콘·텍스트를 흰색으로 (어두운 배경에서 잘 보이도록)
    final dark = AppColors.isDark;
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: dark
              ? Colors.white.withValues(alpha: 0.6)
              : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          radius: 14.r,
          dashWidth: 6,
          dashSpace: 4,
          strokeWidth: 1.5,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: compact ? 22 : 28.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: compact ? 32 : 36.w,
                height: compact ? 32 : 36.w,
                decoration: BoxDecoration(
                  color: dark
                      ? const Color(0xFF5A5F69)
                      : AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add,
                    size: 20.w,
                    color: dark ? Colors.white : AppColors.onSurfaceVariant),
              ),
              SizedBox(height: compact ? 6 : 10.h),
              Text(
                'add_subject_button'.tr,
                style: AppTextTheme.bodyMedium(
                  color: dark ? Colors.white : AppColors.textSecondary,
                  fw: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final dashedPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        dashedPath.addPath(
          metric.extractPath(distance, end.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = end + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
