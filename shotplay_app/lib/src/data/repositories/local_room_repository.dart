import '../../domain/entities/room_session.dart';
import '../../domain/repositories/room_repository.dart';

class LocalRoomRepository implements RoomRepository {
  const LocalRoomRepository();

  static final Map<String, RoomSession> _rooms = <String, RoomSession>{};

  @override
  Future<RoomSession> createRoom({
    required String roomCode,
    required String adminId,
    required String gameId,
    required int maxPlayers,
    required bool isPrivate,
    required String roomName,
  }) async {
    if (_rooms.containsKey(roomCode)) {
      throw RoomCodeCollisionException();
    }

    final room = RoomSession(
      roomCode: roomCode,
      adminId: adminId,
      gameId: gameId,
      maxPlayers: maxPlayers,
      status: 'waiting',
      createdAt: DateTime.now().toUtc(),
      roomName: roomName,
      isPrivate: isPrivate,
    );

    _rooms[roomCode] = room;
    await Future<void>.delayed(const Duration(milliseconds: 550));
    return room;
  }
}