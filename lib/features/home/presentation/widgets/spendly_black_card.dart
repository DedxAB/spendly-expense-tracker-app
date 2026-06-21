import 'package:flutter/material.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/utils/formatters.dart';

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
    return InkWell(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 2.1,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.surface,
            border: Border.all(color: context.border),
            borderRadius: BorderRadius.circular(AppRadii.premiumCard),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _DotBgPainter(
                    dotColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFFE8E8E8),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'SPEND SNAPSHOT',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 10,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints.tightFor(
                          width: 32,
                          height: 32,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: onToggleValues,
                        tooltip: showValues ? 'Hide values' : 'Show values',
                        icon: Icon(
                          showValues ? AppIcons.eye : AppIcons.eyeOff,
                          color: context.textPrimary,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL BALANCE',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 9,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      showValues
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                Formatters.currency(balance),
                                style: TextStyle(
                                  color: context.textPrimary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          : _MaskBars(
                              bars: Formatters.rawCurrency(balance)
                                  .replaceAll(RegExp(r'\s+'), '')
                                  .length,
                            ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        AppIcons.chevronRight,
                        size: 14,
                        color: context.textPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap for transactions',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaskBars extends StatelessWidget {
  const _MaskBars({required this.bars});

  final int bars;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        children: List.generate(
          bars <= 0 ? 1 : bars,
          (index) => Container(
            width: 7,
            height: 22,
            margin: EdgeInsets.only(right: index == bars - 1 ? 0 : 6),
              color: context.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _DotBgPainter extends CustomPainter {
  const _DotBgPainter({required this.dotColor});

  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 14.0;
    const radius = 1.2;
    final paint = Paint()..color = dotColor;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotBgPainter oldDelegate) =>
      oldDelegate.dotColor != dotColor;
}
