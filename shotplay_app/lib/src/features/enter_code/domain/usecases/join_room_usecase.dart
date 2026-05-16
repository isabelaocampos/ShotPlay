import 'package:shotplay_app/src/domain/entities/room_session.dart';
import 'package:shotplay_app/src/domain/repositories/room_repository.dart';

class JoinRoomUsecase {
  const JoinRoomUsecase(this._repository);

  final RoomRepository _repository;

  Future<RoomSession> execute({
    required String roomCode,
    int? expectedGameId,
  }) {
    return _repository.joinRoom(
      roomCode: roomCode,
      expectedGameId: expectedGameId,
    );
  }
}
