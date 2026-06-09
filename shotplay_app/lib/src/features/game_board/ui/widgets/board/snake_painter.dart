import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class SnakePainter extends CustomPainter {
  const SnakePainter({
    this.bodyColor = AppColors.snakeBody,
    this.glowColor = AppColors.snakeGlow,
    this.spotColor = AppColors.snakeGlow,
    this.bodyWidth = 6.0,
  });

  final Color bodyColor;
  final Color glowColor;
  final Color spotColor;
  final double bodyWidth;

  // Draws in a landscape bounding box:
  //   head at Offset(0,       h/2)  ← startSquare (after rotation)
  //   tail at Offset(w,       h/2)  ← endSquare   (after rotation)
  // S-curve wobbles in the Y direction (first half up, second half down).

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final head = Offset(0, h / 2);
    final mid = Offset(w / 2, h / 2);
    final tail = Offset(w, h / 2);

    final path = Path()
      ..moveTo(head.dx, head.dy)
      ..cubicTo(w * 0.15, h * 0.08, w * 0.40, h * 0.08, mid.dx, mid.dy)
      ..cubicTo(w * 0.60, h * 0.92, w * 0.85, h * 0.92, tail.dx, tail.dy);

    // 1. Glow pass
    canvas.drawPath(
      path,
      Paint()
        ..color = glowColor.withValues(alpha: 0.50)
        ..strokeWidth = bodyWidth * 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // 2. Body pass
    canvas.drawPath(
      path,
      Paint()
        ..color = bodyColor
        ..strokeWidth = bodyWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    // 3. Spots at 25 %, 50 %, 75 % along the path
    final spotPaint = Paint()
      ..color = spotColor
      ..style = PaintingStyle.fill;
    for (final t in const [0.25, 0.50, 0.75]) {
      canvas.drawCircle(_sampleCurve(w, h, t), bodyWidth * 0.45, spotPaint);
    }

    // 4. Head circle + glow border
    canvas.drawCircle(
      head,
      bodyWidth * 0.9,
      Paint()
        ..color = bodyColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      head,
      bodyWidth * 0.9,
      Paint()
        ..color = glowColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    // 5. Eyes: two white dots slightly ahead of the head
    final eyeR = bodyWidth * 0.18;
    final eyeDy = bodyWidth * 0.28;
    final eyeX = bodyWidth * 0.35;
    canvas.drawCircle(Offset(eyeX, h / 2 - eyeDy), eyeR, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(eyeX, h / 2 + eyeDy), eyeR, Paint()..color = Colors.white);

    // 6. Tongue: V-shape extending past the head tip
    final tonguePaint = Paint()
      ..color = AppColors.error
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final tipX = -bodyWidth * 0.9;
    final forkDx = bodyWidth * 0.7;
    final forkDy = bodyWidth * 0.35;
    canvas.drawLine(Offset(tipX, h / 2), Offset(tipX - forkDx, h / 2 - forkDy), tonguePaint);
    canvas.drawLine(Offset(tipX, h / 2), Offset(tipX - forkDx, h / 2 + forkDy), tonguePaint);
  }

  // Samples a point on the S-curve at t ∈ [0, 1].
  Offset _sampleCurve(double w, double h, double t) {
    if (t <= 0.5) {
      return _cubic(
        Offset(0, h / 2),
        Offset(w * 0.15, h * 0.08),
        Offset(w * 0.40, h * 0.08),
        Offset(w / 2, h / 2),
        t * 2,
      );
    }
    return _cubic(
      Offset(w / 2, h / 2),
      Offset(w * 0.60, h * 0.92),
      Offset(w * 0.85, h * 0.92),
      Offset(w, h / 2),
      (t - 0.5) * 2,
    );
  }

  Offset _cubic(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final u = 1 - t;
    return Offset(
      u * u * u * p0.dx + 3 * u * u * t * p1.dx + 3 * u * t * t * p2.dx + t * t * t * p3.dx,
      u * u * u * p0.dy + 3 * u * u * t * p1.dy + 3 * u * t * t * p2.dy + t * t * t * p3.dy,
    );
  }

  @override
  bool shouldRepaint(SnakePainter old) => false;
}
