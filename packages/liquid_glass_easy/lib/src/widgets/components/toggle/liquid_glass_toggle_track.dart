import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'liquid_glass_toggle_layout.dart';

/// Solid white pill — the at-rest toggle thumb.
class SolidWhiteToggleThumb extends StatelessWidget {
  final double width;
  final double height;

  const SolidWhiteToggleThumb({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints the toggle track body as ONE filled path: a full-height
/// capsule whose middle is pinched to a thinner pill (where the glass
/// thumb sits). The pinch is built by cutting a pill-shaped hole at the
/// glass position and unioning a thinner pill back into its middle. Doing
/// it in a single fill — instead of stacking a capsule and a separate
/// "fake pill" — keeps a uniform alpha, so a translucent track color
/// never doubles up into a darker band.
class ToggleBodyPainter extends CustomPainter {
  final Color color;
  final double radius;
  final bool animating;
  final double holeCenterX;
  final double holeWidth;
  final double holeHeight;
  final double pinchHeight;

  ToggleBodyPainter({
    required this.color,
    required this.radius,
    required this.animating,
    required this.holeCenterX,
    required this.holeWidth,
    required this.holeHeight,
    required this.pinchHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;

    final capsule = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(radius),
      ));

    Path body = capsule;
    if (animating && holeWidth > 0.001 && holeHeight > 0.001) {
      final hole = Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(holeCenterX, size.height / 2),
            width: holeWidth,
            height: holeHeight,
          ),
          Radius.circular(holeHeight / 2),
        ));
      // Thinner pill spanning the full width so its rounded ends line up
      // with the body; outside the hole it's a no-op (already inside the
      // capsule), inside the hole it forms the pinched waist.
      final pill = Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: size.width,
            height: pinchHeight,
          ),
          Radius.circular(pinchHeight / 2),
        ));
      body = Path.combine(
        PathOperation.union,
        Path.combine(PathOperation.difference, capsule, hole),
        pill,
      );
    }

    canvas.drawPath(body, paint);
  }

  @override
  bool shouldRepaint(covariant ToggleBodyPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.animating != animating ||
      old.holeCenterX != holeCenterX ||
      old.holeWidth != holeWidth ||
      old.holeHeight != holeHeight ||
      old.pinchHeight != pinchHeight;
}

/// Stateless toggle track: capsule background that tints from a
/// gray (off) to a solid color (on), with a static white pill
/// thumb drawn inline. Place inside the INNER `LiquidGlassView`'s
/// `backgroundWidget` so the moving glass thumb (built with
/// [buildLiquidGlassToggleThumb]) can refract it.
///
/// While [pinchFraction] > 0, a pill-shaped hole is cut out of
/// the colored capsule at the glass's x position (driven by
/// [travelFraction]) and a separate, shorter "fake" pill is drawn
/// inside the hole. The glass thumb hides the cut edges entirely,
/// so the user sees: full-height capsule on the sides, plus a
/// thinner pill behind the glass.
class LiquidGlassToggleTrack extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final LiquidGlassToggleLayout layout;

  /// `0` at rest (no hole, plain capsule), `1` at the peak of the
  /// slide (max-size hole + shortest fake pill).
  final double pinchFraction;

  /// `0` when off and `1` when on. Drives where the hole + fake
  /// pill sit along the track. Pass the same value used for the
  /// glass thumb's [buildLiquidGlassToggleThumb] `travelFraction`.
  final double travelFraction;

  /// Tint color of the track when [value] is true. Defaults to a
  /// system green.
  final Color tint;

  /// Background color of the track when [value] is false. Defaults
  /// to a translucent gray that reads well over a glass canvas.
  final Color offColor;

  /// Show/hide the rest thumb (the static white pill). Hide while
  /// the glass lens is taking its place during the slide.
  final bool showRestThumb;

  const LiquidGlassToggleTrack({
    super.key,
    required this.value,
    required this.onChanged,
    this.tint = const Color(0xFF34C759),
    this.offColor = const Color(0x66808080),
    this.layout = const LiquidGlassToggleLayout(),
    this.showRestThumb = true,
    this.pinchFraction = 0,
    this.travelFraction = 0,
  });

  @override
  Widget build(BuildContext context) {
    final p = pinchFraction.clamp(0.0, 1.0);
    final isAnimating = p > 0.001;

    // Hole geometry — matched to the ACTUAL glass-pill footprint (same
    // formula as buildLiquidGlassToggleThumb), so the track body behind
    // the glass is removed across the full pill, not just a narrow
    // center. Inset by a 1.5px hair on every side so the cut edge tucks
    // just under the glass overhang and never shows a seam. The fake
    // (thinner) pinch pill is still unioned back in below.
    const edgeInset = 1.5;
    final pillW = layout.thumbWidth + layout.thumbExtraWidth * p;
    final pillH = pillW * (layout.thumbHeight / layout.thumbWidth);
    final holeWidth = math.max(0.0, pillW - edgeInset * 2);
    final holeHeight = math.max(0.0, pillH - edgeInset * 2);

    // Center of the hole at this travel fraction. Mirrors the math
    // used by buildLiquidGlassToggleThumb so the hole tracks the
    // glass.
    final holeCenterX = layout.padding +
        travelFraction * layout.travel +
        layout.thumbWidth / 2;

    // Height of the thinner pill running through the pinched middle.
    final pinchHeight =
        layout.height + (layout.pinchedHeight - layout.height) * p;

    // Rest thumb position (white pill at on/off endpoints). Always
    // computed against the rest layout so its on/off positions
    // don't shift while the track changes.
    final thumbLeft =
        layout.padding + (value ? layout.travel : 0.0);
    final thumbTop = (layout.height - layout.thumbHeight) / 2;

    return SizedBox(
      width: layout.width,
      height: layout.height,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // The whole track body — a full-height capsule whose middle
            // is pinched to a thinner pill under the glass — painted as a
            // SINGLE filled path. One layer means one alpha everywhere, so
            // a translucent track color can't double up into a darker band
            // the way the old capsule + separate "fake pill" did.
            Positioned.fill(
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: value ? tint : offColor),
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                builder: (context, animatedColor, _) => CustomPaint(
                  painter: ToggleBodyPainter(
                    color: animatedColor ?? (value ? tint : offColor),
                    radius: layout.height / 2,
                    animating: isAnimating,
                    holeCenterX: holeCenterX,
                    holeWidth: holeWidth,
                    holeHeight: holeHeight,
                    pinchHeight: pinchHeight,
                  ),
                ),
              ),
            ),
            // Static white pill thumb. Anchored to the REST rect.
            // Hidden during the slide; the glass takes over.
            if (showRestThumb)
              Positioned(
                left: thumbLeft,
                top: thumbTop,
                child: SolidWhiteToggleThumb(
                  width: layout.thumbWidth,
                  height: layout.thumbHeight,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
