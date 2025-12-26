import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class CameraOverlay extends StatelessWidget {
  const CameraOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryBlack.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Corner bracket settings
    const cornerLength = 40.0;
    const cornerWidth = 4.0;
    const cornerRadius = 8.0;
    const padding = 40.0;

    // Calculate scan area
    final scanWidth = size.width - (padding * 2);
    final scanHeight = size.height * 0.5;
    final scanTop = (size.height - scanHeight) / 2 - 50;
    final scanRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(padding, scanTop, scanWidth, scanHeight),
      const Radius.circular(24),
    );

    // Draw dark overlay with cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(scanRect);
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    // Draw corner brackets
    final bracketPaint = Paint()
      ..color = AppTheme.goldAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerWidth
      ..strokeCap = StrokeCap.round;

    // Top-left corner
    canvas.drawPath(
      _createCornerPath(
        padding,
        scanTop,
        cornerLength,
        cornerRadius,
        true,
        true,
      ),
      bracketPaint,
    );

    // Top-right corner
    canvas.drawPath(
      _createCornerPath(
        size.width - padding,
        scanTop,
        cornerLength,
        cornerRadius,
        false,
        true,
      ),
      bracketPaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      _createCornerPath(
        padding,
        scanTop + scanHeight,
        cornerLength,
        cornerRadius,
        true,
        false,
      ),
      bracketPaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      _createCornerPath(
        size.width - padding,
        scanTop + scanHeight,
        cornerLength,
        cornerRadius,
        false,
        false,
      ),
      bracketPaint,
    );
  }

  Path _createCornerPath(
    double x,
    double y,
    double length,
    double radius,
    bool isLeft,
    bool isTop,
  ) {
    final path = Path();
    
    if (isLeft && isTop) {
      path.moveTo(x, y + length);
      path.lineTo(x, y + radius);
      path.quadraticBezierTo(x, y, x + radius, y);
      path.lineTo(x + length, y);
    } else if (!isLeft && isTop) {
      path.moveTo(x - length, y);
      path.lineTo(x - radius, y);
      path.quadraticBezierTo(x, y, x, y + radius);
      path.lineTo(x, y + length);
    } else if (isLeft && !isTop) {
      path.moveTo(x + length, y);
      path.lineTo(x + radius, y);
      path.quadraticBezierTo(x, y, x, y - radius);
      path.lineTo(x, y - length);
    } else {
      path.moveTo(x, y - length);
      path.lineTo(x, y - radius);
      path.quadraticBezierTo(x, y, x - radius, y);
      path.lineTo(x - length, y);
    }
    
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
