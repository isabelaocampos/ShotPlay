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
    final currentPlayer = gameState.positions
        .where((p) => p.playerId == gameState.currentTurnPlayerId)
        .firstOrNull;

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
        // Last dice roll event
        if (gameState.lastDiceValue > 0 && currentPlayer != null)
          _FeedItem(
            username: currentPlayer.username,
            action: 'lanzó un',
            highlight: '${gameState.lastDiceValue}',
            sub:
                'Avanzó a la casilla ${currentPlayer.square}',
            isActive: true,
          ),
        const SizedBox(height: 8),
        // Waiting for turn
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
