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

  /// One-shot fetch of current participants (used for lobby refresh).
  Future<List<RoomPlayer>> fetchRoomPlayers(String roomCode);

  /// Looks up a room by code, adds the current user as a participant, and
  /// returns the session. [expectedGameId] optionally validates the room game.
  Future<RoomSession> joinRoom({
    required String roomCode,
    int? expectedGameId,
  });
}

class RoomCodeCollisionException implements Exception {}

class RoomNotFoundException implements Exception {
  @override
  String toString() => 'No existe una sala con ese código.';
}

class RoomFullException implements Exception {
  @override
  String toString() => 'La sala está llena.';
}

class RoomGameMismatchException implements Exception {
  @override
  String toString() => 'Este código pertenece a otro juego.';
}

class AlreadyInRoomException implements Exception {
  @override
  String toString() => 'Ya estás en esta sala.';
}

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
