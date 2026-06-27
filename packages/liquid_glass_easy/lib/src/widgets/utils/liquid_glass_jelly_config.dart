/// How a [LiquidGlassJelly] (and, going forward, the slider thumb and
/// nav-bar pill) deforms as its driving value moves.
enum LiquidGlassJellyStyle {
  /// Original model: fast motion → the glass squeezes **narrower** along
  /// the motion axis and extrudes **taller** in the cross axis, leaning
  /// slightly into the motion ("pinch & extrude").
  pinchExtrude,

  /// iOS-26-style squash & stretch with inertial recoil. While moving
  /// fast the glass **elongates along the motion axis** and flattens
  /// (volume preservation). On stop/reversal the spring overshoots
  /// through neutral and the deformation rebounds into the cross axis —
  /// squashes along, pops across — then wobbles to rest.
  squashStretch,
}

/// Unified tuning for the liquid-glass "jelly" deformation: the spring
/// physics plus the squash/stretch amounts.
///
/// This is the single config shared by the reusable [LiquidGlassJelly]
/// widget. It supersedes the per-component `LiquidGlassSliderJelly` /
/// `LiquidGlassPillJelly` descriptors (same fields, plus the
/// [velocityClamp] knob the slider previously kept internal).
///
/// The defaults reproduce the slider's shipped feel
/// ([LiquidGlassJellyStyle.pinchExtrude] with the historical spring
/// constants), tuned for a driving value in the `0..1` range. If your
/// driving value has a different scale (e.g. a tab index `0..N`), raise
/// [maxVelocity] to match.
class LiquidGlassJellyConfig {
  /// Which deformation model to use.
  final LiquidGlassJellyStyle style;

  /// Spring stiffness for the jelly spring.
  final double stiffness;

  /// Spring damping. Lower → more visible overshoot wobble on release.
  final double damping;

  /// Driving-value velocity (in value-units/second) that maps to full
  /// spring load (|target| = 1). Lower → reacts to gentler motion.
  final double maxVelocity;

  /// Hard clamp on the raw input velocity before normalization, in
  /// value-units/second. Guards against absurd spikes from a near-zero
  /// `dt` between value updates.
  final double velocityClamp;

  /// Extra length (px) gained along the motion axis at full spring load.
  /// In [LiquidGlassJellyStyle.pinchExtrude] this is the amount the glass
  /// squeezes narrower; in [LiquidGlassJellyStyle.squashStretch] it is the
  /// amount it elongates.
  final double stretchWidth;

  /// Cross-axis size change (px) at full spring load — the
  /// volume-preserving counter-deformation that accompanies
  /// [stretchWidth].
  final double squashHeight;

  /// `stretch` style only: where the elongation is anchored, `-1..1`.
  /// `-1` → the leading edge stays pinned and the stretch trails behind;
  /// `0` → symmetric; `1` → the stretch leads ahead of the motion.
  final double anchorBias;

  /// `stretch` style only: how exaggerated the squash recoil is on a
  /// stop/reversal. `0` disables recoil; `1` is symmetric with the
  /// moving stretch; above `1` makes the cross-axis pop more pronounced.
  final double recoilScale;

  /// `stretch` style only: where the recoil squash is anchored, `0..1`.
  /// `0` → squashes symmetrically around center; `1` → the leading edge
  /// stays pinned and the whole compression piles into the trailing
  /// side (a crumple-zone effect).
  final double recoilAnchor;

  /// `stretch` style only: time constant (seconds) of the jelly's
  /// **direction memory**. Larger → longer, more dramatic reversal
  /// squash; smaller → snappier re-alignment.
  final double directionTau;

  const LiquidGlassJellyConfig({
    this.style = LiquidGlassJellyStyle.pinchExtrude,
    this.stiffness = 320,
    this.damping = 22,
    this.maxVelocity = 1.5,
    this.velocityClamp = 12,
    this.stretchWidth = 14,
    this.squashHeight = 5,
    this.anchorBias = -0.6,
    this.recoilScale = 1.5,
    this.recoilAnchor = 1.0,
    this.directionTau = 0.12,
  });

  LiquidGlassJellyConfig copyWith({
    LiquidGlassJellyStyle? style,
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
    return LiquidGlassJellyConfig(
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
