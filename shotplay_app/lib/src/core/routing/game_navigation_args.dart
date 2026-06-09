import '../../domain/entities/room_player.dart';
import '../../domain/entities/room_session.dart';

/// Standard route arguments for any active multiplayer game screen.
class GameNavigationArgs {
  const GameNavigationArgs({
    required this.room,
    required this.players,
    required this.isAdmin,
    this.isReconnect = false,
    this.persistedGameState,
    this.impostorInfo,
    this.impostorPhase,
  });

  final RoomSession room;
  final List<RoomPlayer> players;
  final bool isAdmin;
  final bool isReconnect;
  final Map<String, dynamic>? persistedGameState;
  final Map<String, dynamic>? impostorInfo;

  /// When set on [AppRoutes.impostorGame], skips role reveal (`play`) or
  /// shows it (`reveal`). Omit to auto-detect from reconnect + persisted state.
  final String? impostorPhase;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'room': room,
        'players': players,
        'isAdmin': isAdmin,
        'isReconnect': isReconnect,
        'persistedGameState': persistedGameState,
        'impostorInfo': impostorInfo,
        'impostorPhase': impostorPhase,
      };

  factory GameNavigationArgs.fromMap(Map<String, dynamic> map) {
    return GameNavigationArgs(
      room: map['room'] as RoomSession,
      players: (map['players'] as List<dynamic>).cast<RoomPlayer>(),
      isAdmin: map['isAdmin'] as bool,
      isReconnect: map['isReconnect'] as bool? ?? false,
      persistedGameState:
          map['persistedGameState'] as Map<String, dynamic>?,
      impostorInfo: map['impostorInfo'] as Map<String, dynamic>?,
      impostorPhase: map['impostorPhase'] as String?,
    );
  }
}
