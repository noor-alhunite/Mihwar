import 'dart:math' as math;

import 'package:flutter/material.dart';

class DonutChart extends StatelessWidget {
  const DonutChart({
    required this.values,
    required this.colors,
    super.key,
    this.size = 180,
    this.strokeWidth = 24,
    this.centerLabel,
  });

  final List<double> values;
  final List<Color> colors;
  final double size;
  final double strokeWidth;
  final String? centerLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _DonutPainter(
              values: values,
              colors: colors,
              strokeWidth: strokeWidth,
            ),
          ),
          if (centerLabel != null)
            Text(
              centerLabel!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.values,
    required this.colors,
    required this.strokeWidth,
  });

  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double total = values.fold<double>(0, (sum, value) => sum + value);
    if (total <= 0) {
      return;
    }

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < values.length; i++) {
      final double sweep = (values[i] / total) * (2 * math.pi);
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.colors != colors ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
