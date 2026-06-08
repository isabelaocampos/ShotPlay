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
