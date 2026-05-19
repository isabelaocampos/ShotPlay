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
      title: 'SILENT ROUND',
      message: 'You cannot speak until your next turn. If you break it, take 2 shots.',
      iconAsset: 'assets/images/7d8f23c2817a787a650c62a08cefcbf184f80f9c.png',
      accentColor: const Color(0xFF94A3B8),
      primaryLabel: 'Understood',
      onPrimary: onConfirm,
    );
  }
}