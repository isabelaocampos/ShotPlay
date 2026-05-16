import 'package:shotplay_app/src/domain/repositories/game_event_repository.dart';

class WatchGameEventsUsecase {
  const WatchGameEventsUsecase(this._repository);

  final GameEventRepository _repository;

  Stream<Map<String, dynamic>> execute() => _repository.listenToEvents();
}
