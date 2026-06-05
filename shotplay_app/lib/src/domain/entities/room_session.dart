import 'room_lifecycle_status.dart';

class RoomSession {
  RoomSession({
    required this.idRoom,
    required this.roomCode,
    required this.adminId,
    required this.gameId,
    required this.maxPlayers,
    this.roomName,
    this.isPrivate = false,
    this.status = RoomLifecycleStatus.waiting,
  });

  final int idRoom;
  final String roomCode;
  final String adminId;
  final int gameId;
  final int maxPlayers;
  final String? roomName;
  final bool isPrivate;
  final RoomLifecycleStatus status;

  factory RoomSession.fromMap(Map<String, dynamic> map) {
    return RoomSession(
      idRoom: (map['id_room'] as num).toInt(),
      roomCode: map['room_code'] as String,
      adminId: map['admin_id'] as String,
      gameId: (map['game_id'] as num).toInt(),
      maxPlayers: (map['custom_max_players'] as num?)?.toInt() ?? 0,
      status: RoomLifecycleStatus.fromDb(map['status'] as String?),
    );
  }
}
