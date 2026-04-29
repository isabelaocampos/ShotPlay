import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../common_widgets/app_bottom_navigation_bar.dart';
import '../../../common_widgets/primary_button.dart';
import '../../../core/routing/app_routes.dart';
import '../../../domain/entities/game_option.dart';
import '../../../domain/entities/room_session.dart';

class WaitingRoomScreen extends StatelessWidget {
  const WaitingRoomScreen({
    super.key,
    required this.room,
    required this.isAdmin,
  });

  final RoomSession room;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final game = gameOptionFromId(room.gameId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sala de espera'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF140B22), Color(0xFF09070F)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _RoomCodeCard(room: room, game: game),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Jugadores conectados',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF01FFF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '2/${room.maxPlayers}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _PlayerCard(
                  name: 'Majito (Host)',
                  status: 'Listo para jugar',
                  accentColor: const Color(0xFFB56BFF),
                  isHost: true,
                ),
                const SizedBox(height: 10),
                const _PlayerCard(
                  name: 'Daniel',
                  status: 'Conectado',
                  accentColor: Color(0xFF4DE3FF),
                ),
                const SizedBox(height: 10),
                const _PlayerCard(
                  name: 'Sara',
                  status: 'Uniéndose...',
                  accentColor: Color(0xFFFFB23F),
                ),
                const SizedBox(height: 10),
                _PendingCard(maxPlayers: room.maxPlayers),
                const SizedBox(height: 18),
                if (isAdmin)
                  PrimaryButton(
                    label: 'INICIAR PARTIDA',
                    onPressed: () {},
                  )
                else
                  Text(
                    'Solo el administrador puede iniciar la partida.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 1,
        onHomeTap: () {
          Navigator.of(context).pushReplacementNamed(AppRoutes.gameDetails);
        },
        onGamesTap: () {},
        onSocialTap: () {},
        onProfileTap: () {},
      ),
    );
  }
}

class _RoomCodeCard extends StatelessWidget {
  const _RoomCodeCard({required this.room, required this.game});

  final RoomSession room;
  final GameOption game;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1D1230), Color(0xFF0F0B17)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            game.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              width: 180,
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1230),
                borderRadius: BorderRadius.circular(18),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF8E24FF).withOpacity(0.25),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
                border: Border.all(color: const Color(0xFF8E24FF).withOpacity(0.28)),
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    room.roomCode,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFFB427F5),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.4,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'CÓDIGO SALA',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white54,
                          letterSpacing: 1.6,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: room.roomCode));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código copiado al portapapeles.')),
                  );
                }
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('COPIAR LINK'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.name,
    required this.status,
    required this.accentColor,
    this.isHost = false,
  });

  final String name;
  final String status;
  final Color accentColor;
  final bool isHost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1227),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 22,
            backgroundColor: accentColor.withOpacity(0.22),
            child: Text(
              name.substring(0, 1).toUpperCase(),
              style: TextStyle(color: accentColor, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (isHost) ...<Widget>[
                      const SizedBox(width: 8),
                      const Icon(Icons.workspace_premium_rounded, color: Color(0xFFF01FFF), size: 18),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                      ),
                ),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isHost ? const Color(0xFFF01FFF) : const Color(0xFF45E36C),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.maxPlayers});

  final int maxPlayers;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Text(
          'Esperando más jugadores ...',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white38,
              ),
        ),
      ),
    );
  }
}