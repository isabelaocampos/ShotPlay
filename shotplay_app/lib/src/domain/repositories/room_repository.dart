import '../entities/room_session.dart';

abstract class RoomRepository {
  Future<RoomSession> createRoom({
    required String roomCode,
    required String adminId,
    required String gameId,
    required int maxPlayers,
    required bool isPrivate,
    required String roomName,
  });
}

class RoomCodeCollisionException implements Exception {}

class RoomRepositoryException implements Exception {
  RoomRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}