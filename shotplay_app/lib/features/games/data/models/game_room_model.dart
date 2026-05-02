import '../../domain/entities/game_room.dart';

class GameRoomModel extends GameRoom {
  const GameRoomModel({
    required super.id,
    required super.gameId,
    required super.roomName,
    required super.roomCode,
    required super.hostUserId,
    required super.maxPlayers,
    required super.currentPlayers,
    required super.isPrivate,
    required super.hintsEnabled,
    required super.status,
  });

  factory GameRoomModel.fromJson(Map<String, dynamic> json) {
    return GameRoomModel(
      id: json['id'] as String,
      gameId: json['game_id'] as String,
      roomName: json['room_name'] as String,
      roomCode: json['room_code'] as String,
      hostUserId: json['host_user_id'] as String,
      maxPlayers: (json['max_players'] as num).toInt(),
      currentPlayers: ((json['current_players'] ?? 1) as num).toInt(),
      isPrivate: (json['is_private'] ?? false) as bool,
      hintsEnabled: (json['hints_enabled'] ?? false) as bool,
      status: (json['status'] ?? 'waiting') as String,
    );
  }
}
