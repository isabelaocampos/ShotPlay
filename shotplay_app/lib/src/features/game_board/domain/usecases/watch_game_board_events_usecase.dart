import '../../../../domain/repositories/game_event_repository.dart';

class WatchGameBoardEventsUsecase {
  const WatchGameBoardEventsUsecase(this._gameEvents);

  final GameEventRepository _gameEvents;

  Stream<Map<String, dynamic>> execute() => _gameEvents.listenToEvents();
}
