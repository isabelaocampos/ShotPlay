import 'package:shotplay_app/src/domain/repositories/game_event_repository.dart';
import 'package:shotplay_app/src/features/waiting_room/domain/lobby_event_types.dart';

class EmitLobbySyncUsecase {
  const EmitLobbySyncUsecase(this._repository);

  final GameEventRepository _repository;

  Future<void> execute() => _repository.emitEvent(<String, dynamic>{
        'appEventType': LobbyEventTypes.sync,
        'payload': <String, dynamic>{},
      });
}
