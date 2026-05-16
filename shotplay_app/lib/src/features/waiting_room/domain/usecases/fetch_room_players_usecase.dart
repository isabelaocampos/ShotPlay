import 'package:shotplay_app/src/domain/entities/room_player.dart';
import 'package:shotplay_app/src/domain/repositories/room_repository.dart';

class FetchRoomPlayersUsecase {
  const FetchRoomPlayersUsecase(this._repository);

  final RoomRepository _repository;

  Future<List<RoomPlayer>> execute(String roomCode) =>
      _repository.fetchRoomPlayers(roomCode);
}
