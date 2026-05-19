import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';
import 'board_layout.dart';

class LadderOverlayLayer extends StatelessWidget {
  const LadderOverlayLayer({
    super.key,
    required this.cellSize,
  });

  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final ladders = ladderOverlayData();
    final placements = [
      _ManualOverlayPlacement(
        left: 0.22,
        top: 0.63,
        width: 0.16,
        rotation: -0.92,
      ),
      _ManualOverlayPlacement(
        left: 0.50,
        top: 0.26,
        width: 0.14,
        rotation: -0.68,
      ),
      _ManualOverlayPlacement(
        left: 0.70,
        top: 0.39,
        width: 0.15,
        rotation: -0.50,
      ),
      _ManualOverlayPlacement(
        left: 0.14,
        top: 0.24,
        width: 0.15,
        rotation: -0.80,
      ),
    ];

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            for (var i = 0; i < ladders.length && i < placements.length; i++)
              _LadderAssetOverlay(
                overlay: ladders[i],
                cellSize: cellSize,
                placement: placements[i],
              ),
          ],
        ),
      ),
    );
  }
}

class _LadderAssetOverlay extends StatelessWidget {
  const _LadderAssetOverlay({
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
          height: boardSize * (placement.width * 0.68),
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
