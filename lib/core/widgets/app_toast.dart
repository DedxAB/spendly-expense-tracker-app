import 'package:flutter/material.dart';
import 'package:spendly/core/theme/app_design_tokens.dart';

enum AppToastStyle { normal, success, error }

void showAppToast(
  BuildContext context,
  String message, {
  AppToastStyle style = AppToastStyle.normal,
  Duration duration = const Duration(seconds: 3),
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  final brightness = Theme.of(context).brightness;
  final isDark = brightness == Brightness.dark;

  final bgColor = isDark ? Colors.white : Colors.black;
  final textColor = isDark ? Colors.black : Colors.white;

  entry = OverlayEntry(
    builder: (_) => _TopToast(
      message: message,
      bgColor: bgColor,
      textColor: textColor,
      onDismiss: () => entry.remove(),
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    ),
  );

  overlay.insert(entry);
}

class _TopToast extends StatefulWidget {
  final String message;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onDismiss;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _TopToast({
    required this.message,
    required this.bgColor,
    required this.textColor,
    required this.onDismiss,
    required this.duration,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        bottom: false,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: Material(
              color: widget.bgColor,
              elevation: 10,
              shadowColor: Colors.black.withValues(alpha: 0.24),
              borderRadius: BorderRadius.zero,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: AppFontSizes.body,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                        ),
                      ),
                    ),
                    if (widget.actionLabel != null) ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          widget.onAction?.call();
                          _controller.reverse().then((_) => widget.onDismiss());
                        },
                        child: Text(
                          widget.actionLabel!,
                          style: TextStyle(
                            color: widget.textColor,
                            fontSize: AppFontSizes.label,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
