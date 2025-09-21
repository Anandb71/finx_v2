import 'package:flutter/material.dart';
import 'dart:math' as math;

class SparklineWidget extends StatelessWidget {
  final List<double> prices;
  final double width;
  final double height;
  final Color lineColor;
  final Color fillColor;
  final double strokeWidth;

  const SparklineWidget({
    super.key,
    required this.prices,
    this.width = 60.0,
    this.height = 20.0,
    this.lineColor = const Color(0xFF00FFA3),
    this.fillColor = const Color(0x1A00FFA3),
    this.strokeWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    if (prices.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Text('—', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
      );
    }

    return CustomPaint(
      size: Size(width, height),
      painter: SparklinePainter(
        prices: prices,
        lineColor: lineColor,
        fillColor: fillColor,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<double> prices;
  final Color lineColor;
  final Color fillColor;
  final double strokeWidth;

  SparklinePainter({
    required this.prices,
    required this.lineColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    // Calculate the path
    final path = Path();
    final fillPath = Path();

    // Find min and max values for scaling
    final minPrice = prices.reduce(math.min);
    final maxPrice = prices.reduce(math.max);
    final priceRange = maxPrice - minPrice;

    // Avoid division by zero
    if (priceRange == 0) {
      // Draw a horizontal line in the middle
      final y = size.height / 2;
      path.moveTo(0, y);
      path.lineTo(size.width, y);

      fillPath.moveTo(0, y);
      fillPath.lineTo(size.width, y);
      fillPath.lineTo(size.width, size.height);
      fillPath.lineTo(0, size.height);
      fillPath.close();
    } else {
      // Scale points to fit the widget
      final points = <Offset>[];

      for (int i = 0; i < prices.length; i++) {
        final x = (i / (prices.length - 1)) * size.width;
        final y =
            size.height - ((prices[i] - minPrice) / priceRange) * size.height;
        points.add(Offset(x, y));
      }

      // Create the line path
      if (points.isNotEmpty) {
        path.moveTo(points.first.dx, points.first.dy);
        for (int i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }

        // Create the fill path
        fillPath.addPath(path, Offset.zero);
        fillPath.lineTo(size.width, size.height);
        fillPath.lineTo(0, size.height);
        fillPath.close();
      }
    }

    // Draw the fill first (background)
    canvas.drawPath(fillPath, fillPaint);

    // Draw the line on top
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SparklinePainter oldDelegate) {
    return oldDelegate.prices != prices ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
