part of 'game_catalog_cubit.dart';

enum GameCatalogStatus { initial, loading, loaded, error }

class GameCatalogState {
  final GameCatalogStatus status;
  final List<Game> games;
  final Game? selectedGame;
  final String? errorMessage;

  const GameCatalogState({
    required this.status,
    required this.games,
    this.selectedGame,
    this.errorMessage,
  });

  const GameCatalogState.initial()
      : status = GameCatalogStatus.initial,
        games = const [],
        selectedGame = null,
        errorMessage = null;

  GameCatalogState copyWith({
    GameCatalogStatus? status,
    List<Game>? games,
    Game? selectedGame,
    String? errorMessage,
    bool clearSelection = false,
  }) {
    return GameCatalogState(
      status: status ?? this.status,
      games: games ?? this.games,
      selectedGame:
          clearSelection ? null : (selectedGame ?? this.selectedGame),
      errorMessage: errorMessage,
    );
  }
}
