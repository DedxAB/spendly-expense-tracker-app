import 'package:flutter/material.dart';

import '../../liquid_glass.dart';
import '../../liquid_glass_style.dart';
import '../liquid_glass_morph_pill.dart';
import 'liquid_glass_toggle_layout.dart';

/// Build the moving glass thumb. [travelFraction] is `0` when off
/// and `1` when on; the parent should drive it via an
/// `AnimationController` running between those two values during
/// the slide.
///
/// [growFraction] is `0` at rest and `1` at the peak of the
/// animation. Drive it with a `sin(π·t)` envelope (see
/// [liquidGlassMorphEnvelope]) so the glass pill grows OUT of the
/// rest pill, peaks bigger than the whole track mid-slide, then
/// shrinks back to the rest size at the destination.
///
/// [trackLeft] / [trackBottom] are the track's bottom-left corner
/// in the outer view's local coordinate space.
LiquidGlass buildLiquidGlassToggleThumb({
  required LiquidGlassToggleLayout layout,
  required double trackLeft,
  required double trackBottom,
  required double travelFraction,
  required double growFraction,

  /// Glass look of the thumb pill. When null the tuned default capsule
  /// glass is used; see [buildLiquidGlassMorphPill].
  LiquidGlassStyle? style,

  /// Optional content rendered inside the lens, above the glass (e.g.
  /// the white rest handle + its gesture surface).
  Widget? child,
}) {
  final f = growFraction.clamp(0.0, 1.0);
  final extraW = layout.thumbExtraWidth * f;
  final pillW = layout.thumbWidth + extraW;
  // Lock the glass pill to the SAME aspect ratio as the rest handle, so
  // as it grows it stays a uniformly-scaled copy of the white pill
  // instead of becoming more elongated. Height is derived from width
  // via the handle's ratio (thumbExtraHeight no longer drives it).
  final pillH = pillW * (layout.thumbHeight / layout.thumbWidth);

  // Center of the rest thumb at this travel fraction, in track-
  // local coordinates. We anchor the GROWN pill on the same center
  // point so it expands evenly outward as it bulges, then settles
  // back.
  final restCenterXInTrack =
      layout.padding + travelFraction * layout.travel + layout.thumbWidth / 2;
  final restCenterYInTrack = layout.height / 2;

  final left = trackLeft + restCenterXInTrack - pillW / 2;
  final bottomFromTrackBottom =
      layout.height - restCenterYInTrack - pillH / 2;
  final bottom = trackBottom + bottomFromTrackBottom;

  final spec = LiquidGlassMorphPillSpec(
    width: pillW,
    restHeight: pillH,
    extraHeight: 0,
    restRadius: pillH / 2,
  );

  return buildLiquidGlassMorphPill(
    spec: spec,
    left: left,
    bottom: bottom,
    extraHeight: 0,
    style: style,
    child: child,
  );
}
