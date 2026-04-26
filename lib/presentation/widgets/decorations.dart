import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class DottedPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.1,
      size.width, size.height * 0.3,
    );
    
    path.moveTo(size.width, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.8,
      0, size.height * 0.7,
    );

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double distance = 0.0;
    for (ui.PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        canvas.drawPath(
          measurePath.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class FloatingShape extends StatelessWidget {
  final Color color;
  final double size;
  final double top;
  final double left;
  final double rotation;

  const FloatingShape({
    super.key,
    required this.color,
    required this.size,
    required this.top,
    required this.left,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(size * 0.2),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
        ),
      ),
    );
  }
}
