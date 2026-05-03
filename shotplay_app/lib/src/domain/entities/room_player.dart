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
}
