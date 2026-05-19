import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shotplay_app/src/features/game_board/domain/entities/board_entities.dart';
import 'package:shotplay_app/src/features/game_board/domain/game_board_event_types.dart';
import 'package:shotplay_app/src/features/game_board/domain/usecases/emit_dice_roll_event_usecase.dart';
import 'package:shotplay_app/src/features/game_board/domain/usecases/roll_dice_usecase.dart';
import 'package:shotplay_app/src/features/game_board/domain/usecases/start_game_usecase.dart';
import 'package:shotplay_app/src/features/game_board/domain/usecases/watch_game_board_events_usecase.dart';

import '../../../../core/constants/game_event_types.dart';
import '../../../../domain/entities/room_player.dart';
import '../../../../domain/repositories/game_event_repository.dart';

enum GameBoardStatus { waiting, playing, finished }

class GameBoardController extends ChangeNotifier {
  GameBoardController({
    required GameEventRepository gameEvents,
    required this.currentUserId,
    required this.isAdmin,
    required List<RoomPlayer> players,
  }) : _gameEvents = gameEvents,
       _startGame = StartGameUsecase(gameEvents),
       _rollDice = RollDiceUsecase(EmitDiceRollEventUsecase(gameEvents)),
       _watchEvents = WatchGameBoardEventsUsecase(gameEvents),
       _players = players {
    _eventsSubscription = _watchEvents.execute().listen(_onEvent);
  }

  final GameEventRepository _gameEvents;
  final StartGameUsecase _startGame;
  final RollDiceUsecase _rollDice;
  final WatchGameBoardEventsUsecase _watchEvents;
  final List<RoomPlayer> _players;

  StreamSubscription<Map<String, dynamic>>? _eventsSubscription;

  final String currentUserId;
  final bool isAdmin;

  GameBoardStatus _status = GameBoardStatus.waiting;
  GameState? _gameState;
  bool _isRolling = false;
  int? _animatingDiceValue;

  GameBoardStatus get status => _status;
  GameState? get gameState => _gameState;
  bool get isRolling => _isRolling;
  int? get animatingDiceValue => _animatingDiceValue;

  bool get isMyTurn =>
      _gameState != null &&
      _gameState!.currentTurnPlayerId == currentUserId &&
      _status == GameBoardStatus.playing &&
      !_isRolling;

  PlayerPosition? get myPosition =>
      _gameState?.positions
          .where((p) => p.playerId == currentUserId)
          .firstOrNull;

  PlayerPosition? get winnerPosition =>
      _gameState?.positions.where((p) => p.square >= 49).firstOrNull;

  String? get winnerUsername => winnerPosition?.username;

  String get currentTurnUsername {
    if (_gameState == null) return '';
    final pos =
        _gameState!.positions
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
      await _gameEvents.emitEvent({'appEventType': GameEventTypes.gameSync});
      debugPrint('[BOARD] sync request enviado');
    } catch (e) {
      debugPrint('[BOARD] requestSync error: $e');
    }
  }

  Future<void> rollDice() async {
    if (!isMyTurn || _isRolling) return;
    _isRolling = true;
    notifyListeners();

    try {
      await _rollDice.execute(_gameState!);
    } catch (e) {

  // ── Event listener ───────────────────────────────────────────────
      debugPrint('[BOARD] rollDice error: $e');
      _isRolling = false;
      notifyListeners();
    }
  }

  // ── Event listener ───────────────────────────────────────────────

  void _onEvent(Map<String, dynamic> event) {
    final type = event['appEventType'] as String?;

    if (type == GameBoardEventTypes.gameStart) {
      try {
        final state = GameState.fromJson(event);
        _gameState = state;
        _status = GameBoardStatus.playing;
        final winner = state.positions.where((p) => p.square >= 49).firstOrNull;
        if (winner != null) _status = GameBoardStatus.finished;
        _isRolling = false;
        notifyListeners();
      } catch (e) {
        debugPrint('[BOARD] failed to parse event: $e');
      }
      return;
    }

    if (type == GameBoardEventTypes.diceRoll) {
      try {
        final state = GameState.fromJson(event);
        if (_gameState != null) {
          _animateStateTransition(state);
        } else {
          _gameState = state;
          _status = GameBoardStatus.playing;
          final winner =
              state.positions.where((p) => p.square >= 49).firstOrNull;
          if (winner != null) _status = GameBoardStatus.finished;
          _isRolling = false;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('[BOARD] failed to parse event: $e');
      }
      return;
    }

    if (type == GameEventTypes.gameSync && isAdmin && _gameState != null) {
      debugPrint('[BOARD] sync request recibido -> re-emitiendo estado');
      _gameEvents
          .emitEvent({
            'appEventType': GameBoardEventTypes.gameStart,
            ..._gameState!.toJson(),
          })
          .catchError((e) {
            debugPrint('[BOARD] re-emit error: $e');
            return null;
          });
    }
  }

  Future<void> _animateStateTransition(GameState targetState) async {
    _isRolling = true;
    notifyListeners();

    final prevPositions = _gameState!.positions;
    final nextPositions = targetState.positions;

    PlayerPosition? prevMover;
    PlayerPosition? nextMover;

    for (int i = 0; i < prevPositions.length; i++) {
      if (prevPositions[i].square != nextPositions[i].square) {
        prevMover = prevPositions[i];
        nextMover = nextPositions[i];
        break;
      }
    }

    final diceValue = targetState.lastDiceValue;

    _animatingDiceValue = diceValue;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _animatingDiceValue = null;
    notifyListeners();

    if (prevMover != null &&
        nextMover != null &&
        diceValue > 0 &&
        prevMover.playerId == nextMover.playerId &&
        prevMover.square != nextMover.square) {
      int steps = diceValue;
      int logicTarget = prevMover.square + steps;
      if (logicTarget > 49) logicTarget = 49;

      for (int step = 1; step <= steps; step++) {
        int s = prevMover.square + step;
        if (s > 49) break;

        final tempPositions = List<PlayerPosition>.from(_gameState!.positions);
        final idx = tempPositions.indexWhere(
          (p) => p.playerId == prevMover!.playerId,
        );
        tempPositions[idx] = tempPositions[idx].copyWith(square: s);

        _gameState = _gameState!.copyWith(positions: tempPositions);
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 300));
      }

      if (logicTarget != nextMover.square) {
        await Future.delayed(const Duration(milliseconds: 600));
      }
    }

    _gameState = targetState;
    _status = GameBoardStatus.playing;
    final winner =
        targetState.positions.where((p) => p.square >= 49).firstOrNull;
    if (winner != null) _status = GameBoardStatus.finished;

    _isRolling = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }
}
