import 'package:flutter/material.dart';
import '../theme/liquid_material_theme.dart';

class LiquidSparklineChart extends StatelessWidget {
  final List<double> data;
  final double? width;
  final double? height;
  final Color? lineColor;
  final Color? fillColor;
  final double strokeWidth;
  final bool showLiveIndicator;
  final double glowAnimationValue;

  const LiquidSparklineChart({
    Key? key,
    required this.data,
    this.width,
    this.height,
    this.lineColor,
    this.fillColor,
    this.strokeWidth = 2.0,
    this.showLiveIndicator = false,
    this.glowAnimationValue = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        width: width ?? 200,
        height: height ?? 60,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No data',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }

    return Container(
      width: width ?? 200,
      height: height ?? 60,
      child: CustomPaint(
        painter: SparklinePainter(
          data: data,
          lineColor: lineColor ?? const Color(0xFF00E676),
          fillColor: fillColor ?? const Color(0xFF00E676).withOpacity(0.2),
          strokeWidth: strokeWidth,
          showLiveIndicator: showLiveIndicator,
          glowAnimationValue: glowAnimationValue,
        ),
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;
  final double strokeWidth;
  final bool showLiveIndicator;
  final double glowAnimationValue;

  SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
    required this.strokeWidth,
    this.showLiveIndicator = false,
    this.glowAnimationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    if (range == 0) {
      // All values are the same, draw a horizontal line
      final y = size.height / 2;
      path.moveTo(0, y);
      path.lineTo(size.width, y);

      fillPath.moveTo(0, y);
      fillPath.lineTo(size.width, y);
      fillPath.lineTo(size.width, size.height);
      fillPath.lineTo(0, size.height);
      fillPath.close();
    } else {
      final stepX = size.width / (data.length - 1);

      for (int i = 0; i < data.length; i++) {
        final x = i * stepX;
        final normalizedValue = (data[i] - minValue) / range;
        final y = size.height - (normalizedValue * size.height);

        if (i == 0) {
          path.moveTo(x, y);
          fillPath.moveTo(x, y);
        } else {
          path.lineTo(x, y);
          fillPath.lineTo(x, y);
        }
      }

      // Complete the fill path
      fillPath.lineTo(size.width, size.height);
      fillPath.lineTo(0, size.height);
      fillPath.close();
    }

    // Draw fill first
    canvas.drawPath(fillPath, fillPaint);

    // Draw line on top
    canvas.drawPath(path, paint);

    // Draw live indicator at last data point
    if (showLiveIndicator && data.isNotEmpty) {
      final lastX = (data.length - 1) * (size.width / (data.length - 1));
      final lastValue = data.last;
      final normalizedValue = (lastValue - minValue) / range;
      final lastY = size.height - (normalizedValue * size.height);

      // Pulsing glow effect
      final glowRadius = 8.0 + (glowAnimationValue * 8.0);
      final glowPaint = Paint()
        ..color = lineColor.withOpacity(0.3 + (glowAnimationValue * 0.4))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius);

      canvas.drawCircle(Offset(lastX, lastY), 3.0, glowPaint);

      // Inner bright dot
      final dotPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(lastX, lastY), 2.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is SparklinePainter &&
        (oldDelegate.data != data ||
            oldDelegate.lineColor != lineColor ||
            oldDelegate.fillColor != fillColor ||
            oldDelegate.strokeWidth != strokeWidth ||
            oldDelegate.showLiveIndicator != showLiveIndicator ||
            oldDelegate.glowAnimationValue != glowAnimationValue);
  }
}
