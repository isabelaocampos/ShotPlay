import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';

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
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _StatusChip(label: 'TURNO', value: currentTurnUsername),
        _StatusChip(label: 'POSICIÓN', value: myPosition != null ? '${myPosition!.square}/49' : '–'),
        _StatusChip(label: 'SHOTS', value: '${gameState.shotsTakenByCurrentPlayer} shots'),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 108),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF18111F).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF07FCFE).withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5F0F86).withValues(alpha: 0.22),
            blurRadius: 16,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFF8FAFC),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
