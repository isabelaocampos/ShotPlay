abstract class GameEventRepository {
  /// Joins the realtime broadcast channel for [roomCode].
  ///
  /// Idempotent when already connected to the same room.
  Future<void> connect(String roomCode);

  /// Sends a generic JSON event to all subscribers in the room.
  Future<void> emitEvent(Map<String, dynamic> event);

  /// Stream of events received from other clients in the room.
  Stream<Map<String, dynamic>> listenToEvents();

  /// Leaves the room channel and releases realtime resources.
  Future<void> disconnect();
}

class GameEventNotConnectedException implements Exception {
  @override
  String toString() =>
      'GameEventRepository is not connected to a room. Call connect() first.';
}

class GameEventRepositoryException implements Exception {
  GameEventRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
