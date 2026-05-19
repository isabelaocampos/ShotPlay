import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../domain/entities/room_player.dart';
import '../../../../domain/entities/room_session.dart';
import '../../../../domain/repositories/game_event_repository.dart';
import '../../../../domain/repositories/room_repository.dart';
import '../../../../core/routing/app_routes.dart';
import '../../domain/entities/board_entities.dart';
import '../bloc/game_board_controller.dart';
import '../widgets/board/game_board_widget.dart';
import '../widgets/hud/board_status_bar.dart';
import '../widgets/hud/game_feed_section.dart';
import '../widgets/hud/roll_dice_button.dart';
import '../widgets/modals/give_shot_dialog.dart';
import '../widgets/modals/take_shot_dialog.dart';
import '../widgets/modals/truth_or_dare_dialog.dart';
import '../widgets/dice_roll_dialog.dart';
import '../widgets/penalty_challenge_dialog.dart';

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
        players: players,
      ),
    );
  }
}

class _GameBoardView extends StatefulWidget {
  const _GameBoardView({
    required this.room,
    required this.isAdmin,
    required this.currentUserId,
    required this.players,
  });

  final RoomSession room;
  final bool isAdmin;
  final String currentUserId;
  final List<RoomPlayer> players;

  @override
  State<_GameBoardView> createState() => _GameBoardViewState();
}

class _GameBoardViewState extends State<_GameBoardView> {
  GameBoardController? _controller;
  int? _lastDiceShowed;
  bool _winnerDialogShown = false;
  bool _challengeDialogShowing = false;
  bool _specialDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller = context.read<GameBoardController>();
      _controller?.addListener(_onControllerChange);

      if (widget.isAdmin) {
        _controller?.startGame();
      } else {
        _controller?.requestSync();
      }
    });
  }

  void _onControllerChange() {
    if (!mounted) return;

    if (_controller!.status == GameBoardStatus.finished &&
        !_winnerDialogShown) {
      _winnerDialogShown = true;
      _showWinnerDialog();
      return;
    }

    // Penalty challenge: only shown to the rolling player (local decision).
    if (_controller!.pendingChallenge != null && !_challengeDialogShowing) {
      _challengeDialogShowing = true;
      _showPenaltyChallengeDialog();
    }

    if (_controller!.pendingSpecialCell != null && !_specialDialogShowing) {
      _specialDialogShowing = true;
      _showSpecialCellDialog();
    }

    if (_controller!.animatingDiceValue != null &&
        _controller!.animatingDiceValue != _lastDiceShowed) {
      _lastDiceShowed = _controller!.animatingDiceValue;

      showDialog(
        context: context,
        barrierColor: Colors.black87,
        barrierDismissible: false,
        builder:
            (_) => PopScope(
              canPop: false,
              child: DiceRollDialog(value: _lastDiceShowed ?? 1),
            ),
      );
    } else if (_controller!.animatingDiceValue == null &&
        _lastDiceShowed != null) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _lastDiceShowed = null;
    }
  }

  void _showSpecialCellDialog() {
    final specialCell = _controller?.pendingSpecialCell;
    if (specialCell == null) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: switch (specialCell.type) {
          SpecialCellType.takeShot => TakeShotDialog(
              cell: specialCell,
              onConfirm: () {
                Navigator.of(ctx).pop();
                _specialDialogShowing = false;
                _controller?.respondToTakeShot();
              },
            ),
          SpecialCellType.giveShot => GiveShotDialog(
              cell: specialCell,
              players: widget.players,
              currentUserId: widget.currentUserId,
              onConfirm: (player) {
                Navigator.of(ctx).pop();
                _specialDialogShowing = false;
                _controller?.respondToGiveShot(player.userId);
              },
            ),
          SpecialCellType.truthOrDare => TruthOrDareDialog(
              cell: specialCell,
              onTruth: () {
                Navigator.of(ctx).pop();
                _specialDialogShowing = false;
                _controller?.respondToTruthOrDare(true);
              },
              onDare: () {
                Navigator.of(ctx).pop();
                _specialDialogShowing = false;
                _controller?.respondToTruthOrDare(false);
              },
            ),
        },
      ),
    );
  }

  void _showPenaltyChallengeDialog() {
    final challenge = _controller?.pendingChallenge;
    if (challenge == null) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: PenaltyChallengeDialog(
          challenge: challenge,
          onAccept: () {
            Navigator.of(ctx).pop();
            _challengeDialogShowing = false;
            _controller?.respondToChallenge(true);
          },
          onReject: () {
            Navigator.of(ctx).pop();
            _challengeDialogShowing = false;
            _controller?.respondToChallenge(false);
          },
        ),
      ),
    );
  }

  Future<void> _showWinnerDialog() async {
    final winnerName = _controller?.winnerUsername ?? 'Alguien';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => PopScope(
            canPop: false,
            child: AlertDialog(
              title: const Text('Partida terminada'),
              content: Text('Ganó $winnerName. Todos volverán al lobby.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Ir al lobby'),
                ),
              ],
            ),
          ),
    );

    if (mounted) {
      _goToLobby();
    }
  }

  void _goToLobby() {
    Navigator.of(context).popUntil(
      (route) => route.settings.name == AppRoutes.home || route.isFirst,
    );
  }

  Future<void> _confirmExit() async {
    final title = widget.isAdmin ? '¿Cerrar partida?' : '¿Salir de la partida?';
    final content =
        widget.isAdmin
            ? 'Si sales, la partida terminará para todos y la sala se cerrará.'
            : 'Saldrás de la partida y tendrás que volver a unirte a la sala.';

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(
                  'Confirmar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true && mounted) {
      final roomRepo = context.read<RoomRepository>();
      try {
        if (widget.isAdmin) {
          await roomRepo.closeRoom(widget.room.idRoom);
        } else {
          await roomRepo.leaveRoom(widget.room.idRoom);
        }
      } catch (_) {}

      if (mounted) {
        Navigator.of(context).popUntil(
          (route) => route.settings.name == AppRoutes.home || route.isFirst,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameBoardController>();
    final gameState = controller.gameState;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF140B22), Color(0xFF09070F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(
                roomCode: widget.room.roomCode,
                onExitPressed: _confirmExit,
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
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF20142B).withValues(alpha: 0.96),
                                    const Color(0xFF0F0A18).withValues(alpha: 0.96),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFF07FCFE).withValues(alpha: 0.30),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF5F0F86).withValues(alpha: 0.22),
                                    blurRadius: 24,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(6),
                              child:
                                  gameState != null
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.roomCode, required this.onExitPressed});

  final String roomCode;
  final VoidCallback onExitPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF22172D),
        border: Border.all(color: const Color(0x337F0DF2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: onExitPressed,
                tooltip: 'Salir',
              ),
              const SizedBox(width: 8),
              const Text(
                'ShotPlay',
                style: TextStyle(
                  color: Color(0xFFF1F5F9),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
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
            ],
          ),
        ],
      ),
    );
  }
}

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
