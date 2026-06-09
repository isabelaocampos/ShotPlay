import '../domain/entities/impostor_entities.dart';

abstract class ImpostorEvent {
  const ImpostorEvent();
}

/// Evento para que el Host inicie el sorteo.
class StartRoleDistribution extends ImpostorEvent {
  final List<String> playerIds;
  final int impostorCount;

  const StartRoleDistribution({
    required this.playerIds,
    this.impostorCount = 1,
  });
}

/// Evento interno disparado cuando llega el broadcast de Supabase.
class OnImpostorDataReceived extends ImpostorEvent {
  final Map<String, dynamic> payload;

  const OnImpostorDataReceived(this.payload);
}

class SubmitVote extends ImpostorEvent {
  final String targetPlayerId;

  const SubmitVote(this.targetPlayerId);
}

class OnVotesUpdated extends ImpostorEvent {
  final List<ImpostorVote> votes;

  const OnVotesUpdated(this.votes);
}

class RestartImpostorGame extends ImpostorEvent {
  const RestartImpostorGame();
}

class NextRoundImpostorGame extends ImpostorEvent {
  const NextRoundImpostorGame();
}

class StartVotingPhase extends ImpostorEvent {
  final List<String> alivePlayerIds;
  final String impostorId;

  const StartVotingPhase({
    required this.alivePlayerIds,
    required this.impostorId,
  });
}