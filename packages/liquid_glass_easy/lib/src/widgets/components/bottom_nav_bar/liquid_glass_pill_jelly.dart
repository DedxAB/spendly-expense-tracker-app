/// How the moving glass nav-pill deforms while it travels between tabs
/// (on a tap) or is dragged by the finger.
///
/// This mirrors the slider thumb's jelly model
/// (`LiquidGlassSliderJellyStyle`) so the two components share one feel.
enum LiquidGlassPillJellyStyle {
  /// Original nav-pill model: while the deform spring is loaded the pill
  /// squeezes **narrower** and grows **taller**, leaning slightly into
  /// the motion. Only the spring constants ([LiquidGlassPillJelly.stiffness]
  /// / [LiquidGlassPillJelly.damping] / [LiquidGlassPillJelly.maxVelocity])
  /// affect it.
  pinchExtrude,

  /// iOS-26-style squash & stretch with inertial recoil. While moving
  /// fast the pill **elongates along the travel axis** and flattens
  /// slightly (volume preservation). When it stops (or reverses), the
  /// spring overshoots through neutral and the deformation rebounds into
  /// the opposite axis — the pill squashes horizontally and pops taller
  /// — then wobbles back to rest. Uses the full parameter set below.
  stretch,
}

/// Tunable parameters for the nav-pill's jelly deformation — the direct
/// analogue of `LiquidGlassSliderJelly`, retuned for the pill (whose
/// motion is measured in **tabs**, not 0..1 slider value).
///
/// The defaults reproduce the pill's original shipped feel
/// ([LiquidGlassPillJellyStyle.pinchExtrude]); switch to [stretch] for
/// the slider-style iOS squash & stretch.
class LiquidGlassPillJelly {
  /// Which deformation model to use.
  final LiquidGlassPillJellyStyle style;

  /// Spring stiffness for the deform spring.
  final double stiffness;

  /// Spring damping. Lower → more visible overshoot wobble on settle.
  final double damping;

  /// Pill speed (in **tabs/second**) that maps to full spring load
  /// (|target| = 1). Lower → the jelly reacts to gentler / slower
  /// travel.
  final double maxVelocity;

  /// Hard clamp on the raw input velocity before normalization
  /// (tabs/second). Guards against spikes from a near-zero `dt`.
  final double velocityClamp;

  /// `stretch` style only: extra width (px) gained along the travel axis
  /// at full spring load.
  final double stretchWidth;

  /// `stretch` style only: height (px) lost at full spring load — the
  /// volume-preserving flatten that accompanies the elongation.
  final double squashHeight;

  /// `stretch` style only: where the elongation is anchored, `-1..1`.
  /// `-1` → the leading edge stays pinned and the stretch trails behind;
  /// `0` → symmetric; `1` → the stretch leads ahead of the motion.
  final double anchorBias;

  /// `stretch` style only: how exaggerated the squash recoil is. On a
  /// stop or reversal the deformation goes negative and the pill rebounds
  /// narrower + taller; that rebound's amplitude is multiplied by this.
  /// `0` disables the recoil; `1` is symmetric with the moving stretch.
  final double recoilScale;

  /// `stretch` style only: where the recoil squash is anchored, `0..1`.
  /// `0` → squashes symmetrically around center; `1` → the leading edge
  /// stays pinned and the whole compression piles into the trailing side
  /// (a crumple zone).
  final double recoilAnchor;

  /// `stretch` style only: time constant (seconds) of the jelly's
  /// direction memory — how long a reversal keeps squashing before the
  /// memory re-aligns. Larger → longer, more dramatic reversal squash.
  final double directionTau;

  const LiquidGlassPillJelly({
    this.style = LiquidGlassPillJellyStyle.pinchExtrude,
    this.stiffness = 320,
    this.damping = 18,
    this.maxVelocity = 6,
    this.velocityClamp = 60,
    this.stretchWidth = 16,
    this.squashHeight = 6,
    this.anchorBias = -0.4,
    this.recoilScale = 1.5,
    this.recoilAnchor = 1.0,
    this.directionTau = 0.12,
  });

  LiquidGlassPillJelly copyWith({
    LiquidGlassPillJellyStyle? style,
    double? stiffness,
    double? damping,
    double? maxVelocity,
    double? velocityClamp,
    double? stretchWidth,
    double? squashHeight,
    double? anchorBias,
    double? recoilScale,
    double? recoilAnchor,
    double? directionTau,
  }) {
    return LiquidGlassPillJelly(
      style: style ?? this.style,
      stiffness: stiffness ?? this.stiffness,
      damping: damping ?? this.damping,
      maxVelocity: maxVelocity ?? this.maxVelocity,
      velocityClamp: velocityClamp ?? this.velocityClamp,
      stretchWidth: stretchWidth ?? this.stretchWidth,
      squashHeight: squashHeight ?? this.squashHeight,
      anchorBias: anchorBias ?? this.anchorBias,
      recoilScale: recoilScale ?? this.recoilScale,
      recoilAnchor: recoilAnchor ?? this.recoilAnchor,
      directionTau: directionTau ?? this.directionTau,
    );
  }
}
