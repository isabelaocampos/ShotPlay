import 'lobby_settings.dart';
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
    this.lobbySettings = LobbySettings.empty,
  });

  final int idRoom;
  final String roomCode;
  final String adminId;
  final int gameId;
  final int maxPlayers;
  final String? roomName;
  final bool isPrivate;
  final RoomLifecycleStatus status;
  final LobbySettings lobbySettings;

  factory RoomSession.fromMap(Map<String, dynamic> map) {
    return RoomSession(
      idRoom: (map['id_room'] as num).toInt(),
      roomCode: map['room_code'] as String,
      adminId: map['admin_id'] as String,
      gameId: (map['game_id'] as num).toInt(),
      maxPlayers: (map['custom_max_players'] as num?)?.toInt() ?? 0,
      status: RoomLifecycleStatus.fromDb(map['status'] as String?),
      lobbySettings: LobbySettings.fromJson(
        map['lobby_settings'] as Map<String, dynamic>?,
      ),
    );
  }

  RoomSession copyWith({
    int? idRoom,
    String? roomCode,
    String? adminId,
    int? gameId,
    int? maxPlayers,
    String? roomName,
    bool? isPrivate,
    RoomLifecycleStatus? status,
    LobbySettings? lobbySettings,
  }) {
    return RoomSession(
      idRoom: idRoom ?? this.idRoom,
      roomCode: roomCode ?? this.roomCode,
      adminId: adminId ?? this.adminId,
      gameId: gameId ?? this.gameId,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      roomName: roomName ?? this.roomName,
      isPrivate: isPrivate ?? this.isPrivate,
      status: status ?? this.status,
      lobbySettings: lobbySettings ?? this.lobbySettings,
    );
  }
}
