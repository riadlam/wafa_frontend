import 'package:flutter/material.dart';

class CurvedNotchedBarPainter extends CustomPainter {
  final Color backgroundColor;

  CurvedNotchedBarPainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Path path = Path();
    // Start from bottom left
    path.moveTo(0, 20);
    // Left curve up to top left
    path.quadraticBezierTo(0, 0, 20, 0);
    // Line to before notch
    double notchWidth = 80;
    double notchCenter = size.width / 2;
    double notchStart = notchCenter - notchWidth / 2;
    double notchEnd = notchCenter + notchWidth / 2;
    double notchDepth = size.height - 2; // Deep notch almost to the bottom

    path.lineTo(notchStart - 18, 0);
    // Perfect semicircular notch to the bottom
    path.arcToPoint(
      Offset(notchEnd + 18, 0),
      radius: Radius.elliptical(notchWidth / 2, size.height),
      clockwise: false,
      largeArc: false
    );
    // Continue to top right
    path.lineTo(size.width - 20, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20);
    // Down to bottom right
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.08), 12, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
