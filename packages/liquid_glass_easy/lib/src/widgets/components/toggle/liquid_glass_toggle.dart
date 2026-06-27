import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../controllers/liquid_glass_view_controller.dart';
import '../../liquid_glass_style.dart';
import '../../liquid_glass_view.dart';
import 'liquid_glass_toggle_layout.dart';
import 'liquid_glass_toggle_thumb.dart';
import 'liquid_glass_toggle_track.dart';

export 'liquid_glass_toggle_layout.dart';
export 'liquid_glass_toggle_thumb.dart';
export 'liquid_glass_toggle_track.dart';

/// A drop-in liquid-glass toggle switch.
///
/// This is the **developer-facing** component: it owns its own
/// [LiquidGlassView], the colored track ([LiquidGlassToggleTrack]), the
/// moving glass thumb ([buildLiquidGlassToggleThumb]) and the slide
/// animation — so you just give it a [value] and an [onChanged] like a
/// regular `Switch`.
///
/// At rest it shows a solid white pill in a tinted capsule. On tap, the
/// white pill is replaced by a liquid-glass pill that bulges out, slides
/// across, and settles back into the destination — refracting the track
/// underneath as it travels.
///
/// ```dart
/// LiquidGlassToggle(
///   value: _on,
///   onChanged: (v) => setState(() => _on = v),
///   activeColor: const Color(0xFF34C759),
/// )
/// ```
///
/// ## Refraction & the overhang
/// The glass thumb grows larger than the track, so its overhang samples
/// the (transparent) area around the capsule. The shader honors the
/// captured texel's alpha (always on), so that overhang renders as
/// transparent passthrough instead of a black blob. On the Impeller
/// backdrop path the overhang refracts the live backdrop directly.
class LiquidGlassToggle extends StatefulWidget {
  /// Whether the switch is on.
  final bool value;

  /// Called with the new value when the user toggles the switch.
  final ValueChanged<bool> onChanged;

  /// Track tint when the switch is **on**.
  final Color activeColor;

  /// Track color when the switch is **off**.
  final Color inactiveColor;

  /// Size + thumb geometry of the switch. Defaults to a 64×32 capsule.
  final LiquidGlassToggleLayout layout;

  /// Glass look of the moving thumb (shape + appearance + refraction),
  /// the same [LiquidGlassStyle] vocabulary used across the library. When
  /// null, the tuned default capsule glass is used. A null
  /// [LiquidGlassStyle.shape] keeps the height-tracking capsule so the
  /// thumb stays a clean pill as it grows during the slide.
  final LiquidGlassStyle? style;

  /// Capture resolution for the inner view. `1.0` is a good default; use
  /// less for cheaper captures, `0.0` for the device pixel ratio.
  final double pixelRatio;

  const LiquidGlassToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = const Color(0xFF34C759),
    this.inactiveColor = const Color(0x66808080),
    this.layout = const LiquidGlassToggleLayout(),
    this.style,
    this.pixelRatio = 1.0,
  });

  @override
  State<LiquidGlassToggle> createState() => _LiquidGlassToggleState();
}

class _LiquidGlassToggleState extends State<LiquidGlassToggle>
    with SingleTickerProviderStateMixin {
  final LiquidGlassViewController _viewController = LiquidGlassViewController();
  late final AnimationController _anim;
  late Animation<double> _fraction;

  /// True while the slide animation is running — the only time the glass
  /// thumb (and live capture) is needed.
  bool _glassActive = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    // TEMP test: run the capture pipeline from startup instead of
    // starting it on the first tap, to check whether the cold capture
    // start is the first-touch stall.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _viewController.startRealtimeCapture();
    });
    _fraction = AlwaysStoppedAnimation<double>(widget.value ? 1.0 : 0.0);
    _anim.addListener(() => setState(() {}));
    _anim.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Animation done — drop the glass thumb. The view keeps
        // capturing in real time so the always-mounted glass pill
        // stays live.
        if (mounted) setState(() => _glassActive = false);
      }
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _handleTap(bool next) {
    if (next == widget.value) return;
    final from = _fraction.value;
    setState(() {
      _glassActive = true;
      _fraction = Tween<double>(begin: from, end: next ? 1.0 : 0.0)
          .chain(CurveTween(curve: Curves.easeOutCubic))
          .animate(_anim);
    });
    // Capture the changing track while the glass travels over it.
    _viewController.startRealtimeCapture();
    _anim
      ..reset()
      ..forward();
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final layout = widget.layout;

    // Padding around the track so the grown glass thumb (which bulges
    // past the capsule) is never clipped by the inner view bounds.
    final maxPillW = layout.thumbWidth + layout.thumbExtraWidth;
    // Peak glass-pill height is ratio-locked to the handle (see
    // buildLiquidGlassToggleThumb), so size the vertical padding from
    // that, not from thumbExtraHeight.
    final maxPillH = maxPillW * (layout.thumbHeight / layout.thumbWidth);
    final travel = layout.travel;
    final rightExtent =
        layout.padding + travel + layout.thumbWidth / 2 + maxPillW / 2;
    final leftExtent = layout.padding + layout.thumbWidth / 2 - maxPillW / 2;
    final padX = math.max(
          math.max(0.0, rightExtent - layout.width),
          math.max(0.0, -leftExtent),
        ) +
        2.0;
    final padY = math.max(0.0, maxPillH / 2 - layout.height / 2) + 2.0;

    final viewWidth = layout.width + padX * 2;
    final viewHeight = layout.height + padY * 2;

    final growFraction = math.sin(math.pi * _anim.value);

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
        useSync: false,
        backgroundWidget: Stack(
          children: [
            Positioned(
              left: padX,
              top: padY,
              child: LiquidGlassToggleTrack(
                value: widget.value,
                onChanged: _handleTap,
                tint: widget.activeColor,
                offColor: widget.inactiveColor,
                layout: layout,
                // The white rest handle is rendered INSIDE the glass
                // lens (as its child) so it sits ON TOP of the glass
                // pill — never here in the background, which lenses
                // always cover.
                showRestThumb: false,
                pinchFraction: growFraction,
                travelFraction: _fraction.value,
              ),
            ),
          ],
        ),
        children: [
          // The glass thumb is ALWAYS mounted. At rest (growFraction 0)
          // it is exactly the size of the handle and sits UNDER the
          // white rest pill, which is rendered as the lens's child — on
          // top of the glass. On tap the white pill hides and the glass
          // (already rendered all along) bulges and travels, so nothing
          // new is created at first touch. The child also carries the
          // handle's tap surface, since the lens sits above the track
          // and would otherwise block it.
          buildLiquidGlassToggleThumb(
            layout: layout,
            trackLeft: padX,
            trackBottom: padY,
            travelFraction: _fraction.value,
            growFraction: growFraction,
            style: widget.style,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _handleTap(!widget.value),
              // White rest handle, drawn over the glass. Hidden (but
              // still hit-testable) while the glass is sliding.
              child: _glassActive
                  ? const SizedBox.expand()
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          layout.thumbHeight / 2,
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
