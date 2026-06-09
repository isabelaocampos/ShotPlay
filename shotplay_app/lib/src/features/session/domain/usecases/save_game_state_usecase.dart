import 'package:shotplay_app/src/domain/repositories/game_session_repository.dart';

class SaveGameStateUsecase {
  const SaveGameStateUsecase(this._repository);

  final GameSessionRepository _repository;

  Future<void> execute(int roomId, Map<String, dynamic> state) =>
      _repository.saveState(roomId, state);
}
