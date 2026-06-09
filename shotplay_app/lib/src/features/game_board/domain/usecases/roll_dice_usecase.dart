import 'dart:math';

import '../entities/dice_result.dart';

/// Generates and validates a single dice roll value (1–6).
/// Movement calculation and event emission are handled by the caller.
class RollDiceUsecase {
  RollDiceUsecase() : _random = Random();

  /// Pass a seeded [Random] for deterministic tests.
  RollDiceUsecase.withRandom(this._random);

  final Random _random;

  int execute() {
    final value = _random.nextInt(6) + 1;
    final result = DiceResult(value);
    if (!result.isValid) throw StateError('Invalid dice roll value generated.');
    return value;
  }
}
