/// How the glass thumb deforms while being dragged.
enum LiquidGlassSliderJellyStyle {
  /// Original model: fast drag → the pill squeezes **narrower** and
  /// extends **taller** ("pinch & extrude"), leaning slightly into the
  /// motion.
  pinchExtrude,

  /// iOS-26-style squash & stretch with inertial recoil. While moving
  /// fast the pill **elongates along the drag axis** and flattens
  /// slightly (volume preservation). When the drag stops (or reverses),
  /// the spring overshoots through neutral and the deformation rebounds
  /// into the **opposite axis** — the pill squashes horizontally and
  /// pops taller — then wobbles back to rest.
  stretch,
}

/// Tunable parameters for the slider thumb's jelly deformation.
///
/// The defaults reproduce the original shipped feel exactly
/// ([LiquidGlassSliderJellyStyle.pinchExtrude] with the historical
/// spring constants). Pass a custom instance to experiment — the
/// `stretch` style is the iOS-like alternative.
class LiquidGlassSliderJelly {
  /// Which deformation model to use.
  final LiquidGlassSliderJellyStyle style;

  /// Spring stiffness for the jelly spring.
  final double stiffness;

  /// Spring damping. Lower → more visible overshoot wobble on release.
  final double damping;

  /// Drag velocity (in value-units/second) that maps to full spring
  /// load (|target| = 1). Lower → the jelly reacts to gentler drags.
  final double maxVelocity;

  /// `stretch` style only: extra width (px) gained along the drag axis
  /// at full spring load.
  final double stretchWidth;

  /// `stretch` style only: height (px) lost at full spring load —
  /// the volume-preserving flatten that accompanies the elongation.
  final double squashHeight;

  /// `stretch` style only: where the elongation is anchored, `-1..1`.
  /// `-1` → the leading edge stays pinned at the finger and all the
  /// stretch trails behind it; `0` → symmetric; `1` → the stretch
  /// leads ahead of the finger.
  final double anchorBias;

  /// `stretch` style only: how exaggerated the squash recoil is. On a
  /// stop or direction reversal the deformation goes negative and the
  /// pill rebounds narrower + taller; that rebound's amplitude is
  /// multiplied by this. `0` disables the recoil entirely; `1` is
  /// physically symmetric with the moving stretch; above `1` makes the
  /// vertical pop more pronounced than the horizontal stretch.
  final double recoilScale;

  /// `stretch` style only: where the recoil squash is anchored, `0..1`.
  /// `0` → the pill squashes symmetrically around its center. `1` → the
  /// **leading edge stays pinned** and the entire compression is
  /// absorbed by the trailing side — the side the momentum pushes from
  /// piles into the front, like a crumple zone. (Moving left → the
  /// right half compresses.)
  final double recoilAnchor;

  /// `stretch` style only: time constant (seconds) of the jelly's
  /// **direction memory**. The deform target is the drag velocity
  /// projected onto a smoothed direction — so on a sudden reversal the
  /// velocity opposes the remembered direction and the target swings
  /// hard negative (squash + vertical stretch) until the memory adapts
  /// to the new direction over roughly this time. Larger → longer,
  /// more dramatic reversal squash; smaller → snappier re-alignment.
  final double directionTau;

  const LiquidGlassSliderJelly({
    this.style = LiquidGlassSliderJellyStyle.pinchExtrude,
    this.stiffness = 320,
    this.damping = 22,
    this.maxVelocity = 1.5,
    this.stretchWidth = 14,
    this.squashHeight = 5,
    this.anchorBias = -0.6,
    this.recoilScale = 1.5,
    this.recoilAnchor = 1.0,
    this.directionTau = 0.12,
  });
}
