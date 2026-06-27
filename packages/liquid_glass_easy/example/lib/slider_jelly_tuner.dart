import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

import 'tuner_widgets.dart';
import 'tuning_store.dart';

// =============================================================
// Slider Jelly Tuner — a live playground for the LiquidGlassSlider thumb.
//
//   flutter run -t lib/slider_jelly_tuner.dart   (standalone)
//   …or open it from the home menu.
//
// Every knob writes into the shared [TuningStore.slider], so the live
// slider below reacts AND the Slider & Toggle page picks up the same
// values (in memory, this session) — tune here, record the GIF there.
// =============================================================

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _SliderTunerApp());
}

class _SliderTunerApp extends StatelessWidget {
  const _SliderTunerApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const SliderJellyTunerPage(),
    );
  }
}

/// Live tuner for the [LiquidGlassSlider] thumb jelly. Writes to
/// [TuningStore.slider]; pushable as its own route from the home menu.
class SliderJellyTunerPage extends StatefulWidget {
  const SliderJellyTunerPage({super.key});

  @override
  State<SliderJellyTunerPage> createState() => _SliderJellyTunerPageState();
}

class _SliderJellyTunerPageState extends State<SliderJellyTunerPage> {
  double _value = 0.5;

  late double _stiffness;
  late double _damping;
  late double _maxVelocity;
  late double _stretchWidth;
  late double _squashHeight;
  late double _anchorBias;
  late double _recoilScale;
  late double _recoilAnchor;
  late double _directionTau;

  @override
  void initState() {
    super.initState();
    _seedFrom(TuningStore.instance.slider.value.jelly);
  }

  void _seedFrom(LiquidGlassJellyConfig j) {
    _stiffness = j.stiffness;
    _damping = j.damping;
    _maxVelocity = j.maxVelocity;
    _stretchWidth = j.stretchWidth;
    _squashHeight = j.squashHeight;
    _anchorBias = j.anchorBias;
    _recoilScale = j.recoilScale;
    _recoilAnchor = j.recoilAnchor;
    _directionTau = j.directionTau;
  }

  LiquidGlassJellyConfig get _jelly => LiquidGlassJellyConfig(
        style: LiquidGlassJellyStyle.squashStretch,
        stiffness: _stiffness,
        damping: _damping,
        maxVelocity: _maxVelocity,
        stretchWidth: _stretchWidth,
        squashHeight: _squashHeight,
        anchorBias: _anchorBias,
        recoilScale: _recoilScale,
        recoilAnchor: _recoilAnchor,
        directionTau: _directionTau,
      );

  /// Applies a local edit then commits it to the shared in-memory store.
  void _update(VoidCallback change) {
    setState(change);
    TuningStore.instance.slider.value = SliderTuning(jelly: _jelly);
  }

  void _reset() {
    setState(() => _seedFrom(SliderTuning.defaults.jelly));
    TuningStore.instance.slider.value = SliderTuning.defaults;
  }

  String get _snippet => '''
LiquidGlassSlider(
  value: _value,
  onChanged: (v) => setState(() => _value = v),
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
)''';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final sliderW = math.min(320.0, width - 96);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Slider Jelly Tuner'),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: TunerGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // Live slider — feeds straight off the knobs below.
              TunerCard(
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: TunerPanelTitle('Live slider'),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: SizedBox(
                        width: sliderW,
                        child: LiquidGlassSlider(
                          value: _value,
                          onChanged: (v) => setState(() => _value = v),
                          layout: LiquidGlassSliderLayout(width: sliderW),
                          jelly: _jelly,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        'Drag fast, then release — the thumb should jelly.',
                        style:
                            TextStyle(fontSize: 12, color: Colors.white54)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TunerCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TunerPanelTitle('Jelly'),
                    const SizedBox(height: 4),
                    const Text('iOS squash & stretch — the only slider model.',
                        style: TextStyle(fontSize: 12, color: Colors.white54)),
                    const SizedBox(height: 8),
                    TunerParamSlider('stiffness', _stiffness, 100, 800,
                        _stiffness.round().toString(),
                        (v) => _update(() => _stiffness = v)),
                    TunerParamSlider('damping', _damping, 5, 40,
                        _damping.toStringAsFixed(1),
                        (v) => _update(() => _damping = v)),
                    TunerParamSlider('maxVelocity', _maxVelocity, 0.5, 4,
                        _maxVelocity.toStringAsFixed(1),
                        (v) => _update(() => _maxVelocity = v)),
                    const Divider(color: Colors.white12, height: 24),
                    TunerParamSlider('stretchWidth', _stretchWidth, 0, 40,
                        _stretchWidth.toStringAsFixed(1),
                        (v) => _update(() => _stretchWidth = v)),
                    TunerParamSlider('squashHeight', _squashHeight, 0, 24,
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
            ],
          ),
        ),
      ),
    );
  }
}
