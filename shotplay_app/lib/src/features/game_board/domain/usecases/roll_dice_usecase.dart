import 'dart:math';

import '../entities/board_entities.dart';
import '../entities/dice_result.dart';
import 'emit_dice_roll_event_usecase.dart';

/// Usecase responsible for rolling the dice, calculating the new state
/// and calling the emission usecase.
class RollDiceUsecase {
  RollDiceUsecase(this._emitEventUsecase) : _random = Random();

  /// Pass an optional [Random] instance for testing.
  RollDiceUsecase.withRandom(this._emitEventUsecase, this._random);

  final EmitDiceRollEventUsecase _emitEventUsecase;
  final Random _random;

  /// Generates a random dice value, creates the new game state,
  /// and emits the broadcast event.
  Future<GameState> execute(GameState current) async {
    final diceValue = _random.nextInt(6) + 1;
    final diceResult = DiceResult(diceValue);

    if (!diceResult.isValid) {
      throw StateError('Invalid dice roll value generated.');
    }

    final newState = current.applyDiceRoll(diceResult.value);

    await _emitEventUsecase.execute(newState);

    return newState;
  }
}

