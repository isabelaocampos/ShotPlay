import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/game.dart';
import '../../domain/repositories/game_repository.dart';

part 'game_catalog_state.dart';

class GameCatalogCubit extends Cubit<GameCatalogState> {
  final GameRepository _repository;

  GameCatalogCubit(this._repository) : super(const GameCatalogState.initial());

  Future<void> loadGames() async {
    emit(state.copyWith(
      status: GameCatalogStatus.loading,
      errorMessage: null,
    ));
    try {
      final games = await _repository.getAvailableGames();
      emit(state.copyWith(
        status: GameCatalogStatus.loaded,
        games: games,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: GameCatalogStatus.error,
        errorMessage:
            'No pudimos cargar los juegos. Revisa tu conexión e inténtalo otra vez.',
      ));
    }
  }

  void selectGame(Game game) {
    if (!game.isAvailable) return;
    emit(state.copyWith(selectedGame: game));
  }

  void clearSelection() {
    emit(state.copyWith(clearSelection: true));
  }
}
