class RoomSession {
  RoomSession({
    required this.idRoom,
    required this.roomCode,
    required this.adminId,
    required this.gameId,
    required this.maxPlayers,
    this.status = 'waiting',
    DateTime? createdAt,
    String? roomName,
    this.isPrivate = false,
  })  : createdAt = createdAt ?? DateTime(2000),
        roomName = roomName ?? roomCode;

  /// Primary key returned by Supabase (column: id_room, type: int4 → stored as String).
  final String idRoom;
  final String roomCode;
  final String adminId;
  final String gameId;
  final int maxPlayers;
  final String status;
  final DateTime createdAt;
  /// Display name for the room. Falls back to roomCode when the 'room_name'
  /// column does not exist in the schema.
  final String roomName;
  final bool isPrivate;

  factory RoomSession.fromMap(Map<String, dynamic> map) {
    final roomCode = (map['room_code'] as String?) ?? '';
    return RoomSession(
      // id_room is int4 in Supabase — always convert to String
      idRoom: map['id_room']?.toString() ?? '',
      roomCode: roomCode,
      adminId: (map['admin_id'] as String?) ?? '',
      gameId: (map['game_id'] as String?) ?? '',
      // Schema uses 'custom_max_players'; fall back for local/test payloads
      maxPlayers: (map['custom_max_players'] as num?)?.toInt()
          ?? (map['max_players'] as num?)?.toInt()
          ?? 0,
      // 'status', 'created_at', 'room_name', 'is_private' are NOT in the
      // current schema — use safe defaults so the app never crashes on null.
      status: (map['status'] as String?) ?? 'waiting',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      // Use room_name when present; otherwise display room_code as the name
      roomName: (map['room_name'] as String?) ?? roomCode,
      isPrivate: (map['is_private'] as bool?) ?? false,
    );
  }
}
