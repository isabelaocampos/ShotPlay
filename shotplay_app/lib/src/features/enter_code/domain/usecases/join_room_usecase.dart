import 'package:shotplay_app/src/domain/entities/room_entry_result.dart';
import 'package:shotplay_app/src/domain/repositories/room_repository.dart';

class JoinRoomUsecase {
  const JoinRoomUsecase(this._repository);

  final RoomRepository _repository;

  Future<RoomEntryResult> execute({
    required String roomCode,
    int? expectedGameId,
  }) {
    return _repository.enterRoom(
      roomCode: roomCode,
      expectedGameId: expectedGameId,
    );
  }
}
