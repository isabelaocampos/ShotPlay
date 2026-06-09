import '../../../../domain/entities/room_player.dart';
import '../../../../domain/repositories/game_event_repository.dart';
import '../entities/board_entities.dart';
import 'package:shotplay_app/src/features/impostor/domain/entities/impostor_entities.dart';
import '../game_board_event_types.dart';

class StartGameUsecase {
  const StartGameUsecase(this._gameEvents);

  final GameEventRepository _gameEvents;

  Future<GameState> execute(
    List<RoomPlayer> players, {
    QuestionPhaseState? questionPhase,
  }) async {
    final positions = players
        .asMap()
        .entries
        .map((e) => PlayerPosition(
              playerId: e.value.userId,
              username: e.value.username,
              square: 1,
              avatarIndex: e.key % 4,
            avatarUrl: e.value.avatarUrl,
            ))
        .toList();

    final state = GameState.initial(positions).copyWith(
      questionPhase: questionPhase,
    );

    await _gameEvents.emitEvent({
      'appEventType': GameBoardEventTypes.gameStart,
      ...state.toJson(),
    });

    return state;
  }
}
