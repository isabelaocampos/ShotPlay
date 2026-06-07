import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';
import 'generic_challenge_dialog.dart';

class TakeShotDialog extends StatelessWidget {
  const TakeShotDialog({
    super.key,
    required this.cell,
    required this.onConfirm,
  });

  final SpecialCell cell;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return GenericChallengeDialog(
      title: 'Toma 2 shots',
      message: 'Toma 2 shots y sigue la partida.',
      iconAsset: 'assets/images/7d8f23c2817a787a650c62a08cefcbf184f80f9c.png',
      accentColor: const Color(0xFFBAFA5E),
      primaryLabel: 'Salud',
      onPrimary: onConfirm,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF10131C).withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBAFA5E).withValues(alpha: 0.24)),
        ),
        child: Text(
          'Te quedas aquí',
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
