import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shotplay_app/src/features/game_board/domain/entities/board_entities.dart';
import 'package:shotplay_app/src/features/game_board/domain/game_board_event_types.dart';
import 'package:shotplay_app/src/features/game_board/domain/usecases/leave_game_usecase.dart';
import 'package:shotplay_app/src/features/game_board/domain/usecases/roll_dice_usecase.dart';
import 'package:shotplay_app/src/features/game_board/domain/usecases/start_game_usecase.dart';
import 'package:shotplay_app/src/features/game_board/domain/usecases/watch_game_board_events_usecase.dart';

import '../../../../core/constants/game_event_types.dart';
import '../../../../domain/entities/room_player.dart';
import '../../../../domain/repositories/game_event_repository.dart';

// import '../entities/board_entities.dart';
// import '../game_board_event_types.dart';
// import '../usecases/roll_dice_usecase.dart';
// import '../usecases/start_game_usecase.dart';
// import '../usecases/watch_game_board_events_usecase.dart';

enum GameBoardStatus { waiting, playing, finished }

class GameBoardController extends ChangeNotifier {
  GameBoardController({
    required GameEventRepository gameEvents,
    required this.currentUserId,
    required this.isAdmin,
    required List<RoomPlayer> players,
  })  : _gameEvents = gameEvents,
        _startGame = StartGameUsecase(gameEvents),
        _rollDice = RollDiceUsecase(gameEvents),
        _watchEvents = WatchGameBoardEventsUsecase(gameEvents),
        _leaveGame = LeaveGameUsecase(gameEvents),
        _players = players {
    _eventsSubscription = _watchEvents.execute().listen(_onEvent);
  }

  final GameEventRepository _gameEvents;
  final StartGameUsecase _startGame;
  final RollDiceUsecase _rollDice;
  final WatchGameBoardEventsUsecase _watchEvents;
  final LeaveGameUsecase _leaveGame;
  final List<RoomPlayer> _players;

  StreamSubscription<Map<String, dynamic>>? _eventsSubscription;

  final String currentUserId;
  final bool isAdmin;

  GameBoardStatus _status = GameBoardStatus.waiting;
  GameState? _gameState;
  bool _isRolling = false;

  GameBoardStatus get status => _status;
  GameState? get gameState => _gameState;
  bool get isRolling => _isRolling;

  bool get isMyTurn =>
      _gameState != null &&
      _gameState!.currentTurnPlayerId == currentUserId &&
      _status == GameBoardStatus.playing;

  PlayerPosition? get myPosition => _gameState?.positions
      .where((p) => p.playerId == currentUserId)
      .firstOrNull;

  String get currentTurnUsername {
    if (_gameState == null) return '';
    final pos = _gameState!.positions
        .where((p) => p.playerId == _gameState!.currentTurnPlayerId)
        .firstOrNull;
    return pos?.username ?? '';
  }

  // ── Public actions ──────────────────────────────────────────────

  /// Admin: inicia el juego y emite el estado al canal.
  Future<void> startGame() async {
    if (!isAdmin) return;
    try {
      final state = await _startGame.execute(_players);
      _gameState = state;
      _status = GameBoardStatus.playing;
      notifyListeners();
    } catch (e) {
      debugPrint('[BOARD] startGame error: $e');
    }
  }

  /// No-admin: pide al admin que re-emita el estado actual.
  Future<void> requestSync() async {
    if (isAdmin) return;
    try {
      await _gameEvents.emitEvent({'type': GameEventTypes.gameSync});
      debugPrint('[BOARD] sync request enviado');
    } catch (e) {
      debugPrint('[BOARD] requestSync error: $e');
    }
  }

  /// Disconnects from the room realtime channel when leaving the board.
  Future<void> leaveGame() async {
    try {
      await _leaveGame.execute();
      debugPrint('[BOARD] left game — channel disconnected');
    } catch (e) {
      debugPrint('[BOARD] leaveGame error: $e');
    }
  }

  Future<void> rollDice() async {
    if (!isMyTurn || _isRolling) return;
    _isRolling = true;
    notifyListeners();

    try {
      final state = await _rollDice.execute(_gameState!);
      _gameState = state;
      final winner = state.positions.where((p) => p.square >= 49).firstOrNull;
      if (winner != null) _status = GameBoardStatus.finished;
    } catch (e) {
      debugPrint('[BOARD] rollDice error: $e');
    } finally {
      _isRolling = false;
      notifyListeners();
    }
  }

  // ── Event listener ───────────────────────────────────────────────

  void _onEvent(Map<String, dynamic> event) {
    final type = event['type'] as String?;

    // Estado completo del juego recibido (game.start o game.dice_roll)
    if (type == GameBoardEventTypes.gameStart ||
        type == GameBoardEventTypes.diceRoll) {
      try {
        final state = GameState.fromJson(event);
        _gameState = state;
        _status = GameBoardStatus.playing;
        final winner = state.positions.where((p) => p.square >= 49).firstOrNull;
        if (winner != null) _status = GameBoardStatus.finished;
        notifyListeners();
      } catch (e) {
        debugPrint('[BOARD] failed to parse event: $e');
      }
      return;
    }

    // El no-admin pide sync → el admin re-emite el estado actual
    if (type == GameEventTypes.gameSync && isAdmin && _gameState != null) {
      debugPrint('[BOARD] sync request recibido — re-emitiendo estado');
      _gameEvents.emitEvent({
        'type': GameBoardEventTypes.gameStart,
        ..._gameState!.toJson(),
      }).catchError((e) {
        debugPrint('[BOARD] re-emit error: $e');
        return null;
      });
    }
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    unawaited(_leaveGame.execute());
    super.dispose();
  }
}