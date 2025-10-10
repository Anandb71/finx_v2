import 'package:flutter/material.dart';
import 'dart:math' as math;

class FluidCursorBackground extends StatefulWidget {
  final Widget child;
  
  const FluidCursorBackground({
    super.key,
    required this.child,
  });

  @override
  State<FluidCursorBackground> createState() => _FluidCursorBackgroundState();
}

class _FluidCursorBackgroundState extends State<FluidCursorBackground>
    with TickerProviderStateMixin {
  Offset _mousePosition = const Offset(0, 0);
  Offset _previousMousePosition = const Offset(0, 0);
  final List<MetaBall> _metaBalls = [];
  final List<FluidParticle> _particles = [];
  late AnimationController _physicsController;
  double _mouseVelocityX = 0;
  double _mouseVelocityY = 0;
  
  @override
  void initState() {
    super.initState();
    
    // High framerate physics simulation
    _physicsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // 60fps
    )..repeat();
    
    // Initialize metaballs with physics properties
    _initializeMetaBalls();
    
    // Initialize fluid particles
    _initializeParticles();
  }
  
  void _initializeMetaBalls() {
    final random = math.Random();
    _metaBalls.addAll([
      MetaBall(
        position: Offset(0.2, 0.3),
        velocity: Offset(random.nextDouble() - 0.5, random.nextDouble() - 0.5),
        radius: 180,
        mass: 1.5,
        color: const Color(0xFF00FFA3),
      ),
      MetaBall(
        position: Offset(0.8, 0.2),
        velocity: Offset(random.nextDouble() - 0.5, random.nextDouble() - 0.5),
        radius: 220,
        mass: 2.0,
        color: const Color(0xFF00D9FF),
      ),
      MetaBall(
        position: Offset(0.5, 0.7),
        velocity: Offset(random.nextDouble() - 0.5, random.nextDouble() - 0.5),
        radius: 160,
        mass: 1.2,
        color: const Color(0xFF9D4EDD),
      ),
      MetaBall(
        position: Offset(0.1, 0.8),
        velocity: Offset(random.nextDouble() - 0.5, random.nextDouble() - 0.5),
        radius: 200,
        mass: 1.8,
        color: const Color(0xFFFF006E),
      ),
      MetaBall(
        position: Offset(0.6, 0.4),
        velocity: Offset(random.nextDouble() - 0.5, random.nextDouble() - 0.5),
        radius: 140,
        mass: 1.0,
        color: const Color(0xFFFFBE0B),
      ),
    ]);
  }
  
  void _initializeParticles() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _particles.add(FluidParticle(
        position: Offset(random.nextDouble(), random.nextDouble()),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 0.2,
          (random.nextDouble() - 0.5) * 0.2,
        ),
        radius: random.nextDouble() * 3 + 1,
        opacity: random.nextDouble() * 0.3 + 0.2,
      ));
    }
  }
  
  @override
  void dispose() {
    _physicsController.dispose();
    super.dispose();
  }
  
  void _updatePhysics(Size size) {
    // Calculate mouse velocity
    _mouseVelocityX = (_mousePosition.dx - _previousMousePosition.dx) * 0.5;
    _mouseVelocityY = (_mousePosition.dy - _previousMousePosition.dy) * 0.5;
    _previousMousePosition = _mousePosition;
    
    // Update metaballs with physics
    for (var ball in _metaBalls) {
      // Calculate attraction to mouse
      final ballPos = Offset(
        ball.position.dx * size.width,
        ball.position.dy * size.height,
      );
      final toMouse = _mousePosition - ballPos;
      final distance = toMouse.distance;
      
      if (distance > 0 && distance < 400) {
        // Strong magnetic attraction with velocity influence
        final force = (400 - distance) / 400;
        final attraction = toMouse / distance * force * 0.8;
        ball.velocity += attraction;
        
        // Add mouse velocity influence (liquid drag effect)
        ball.velocity += Offset(_mouseVelocityX, _mouseVelocityY) * 0.15;
      }
      
      // Apply velocity with damping
      ball.position += ball.velocity * 0.002;
      ball.velocity *= 0.95; // Damping
      
      // Bounce off edges with energy loss
      if (ball.position.dx < 0 || ball.position.dx > 1) {
        ball.velocity = Offset(-ball.velocity.dx * 0.8, ball.velocity.dy);
        ball.position = Offset(ball.position.dx.clamp(0, 1), ball.position.dy);
      }
      if (ball.position.dy < 0 || ball.position.dy > 1) {
        ball.velocity = Offset(ball.velocity.dx, -ball.velocity.dy * 0.8);
        ball.position = Offset(ball.position.dx, ball.position.dy.clamp(0, 1));
      }
      
      // Metaball interactions (repulsion when too close)
      for (var other in _metaBalls) {
        if (ball != other) {
          final otherPos = Offset(
            other.position.dx * size.width,
            other.position.dy * size.height,
          );
          final toBall = ballPos - otherPos;
          final dist = toBall.distance;
          final minDist = (ball.radius + other.radius) * 0.5;
          
          if (dist < minDist && dist > 0) {
            final repulsion = toBall / dist * (minDist - dist) * 0.001;
            ball.velocity += repulsion / ball.mass;
            other.velocity -= repulsion / other.mass;
          }
        }
      }
    }
    
    // Update fluid particles
    for (var particle in _particles) {
      // Particle attraction to mouse
      final particlePos = Offset(
        particle.position.dx * size.width,
        particle.position.dy * size.height,
      );
      final toMouse = _mousePosition - particlePos;
      final distance = toMouse.distance;
      
      if (distance > 0 && distance < 300) {
        final force = (300 - distance) / 300;
        final attraction = toMouse / distance * force * 0.3;
        particle.velocity += attraction * 0.001;
      }
      
      // Apply velocity
      particle.position += particle.velocity * 0.01;
      particle.velocity *= 0.98;
      
      // Wrap around edges
      if (particle.position.dx < 0) particle.position = Offset(1, particle.position.dy);
      if (particle.position.dx > 1) particle.position = Offset(0, particle.position.dy);
      if (particle.position.dy < 0) particle.position = Offset(particle.position.dx, 1);
      if (particle.position.dy > 1) particle.position = Offset(particle.position.dx, 0);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        setState(() {
          _mousePosition = event.position;
        });
      },
      child: Stack(
        children: [
          // Fluid background layer (behind everything)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _physicsController,
              builder: (context, child) {
                final size = MediaQuery.of(context).size;
                _updatePhysics(size);
                
                return CustomPaint(
                  painter: AdvancedFluidPainter(
                    mousePosition: _mousePosition,
                    metaBalls: _metaBalls,
                    particles: _particles,
                    mouseVelocity: Offset(_mouseVelocityX, _mouseVelocityY),
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
          
          // Content layer (above fluid)
          widget.child,
        ],
      ),
    );
  }
}

class MetaBall {
  Offset position;
  Offset velocity;
  final double radius;
  final double mass;
  final Color color;
  
  MetaBall({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.mass,
    required this.color,
  });
}

class FluidParticle {
  Offset position;
  Offset velocity;
  final double radius;
  final double opacity;
  
  FluidParticle({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.opacity,
  });
}

class AdvancedFluidPainter extends CustomPainter {
  final Offset mousePosition;
  final List<MetaBall> metaBalls;
  final List<FluidParticle> particles;
  final Offset mouseVelocity;
  
  AdvancedFluidPainter({
    required this.mousePosition,
    required this.metaBalls,
    required this.particles,
    required this.mouseVelocity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Dark gradient background
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF0A0E27),
        const Color(0xFF1A1F3A),
        const Color(0xFF0F1419),
      ],
    );
    
    final bgPaint = Paint()..shader = bgGradient.createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);
    
    // Draw metaballs with metaball blending effect
    canvas.saveLayer(bgRect, Paint());
    
    for (var ball in metaBalls) {
      final ballX = ball.position.dx * size.width;
      final ballY = ball.position.dy * size.height;
      
      // Calculate distance from mouse for intensity
      final toMouse = mousePosition - Offset(ballX, ballY);
      final distance = toMouse.distance;
      final intensity = (1 - (distance / 400).clamp(0.0, 1.0)) * 0.4;
      
      // Enhanced radius based on mouse proximity
      final enhancedRadius = ball.radius * (1 + intensity);
      
      // Multiple gradient layers for depth
      for (int i = 3; i >= 0; i--) {
        final layerRadius = enhancedRadius * (1 + i * 0.3);
        final layerOpacity = (1.0 - i * 0.25) * 0.4;
        
        final gradient = RadialGradient(
          colors: [
            ball.color.withOpacity(layerOpacity),
            ball.color.withOpacity(layerOpacity * 0.6),
            ball.color.withOpacity(layerOpacity * 0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        );
        
        final paint = Paint()
          ..shader = gradient.createShader(
            Rect.fromCircle(
              center: Offset(ballX, ballY),
              radius: layerRadius,
            ),
          )
          ..blendMode = BlendMode.screen
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 40 + i * 20);
        
        canvas.drawCircle(Offset(ballX, ballY), layerRadius, paint);
      }
      
      // Core glow
      final corePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            ball.color.withOpacity(0.8),
            ball.color.withOpacity(0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(ballX, ballY),
            radius: ball.radius * 0.5,
          ),
        )
        ..blendMode = BlendMode.screen
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
      
      canvas.drawCircle(Offset(ballX, ballY), ball.radius * 0.5, corePaint);
    }
    
    canvas.restore();
    
    // Draw cursor follower with velocity trail
    final cursorRadius = 120.0 + mouseVelocity.distance * 2;
    final velocityAngle = math.atan2(mouseVelocity.dy, mouseVelocity.dx);
    
    // Velocity-based ellipse
    canvas.save();
    canvas.translate(mousePosition.dx, mousePosition.dy);
    canvas.rotate(velocityAngle);
    
    final cursorGradient = RadialGradient(
      colors: [
        const Color(0xFF00FFA3).withOpacity(0.6),
        const Color(0xFF00D9FF).withOpacity(0.4),
        const Color(0xFF9D4EDD).withOpacity(0.2),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );
    
    final cursorPaint = Paint()
      ..shader = cursorGradient.createShader(
        Rect.fromCenter(
          center: Offset.zero,
          width: cursorRadius * 2,
          height: cursorRadius * 2,
        ),
      )
      ..blendMode = BlendMode.screen
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: cursorRadius * 2,
        height: cursorRadius * (1 + mouseVelocity.distance * 0.01),
      ),
      cursorPaint,
    );
    
    canvas.restore();
    
    // Draw fluid particles
    for (var particle in particles) {
      final particleX = particle.position.dx * size.width;
      final particleY = particle.position.dy * size.height;
      
      final particlePaint = Paint()
        ..color = const Color(0xFF00FFA3).withOpacity(particle.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.radius * 2);
      
      canvas.drawCircle(
        Offset(particleX, particleY),
        particle.radius,
        particlePaint,
      );
    }
    
    // Draw connecting tendrils between nearby metaballs
    for (int i = 0; i < metaBalls.length; i++) {
      for (int j = i + 1; j < metaBalls.length; j++) {
        final ball1 = metaBalls[i];
        final ball2 = metaBalls[j];
        
        final pos1 = Offset(
          ball1.position.dx * size.width,
          ball1.position.dy * size.height,
        );
        final pos2 = Offset(
          ball2.position.dx * size.width,
          ball2.position.dy * size.height,
        );
        
        final distance = (pos1 - pos2).distance;
        final maxDist = 350.0;
        
        if (distance < maxDist) {
          final strength = (1 - distance / maxDist);
          final opacity = strength * 0.3;
          
          // Draw gradient line
          final path = Path()
            ..moveTo(pos1.dx, pos1.dy)
            ..quadraticBezierTo(
              (pos1.dx + pos2.dx) / 2,
              (pos1.dy + pos2.dy) / 2 - 50 * strength,
              pos2.dx,
              pos2.dy,
            );
          
          final paint = Paint()
            ..shader = LinearGradient(
              colors: [
                ball1.color.withOpacity(opacity),
                ball2.color.withOpacity(opacity),
              ],
            ).createShader(Rect.fromPoints(pos1, pos2))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3 * strength
            ..blendMode = BlendMode.screen
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20 * strength);
          
          canvas.drawPath(path, paint);
        }
      }
    }
    
    // Add chromatic aberration effect near cursor
    _drawChromaticAberration(canvas, size);
  }
  
  void _drawChromaticAberration(Canvas canvas, Size size) {
    final aberrationRadius = 200.0;
    
    final redPaint = Paint()
      ..color = const Color(0xFFFF0000).withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40)
      ..blendMode = BlendMode.screen;
    
    final bluePaint = Paint()
      ..color = const Color(0xFF0000FF).withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40)
      ..blendMode = BlendMode.screen;
    
    canvas.drawCircle(
      mousePosition + const Offset(-5, -5),
      aberrationRadius,
      redPaint,
    );
    
    canvas.drawCircle(
      mousePosition + const Offset(5, 5),
      aberrationRadius,
      bluePaint,
    );
  }
  
  @override
  bool shouldRepaint(AdvancedFluidPainter oldDelegate) => true;
}
