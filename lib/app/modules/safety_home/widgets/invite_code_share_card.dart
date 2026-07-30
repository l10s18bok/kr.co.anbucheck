import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anbucheck/app/core/theme/app_spacing.dart';
import 'package:anbucheck/app/core/theme/app_text_theme.dart';

/// 안전 코드 표시 + 복사/공유 히어로 카드 — S/G+S 공통
///
/// 화면의 주인공이므로 딥 블루 그라데이션으로 채워 시선을 먼저 잡는다.
///
/// **Teal을 쓰지 않는 이유**: 주 버튼(안전 보고하기)이 브랜드 Teal 솔리드라
/// 같은 계열을 쓰면 "정보 카드"와 "버튼"이 다시 한 덩어리로 읽힌다. 색상 계열
/// 자체를 갈라 두면 채움 방식이 비슷해도 역할이 즉시 구분된다.
///
/// 보호자 모드 Indigo(#4355B9)와도 일부러 거리를 둔 네이비~아주르 계열이다 —
/// 대상자 화면에서 보호자 모드 색을 그대로 쓰면 모드 구분이 흐려진다.
///
/// 카드 내부의 복사/공유만 원형 아이콘 버튼으로 눌리는 요소임을 드러낸다.
class InviteCodeShareCard extends StatelessWidget {
  final String inviteCode;
  final bool isDark;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const InviteCodeShareCard({
    super.key,
    required this.inviteCode,
    required this.isDark,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final hasCode = inviteCode.isNotEmpty;
    final radius = BorderRadius.circular(16.r);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF0A2138), Color(0xFF123F63)]
                : const [Color(0xFF123C63), Color(0xFF1D6FA5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: radius,
        ),
        child: Stack(
          children: [
            // 은은한 원형 액센트 (ClipRRect로 카드 밖은 잘려나감)
            Positioned(
              right: -34.w,
              top: -46.w,
              child: _accentCircle(132.w, 0.07),
            ),
            Positioned(
              right: 46.w,
              bottom: -56.w,
              child: _accentCircle(118.w, 0.05),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.sp4,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'SAFETY SHARE CODE',
                          style: AppTextTheme.labelSmall(
                            color: Colors.white.withValues(alpha: 0.75),
                            fw: FontWeight.w700,
                          ).copyWith(letterSpacing: 1.4),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _CircleIconButton(
                        icon: Icons.copy_rounded,
                        onTap: onCopy,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      _CircleIconButton(
                        icon: Icons.share_rounded,
                        onTap: onShare,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.vmd),
                  // 긴 코드/큰 글씨 접근성에서도 줄바꿈 없이 축소되도록 FittedBox
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        hasCode ? inviteCode : '---  ----',
                        style: TextStyle(
                          fontSize: 42.sp,
                          fontWeight: FontWeight.w800,
                          color: hasCode
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                          letterSpacing: 3,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accentCircle(double size, double alpha) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: alpha),
      shape: BoxShape.circle,
    ),
  );
}

/// 히어로 카드 위의 반투명 원형 아이콘 버튼 (복사/공유)
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      // 히어로 카드 자체는 테두리 없이 두되, 그 위의 "버튼"만 테두리를 갖는다.
      shape: CircleBorder(
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 42.w,
          height: 42.w,
          child: Icon(icon, size: 20.w, color: Colors.white),
        ),
      ),
    );
  }
}
