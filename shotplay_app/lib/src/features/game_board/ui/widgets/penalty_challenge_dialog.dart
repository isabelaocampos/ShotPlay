import 'package:flutter/material.dart';

import '../../domain/entities/board_entities.dart';

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
    final isSnake =
        challenge.type == PenaltyChallengeType.takeShootToStay;

    final emoji = isSnake ? '🐍' : '🪜';
    final title = isSnake ? '$emoji ¡Cabeza de serpiente!' : '$emoji ¡Base de escalera!';

    final question = isSnake
        ? '¿Tomas un shot para quedarte en la casilla ${challenge.rawSquare}?\n\n'
            'Si rechazas, bajas a la casilla ${challenge.rejectSquare}.'
        : '¿Tomas un shot para subir a la casilla ${challenge.acceptSquare}?\n\n'
            'Si rechazas, te quedas en la casilla ${challenge.rawSquare}.';

    final rejectLabel =
        isSnake ? 'Bajo a ${challenge.rejectSquare}' : 'Me quedo aquí';

    return AlertDialog(
      backgroundColor: const Color(0xFF22172D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFF1F5F9),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        question,
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.5),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: onReject,
          child: Text(
            rejectLabel,
            style: const TextStyle(color: Color(0xFF94A3B8)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5F0F86),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: onAccept,
          child: const Text(
            '¡Tomo el shot!',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
