import '../../domain/entities/game_option.dart';
import '../../domain/repositories/game_repository.dart';

class LocalGameRepository implements GameRepository {
  const LocalGameRepository();

  @override
  Future<List<GameOption>> getAvailableGames() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return defaultGameOptions;
  }
}
