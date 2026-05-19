import 'package:flutter/material.dart';

import '../../../../../domain/entities/room_player.dart';
import 'generic_challenge_dialog.dart';

class GiveShotsDialog extends StatefulWidget {
  const GiveShotsDialog({
    super.key,
    required this.players,
    required this.currentUserId,
    required this.onConfirm,
  });

  final List<RoomPlayer> players;
  final String currentUserId;
  final ValueChanged<RoomPlayer> onConfirm;

  @override
  State<GiveShotsDialog> createState() => _GiveShotsDialogState();
}

class _GiveShotsDialogState extends State<GiveShotsDialog> {
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
      title: 'Give 2 shots',
      message: 'Choose a player to drink 2 shots.',
      iconAsset: 'assets/images/7d8f23c2817a787a650c62a08cefcbf184f80f9c.png',
      accentColor: const Color(0xFF07FCFE),
      primaryLabel: 'Confirm',
      onPrimary: selected == null ? () {} : () => widget.onConfirm(selected),
      secondaryLabel: 'Cancel',
      onSecondary: () => Navigator.of(context).pop(),
      body: Column(
        children: [
          const SizedBox(height: 4),
          ...candidates.map((player) {
            final isSelected = player.userId == _selectedPlayerId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedPlayerId = player.userId),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF07FCFE).withValues(alpha: 0.12)
                        : const Color(0xFF10131C).withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF07FCFE).withValues(alpha: 0.70)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: const Color(0xFF07FCFE).withValues(alpha: 0.18),
                        backgroundImage: player.avatarUrl != null && player.avatarUrl!.trim().isNotEmpty
                            ? NetworkImage(player.avatarUrl!)
                            : null,
                        child: player.avatarUrl != null && player.avatarUrl!.trim().isNotEmpty
                            ? null
                            : Text(
                                player.username.isNotEmpty ? player.username.substring(0, 1).toUpperCase() : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
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
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF07FCFE), size: 18),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}