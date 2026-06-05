import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/game_session_repository.dart';

class SupabaseGameSessionRepository implements GameSessionRepository {
  SupabaseGameSessionRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> saveState(int roomId, Map<String, dynamic> state) async {
    try {
      await _client.from('room').update(<String, dynamic>{
        'game_state': state,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id_room', roomId);
      debugPrint('[GAME_STATE] Persisted snapshot for room $roomId');
    } catch (e) {
      debugPrint('[GAME_STATE] Save failed for room $roomId: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchState(int roomId) async {
    try {
      final row = await _client
          .from('room')
          .select('game_state')
          .eq('id_room', roomId)
          .maybeSingle();

      final raw = row?['game_state'];
      if (raw is! Map<String, dynamic>) return null;

      debugPrint('[GAME_STATE] Loaded snapshot for room $roomId');
      return Map<String, dynamic>.from(raw);
    } catch (e) {
      debugPrint('[GAME_STATE] Fetch failed for room $roomId: $e');
      return null;
    }
  }
}
