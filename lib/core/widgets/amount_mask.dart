import 'package:flutter/material.dart';
import 'package:spendly/core/utils/amount_visibility.dart';
import 'package:spendly/core/utils/formatters.dart';

class AmountMask extends StatelessWidget {
  const AmountMask({
    super.key,
    required this.digitCount,
    this.barColor,
    this.barWidth = 6,
    this.barHeight = 18,
    this.barSpacing = 3,
    this.borderRadius = 0,
  });

  final int digitCount;
  final Color? barColor;
  final double barWidth;
  final double barHeight;
  final double barSpacing;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final color = barColor ?? Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(digitCount, (i) {
        return Padding(
          padding: EdgeInsets.only(right: i < digitCount - 1 ? barSpacing : 0),
          child: Container(
            width: barWidth,
            height: barHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        );
      }),
    );
  }
}

class AmountView extends StatelessWidget {
  const AmountView(
    this.value, {
    super.key,
    this.style,
    this.maskColor,
    this.maskWidth,
    this.maskHeight,
    this.maskSpacing,
    this.maskRadius,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final double value;
  final TextStyle? style;
  final Color? maskColor;
  final double? maskWidth;
  final double? maskHeight;
  final double? maskSpacing;
  final double? maskRadius;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  int _digitCount() {
    final formatted = Formatters.rawCurrency(value);
    return formatted.replaceAll(RegExp(r'[^\d]'), '').length;
  }

  @override
  Widget build(BuildContext context) {
    if (AmountVisibilityController.isVisible) {
      return Text(
        Formatters.currency(value),
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }
    return AmountMask(
      digitCount: _digitCount(),
      barColor: maskColor ?? style?.color,
      barWidth: maskWidth ?? 6,
      barHeight: maskHeight ?? 18,
      barSpacing: maskSpacing ?? 3,
      borderRadius: maskRadius ?? 0,
    );
  }
}
