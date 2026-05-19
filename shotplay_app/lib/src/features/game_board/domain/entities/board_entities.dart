/// Represents the type of a board cell with its colour group.
enum CellType {
  normal,
  snakeHead, // pink — player slides down (head of the snake)
  ladderBase, // ladder bottom — player goes up
  shotTake, // lime/green — take a shot
  shotGive, // cyan — give a shot
}

/// A single square on the 7×7 board (numbered 1–49, bottom-left to top-right
/// following the boustrophedon / snakes-and-ladders numbering).
class BoardSquare {
  const BoardSquare({
    required this.number,
    required this.type,
    this.connectsTo, // snake head → tail, or ladder base → top
  });

  final int number;
  final CellType type;
  final int? connectsTo;
}

/// Immutable description of every snake and ladder on the 7×7 board,
/// matching the reference image (pink board, 49 squares).
///
/// Snakes: head → tail (player goes DOWN)
/// Ladders: base → top (player goes UP)
class BoardDefinition {
  BoardDefinition._();

  /// Snakes: key = head square, value = tail square (where player lands).
  static const Map<int, int> snakes = {
    12: 2,  // snake at 12 → drops to 2
    40: 22, // snake at 40 → drops to 22
    44: 37, // snake at 44 → drops to 37
  };

  /// Ladders: key = base square, value = top square (where player lands).
  static const Map<int, int> ladders = {
    4: 20,  // ladder at 4 → climbs to 20
    9: 31,  // ladder at 9 → climbs to 31
    20: 38, // ladder at 20 → climbs to 38 (double-check image)
    28: 46, // ladder at 28 → climbs to 46
  };

  /// Truth-or-dare squares (pink board uses these as 'shot' squares).
  static const Set<int> shotSquares = {7, 14, 21, 30, 31};

  static CellType typeOf(int square) {
    if (snakes.containsKey(square)) return CellType.snakeHead;
    if (ladders.containsKey(square)) return CellType.ladderBase;
    if (shotSquares.contains(square)) return CellType.shotTake;
    return CellType.normal;
  }
}

/// Live position of a single player on the board.
class PlayerPosition {
  const PlayerPosition({
    required this.playerId,
    required this.username,
    required this.square, // 1–49, 0 = not started
    required this.avatarIndex, // 0,1,2,3 → colour token
  });

  final String playerId;
  final String username;
  final int square;
  final int avatarIndex;

  PlayerPosition copyWith({int? square}) => PlayerPosition(
        playerId: playerId,
        username: username,
        square: square ?? this.square,
        avatarIndex: avatarIndex,
      );
}

/// Full game state broadcast over the realtime channel.
class GameState {
  const GameState({
    required this.positions,
    required this.currentTurnPlayerId,
    required this.lastDiceValue,
    required this.shotsTakenByCurrentPlayer,
    required this.isStarted,
    this.lastMovedPlayerId = '', // '' = nobody has moved yet
  });

  final List<PlayerPosition> positions;
  final String currentTurnPlayerId;
  final int lastDiceValue; // 0 = not rolled yet
  final int shotsTakenByCurrentPlayer;
  final bool isStarted;

  /// ID of the player who last rolled the dice (differs from
  /// [currentTurnPlayerId] once the turn has advanced).
  final String lastMovedPlayerId;

  GameState copyWith({
    List<PlayerPosition>? positions,
    String? currentTurnPlayerId,
    int? lastDiceValue,
    int? shotsTakenByCurrentPlayer,
    bool? isStarted,
    String? lastMovedPlayerId,
  }) {
    return GameState(
      positions: positions ?? this.positions,
      currentTurnPlayerId: currentTurnPlayerId ?? this.currentTurnPlayerId,
      lastDiceValue: lastDiceValue ?? this.lastDiceValue,
      shotsTakenByCurrentPlayer:
          shotsTakenByCurrentPlayer ?? this.shotsTakenByCurrentPlayer,
      isStarted: isStarted ?? this.isStarted,
      lastMovedPlayerId: lastMovedPlayerId ?? this.lastMovedPlayerId,
    );
  }

  /// Returns the raw square for the current player after rolling [diceValue],
  /// without applying snake or ladder logic.
  int rawSquareForCurrentPlayer(int diceValue) {
    if (positions.isEmpty) return 1;
    final player = positions.firstWhere(
      (p) => p.playerId == currentTurnPlayerId,
      orElse: () => positions.first,
    );
    return (player.square + diceValue).clamp(1, 49);
  }

  /// Applies [finalSquare] as the current player's resolved position and
  /// advances the turn. [diceValue] is preserved for animation.
  GameState applyFinalMove(int finalSquare, int diceValue) {
    if (positions.isEmpty) return this;

    final mover = currentTurnPlayerId; // capture BEFORE advancing

    final updatedPositions = positions.map((p) {
      if (p.playerId != mover) return p;
      return p.copyWith(square: finalSquare);
    }).toList();

    final playerIds = positions.map((p) => p.playerId).toList();
    final currentIndex = playerIds.indexOf(mover);
    final nextIndex = (currentIndex + 1) % playerIds.length;

    return copyWith(
      positions: updatedPositions,
      currentTurnPlayerId: playerIds[nextIndex],
      lastDiceValue: diceValue,
      shotsTakenByCurrentPlayer: 0,
      lastMovedPlayerId: mover,
    );
  }

  /// Convenience: rolls dice and auto-resolves snake/ladder without player choice.
  /// Used only for the no-challenge path (normal squares).
  GameState applyDiceRoll(int diceValue) {
    final rawSquare = rawSquareForCurrentPlayer(diceValue);
    int finalSquare = rawSquare;
    if (BoardDefinition.snakes.containsKey(rawSquare)) {
      finalSquare = BoardDefinition.snakes[rawSquare]!;
    } else if (BoardDefinition.ladders.containsKey(rawSquare)) {
      finalSquare = BoardDefinition.ladders[rawSquare]!;
    }
    return applyFinalMove(finalSquare, diceValue);
  }

  Map<String, dynamic> toJson() => {
        'positions': positions
            .map((p) => {
                  'playerId': p.playerId,
                  'username': p.username,
                  'square': p.square,
                  'avatarIndex': p.avatarIndex,
                })
            .toList(),
        'currentTurnPlayerId': currentTurnPlayerId,
        'lastDiceValue': lastDiceValue,
        'shotsTakenByCurrentPlayer': shotsTakenByCurrentPlayer,
        'isStarted': isStarted,
        'lastMovedPlayerId': lastMovedPlayerId,
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    final rawPositions = (json['positions'] as List<dynamic>?) ?? [];
    return GameState(
      positions: rawPositions
          .map((e) => PlayerPosition(
                playerId: e['playerId'] as String,
                username: e['username'] as String,
                square: (e['square'] as num).toInt(),
                avatarIndex: (e['avatarIndex'] as num).toInt(),
              ))
          .toList(),
      currentTurnPlayerId: json['currentTurnPlayerId'] as String? ?? '',
      lastDiceValue: (json['lastDiceValue'] as num?)?.toInt() ?? 0,
      shotsTakenByCurrentPlayer:
          (json['shotsTakenByCurrentPlayer'] as num?)?.toInt() ?? 0,
      isStarted: json['isStarted'] as bool? ?? false,
      lastMovedPlayerId: json['lastMovedPlayerId'] as String? ?? '',
    );
  }

  static GameState initial(List<PlayerPosition> players) => GameState(
        positions: players,
        currentTurnPlayerId: players.isNotEmpty ? players.first.playerId : '',
        lastDiceValue: 0,
        shotsTakenByCurrentPlayer: 0,
        isStarted: true,
        lastMovedPlayerId: '',
      );
}

// ── Penalty Challenge ───────────────────────────────────────────────────────

/// Describes which shot offer is presented to the player.
enum PenaltyChallengeType {
  /// Snake head — accept shot → stay at head; decline → fall to tail.
  takeShootToStay,
  /// Ladder base — accept shot → climb to top; decline → stay at base.
  takeShotToClimb,
}

/// The interactive challenge shown when a player lands on a snake head or
/// ladder base. Carries both outcomes so the controller can resolve the move
/// without knowing board details.
class PenaltyChallenge {
  const PenaltyChallenge({
    required this.type,
    required this.rawSquare,
    required this.acceptSquare,
    required this.rejectSquare,
  });

  final PenaltyChallengeType type;

  /// The square the player's token landed on (head or base).
  final int rawSquare;

  /// Final square if the player takes the shot.
  final int acceptSquare;

  /// Final square if the player refuses the shot.
  final int rejectSquare;

  /// Returns a [PenaltyChallenge] if [rawSquare] is a snake head or ladder
  /// base, or null for any other square.
  static PenaltyChallenge? forSquare(int rawSquare) {
    if (BoardDefinition.snakes.containsKey(rawSquare)) {
      return PenaltyChallenge(
        type: PenaltyChallengeType.takeShootToStay,
        rawSquare: rawSquare,
        acceptSquare: rawSquare, // stays at head
        rejectSquare: BoardDefinition.snakes[rawSquare]!, // falls to tail
      );
    }
    if (BoardDefinition.ladders.containsKey(rawSquare)) {
      return PenaltyChallenge(
        type: PenaltyChallengeType.takeShotToClimb,
        rawSquare: rawSquare,
        acceptSquare: BoardDefinition.ladders[rawSquare]!, // climbs to top
        rejectSquare: rawSquare, // stays at base
      );
    }
    return null;
  }
}
