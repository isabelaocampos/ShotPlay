import 'package:shotplay_app/src/domain/repositories/game_event_repository.dart';

class DisconnectRoomGameEventsUsecase {
  const DisconnectRoomGameEventsUsecase(this._repository);

  final GameEventRepository _repository;

  Future<void> execute() => _repository.disconnect();
}
