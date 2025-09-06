import 'package:flutter/material.dart';
import 'simple_logo.dart';
import 'app_logo.dart';

class LogoExamples extends StatelessWidget {
  const LogoExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logo Examples'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Simple Logo
            const Text(
              'Simple Logo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const SimpleLogo(size: 100),
            
            const SizedBox(height: 32),
            
            // Animated Logo
            const Text(
              'Animated Logo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const AnimatedLogo(size: 100),
            
            const SizedBox(height: 32),
            
            // Minimal Logo
            const Text(
              'Minimal Logo (for App Bars)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const MinimalLogo(size: 48),
            
            const SizedBox(height: 32),
            
            // Custom Logo
            const Text(
              'Custom Logo (CustomPainter)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const AppLogo(size: 100),
            
            const SizedBox(height: 32),
            
            // Gradient Logo
            const Text(
              'Gradient Logo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const GradientAppLogo(size: 100),
            
            const SizedBox(height: 32),
            
            // Different Sizes
            const Text(
              'Different Sizes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                SimpleLogo(size: 60, showText: false),
                SimpleLogo(size: 80, showText: false),
                SimpleLogo(size: 100, showText: false),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
