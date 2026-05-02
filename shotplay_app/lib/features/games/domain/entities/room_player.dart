class RoomPlayer {
  final String id;
  final String roomId;
  final String userId;
  final String username;
  final String? avatarUrl;
  final bool isReady;
  final bool isHost;

  const RoomPlayer({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.isReady,
    required this.isHost,
  });

  String get statusLabel {
    if (isHost) return 'ANFITRIÓN';
    if (isReady) return 'LISTO';
    return 'ESPERANDO...';
  }
}
