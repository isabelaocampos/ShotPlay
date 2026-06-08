import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/impostor_entities.dart';
import '../../domain/repositories/impostor_vote_repository.dart';

class ImpostorVoteRepositoryImpl implements ImpostorVoteRepository {
  final SupabaseClient _supabase;

  ImpostorVoteRepositoryImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<void> insertVote(String roomId, ImpostorVote vote) async {
    final parsedRoomId = int.tryParse(roomId) ?? roomId;
    await _supabase.from('impostor_votes').insert({
      'room_id': parsedRoomId,
      'voter_id': vote.voterId,
      'target_id': vote.targetId,
    });
  }

  @override
  Future<void> clearVotes(String roomId) async {
    final parsedRoomId = int.tryParse(roomId) ?? roomId;
    await _supabase
        .from('impostor_votes')
        .delete()
        .eq('room_id', parsedRoomId);
  }

  @override
  Stream<List<ImpostorVote>> watchVotes(String roomId) {
    final parsedRoomId = int.tryParse(roomId) ?? roomId;
    return _supabase
        .from('impostor_votes')
        .stream(primaryKey: ['room_id', 'voter_id'])
        .eq('room_id', parsedRoomId)
        .map((maps) => maps.map((map) => ImpostorVote.fromJson(map)).toList());
  }
}
