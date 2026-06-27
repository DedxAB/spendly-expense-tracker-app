import 'dart:math' as math;

import 'liquid_glass_jelly_config.dart';

/// Signed deformation produced by [resolveJellyDeformation]: size deltas
/// (logical px) along and across the motion axis, plus a center shift
/// along it.
class LiquidGlassJellyDeform {
  /// Size delta along the motion axis (negative = squeeze / shorter).
  final double along;

  /// Size delta across the motion axis.
  final double cross;

  /// Center shift along the motion axis (the directional lean / crumple).
  final double bias;

  const LiquidGlassJellyDeform(this.along, this.cross, this.bias);

  static const LiquidGlassJellyDeform zero = LiquidGlassJellyDeform(0, 0, 0);
}

/// The **single source of truth** mapping a jelly spring's output to
/// geometry. Shared by [LiquidGlassJelly], the slider thumb, and the
/// nav-bar pill so the squash/stretch math lives in exactly one place.
///
/// [springValue] is the pre-selected spring output for the [style]:
/// the *stretch* spring for [LiquidGlassJellyStyle.pinchExtrude], the
/// *deform* spring for [LiquidGlassJellyStyle.squashStretch]. [directionSign]
/// (`±1`) is the smoothed motion direction, used only by the `stretch`
/// lean.
///
/// [alongAmount] / [crossAmount] are the deformation magnitudes (px) at
/// full spring load; each consumer supplies its own (the slider/nav pull
/// theirs from their layout, the widget from its config). [alongFloor] /
/// [crossFloor] are the negative clamps that stop the shape inverting
/// under extreme settings.
LiquidGlassJellyDeform resolveJellyDeformation({
  required LiquidGlassJellyStyle style,
  required double springValue,
  required double directionSign,
  required double alongAmount,
  required double crossAmount,
  required double anchorBias,
  required double recoilScale,
  required double recoilAnchor,
  required double alongFloor,
  required double crossFloor,
}) {
  final double s = springValue.clamp(-1.5, 1.5);

  if (style == LiquidGlassJellyStyle.pinchExtrude) {
    // Squeeze narrower along the motion, extrude across it, lean into it.
    final double sMag = s.abs();
    final double sSign = s.isNegative ? -1.0 : 1.0;
    final double along = math.max(-alongAmount * sMag, alongFloor);
    final double cross = crossAmount * sMag;
    final double bias = alongAmount * 0.6 * sMag * sSign;
    return LiquidGlassJellyDeform(along, cross, bias);
  }

  // stretch: elongate along the axis while moving; on stop/reversal the
  // deform spring overshoots negative → squash + cross-axis pop, scaled
  // by recoilScale and anchored to the trailing side by recoilAnchor.
  final double d = s >= 0 ? s : s * recoilScale;
  final double along = math.max(alongAmount * d, alongFloor);
  final double cross = math.max(-crossAmount * d, crossFloor);
  final double leanBias =
      anchorBias * (math.max(along, 0.0) / 2) * directionSign;
  final double squashShift =
      along < 0 ? recoilAnchor * (-along / 2) * directionSign : 0.0;
  return LiquidGlassJellyDeform(along, cross, leanBias + squashShift);
}
