import 'package:flutter/foundation.dart';

import '../../../domain/entities/game_option.dart';
import '../../../domain/repositories/game_repository.dart';
import '../domain/usecases/get_available_games_usecase.dart';

enum GameCatalogStatus { initial, loading, loaded, error }

class GameCatalogController extends ChangeNotifier {
  GameCatalogController({required GameRepository gameRepository})
      : _getGamesUsecase = GetAvailableGamesUsecase(gameRepository);

  final GetAvailableGamesUsecase _getGamesUsecase;

  GameCatalogStatus _status = GameCatalogStatus.initial;
  List<GameOption> _games = const <GameOption>[];
  GameOption? _selectedGame;
  String? _errorMessage;

  GameCatalogStatus get status => _status;
  List<GameOption> get games => _games;
  GameOption? get selectedGame => _selectedGame;
  String? get errorMessage => _errorMessage;

  Future<void> loadGames() async {
    if (_status == GameCatalogStatus.loading) return;

    _status = GameCatalogStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final games = await _getGamesUsecase.execute();
      _games = games;
      _status = GameCatalogStatus.loaded;
    } on GameRepositoryException catch (error) {
      _errorMessage = error.message;
      _status = GameCatalogStatus.error;
    } catch (_) {
      _errorMessage = 'No pudimos cargar el catálogo. Revisa tu conexión.';
      _status = GameCatalogStatus.error;
    }

    notifyListeners();
  }

  void selectGame(GameOption game) {
    _selectedGame = game;
    notifyListeners();
  }

  void clearSelection() {
    _selectedGame = null;
    notifyListeners();
  }
}
