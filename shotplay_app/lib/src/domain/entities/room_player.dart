class RoomPlayer {
  const RoomPlayer({
    required this.id,
    required this.roomCode,
    required this.userId,
    required this.username,
    required this.isHost,
    required this.isReady,
  });

  final String id;
  final String roomCode;
  final String userId;
  final String username;
  final bool isHost;
  final bool isReady;

  String get statusLabel {
    if (isHost) return 'Anfitrión';
    if (isReady) return 'Listo para jugar';
    return 'Conectado';
  }

  factory RoomPlayer.fromMap(Map<String, dynamic> map) {
    return RoomPlayer(
      id: map['id']?.toString() ?? '',
      roomCode: (map['room_code'] as String?) ?? '',
      userId: (map['user_id'] as String?) ?? '',
      username: (map['username'] as String?) ?? 'Jugador',
      isHost: (map['is_host'] as bool?) ?? false,
      isReady: (map['is_ready'] as bool?) ?? false,
    );
  }
}
