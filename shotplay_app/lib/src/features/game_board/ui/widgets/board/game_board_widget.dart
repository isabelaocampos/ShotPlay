import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';
import 'board_grid.dart';
import 'ladder_overlay_layer.dart';
import 'player_token_layer.dart';
import 'snake_overlay_layer.dart';
import 'special_cell_overlay_layer.dart';

class GameBoardWidget extends StatelessWidget {
  const GameBoardWidget({
    super.key,
    required this.positions,
    this.highlightSquare,
  });

  final List<PlayerPosition> positions;
  final int? highlightSquare;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth;
        final cellSize = boardSize / 7;

        return ClipRRect(
          borderRadius: BorderRadius.circular(boardSize * 0.04),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1D1027),
                        const Color(0xFF0B0711),
                        const Color(0xFF110B1A),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF5F0F86).withValues(alpha: 0.12),
                        const Color(0xFF07FCFE).withValues(alpha: 0.04),
                        Colors.black.withValues(alpha: 0.18),
                      ],
                    ),
                  ),
                ),
              ),
              BoardGrid(highlightSquare: highlightSquare),
              SpecialCellOverlayLayer(cellSize: cellSize),
              SnakeOverlayLayer(cellSize: cellSize),
              LadderOverlayLayer(cellSize: cellSize),
              PlayerTokenLayer(positions: positions, cellSize: cellSize),
            ],
          ),
        );
      },
    );
  }
}
