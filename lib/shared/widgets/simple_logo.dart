import 'package:flutter/material.dart';

class SimpleLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const SimpleLogo({
    super.key,
    this.size = 100.0,
    this.showText = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Theme.of(context).primaryColor;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon with blockchain and shield
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: primaryColor,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              // Shield icon
              Center(
                child: Icon(
                  Icons.shield,
                  size: size * 0.4,
                  color: primaryColor,
                ),
              ),
              // Blockchain links
              Positioned(
                top: size * 0.2,
                left: size * 0.15,
                child: Row(
                  children: [
                    _buildBlock(size * 0.08, primaryColor),
                    SizedBox(width: size * 0.05),
                    _buildBlock(size * 0.08, primaryColor),
                    SizedBox(width: size * 0.05),
                    _buildBlock(size * 0.08, primaryColor),
                  ],
                ),
              ),
              // Crypto diamond
              Positioned(
                bottom: size * 0.25,
                right: size * 0.2,
                child: Icon(
                  Icons.diamond,
                  size: size * 0.15,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'SecureChain',
            style: TextStyle(
              fontSize: size * 0.2,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          Text(
            'Blockchain Wallet',
            style: TextStyle(
              fontSize: size * 0.12,
              color: primaryColor.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBlock(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// Minimal logo for app bars
class MinimalLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const MinimalLogo({
    super.key,
    this.size = 32.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Theme.of(context).primaryColor;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.shield,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}

// Animated logo
class AnimatedLogo extends StatefulWidget {
  final double size;
  final bool showText;
  final Color? color;

  const AnimatedLogo({
    super.key,
    this.size = 100.0,
    this.showText = true,
    this.color,
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.color ?? Theme.of(context).primaryColor;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1 + (_animation.value * 0.1)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryColor.withOpacity(0.5 + (_animation.value * 0.5)),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3 * _animation.value),
                    blurRadius: 20 * _animation.value,
                    offset: Offset(0, 10 * _animation.value),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.shield,
                      size: widget.size * 0.4,
                      color: primaryColor,
                    ),
                  ),
                  Positioned(
                    top: widget.size * 0.2,
                    left: widget.size * 0.15,
                    child: Row(
                      children: [
                        _buildBlock(widget.size * 0.08, primaryColor),
                        SizedBox(width: widget.size * 0.05),
                        _buildBlock(widget.size * 0.08, primaryColor),
                        SizedBox(width: widget.size * 0.05),
                        _buildBlock(widget.size * 0.08, primaryColor),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: widget.size * 0.25,
                    right: widget.size * 0.2,
                    child: Icon(
                      Icons.diamond,
                      size: widget.size * 0.15,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.showText) ...[
              const SizedBox(height: 12),
              Text(
                'SecureChain',
                style: TextStyle(
                  fontSize: widget.size * 0.2,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Text(
                'Blockchain Wallet',
                style: TextStyle(
                  fontSize: widget.size * 0.12,
                  color: primaryColor.withOpacity(0.7),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBlock(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
