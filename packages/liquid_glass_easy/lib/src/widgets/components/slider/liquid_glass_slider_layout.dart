/// Public layout for [LiquidGlassSliderTrack] /
/// [buildLiquidGlassSliderThumb].
///
/// At rest the slider thumb is a solid **white** pill sitting in
/// the track. While the user holds the thumb the white pill is
/// hidden and a slightly larger liquid-glass pill takes its place
/// (built via [buildLiquidGlassSliderThumb] and placed in the
/// OUTER `LiquidGlassView`'s `children:` list).
class LiquidGlassSliderLayout {
  /// Width of the slider track in logical pixels.
  final double width;

  /// Height of the track (background + filled portion).
  final double trackHeight;

  /// Width of the static rest thumb pill.
  final double thumbWidth;

  /// Height of the static rest thumb pill.
  final double thumbHeight;

  /// Extra width the GLASS thumb gains while held (relative to
  /// [thumbWidth]).
  final double thumbExtraWidth;

  /// Extra height the GLASS thumb gains while held (relative to
  /// [thumbHeight]).
  final double thumbExtraHeight;

  /// How much **narrower** the glass thumb gets at peak drag
  /// velocity — the jelly squeezes inward along the direction of
  /// motion as it's pulled. Should be small relative to
  /// [thumbWidth] so the pill never disappears.
  final double thumbSqueezeWidth;

  /// How much **taller** the glass thumb gets at peak drag
  /// velocity — the jelly extends vertically as the horizontal
  /// width squeezes, suggesting volume preservation.
  final double thumbStretchHeight;

  const LiquidGlassSliderLayout({
    this.width = 280,
    this.trackHeight = 8,
    this.thumbWidth = 35,
    this.thumbHeight = 23,
    this.thumbExtraWidth = 14,
    this.thumbExtraHeight = 10,
    this.thumbSqueezeWidth = 6,
    this.thumbStretchHeight = 10,
  });

  /// Pixel range over which the thumb's center can travel.
  double get travel => width;
}
