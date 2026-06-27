import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../utils/liquid_glass_jelly_config.dart';
import '../utils/liquid_glass_jelly_resolver.dart';
import '../utils/liquid_glass_jelly_spring.dart';

/// A reusable **jelly** wrapper: drive it with a 1-D [value] and it
/// squash/stretches its [child] like the slider thumb and nav-bar pill
/// do — the same `LiquidGlassJellySpring` physics, exposed as a drop-in
/// widget.
///
/// It deforms by **resizing** the child (not a `Transform` scale), so
/// when the child is a `LiquidGlassLens` the shader re-refracts at the
/// deformed dimensions — a true liquid-glass jelly, not stretched pixels.
/// The widget keeps a stable [width]×[height] footprint and lets the
/// deformation overflow around it, so siblings don't shift.
///
/// ```dart
/// LiquidGlassJelly(
///   value: _progress,            // any 1-D signal; deforms as it moves
///   width: 56,
///   height: 56,
///   config: const LiquidGlassJellyConfig(
///     style: LiquidGlassJellyStyle.squashStretch,
///   ),
///   child: const LiquidGlassLens(
///     shape: LiquidGlassShape.roundedRectangle(cornerRadius: 28),
///   ),
/// )
/// ```
///
/// Drive [value] from whatever moves — a slider value, a page-scroll
/// fraction, a selected-index `0..N` (raise [LiquidGlassJellyConfig.maxVelocity]
/// to match a larger scale). When [value] stops changing, the spring
/// recoils and settles on its own; while idle the widget runs no ticker.
class LiquidGlassJelly extends StatefulWidget {
  const LiquidGlassJelly({
    super.key,
    required this.value,
    required this.width,
    required this.height,
    required this.child,
    this.axis = Axis.horizontal,
    this.config = const LiquidGlassJellyConfig(),
  });

  /// The 1-D driving signal. Each change pumps the jelly spring; the
  /// deformation follows the value's velocity and direction.
  final double value;

  /// Rest width of the child footprint.
  final double width;

  /// Rest height of the child footprint.
  final double height;

  /// The axis the [value] motion runs along. The "elongate / squeeze"
  /// deformation is applied to this axis and the volume-preserving
  /// counter-deformation to the cross axis.
  final Axis axis;

  /// Spring + squash/stretch tuning.
  final LiquidGlassJellyConfig config;

  /// The deformed child — typically a `LiquidGlassLens`.
  final Widget child;

  @override
  State<LiquidGlassJelly> createState() => _LiquidGlassJellyState();
}

class _LiquidGlassJellyState extends State<LiquidGlassJelly>
    with SingleTickerProviderStateMixin {
  late LiquidGlassJellySpring _spring;
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;
  bool _running = false;

  /// Wall-clock of the last value change; the spring is treated as
  /// "dragging" for a short window after it, then released (which lets
  /// the recoil overshoot play out and settle).
  DateTime _lastPump = DateTime.fromMillisecondsSinceEpoch(0);

  static const Duration _draggingWindow = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _spring = _buildSpring();
  }

  LiquidGlassJellySpring _buildSpring() => LiquidGlassJellySpring(
        stiffness: widget.config.stiffness,
        damping: widget.config.damping,
        maxVelocity: widget.config.maxVelocity,
        directionTau: widget.config.directionTau,
        velocityClamp: widget.config.velocityClamp,
      );

  @override
  void didUpdateWidget(covariant LiquidGlassJelly oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Keep the live spring in sync with config tuning changes.
    final cfg = widget.config;
    _spring
      ..stiffness = cfg.stiffness
      ..damping = cfg.damping
      ..maxVelocity = cfg.maxVelocity
      ..directionTau = cfg.directionTau
      ..velocityClamp = cfg.velocityClamp;

    if (widget.value != oldWidget.value) {
      if (!_running) {
        // First motion after rest: prime velocity tracking at the
        // previous value before pumping the new one.
        _spring.start(oldWidget.value);
        _startTicker();
      }
      _spring.pump(widget.value);
      _lastPump = DateTime.now();
    }
  }

  void _startTicker() {
    _running = true;
    _lastTick = Duration.zero;
    (_ticker ??= createTicker(_onTick)).start();
  }

  void _onTick(Duration elapsed) {
    final double dt = _lastTick == Duration.zero
        ? 1 / 60
        : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;

    final bool dragging =
        DateTime.now().difference(_lastPump) < _draggingWindow;
    // Clamp dt so a dropped frame doesn't explode the spring.
    final bool settled =
        _spring.tick(dt.clamp(0.0, 1 / 30), dragging: dragging);

    if (mounted) setState(() {});

    if (settled && !dragging) {
      _ticker?.stop();
      _running = false;
      _lastTick = Duration.zero;
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  /// Maps the current spring state to a [LiquidGlassJellyDeform] via the
  /// shared [resolveJellyDeformation] — the one place the squash/stretch
  /// math lives (also used by the slider thumb and nav-bar pill).
  LiquidGlassJellyDeform _resolveDeform() {
    final cfg = widget.config;
    final double alongBase =
        widget.axis == Axis.horizontal ? widget.width : widget.height;
    final double crossBase =
        widget.axis == Axis.horizontal ? widget.height : widget.width;

    // pinchExtrude reads the lean spring; stretch reads the deform spring.
    final double springValue = cfg.style == LiquidGlassJellyStyle.pinchExtrude
        ? _spring.stretch
        : _spring.deform;

    return resolveJellyDeformation(
      style: cfg.style,
      springValue: springValue,
      directionSign: _spring.direction.isNegative ? -1.0 : 1.0,
      alongAmount: cfg.stretchWidth,
      crossAmount: cfg.squashHeight,
      anchorBias: cfg.anchorBias,
      recoilScale: cfg.recoilScale,
      recoilAnchor: cfg.recoilAnchor,
      alongFloor: -alongBase * 0.45,
      crossFloor: -crossBase * 0.4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final LiquidGlassJellyDeform deform = _resolveDeform();
    final bool horizontal = widget.axis == Axis.horizontal;

    final double dW = horizontal ? deform.along : deform.cross;
    final double dH = horizontal ? deform.cross : deform.along;
    final Offset biasOffset =
        horizontal ? Offset(deform.bias, 0) : Offset(0, deform.bias);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      // Stable footprint; the deformed glass overflows around it so
      // neighbouring widgets don't shift as the jelly wobbles.
      child: OverflowBox(
        minWidth: 0,
        maxWidth: double.infinity,
        minHeight: 0,
        maxHeight: double.infinity,
        child: Transform.translate(
          offset: biasOffset,
          child: SizedBox(
            width: math.max(0.0, widget.width + dW),
            height: math.max(0.0, widget.height + dH),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
