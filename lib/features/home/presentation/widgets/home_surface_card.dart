import 'package:flutter/material.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';

class HomeSurfaceCard extends StatelessWidget {
  const HomeSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AppRadii.card,
    this.backgroundColor,
    this.borderColor,
    this.topAccent,
    this.margin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? topAccent;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = backgroundColor ?? context.surface;
    final lineColor = borderColor ?? context.border;

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border.all(color: lineColor),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
          if (topAccent != null)
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: Container(height: 3, color: topAccent),
            ),
          Padding(
            padding: EdgeInsets.only(top: topAccent == null ? 0 : 6),
            child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
          ),
        ],
      ),
    );

    final wrapped = onTap == null
        ? card
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              child: card,
            ),
          );

    if (margin == null) return wrapped;
    return Padding(padding: margin!, child: wrapped);
  }
}
