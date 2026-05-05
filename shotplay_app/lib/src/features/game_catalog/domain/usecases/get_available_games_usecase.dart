import 'package:shotplay_app/src/domain/entities/game_option.dart';
import 'package:shotplay_app/src/domain/repositories/game_repository.dart';

class GetAvailableGamesUsecase {
  final GameRepository _repository;

  const GetAvailableGamesUsecase(this._repository);

  Future<List<GameOption>> execute() => _repository.getAvailableGames();
}
