import 'package:shotplay_app/src/domain/repositories/game_event_repository.dart';

class ConnectRoomGameEventsUsecase {
  const ConnectRoomGameEventsUsecase(this._repository);

  final GameEventRepository _repository;

  Future<void> execute(String roomCode) => _repository.connect(roomCode);
}
