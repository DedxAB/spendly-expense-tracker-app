import 'package:flutter/material.dart';
import 'package:spendly/core/theme/app_icons.dart';
import 'package:spendly/core/utils/formatters.dart';

class SpendlyBlackCard extends StatefulWidget {
  const SpendlyBlackCard({super.key, required this.balance, this.onTap});

  final double balance;
  final VoidCallback? onTap;

  @override
  State<SpendlyBlackCard> createState() => _SpendlyBlackCardState();
}

class _SpendlyBlackCardState extends State<SpendlyBlackCard> {
  bool _showValues = true;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: AspectRatio(
        aspectRatio: 2.1,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E0E),
            border: Border.all(color: const Color(0xFF282828)),
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: _DotBgPainter()),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'SPEND SNAPSHOT',
                        style: TextStyle(
                          color: Color(0xFFA0A0A0),
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
                        onPressed: () =>
                            setState(() => _showValues = !_showValues),
                        tooltip: _showValues ? 'Hide values' : 'Show values',
                        icon: Icon(
                          _showValues ? AppIcons.eye : AppIcons.eyeOff,
                          color: const Color(0xFFDADADA),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL BALANCE',
                        style: TextStyle(
                          color: Color(0xFF8F8F8F),
                          fontSize: 9,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _showValues
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                Formatters.currency(widget.balance),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          : const _MaskBars(bars: 10),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(
                        AppIcons.chevronRight,
                        size: 14,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Tap for transactions',
                        style: TextStyle(
                          color: Color(0xFFB7B7B7),
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
      height: 20,
      child: Row(
        children: List.generate(
          bars,
          (index) => Container(
            width: 4,
            height: 18,
            margin: EdgeInsets.only(right: index == bars - 1 ? 0 : 5),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _DotBgPainter extends CustomPainter {
  const _DotBgPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 14.0;
    const radius = 1.2;
    final paint = Paint()..color = const Color(0xFF1A1A1A);

    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
