/// Generic persisted game state keyed by room. Game features own the JSON shape.
abstract class GameSessionRepository {
  Future<void> saveState(int roomId, Map<String, dynamic> state);

  Future<Map<String, dynamic>?> fetchState(int roomId);
}
