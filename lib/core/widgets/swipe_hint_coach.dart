import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/database/app_flags_provider.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';
import 'package:spendly/core/theme/app_icons.dart';

const _kCoachGreen = Color(0xFF38D97A);
const _kCoachRed = Color(0xFFFF5C6C);
const _kCoachGreenTint = Color(0xFF0F2A1C);
const _kCoachRedTint = Color(0xFF2A1313);
const _kCoachGreenLight = Color(0xFF0E9C58);
const _kCoachRedLight = Color(0xFFE03550);
const _kCoachGreenTintLight = Color(0xFFE7F7EE);
const _kCoachRedTintLight = Color(0xFFFDE7EA);

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _green(BuildContext context) =>
    _isDark(context) ? _kCoachGreen : _kCoachGreenLight;

Color _red(BuildContext context) =>
    _isDark(context) ? _kCoachRed : _kCoachRedLight;

Color _greenTint(BuildContext context) =>
    _isDark(context) ? _kCoachGreenTint : _kCoachGreenTintLight;

Color _redTint(BuildContext context) =>
    _isDark(context) ? _kCoachRedTint : _kCoachRedTintLight;

/// Wraps a swipeable card and, when the user has not seen the swipe hint
/// before (once per install), plays a "coach peek": the real card slides
/// right revealing the edit background, settles, then slides left revealing
/// the delete background, settles, while a tip pill fades in on the card.
///
/// Place it around the *first* [Dismissible]'s child and pass
/// [enabled] = whether swipeable rows are present.
class SwipeHintCoach extends ConsumerStatefulWidget {
  const SwipeHintCoach({
    super.key,
    required this.child,
    this.enabled = true,
    this.peekFraction = 0.26,
  });

  final Widget child;

  /// Set to false when there are no rows to swipe (empty state), so the
  /// hint never shows against an empty list.
  final bool enabled;

  /// Fraction of the card width revealed during the peek (0..1).
  final double peekFraction;

  @override
  ConsumerState<SwipeHintCoach> createState() => _SwipeHintCoachState();
}

class _SwipeHintCoachState extends ConsumerState<SwipeHintCoach>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  )
    ..addStatusListener(_onAnimationStatus);

  late final Animation<double> _offset = _controller.drive(
    TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 16,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 10),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: 16,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 12),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -1).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: 16,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(-1), weight: 10),
      TweenSequenceItem(
        tween: Tween<double>(begin: -1, end: 0).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: 16,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 4),
    ]),
  );

  late final Animation<double> _pillOpacity = _controller.drive(
    TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 8,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 82),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0).chain(
          CurveTween(curve: Curves.easeInCubic),
        ),
        weight: 10,
      ),
    ]),
  );

  bool _shown = false;
  bool _hintSeen = false;

  @override
  void initState() {
    super.initState();
    _hintSeen = ref.read(swipeHintSeenProvider).valueOrNull ?? true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _hintSeen == false) {
      setState(() => _shown = true);
      ref.read(swipeHintSeenActionsProvider)();
    }
  }

  @override
  Widget build(BuildContext context) {
    final seen = ref.watch(swipeHintSeenProvider).valueOrNull ?? _hintSeen;
    if (seen || _shown || !widget.enabled) {
      return widget.child;
    }

    if (!_controller.isAnimating && _controller.value == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_shown && !seen) _controller.forward();
      });
    }

    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return AnimatedBuilder(
            animation: _offset,
            builder: (context, child) {
              final dx = _offset.value * width * widget.peekFraction;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Transform.translate(
                    offset: Offset(dx, 0),
                    child: child,
                  ),
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: FadeTransition(
                        opacity: _pillOpacity,
                        child: Center(child: _SwipeHintPill()),
                      ),
                    ),
                  ),
                ],
              );
            },
            child: widget.child,
          );
        },
      ),
    );
  }
}

class _SwipeHintPill extends StatelessWidget {
  const _SwipeHintPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.surface.withValues(alpha: 0.95),
        border: Border.all(color: context.border),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillChip(
            color: _green(context),
            tint: _greenTint(context),
            icon: AppIcons.edit,
            label: 'Swipe right to edit',
          ),
          Container(
            width: 1,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: context.border,
          ),
          _PillChip(
            color: _red(context),
            tint: _redTint(context),
            icon: AppIcons.trash,
            label: 'Swipe left to delete',
          ),
        ],
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.color,
    required this.tint,
    required this.icon,
    required this.label,
  });

  final Color color;
  final Color tint;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Icon(icon, size: 12, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSizes.label,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}