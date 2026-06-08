import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/app_bottom_navigation_bar.dart';
import '../../../common_widgets/primary_button.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/ui/game_option_ui.dart';
import '../../../domain/entities/game_option.dart';
import '../../../domain/entities/room_lifecycle_status.dart';
import '../../../domain/entities/room_player.dart';
import '../../../domain/entities/room_session.dart';
import '../../../domain/repositories/game_event_repository.dart';
import '../../../domain/repositories/room_repository.dart';
import '../domain/usecases/connect_room_game_events_usecase.dart';
import '../domain/usecases/disconnect_room_game_events_usecase.dart';
import '../domain/usecases/emit_game_start_usecase.dart';
import '../domain/usecases/emit_lobby_sync_usecase.dart';
import '../domain/usecases/fetch_room_players_usecase.dart';
import '../domain/usecases/watch_game_events_usecase.dart';
import '../domain/usecases/leave_room_usecase.dart';
import '../domain/usecases/close_room_usecase.dart';
import '../domain/usecases/emit_room_closed_usecase.dart';
import '../../session/domain/usecases/update_room_status_usecase.dart';
import '../../../core/session/room_session_lifecycle_scope.dart';
import 'waiting_room_controller.dart';

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
    return ChangeNotifierProvider<WaitingRoomController>(
      create: (ctx) {
        final gameEvents = ctx.read<GameEventRepository>();
        final roomRepo = ctx.read<RoomRepository>();
        return WaitingRoomController(
          roomRepository: roomRepo,
          connectGameEvents: ConnectRoomGameEventsUsecase(gameEvents),
          disconnectGameEvents: DisconnectRoomGameEventsUsecase(gameEvents),
          watchGameEvents: WatchGameEventsUsecase(gameEvents),
          fetchRoomPlayers: FetchRoomPlayersUsecase(roomRepo),
          emitLobbySync: EmitLobbySyncUsecase(gameEvents),
          emitGameStart: EmitGameStartUsecase(gameEvents),
          leaveRoom: LeaveRoomUsecase(roomRepo),
          closeRoom: CloseRoomUsecase(roomRepo),
          emitRoomClosed: EmitRoomClosedUsecase(gameEvents),
          updateRoomStatus: UpdateRoomStatusUsecase(roomRepo),
        )..start(
            roomCode: room.roomCode,
            roomId: room.idRoom,
            roomStatus: room.status,
          );
      },
      child: RoomSessionLifecycleScope(
        roomId: room.idRoom,
        roomCode: room.roomCode,
        child: _WaitingRoomView(room: room, isAdmin: isAdmin),
      ),
    );
  }
}

// ── Convertido a StatefulWidget para poder reaccionar a gameStarted ──

class _WaitingRoomView extends StatefulWidget {
  const _WaitingRoomView({required this.room, required this.isAdmin});

  final RoomSession room;
  final bool isAdmin;

  @override
  State<_WaitingRoomView> createState() => _WaitingRoomViewState();
}

class _WaitingRoomViewState extends State<_WaitingRoomView> {
  bool _navigated = false;

  void _goToBoard(WaitingRoomController controller) {
    if (_navigated) return;
    _navigated = true;
    controller.markAsNavigatingToBoard();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isImpostorGame = gameOptionFromDbId(widget.room.gameId).id == 'impostor';

      Navigator.of(context).pushReplacementNamed(
        isImpostorGame ? AppRoutes.impostorReveal : AppRoutes.gameBoard,
        arguments: {
          'room': widget.room,
          'players': controller.players,
          'isAdmin': widget.isAdmin,
        },
      );
    });
  }

  void _handleRoomClosed() {
    if (_navigated) return;
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El administrador cerró la sala.')),
      );
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WaitingRoomController>();
    final game = gameOptionFromDbId(widget.room.gameId);

    if (controller.roomClosedByAdmin) {
      _handleRoomClosed();
    }

    // Cuando llega game.start por realtime, TODOS navegan al tablero
    if (controller.gameStarted) {
      _goToBoard(controller);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sala de espera'),
        leading: BackButton(
          onPressed: () => _confirmExit(context, controller),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => _shareCode(context),
            icon: const Icon(Icons.share_rounded),
          ),
        ],
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
                _RoomCodeCard(room: widget.room, game: game),
                const SizedBox(height: 16),
                _PlayersHeader(
                  current: controller.players.length,
                  total: widget.room.maxPlayers,
                ),
                const SizedBox(height: 12),
                _PlayersSection(
                  controller: controller,
                  total: widget.room.maxPlayers,
                  hostAccent: game.accentColor,
                ),
                const SizedBox(height: 18),
                _TipsCard(),
                const SizedBox(height: 18),
                if (widget.isAdmin)
                  PrimaryButton(
                    label: 'INICIAR PARTIDA',
                    // Solo activo con >= 2 jugadores
                    onPressed: controller.players.length >= 2
                        ? () => _startGame(controller)
                        : null,
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
        currentIndex: 0,
        onGamesTap: () {},
        onProfileTap: () {},
      ),
    );
  }

  /// El admin emite game.start por el canal → todos (incluido el admin)
  /// reciben el evento y navegan vía _goToBoard.
  Future<void> _startGame(WaitingRoomController controller) async {
    await controller.emitGameStart();
    // Esperamos 800ms para que Supabase entregue el broadcast
    // al no-admin ANTES de que el admin destruya el canal al navegar.
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (mounted && !_navigated) {
      _goToBoard(controller);
    }
  }

  Future<void> _shareCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: widget.room.roomCode));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código copiado al portapapeles.')),
      );
    }
  }

  Future<void> _confirmExit(
      BuildContext context, WaitingRoomController controller) async {
    final title = widget.isAdmin ? '¿Cerrar sala?' : '¿Salir de la sala?';
    final content = widget.isAdmin
        ? 'Esto cancelará la partida y sacará a todos los jugadores.'
        : 'Abandonarás la sala y tendrás que volver a ingresar con el código.';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirmar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      if (widget.isAdmin) {
        await controller.closeRoom(widget.room.idRoom);
      } else {
        await controller.leaveRoom(widget.room.idRoom);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}

// ── Widgets de soporte (sin cambios) ──────────────────────────────

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
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFB427F5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'ESPERANDO ANFITRIÓN',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                ),
              ),
              const Spacer(),
              Text(
                game.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              width: 200,
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
                border: Border.all(
                    color: const Color(0xFF8E24FF).withOpacity(0.28)),
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
                    const SnackBar(
                      content: Text('Código copiado al portapapeles.'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('COPIAR CÓDIGO'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayersHeader extends StatelessWidget {
  const _PlayersHeader({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            '$current/$total',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }
}

class _PlayersSection extends StatelessWidget {
  const _PlayersSection({
    required this.controller,
    required this.total,
    required this.hostAccent,
  });

  final WaitingRoomController controller;
  final int total;
  final Color hostAccent;

  @override
  Widget build(BuildContext context) {
    if (controller.status == WaitingRoomStatus.loading &&
        controller.players.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.status == WaitingRoomStatus.error) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          controller.errorMessage ?? 'Error al cargar jugadores',
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    final players = controller.players;
    final emptySlots = (total - players.length).clamp(0, total);

    return Column(
      children: <Widget>[
        for (final player in players) ...<Widget>[
          _PlayerCard(player: player, hostAccent: hostAccent),
          const SizedBox(height: 10),
        ],
        for (var i = 0; i < emptySlots; i++) ...<Widget>[
          const _PendingCard(),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.player, required this.hostAccent});

  final RoomPlayer player;
  final Color hostAccent;

  @override
  Widget build(BuildContext context) {
    final accent = player.isHost ? hostAccent : const Color(0xFF4DE3FF);
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
            backgroundColor: accent.withOpacity(0.22),
            child: Text(
              player.username.isEmpty
                  ? '?'
                  : player.username.substring(0, 1).toUpperCase(),
              style: TextStyle(color: accent, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        player.username,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (player.isHost) ...<Widget>[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFFF01FFF),
                        size: 18,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  player.statusLabel,
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
              color: player.isHost
                  ? const Color(0xFFF01FFF)
                  : (player.isReady
                      ? const Color(0xFF45E36C)
                      : const Color(0xFFFFB23F)),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard();

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

class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1227),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: const <Widget>[
              Icon(Icons.tips_and_updates_outlined,
                  color: Color(0xFFB427F5), size: 18),
              SizedBox(width: 8),
              Text(
                'TIPS & GUÍAS',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Comparte el código de la sala con tus amigos para que se '
            'unan rápido. Cuando todos estén listos, el anfitrión podrá '
            'iniciar la partida.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}