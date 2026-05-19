import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';
import 'board_layout.dart';

class SnakeOverlayLayer extends StatelessWidget {
  const SnakeOverlayLayer({
    super.key,
    required this.cellSize,
  });

  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final snakes = snakeOverlayData();
    final placements = [
      _ManualOverlayPlacement(
        left: 0.12,
        top: 0.54,
        width: 0.28,
        rotation: -0.42,
      ),
      _ManualOverlayPlacement(
        left: 0.56,
        top: 0.15,
        width: 0.22,
        rotation: 0.28,
      ),
      _ManualOverlayPlacement(
        left: 0.42,
        top: 0.55,
        width: 0.26,
        rotation: -0.12,
      ),
    ];

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            for (var i = 0; i < snakes.length && i < placements.length; i++)
              _SnakeAssetOverlay(
                overlay: snakes[i],
                cellSize: cellSize,
                placement: placements[i],
              ),
          ],
        ),
      ),
    );
  }
}

class _SnakeAssetOverlay extends StatelessWidget {
  const _SnakeAssetOverlay({
    required this.overlay,
    required this.cellSize,
    required this.placement,
  });

  final BoardOverlayData overlay;
  final double cellSize;
  final _ManualOverlayPlacement placement;

  @override
  Widget build(BuildContext context) {
    final boardSize = cellSize * 7;

    return Positioned(
      left: boardSize * placement.left,
      top: boardSize * placement.top,
      child: Transform.rotate(
        angle: placement.rotation,
        alignment: Alignment.center,
        child: SizedBox(
          width: boardSize * placement.width,
          height: boardSize * (placement.width * 0.52),
          child: Image.asset(
            overlay.asset,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _ManualOverlayPlacement {
  const _ManualOverlayPlacement({
    required this.left,
    required this.top,
    required this.width,
    required this.rotation,
  });

  final double left;
  final double top;
  final double width;
  final double rotation;
}
