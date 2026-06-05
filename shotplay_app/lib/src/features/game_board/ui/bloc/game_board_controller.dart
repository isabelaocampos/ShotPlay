import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shotplay_app/src/features/game_board/domain/entities/board_entities.dart';
import 'package:shotplay_app/src/features/game_board/domain/entities/challenge_card.dart';
import 'package:shotplay_app/src/features/game_board/domain/entities/trap_state.dart';
import 'package:shotplay_app/src/features/game_board/domain/game_board_event_types.dart';
import 'package:shotplay_app/src/features/game_board/domain/usecases/emit_dice_roll_event_usecase.dart';
import 'package:shotplay_app/src/features/game_board/domain/usecases/roll_dice_usecase.dart';
import 'package:shotplay_app/src/features/game_board/domain/usecases/start_game_usecase.dart';
import 'package:shotplay_app/src/features/game_board/domain/usecases/watch_game_board_events_usecase.dart';
import 'package:shotplay_app/src/features/session/domain/usecases/save_game_state_usecase.dart';
import 'package:shotplay_app/src/features/waiting_room/domain/usecases/fetch_room_players_usecase.dart';

import '../../../../core/constants/game_event_types.dart';
import '../../../../domain/entities/room_lifecycle_status.dart';
import '../../../../domain/entities/room_player.dart';
import '../../../../domain/repositories/game_event_repository.dart';
import 'package:shotplay_app/src/features/session/domain/usecases/update_room_status_usecase.dart';

enum GameBoardStatus { waiting, playing, finished }

class GameBoardController extends ChangeNotifier {
  GameBoardController({
    required GameEventRepository gameEvents,
    required this.currentUserId,
    required this.isAdmin,
    required List<RoomPlayer> players,
    required this.roomId,
    required this.roomCode,
    required SaveGameStateUsecase saveGameState,
    required UpdateRoomStatusUsecase updateRoomStatus,
    required FetchRoomPlayersUsecase fetchRoomPlayers,
  })  : _gameEvents = gameEvents,
        _startGame = StartGameUsecase(gameEvents),
        _rollDice = RollDiceUsecase(),
        _emitEvent = EmitDiceRollEventUsecase(gameEvents),
        _watchEvents = WatchGameBoardEventsUsecase(gameEvents),
        _saveGameState = saveGameState,
        _updateRoomStatus = updateRoomStatus,
        _fetchRoomPlayers = fetchRoomPlayers,
        _players = players;

  bool _sessionStarted = false;

  final GameEventRepository _gameEvents;
  final StartGameUsecase _startGame;
  final RollDiceUsecase _rollDice;
  final EmitDiceRollEventUsecase _emitEvent;
  final WatchGameBoardEventsUsecase _watchEvents;
  final SaveGameStateUsecase _saveGameState;
  final UpdateRoomStatusUsecase _updateRoomStatus;
  final FetchRoomPlayersUsecase _fetchRoomPlayers;
  final List<RoomPlayer> _players;

  final int roomId;
  final String roomCode;

  StreamSubscription<Map<String, dynamic>>? _eventsSubscription;
  Set<String> _disconnectedPlayerIds = <String>{};

  final String currentUserId;
  final bool isAdmin;

  GameBoardStatus _status = GameBoardStatus.waiting;
  GameState? _gameState;
  bool _isRolling = false;
  int? _animatingDiceValue;

  // Pending penalty challenge waiting for the current player's response.
  PenaltyChallenge? _pendingChallenge;
  int _pendingDiceValue = 0;

  // Pending special party cell waiting for the current player's response.
  SpecialCell? _pendingSpecialCell;
  ChallengeCard? _pendingChallengeCard;
  TrapState? _pendingTrapState;
  bool _pendingTrapTriggered = false;

  // True when the challenge path pre-animated locally; tells
  // _animateStateTransition to skip the dice+step animation (already seen).
  bool _localAnimDone = false;

  GameBoardStatus get status => _status;
  GameState? get gameState => _gameState;
  bool get isRolling => _isRolling;
  int? get animatingDiceValue => _animatingDiceValue;
  PenaltyChallenge? get pendingChallenge => _pendingChallenge;
  SpecialCell? get pendingSpecialCell => _pendingSpecialCell;
  ChallengeCard? get pendingChallengeCard => _pendingChallengeCard;
  TrapState? get pendingTrapState => _pendingTrapState;
  bool get pendingTrapTriggered => _pendingTrapTriggered;

  bool get isMyTurn =>
      _gameState != null &&
      _gameState!.currentTurnPlayerId == currentUserId &&
      !_disconnectedPlayerIds.contains(currentUserId) &&
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

    String? get lastPunisherUsername => _gameState == null
      ? null
      : _gameState!.positions
        .where((player) => player.playerId == _gameState!.lastPunisherPlayerId)
        .firstOrNull
        ?.username;

  String get currentTurnUsername {
    if (_gameState == null) return '';
    final pos = _gameState!.positions
        .where((p) => p.playerId == _gameState!.currentTurnPlayerId)
        .firstOrNull;
    return pos?.username ?? '';
  }

  // ── Public actions ──────────────────────────────────────────────

  /// Attaches realtime listeners only after [GameEventRepository.connect].
  Future<void> startSession({
    bool isReconnect = false,
    Map<String, dynamic>? persistedGameState,
  }) async {
    if (_sessionStarted) {
      debugPrint('[PUBSUB] Game session already started — skipping');
      return;
    }

    if (!_gameEvents.isConnected) {
      debugPrint(
        '[PUBSUB] Cannot start session — repository not connected '
        '(room=$roomCode)',
      );
      throw GameEventNotConnectedException();
    }

    _sessionStarted = true;
    debugPrint(
      '[PUBSUB] Attaching listeners on channel '
      '${_gameEvents.connectedRoomCode}',
    );

    await _eventsSubscription?.cancel();
    _eventsSubscription = _watchEvents.execute().listen(
      _onEvent,
      onError: (Object error) {
        debugPrint('[PUBSUB] Game listener error: $error');
      },
    );

    await _refreshDisconnectedPlayers();

    if (isReconnect) {
      debugPrint('[GAME_STATE] Restoring persisted state');
      restoreFromPersisted(persistedGameState);
      await requestSync();
      debugPrint('[GAME_STATE] Sync requested — awaiting server state');
      return;
    }

    if (isAdmin) {
      await startGame();
    } else {
      await requestSync();
    }
  }

  Future<void> startGame() async {
    if (!isAdmin) return;
    try {
      final state = await _startGame.execute(_players);
      _gameState = state;
      _status = GameBoardStatus.playing;
      await _updateRoomStatus.execute(roomId, RoomLifecycleStatus.inProgress);
      await _persistState(state);
      notifyListeners();
      debugPrint('[GAME_STATE] Game started and persisted');
    } catch (e) {
      debugPrint('[BOARD] startGame error: $e');
    }
  }

  void restoreFromPersisted(Map<String, dynamic>? snapshot) {
    if (snapshot == null || snapshot.isEmpty) return;
    try {
      final state = GameState.fromJson(snapshot);
      _gameState = state;
      _status = GameBoardStatus.playing;
      if (state.positions.any((p) => p.square >= 49)) {
        _status = GameBoardStatus.finished;
      }
      notifyListeners();
      debugPrint('[GAME_STATE] Restored persisted game state');
    } catch (e) {
      debugPrint('[RECONNECT] Failed to restore persisted state: $e');
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

    if (_gameState?.silentPlayerId == currentUserId) {
      _gameState = _gameState!.copyWith(silentPlayerId: '');
      notifyListeners();
    }

    _isRolling = true;
    notifyListeners();

    try {
      final diceValue = _rollDice.execute();
      final rawSquare = _gameState!.rawSquareForCurrentPlayer(diceValue);
      final challenge = PenaltyChallenge.forSquare(rawSquare);
      final specialCell = BoardDefinition.specialCellFor(rawSquare);
      final trap = _gameState!.trapAt(rawSquare);

      if (challenge != null) {
        // Show dice + token animation before presenting the challenge dialog.
        await _animateLocalMove(diceValue, rawSquare);
        _localAnimDone = true;
        _pendingDiceValue = diceValue;
        _pendingChallenge = challenge;
        _isRolling = false;
        notifyListeners();
      } else if (trap != null) {
        await _animateLocalMove(diceValue, rawSquare);
        _localAnimDone = true;
        _pendingDiceValue = diceValue;
        _pendingSpecialCell = SpecialCell(
          square: rawSquare,
          type: SpecialCellType.trapCell,
        );
        _pendingTrapState = trap;
        _pendingTrapTriggered = true;
        _isRolling = false;
        notifyListeners();
      } else if (specialCell != null) {
        await _animateLocalMove(diceValue, rawSquare);
        _localAnimDone = true;
        _pendingDiceValue = diceValue;
        _pendingSpecialCell = specialCell;
        _pendingChallengeCard = switch (specialCell.type) {
          SpecialCellType.neverHaveIEver => ChallengeCard.randomNeverHaveIEver(),
          SpecialCellType.mostLikelyTo => ChallengeCard.randomMostLikelyTo(),
          _ => null,
        };
        _pendingTrapTriggered = false;
        _pendingTrapState = null;
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
    final eventLog = _buildChallengeLog(challenge, accepted);
    final shouldCountShot = accepted &&
      (challenge.type == PenaltyChallengeType.takeShotToClimb ||
        challenge.type == PenaltyChallengeType.takeShootToStay);
    _pendingChallenge = null;
    _pendingDiceValue = 0;

    _isRolling = true;
    notifyListeners();

    try {
      final finalSquare =
          accepted ? challenge.acceptSquare : challenge.rejectSquare;
      await _applyAndEmit(
        diceValue,
        finalSquare,
        eventLog: eventLog,
        shotsDelta: shouldCountShot ? 1 : 0,
      );
    } catch (e) {
      debugPrint('[BOARD] respondToChallenge error: $e');
      _isRolling = false;
      notifyListeners();
    }
  }

  Future<void> respondToTakeShot() async {
    final specialCell = _pendingSpecialCell;
    if (specialCell == null || _gameState == null) return;
    final diceValue = _pendingDiceValue;
    _pendingSpecialCell = null;
    _pendingDiceValue = 0;
    _isRolling = true;
    notifyListeners();

    try {
      await _applyAndEmit(
        diceValue,
        specialCell.square,
        eventLog: _buildSpecialCellLog(
          specialCell,
          eventLabel: 'tomó 2 shots',
        ),
        shotsDelta: 2,
      );
    } catch (e) {
      debugPrint('[BOARD] respondToTakeShot error: $e');
      _isRolling = false;
      notifyListeners();
    }
  }

  Future<void> respondToWaterfall() async {
    final specialCell = _pendingSpecialCell;
    if (specialCell == null || _gameState == null) return;

    final diceValue = _pendingDiceValue;
    final moverId = _gameState!.currentTurnPlayerId;
    _pendingSpecialCell = null;
    _pendingDiceValue = 0;
    _pendingChallengeCard = null;
    _isRolling = true;
    notifyListeners();

    try {
      await _applyAndEmit(
        diceValue,
        specialCell.square,
        eventLog: _buildSpecialCellLog(specialCell),
        shotsDelta: 1,
        mutateState: (state) => state.copyWith(lastPunisherPlayerId: moverId),
      );
    } catch (e) {
      debugPrint('[BOARD] respondToWaterfall error: $e');
      _isRolling = false;
      notifyListeners();
    }
  }

  Future<void> respondToSplitShots(Map<String, int> distribution) async {
    final specialCell = _pendingSpecialCell;
    if (specialCell == null || _gameState == null) return;

    final diceValue = _pendingDiceValue;
    final moverId = _gameState!.currentTurnPlayerId;
    _pendingSpecialCell = null;
    _pendingDiceValue = 0;
    _pendingChallengeCard = null;
    _isRolling = true;
    notifyListeners();

    final recipients = _gameState!.positions
        .where((player) => distribution.containsKey(player.playerId))
        .map((player) => '${player.username}=${distribution[player.playerId]}')
        .join(', ');

    try {
      await _applyAndEmit(
        diceValue,
        specialCell.square,
        eventLog: '${_gameState!.positions.firstWhere((p) => p.playerId == moverId).username} repartió 4 shots: $recipients',
        mutateState: (state) => state.copyWith(lastPunisherPlayerId: moverId),
      );
    } catch (e) {
      debugPrint('[BOARD] respondToSplitShots error: $e');
      _isRolling = false;
      notifyListeners();
    }
  }

  Future<void> respondToGiveShots(String targetPlayerId) async {
    final specialCell = _pendingSpecialCell;
    if (specialCell == null || _gameState == null) return;

    final targetUsername = _gameState!.positions
            .where((p) => p.playerId == targetPlayerId)
            .firstOrNull
            ?.username ??
        'another player';
    final moverId = _gameState!.currentTurnPlayerId;

    await _resolveSpecialCell(
      specialCell,
      _buildSpecialCellLog(
        specialCell,
        eventLabel: 'dio 2 shots a $targetUsername',
      ),
      mutateState: (state) => state.copyWith(lastPunisherPlayerId: moverId),
    );
  }

  Future<void> respondToRevengeShot() async {
    final specialCell = _pendingSpecialCell;
    if (specialCell == null || _gameState == null) return;

    final diceValue = _pendingDiceValue;
    final moverId = _gameState!.currentTurnPlayerId;
    final punisher = _gameState!.positions
        .where((p) => p.playerId == _gameState!.lastPunisherPlayerId)
        .firstOrNull;

    _pendingSpecialCell = null;
    _pendingDiceValue = 0;
    _pendingChallengeCard = null;
    _isRolling = true;
    notifyListeners();

    try {
      await _applyAndEmit(
        diceValue,
        specialCell.square,
        eventLog:
            '${_gameState!.positions.firstWhere((p) => p.playerId == moverId).username} activó REVENGE SHOT${punisher != null ? ' con ${punisher.username}' : ''}',
        shotsDelta: 1,
        mutateState: (state) => state.copyWith(lastPunisherPlayerId: moverId),
      );
    } catch (e) {
      debugPrint('[BOARD] respondToRevengeShot error: $e');
      _isRolling = false;
      notifyListeners();
    }
  }

  Future<void> respondToNeverHaveIEver({required bool haveDoneIt}) async {
    final specialCell = _pendingSpecialCell;
    if (specialCell == null || _gameState == null) return;

    final diceValue = _pendingDiceValue;
    final moverId = _gameState!.currentTurnPlayerId;
    final card = _pendingChallengeCard;
    _pendingSpecialCell = null;
    _pendingDiceValue = 0;
    _pendingChallengeCard = null;
    _isRolling = true;
    notifyListeners();

    try {
      await _applyAndEmit(
        diceValue,
        specialCell.square,
        eventLog:
            '${_gameState!.positions.firstWhere((p) => p.playerId == moverId).username} lanzó NEVER HAVE I EVER${card != null ? ': ${card.prompt}' : ''}',
        shotsDelta: haveDoneIt ? 1 : 0,
        mutateState: (state) => state.copyWith(lastPunisherPlayerId: moverId),
      );
    } catch (e) {
      debugPrint('[BOARD] respondToNeverHaveIEver error: $e');
      _isRolling = false;
      notifyListeners();
    }
  }

  Future<void> respondToMostLikelyTo(String targetPlayerId) async {
    final specialCell = _pendingSpecialCell;
    if (specialCell == null || _gameState == null) return;

    final diceValue = _pendingDiceValue;
    final moverId = _gameState!.currentTurnPlayerId;
    final targetUsername = _gameState!.positions
            .where((p) => p.playerId == targetPlayerId)
            .firstOrNull
            ?.username ??
        'another player';
    final card = _pendingChallengeCard;
    _pendingSpecialCell = null;
    _pendingDiceValue = 0;
    _pendingChallengeCard = null;
    _isRolling = true;
    notifyListeners();

    try {
      await _applyAndEmit(
        diceValue,
        specialCell.square,
        eventLog:
            '${_gameState!.positions.firstWhere((p) => p.playerId == moverId).username} eligió a $targetUsername en MOST LIKELY TO${card != null ? ': ${card.prompt}' : ''}',
        mutateState: (state) => state.copyWith(lastPunisherPlayerId: moverId),
      );
    } catch (e) {
      debugPrint('[BOARD] respondToMostLikelyTo error: $e');
      _isRolling = false;
      notifyListeners();
    }
  }

  Future<void> respondToTrapCell() async {
    final specialCell = _pendingSpecialCell;
    if (specialCell == null || _gameState == null) return;

    final diceValue = _pendingDiceValue;
    final moverId = _gameState!.currentTurnPlayerId;
    final moverName = _gameState!.positions
        .firstWhere((p) => p.playerId == moverId)
        .username;
    final trapState = _pendingTrapState;
    final triggered = _pendingTrapTriggered;
    _pendingSpecialCell = null;
    _pendingDiceValue = 0;
    _pendingTrapState = null;
    _pendingTrapTriggered = false;
    _pendingChallengeCard = null;
    _isRolling = true;
    notifyListeners();

    try {
      await _applyAndEmit(
        diceValue,
        specialCell.square,
        eventLog: triggered
            ? '$moverName activó un TRAP y bebió 3 shots'
            : '$moverName dejó un TRAP en la casilla ${specialCell.square}',
        shotsDelta: triggered ? 3 : 0,
        mutateState: (state) {
          if (triggered && trapState != null) {
            return state.removeTrapAt(trapState.square).copyWith(
              lastPunisherPlayerId: trapState.ownerPlayerId,
            );
          }

          return state.addTrap(
            TrapState(
              square: specialCell.square,
              ownerPlayerId: moverId,
              ownerUsername: moverName,
            ),
          ).copyWith(lastPunisherPlayerId: moverId);
        },
      );
    } catch (e) {
      debugPrint('[BOARD] respondToTrapCell error: $e');
      _isRolling = false;
      notifyListeners();
    }
  }

  Future<void> respondToSilentRound() async {
    final specialCell = _pendingSpecialCell;
    if (specialCell == null || _gameState == null) return;

    final diceValue = _pendingDiceValue;
    final moverId = _gameState!.currentTurnPlayerId;
    final moverName = _gameState!.positions
        .firstWhere((p) => p.playerId == moverId)
        .username;
    _pendingSpecialCell = null;
    _pendingDiceValue = 0;
    _pendingChallengeCard = null;
    _isRolling = true;
    notifyListeners();

    try {
      await _applyAndEmit(
        diceValue,
        specialCell.square,
        eventLog: '$moverName inició una SILENT ROUND',
        mutateState: (state) => state.copyWith(
          silentPlayerId: moverId,
          lastPunisherPlayerId: moverId,
        ),
      );
    } catch (e) {
      debugPrint('[BOARD] respondToSilentRound error: $e');
      _isRolling = false;
      notifyListeners();
    }
  }

  Future<void> respondToTruthOrDare(bool choseTruth) async {
    final specialCell = _pendingSpecialCell;
    if (specialCell == null || _gameState == null) return;

    await _resolveSpecialCell(
      specialCell,
      _buildSpecialCellLog(
        specialCell,
        eventLabel: choseTruth ? 'eligió Verdad' : 'eligió Reto',
      ),
    );
  }

  // ── Private helpers ─────────────────────────────────────────────

  /// Plays the dice dialog and step-by-step token movement locally for the
  /// rolling player BEFORE showing the penalty challenge dialog.
  /// Does NOT emit anything to Supabase.
  Future<void> _animateLocalMove(int diceValue, int rawSquare) async {
    _animatingDiceValue = diceValue;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _animatingDiceValue = null;
    notifyListeners();

    final startSquare = _gameState!.positions
        .firstWhere((p) => p.playerId == currentUserId)
        .square;

    for (int step = 1; step <= diceValue; step++) {
      final s = startSquare + step;
      if (s > 49) break;
      final temp = List<PlayerPosition>.from(_gameState!.positions);
      final idx = temp.indexWhere((p) => p.playerId == currentUserId);
      temp[idx] = temp[idx].copyWith(square: s);
      _gameState = _gameState!.copyWith(positions: temp);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  String _buildChallengeLog(PenaltyChallenge challenge, bool accepted) {
    final rollerName = _gameState!.positions
        .firstWhere((p) => p.playerId == _gameState!.currentTurnPlayerId)
        .username;

    if (challenge.type == PenaltyChallengeType.takeShotToClimb) {
      return accepted
          ? '$rollerName tomó un shot y subió la escalera a la casilla ${challenge.acceptSquare} 🪜'
          : '$rollerName rechazó el shot y se quedó en la casilla ${challenge.rejectSquare}';
    } else {
      return accepted
          ? '$rollerName tomó un shot y se quedó en la casilla ${challenge.acceptSquare}'
          : '$rollerName rechazó el shot y bajó por la serpiente a la casilla ${challenge.rejectSquare} 🐍';
    }
  }

  String _buildSpecialCellLog(
    SpecialCell cell, {
    String eventLabel = '',
  }) {
    final rollerName = _gameState!.positions
        .firstWhere((p) => p.playerId == _gameState!.currentTurnPlayerId)
        .username;

    return switch (cell.type) {
      SpecialCellType.takeShot => '$rollerName tomó 2 shots en la casilla ${cell.square}',
      SpecialCellType.giveShot => '$rollerName activó GIVE SHOT en la casilla ${cell.square}',
      SpecialCellType.truthOrDare => '$rollerName activó Truth or Dare en la casilla ${cell.square}',
      SpecialCellType.waterfall => '$rollerName activó WATERFALL',
      SpecialCellType.splitShots => '$rollerName activó SPLIT THE SHOTS',
      SpecialCellType.giveShots => '$rollerName activó GIVE 2 SHOTS',
      SpecialCellType.revengeShot => '$rollerName activó REVENGE SHOT',
      SpecialCellType.neverHaveIEver => '$rollerName activó NEVER HAVE I EVER',
      SpecialCellType.mostLikelyTo => '$rollerName activó MOST LIKELY TO',
      SpecialCellType.trapCell => '$rollerName activó TRAP CELL',
      SpecialCellType.silentRound => '$rollerName activó SILENT ROUND',
    };
  }

  Future<void> _resolveSpecialCell(
    SpecialCell cell,
    String eventLog, {
    GameState Function(GameState state)? mutateState,
  }) async {
    final diceValue = _pendingDiceValue;
    _pendingSpecialCell = null;
    _pendingDiceValue = 0;
    _localAnimDone = true;
    _isRolling = true;
    notifyListeners();

    try {
      await _applyAndEmit(
        diceValue,
        cell.square,
        eventLog: eventLog,
        mutateState: mutateState,
      );
    } catch (e) {
      debugPrint('[BOARD] resolveSpecialCell error: $e');
      _isRolling = false;
      notifyListeners();
    }
  }

  Future<void> _applyAndEmit(
    int diceValue,
    int finalSquare, {
    String eventLog = '',
    int shotsDelta = 0,
    GameState Function(GameState state)? mutateState,
  }) async {
    final shotsCount = shotsDelta > 0
        ? _gameState!.shotsTakenByCurrentPlayer + shotsDelta
        : _gameState!.shotsTakenByCurrentPlayer;
    await _refreshDisconnectedPlayers();
    var newState = _gameState!.applyFinalMove(
      finalSquare,
      diceValue,
      shotsTakenByCurrentPlayer: shotsCount,
      skipPlayerIds: _disconnectedPlayerIds,
    );
    if (mutateState != null) {
      newState = mutateState(newState);
    }
    if (eventLog.isNotEmpty) {
      newState = newState.copyWith(lastEventLog: eventLog);
    }
    await _emitEvent.execute(newState);
    await _persistState(newState);

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

  Future<void> _refreshDisconnectedPlayers() async {
    try {
      final players = await _fetchRoomPlayers.execute(roomCode);
      _disconnectedPlayerIds = players
          .where((player) => !player.isConnected)
          .map((player) => player.userId)
          .toSet();
      debugPrint(
        '[RECONNECT] Disconnected players: ${_disconnectedPlayerIds.length}',
      );

      if (isAdmin &&
          _gameState != null &&
          _disconnectedPlayerIds.contains(_gameState!.currentTurnPlayerId)) {
        debugPrint('[RECONNECT] Skipping turn for disconnected player');
        final current = _gameState!.positions.firstWhere(
          (p) => p.playerId == _gameState!.currentTurnPlayerId,
        );
        final skipped = _gameState!.applyFinalMove(
          current.square,
          0,
          skipPlayerIds: _disconnectedPlayerIds,
        );
        _gameState = skipped;
        await _emitEvent.execute(skipped);
        await _persistState(skipped);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[RECONNECT] Failed to refresh disconnected players: $e');
    }
  }

  Future<void> _persistState(GameState state) async {
    final payload = <String, dynamic>{
      'appEventType': GameBoardEventTypes.gameStart,
      ...state.toJson(),
    };
    await _saveGameState.execute(roomId, payload);
  }

  void _onEvent(Map<String, dynamic> event) {
    final type = event['appEventType'] as String?;

    if (type == GameEventTypes.playerDisconnected ||
        type == GameEventTypes.playerReconnected ||
        type == GameEventTypes.lobbySync) {
      unawaited(_refreshDisconnectedPlayers());
      return;
    }

    if (type == GameBoardEventTypes.gameStart) {
      try {
        final state = GameState.fromJson(event);
        _gameState = state;
        _status = GameBoardStatus.playing;
        if (state.positions.any((p) => p.square >= 49)) {
          _status = GameBoardStatus.finished;
        }
        _isRolling = false;
        unawaited(_persistState(state));
        notifyListeners();
        debugPrint('[GAME_STATE] Synced from server');
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

    if (_pendingSpecialCell != null && type == GameBoardEventTypes.diceRoll) {
      // Special cell resolution is local, so remote broadcasts already carry the final state.
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

    if (_localAnimDone) {
      // Rolling player already saw dice dialog + step-by-step locally.
      // Only pause for the snake/ladder jump if the position changed.
      _localAnimDone = false;
      if (prevMover != null &&
          nextMover != null &&
          prevMover.square != nextMover.square) {
        await Future.delayed(const Duration(milliseconds: 600));
      }
    } else {
      // Normal path: show dice dialog then step-by-step animation.
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

        // Snake/ladder jump — pause so the player sees the intermediate pos.
        if (logicTarget != nextMover.square) {
          await Future.delayed(const Duration(milliseconds: 600));
        }
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
    _pendingSpecialCell = null;
    super.dispose();
  }
}
