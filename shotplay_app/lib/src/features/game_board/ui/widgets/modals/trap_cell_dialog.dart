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
      title: 'TRAP CELL',
      message: isTriggered
          ? 'You hit a trap. Drink 3 shots and keep the game moving.'
          : 'Leave a trap on this square. The next player who lands here drinks 3 shots.',
      iconAsset: 'assets/images/7d8f23c2817a787a650c62a08cefcbf184f80f9c.png',
      accentColor: const Color(0xFFF97316),
      primaryLabel: isTriggered ? 'Drink 3' : 'Plant trap',
      onPrimary: onConfirm,
      body: trapState != null
          ? Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Trap owner: ${trapState!.ownerUsername}',
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