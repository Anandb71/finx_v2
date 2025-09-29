// lib/utils/gyroscope_parallax.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// For web platform, we'll use a simplified version without HTML dependencies
// This ensures compatibility across all platforms

class GyroscopeParallaxController extends ChangeNotifier {
  double _gyroX = 0.0;
  double _gyroY = 0.0;
  Timer? _updateTimer;

  double get gyroX => _gyroX;
  double get gyroY => _gyroY;

  // Normalize gyro values to controlled range (-1 to 1)
  double _normalizeGyroValue(double value) {
    return (value / 90.0).clamp(-1.0, 1.0);
  }

  void _handleOrientationChange(double gamma, double beta) {
    final newGyroX = _normalizeGyroValue(gamma);
    final newGyroY = _normalizeGyroValue(beta);

    if (_gyroX != newGyroX || _gyroY != newGyroY) {
      _gyroX = newGyroX;
      _gyroY = newGyroY;
      notifyListeners();
    }
  }

  void startListening() {
    // Simplified version for cross-platform compatibility
    // In a real implementation, you would use platform-specific code
    // For now, we'll simulate gyroscope data for demonstration
    _updateTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      // Simulate subtle movement for demonstration
      final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
      _handleOrientationChange(
        math.sin(time * 0.1) * 5.0, // Simulate gamma
        math.cos(time * 0.1) * 5.0, // Simulate beta
      );
    });
  }

  void stopListening() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

class GyroscopeParallaxWidget extends StatefulWidget {
  final Widget child;
  final double multiplier;
  final GyroscopeParallaxController controller;

  const GyroscopeParallaxWidget({
    Key? key,
    required this.child,
    required this.multiplier,
    required this.controller,
  }) : super(key: key);

  @override
  State<GyroscopeParallaxWidget> createState() =>
      _GyroscopeParallaxWidgetState();
}

class _GyroscopeParallaxWidgetState extends State<GyroscopeParallaxWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateTransform);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateTransform);
    super.dispose();
  }

  void _updateTransform() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(
        widget.controller.gyroX * widget.multiplier,
        widget.controller.gyroY * widget.multiplier,
      ),
      child: widget.child,
    );
  }
}

// Convenience widget for different parallax layers
class ParallaxBackground extends StatelessWidget {
  final Widget child;
  final GyroscopeParallaxController controller;

  const ParallaxBackground({
    Key? key,
    required this.child,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GyroscopeParallaxWidget(
      controller: controller,
      multiplier: 10.0, // Background moves most
      child: child,
    );
  }
}

class ParallaxCard extends StatelessWidget {
  final Widget child;
  final GyroscopeParallaxController controller;

  const ParallaxCard({Key? key, required this.child, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GyroscopeParallaxWidget(
      controller: controller,
      multiplier: -2.0, // Cards move opposite to background
      child: child,
    );
  }
}

class ParallaxButton extends StatelessWidget {
  final Widget child;
  final GyroscopeParallaxController controller;

  const ParallaxButton({
    Key? key,
    required this.child,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GyroscopeParallaxWidget(
      controller: controller,
      multiplier: -4.0, // Buttons move most opposite (foreground effect)
      child: child,
    );
  }
}
