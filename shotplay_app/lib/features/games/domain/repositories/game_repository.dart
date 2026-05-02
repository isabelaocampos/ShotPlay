import '../entities/game.dart';
import '../entities/game_room.dart';
import '../entities/room_player.dart';

abstract class GameRepository {
  Future<List<Game>> getAvailableGames();

  Future<GameRoom> createRoom({
    required String gameId,
    required String roomName,
    required int maxPlayers,
    required bool isPrivate,
    required bool hintsEnabled,
  });

  Future<bool> validatePlayerCount({
    required String gameId,
    required int playerCount,
  });

  Stream<List<RoomPlayer>> watchRoomPlayers(String roomId);
}
