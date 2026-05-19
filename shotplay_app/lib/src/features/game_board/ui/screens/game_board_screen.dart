import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/room_player.dart';
import '../../../../domain/entities/room_session.dart';
import '../../../../domain/repositories/game_event_repository.dart';
import '../bloc/game_board_controller.dart';
import '../sections/game_feed_section.dart';
import '../widgets/board_status_bar.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/roll_dice_button.dart';

/// Entry point for the game board screen.
/// Receives [room], [players] and [isAdmin] from the waiting room.
class GameBoardScreen extends StatelessWidget {
  const GameBoardScreen({
    super.key,
    required this.room,
    required this.players,
    required this.isAdmin,
  });

  final RoomSession room;
  final List<RoomPlayer> players;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

    return ChangeNotifierProvider<GameBoardController>(
      create:
          (ctx) => GameBoardController(
            gameEvents: ctx.read<GameEventRepository>(),
            currentUserId: currentUserId,
            isAdmin: isAdmin,
            players: players,
          ),
      child: _GameBoardView(
        room: room,
        isAdmin: isAdmin,
        currentUserId: currentUserId,
      ),
    );
  }
}

class _GameBoardView extends StatefulWidget {
  const _GameBoardView({
    required this.room,
    required this.isAdmin,
    required this.currentUserId,
  });

  final RoomSession room;
  final bool isAdmin;
  final String currentUserId;

  @override
  State<_GameBoardView> createState() => _GameBoardViewState();
}

class _GameBoardViewState extends State<_GameBoardView> {
  static const double _maxWidth = 440;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = context.read<GameBoardController>();
      if (widget.isAdmin) {
        // Admin inicia el juego y emite el estado al canal
        controller.startGame();
      } else {
        // No-admin pide al admin que re-emita el estado actual
        controller.requestSync();
      }
    });
  }

  Future<void> _onLeaveTap() async {
    final shouldLeave = await _showLeaveGameConfirmation(context);
    if (!shouldLeave || !mounted) return;

    await context.read<GameBoardController>().leaveGame();
    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.gameCatalog,
      (route) => false,
    );
  }

  Future<bool> _showLeaveGameConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF191022),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppTheme.primary.withOpacity(0.2)),
        ),
        title: const Text(
          '¿Seguro que quieres salir de la partida?',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Seguir jugando',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Salir de la partida',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameBoardController>();
    final gameState = controller.gameState;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Container(
            color: const Color(0xFF191022),
            child: SafeArea(
              child: Column(
                children: [
                  _TopBar(
                    roomCode: widget.room.roomCode,
                    onLeaveTap: _onLeaveTap,
                  ),

                  if (gameState != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: BoardStatusBar(
                        gameState: gameState,
                        currentTurnUsername: controller.currentTurnUsername,
                        myPosition: controller.myPosition,
                      ),
                    ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D3043),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: const Color(0xFF252336),
                                  width: 2,
                                ),
                              ),
                              padding: const EdgeInsets.all(5),
                              child: gameState != null
                                  ? GameBoardWidget(
                                      positions: gameState.positions,
                                      highlightSquare:
                                          controller.myPosition?.square,
                                    )
                                  : const _LoadingBoard(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (gameState != null)
                            GameFeedSection(
                              gameState: gameState,
                              currentUserId: widget.currentUserId,
                            ),

                          const SizedBox(height: 20),

                          if (gameState != null)
                            RollDiceButton(
                              isMyTurn: controller.isMyTurn,
                              isRolling: controller.isRolling,
                              onRoll: controller.rollDice,
                            )
                          else
                            const _LoadingButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Top bar (matches Figma) ────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.roomCode,
    required this.onLeaveTap,
  });

  final String roomCode;
  final VoidCallback onLeaveTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF22172D),
        border: Border.all(color: const Color(0x337F0DF2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App name
          const Text(
            'ShotPlay',
            style: TextStyle(
              color: Color(0xFFF1F5F9),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          // Room code
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'ROOM CODE',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    roomCode,
                    style: const TextStyle(
                      color: Color(0xFF00FFFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF272B43),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFF373E61),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              _TopBarIconButton(
                icon: Icons.logout_rounded,
                onTap: onLeaveTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  const _TopBarIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF272B43),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFF373E61),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF94A3B8),
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ── Loading mientras el tablero se inicializa ─────────────────────

class _LoadingBoard extends StatelessWidget {
  const _LoadingBoard();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFF5F0F86)),
          SizedBox(height: 16),
          Text(
            'Iniciando partida...',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _LoadingButton extends StatelessWidget {
  const _LoadingButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1D35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: Color(0xFF5F0F86),
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }
}