import 'package:flutter/material.dart';

import 'generic_challenge_dialog.dart';

class RevengeShotDialog extends StatelessWidget {
  const RevengeShotDialog({
    super.key,
    required this.punisherName,
    required this.onConfirm,
  });

  final String punisherName;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return GenericChallengeDialog(
      title: 'REVENGE SHOT',
      message: 'The last player who punished you must drink with you.\n\n$punisherName drinks too.',
      iconAsset: 'assets/images/7d8f23c2817a787a650c62a08cefcbf184f80f9c.png',
      accentColor: const Color(0xFFFF339A),
      primaryLabel: 'Revenge',
      onPrimary: onConfirm,
    );
  }
}