import 'package:flutter/material.dart';

class GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double strokeWidth;
  final double radius;

  GradientBorderPainter({
    required this.gradient,
    this.strokeWidth = 2.0,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant GradientBorderPainter oldDelegate) {
    return oldDelegate.gradient != gradient ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}
