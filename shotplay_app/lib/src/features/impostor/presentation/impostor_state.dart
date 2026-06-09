import 'package:shotplay_app/src/features/impostor/domain/entities/impostor_entities.dart';

abstract class ImpostorState {
  const ImpostorState();
}

class ImpostorInitial extends ImpostorState {}

class ImpostorLoading extends ImpostorState {}

class ImpostorRoleAssigned extends ImpostorState {
  final PlayerRole role;
  final String? word; // Será null si es impostor
  final String hint;
  final String category;
  final String globalImpostorId;

  const ImpostorRoleAssigned({
    required this.role,
    this.word,
    required this.hint,
    required this.category,
    required this.globalImpostorId,
  });
}

class ImpostorError extends ImpostorState {
  final String message;
  const ImpostorError(this.message);
}

class ImpostorVotingState extends ImpostorState {
  final List<ImpostorVote> votes;
  final List<String> alivePlayerIds;
  final String impostorId;

  const ImpostorVotingState({
    required this.votes,
    required this.alivePlayerIds,
    required this.impostorId,
  });
}

class ImpostorGameOverState extends ImpostorState {
  final bool impostorWon;
  final String impostorId;
  final Map<String, String> voteMap;

  const ImpostorGameOverState({
    required this.impostorWon,
    required this.impostorId,
    required this.voteMap,
  });
}