import 'package:flutter/material.dart';

import '../../domain/entities/board_entities.dart';

class BoardStatusBar extends StatelessWidget {
  const BoardStatusBar({
    super.key,
    required this.gameState,
    required this.currentTurnUsername,
    required this.myPosition,
  });

  final GameState gameState;
  final String currentTurnUsername;
  final PlayerPosition? myPosition;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatusChip(
          label: 'TURNO ACTUAL',
          value: currentTurnUsername,
          minWidth: 93,
        ),
        const SizedBox(width: 10),
        _StatusChip(
          label: 'CASILLA',
          value: myPosition != null ? '${myPosition!.square}/49' : '–',
        ),
        const SizedBox(width: 10),
        _StatusChip(
          label: 'SHOTS DADOS',
          value: '${gameState.shotsTakenByCurrentPlayer} shots',
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.value,
    this.minWidth,
  });

  final String label;
  final String value;
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth ?? 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF29252D),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFF47404E)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFF1F5F9),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
