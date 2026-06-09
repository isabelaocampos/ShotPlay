import 'package:flutter/material.dart';

int stepsForDistance(int distance) {
  if (distance <= 10) return 4;
  if (distance <= 18) return 6;
  return 8;
}

class LadderPainter extends CustomPainter {
  const LadderPainter({
    required this.stepCount,
    this.railColor = const Color(0xFFFFA726),
    this.stepColor = const Color(0xFFFFCC02),
    this.glowColor = const Color(0xFFFF6D00),
    this.railWidth = 6.0,
    this.stepWidth = 3.5,
  });

  final int stepCount;
  final Color railColor;
  final Color stepColor;
  final Color glowColor;
  final double railWidth;
  final double stepWidth;

  // The painter works in a landscape bounding box:
  //   size.width  = length along the board line (startSquare → endSquare)
  //   size.height = visual thickness of the ladder (space between rails)
  // Two rails run horizontally at 15 % and 85 % of the height.
  // Rungs are vertical lines distributed uniformly along the width.

  @override
  void paint(Canvas canvas, Size size) {
    final railY1 = size.height * 0.15;
    final railY2 = size.height * 0.85;

    // --- glow pass (drawn under the solid lines) ---
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.55)
      ..strokeWidth = railWidth * 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawLine(Offset(0, railY1), Offset(size.width, railY1), glowPaint);
    canvas.drawLine(Offset(0, railY2), Offset(size.width, railY2), glowPaint);

    // --- solid rails ---
    final railPaint = Paint()
      ..color = railColor
      ..strokeWidth = railWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, railY1), Offset(size.width, railY1), railPaint);
    canvas.drawLine(Offset(0, railY2), Offset(size.width, railY2), railPaint);

    // --- rungs (uniformly spaced, not at the endpoints) ---
    final rungPaint = Paint()
      ..color = stepColor
      ..strokeWidth = stepWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final spacing = size.width / (stepCount + 1);
    for (int i = 1; i <= stepCount; i++) {
      final x = spacing * i;
      canvas.drawLine(Offset(x, railY1), Offset(x, railY2), rungPaint);
    }
  }

  @override
  bool shouldRepaint(LadderPainter old) => old.stepCount != stepCount;
}
