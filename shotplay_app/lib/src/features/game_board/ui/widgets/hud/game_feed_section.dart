import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';

class GameFeedSection extends StatelessWidget {
  const GameFeedSection({
    super.key,
    required this.gameState,
    required this.currentUserId,
  });

  final GameState gameState;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final currentPlayer = gameState.positions
        .where((p) => p.playerId == gameState.currentTurnPlayerId)
        .firstOrNull;

    final lastMover = gameState.lastMovedPlayerId.isNotEmpty
        ? gameState.positions
            .where((p) => p.playerId == gameState.lastMovedPlayerId)
            .firstOrNull
        : null;

    final isMe = currentPlayer?.playerId == currentUserId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF140D1B).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF5F0F86).withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF07FCFE).withValues(alpha: 0.06),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.electric_bolt_rounded, color: Color(0xFF07FCFE), size: 15),
              SizedBox(width: 8),
              Text(
                'GAME FEED',
                style: TextStyle(
                  color: Color(0xFFF1F5F9),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (gameState.lastDiceValue > 0 && lastMover != null)
            _FeedItem(
              icon: Icons.person_rounded,
              accent: const Color(0xFF07FCFE),
              username: lastMover.username,
              action: 'tiro',
              highlight: '${gameState.lastDiceValue}',
              sub: 'Avanzo a la casilla ${lastMover.square}',
            ),
          if (gameState.lastEventLog.isNotEmpty) ...[
            const SizedBox(height: 10),
            _EventLogItem(message: gameState.lastEventLog),
          ],
          const SizedBox(height: 10),
          Opacity(
            opacity: isMe ? 1 : 0.78,
            child: _FeedItem(
              icon: Icons.person_rounded,
              accent: isMe ? const Color(0xFFFFBDF5) : const Color(0xFF94A3B8),
              username: currentPlayer?.username ?? '...',
              action: 'tiene el turno',
              highlight: '',
              sub: 'Casilla ${currentPlayer?.square ?? 1}/49',
            ),
          ),
        ],
      ),
    );
  }
}

class _EventLogItem extends StatelessWidget {
  const _EventLogItem({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1026),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAFA5E).withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_bar_rounded, color: Color(0xFFBAFA5E), size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFDE68A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedItem extends StatelessWidget {
  const _FeedItem({
    required this.icon,
    required this.accent,
    required this.username,
    required this.action,
    required this.highlight,
    required this.sub,
  });

  final IconData icon;
  final Color accent;
  final String username;
  final String action;
  final String highlight;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1422).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [accent.withValues(alpha: 0.95), accent.withValues(alpha: 0.55)],
              ),
            ),
              child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$username $action ',
                        style: const TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (highlight.isNotEmpty)
                        TextSpan(
                          text: highlight,
                          style: TextStyle(
                            color: accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sub,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
