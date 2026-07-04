import 'package:flutter/material.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/utils/formatters.dart';
import 'package:spendly/features/home/presentation/widgets/home_surface_card.dart';

class SpendlyBlackCard extends StatelessWidget {
  const SpendlyBlackCard({
    super.key,
    required this.balance,
    required this.showValues,
    required this.onToggleValues,
    this.dailyIncome = const [],
    this.dailyExpense = const [],
    this.onTap,
  });

  final double balance;
  final bool showValues;
  final VoidCallback onToggleValues;
  final List<double> dailyIncome;
  final List<double> dailyExpense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return HomeSurfaceCard(
      onTap: onTap,
      borderRadius: 28,
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 14),
      child: SizedBox(
        height: 190,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _BackgroundGraphPainter(
                    accent: context.homeAccentGreen,
                    gridColor: context.border.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'SPEND SNAPSHOT',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 12,
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
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Total Balance',
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            showValues
                                ? FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      Formatters.currency(balance),
                                      style: TextStyle(
                                        color: context.textPrimary,
                                        fontSize: 40,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -1,
                                        height: 1,
                                      ),
                                    ),
                                  )
                                : Text(
                                    '******',
                                    style: TextStyle(
                                      color: context.textPrimary,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 4,
                                    ),
                                  ),
                            const Spacer(),
                            Row(
                              children: [
                                Text(
                                  'Tap for transactions',
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  AppIcons.chevronRight,
                                  size: 18,
                                  color: context.textPrimary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: CustomPaint(
                            size: const Size(120, 120),
                            painter: _HeroGraphPainter(
                              incomeColor: context.homeAccentGreen,
                              expenseColor: AppColors.expense,
                              dailyIncome: dailyIncome,
                              dailyExpense: dailyExpense,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundGraphPainter extends CustomPainter {
  const _BackgroundGraphPainter({
    required this.accent,
    required this.gridColor,
  });

  final Color accent;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = accent.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(w * 0.1, h * 0.65)
      ..cubicTo(w * 0.3, h * 0.8, w * 0.45, h * 0.4, w * 0.6, h * 0.55)
      ..cubicTo(w * 0.75, h * 0.7, w * 0.85, h * 0.35, w * 0.92, h * 0.3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundGraphPainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.gridColor != gridColor;
}

class _HeroGraphPainter extends CustomPainter {
  const _HeroGraphPainter({
    required this.incomeColor,
    required this.expenseColor,
    required this.dailyIncome,
    required this.dailyExpense,
  });

  final Color incomeColor;
  final Color expenseColor;
  final List<double> dailyIncome;
  final List<double> dailyExpense;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final padX = w * 0.06;
    final padY = h * 0.06;
    final chartW = w - padX * 2;
    final chartH = h - padY * 2;

    final maxVal = _maxAcross(dailyIncome, dailyExpense);
    if (maxVal <= 0) {
      _drawEmptyState(canvas, w, h);
      return;
    }

    _drawLine(canvas, dailyIncome, incomeColor, padX, padY, chartW, chartH, maxVal);
    _drawLine(canvas, dailyExpense, expenseColor, padX, padY, chartW, chartH, maxVal);
  }

  double _maxAcross(List<double> a, List<double> b) {
    double m = 0;
    for (final v in a) { if (v > m) m = v; }
    for (final v in b) { if (v > m) m = v; }
    return m;
  }

  void _drawLine(Canvas canvas, List<double> values, Color color,
      double padX, double padY, double chartW, double chartH, double maxVal) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final maxIdx = values.length - 1;
    final dots = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = padX + (i / (maxIdx > 0 ? maxIdx : 1)) * chartW;
      final y = padY + chartH - (values[i] / maxVal) * chartH;
      dots.add(Offset(x, y));
    }

    if (dots.isEmpty) return;

    final path = Path()..moveTo(dots.first.dx, dots.first.dy);
    for (var i = 1; i < dots.length; i++) {
      path.lineTo(dots[i].dx, dots[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawEmptyState(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = incomeColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(w * 0.15, h * 0.6)
      ..cubicTo(w * 0.3, h * 0.75, w * 0.45, h * 0.45, w * 0.6, h * 0.55)
      ..cubicTo(w * 0.75, h * 0.65, w * 0.85, h * 0.35, w * 0.88, h * 0.3);

    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(w * 0.88, h * 0.3), 4, paint);
  }

  @override
  bool shouldRepaint(covariant _HeroGraphPainter oldDelegate) {
    return oldDelegate.incomeColor != incomeColor ||
        oldDelegate.expenseColor != expenseColor ||
        oldDelegate.dailyIncome != dailyIncome ||
        oldDelegate.dailyExpense != dailyExpense;
  }
}
