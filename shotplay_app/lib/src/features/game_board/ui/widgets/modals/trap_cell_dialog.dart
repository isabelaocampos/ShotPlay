import 'package:flutter/material.dart';

import '../../../domain/entities/trap_state.dart';
import 'generic_challenge_dialog.dart';

class TrapCellDialog extends StatelessWidget {
  const TrapCellDialog({
    super.key,
    required this.isTriggered,
    required this.onConfirm,
    this.trapState,
  });

  final bool isTriggered;
  final TrapState? trapState;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return GenericChallengeDialog(
      title: 'CASILLA TRAMPA',
      message: isTriggered
          ? 'Caíste en una trampa. Toma 3 shots y que siga el juego.'
          : 'Deja una trampa en esta casilla. El próximo jugador que caiga aquí toma 3 shots.',
      iconAsset: 'assets/images/7d8f23c2817a787a650c62a08cefcbf184f80f9c.png',
      accentColor: const Color(0xFFF97316),
      primaryLabel: isTriggered ? 'Tomo 3' : 'Plantar trampa',
      onPrimary: onConfirm,
      body: trapState != null
          ? Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Dueño de la trampa: ${trapState!.ownerUsername}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFF8FAFC),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
    );
  }
}