import '../entities/room_player.dart';
import '../entities/room_session.dart';

abstract class RoomRepository {
  Future<RoomSession> createRoom({
    required String roomCode,
    required int gameId,
    required int maxPlayers,
    required bool isPrivate,
    required String roomName,
  });

  Stream<List<RoomPlayer>> watchRoomPlayers(String roomCode);
}

class RoomCodeCollisionException implements Exception {}

class NotAuthenticatedException implements Exception {
  @override
  String toString() => 'No hay un usuario autenticado.';
}

class RoomRepositoryException implements Exception {
  RoomRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
