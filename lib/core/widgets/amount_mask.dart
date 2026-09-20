import 'package:flutter/material.dart';
import 'package:spendly/core/utils/amount_visibility.dart';
import 'package:spendly/core/utils/formatters.dart';

class AmountView extends StatelessWidget {
  const AmountView(
    this.value, {
    super.key,
    this.style,
    this.maskColor,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final double value;
  final TextStyle? style;
  final Color? maskColor;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

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
    return Text(
      '◆ ◆ ◆',
      style: (style?.copyWith(color: maskColor)) ?? TextStyle(color: maskColor),
      textAlign: textAlign,
    );
  }
}
