part of 'configure_game_cubit.dart';

enum ConfigureGameStatus { idle, creating, created, error }

class ConfigureGameState {
  final ConfigureGameStatus status;
  final int playerCount;
  final bool hintsEnabled;
  final bool isPrivate;
  final GameRoom? createdRoom;
  final String? errorMessage;

  const ConfigureGameState({
    required this.status,
    required this.playerCount,
    required this.hintsEnabled,
    required this.isPrivate,
    this.createdRoom,
    this.errorMessage,
  });

  factory ConfigureGameState.initial(Game game) {
    return ConfigureGameState(
      status: ConfigureGameStatus.idle,
      playerCount: game.maxPlayers,
      hintsEnabled: false,
      isPrivate: false,
    );
  }

  ConfigureGameState copyWith({
    ConfigureGameStatus? status,
    int? playerCount,
    bool? hintsEnabled,
    bool? isPrivate,
    GameRoom? createdRoom,
    String? errorMessage,
  }) {
    return ConfigureGameState(
      status: status ?? this.status,
      playerCount: playerCount ?? this.playerCount,
      hintsEnabled: hintsEnabled ?? this.hintsEnabled,
      isPrivate: isPrivate ?? this.isPrivate,
      createdRoom: createdRoom ?? this.createdRoom,
      errorMessage: errorMessage,
    );
  }
}
