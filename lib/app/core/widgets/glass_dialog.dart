import 'dart:math' as math;
import 'dart:math' show Random;
import 'dart:ui' show ImageFilter, PointMode;

import 'package:flutter/cupertino.dart' show CupertinoThemeData, CupertinoTheme, showCupertinoModalPopup;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:anbucheck/app/core/theme/app_colors.dart';

/// 다이얼로그 뒤 배경을 어두운 단색 막 대신 블러 + 옅은 틴트(글래스)로 표시한다.
///
/// 디자인 시스템의 "플로팅 요소에 Glassmorphism". 다이얼로그 라우트의 barrierColor는 투명으로 두고
/// 이 위젯이 블러 층을 깐다 — 블러 층은 터치를 가로채지 않아(IgnorePointer) 바깥 탭으로 닫히는
/// 기존 동작(barrierDismissible)은 그대로다. 라우트의 페이드 전환에 같이 실려 부드럽게 나타난다.
class GlassBackdrop extends StatelessWidget {
  const GlassBackdrop({super.key, required this.child});

  final Widget child;

  /// 블러 세기·틴트 농도. 여기 숫자만 바꾸면 모든 다이얼로그에 반영된다.
  static const double blurSigma = 14;

  /// 표면 효과 — 알갱이(서리 유리) / 금(깨진 차 유리). 켜고 끄기만 하면 된다.
  static const bool showGrain = false;
  static const bool showCracks = true;
  static Color get tint =>
      AppColors.isDark ? Colors.black.withValues(alpha: 0.18) : Colors.black.withValues(alpha: 0.07);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: ColoredBox(
                color: tint,
                // 서리 낀 유리처럼 거친 표면 — 블러 위에 잔 알갱이(노이즈)를 깐다.
                child: const RepaintBoundary(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (showGrain)
                        CustomPaint(painter: _GrainPainter(), size: Size.infinite),
                      if (showCracks)
                        CustomPaint(painter: _CrackPainter(), size: Size.infinite),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// `Get.dialog` 대체 — 글래스 배경을 입힌다. 시그니처는 `Get.dialog`와 같게 유지.
class AppDialog {
  AppDialog._();

  static Future<T?> show<T>(
    Widget widget, {
    bool barrierDismissible = true,
  }) {
    return Get.dialog<T>(
      GlassBackdrop(child: widget),
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.transparent,
      // 블러 배경이 세이프 에리어(Duo 카메라·노치 쪽)까지 화면 전체를 덮어야 한다.
      useSafeArea: false,
    );
  }
}

/// 글래스 배경 위에 얹는 다이얼로그 카드 — 반투명 면 + 자체 블러 + 큰 라운드 + 부드러운 그림자.
/// 1px 실선 테두리 없이 면의 밝기 차이로만 구분한다(디자인 시스템).
class GlassDialogCard extends StatelessWidget {
  const GlassDialogCard({
    super.key,
    required this.child,
    this.maxWidth = 420,
    this.forceLight = false,
  });

  final Widget child;
  final double maxWidth;

  /// 앱의 기존 알림 다이얼로그는 글자색을 어두운 색으로 고정해 둔 채 다크 모드에서도 밝은 카드였다.
  /// 그 글자가 묻히지 않도록 true면 다크 모드에서도 밝은 카드를 쓴다(테두리는 모드를 따른다).
  final bool forceLight;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark;
    final darkCard = dark && !forceLight;
    final radius = BorderRadius.circular(28);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: DecoratedBox(
          // 테두리는 카드 위(foreground)에 그려야 안쪽 블러·면에 가려지지 않는다.
          // 라이트: 어두운 테두리 / 다크: 밝은 테두리. 굵기·농도는 여기 숫자만 조정.
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: dark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.5),
              width: 1.8,
            ),
          ),
          child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.45 : 0.16),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: ColoredBox(
                color: darkCard
                    ? const Color(0xFF24262B).withValues(alpha: 0.72)
                    : Colors.white.withValues(alpha: 0.78),
                child: child,
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

/// 고정 시드의 잔 알갱이를 흩뿌린다(매 프레임 바뀌지 않아 깜빡이지 않음). 밝은·어두운 점을 섞어
/// 라이트·다크 어디서나 질감이 보인다. 굵기·밀도·농도는 아래 상수만 조정.
class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  static const double _density = 0.014; // 픽셀 대비 점 비율
  static const double _dotSize = 5;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rnd = Random(7);
    final count = (size.width * size.height * _density).clamp(0, 90000).toInt();
    final light = <Offset>[];
    final dark = <Offset>[];
    for (var i = 0; i < count; i++) {
      final p = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
      (rnd.nextBool() ? light : dark).add(p);
    }
    canvas.drawPoints(
      PointMode.points,
      light,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..strokeWidth = _dotSize
        ..strokeCap = StrokeCap.square,
    );
    canvas.drawPoints(
      PointMode.points,
      dark,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..strokeWidth = _dotSize
        ..strokeCap = StrokeCap.square,
    );
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) => false;
}

/// 깨진 차 유리 — 총알 자국 여러 곳. 각 충격점에서 금이 사방으로 뻗고, 둘레를 도는 고리 금과
/// 곁가지가 붙는다. 한쪽으로 쏠리지 않게 대각선 두 곳에 놓았다. 고정 시드라 매번 같은 모양.
/// 흰 선 아래에 어두운 선을 살짝 어긋나게 깔아 갈라진 단면처럼 보인다.
class _CrackPainter extends CustomPainter {
  const _CrackPainter();

  static const int _radials = 15;
  static const List<double> _rings = [26, 62, 112, 180, 270, 390, 540, 740, 1000];

  /// 충격점들 — (가로 비율, 세로 비율, 금 크기 배율).
  static const List<(double, double, double)> _impacts = [
    (0.20, 0.24, 1.1), // 왼쪽 위
    (0.80, 0.78, 1.1), // 오른쪽 아래 (대각선)
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final path = Path();
    final centers = <Offset>[];
    var seed = 11;
    for (final (fx, fy, scale) in _impacts) {
      final c = Offset(size.width * fx, size.height * fy);
      centers.add(c);
      _addCluster(path, Random(seed++), c, scale);
    }

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // 그림자 선(살짝 어긋나게) → 흰 선
    canvas.save();
    canvas.translate(1.4, 1.4);
    canvas.drawPath(path, stroke..color = Colors.black.withValues(alpha: 0.14)..strokeWidth = 2.2);
    canvas.restore();
    canvas.drawPath(path, stroke..color = Colors.white.withValues(alpha: 0.35)..strokeWidth = 1.1);
    // 충격점(구멍 + 고리)
    for (final c in centers) {
      canvas.drawCircle(c, 6, Paint()..color = Colors.black.withValues(alpha: 0.35));
      canvas.drawCircle(c, 5, Paint()..color = Colors.white.withValues(alpha: 0.5));
      canvas.drawCircle(c, 9, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.4));
    }
  }

  void _addCluster(Path path, Random rnd, Offset center, double scale) {
    // 방사형 금: 각 가닥의 고리별 점. 중간에 끊기는 가닥도 있다.
    final pts = <List<Offset>>[];
    final base = <double>[];
    for (var i = 0; i < _radials; i++) {
      var a = i * 2 * math.pi / _radials + (rnd.nextDouble() - 0.5) * 0.28;
      base.add(a);
      final reach = 3 + rnd.nextInt(_rings.length - 2);
      final line = <Offset>[];
      for (var j = 0; j < reach; j++) {
        a += (rnd.nextDouble() - 0.5) * 0.16;
        final r = _rings[j] * scale * (0.92 + rnd.nextDouble() * 0.16);
        line.add(center + Offset(math.cos(a), math.sin(a)) * r);
      }
      pts.add(line);
    }

    for (final line in pts) {
      path.moveTo(center.dx, center.dy);
      for (final p in line) {
        path.lineTo(p.dx, p.dy);
      }
    }
    // 고리 금 — 이웃한 두 가닥의 같은 고리 점을 이어 거미줄 모양으로.
    for (var j = 0; j < 6; j++) {
      for (var i = 0; i < _radials; i++) {
        final k = (i + 1) % _radials;
        if (j >= pts[i].length || j >= pts[k].length) continue;
        if (rnd.nextDouble() > 0.72) continue;
        final a = pts[i][j];
        final b = pts[k][j];
        final mid = Offset.lerp(a, b, 0.5)! +
            Offset((rnd.nextDouble() - 0.5) * 10, (rnd.nextDouble() - 0.5) * 10);
        path
          ..moveTo(a.dx, a.dy)
          ..lineTo(mid.dx, mid.dy)
          ..lineTo(b.dx, b.dy);
      }
    }
    // 곁가지 — 방사 금에서 짧게 갈라진다.
    for (var i = 0; i < _radials; i++) {
      for (var j = 1; j < pts[i].length; j++) {
        if (rnd.nextDouble() > 0.38) continue;
        final p = pts[i][j];
        final dir = base[i] + (rnd.nextBool() ? 1 : -1) * (0.5 + rnd.nextDouble() * 0.6);
        final len = (40 + rnd.nextDouble() * 90) * scale;
        final mid = p + Offset(math.cos(dir), math.sin(dir)) * (len * 0.5) +
            Offset((rnd.nextDouble() - 0.5) * 8, (rnd.nextDouble() - 0.5) * 8);
        final end = p + Offset(math.cos(dir), math.sin(dir)) * len;
        path
          ..moveTo(p.dx, p.dy)
          ..lineTo(mid.dx, mid.dy)
          ..lineTo(end.dx, end.dy);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CrackPainter old) => false;
}

/// `AlertDialog` 대체 — 글래스 카드 + 같은 title/content/actions 구성. 기존 호출부는 클래스 이름만 바꾸면 된다.
/// (`shape`는 받아서 무시한다 — 카드 모양은 글래스 카드가 정한다.)
class GlassAlertDialog extends StatelessWidget {
  const GlassAlertDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.shape,
  });

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    return GlassDialogCard(
      child: DefaultTextStyle.merge(
        // 색을 따로 지정하지 않은 글자는 모드에 맞게(다크: 밝은 글자).
        style: TextStyle(color: GlassColors.title),
        child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              DefaultTextStyle(
                style: Theme.of(context).textTheme.titleLarge ?? const TextStyle(),
                child: title!,
              ),
            if (title != null && content != null) const SizedBox(height: 16),
            if (content != null)
              Flexible(child: SingleChildScrollView(child: content!)),
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 20),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: 8,
                overflowAlignment: OverflowBarAlignment.end,
                overflowSpacing: 8,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }
}

/// 다이얼로그 안 글자색 — 라이트는 기존 어두운 색, 다크는 밝은 색. 하드코딩 색 대신 쓴다.
class GlassColors {
  GlassColors._();

  static Color get title => AppColors.isDark ? Colors.white : const Color(0xFF1A1C1C);
  static Color get body => AppColors.isDark ? const Color(0xFFD6D8DD) : const Color(0xFF3F4948);
  static Color get muted => AppColors.isDark ? const Color(0xFF9DA0A8) : const Color(0xFF9E9E9E);
  /// 글래스 테두리 — 라이트는 어두운 테두리, 다크는 밝은 테두리.
  static Color get border => AppColors.isDark
      ? Colors.white.withValues(alpha: 0.7)
      : Colors.black.withValues(alpha: 0.5);
  static const double borderWidth = 1.8;
  static Color get divider => AppColors.isDark ? const Color(0x33FFFFFF) : const Color(0xFFE0E0E0);
}

/// 아래에서 올라오는 시트(시간 선택 휠 등)용 글래스 카드 — 위쪽 두 모서리만 크게 둥글다.
class GlassSheet extends StatelessWidget {
  const GlassSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark;
    const radius = BorderRadius.vertical(top: Radius.circular(28));
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border(
          top: BorderSide(color: GlassColors.border, width: GlassColors.borderWidth),
          left: BorderSide(color: GlassColors.border, width: GlassColors.borderWidth),
          right: BorderSide(color: GlassColors.border, width: GlassColors.borderWidth),
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.45 : 0.16),
              blurRadius: 40,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: ColoredBox(
              color: dark
                  ? const Color(0xFF24262B).withValues(alpha: 0.72)
                  : Colors.white.withValues(alpha: 0.78),
              // 홈 인디케이터 영역까지 카드가 이어지도록 아래 여백을 더한다.
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `showCupertinoModalPopup` 대체 — 글래스 배경 + 글래스 시트. 시트 안 휠·글자가 모드에 맞게 보이도록
/// Cupertino 테마 밝기도 앱 모드에 맞춘다.
Future<T?> showGlassSheet<T>({required WidgetBuilder builder}) {
  return showCupertinoModalPopup<T>(
    context: Get.context!,
    barrierColor: Colors.transparent,
    builder: (ctx) => GlassBackdrop(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: CupertinoTheme(
          data: CupertinoThemeData(
            brightness: AppColors.isDark ? Brightness.dark : Brightness.light,
          ),
          child: GlassSheet(child: Builder(builder: builder)),
        ),
      ),
    ),
  );
}

/// `showTimePicker` 대체(안드로이드 시간 선택) — 글래스 배경 + 세이프 에리어까지 덮음.
/// 기본 `showTimePicker`는 배경을 세이프 에리어 안쪽에만 그리고 배리어 색 외에는 꾸밀 수 없어,
/// `TimePickerDialog`를 직접 `showDialog`로 띄운다. [builder]는 기존처럼 다이얼로그를 감싼다(12/24시간제 등).
Future<TimeOfDay?> showGlassTimePicker({
  required TimeOfDay initialTime,
  String? helpText,
  TransitionBuilder? builder,
}) {
  return showDialog<TimeOfDay>(
    context: Get.context!,
    barrierColor: Colors.transparent,
    useSafeArea: false,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      // 다른 글래스 다이얼로그와 같은 큰 모서리 + 모드별 테두리(라이트 어두운 선 / 다크 밝은 선).
      final Widget dialog = Theme(
        data: theme.copyWith(
          timePickerTheme: theme.timePickerTheme.copyWith(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(color: GlassColors.border, width: GlassColors.borderWidth),
            ),
          ),
        ),
        child: TimePickerDialog(initialTime: initialTime, helpText: helpText),
      );
      return GlassBackdrop(
        child: builder == null ? dialog : builder(ctx, dialog),
      );
    },
  );
}
