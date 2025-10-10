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
  final List<FluidBlob> _blobs = [];
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    
    // Animation for blob movement
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    
    // Initialize fluid blobs
    _initializeBlobs();
  }
  
  void _initializeBlobs() {
    _blobs.addAll([
      FluidBlob(
        position: const Offset(0.2, 0.3),
        radius: 200,
        color: const Color(0xFF00FFA3).withOpacity(0.3),
        speed: 0.5,
      ),
      FluidBlob(
        position: const Offset(0.8, 0.2),
        radius: 250,
        color: const Color(0xFF00D9FF).withOpacity(0.25),
        speed: 0.3,
      ),
      FluidBlob(
        position: const Offset(0.5, 0.7),
        radius: 180,
        color: const Color(0xFF9D4EDD).withOpacity(0.2),
        speed: 0.4,
      ),
      FluidBlob(
        position: const Offset(0.1, 0.8),
        radius: 220,
        color: const Color(0xFFFF006E).withOpacity(0.15),
        speed: 0.6,
      ),
    ]);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          // Animated gradient background
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: FluidGradientPainter(
                  mousePosition: _mousePosition,
                  blobs: _blobs,
                  animationValue: _animationController.value,
                ),
                size: Size.infinite,
              );
            },
          ),
          
          // Cursor follower effect
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            left: _mousePosition.dx - 150,
            top: _mousePosition.dy - 150,
            child: IgnorePointer(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00FFA3).withOpacity(0.15),
                      const Color(0xFF00D9FF).withOpacity(0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          
          // Main content
          widget.child,
        ],
      ),
    );
  }
}

class FluidBlob {
  Offset position;
  final double radius;
  final Color color;
  final double speed;
  
  FluidBlob({
    required this.position,
    required this.radius,
    required this.color,
    required this.speed,
  });
}

class FluidGradientPainter extends CustomPainter {
  final Offset mousePosition;
  final List<FluidBlob> blobs;
  final double animationValue;
  
  FluidGradientPainter({
    required this.mousePosition,
    required this.blobs,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Base gradient background
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
    
    final bgPaint = Paint()
      ..shader = bgGradient.createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);
    
    // Draw fluid blobs
    for (int i = 0; i < blobs.length; i++) {
      final blob = blobs[i];
      
      // Animate blob position
      final animOffset = Offset(
        math.sin(animationValue * 2 * math.pi * blob.speed + i) * 50,
        math.cos(animationValue * 2 * math.pi * blob.speed + i) * 50,
      );
      
      // Calculate blob position relative to screen size
      final blobX = blob.position.dx * size.width + animOffset.dx;
      final blobY = blob.position.dy * size.height + animOffset.dy;
      
      // Calculate distance from mouse
      final mouseDistance = (Offset(blobX, blobY) - mousePosition).distance;
      final maxDistance = 300.0;
      final influence = (1 - (mouseDistance / maxDistance).clamp(0.0, 1.0)) * 0.3;
      
      // Move blob towards mouse
      final toMouse = mousePosition - Offset(blobX, blobY);
      final influencedX = blobX + toMouse.dx * influence;
      final influencedY = blobY + toMouse.dy * influence;
      
      // Draw blob with gradient
      final blobPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            blob.color,
            blob.color.withOpacity(blob.color.opacity * 0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(influencedX, influencedY),
            radius: blob.radius * (1 + influence * 0.5),
          ),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
      
      canvas.drawCircle(
        Offset(influencedX, influencedY),
        blob.radius * (1 + influence * 0.5),
        blobPaint,
      );
    }
    
    // Draw connecting lines between blobs (subtle)
    for (int i = 0; i < blobs.length; i++) {
      for (int j = i + 1; j < blobs.length; j++) {
        final blob1 = blobs[i];
        final blob2 = blobs[j];
        
        final pos1 = Offset(
          blob1.position.dx * size.width,
          blob1.position.dy * size.height,
        );
        final pos2 = Offset(
          blob2.position.dx * size.width,
          blob2.position.dy * size.height,
        );
        
        final distance = (pos1 - pos2).distance;
        if (distance < 400) {
          final opacity = (1 - distance / 400) * 0.1;
          final linePaint = Paint()
            ..color = const Color(0xFF00FFA3).withOpacity(opacity)
            ..strokeWidth = 2
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
          
          canvas.drawLine(pos1, pos2, linePaint);
        }
      }
    }
    
    // Add noise texture overlay
    _drawNoiseOverlay(canvas, size);
  }
  
  void _drawNoiseOverlay(Canvas canvas, Size size) {
    final noisePaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.fill;
    
    final random = math.Random(42);
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2;
      
      canvas.drawCircle(Offset(x, y), radius, noisePaint);
    }
  }
  
  @override
  bool shouldRepaint(FluidGradientPainter oldDelegate) {
    return oldDelegate.mousePosition != mousePosition ||
        oldDelegate.animationValue != animationValue;
  }
}

