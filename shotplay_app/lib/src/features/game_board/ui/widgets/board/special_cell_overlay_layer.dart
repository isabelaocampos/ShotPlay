import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';
import 'board_layout.dart';

class SpecialCellOverlayLayer extends StatelessWidget {
  const SpecialCellOverlayLayer({
    super.key,
    required this.cellSize,
  });

  final double cellSize;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            for (final cell in BoardDefinition.specialCells)
              _SpecialCellOverlay(
                cell: cell,
                cellSize: cellSize,
              ),
          ],
        ),
      ),
    );
  }
}

class _SpecialCellOverlay extends StatelessWidget {
  const _SpecialCellOverlay({
    required this.cell,
    required this.cellSize,
  });

  final SpecialCell cell;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final pos = squareToGridPos(cell.square);
    final left = pos.col * cellSize + cellSize * 0.28;
    final top = pos.row * cellSize + cellSize * 0.28;
    final icon = switch (cell.type) {
      SpecialCellType.takeShot => Icons.local_bar_rounded,
      SpecialCellType.giveShot => Icons.gps_fixed_rounded,
      SpecialCellType.truthOrDare => Icons.help_outline_rounded,
    };

    final glowColor = switch (cell.type) {
      SpecialCellType.takeShot => const Color(0xFFBAFA5E),
      SpecialCellType.giveShot => const Color(0xFF07FCFE),
      SpecialCellType.truthOrDare => const Color(0xFFFFBDF5),
    };

    return Positioned(
      left: left,
      top: top,
      child: SizedBox(
        width: cellSize * 0.42,
        height: cellSize * 0.42,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                glowColor.withValues(alpha: 0.24),
                const Color(0xFF0E1016).withValues(alpha: 0.95),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: glowColor.withValues(alpha: 0.58), width: 1.0),
          ),
          child: Icon(
            icon,
            color: glowColor.withValues(alpha: 0.96),
            size: cellSize * 0.16,
          ),
        ),
      ),
    );
  }
}
