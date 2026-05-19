import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';
import 'board_layout.dart';

class TrapOverlayLayer extends StatelessWidget {
  const TrapOverlayLayer({
    super.key,
    required this.cellSize,
    required this.traps,
  });

  final double cellSize;
  final List<TrapState> traps;

  @override
  Widget build(BuildContext context) {
    if (traps.isEmpty) return const SizedBox.shrink();

    final boardSize = cellSize * 7;

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            for (final trap in traps)
              Positioned(
                left: boardSize * 0.02 + squareToGridPos(trap.square).col * cellSize + cellSize * 0.26,
                top: boardSize * 0.02 + squareToGridPos(trap.square).row * cellSize + cellSize * 0.26,
                child: Container(
                  width: cellSize * 0.42,
                  height: cellSize * 0.42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFF97316).withValues(alpha: 0.30),
                        const Color(0xFF0F121A).withValues(alpha: 0.92),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFF97316).withValues(alpha: 0.60),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF97316).withValues(alpha: 0.25),
                        blurRadius: 10,
                        spreadRadius: 0.6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    size: 16,
                    color: Color(0xFFF97316),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}