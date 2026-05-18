import 'dart:math';

import '../../../../domain/repositories/game_event_repository.dart';
import '../entities/board_entities.dart';
import '../game_board_event_types.dart';

class RollDiceUsecase {
  RollDiceUsecase(this._gameEvents);

  final GameEventRepository _gameEvents;
  final _random = Random();

  /// Rolls a 1-6 die, moves the current player, applies snakes/ladders,
  /// advances the turn, and broadcasts the new state.
  Future<GameState> execute(GameState current) async {
    final dice = _random.nextInt(6) + 1;
    final currentPlayerId = current.currentTurnPlayerId;

    final updatedPositions = current.positions.map((p) {
      if (p.playerId != currentPlayerId) return p;

      int newSquare = (p.square + dice).clamp(1, 49);

      // Apply snake
      if (BoardDefinition.snakes.containsKey(newSquare)) {
        newSquare = BoardDefinition.snakes[newSquare]!;
      }
      // Apply ladder
      else if (BoardDefinition.ladders.containsKey(newSquare)) {
        newSquare = BoardDefinition.ladders[newSquare]!;
      }

      return p.copyWith(square: newSquare);
    }).toList();

    // Advance turn to the next player
    final playerIds = current.positions.map((p) => p.playerId).toList();
    final currentIndex = playerIds.indexOf(currentPlayerId);
    final nextIndex = (currentIndex + 1) % playerIds.length;
    final nextPlayerId = playerIds[nextIndex];

    final newState = current.copyWith(
      positions: updatedPositions,
      currentTurnPlayerId: nextPlayerId,
      lastDiceValue: dice,
      shotsTakenByCurrentPlayer: 0,
    );

    await _gameEvents.emitEvent({
      'type': GameBoardEventTypes.diceRoll,
      ...newState.toJson(),
    });

    return newState;
  }
}
