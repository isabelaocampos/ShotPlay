class RoomSession {
  RoomSession({
    required this.idRoom,
    required this.roomCode,
    required this.adminId,
    required this.gameId,
    required this.maxPlayers,
    this.roomName,
    this.isPrivate = false,
  });

  // room.id_room is int4 in Supabase.
  final int idRoom;
  // room.room_code (text, unique).
  final String roomCode;
  // room.admin_id (uuid → profiles.id).
  final String adminId;
  // room.game_id (int4).
  final int gameId;
  // room.custom_max_players (int4).
  final int maxPlayers;
  // Display-only metadata supplied by the UI. Not persisted: the schema has
  // no room_name / is_private columns. Kept here so the in-memory session
  // returned to the screen carries what the user typed.
  final String? roomName;
  final bool isPrivate;

  factory RoomSession.fromMap(Map<String, dynamic> map) {
    return RoomSession(
      idRoom: (map['id_room'] as num).toInt(),
      roomCode: map['room_code'] as String,
      adminId: map['admin_id'] as String,
      gameId: (map['game_id'] as num).toInt(),
      maxPlayers: (map['custom_max_players'] as num?)?.toInt() ?? 0,
    );
  }
}
