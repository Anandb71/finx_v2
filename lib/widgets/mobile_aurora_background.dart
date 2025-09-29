// lib/widgets/mobile_aurora_background.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:finx_v2/utils/gyroscope_parallax.dart';

class MobileAuroraBackground extends StatefulWidget {
  final GyroscopeParallaxController? gyroController;

  const MobileAuroraBackground({Key? key, this.gyroController})
    : super(key: key);

  @override
  State<MobileAuroraBackground> createState() => _MobileAuroraBackgroundState();
}

class _MobileAuroraBackgroundState extends State<MobileAuroraBackground>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _glowController;
  List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _initializeParticles();
    _particleController.repeat();
    _glowController.repeat(reverse: true);
  }

  void _initializeParticles() {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 800;
    final particleCount = isMobile ? 15 : 30; // 50% reduction on mobile

    _particles = List.generate(particleCount, (index) {
      return Particle(
        id: index,
        x: _random.nextDouble() * screenSize.width,
        y: _random.nextDouble() * screenSize.height,
        size: _random.nextDouble() * 3 + 1, // 1-4px size
        opacity: _random.nextDouble() * 0.8 + 0.2, // 0.2-1.0 opacity
        speed: _random.nextDouble() * 0.5 + 0.1, // 0.1-0.6 speed
        direction: _random.nextDouble() * 2 * pi,
      );
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    Widget background = AnimatedBuilder(
      animation: Listenable.merge([_particleController, _glowController]),
      builder: (context, child) {
        return CustomPaint(
          size: screenSize,
          painter: AuroraPainter(
            particles: _particles,
            animationValue: _particleController.value,
            glowValue: _glowController.value,
          ),
        );
      },
    );

    // Apply gyroscope parallax if controller is provided
    if (widget.gyroController != null) {
      background = ParallaxBackground(
        controller: widget.gyroController!,
        child: background,
      );
    }

    return Positioned.fill(child: background);
  }
}

class Particle {
  final int id;
  double x;
  double y;
  final double size;
  final double opacity;
  final double speed;
  final double direction;

  Particle({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.direction,
  });
}

class AuroraPainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final double glowValue;

  AuroraPainter({
    required this.particles,
    required this.animationValue,
    required this.glowValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF00FF88); // Neon green

    for (final particle in particles) {
      // Update particle position
      final newX =
          (particle.x + cos(particle.direction) * particle.speed) % size.width;
      final newY =
          (particle.y + sin(particle.direction) * particle.speed) % size.height;

      particle.x = newX;
      particle.y = newY;

      // Calculate glow effect
      final glowIntensity = 0.3 + (glowValue * 0.2);
      final currentOpacity = particle.opacity * glowIntensity;

      // Draw particle with glow
      paint.color = const Color(0xFF00FF88).withOpacity(currentOpacity);
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);

      // Add subtle glow ring
      paint.color = const Color(0xFF00FF88).withOpacity(currentOpacity * 0.3);
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(AuroraPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.glowValue != glowValue;
  }
}


