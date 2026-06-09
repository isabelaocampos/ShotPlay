import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';
import 'board_layout.dart';
import '../../../../../core/theme/app_colors.dart';

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
                        AppColors.warning.withValues(alpha: 0.30),
                        AppColors.background.withValues(alpha: 0.92),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.60),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.warning.withValues(alpha: 0.25),
                        blurRadius: 10,
                        spreadRadius: 0.6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}