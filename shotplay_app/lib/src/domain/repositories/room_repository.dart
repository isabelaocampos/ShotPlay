import '../entities/room_entry_result.dart';
import '../entities/room_lifecycle_status.dart';
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

  Future<List<RoomPlayer>> fetchRoomPlayers(String roomCode);

  /// Joins or re-enters a room and resolves the correct navigation destination.
  Future<RoomEntryResult> enterRoom({
    required String roomCode,
    int? expectedGameId,
  });

  /// Marks the current user as intentionally left (keeps row for history).
  Future<void> leaveRoom(int roomId);

  /// Allows the admin to close (delete) the room entirely.
  Future<void> closeRoom(int roomId);

  Future<void> updateRoomStatus(int roomId, RoomLifecycleStatus status);

  Future<void> markParticipationActive(int roomId);

  Future<void> markParticipationDisconnected(int roomId);
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

class RoomFinishedException implements Exception {
  @override
  String toString() => 'Esta partida ya finalizó.';
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
