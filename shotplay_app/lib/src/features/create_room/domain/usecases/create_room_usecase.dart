import 'package:shotplay_app/src/domain/entities/room_session.dart';
import 'package:shotplay_app/src/domain/repositories/room_repository.dart';

class CreateRoomUsecase {
  final RoomRepository _repository;

  const CreateRoomUsecase(this._repository);

  Future<RoomSession> execute({
    required String roomCode,
    required int gameId,
    required int maxPlayers,
    required bool isPrivate,
    required String roomName,
  }) =>
      _repository.createRoom(
        roomCode: roomCode,
        gameId: gameId,
        maxPlayers: maxPlayers,
        isPrivate: isPrivate,
        roomName: roomName,
      );
}
