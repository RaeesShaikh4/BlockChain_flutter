import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? primaryColor;
  final Color? secondaryColor;

  const AppLogo({
    super.key,
    this.size = 100.0,
    this.showText = true,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = primaryColor ?? const Color(0xFF2196F3);
    final secondary = secondaryColor ?? const Color(0xFF1976D2);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: LogoPainter(
            primaryColor: primary,
            secondaryColor: secondary,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 8),
          Text(
            'SecureChain',
            style: TextStyle(
              fontSize: size * 0.2,
              fontWeight: FontWeight.w600,
              color: primary,
            ),
          ),
          Text(
            'Blockchain Wallet',
            style: TextStyle(
              fontSize: size * 0.12,
              fontWeight: FontWeight.w400,
              color: primary.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }
}

class LogoPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  LogoPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Draw shield background
    paint.color = primaryColor.withOpacity(0.1);
    _drawShield(canvas, center, radius, paint);

    // Draw shield border
    paint.color = primaryColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3.0;
    _drawShield(canvas, center, radius, paint);

    // Draw blockchain links
    paint.style = PaintingStyle.fill;
    paint.color = secondaryColor;
    _drawBlockchainLinks(canvas, center, radius * 0.6);

    // Draw center diamond (crypto symbol)
    paint.color = const Color(0xFFFFD700); // Gold
    _drawDiamond(canvas, center, radius * 0.3);

    // Draw security checkmark
    paint.color = const Color(0xFF4CAF50); // Green
    paint.strokeWidth = 4.0;
    paint.style = PaintingStyle.stroke;
    _drawCheckmark(canvas, center, radius * 0.2);
  }

  void _drawShield(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final top = Offset(center.dx, center.dy - radius);
    final left = Offset(center.dx - radius * 0.6, center.dy);
    final right = Offset(center.dx + radius * 0.6, center.dy);
    final bottom = Offset(center.dx, center.dy + radius * 0.8);

    path.moveTo(top.dx, top.dy);
    path.quadraticBezierTo(
      left.dx - radius * 0.2, left.dy - radius * 0.3,
      left.dx, left.dy,
    );
    path.quadraticBezierTo(
      left.dx - radius * 0.1, bottom.dy - radius * 0.2,
      bottom.dx, bottom.dy,
    );
    path.quadraticBezierTo(
      right.dx + radius * 0.1, bottom.dy - radius * 0.2,
      right.dx, right.dy,
    );
    path.quadraticBezierTo(
      right.dx + radius * 0.2, right.dy - radius * 0.3,
      top.dx, top.dy,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawBlockchainLinks(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    // Draw 3 connected blocks
    final blockSize = radius * 0.15;
    final spacing = radius * 0.4;

    for (int i = 0; i < 3; i++) {
      final x = center.dx - spacing + (i * spacing);
      final y = center.dy - radius * 0.2;

      // Draw block
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y),
          width: blockSize,
          height: blockSize,
        ),
        paint,
      );

      // Draw connection line (except for last block)
      if (i < 2) {
        final linePaint = Paint()
          ..color = secondaryColor
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke;

        canvas.drawLine(
          Offset(x + blockSize / 2, y),
          Offset(x + spacing - blockSize / 2, y),
          linePaint,
        );
      }
    }
  }

  void _drawDiamond(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final path = Path();
    final top = Offset(center.dx, center.dy - size);
    final right = Offset(center.dx + size, center.dy);
    final bottom = Offset(center.dx, center.dy + size);
    final left = Offset(center.dx - size, center.dy);

    path.moveTo(top.dx, top.dy);
    path.lineTo(right.dx, right.dy);
    path.lineTo(bottom.dx, bottom.dy);
    path.lineTo(left.dx, left.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawCheckmark(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final start = Offset(center.dx - size * 0.6, center.dy);
    final middle = Offset(center.dx - size * 0.2, center.dy + size * 0.3);
    final end = Offset(center.dx + size * 0.6, center.dy - size * 0.3);

    path.moveTo(start.dx, start.dy);
    path.lineTo(middle.dx, middle.dy);
    path.lineTo(end.dx, end.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// App Icon Widget (for app icon)
class AppIcon extends StatelessWidget {
  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  const AppIcon({
    super.key,
    this.size = 64.0,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: LogoPainter(
        primaryColor: primaryColor ?? const Color(0xFF2196F3),
        secondaryColor: secondaryColor ?? const Color(0xFF1976D2),
      ),
    );
  }
}

// Logo with gradient background
class GradientAppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const GradientAppLogo({
    super.key,
    this.size = 100.0,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2196F3),
            Color(0xFF1976D2),
            Color(0xFF0D47A1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: AppLogo(
        size: size,
        showText: showText,
        primaryColor: Colors.white,
        secondaryColor: Colors.white.withOpacity(0.8),
      ),
    );
  }
}
