import 'package:flutter/material.dart';

import '../../../../../domain/entities/room_player.dart';
import '../../../domain/entities/challenge_card.dart';
import 'generic_challenge_dialog.dart';

class MostLikelyToDialog extends StatefulWidget {
  const MostLikelyToDialog({
    super.key,
    required this.card,
    required this.players,
    required this.currentUserId,
    required this.onConfirm,
  });

  final ChallengeCard card;
  final List<RoomPlayer> players;
  final String currentUserId;
  final ValueChanged<RoomPlayer> onConfirm;

  @override
  State<MostLikelyToDialog> createState() => _MostLikelyToDialogState();
}

class _MostLikelyToDialogState extends State<MostLikelyToDialog> {
  String? _selectedPlayerId;

  @override
  void initState() {
    super.initState();
    _selectedPlayerId = widget.players
        .where((player) => player.userId != widget.currentUserId)
        .firstOrNull
        ?.userId;
  }

  @override
  Widget build(BuildContext context) {
    final candidates = widget.players.where((p) => p.userId != widget.currentUserId).toList();
    final selected = candidates.where((p) => p.userId == _selectedPlayerId).firstOrNull;

    return GenericChallengeDialog(
      title: widget.card.title,
      message: widget.card.prompt,
      iconAsset: 'assets/images/7d8f23c2817a787a650c62a08cefcbf184f80f9c.png',
      accentColor: const Color(0xFF07FCFE),
      primaryLabel: 'Elegir',
      onPrimary: selected == null ? () {} : () => widget.onConfirm(selected),
      secondaryLabel: 'Cancelar',
      onSecondary: () => Navigator.of(context).pop(),
      body: Column(
        children: [
          for (final player in candidates)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedPlayerId = player.userId),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: player.userId == _selectedPlayerId
                        ? const Color(0xFF07FCFE).withValues(alpha: 0.12)
                        : const Color(0xFF10131C).withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: player.userId == _selectedPlayerId
                          ? const Color(0xFF07FCFE).withValues(alpha: 0.70)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          player.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (player.userId == _selectedPlayerId)
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF07FCFE), size: 18),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}