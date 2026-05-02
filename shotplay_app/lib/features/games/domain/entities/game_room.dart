class GameRoom {
  final String id;
  final String gameId;
  final String roomName;
  final String roomCode;
  final String hostUserId;
  final int maxPlayers;
  final int currentPlayers;
  final bool isPrivate;
  final bool hintsEnabled;
  final String status;

  const GameRoom({
    required this.id,
    required this.gameId,
    required this.roomName,
    required this.roomCode,
    required this.hostUserId,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.isPrivate,
    required this.hintsEnabled,
    required this.status,
  });
}
