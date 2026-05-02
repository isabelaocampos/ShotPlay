import '../../domain/entities/room_player.dart';

class RoomPlayerModel extends RoomPlayer {
  const RoomPlayerModel({
    required super.id,
    required super.roomId,
    required super.userId,
    required super.username,
    super.avatarUrl,
    required super.isReady,
    required super.isHost,
  });

  factory RoomPlayerModel.fromJson(Map<String, dynamic> json) {
    return RoomPlayerModel(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      userId: (json['user_id'] ?? '') as String,
      username: (json['username'] ?? 'Jugador') as String,
      avatarUrl: json['avatar_url'] as String?,
      isReady: (json['is_ready'] ?? false) as bool,
      isHost: (json['is_host'] ?? false) as bool,
    );
  }
}
