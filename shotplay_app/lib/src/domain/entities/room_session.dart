class RoomSession {
  const RoomSession({
    required this.roomCode,
    required this.adminId,
    required this.gameId,
    required this.maxPlayers,
    required this.status,
    required this.createdAt,
    required this.roomName,
    required this.isPrivate,
  });

  final String roomCode;
  final String adminId;
  final String gameId;
  final int maxPlayers;
  final String status;
  final DateTime createdAt;
  final String roomName;
  final bool isPrivate;

  Map<String, dynamic> toInsertMap() {
    return <String, dynamic>{
      'room_code': roomCode,
      'admin_id': adminId,
      'game_id': gameId,
      'max_players': maxPlayers,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'room_name': roomName,
      'is_private': isPrivate,
    };
  }

  factory RoomSession.fromMap(Map<String, dynamic> map) {
    return RoomSession(
      roomCode: map['room_code'] as String,
      adminId: map['admin_id'] as String,
      gameId: map['game_id'] as String,
      maxPlayers: (map['max_players'] as num).toInt(),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'].toString()),
      roomName: (map['room_name'] as String?) ?? 'ShotPlay Room',
      isPrivate: (map['is_private'] as bool?) ?? false,
    );
  }
}