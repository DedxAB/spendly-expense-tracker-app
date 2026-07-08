import 'package:flutter/material.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/widgets/amount_mask.dart';
import 'package:spendly/features/home/presentation/widgets/home_surface_card.dart';

class SpendlyBlackCard extends StatelessWidget {
  const SpendlyBlackCard({
    super.key,
    required this.balance,
    required this.showValues,
    required this.onToggleValues,
    this.onTap,
  });

  final double balance;
  final bool showValues;
  final VoidCallback onToggleValues;
  final VoidCallback? onTap;

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
              bottom: 0,
              child: IgnorePointer(
                child: _SpendGraphArea(
                  width: 204,
                  height: 136,
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
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Balance',
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
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: AmountView(
                                  balance,
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: AppFontSizes.largeHeading,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -1.1,
                                    height: 1,
                                  ),
                                  maskColor: context.textPrimary,
                                  maskWidth: 7,
                                  maskHeight: 22,
                                  maskSpacing: 4,
                                  maskRadius: 0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          'Tap for transactions',
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: AppFontSizes.subhead,
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

class _SpendGraphArea extends StatelessWidget {
  const _SpendGraphArea({
    required this.width,
    required this.height,
    required this.lineColor,
    required this.fillColor,
    required this.dashedColor,
  });

  final double width;
  final double height;
  final Color lineColor;
  final Color fillColor;
  final Color dashedColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        size: Size(width, height),
        painter: _SpendGraphPainter(
          lineColor: lineColor,
          fillColor: fillColor,
          dashedColor: dashedColor,
        ),
      ),
    );
  }
}

class _SpendGraphPainter extends CustomPainter {
  const _SpendGraphPainter({
    required this.lineColor,
    required this.fillColor,
    required this.dashedColor,
  });

  final Color lineColor;
  final Color fillColor;
  final Color dashedColor;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final linePath = Path()
      ..moveTo(width * 0.08, height * 0.77)
      ..cubicTo(
        width * 0.18,
        height * 0.62,
        width * 0.26,
        height * 0.48,
        width * 0.38,
        height * 0.64,
      )
      ..cubicTo(
        width * 0.50,
        height * 0.82,
        width * 0.60,
        height * 0.38,
        width * 0.72,
        height * 0.34,
      )
      ..cubicTo(
        width * 0.82,
        height * 0.30,
        width * 0.90,
        height * 0.44,
        width * 0.96,
        height * 0.20,
      );

    final fillPath = Path.from(linePath)
      ..lineTo(width * 0.96, height * 0.98)
      ..lineTo(width * 0.08, height * 0.98)
      ..close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor, fillColor.withValues(alpha: 0.02)],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawPath(fillPath, fillPaint);

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

    final dashedPaint = Paint()
      ..color = dashedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final dashedSegments = <Offset>[
      Offset(width * 0.12, height * 0.88),
      Offset(width * 0.30, height * 0.74),
      Offset(width * 0.48, height * 0.62),
      Offset(width * 0.66, height * 0.50),
      Offset(width * 0.84, height * 0.40),
      Offset(width * 0.96, height * 0.30),
    ];
    for (var i = 0; i < dashedSegments.length - 1; i++) {
      canvas.drawLine(dashedSegments[i], dashedSegments[i + 1], dashedPaint);
    }

    final barsPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.18),
          lineColor.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    const barXs = [106.0, 114.0, 122.0, 130.0, 138.0, 146.0, 154.0, 162.0];
    final barHeights = [54.0, 62.0, 68.0, 72.0, 68.0, 78.0, 84.0, 92.0];
    for (var i = 0; i < barXs.length; i++) {
      final x = barXs[i];
      final h = barHeights[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, height - h - 4, 4, h),
          const Radius.circular(999),
        ),
        barsPaint,
      );
    }

    canvas.drawCircle(
      Offset(width * 0.96, height * 0.20),
      4.5,
      Paint()..color = lineColor,
    );
  }

  @override
  bool shouldRepaint(covariant _SpendGraphPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.dashedColor != dashedColor;
  }
}
