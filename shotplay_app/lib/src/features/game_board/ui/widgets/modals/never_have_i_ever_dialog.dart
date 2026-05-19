import 'package:flutter/material.dart';

import '../../../domain/entities/challenge_card.dart';
import 'generic_challenge_dialog.dart';

class NeverHaveIEverDialog extends StatelessWidget {
  const NeverHaveIEverDialog({
    super.key,
    required this.card,
    required this.onDrink,
    required this.onPass,
  });

  final ChallengeCard card;
  final VoidCallback onDrink;
  final VoidCallback onPass;

  @override
  Widget build(BuildContext context) {
    return GenericChallengeDialog(
      title: card.title,
      message: card.prompt,
      iconAsset: 'assets/images/7d8f23c2817a787a650c62a08cefcbf184f80f9c.png',
      accentColor: const Color(0xFFA50EEB),
      primaryLabel: 'I have',
      onPrimary: onDrink,
      secondaryLabel: 'I haven\'t',
      onSecondary: onPass,
    );
  }
}