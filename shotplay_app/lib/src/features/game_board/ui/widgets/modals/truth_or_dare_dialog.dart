import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';
import 'generic_challenge_dialog.dart';

class TruthOrDareDialog extends StatelessWidget {
  const TruthOrDareDialog({
    super.key,
    required this.cell,
    required this.onTruth,
    required this.onDare,
  });

  final SpecialCell cell;
  final VoidCallback onTruth;
  final VoidCallback onDare;

  @override
  Widget build(BuildContext context) {
    return GenericChallengeDialog(
      title: 'Verdad o Reto',
      message: 'Elige tu veneno y mantén viva la ronda.',
      iconAsset: 'assets/images/headliner_escalera.png',
      accentColor: const Color(0xFFFFBDF5),
      primaryLabel: 'Reto',
      onPrimary: onDare,
      secondaryLabel: 'Verdad',
      onSecondary: onTruth,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF10131C).withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFBDF5).withValues(alpha: 0.24)),
        ),
        child: Text(
          'Casilla ${cell.square}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFF8FAFC),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
