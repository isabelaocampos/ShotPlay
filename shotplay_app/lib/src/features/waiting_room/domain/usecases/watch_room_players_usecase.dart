import 'package:shotplay_app/src/domain/entities/room_player.dart';
import 'package:shotplay_app/src/domain/repositories/room_repository.dart';

class WatchRoomPlayersUsecase {
  final RoomRepository _repository;

  const WatchRoomPlayersUsecase(this._repository);

  Stream<List<RoomPlayer>> execute(String roomCode) =>
      _repository.watchRoomPlayers(roomCode);
}
