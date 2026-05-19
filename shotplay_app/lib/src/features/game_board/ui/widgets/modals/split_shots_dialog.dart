import 'package:flutter/material.dart';

import '../../../../../domain/entities/room_player.dart';
import 'generic_challenge_dialog.dart';

class SplitShotsDialog extends StatefulWidget {
  const SplitShotsDialog({
    super.key,
    required this.players,
    required this.currentUserId,
    required this.onConfirm,
  });

  final List<RoomPlayer> players;
  final String currentUserId;
  final ValueChanged<Map<String, int>> onConfirm;

  @override
  State<SplitShotsDialog> createState() => _SplitShotsDialogState();
}

class _SplitShotsDialogState extends State<SplitShotsDialog> {
  late final List<RoomPlayer> _targets;
  final Map<String, int> _allocation = {};
  static const int _totalShots = 4;

  @override
  void initState() {
    super.initState();
    _targets = widget.players.toList();
    if (_targets.isNotEmpty) {
      _allocation[_targets.first.userId] = _totalShots;
    }
  }

  int get _distributed => _allocation.values.fold(0, (sum, item) => sum + item);

  void _setFor(String playerId, int value) {
    setState(() {
      _allocation[playerId] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _distributed == _totalShots;

    return GenericChallengeDialog(
      title: 'Split 4 shots',
      message: 'Distribute the 4 shots among the table.',
      iconAsset: 'assets/images/7d8f23c2817a787a650c62a08cefcbf184f80f9c.png',
      accentColor: const Color(0xFFFFBDF5),
      primaryLabel: 'Lock split',
      onPrimary: canConfirm ? () => widget.onConfirm(Map<String, int>.from(_allocation)) : () {},
      secondaryLabel: 'Cancel',
      onSecondary: () => Navigator.of(context).pop(),
      body: Column(
        children: [
          for (final player in _targets)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10131C).withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        player.username,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        final current = _allocation[player.userId] ?? 0;
                        if (current > 0) _setFor(player.userId, current - 1);
                      },
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFF07FCFE)),
                    ),
                    Text(
                      '${_allocation[player.userId] ?? 0}',
                      style: const TextStyle(color: Color(0xFFF8FAFC), fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      onPressed: _distributed < _totalShots
                          ? () => _setFor(player.userId, (_allocation[player.userId] ?? 0) + 1)
                          : null,
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFFFFBDF5)),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'Distributed $_distributed / $_totalShots shots',
            style: TextStyle(
              color: _distributed == _totalShots ? const Color(0xFFBAFA5E) : const Color(0xFFFDE68A),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}