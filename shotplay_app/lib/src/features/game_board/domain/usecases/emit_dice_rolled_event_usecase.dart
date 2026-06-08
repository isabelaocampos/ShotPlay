import 'package:flutter/foundation.dart';

import '../../../../domain/repositories/game_event_repository.dart';
import '../game_board_event_types.dart';

/// Broadcasts incremental dice-roll progress before the turn resolves.
class EmitDiceRolledEventUsecase {
  const EmitDiceRolledEventUsecase(this._gameEvents);

  final GameEventRepository _gameEvents;

  Future<void> execute({
    required String playerId,
    required int diceValue,
    required int fromSquare,
    required int rawSquare,
  }) async {
    debugPrint('[SYNC] Broadcasting dice roll (value=$diceValue)');
    await _gameEvents.emitEvent(<String, dynamic>{
      'appEventType': GameBoardEventTypes.diceRolled,
      'payload': <String, dynamic>{
        'playerId': playerId,
        'diceValue': diceValue,
        'fromSquare': fromSquare,
        'rawSquare': rawSquare,
      },
    });
  }
}
