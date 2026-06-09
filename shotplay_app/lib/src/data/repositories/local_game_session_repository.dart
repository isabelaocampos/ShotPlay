import 'package:flutter/foundation.dart';

import '../../domain/repositories/game_session_repository.dart';

class LocalGameSessionRepository implements GameSessionRepository {
  LocalGameSessionRepository();

  static final Map<int, Map<String, dynamic>> _states =
      <int, Map<String, dynamic>>{};

  @override
  Future<void> saveState(int roomId, Map<String, dynamic> state) async {
    _states[roomId] = Map<String, dynamic>.from(state);
    debugPrint('[GAME_STATE] Persisted snapshot (local) for room $roomId');
  }

  @override
  Future<Map<String, dynamic>?> fetchState(int roomId) async {
    final state = _states[roomId];
    if (state == null) return null;
    debugPrint('[GAME_STATE] Loaded snapshot (local) for room $roomId');
    return Map<String, dynamic>.from(state);
  }
}
