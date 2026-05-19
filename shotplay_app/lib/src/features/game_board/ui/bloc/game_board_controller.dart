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
       _rollDice = RollDiceUsecase(),
       _emitEvent = EmitDiceRollEventUsecase(gameEvents),
       _watchEvents = WatchGameBoardEventsUsecase(gameEvents),
       _players = players {
    _eventsSubscription = _watchEvents.execute().listen(_onEvent);
  }

  final GameEventRepository _gameEvents;
  final StartGameUsecase _startGame;
  final RollDiceUsecase _rollDice;
  final EmitDiceRollEventUsecase _emitEvent;
  final WatchGameBoardEventsUsecase _watchEvents;
  final List<RoomPlayer> _players;

  StreamSubscription<Map<String, dynamic>>? _eventsSubscription;

  final String currentUserId;
  final bool isAdmin;

  GameBoardStatus _status = GameBoardStatus.waiting;
  GameState? _gameState;
  bool _isRolling = false;
  int? _animatingDiceValue;

  // Pending penalty challenge waiting for the current player's response.
  PenaltyChallenge? _pendingChallenge;
  int _pendingDiceValue = 0;

  GameBoardStatus get status => _status;
  GameState? get gameState => _gameState;
  bool get isRolling => _isRolling;
  int? get animatingDiceValue => _animatingDiceValue;
  PenaltyChallenge? get pendingChallenge => _pendingChallenge;

  bool get isMyTurn =>
      _gameState != null &&
      _gameState!.currentTurnPlayerId == currentUserId &&
      _status == GameBoardStatus.playing &&
      !_isRolling &&
      _pendingChallenge == null;

  PlayerPosition? get myPosition =>
      _gameState?.positions
          .where((p) => p.playerId == currentUserId)
          .firstOrNull;

  PlayerPosition? get winnerPosition =>
      _gameState?.positions.where((p) => p.square >= 49).firstOrNull;

  String? get winnerUsername => winnerPosition?.username;

  String get currentTurnUsername {
    if (_gameState == null) return '';
    final pos = _gameState!.positions
        .where((p) => p.playerId == _gameState!.currentTurnPlayerId)
        .firstOrNull;
    return pos?.username ?? '';
  }

  // ── Public actions ──────────────────────────────────────────────

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

  Future<void> requestSync() async {
    if (isAdmin) return;
    try {
      await _gameEvents.emitEvent({'appEventType': GameEventTypes.gameSync});
      debugPrint('[BOARD] sync request enviado');
    } catch (e) {
      debugPrint('[BOARD] requestSync error: $e');
    }
  }

  /// Rolls the dice. If the result lands on a snake head or ladder base,
  /// sets [pendingChallenge] so the UI can present the shot pop-up.
  /// Otherwise, applies the move directly and broadcasts the new state.
  Future<void> rollDice() async {
    if (!isMyTurn || _isRolling) return;
    _isRolling = true;
    notifyListeners();

    try {
      final diceValue = _rollDice.execute();
      final rawSquare = _gameState!.rawSquareForCurrentPlayer(diceValue);
      final challenge = PenaltyChallenge.forSquare(rawSquare);

      if (challenge != null) {
        // Pause and wait for the player's shot decision.
        _pendingDiceValue = diceValue;
        _pendingChallenge = challenge;
        _isRolling = false;
        notifyListeners();
      } else {
        await _applyAndEmit(diceValue, rawSquare);
      }
    } catch (e) {
      debugPrint('[BOARD] rollDice error: $e');
      _isRolling = false;
      notifyListeners();
    }
  }

  /// Called by the UI after the player responds to a [pendingChallenge].
  /// [accepted] = true → takes the shot; false → declines.
  Future<void> respondToChallenge(bool accepted) async {
    if (_pendingChallenge == null || _gameState == null) return;

    final challenge = _pendingChallenge!;
    final diceValue = _pendingDiceValue;
    _pendingChallenge = null;
    _pendingDiceValue = 0;

    _isRolling = true;
    notifyListeners();

    try {
      final finalSquare =
          accepted ? challenge.acceptSquare : challenge.rejectSquare;
      await _applyAndEmit(diceValue, finalSquare);
    } catch (e) {
      debugPrint('[BOARD] respondToChallenge error: $e');
      _isRolling = false;
      notifyListeners();
    }
  }

  // ── Private helpers ─────────────────────────────────────────────

  Future<void> _applyAndEmit(int diceValue, int finalSquare) async {
    final newState = _gameState!.applyFinalMove(finalSquare, diceValue);
    await _emitEvent.execute(newState);

    // Emit a dedicated victory event so SHOT-NEW-4 can react to it.
    final winner = newState.positions.where((p) => p.square >= 49).firstOrNull;
    if (winner != null) {
      await _gameEvents
          .emitEvent({
            'appEventType': GameBoardEventTypes.gameVictory,
            'winnerId': winner.playerId,
            'winnerUsername': winner.username,
          })
          .catchError((e) {
            debugPrint('[BOARD] victory emit error: $e');
            return null;
          });
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
        if (state.positions.any((p) => p.square >= 49)) {
          _status = GameBoardStatus.finished;
        }
        _isRolling = false;
        notifyListeners();
      } catch (e) {
        debugPrint('[BOARD] failed to parse gameStart event: $e');
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
          if (state.positions.any((p) => p.square >= 49)) {
            _status = GameBoardStatus.finished;
          }
          _isRolling = false;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('[BOARD] failed to parse diceRoll event: $e');
      }
      return;
    }

    if (type == GameBoardEventTypes.gameVictory) {
      _status = GameBoardStatus.finished;
      notifyListeners();
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

      // Snake/ladder jump — pause briefly so the player sees the intermediate pos.
      if (logicTarget != nextMover.square) {
        await Future.delayed(const Duration(milliseconds: 600));
      }
    }

    _gameState = targetState;
    _status = GameBoardStatus.playing;
    if (targetState.positions.any((p) => p.square >= 49)) {
      _status = GameBoardStatus.finished;
    }

    _isRolling = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _pendingChallenge = null;
    super.dispose();
  }
}
