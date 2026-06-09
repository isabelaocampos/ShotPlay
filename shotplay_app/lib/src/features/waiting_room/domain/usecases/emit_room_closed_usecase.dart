import '../../../../domain/repositories/game_event_repository.dart';
import '../lobby_event_types.dart';

class EmitRoomClosedUsecase {
  const EmitRoomClosedUsecase(this._repository);

  final GameEventRepository _repository;

  Future<void> execute() => _repository.emitEvent(<String, dynamic>{
        'appEventType': LobbyEventTypes.closed,
      });
}
