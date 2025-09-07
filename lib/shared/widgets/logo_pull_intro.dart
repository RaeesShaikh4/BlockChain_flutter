import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simple_logo.dart';

/// An intro animation where a person pulls the logo to horizontal center,
/// then leans slightly toward it when centered.
class LogoPullIntro extends StatefulWidget {
  final double height;
  final double logoSize;
  final Duration pullDuration;
  final Duration leanDuration;
  final bool showText;

  const LogoPullIntro({
    super.key,
    this.height = 180,
    this.logoSize = 120,
    this.pullDuration = const Duration(milliseconds: 3000),
    this.leanDuration = const Duration(milliseconds: 300),
    this.showText = true,
  });

  @override
  State<LogoPullIntro> createState() => _LogoPullIntroState();
}

class _LogoPullIntroState extends State<LogoPullIntro>
    with TickerProviderStateMixin {
  late AnimationController _pullController;
  late AnimationController _leanController;
  late AnimationController _walkController;
  late Animation<double> _pull;
  late Animation<double> _lean;
  late Animation<double> _walk;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _pullController = AnimationController(
      vsync: this,
      duration: widget.pullDuration,
    );
    _leanController = AnimationController(
      vsync: this,
      duration: widget.leanDuration,
    );
    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _pull =
        CurvedAnimation(parent: _pullController, curve: Curves.easeOutCubic);
    _lean = CurvedAnimation(parent: _leanController, curve: Curves.easeOut);
    _walk = CurvedAnimation(parent: _walkController, curve: Curves.linear);

    _pullController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _leanController.forward();
        _walkController.stop();
      }
    });

    // Start automatically after first frame to ensure layout is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_started) {
        _started = true;
        _pullController.forward(from: 0);
        _walkController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _pullController.dispose();
    _leanController.dispose();
    _walkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height + (widget.showText ? 40 : 0),
      width: double.infinity,
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_pullController, _leanController, _walkController]),
        builder: (context, child) {
          final size = MediaQuery.of(context).size;

          final centerX = size.width / 2;

          // Person size (stick figure)
          const personWidth = 56.0;

          // Final total width = logo + rope + person
          final totalWidth =
              widget.logoSize + personWidth + 40; // 40 = rope (adjustable)

          // Starting logo X (off-screen left)
          final startX = -widget.logoSize * 1.8;

          // Ending system aligned to screen center
          final endLogoX = centerX - totalWidth / 2;

          // Animate logo from start to centered position
          final logoX = lerpDouble(startX, endLogoX, _pull.value)!;

          // Person always sits to the right of logo + rope
          final ropeLength = 40.0; // constant, visually nice
          final personX = logoX + widget.logoSize + ropeLength;

          // Person lean calculation (unchanged)
          final baseLean = (0.12 * (1 - _pull.value));
          final personLean = baseLean + _lean.value * 0.25;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Rope line
              Positioned(
                top: widget.height / 2,
                left: logoX + (widget.logoSize * 0.5),
                width: (personX - (logoX + (widget.logoSize * 0.5)))
                    .clamp(0, size.width),
                child: Container(
                  height: 2,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                ),
              ),

              // Person icon pulling
              Positioned(
                top: widget.height / 2 - 24,
                left: personX,
                child: PersonPuller(
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                  leanRadians: personLean,
                  stridePhase: _walk.value,
                  pulling: _pull.value < 1.0,
                  ropeToRight: false, // rope goes to the left toward logo
                ),
              ),

              // Logo moving to center
              Positioned(
                top: 0,
                left: logoX,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedOpacity(
                      opacity: _pull.value.clamp(0.0, 1.0),
                      duration: const Duration(milliseconds: 200),
                      child: AnimatedScale(
                        scale: 0.92 + (_lean.value * 0.08),
                        duration: const Duration(milliseconds: 200),
                        child: AnimatedLogo(
                          size: widget.logoSize,
                          showText: false,
                        ),
                      ),
                    ),
                    if (widget.showText) ...[
                      const SizedBox(height: 12),
                      AnimatedOpacity(
                        opacity: _lean.value,
                        duration: const Duration(milliseconds: 250),
                        child: AnimatedPadding(
                          duration: const Duration(milliseconds: 250),
                          padding: EdgeInsets.only(top: (1 - _lean.value) * 8),
                          child: Text(
                            'SecureChain',
                            style: TextStyle(
                              fontSize: widget.logoSize * 0.2,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double? lerpDouble(num? a, num? b, double t) {
    if (a == null && b == null) return null;
    a ??= 0.0;
    b ??= 0.0;
    return a + (b - a) * t;
  }
}

/// Simple animated stick-figure pulling character.
class PersonPuller extends StatelessWidget {
  final double size;
  final Color color;
  final double leanRadians;
  final double stridePhase; // 0..1
  final bool pulling;
  final bool ropeToRight; // true if rope points to right, false for left

  const PersonPuller({
    super.key,
    required this.size,
    required this.color,
    required this.leanRadians,
    required this.stridePhase,
    required this.pulling,
    this.ropeToRight = true,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: leanRadians,
      alignment: Alignment.bottomCenter,
      child: CustomPaint(
        painter: _PersonPainter(
          color: color,
          phase: stridePhase,
          pulling: pulling,
          ropeToRight: ropeToRight,
        ),
        size: Size(size, size),
      ),
    );
  }
}

class _PersonPainter extends CustomPainter {
  final Color color;
  final double phase; // 0..1
  final bool pulling;
  final bool ropeToRight;

  _PersonPainter({
    required this.color,
    required this.phase,
    required this.pulling,
    required this.ropeToRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width * 0.5;
    final groundY = size.height * 0.9;

    // Body proportions
    final headR = size.width * 0.12;
    final torsoLen = size.height * 0.32;
    final legLen = size.height * 0.34;
    final armLen = size.height * 0.28;

    // Stride animation using sine wave
    final t = phase * 2 * math.pi;
    final step = math.sin(t);

    // Hips oscillate a bit vertically during walking
    final hipY = groundY - legLen;
    final hipYOffset = pulling ? (math.sin(t * 2) * 1.0) : 0.0;

    final hip = Offset(centerX, hipY + hipYOffset);
    final neck = Offset(centerX, hip.dy - torsoLen);
    final headCenter = Offset(neck.dx, neck.dy - headR * 1.6);

    // Legs: front leg forward, back leg backward relative to rope direction (to the right)
    final frontKnee = Offset(hip.dx + step * 6, hip.dy + legLen * 0.45);
    final backKnee = Offset(hip.dx - step * 6, hip.dy + legLen * 0.4);
    final frontFoot = Offset(frontKnee.dx + 10, groundY);
    final backFoot = Offset(backKnee.dx - 10, groundY);

    // Arms: both stretched toward the rope (to the right), with slight alternate motion
    final armSwing = math.sin(t + math.pi / 2) * 4;
    final ropeDir = ropeToRight ? 1.0 : -1.0;
    final leftHand =
        Offset(neck.dx + ropeDir * (armLen + 6), neck.dy + armSwing * 0.2);
    final rightHand =
        Offset(neck.dx + ropeDir * (armLen - 2), neck.dy - armSwing * 0.1);

    // Draw head
    canvas.drawCircle(headCenter, headR, paint);

    // Draw torso
    canvas.drawLine(neck, hip, paint);

    // Draw legs
    canvas.drawLine(hip, frontKnee, paint);
    canvas.drawLine(frontKnee, frontFoot, paint);
    canvas.drawLine(hip, backKnee, paint);
    canvas.drawLine(backKnee, backFoot, paint);

    // Draw arms
    canvas.drawLine(neck, leftHand, paint);
    canvas.drawLine(neck, rightHand, paint);

    // Optional: small ground line under feet for context
    canvas.drawLine(
      Offset(centerX - 18, groundY + 1),
      Offset(centerX + 22, groundY + 1),
      paint..strokeWidth = 1.5,
    );

    // Small handle to suggest rope grip at hands (to the right)
    final handleY = (leftHand.dy + rightHand.dy) / 2;
    canvas.drawLine(
      Offset(leftHand.dx - 6 * ropeDir, handleY),
      Offset(leftHand.dx + 6 * ropeDir, handleY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PersonPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.color != color ||
        oldDelegate.pulling != pulling;
  }
}
