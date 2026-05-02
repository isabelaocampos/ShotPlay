import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_theme.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../domain/entities/game_room.dart';
import '../../domain/entities/room_player.dart';
import '../cubits/waiting_room_cubit.dart';

class WaitingRoomScreen extends StatelessWidget {
  final GameRoom room;

  const WaitingRoomScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WaitingRoomCubit(
        GameRepositoryImpl(Supabase.instance.client),
      )..watchPlayers(room.id),
      child: _WaitingRoomView(room: room),
    );
  }
}

class _WaitingRoomView extends StatelessWidget {
  final GameRoom room;
  const _WaitingRoomView({required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          room.roomName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
            tooltip: 'Compartir código ${room.roomCode}',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<WaitingRoomCubit, WaitingRoomState>(
        builder: (context, state) {
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _StatusBanner(roomCode: room.roomCode),
                const SizedBox(height: 20),
                _PlayersHeader(
                  current: state.players.length,
                  total: room.maxPlayers,
                ),
                const SizedBox(height: 14),
                _PlayersGrid(
                  players: state.players,
                  total: room.maxPlayers,
                  isLoading: state.status == WaitingRoomStatus.loading,
                ),
                if (state.status == WaitingRoomStatus.error) ...[
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Error al cargar jugadores',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: 24),
                const _TipsCard(),
                const SizedBox(height: 18),
                _BottomStatus(
                  current: state.players.length,
                  total: room.maxPlayers,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String roomCode;
  const _StatusBanner({required this.roomCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primarySoft, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_top_rounded, color: Colors.white),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'ESPERANDO A QUE EL ANFITRIÓN INICIE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              roomCode,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayersHeader extends StatelessWidget {
  final int current;
  final int total;

  const _PlayersHeader({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'SALA DE ESPERA · JUGADORES',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          '$current/$total',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PlayersGrid extends StatelessWidget {
  final List<RoomPlayer> players;
  final int total;
  final bool isLoading;

  const _PlayersGrid({
    required this.players,
    required this.total,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && players.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final slots = total;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 14,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        if (index < players.length) {
          return _PlayerTile(player: players[index]);
        }
        return const _EmptyPlayerTile();
      },
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final RoomPlayer player;
  const _PlayerTile({required this.player});

  @override
  Widget build(BuildContext context) {
    final colors = _avatarPalette(player.userId);
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: colors),
            border: Border.all(
              color: player.isHost ? AppColors.badge : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              _initial(player.username),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          player.username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          player.statusLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: player.isHost
                ? AppColors.badge
                : (player.isReady
                    ? AppColors.success
                    : AppColors.textMuted),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  String _initial(String name) =>
      name.isEmpty ? '?' : name.trim()[0].toUpperCase();

  List<Color> _avatarPalette(String seed) {
    const palettes = [
      [Color(0xFF7C3AED), Color(0xFFEC4899)],
      [Color(0xFF22C55E), Color(0xFF0EA5E9)],
      [Color(0xFFF59E0B), Color(0xFFEF4444)],
      [Color(0xFF06B6D4), Color(0xFF7C3AED)],
      [Color(0xFFD946EF), Color(0xFFF59E0B)],
      [Color(0xFF22D3EE), Color(0xFF22C55E)],
    ];
    final hash = seed.codeUnits.fold<int>(0, (a, b) => a + b);
    return palettes[hash % palettes.length];
  }
}

class _EmptyPlayerTile extends StatelessWidget {
  const _EmptyPlayerTile();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            border: Border.all(
              color: AppColors.border,
              style: BorderStyle.solid,
            ),
          ),
          child: const Icon(Icons.person_outline,
              color: AppColors.textMuted, size: 22),
        ),
        const SizedBox(height: 6),
        const Text(
          'Vacío',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 2),
        const Text(
          'ESPERANDO',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tips_and_updates_outlined,
                  color: AppColors.secondary, size: 18),
              SizedBox(width: 8),
              Text(
                'TIPS & GUÍAS',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Comparte el código de la sala con tus amigos para que se '
            'unan rápido. Cuando todos estén listos, el anfitrión podrá '
            'iniciar la partida.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomStatus extends StatelessWidget {
  final int current;
  final int total;
  const _BottomStatus({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final isFull = current >= total;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isFull
            ? AppColors.success.withValues(alpha: 0.18)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFull ? AppColors.success : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isFull ? Icons.check_circle_outline : Icons.access_time_rounded,
            color: isFull ? AppColors.success : AppColors.textMuted,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isFull
                  ? 'Sala completa — listos para empezar'
                  : 'Faltan ${total - current} jugadores para iniciar',
              style: TextStyle(
                color: isFull ? AppColors.success : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
