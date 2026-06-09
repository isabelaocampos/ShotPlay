import 'package:flutter/material.dart';

import '../../domain/entities/board_entities.dart';
import 'modals/generic_challenge_dialog.dart';

/// Pop-up shown to the rolling player when they land on a snake head or
/// ladder base. Presents a shot offer and routes the response back via
/// [onAccept] / [onReject].
class PenaltyChallengeDialog extends StatelessWidget {
  const PenaltyChallengeDialog({
    super.key,
    required this.challenge,
    required this.onAccept,
    required this.onReject,
  });

  final PenaltyChallenge challenge;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final isSnake = challenge.type == PenaltyChallengeType.takeShootToStay;
    final emoji = isSnake ? '🐍' : '🪜';
    final title = isSnake ? '$emoji Cabeza de serpiente' : '$emoji Base de escalera';
    final question = isSnake
      ? 'Toma un shot para quedarte aquí.\n\n'
        'Si rechazas, bajas a la casilla ${challenge.rejectSquare}.'
      : 'Toma un shot para subir la escalera.\n\n'
        'Si rechazas, te quedas aquí.';

    return GenericChallengeDialog(
      title: title,
      message: question,
      iconAsset: 'assets/images/7d8f23c2817a787a650c62a08cefcbf184f80f9c.png',
      accentColor: isSnake ? const Color(0xFFFF339A) : const Color(0xFF07FCFE),
      primaryLabel: 'Yo tomo',
      onPrimary: onAccept,
      secondaryLabel: 'Te quedas aquí',
      onSecondary: onReject,
    );
  }
}