import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../liquid_glass_config.dart';
import '../painters/liquid_glass_painter.dart';
import '../utils/liquid_glass_shape.dart';

/// Skia / Web render path for a single lens, extracted from
/// `LiquidGlassWidget`.
///
/// Samples a **captured** snapshot of the background ([image]) through
/// a `CustomPaint` + [LiquidGlassPainter]. When blur is enabled it adds
/// a `BackdropFilter` blur plus a second, sharp border pass
/// ([LiquidGlassBorderPainter]) on top.
///
/// This path does **not** own an `AnimatedBuilder` for the show/hide
/// animation: it reads the already-resolved [animValue] directly and is
/// re-driven by the parent `LiquidGlassView`'s capture ticker (which
/// rebuilds the whole lens every captured frame). The drag [touch]
/// notifier is still listened to locally for the movable hit target.
class SkiaLiquidGlassLens extends StatelessWidget {
  final LiquidGlass config;
  final Size parentSize;

  /// Shared main shader. Null while the program is still loading.
  final ui.FragmentShader? shader;

  /// Captured background snapshot. Null until the first capture lands.
  final ui.Image? image;

  /// Paint-time synchronous capture fallback, used by the painters when
  /// [image] is still null (the first frame after the parent view is
  /// created). Lets a freshly mounted lens refract on its very first
  /// frame instead of waiting for the post-frame capture.
  final ui.Image? Function()? imageFallback;

  /// Shared border shader, used for the sharp second border pass under
  /// blur.
  final ui.FragmentShader? borderShader;

  /// Drag position (lens top-left), owned by the coordinator.
  final ValueNotifier<Offset> touch;

  /// Already-resolved show/hide animation value (`0` = shown, `1` =
  /// hidden), supplied by the coordinator on each parent rebuild.
  final double animValue;

  /// Parent-space rectangle that [image] covers. `null` → the image is a
  /// full-frame capture (image == whole parent). When set, the image is a
  /// captured sub-rect and the shader samples it via that offset/size.
  final Rect? imageRegion;

  /// Whether the captured backdrop's alpha is folded into coverage (the
  /// shader's `u_honorBackdropAlpha`). Only the slider/toggle — whose
  /// captured track is authored-transparent — want this `true`; everything
  /// else treats the capture as opaque. See [LiquidGlassPainter].
  final bool honorBackdropAlpha;

  const SkiaLiquidGlassLens({
    super.key,
    required this.config,
    required this.parentSize,
    required this.shader,
    required this.image,
    this.imageFallback,
    required this.borderShader,
    required this.touch,
    required this.animValue,
    this.imageRegion,
    this.honorBackdropAlpha = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool useBlur = config.effectiveAppearance.blur.sigmaX > 0 ||
        config.effectiveAppearance.blur.sigmaY > 0;

    return Stack(
      children: [
        // Shader layer
        IgnorePointer(
          ignoring: true,
          child: SizedBox(
            width: parentSize.width,
            height: parentSize.height,
            child: CustomPaint(
              painter: (shader != null &&
                      (image != null || imageFallback != null))
                  ? LiquidGlassPainter(
                      dragOffset: touch.value,
                      position: config.geometry.position,
                      lensWidth: config.geometry.width,
                      lensHeight: config.geometry.height,
                      magnification: (animValue) +
                          (config.effectiveRefraction.magnification *
                              (1 - animValue)),
                      distortion:
                          config.effectiveRefraction.effectiveDistortion,
                      distortionWidth:
                          (config.effectiveRefraction.effectiveDistortionWidth -
                              animValue *
                                  config.effectiveRefraction
                                      .effectiveDistortionWidth),
                      diagonalFlip: config.effectiveRefraction.diagonalFlip,
                      enableInnerRadiusTransparent: config
                          .effectiveAppearance.enableInnerRadiusTransparent,
                      draggable: config.behavior.draggable,
                      parentSize: parentSize,
                      border: config.effectiveShape,
                      borderAlpha: (1 - animValue),
                      blur: config.effectiveAppearance.blur,
                      color: config.effectiveAppearance.color,
                      shader: shader!,
                      image: image,
                      imageFallback: imageFallback,
                      borderShader: borderShader,
                      chromaticAberration:
                          config.effectiveRefraction.chromaticAberration *
                              (1 - animValue),
                      saturation: (animValue) +
                          (config.effectiveAppearance.saturation *
                              (1 - animValue)),
                      refractionMode: config.effectiveRefraction.refractionMode,
                      refractionType: config.effectiveRefraction.refractionType,
                      imageOffset: imageRegion?.topLeft,
                      imageSize: imageRegion?.size,
                      honorBackdropAlpha: honorBackdropAlpha,
                    )
                  : null,
              child: const SizedBox.expand(),
            ),
          ),
        ),

        // BackdropFilter blur for rounded-clip shapes (rounded-rect / squircle)
        if (borderShader != null &&
            useBlur &&
            liquidGlassUsesRoundedClip(config.effectiveShape))
          Positioned(
            left: touch.value.dx,
            top: touch.value.dy,
            width: config.geometry.width,
            height: config.geometry.height,
            child: liquidGlassClip(
              shape: config.effectiveShape,
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX:
                      config.effectiveAppearance.blur.sigmaX * (1 - animValue),
                  sigmaY:
                      config.effectiveAppearance.blur.sigmaY * (1 - animValue),
                ),
                child: Container(),
              ),
            ),
          ),

        // // SECOND PASS: border painter ONLY (sharp, isolated)
        if (borderShader != null &&
            (image != null || imageFallback != null) &&
            useBlur)
          IgnorePointer(
            ignoring: true,
            child: CustomPaint(
              painter: LiquidGlassBorderPainter(
                borderShader: borderShader!,
                lensPosition: touch.value,
                lensWidth: config.geometry.width,
                lensHeight: config.geometry.height,
                magnification: (animValue) +
                    (config.effectiveRefraction.magnification *
                        (1 - animValue)),
                distortion: config.effectiveRefraction.effectiveDistortion,
                distortionWidth: (config
                        .effectiveRefraction.effectiveDistortionWidth -
                    animValue *
                        config.effectiveRefraction.effectiveDistortionWidth),
                diagonalFlip: config.effectiveRefraction.diagonalFlip,
                enableInnerRadiusTransparent:
                    config.effectiveAppearance.enableInnerRadiusTransparent,
                chromaticAberration:
                    config.effectiveRefraction.chromaticAberration *
                        (1 - animValue),
                saturation: (animValue) +
                    (config.effectiveAppearance.saturation * (1 - animValue)),
                refractionMode: config.effectiveRefraction.refractionMode,
                refractionType: config.effectiveRefraction.refractionType,
                border: config.effectiveShape,
                borderAlpha: (1 - animValue),
                image: image,
                imageFallback: imageFallback,
                imageOffset: imageRegion?.topLeft,
                imageSize: imageRegion?.size,
              ),
              size: Size.infinite,
            ),
          ),

        // Draggable lens
        ValueListenableBuilder<Offset>(
          valueListenable: touch,
          builder: (context, offset, child) {
            return Positioned(
              left: offset.dx,
              top: offset.dy,
              width:
                  config.geometry.width - config.effectiveShape.borderWidth / 2,
              height: config.geometry.height -
                  config.effectiveShape.borderWidth / 2,
              child: GestureDetector(
                behavior: HitTestBehavior
                    .opaque, // ensures full area receives gestures
                onPanUpdate: config.behavior.draggable
                    ? (details) {
                        touch.value += details.delta;
                      }
                    : null,
                child: liquidGlassClip(
                  shape: config.effectiveShape,
                  child: config.child ??
                      Container(
                        color: Colors.transparent,
                      ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
