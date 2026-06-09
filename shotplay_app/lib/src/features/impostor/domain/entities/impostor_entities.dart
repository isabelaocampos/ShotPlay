enum PlayerRole { civil, impostor }

class WordEntity {
  final String word;
  final String hint;

  const WordEntity({required this.word, required this.hint});
}

class CategoryEntity {
  final String name;
  final List<WordEntity> words;

  const CategoryEntity({required this.name, required this.words});
}

class AssignedRole {
  final String playerId;
  final PlayerRole role;
  final String? word; // Null para impostores
  final String hint;
  final String category;

  AssignedRole({
    required this.playerId,
    required this.role,
    this.word,
    required this.hint,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    "playerId": playerId,
    "role": role.name,
    "word": word,
    "hint": hint,
    "category": category,
  };
}

enum QuestionPhaseType { pregunta, votacion }

class QuestionPhaseState {
  const QuestionPhaseState({
    required this.phase,
    required this.roundStartTimeUtc,
    required this.durationSeconds,
    required this.roundNumber,
    required this.alivePlayerIds,
  });

  final QuestionPhaseType phase;
  final DateTime roundStartTimeUtc;
  final int durationSeconds;
  final int roundNumber;
  final List<String> alivePlayerIds;

  Duration get remainingDuration {
    final elapsed = DateTime.now().toUtc().difference(roundStartTimeUtc);
    final remaining = Duration(seconds: durationSeconds) - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  int get remainingSeconds => remainingDuration.inSeconds;

  bool get isVoting => phase == QuestionPhaseType.votacion;

  QuestionPhaseState copyWith({
    QuestionPhaseType? phase,
    DateTime? roundStartTimeUtc,
    int? durationSeconds,
    int? roundNumber,
    List<String>? alivePlayerIds,
  }) {
    return QuestionPhaseState(
      phase: phase ?? this.phase,
      roundStartTimeUtc: roundStartTimeUtc ?? this.roundStartTimeUtc,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      roundNumber: roundNumber ?? this.roundNumber,
      alivePlayerIds: alivePlayerIds ?? this.alivePlayerIds,
    );
  }

  QuestionPhaseState asVoting() => copyWith(phase: QuestionPhaseType.votacion);

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'roundStartTimeUtc': roundStartTimeUtc.toUtc().toIso8601String(),
        'durationSeconds': durationSeconds,
        'roundNumber': roundNumber,
        'alivePlayerIds': alivePlayerIds,
      };

  factory QuestionPhaseState.fromJson(Map<String, dynamic> json) {
    final rawPhase = json['phase'] as String? ?? QuestionPhaseType.pregunta.name;
    return QuestionPhaseState(
      phase: rawPhase == QuestionPhaseType.votacion.name
          ? QuestionPhaseType.votacion
          : QuestionPhaseType.pregunta,
      roundStartTimeUtc: DateTime.parse(
        json['roundStartTimeUtc'] as String? ??
            DateTime.now().toUtc().toIso8601String(),
      ).toUtc(),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 45,
      roundNumber: (json['roundNumber'] as num?)?.toInt() ?? 1,
      alivePlayerIds:
          ((json['alivePlayerIds'] as List<dynamic>?) ?? const <dynamic>[])
              .map((id) => id.toString())
              .toList(),
    );
  }
}

class ImpostorVote {
  final String voterId;
  final String targetId;

  const ImpostorVote({required this.voterId, required this.targetId});

  factory ImpostorVote.fromJson(Map<String, dynamic> json) {
    return ImpostorVote(
      voterId: json['voter_id'] as String,
      targetId: json['target_id'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'voter_id': voterId,
        'target_id': targetId,
      };
}

class VerdictResult {
  final bool impostorWon;
  final String impostorId;
  final Map<String, String> voteMap; // voterId -> targetId

  const VerdictResult({
    required this.impostorWon,
    required this.impostorId,
    required this.voteMap,
  });
}

VerdictResult calculateVerdict(List<ImpostorVote> votes, String impostorId) {
  final voteCounts = <String, int>{};
  final voteMap = <String, String>{};

  for (final vote in votes) {
    voteMap[vote.voterId] = vote.targetId;
    voteCounts[vote.targetId] = (voteCounts[vote.targetId] ?? 0) + 1;
  }

  if (voteCounts.isEmpty) {
    return VerdictResult(impostorWon: true, impostorId: impostorId, voteMap: voteMap);
  }

  int maxVotes = 0;
  for (final count in voteCounts.values) {
    if (count > maxVotes) {
      maxVotes = count;
    }
  }

  final playersWithMaxVotes = voteCounts.entries
      .where((e) => e.value == maxVotes)
      .map((e) => e.key)
      .toList();

  bool impostorWon;
  if (playersWithMaxVotes.length == 1) {
    final eliminatedId = playersWithMaxVotes.first;
    if (eliminatedId == impostorId) {
      // Impostor was identified and eliminated
      impostorWon = false;
    } else {
      // A civilian was eliminated
      impostorWon = true;
    }
  } else {
    // Business rule: Empate en votos: gana el impostor por supervivencia.
    impostorWon = true;
  }

  return VerdictResult(
    impostorWon: impostorWon,
    impostorId: impostorId,
    voteMap: voteMap,
  );
}
