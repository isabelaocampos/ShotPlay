import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';
import 'board_layout.dart';

class PlayerTokenLayer extends StatelessWidget {
  const PlayerTokenLayer({
    super.key,
    required this.positions,
    required this.cellSize,
    this.silentPlayerId,
  });

  final List<PlayerPosition> positions;
  final double cellSize;
  final String? silentPlayerId;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          for (final position in positions)
            _PlayerToken(
              position: position,
              allPositions: positions,
              cellSize: cellSize,
              isSilent: position.playerId == silentPlayerId,
            ),
        ],
      ),
    );
  }
}

class _PlayerToken extends StatelessWidget {
  const _PlayerToken({
    required this.position,
    required this.allPositions,
    required this.cellSize,
    required this.isSilent,
  });

  final PlayerPosition position;
  final List<PlayerPosition> allPositions;
  final double cellSize;
  final bool isSilent;

  static const _tokenColors = [
    Color(0xFFBFFBF9),
    Color(0xFFFEE967),
    Color(0xFFFFBDF5),
    Color(0xFFBAFA5E),
  ];

  @override
  Widget build(BuildContext context) {
    final gridPos = squareToGridPos(position.square);
    final sameCell = allPositions.where((p) => p.square == position.square).toList();
    final myIndex = sameCell.indexOf(position);
    final offsetX = myIndex.isOdd ? cellSize * 0.19 : -cellSize * 0.19;
    final offsetY = myIndex >= 2 ? cellSize * 0.19 : -cellSize * 0.19;
    final hasOverlap = sameCell.length > 1;
    final cx = gridPos.col * cellSize + cellSize / 2 + (hasOverlap ? offsetX : 0);
    final cy = gridPos.row * cellSize + cellSize / 2 + (hasOverlap ? offsetY : 0);
    final r = cellSize * 0.20;
    final color = _tokenColors[position.avatarIndex % _tokenColors.length];
    final avatarUrl = position.avatarUrl;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      left: cx - r,
      top: cy - r,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: hasOverlap ? 0.96 : 1.02,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: r * 2.15,
              height: r * 2.15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.30),
                    blurRadius: 16,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
            Container(
              width: r * 2,
              height: r * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.82),
                  width: 1.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.58),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipOval(
                child: avatarUrl == null || avatarUrl.trim().isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              color.withValues(alpha: 0.98),
                              color.withValues(alpha: 0.72),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            position.username.isNotEmpty
                                ? position.username.substring(0, 1).toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: const Color(0xFF120818),
                              fontSize: r * 0.88,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  color: Colors.white.withValues(alpha: 0.40),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                color.withValues(alpha: 0.98),
                                color.withValues(alpha: 0.72),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              position.username.isNotEmpty
                                  ? position.username.substring(0, 1).toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: const Color(0xFF120818),
                                fontSize: r * 0.88,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            if (isSilent)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E1018),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF07FCFE).withValues(alpha: 0.52), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF07FCFE).withValues(alpha: 0.30),
                        blurRadius: 8,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.volume_off_rounded,
                    size: 10,
                    color: Color(0xFF07FCFE),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
