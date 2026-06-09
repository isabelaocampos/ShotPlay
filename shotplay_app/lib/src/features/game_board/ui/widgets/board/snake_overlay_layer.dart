import 'package:flutter/material.dart';

import 'board_layout.dart';
import 'snake_painter.dart';

class SnakeOverlayLayer extends StatelessWidget {
  const SnakeOverlayLayer({
    super.key,
    required this.cellSize,
  });

  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final snakes = snakeOverlayData();
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            for (final overlay in snakes)
              _SnakePainterOverlay(overlay: overlay, cellSize: cellSize),
          ],
        ),
      ),
    );
  }
}

class _SnakePainterOverlay extends StatelessWidget {
  const _SnakePainterOverlay({
    required this.overlay,
    required this.cellSize,
  });

  final BoardOverlayData overlay;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final placement = snakePlacementFor(overlay, cellSize);
    final bodyWidth = cellSize * (overlay.isLong ? 0.09 : 0.08);

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
            painter: SnakePainter(bodyWidth: bodyWidth),
          ),
        ),
      ),
    );
  }
}
