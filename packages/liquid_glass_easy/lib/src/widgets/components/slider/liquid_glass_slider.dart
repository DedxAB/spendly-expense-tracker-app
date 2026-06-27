import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../controllers/liquid_glass_view_controller.dart';
import '../../liquid_glass_style.dart';
import '../../liquid_glass_view.dart';
import '../../utils/liquid_glass_jelly_config.dart';
import '../../utils/liquid_glass_jelly_spring.dart';
import 'liquid_glass_slider_layout.dart';
import 'liquid_glass_slider_thumb.dart';
import 'liquid_glass_slider_track.dart';

export 'liquid_glass_slider_layout.dart';
export 'liquid_glass_slider_thumb.dart';
export 'liquid_glass_slider_track.dart';

/// A drop-in liquid-glass slider.
///
/// This is the **developer-facing** component: it owns its own
/// [LiquidGlassView], the track ([LiquidGlassSliderTrack]), the moving
/// glass thumb ([buildLiquidGlassSliderThumb]) and all the interaction
/// animation (grow-on-press + the signed "jelly" spring that leans the
/// thumb in the drag direction) — so you just give it a [value] in
/// `0..1` and an [onChanged] like a regular `Slider`.
///
/// At rest it shows a solid white pill on the track. While the user
/// drags, the pill is replaced by a liquid-glass pill that grows, leans
/// into the motion, and refracts the track underneath.
///
/// ```dart
/// LiquidGlassSlider(
///   value: _v,
///   onChanged: (v) => setState(() => _v = v),
///   activeColor: Colors.white,
/// )
/// ```
///
/// The glass thumb overhangs the track; the shader honors the captured
/// texel's alpha (always on), so the overhang renders as transparent
/// passthrough instead of a black blob.
class LiquidGlassSlider extends StatefulWidget {
  /// Current value, in `0..1`.
  final double value;

  /// Called continuously with the new value while the user drags.
  final ValueChanged<double> onChanged;

  /// Called when a drag (or tap) begins.
  final ValueChanged<double>? onChangeStart;

  /// Called when the drag ends.
  final ValueChanged<double>? onChangeEnd;

  /// Color of the filled (left) portion of the track.
  final Color activeColor;

  /// Color of the unfilled track background.
  final Color inactiveColor;

  /// Track + thumb geometry. Defaults to a 280-wide track.
  final LiquidGlassSliderLayout layout;

  /// Glass look of the moving thumb (shape + appearance + refraction),
  /// the same [LiquidGlassStyle] vocabulary used across the library. When
  /// null, the tuned default capsule glass is used. A null
  /// [LiquidGlassStyle.shape] keeps the height-tracking capsule so the
  /// thumb stays a clean pill as it grows/jellies during a drag.
  final LiquidGlassStyle? style;

  /// Capture resolution for the inner view. `1.0` is a good default; use
  /// less for cheaper captures, `0.0` for the device pixel ratio.
  final double pixelRatio;

  /// Jelly deformation tuning for the moving thumb. The slider is
  /// **locked to the iOS [LiquidGlassJellyStyle.squashStretch]** squash &
  /// stretch model (on-device-tuned) — any [LiquidGlassJellyConfig.style]
  /// you pass is ignored and normalized to `squashStretch`. The original
  /// `pinchExtrude` model is kept internally (it still drives
  /// [LiquidGlassJelly]) but is no longer selectable here. All the other
  /// fields — springs, stretch/squash amounts, anchors — are honored.
  final LiquidGlassJellyConfig jelly;

  const LiquidGlassSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0x3CFFFFFF),
    this.layout = const LiquidGlassSliderLayout(),
    this.style,
    this.pixelRatio = 1.0,
    this.jelly = const LiquidGlassJellyConfig(
      style: LiquidGlassJellyStyle.squashStretch,
      stiffness: 230,
      damping: 12,
      maxVelocity: 2.9,
      stretchWidth: 8.8,
      squashHeight: 8.0,
      anchorBias: -1.0,
      recoilScale: 3.0,
      recoilAnchor: 1.0,
      directionTau: 0.42,
    ),
  });

  @override
  State<LiquidGlassSlider> createState() => _LiquidGlassSliderState();
}

class _LiquidGlassSliderState extends State<LiquidGlassSlider>
    with TickerProviderStateMixin {
  final LiquidGlassViewController _viewController = LiquidGlassViewController();

  /// Grow envelope: ramps 0→1 on touch-down, holds while dragging,
  /// reverses to 0 on release.
  late final AnimationController _grow;

  bool _dragging = false;

  /// The shared jelly simulation (lean spring + deform spring +
  /// direction memory). The slider feeds it drag values and maps its
  /// outputs onto the thumb geometry in [buildLiquidGlassSliderThumb].
  final LiquidGlassJellySpring _jelly = LiquidGlassJellySpring();

  /// The slider is locked to the iOS jelly (squash & stretch) model.
  /// Whatever [LiquidGlassJellyConfig.style] the caller supplies is
  /// normalized to [LiquidGlassJellyStyle.squashStretch]; the internal
  /// `pinchExtrude` path is kept for [LiquidGlassJelly] but is not
  /// reachable through the slider.
  LiquidGlassJellyConfig get _effectiveJelly =>
      widget.jelly.style == LiquidGlassJellyStyle.squashStretch
          ? widget.jelly
          : widget.jelly.copyWith(style: LiquidGlassJellyStyle.squashStretch);

  /// Last ticker `elapsed`, used as the spring integrator's `dt`.
  Duration? _jellyTickerLast;
  Ticker? _jellyTicker;

  /// Geometry stashed by [build] so the thumb-child gesture surface can
  /// map a global pointer position to a 0..1 value (same math as the
  /// track's own hit handling).
  double _gesturePadX = 0;
  double _gestureInnerWidth = 1;

  /// Maps a global pointer position to a slider value and reports it.
  void _handleGlobalDrag(Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(globalPosition);
    final clamped =
        ((local.dx - _gesturePadX) / _gestureInnerWidth).clamp(0.0, 1.0);
    _onChanged(clamped);
  }

  @override
  void initState() {
    super.initState();
    _grow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _grow.addListener(() => setState(() {}));
    _syncJellyConfig();
    _jelly.start(widget.value);
    _jellyTicker = createTicker(_onJellyTick);
    // TEMP test: run the capture pipeline from startup instead of
    // starting it on the first grab, to check whether the cold capture
    // start is the first-touch stall.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _viewController.startRealtimeCapture();
    });
  }

  @override
  void dispose() {
    _jellyTicker?.dispose();
    _grow.dispose();
    super.dispose();
  }

  /// Pushes the widget's physics tuning into the shared simulation.
  /// Called every tick so a live change to [LiquidGlassSlider.jelly]
  /// applies immediately, matching the old inline behavior.
  void _syncJellyConfig() {
    _jelly
      ..stiffness = widget.jelly.stiffness
      ..damping = widget.jelly.damping
      ..maxVelocity = widget.jelly.maxVelocity
      ..velocityClamp = widget.jelly.velocityClamp
      ..directionTau = widget.jelly.directionTau;
  }

  void _onStart(double v) {
    _dragging = true;
    _viewController.startRealtimeCapture();
    _grow
      ..stop()
      ..forward(from: _grow.value);
    _syncJellyConfig();
    _jelly.start(widget.value);
    _jellyTickerLast = null;
    _jellyTicker?.start();
    widget.onChangeStart?.call(v);
  }

  void _onChanged(double v) {
    widget.onChanged(v);
    _jelly.pump(v);
  }

  void _onEnd(double v) {
    _dragging = false;
    _grow.reverse(from: _grow.value);
    _jelly.release(); // spring momentum carries the overshoot
    widget.onChangeEnd?.call(v);
  }

  void _onJellyTick(Duration elapsed) {
    final last = _jellyTickerLast ?? elapsed;
    final dt = (elapsed - last).inMicroseconds / 1e6;
    _jellyTickerLast = elapsed;

    _syncJellyConfig();
    final settled = _jelly.tick(dt, dragging: _dragging);
    if (settled) _jellyTicker?.stop();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final layout = widget.layout;
    final bool glassActive = _dragging || _grow.isAnimating;

    // Padding so the grown AND jelly-deformed thumb is always fully
    // inside the inner view — so it is never clipped at the ends, and
    // its position never hits the clamp (which would pin it before the
    // end and drift on release). The jelly spring output is clamped to
    // +/-1.5 inside the thumb builder, so use that as the peak.
    const jellyPeak = 1.5;
    // Horizontal: exactly half the (grown) pill width — the pill sits
    // centered on the track end and overhangs it by half its width. This is
    // intentionally **independent of `stretchWidth`**: raising the jelly's
    // stretch must not shrink the visible track. The stretch elongation
    // then lives inside this overhang room (and, at the extreme ends with a
    // very large stretch, may briefly reach the view edge).
    final jelly = _effectiveJelly;
    final maxPillW = layout.thumbWidth + layout.thumbExtraWidth;
    final padX = maxPillW / 2;
    // Vertical: half of the (grown + stretched) pill beyond the track.
    // The stretch style gains height during the stop-recoil
    // (squashHeight × recoilScale at peak spring overshoot) instead of
    // the pinch style's thumbStretchHeight.
    final jellyHeightGain = jelly.style == LiquidGlassJellyStyle.squashStretch
        ? jelly.squashHeight * jelly.recoilScale * jellyPeak
        : layout.thumbStretchHeight * jellyPeak;
    final maxPillH =
        layout.thumbHeight + layout.thumbExtraHeight + jellyHeightGain;
    final padY = math.max(0.0, (maxPillH - layout.thumbHeight) / 2) + 2.0;

    // Inset the track INSIDE the requested width instead of widening the
    // widget. The widget stays exactly `layout.width` wide; the visible
    // track is narrowed by padX on each side (and stays centered), so
    // the thumb's horizontal overhang lives inside that width — no shift,
    // no extra width. Height still grows by padY to fit the taller
    // (grown) thumb vertically.
    final innerLayout = LiquidGlassSliderLayout(
      width: math.max(0.0, layout.width - padX * 2),
      trackHeight: layout.trackHeight,
      thumbWidth: layout.thumbWidth,
      thumbHeight: layout.thumbHeight,
      thumbExtraWidth: layout.thumbExtraWidth,
      thumbExtraHeight: layout.thumbExtraHeight,
      thumbSqueezeWidth: layout.thumbSqueezeWidth,
      thumbStretchHeight: layout.thumbStretchHeight,
    );
    final viewWidth = layout.width;
    final viewHeight = layout.thumbHeight + padY * 2;

    _gesturePadX = padX;
    _gestureInnerWidth = math.max(1.0, innerLayout.width);

    return SizedBox(
      width: viewWidth,
      height: viewHeight,
      child: LiquidGlassView.withPositionedLenses(
        controller: _viewController,
        // The track is captured with authored transparency; honor it on
        // Skia so the glass thumb shows the real screen through the track.
        honorBackdropAlpha: true,
        pixelRatio: widget.pixelRatio,
        realTimeCapture: true,
        useSync: true,
        backgroundWidget: Stack(
          children: [
            Positioned(
              // Span the full view width: the track's visible body is
              // re-centered inside via hitSlopX, while the gesture area
              // now reaches the very ends, so the thumb's half-overhang
              // at value 0 and 1 (which lives in padX) is tappable.
              left: 0,
              top: padY,
              child: LiquidGlassSliderTrack(
                value: widget.value,
                onChanged: _onChanged,
                onChangeStart: _onStart,
                onChangeEnd: _onEnd,
                // The white rest handle is rendered INSIDE the glass
                // lens (as its child) so it sits ON TOP of the glass
                // pill — never here in the background, which lenses
                // always cover.
                showRestThumb: false,
                activeColor: widget.activeColor,
                inactiveColor: widget.inactiveColor,
                layout: innerLayout,
                hitSlopX: padX,
              ),
            ),
          ],
        ),
        children: [
          // The glass thumb is ALWAYS mounted. At rest (growFraction 0,
          // springs at 0) it is exactly the size of the handle and sits
          // UNDER the white rest pill, which is rendered as the lens's
          // child — on top of the glass. On grab the white pill hides
          // and the glass (already rendered all along) grows and
          // jelly-deforms, so nothing new is created at first touch.
          // The child also carries the handle's gesture surface, since
          // the lens sits above the track and would otherwise block it.
          buildLiquidGlassSliderThumb(
            layout: innerLayout,
            trackLeft: padX,
            trackBottom: padY,
            value: widget.value,
            growFraction: _grow.value,
            // The stretch style is driven by the speed-based
            // deform spring (sign = stretch vs recoil); the pinch
            // style keeps the direction-signed spring.
            stretchFraction: jelly.style == LiquidGlassJellyStyle.squashStretch
                ? _jelly.deform
                : _jelly.stretch,
            // Smoothed direction memory: the lean follows it
            // continuously, flipping softly across a reversal.
            motionSign: _jelly.direction,
            jelly: jelly,
            style: widget.style,
            // Once the user lands on the thumb we want the slider to OWN
            // the gesture: grabbing the pill and moving vertically should
            // hold/adjust the slider, never scroll an ancestor list. A
            // plain GestureDetector loses that contest — the parent
            // Scrollable wins the arena on vertical motion and the drag is
            // cancelled (leaving the glass latched). So we use an eager
            // pan recognizer that claims the arena the instant a pointer
            // lands, beating any ancestor Scrollable. A pan (not
            // horizontal-only) recognizer also keeps the grab alive under
            // vertical movement; the value still tracks horizontal x only.
            child: RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: <Type, GestureRecognizerFactory>{
                _EagerPanGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                        _EagerPanGestureRecognizer>(
                  () => _EagerPanGestureRecognizer(debugOwner: this),
                  (instance) {
                    instance
                      // Fire onStart at touch-down (not after slop) so the
                      // glass grows the instant the thumb is grabbed.
                      ..dragStartBehavior = DragStartBehavior.down
                      ..onStart = (d) {
                        _onStart(widget.value);
                        _handleGlobalDrag(d.globalPosition);
                      }
                      ..onUpdate = (d) {
                        _handleGlobalDrag(d.globalPosition);
                      }
                      ..onEnd = (_) {
                        _onEnd(widget.value);
                      }
                      // Still revert cleanly if the gesture is ever
                      // cancelled for any other reason.
                      ..onCancel = () {
                        _onEnd(widget.value);
                      };
                  },
                ),
              },
              // White rest handle, drawn over the glass. Hidden (but
              // still hit-testable) while the glass is active.
              child: glassActive
                  ? const SizedBox.expand()
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          innerLayout.thumbHeight / 2,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A [PanGestureRecognizer] that wins the gesture arena the instant a
/// pointer lands on it, instead of waiting to accumulate drag slop.
///
/// This is what lets the slider thumb beat an ancestor [Scrollable]:
/// normally both join the arena and the scrollable wins as soon as the
/// finger moves vertically, stealing the drag. By resolving
/// [GestureDisposition.accepted] in [addAllowedPointer], the thumb claims
/// the pointer immediately — so once you grab the pill, moving in any
/// direction keeps controlling the slider and the page never scrolls.
class _EagerPanGestureRecognizer extends PanGestureRecognizer {
  _EagerPanGestureRecognizer({super.debugOwner});

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}
