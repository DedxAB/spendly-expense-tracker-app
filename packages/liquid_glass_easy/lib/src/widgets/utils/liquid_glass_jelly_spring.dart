import 'dart:math' as math;

/// One integration step of an underdamped spring, sub-stepped at 240 Hz
/// for stability. Returns the new `(position, velocity)`.
///
/// This is the shared integrator behind every "jelly" deformation in the
/// package (slider thumb, nav-bar pill). Use it directly for one-off
/// springs, or use [LiquidGlassJellySpring] for the full drag-driven
/// jelly simulation.
(double, double) liquidGlassSpringStep({
  required double x,
  required double vel,
  required double target,
  required double dt,
  double stiffness = 320,
  double damping = 22,
}) {
  var t = dt;
  var px = x;
  var pv = vel;
  while (t > 0) {
    final step = t > 1 / 240.0 ? 1 / 240.0 : t;
    final accel = -stiffness * (px - target) - damping * pv;
    pv += accel * step;
    px += pv * step;
    t -= step;
  }
  return (px, pv);
}

/// Component-agnostic 1-D jelly simulation: the drag-velocity-driven
/// spring system originally built (and tuned, on device) for the
/// slider thumb.
///
/// Feed it a stream of 1-D positions over time — a slider value, a
/// nav-bar tab fraction, a scroll offset — and it produces two signed
/// outputs each tick:
///
///  • [stretch] (-1..1) — the "lean into motion" spring. Sign is the
///    drag direction, magnitude the intensity. Drives the
///    `pinchExtrude` deformation style.
///  • [deform] (-1..1) — the velocity-projected-onto-direction-memory
///    spring. Positive while moving steadily (elongate along motion),
///    swings negative on a sudden stop or reversal (squash recoil).
///    Drives the iOS-style `stretch` deformation style.
///
/// It also exposes [direction], the smoothed motion direction in
/// `-1..1`, for anchor-bias leans.
///
/// The caller owns the `Ticker`: call [start] on gesture-down,
/// [pump] with each new position, [release] on gesture-up, and
/// [tick] every frame — it returns `true` once everything has
/// settled, which is the caller's cue to stop its ticker.
///
/// How the simulation maps to pixels is up to each component (the
/// slider bends its thumb geometry, the nav bar its pill) — this class
/// is physics only.
class LiquidGlassJellySpring {
  /// Spring stiffness shared by both springs.
  double stiffness;

  /// Spring damping. Lower → more visible overshoot wobble.
  double damping;

  /// Input velocity (position-units/second) that maps to full spring
  /// load (|target| = 1). Lower → reacts to gentler drags.
  double maxVelocity;

  /// Time constant (seconds) of the direction memory. See
  /// [direction].
  double directionTau;

  /// Hard clamp on the raw input velocity before normalization, in
  /// position-units/second. Guards against absurd spikes from
  /// near-zero `dt` between pumps.
  double velocityClamp;

  LiquidGlassJellySpring({
    this.stiffness = 320,
    this.damping = 22,
    this.maxVelocity = 1.5,
    this.directionTau = 0.12,
    this.velocityClamp = 12,
  });

  // ── Signed lean spring ────────────────────────────────────────────
  double _stretch = 0;
  double _stretchVel = 0;
  double _stretchTarget = 0;

  // ── Deform spring (velocity projected onto direction memory) ─────
  // Target = velocity PROJECTED onto the smoothed direction memory
  // [_dir] (recomputed every tick as `_velNorm * _dir`):
  //  • steady drag — velocity and memory aligned → target ≈ +speed →
  //    elongate along motion;
  //  • sudden stop — pumps cease, _velNorm decays → target → 0 and the
  //    underdamped spring overshoots NEGATIVE → squash recoil;
  //  • sudden reversal — velocity OPPOSES the memory → target swings
  //    hard negative immediately, easing into the new direction's
  //    elongation as _dir re-adapts (over [directionTau] seconds).
  double _deform = 0;
  double _deformVel = 0;
  double _deformTarget = 0;

  /// Latest input velocity, normalized by [maxVelocity], signed.
  double _velNorm = 0;

  /// Smoothed direction memory (-1..1) and its raw target (±1).
  double _dir = 0;
  double _dirTarget = 0;

  double _lastValue = 0;

  /// Wall-clock timestamp of the last [pump] — used to derive the
  /// signed velocity and to detect a mid-drag pause.
  DateTime _lastTs = DateTime.now();

  /// Signed lean spring output, clamped use is the caller's job.
  double get stretch => _stretch;

  /// Signed deform spring output (stretch vs. squash-recoil).
  double get deform => _deform;

  /// Smoothed motion direction in `-1..1` (negative = decreasing
  /// values). Lags a reversal by ~[directionTau] by design.
  double get direction => _dir;

  /// Resets all state and primes the velocity tracking at [value].
  /// Call on gesture-down, before starting the ticker.
  void start(double value) {
    _stretch = 0;
    _stretchVel = 0;
    _stretchTarget = 0;
    _deform = 0;
    _deformVel = 0;
    _deformTarget = 0;
    _velNorm = 0;
    _dir = 0;
    _dirTarget = 0;
    _lastValue = value;
    _lastTs = DateTime.now();
  }

  /// Maps the most recent position delta to the signed `[-1, 1]`
  /// spring targets. Call with every new position while dragging.
  void pump(double newValue) {
    final now = DateTime.now();
    final dt = now.difference(_lastTs).inMicroseconds / 1e6;
    if (dt > 0) {
      final signedVel =
          ((newValue - _lastValue) / dt).clamp(-velocityClamp, velocityClamp);
      _stretchTarget = (signedVel / maxVelocity).clamp(-1.0, 1.0);
      // Store the signed normalized velocity; [tick] projects it onto
      // the direction memory every frame to produce the deform target
      // (stretch when aligned, squash when opposed).
      _velNorm = (signedVel / maxVelocity).clamp(-1.0, 1.0);
      if (signedVel.abs() > 0.05) {
        _dirTarget = signedVel.isNegative ? -1.0 : 1.0;
      }
    }
    _lastValue = newValue;
    _lastTs = now;
  }

  /// Drives the spring targets to 0; the springs' own momentum
  /// produces the release overshoot, then settles. Call on gesture-up.
  void release() {
    _stretchTarget = 0; // spring momentum carries the overshoot
    _deformTarget = 0;
  }

  /// Advances the simulation by [dt] seconds. [dragging] tells the
  /// simulation whether the input gesture is still down (it decays the
  /// targets during a mid-drag pause, and zeroes them after release).
  ///
  /// Returns `true` when the simulation has fully settled — the
  /// caller's cue to stop its ticker.
  bool tick(double dt, {required bool dragging}) {
    if (dragging) {
      // Decay the target toward 0 if the input paused mid-drag so the
      // lean doesn't stick.
      final sincePump =
          DateTime.now().difference(_lastTs).inMicroseconds / 1e6;
      if (sincePump > 0.032) {
        const targetTau = 0.08;
        final targetAlpha = 1 - math.exp(-dt / targetTau);
        _stretchTarget *= (1 - targetAlpha);
        _velNorm *= (1 - targetAlpha);
      }
    } else {
      _stretchTarget = 0;
      _velNorm = 0;
    }

    // Direction memory eases toward the latest motion sign; the deform
    // target is the velocity projected onto it. On a reversal the
    // projection is negative until _dir crosses over — that's the
    // squash-recoil phase.
    final dirAlpha = 1 - math.exp(-dt / directionTau);
    _dir += (_dirTarget - _dir) * dirAlpha;
    _deformTarget = (_velNorm * _dir).clamp(-1.0, 1.0);

    final result = liquidGlassSpringStep(
      x: _stretch,
      vel: _stretchVel,
      target: _stretchTarget,
      dt: dt,
      stiffness: stiffness,
      damping: damping,
    );
    _stretch = result.$1;
    _stretchVel = result.$2;

    final deformResult = liquidGlassSpringStep(
      x: _deform,
      vel: _deformVel,
      target: _deformTarget,
      dt: dt,
      stiffness: stiffness,
      damping: damping,
    );
    _deform = deformResult.$1;
    _deformVel = deformResult.$2;

    if (!dragging &&
        _stretch.abs() < 0.005 &&
        _stretchVel.abs() < 0.05 &&
        _stretchTarget.abs() < 0.005 &&
        _deform.abs() < 0.005 &&
        _deformVel.abs() < 0.05 &&
        _deformTarget.abs() < 0.005) {
      _stretch = 0;
      _stretchVel = 0;
      _stretchTarget = 0;
      _deform = 0;
      _deformVel = 0;
      _deformTarget = 0;
      return true;
    }
    return false;
  }
}
