import '../entities/impostor_entities.dart';
import '../repositories/impostor_vote_repository.dart';

class EmitImpostorVoteUseCase {
  final ImpostorVoteRepository _repository;

  EmitImpostorVoteUseCase(this._repository);

  Future<void> execute(String roomId, ImpostorVote vote) async {
    await _repository.insertVote(roomId, vote);
  }
}
