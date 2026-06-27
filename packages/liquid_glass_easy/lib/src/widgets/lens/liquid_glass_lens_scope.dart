import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Connection between a `LiquidGlassView` and the `LiquidGlassLens`
/// widgets living anywhere inside its `child` subtree.
///
/// This is the **registration half** of the lens-anywhere design: the
/// view exposes everything a descendant lens needs to render, and the
/// lens looks it up with [maybeOf]. How the lens then paints (live
/// Impeller backdrop vs. sampling the view's captured background) is an
/// implementation detail behind this contract — the widget tree shape
/// never changes when the renderer does.
class LiquidGlassLensScope extends InheritedWidget {
  /// Whether the owning view renders lenses through
  /// `BackdropFilter(ImageFilter.shader(...))` (Impeller) instead of
  /// the capture pipeline (Skia / Web).
  final bool useImpellerBackdrop;

  /// Bumped after every successful background capture (Skia path).
  /// Lenses repaint when this ticks; the actual image is read through
  /// [currentImage] at paint time so paint never holds a stale frame.
  final ValueListenable<int> captureRevision;

  /// Latest captured background snapshot, or null before the first
  /// capture lands. Always a full-frame capture of the view's
  /// background boundary.
  final ui.Image? Function() currentImage;

  /// Paint-time synchronous capture fallback — rasterizes the already-
  /// painted background boundary when [currentImage] is still null (the
  /// view's very first frame), so a lens refracts on frame one.
  final ui.Image? Function() captureFallback;

  /// The render box of the background `RepaintBoundary` — the
  /// coordinate space the captured image lives in. Lenses map their own
  /// rect into this space with `getTransformTo`.
  final RenderBox? Function() backgroundRenderBox;

  const LiquidGlassLensScope({
    super.key,
    required this.useImpellerBackdrop,
    required this.captureRevision,
    required this.currentImage,
    required this.captureFallback,
    required this.backgroundRenderBox,
    required super.child,
  });

  static LiquidGlassLensScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LiquidGlassLensScope>();
  }

  @override
  bool updateShouldNotify(covariant LiquidGlassLensScope oldWidget) {
    // The function members are instance-method tear-offs from the view's
    // State, which compare equal across rebuilds of the same State, so
    // this only notifies on a real configuration change.
    return useImpellerBackdrop != oldWidget.useImpellerBackdrop ||
        captureRevision != oldWidget.captureRevision ||
        currentImage != oldWidget.currentImage ||
        captureFallback != oldWidget.captureFallback ||
        backgroundRenderBox != oldWidget.backgroundRenderBox;
  }
}
