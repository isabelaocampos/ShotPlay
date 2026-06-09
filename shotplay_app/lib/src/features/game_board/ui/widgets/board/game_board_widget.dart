import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';
import 'board_grid.dart';
import 'ladder_overlay_layer.dart';
import 'player_token_layer.dart';
import 'snake_overlay_layer.dart';
import 'trap_overlay_layer.dart';
import 'special_cell_overlay_layer.dart';

class GameBoardWidget extends StatelessWidget {
  const GameBoardWidget({
    super.key,
    required this.positions,
    this.highlightSquare,
    this.activeTraps = const [],
    this.silentPlayerId,
  });

  final List<PlayerPosition> positions;
  final int? highlightSquare;
  final List<TrapState> activeTraps;
  final String? silentPlayerId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth;
        final cellSize = boardSize / 7;

        return ClipRRect(
          borderRadius: BorderRadius.circular(boardSize * 0.035),
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
                        const Color(0xFF16111D),
                        const Color(0xFF09070D),
                        const Color(0xFF120D17),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF07FCFE).withValues(alpha: 0.10),
                      width: 1,
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
                        const Color(0xFF5F0F86).withValues(alpha: 0.05),
                        const Color(0xFF07FCFE).withValues(alpha: 0.02),
                        Colors.black.withValues(alpha: 0.22),
                      ],
                    ),
                  ),
                ),
              ),
              BoardGrid(highlightSquare: highlightSquare),
              SpecialCellOverlayLayer(cellSize: cellSize),
              TrapOverlayLayer(cellSize: cellSize, traps: activeTraps),
              SnakeOverlayLayer(cellSize: cellSize),
              LadderOverlayLayer(cellSize: cellSize),
              PlayerTokenLayer(
                positions: positions,
                cellSize: cellSize,
                silentPlayerId: silentPlayerId,
              ),
            ],
          ),
        );
      },
    );
  }
}
