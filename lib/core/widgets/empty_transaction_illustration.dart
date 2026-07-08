import 'package:flutter/material.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';

class EmptyTransactionIllustration extends StatelessWidget {
  const EmptyTransactionIllustration({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 88,
            height: 72,
            child: CustomPaint(
              painter: _ReceiptIllustrationPainter(
                surfaceColor: context.surface,
                surfaceAltColor: context.surfaceAlt,
                iconColor: context.textSecondary.withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'No transactions yet',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: AppFontSizes.body,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptIllustrationPainter extends CustomPainter {
  _ReceiptIllustrationPainter({
    required this.surfaceColor,
    required this.surfaceAltColor,
    required this.iconColor,
  });

  final Color surfaceColor;
  final Color surfaceAltColor;
  final Color iconColor;

  static const _neonGreen = Color(0xFF22C55E);

  void _drawNeonBorder(Canvas canvas, RRect rrect) {
    final glow = Paint()
      ..color = _neonGreen.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, glow);
    final sharp = Paint()
      ..color = _neonGreen.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, sharp);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(14, 18, 58, 42),
      const Radius.circular(10),
    );
    final paint = Paint()
      ..color = surfaceAltColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, paint);
    _drawNeonBorder(canvas, rrect);

    final rrect2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(18, 24, 58, 42),
      const Radius.circular(10),
    );
    final paint2 = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect2, paint2);
    _drawNeonBorder(canvas, rrect2);

    final paintLine = Paint()
      ..color = _neonGreen.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    final lineGlow = Paint()
      ..color = _neonGreen.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
      ..style = PaintingStyle.fill;

    void drawLine(double left, double top, double width) {
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, width, 3),
        const Radius.circular(2),
      );
      canvas.drawRRect(r, lineGlow);
      canvas.drawRRect(r, paintLine);
    }

    drawLine(30, 34, 34);
    drawLine(30, 42, 22);
    drawLine(30, 50, 12);

    canvas.save();
    canvas.translate(8, 12);
    canvas.rotate(0.08);
    final rrect3 = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, 32, 22),
      const Radius.circular(6),
    );
    canvas.drawRRect(rrect3, paint..color = surfaceAltColor);
    _drawNeonBorder(canvas, rrect3);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ReceiptIllustrationPainter oldDelegate) =>
      oldDelegate.surfaceColor != surfaceColor ||
      oldDelegate.surfaceAltColor != surfaceAltColor ||
      oldDelegate.iconColor != iconColor;
}
