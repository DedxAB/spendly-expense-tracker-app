import 'package:flutter/material.dart';

import '../lens/liquid_glass_lens.dart';
import '../liquid_glass_config.dart';
import '../liquid_glass_style.dart';
import '../utils/liquid_glass_blur.dart';
import '../utils/liquid_glass_border_mode.dart';
import '../utils/liquid_glass_shape.dart';

/// Description of a single tab in [LiquidGlassTabBar].
class LiquidGlassTabBarItem {
  /// Icon shown when the tab is unselected.
  final IconData icon;

  /// Icon shown when the tab is selected (defaults to [icon]).
  final IconData? selectedIcon;

  /// Optional label below the icon. When `null` the tab renders icon
  /// only, matching the modern liquid-glass minimal style.
  final String? label;

  const LiquidGlassTabBarItem({
    required this.icon,
    this.selectedIcon,
    this.label,
  });
}

/// A floating "liquid glass" tab bar.
///
/// Renders 2–5 tabs as a single translucent pill that sits above the
/// content. The active tab is marked with a soft inner pill that moves
/// **instantly** to the selected tab (no slide animation).
///
/// Drop it anywhere in your layout. Styling uses one [LiquidGlassStyle]
/// ([style] — shape + appearance + refraction). An animated counterpart
/// ([LiquidGlassAnimatedTabBar]) exists in the source but is intentionally
/// **not exported** while its motion work is finished.
class LiquidGlassTabBar extends StatelessWidget {
  const LiquidGlassTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 64,
    this.width = 320,
    this.style,
    this.visibility = true,
    this.showSelectionPill = true,
    this.selectionColor = const Color(0x32FFFFFF), // white, alpha 50
    this.selectionBorderColor = const Color(0x50FFFFFF), // alpha 80
    this.selectedItemColor = Colors.white,
    this.unselectedItemColor = Colors.white70,
    this.iconSize = 24,
    this.fontSize = 10.5,
  })  : assert(items.length >= 2 && items.length <= 5,
            'Tab bars use 2–5 tabs'),
        assert(selectedIndex >= 0 && selectedIndex < items.length);

  /// The tabs, left to right.
  final List<LiquidGlassTabBarItem> items;

  /// Currently selected tab index.
  final int selectedIndex;

  /// Called with the tapped tab index.
  final ValueChanged<int> onChanged;

  /// Bar height; also drives the default pill radius (`height / 2`).
  final double height;

  /// Explicit width. When null the bar hugs its content.
  final double? width;

  /// The bar's glass look as one [LiquidGlassStyle] (shape + appearance +
  /// refraction), taken as the complete look. When null the tuned
  /// [defaultStyle] is used; its `shape` may be null, in which case a full
  /// pill with a tuned optical border is used. To tweak one facet while
  /// keeping the rest of the tuned look, compose with `copyWith`, e.g.
  /// `style: LiquidGlassTabBar.defaultStyle.copyWith(...)`.
  final LiquidGlassStyle? style;

  /// Whether the bar is shown; toggling animates the glass in/out.
  final bool visibility;

  /// Whether to draw the soft pill behind the selected tab.
  final bool showSelectionPill;

  /// Fill color of the selection pill.
  final Color selectionColor;

  /// Border color of the selection pill.
  final Color selectionBorderColor;

  /// Color of the selected tab's icon + label.
  final Color selectedItemColor;

  /// Color of unselected tabs' icons + labels.
  final Color unselectedItemColor;

  /// Icon size for every tab.
  final double iconSize;

  /// Label font size (labels show only when an item has a label).
  final double fontSize;

  static const LiquidGlassAppearance _defaultAppearance =
      LiquidGlassAppearance(
    color: Color(0x1CFFFFFF), // white, alpha 28
    blur: LiquidGlassBlur(sigmaX: 4, sigmaY: 4),
  );

  static const LiquidGlassRefraction _defaultRefraction =
      LiquidGlassRefraction(
    distortion: 0.08,
    distortionWidth: 32,
    chromaticAberration: 0.002,
  );

  /// The tuned default look — a faint white frost over a soft optical
  /// refraction. Its `shape` is `null`: the bar derives a height-tracking
  /// capsule when [style] supplies no shape. Compose with `copyWith` to
  /// tweak one facet, e.g. `style: LiquidGlassTabBar.defaultStyle.copyWith(...)`.
  static const LiquidGlassStyle defaultStyle = LiquidGlassStyle(
    appearance: _defaultAppearance,
    refraction: _defaultRefraction,
  );

  @override
  Widget build(BuildContext context) {
    final LiquidGlassStyle resolved = defaultStyle.merge(style);
    final LiquidGlassShape effectiveShape = resolved.shape ?? _tabBarShape(height);

    return SizedBox(
      width: width,
      height: height,
      child: LiquidGlassLens(
        style: LiquidGlassStyle(
          shape: effectiveShape,
          appearance: resolved.appearance,
          refraction: resolved.refraction,
        ),
        visibility: visibility,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: LayoutBuilder(builder: (context, constraints) {
            final segWidth = constraints.maxWidth / items.length;
            return Stack(
              children: [
                if (showSelectionPill)
                  Positioned(
                    left: selectedIndex * segWidth,
                    top: 0,
                    bottom: 0,
                    width: segWidth,
                    child: _SelectionPill(
                      height: height,
                      color: selectionColor,
                      borderColor: selectionBorderColor,
                    ),
                  ),
                Row(
                  children: [
                    for (int i = 0; i < items.length; i++)
                      Expanded(
                        child: _TabButton(
                          item: items[i],
                          selected: i == selectedIndex,
                          selectedColor: selectedItemColor,
                          unselectedColor: unselectedItemColor,
                          iconSize: iconSize,
                          fontSize: fontSize,
                          onTap: () => onChanged(i),
                        ),
                      ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

/// Animated variant of [LiquidGlassTabBar]: the selection pill **slides**
/// between tabs instead of jumping.
///
/// **Not exported yet.** Kept internal while the animation polish is
/// finished, so it is only consumed by the package's own example /
/// showcase.
class LiquidGlassAnimatedTabBar extends StatelessWidget {
  const LiquidGlassAnimatedTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 64,
    this.width = 320,
    this.shape,
    this.appearance = LiquidGlassTabBar._defaultAppearance,
    this.refraction = LiquidGlassTabBar._defaultRefraction,
    this.style,
    this.visibility = true,
    this.showSelectionPill = true,
    this.selectionColor = const Color(0x32FFFFFF),
    this.selectionBorderColor = const Color(0x50FFFFFF),
    this.selectionDuration = const Duration(milliseconds: 240),
    this.selectionCurve = Curves.easeOutCubic,
    this.selectedItemColor = Colors.white,
    this.unselectedItemColor = Colors.white70,
    this.iconSize = 24,
    this.fontSize = 10.5,
  })  : assert(items.length >= 2 && items.length <= 5,
            'Tab bars use 2–5 tabs'),
        assert(selectedIndex >= 0 && selectedIndex < items.length);

  final List<LiquidGlassTabBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;
  final double? width;
  final LiquidGlassShape? shape;
  final LiquidGlassAppearance appearance;
  final LiquidGlassRefraction refraction;
  final LiquidGlassStyle? style;
  final bool visibility;
  final bool showSelectionPill;
  final Color selectionColor;
  final Color selectionBorderColor;

  /// How long the selection pill takes to slide between tabs.
  final Duration selectionDuration;

  /// Easing curve for the slide.
  final Curve selectionCurve;

  final Color selectedItemColor;
  final Color unselectedItemColor;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final LiquidGlassShape effectiveShape = shape ?? _tabBarShape(height);

    return SizedBox(
      width: width,
      height: height,
      child: LiquidGlassLens(
        style: LiquidGlassStyle(
          shape: effectiveShape,
          appearance: appearance,
          refraction: refraction,
        ).merge(style),
        visibility: visibility,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: LayoutBuilder(builder: (context, constraints) {
            final segWidth = constraints.maxWidth / items.length;
            return Stack(
              children: [
                if (showSelectionPill)
                  AnimatedPositioned(
                    duration: selectionDuration,
                    curve: selectionCurve,
                    left: selectedIndex * segWidth,
                    top: 0,
                    bottom: 0,
                    width: segWidth,
                    child: _SelectionPill(
                      height: height,
                      color: selectionColor,
                      borderColor: selectionBorderColor,
                    ),
                  ),
                Row(
                  children: [
                    for (int i = 0; i < items.length; i++)
                      Expanded(
                        child: _TabButton(
                          item: items[i],
                          selected: i == selectedIndex,
                          selectedColor: selectedItemColor,
                          unselectedColor: unselectedItemColor,
                          iconSize: iconSize,
                          fontSize: fontSize,
                          onTap: () => onChanged(i),
                        ),
                      ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

/// Default pill shape shared by the tab bars (radius derived from the
/// bar height).
LiquidGlassShape _tabBarShape(double height) => LiquidGlassShape.roundedRectangle(
      cornerRadius: height / 2,
      borderWidth: 1.2,
      lightIntensity: 1.2,
      lightDirection: 80,
      borderType: const OpticalBorder(
        borderSaturation: 1.3,
        ambientIntensity: 1.0,
        borderSolidity: 0.4,
      ),
    );

class _SelectionPill extends StatelessWidget {
  final double height;
  final Color color;
  final Color borderColor;

  const _SelectionPill({
    required this.height,
    required this.color,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular((height - 12) / 2),
        border: Border.all(color: borderColor, width: 0.6),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final LiquidGlassTabBarItem item;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final double iconSize;
  final double fontSize;
  final VoidCallback onTap;

  const _TabButton({
    required this.item,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.iconSize,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? (item.selectedIcon ?? item.icon) : item.icon,
                size: iconSize,
                color: color,
              ),
              if (item.label != null) ...[
                const SizedBox(height: 2),
                Text(
                  item.label!,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Companion floating action button rendered as its own liquid-glass
/// pill, mirroring the pattern of pairing a tab bar with a separate,
/// side-floating action (often Search).
class LiquidGlassTabBarAction extends StatelessWidget {
  const LiquidGlassTabBarAction({
    super.key,
    required this.icon,
    this.onTap,
    this.foregroundColor = Colors.white,
    this.size = 56,
    this.style,
    this.visibility = true,
  });

  /// The action glyph.
  final IconData icon;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Color of the glyph.
  final Color foregroundColor;

  /// Diameter of the circular button.
  final double size;

  /// The action's glass look as one [LiquidGlassStyle] (shape + appearance
  /// + refraction), taken as the complete look. When null the tuned
  /// [defaultStyle] is used; its `shape` may be null, in which case a
  /// circular pill mirroring the bottom-nav capsule rim is used. To tweak
  /// one facet while keeping the rest, compose with `copyWith`, e.g.
  /// `style: LiquidGlassTabBarAction.defaultStyle.copyWith(...)`.
  final LiquidGlassStyle? style;

  /// Whether the button is shown; toggling animates the glass in/out.
  final bool visibility;

  static const LiquidGlassAppearance _defaultAppearance =
      LiquidGlassAppearance(
    // Transparent body — let the refraction speak for itself.
    blur: LiquidGlassBlur(sigmaX: 2, sigmaY: 2),
  );

  static const LiquidGlassRefraction _defaultRefraction =
      LiquidGlassRefraction(
    distortion: 0.07,
    distortionWidth: 28,
    chromaticAberration: 0.002,
  );

  /// The tuned default look — a transparent body over a soft optical
  /// refraction. Its `shape` is `null`: the action derives a circular pill
  /// when [style] supplies no shape. Compose with `copyWith` to tweak one
  /// facet, e.g. `style: LiquidGlassTabBarAction.defaultStyle.copyWith(...)`.
  static const LiquidGlassStyle defaultStyle = LiquidGlassStyle(
    appearance: _defaultAppearance,
    refraction: _defaultRefraction,
  );

  @override
  Widget build(BuildContext context) {
    final LiquidGlassStyle resolved = defaultStyle.merge(style);
    final LiquidGlassShape effectiveShape = resolved.shape ??
        LiquidGlassShape.roundedRectangle(
          cornerRadius: size / 2,
          borderWidth: 1.2,
          lightIntensity: 1.1,
          lightDirection: 80,
          borderType: const OpticalBorder(
            borderSaturation: 1.2,
            ambientIntensity: 1.0,
            borderSolidity: 0.35,
          ),
        );

    return SizedBox(
      width: size,
      height: size,
      child: LiquidGlassLens(
        style: LiquidGlassStyle(
          shape: effectiveShape,
          appearance: resolved.appearance,
          refraction: resolved.refraction,
        ),
        visibility: visibility,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Center(
              child: Icon(icon, color: foregroundColor, size: size * 0.46),
            ),
          ),
        ),
      ),
    );
  }
}
