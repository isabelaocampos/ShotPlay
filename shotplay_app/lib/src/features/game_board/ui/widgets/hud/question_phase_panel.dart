import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/entities/board_entities.dart';
import 'package:shotplay_app/src/features/impostor/domain/entities/impostor_entities.dart';

class QuestionPhasePanel extends StatefulWidget {
  const QuestionPhasePanel({
    super.key,
    required this.gameState,
  });

  final GameState gameState;

  @override
  State<QuestionPhasePanel> createState() => _QuestionPhasePanelState();
}

class _QuestionPhasePanelState extends State<QuestionPhasePanel> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  @override
  void didUpdateWidget(covariant QuestionPhasePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameState.questionPhase?.phase !=
        widget.gameState.questionPhase?.phase) {
      _startTicker();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phase = widget.gameState.questionPhase;
    if (phase == null) return const SizedBox.shrink();

    final isVoting = phase.isVoting;
    final remainingSeconds = phase.remainingSeconds;
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    final alivePlayers = widget.gameState.positions.where((player) {
      if (phase.alivePlayerIds.isEmpty) return true;
      return phase.alivePlayerIds.contains(player.playerId);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF26112F).withValues(alpha: 0.95),
            const Color(0xFF0F0A18).withValues(alpha: 0.98),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF07FCFE).withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF01FFF).withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isVoting
                      ? const Color(0xFFFFBDF5).withValues(alpha: 0.18)
                      : const Color(0xFF07FCFE).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isVoting ? 'FASE DE VOTACIÓN' : 'FASE DE PREGUNTAS',
                  style: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Ronda ${phase.roundNumber}',
                style: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tiempo restante',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isVoting ? '00:00' : '$minutes:$seconds',
                      style: const TextStyle(
                        color: Color(0xFFF8FAFC),
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isVoting
                          ? 'La ronda pasó a votación.'
                          : 'El tiempo se calcula desde la hora global de inicio.',
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF07FCFE), Color(0xFFF01FFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF07FCFE).withValues(alpha: 0.18),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'VIVOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${alivePlayers.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Jugadores vivos',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          if (alivePlayers.isEmpty)
            const Text(
              'Aún no hay jugadores disponibles para mostrar.',
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 12,
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: alivePlayers.map((player) {
                return _AlivePlayerChip(player: player);
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _AlivePlayerChip extends StatelessWidget {
  const _AlivePlayerChip({required this.player});

  final PlayerPosition player;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF17111F),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF07FCFE).withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: const Color(0xFF07FCFE).withValues(alpha: 0.18),
            backgroundImage: player.avatarUrl != null && player.avatarUrl!.isNotEmpty
                ? NetworkImage(player.avatarUrl!)
                : null,
            child: player.avatarUrl == null || player.avatarUrl!.isEmpty
                ? Text(
                    player.username.isEmpty
                        ? '?'
                        : player.username.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF07FCFE),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            player.username,
            style: const TextStyle(
              color: Color(0xFFF8FAFC),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
