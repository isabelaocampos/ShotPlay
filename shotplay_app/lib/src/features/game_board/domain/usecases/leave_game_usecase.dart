import '../../../../domain/repositories/game_event_repository.dart';

/// Releases the realtime game channel when the player leaves the board.
class LeaveGameUsecase {
  const LeaveGameUsecase(this._repository);

  final GameEventRepository _repository;

  Future<void> execute() => _repository.disconnect();
}
