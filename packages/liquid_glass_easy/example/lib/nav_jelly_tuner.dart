import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

import 'nav_bar_tuning.dart';
import 'tuner_widgets.dart';
import 'tuning_store.dart';

// =============================================================
// Nav-bar Jelly Tuner — a live playground for the bottom-nav glass pill.
//
//   flutter run -t lib/nav_jelly_tuner.dart   (standalone)
//   …or open it from the home menu.
//
// Every control writes straight into the shared [TuningStore.nav], so the
// glass nav bar below reacts live AND the polished scaffold demo picks up
// the same values (in memory, this session) — tune here, record the GIF there.
//
//   Travel spring — the positional slide (bounce vs glide).
//   Jelly         — the iOS squash/stretch deformation.
//   Background    — the bar's frosted tint.
//   Light dir     — the angle of the rim highlight.
// =============================================================

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _TunerApp());
}

class _TunerApp extends StatelessWidget {
  const _TunerApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const NavJellyTunerPage(),
    );
  }
}

/// Live tuner for the bottom-nav glass pill + bar look. Writes to
/// [TuningStore.nav]; pushable as its own route from the home menu.
class NavJellyTunerPage extends StatefulWidget {
  const NavJellyTunerPage({super.key});

  @override
  State<NavJellyTunerPage> createState() => _NavJellyTunerPageState();
}

class _NavJellyTunerPageState extends State<NavJellyTunerPage> {
  int _index = 0;

  // Travel (positional) spring.
  late double _travelStiffness;
  late double _travelDamping;
  late double _growHeight;
  late double _lightDirection;

  // Jelly knobs.
  late double _stiffness;
  late double _damping;
  late double _maxVelocity;
  late double _stretchWidth;
  late double _squashHeight;
  late double _anchorBias;
  late double _recoilScale;
  late double _recoilAnchor;
  late double _directionTau;

  // Background (frosted tint): an opaque base hue + an opacity.
  late Color _bgBase;
  late double _bgOpacity;

  static const List<Color> _bgSwatches = [
    Colors.black,
    Colors.white,
    Color(0xFF7C5CFF),
    Color(0xFF2DD4BF),
    Color(0xFFFF5C8A),
    Color(0xFF4FB3FF),
  ];

  @override
  void initState() {
    super.initState();
    _seedFrom(TuningStore.instance.nav.value);
  }

  void _seedFrom(NavTuning n) {
    _travelStiffness = n.travelStiffness;
    _travelDamping = n.travelDamping;
    _growHeight = n.growHeight;
    _lightDirection = n.lightDirection;
    final j = n.jelly;
    _stiffness = j.stiffness;
    _damping = j.damping;
    _maxVelocity = j.maxVelocity;
    _stretchWidth = j.stretchWidth;
    _squashHeight = j.squashHeight;
    _anchorBias = j.anchorBias;
    _recoilScale = j.recoilScale;
    _recoilAnchor = j.recoilAnchor;
    _directionTau = j.directionTau;
    _bgOpacity = n.background.a;
    _bgBase = n.background.withValues(alpha: 1);
  }

  LiquidGlassJellyConfig get _jelly => LiquidGlassJellyConfig(
        style: LiquidGlassJellyStyle.squashStretch,
        stiffness: _stiffness,
        damping: _damping,
        maxVelocity: _maxVelocity,
        velocityClamp: 60,
        stretchWidth: _stretchWidth,
        squashHeight: _squashHeight,
        anchorBias: _anchorBias,
        recoilScale: _recoilScale,
        recoilAnchor: _recoilAnchor,
        directionTau: _directionTau,
      );

  Color get _bg => _bgBase.withValues(alpha: _bgOpacity);

  NavTuning get _tuning => NavTuning(
        jelly: _jelly,
        travelStiffness: _travelStiffness,
        travelDamping: _travelDamping,
        growHeight: _growHeight,
        lightDirection: _lightDirection,
        background: _bg,
      );

  double get _travelCritical => 2 * math.sqrt(_travelStiffness);

  /// Applies a local edit, then commits it to the shared in-memory store
  /// so the scaffold demo sees it.
  void _update(VoidCallback change) {
    setState(change);
    TuningStore.instance.nav.value = _tuning;
  }

  void _reset() {
    setState(() => _seedFrom(NavTuning.defaults));
    TuningStore.instance.nav.value = NavTuning.defaults;
  }

  String get _snippet => '''
LiquidGlassNavPillStyle(
  mode: LiquidGlassPillMode.both,
  animated: true,
  travelStiffness: ${_travelStiffness.round()},
  travelDamping: ${_travelDamping.toStringAsFixed(1)},
  growHeight: ${_growHeight.round()},
  jelly: const LiquidGlassJellyConfig(
    style: LiquidGlassJellyStyle.squashStretch,
    stiffness: ${_stiffness.round()},
    damping: ${_damping.toStringAsFixed(1)},
    maxVelocity: ${_maxVelocity.toStringAsFixed(1)},
    stretchWidth: ${_stretchWidth.toStringAsFixed(1)},
    squashHeight: ${_squashHeight.toStringAsFixed(1)},
    anchorBias: ${_anchorBias.toStringAsFixed(2)},
    recoilScale: ${_recoilScale.toStringAsFixed(2)},
    recoilAnchor: ${_recoilAnchor.toStringAsFixed(2)},
    directionTau: ${_directionTau.toStringAsFixed(2)},
  ),
)
// bar: lightDirection ${_lightDirection.round()}, '''
      'background 0x${_bg.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bounces = _travelDamping < _travelCritical;

    return LiquidGlassScaffold(
      appBar: LiquidGlassAppBar(
        width: width - 32,
        title: const Text('Nav Jelly Tuner'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          onPressed: Navigator.of(context).canPop()
              ? () => Navigator.of(context).pop()
              : null,
        ),
      ),
      body: TunerGradientBackground(
        child: Material(
          type: MaterialType.transparency,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.paddingOf(context).top + 84, 16, 170),
            children: [
              // ── Travel spring ─────────────────────────────────────
              TunerCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const TunerPanelTitle('Travel spring'),
                        const Spacer(),
                        TunerBadge(
                            text: bounces ? 'BOUNCES' : 'SETTLES',
                            good: !bounces),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Critical ≈ ${_travelCritical.toStringAsFixed(1)} '
                      '— below it the pill overshoots.',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white54, height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    TunerParamSlider('stiffness', _travelStiffness, 80, 600,
                        _travelStiffness.round().toString(),
                        (v) => _update(() => _travelStiffness = v)),
                    TunerParamSlider('damping', _travelDamping, 8, 48,
                        _travelDamping.toStringAsFixed(1),
                        (v) => _update(() => _travelDamping = v)),
                    TunerParamSlider('growHeight', _growHeight, 0, 40,
                        _growHeight.round().toString(),
                        (v) => _update(() => _growHeight = v)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ── Bar look ──────────────────────────────────────────
              TunerCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TunerPanelTitle('Bar look'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(
                          width: 104,
                          child: Text('background',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.white70)),
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: 10,
                            children: [
                              for (final c in _bgSwatches)
                                _Swatch(
                                  color: c,
                                  selected: c.toARGB32() == _bgBase.toARGB32(),
                                  onTap: () => _update(() => _bgBase = c),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TunerParamSlider('opacity', _bgOpacity, 0, 1,
                        '${(_bgOpacity * 100).round()}%',
                        (v) => _update(() => _bgOpacity = v)),
                    TunerParamSlider('lightDir', _lightDirection, 0, 360,
                        _lightDirection.round().toString(),
                        (v) => _update(() => _lightDirection = v)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ── Jelly ─────────────────────────────────────────────
              TunerCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TunerPanelTitle('Jelly'),
                    const SizedBox(height: 4),
                    const Text('iOS squash & stretch — the only pill model.',
                        style: TextStyle(fontSize: 12, color: Colors.white54)),
                    const SizedBox(height: 8),
                    TunerParamSlider('stiffness', _stiffness, 100, 800,
                        _stiffness.round().toString(),
                        (v) => _update(() => _stiffness = v)),
                    TunerParamSlider('damping', _damping, 5, 40,
                        _damping.toStringAsFixed(1),
                        (v) => _update(() => _damping = v)),
                    TunerParamSlider('maxVelocity', _maxVelocity, 1, 16,
                        _maxVelocity.toStringAsFixed(1),
                        (v) => _update(() => _maxVelocity = v)),
                    const Divider(color: Colors.white12, height: 24),
                    TunerParamSlider('stretchWidth', _stretchWidth, 0, 40,
                        _stretchWidth.toStringAsFixed(1),
                        (v) => _update(() => _stretchWidth = v)),
                    TunerParamSlider('squashHeight', _squashHeight, 0, 16,
                        _squashHeight.toStringAsFixed(1),
                        (v) => _update(() => _squashHeight = v)),
                    TunerParamSlider('anchorBias', _anchorBias, -1, 1,
                        _anchorBias.toStringAsFixed(2),
                        (v) => _update(() => _anchorBias = v)),
                    TunerParamSlider('recoilScale', _recoilScale, 0, 3,
                        _recoilScale.toStringAsFixed(2),
                        (v) => _update(() => _recoilScale = v)),
                    TunerParamSlider('recoilAnchor', _recoilAnchor, 0, 1,
                        _recoilAnchor.toStringAsFixed(2),
                        (v) => _update(() => _recoilAnchor = v)),
                    TunerParamSlider('directionTau', _directionTau, 0.04, 1.0,
                        _directionTau.toStringAsFixed(2),
                        (v) => _update(() => _directionTau = v)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TunerCodeCard(snippet: _snippet, onReset: _reset),
              const SizedBox(height: 8),
              const Center(
                child: Text('Tap or drag the pill below to feel it',
                    style: TextStyle(color: Colors.white38, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: LiquidGlassBottomNavBar(
        width: width - 32,
        selectedIndex: _index,
        onChanged: (i) => setState(() => _index = i),
        style: navBarStyle(_tuning),
        pillStyle: navPillStyle(_tuning),
        items: const [
          LiquidGlassTabBarItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Home'),
          LiquidGlassTabBarItem(icon: Icons.search_rounded, label: 'Search'),
          LiquidGlassTabBarItem(
              icon: Icons.favorite_border_rounded,
              selectedIcon: Icons.favorite_rounded,
              label: 'Likes'),
          LiquidGlassTabBarItem(
              icon: Icons.notifications_none_rounded,
              selectedIcon: Icons.notifications_rounded,
              label: 'Alerts'),
          LiquidGlassTabBarItem(
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: 'Profile'),
        ],
      ),
    );
  }
}

/// A tappable background-color swatch.
class _Swatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _Swatch(
      {required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? kTunerAccent : Colors.white24,
            width: selected ? 2.5 : 1,
          ),
        ),
      ),
    );
  }
}
