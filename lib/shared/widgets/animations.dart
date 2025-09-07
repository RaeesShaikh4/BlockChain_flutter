import 'package:flutter/material.dart';

/// A reusable shake animation for error feedback (e.g., wrong PIN).
class Shake extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;
  final bool animate;

  const Shake({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.offset = 12,
    this.animate = false,
  });

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -1, end: 1), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1, end: -1), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -1, end: 1), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant Shake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value * widget.offset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Simple fade + slide in from bottom for dialog/body sections.
class FadeSlide extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double beginOffsetY;
  final Curve curve;

  const FadeSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.beginOffsetY = 0.08,
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 100 * beginOffsetY),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Tap scale for buttons.
class TapScale extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;
  final VoidCallback? onTap;

  const TapScale({
    super.key,
    required this.child,
    this.scale = 0.96,
    this.duration = const Duration(milliseconds: 90),
    this.onTap,
  });

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// A quick success check animation (scale + fade).
class SuccessCheck extends StatelessWidget {
  final Color color;
  final double size;
  final Duration duration;

  const SuccessCheck({
    super.key,
    this.color = Colors.green,
    this.size = 48,
    this.duration = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1),
      duration: duration,
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: (value - 0.6).clamp(0, 1),
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: Icon(Icons.check_circle, color: color, size: size),
    );
  }
}



