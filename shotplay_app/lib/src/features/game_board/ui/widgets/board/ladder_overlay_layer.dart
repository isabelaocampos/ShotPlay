import 'package:flutter/material.dart';

import 'board_layout.dart';
import 'ladder_painter.dart';

class LadderOverlayLayer extends StatelessWidget {
  const LadderOverlayLayer({
    super.key,
    required this.cellSize,
  });

  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final ladders = ladderOverlayData();
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            for (final overlay in ladders)
              _LadderPainterOverlay(overlay: overlay, cellSize: cellSize),
          ],
        ),
      ),
    );
  }
}

class _LadderPainterOverlay extends StatelessWidget {
  const _LadderPainterOverlay({
    required this.overlay,
    required this.cellSize,
  });

  final BoardOverlayData overlay;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final placement = ladderPlacementFor(overlay, cellSize);
    final distance = (overlay.endSquare - overlay.startSquare).abs();
    final steps = stepsForDistance(distance);

    return Positioned(
      left: placement.left,
      top: placement.top,
      child: Transform.rotate(
        angle: placement.rotation,
        alignment: Alignment.center,
        child: SizedBox(
          width: placement.width,
          height: placement.height,
          child: CustomPaint(
            painter: LadderPainter(stepCount: steps),
          ),
        ),
      ),
    );
  }
}
