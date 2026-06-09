import '../entities/impostor_entities.dart';

abstract class ImpostorVoteRepository {
  Future<void> insertVote(String roomId, ImpostorVote vote);
  Future<void> clearVotes(String roomId);
  Stream<List<ImpostorVote>> watchVotes(String roomId);
}
