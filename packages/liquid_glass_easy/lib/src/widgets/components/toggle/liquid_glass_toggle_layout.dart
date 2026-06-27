/// Layout for [LiquidGlassToggleTrack] /
/// [buildLiquidGlassToggleThumb].
///
/// At rest the thumb is a solid **white** horizontal pill sitting
/// inside a tinted track (gray when off, green when on).
///
/// During a slide, the white pill is replaced by a liquid-glass
/// pill that grows larger than the toggle track. The slice of the
/// colored track *behind* the glass simultaneously **pinches** to a
/// shorter height — the rest of the track stays at full height.
/// The glass then refracts whatever sits above and below the
/// pinched slice (typically the wallpaper).
class LiquidGlassToggleLayout {
  final double width;
  final double height;
  final double padding;

  /// Width of the static rest thumb pill. Should be wider than
  /// [thumbHeight] for the pill look.
  final double thumbWidth;

  /// Height of the static rest thumb pill.
  final double thumbHeight;

  /// Extra width the GLASS thumb gains at the peak of the slide
  /// relative to [thumbWidth]. Also drives the WIDTH of the
  /// pinched slice in the colored track.
  final double thumbExtraWidth;

  /// Extra height the GLASS thumb gains at the peak of the slide
  /// relative to [thumbHeight].
  final double thumbExtraHeight;

  /// Height of the pinched slice at the peak of the slide. Make
  /// this noticeably less than [height] so the pinch is visible.
  final double pinchedHeight;

  const LiquidGlassToggleLayout({
    this.width = 64,
    this.height = 32,
    this.padding = 2.5,
    this.thumbWidth = 36,
    this.thumbHeight = 27,
    this.thumbExtraWidth = 28,
    this.thumbExtraHeight = 18,
    this.pinchedHeight = 20,
  });

  /// Travel along the track between off and on positions.
  double get travel => width - thumbWidth - padding * 2;
}
