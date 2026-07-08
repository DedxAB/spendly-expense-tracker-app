import 'package:flutter/material.dart';

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

  final bgColor = switch (style) {
    AppToastStyle.success => const Color(0xFF1A3A2A),
    AppToastStyle.error => const Color(0xFF3D1D1D),
    AppToastStyle.normal => const Color(0xFF1A1A1A),
  };

  final textColor = Colors.white;

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
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

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
    final topPadding = MediaQuery.of(context).padding.top;
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: EdgeInsets.only(top: topPadding),
            color: widget.bgColor,
            width: double.infinity,
            child: SafeArea(
              bottom: false,
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                    if (widget.actionLabel != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          widget.onAction?.call();
                          _controller.reverse().then((_) => widget.onDismiss());
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.actionLabel!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
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
