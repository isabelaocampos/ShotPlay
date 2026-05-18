import '../../../../domain/repositories/game_event_repository.dart';
import '../entities/board_entities.dart';
import '../game_board_event_types.dart';

/// Usecase responsible solely for emitting the new game state
/// after a dice roll. Follows Single Responsibility Principle.
class EmitDiceRollEventUsecase {
  EmitDiceRollEventUsecase(this._gameEvents);

  final GameEventRepository _gameEvents;

  Future<void> execute(GameState newState) async {
    await _gameEvents.emitEvent({
      'appEventType': GameBoardEventTypes.diceRoll,
      ...newState.toJson(),
    });
  }
}
