import '../entities/game_option.dart';

abstract class GameRepository {
  Future<List<GameOption>> getAvailableGames();
}

class GameRepositoryException implements Exception {
  GameRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
