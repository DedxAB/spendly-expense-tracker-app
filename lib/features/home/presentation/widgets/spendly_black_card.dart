import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/core/widgets/amount_mask.dart';
import 'package:spendly/features/home/presentation/widgets/home_surface_card.dart';

class SpendlyBlackCard extends StatelessWidget {
  const SpendlyBlackCard({
    super.key,
    required this.balance,
    required this.goalAllocation,
    required this.showValues,
    required this.onToggleValues,
    this.onTap,
    this.dailyExpense = const [],
  });

  final double balance;
  final double goalAllocation;
  final bool showValues;
  final VoidCallback onToggleValues;
  final VoidCallback? onTap;
  final List<double> dailyExpense;

  @override
  Widget build(BuildContext context) {
    return HomeSurfaceCard(
      onTap: onTap,
      borderRadius: 28,
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
      child: SizedBox(
        height: 188,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -10,
              top: 26,
              bottom: 16,
              child: IgnorePointer(
                child: _SpendGraphArea(
                  width: 204,
                  height: 136,
                  values: dailyExpense,
                  todayIndex: math.max(DateTime.now().day - 1, 0),
                  lineColor: context.homeAccentGreen,
                  fillColor: context.homeAccentGreen.withValues(alpha: 0.16),
                  dashedColor: context.border.withValues(alpha: 0.6),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'SPEND SNAPSHOT',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: AppFontSizes.label,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: onToggleValues,
                          tooltip: showValues
                              ? 'Hide amounts'
                              : 'Show amounts',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints.tightFor(
                            width: 28,
                            height: 28,
                          ),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            showValues ? AppIcons.eye : AppIcons.eyeOff,
                            size: 16,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Available to spend',
                              style: TextStyle(
                                color: context.textPrimary,
                                fontSize: AppFontSizes.heading,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: AmountView(
                                      balance,
                                      style: TextStyle(
                                        color: balance < 0
                                            ? context.homeAccentRed
                                            : context.textPrimary,
                                        fontSize: AppFontSizes.largeHeading,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -1.1,
                                        height: 1,
                                      ),
                                      maskColor: balance < 0
                                          ? context.homeAccentRed
                                          : context.textPrimary,
                                    ),
                                  ),
                                ),
],
                          ),
                        ],
                      ),
                    ),
                  ),
                    Row(
                      children: [
Text(
                          'Tap for transactions',
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: AppFontSizes.label,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          AppIcons.chevronRight,
                          size: 19,
                          color: context.textPrimary,
                        ),
                      ],
                    ),
                    if (goalAllocation > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        showValues
                            ? '${Formatters.currency(goalAllocation)} allocated to '
                                  'goals this month'
                            : '◆ ◆ ◆ allocated to goals this month',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: AppFontSizes.label,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendGraphArea extends StatefulWidget {
  const _SpendGraphArea({
    required this.width,
    required this.height,
    required this.values,
    required this.todayIndex,
    required this.lineColor,
    required this.fillColor,
    required this.dashedColor,
  });

  final double width;
  final double height;
  final List<double> values;
  final int todayIndex;
  final Color lineColor;
  final Color fillColor;
  final Color dashedColor;

  @override
  State<_SpendGraphArea> createState() => _SpendGraphAreaState();
}

class _SpendGraphAreaState extends State<_SpendGraphArea>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Daily spending chart this month; higher bars mean more spent',
      child: RepaintBoundary(
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              size: Size(widget.width, widget.height),
              painter: _SpendGraphPainter(
                values: widget.values,
                todayIndex: widget.todayIndex,
                pulse: _controller.value,
                lineColor: widget.lineColor,
                fillColor: widget.fillColor,
                dashedColor: widget.dashedColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpendGraphPainter extends CustomPainter {
  const _SpendGraphPainter({
    required this.values,
    required this.todayIndex,
    required this.pulse,
    required this.lineColor,
    required this.fillColor,
    required this.dashedColor,
  });

  final List<double> values;
  final int todayIndex;
  final double pulse;
  final Color lineColor;
  final Color fillColor;
  final Color dashedColor;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final baseY = height - 4;
    final n = values.length;

    if (n == 0) return;

    final seg = width / n;
    final top = 8.0;
    final chartH = baseY - top;
    final glowRadius = 8.0 + pulse * 9;
    final glowAlpha = 0.16 + pulse * 0.26;

    void drawGlowDot(Offset pos) {
      canvas.drawCircle(
        pos,
        glowRadius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              lineColor.withValues(alpha: glowAlpha),
              lineColor.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(center: pos, radius: glowRadius),
          ),
      );
      canvas.drawCircle(
        pos,
        7 - pulse * 1.5,
        Paint()
          ..color = lineColor.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      canvas.drawCircle(
        pos,
        4.5,
        Paint()..color = lineColor,
      );
    }

    if (!values.any((v) => v > 0)) {
      // No spend yet — anchor a quietly pulsing dot at today's column.
      final idx = todayIndex.clamp(0, n - 1);
      drawGlowDot(Offset(idx * seg + seg / 2, baseY));
      return;
    }

    final maxV = values.reduce(math.max);

    final barW = (seg * 0.6).clamp(2.0, 6.0);

    final pts = <Offset>[];
    for (var i = 0; i < n; i++) {
      final v = values[i];
      if (v <= 0) continue;
      final h = math.max((v / maxV) * chartH, 3.0);
      final x = i * seg + (seg - barW) / 2;
      final y = baseY - h;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barW, h),
          const Radius.circular(999),
        ),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lineColor.withValues(alpha: 0.40),
              lineColor.withValues(alpha: 0.06),
            ],
          ).createShader(Rect.fromLTWH(x, y, barW, h)),
      );
      pts.add(Offset(i * seg + seg / 2, y));
    }

    final linePath = _smoothPath(pts, minY: top, maxY: baseY);
    final lastPoint = pts.isEmpty ? null : pts.last;

    // Soft area fill under the trend line.
    if (lastPoint != null) {
      final fillPath = Path.from(linePath)
        ..lineTo(lastPoint.dx, baseY)
        ..lineTo(linePath.getBounds().left, baseY)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [fillColor, fillColor.withValues(alpha: 0.02)],
          ).createShader(Rect.fromLTWH(0, 0, width, height)),
      );
    }

    final glowPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, glowPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    if (lastPoint != null) {
      drawGlowDot(lastPoint);
    }
  }

  static Path _smoothPath(
    List<Offset> pts, {
    required double minY,
    required double maxY,
  }) {
    double clampY(double y) => y.clamp(minY, maxY);
    final path = Path();
    if (pts.isEmpty) return path;
    if (pts.length == 1) {
      path.moveTo(pts.first.dx, pts.first.dy);
      return path;
    }
    path.moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = i - 1 < 0 ? pts[0] : pts[i - 1];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : pts[i + 1];
      final cp1 = p1 + (p2 - p0) * (1 / 6);
      final cp2 = p2 - (p3 - p1) * (1 / 6);
      path.cubicTo(
        cp1.dx,
        clampY(cp1.dy),
        cp2.dx,
        clampY(cp2.dy),
        p2.dx,
        p2.dy,
      );
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _SpendGraphPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.todayIndex != todayIndex ||
        oldDelegate.pulse != pulse ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.dashedColor != dashedColor;
  }
}
