import 'package:flutter/material.dart';

import 'generic_challenge_dialog.dart';

class SilentRoundDialog extends StatelessWidget {
  const SilentRoundDialog({
    super.key,
    required this.onConfirm,
  });

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return GenericChallengeDialog(
      title: 'RONDA SILENCIOSA',
      message:
          'Nadie puede hablar. El primero que hable toma un shot.',
      iconAsset: 'assets/images/7d8f23c2817a787a650c62a08cefcbf184f80f9c.png',
      accentColor: const Color(0xFF07FCFE),
      primaryLabel: 'Entendido',
      onPrimary: onConfirm,
    );
  }
}