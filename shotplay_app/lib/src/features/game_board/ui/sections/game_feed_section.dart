import 'package:flutter/material.dart';

import '../../domain/entities/board_entities.dart';

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
    // Player whose turn it is RIGHT NOW (hasn't rolled yet).
    final currentPlayer = gameState.positions
        .where((p) => p.playerId == gameState.currentTurnPlayerId)
        .firstOrNull;

    // Player who JUST rolled (may differ from currentPlayer after turn advance).
    final lastMover = gameState.lastMovedPlayerId.isNotEmpty
        ? gameState.positions
            .where((p) => p.playerId == gameState.lastMovedPlayerId)
            .firstOrNull
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.electric_bolt_rounded,
                color: Color(0xFF94A3B8), size: 14),
            SizedBox(width: 6),
            Text(
              'GAME FEED',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Last dice roll — attributed to the player who actually rolled.
        if (gameState.lastDiceValue > 0 && lastMover != null)
          _FeedItem(
            username: lastMover.username,
            action: 'lanzó un',
            highlight: '${gameState.lastDiceValue}',
            sub: 'Avanzó a la casilla ${lastMover.square}',
            isActive: true,
          ),

        // Penalty challenge outcome (only shown when a challenge occurred).
        if (gameState.lastEventLog.isNotEmpty) ...[
          const SizedBox(height: 8),
          _EventLogItem(message: gameState.lastEventLog),
        ],

        const SizedBox(height: 8),
        // Waiting for the current player to roll.
        Opacity(
          opacity: 0.6,
          child: _FeedItem(
            username: currentPlayer?.username ?? '...',
            action: 'tiene el turno',
            highlight: '',
            sub: 'Casilla ${currentPlayer?.square ?? 1}/49',
            isActive: false,
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2535),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5F0F86).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_bar_rounded, color: Color(0xFFBAFA5E), size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFBAFA5E),
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
    required this.username,
    required this.action,
    required this.highlight,
    required this.sub,
    required this.isActive,
  });

  final String username;
  final String action;
  final String highlight;
  final String sub;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF302839).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFF334155).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFBFFBF9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    username.isNotEmpty
                        ? username.substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Color(0xFF1E0412),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$username $action ',
                          style: const TextStyle(
                            color: Color(0xFFF1F5F9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (highlight.isNotEmpty)
                          TextSpan(
                            text: highlight,
                            style: const TextStyle(
                              color: Color(0xFF07FCFE),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Text(
            'ahora',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
          ),
        ],
      ),
    );
  }
}
