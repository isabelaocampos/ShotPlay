/// Represents the type of a board cell with its colour group.
enum CellType {
  normal,
  snakeTail, // pink — player slides down
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
    if (snakes.containsKey(square)) return CellType.snakeTail;
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
  });

  final List<PlayerPosition> positions;
  final String currentTurnPlayerId;
  final int lastDiceValue; // 0 = not rolled yet
  final int shotsTakenByCurrentPlayer;
  final bool isStarted;

  GameState copyWith({
    List<PlayerPosition>? positions,
    String? currentTurnPlayerId,
    int? lastDiceValue,
    int? shotsTakenByCurrentPlayer,
    bool? isStarted,
  }) {
    return GameState(
      positions: positions ?? this.positions,
      currentTurnPlayerId: currentTurnPlayerId ?? this.currentTurnPlayerId,
      lastDiceValue: lastDiceValue ?? this.lastDiceValue,
      shotsTakenByCurrentPlayer:
          shotsTakenByCurrentPlayer ?? this.shotsTakenByCurrentPlayer,
      isStarted: isStarted ?? this.isStarted,
    );
  }

  /// Calculates the next state after rolling the dice.
  /// Applies movements, ladders, snakes, and advances the turn.
  GameState applyDiceRoll(int diceValue) {
    if (positions.isEmpty) return this;

    final updatedPositions = positions.map((p) {
      if (p.playerId != currentTurnPlayerId) return p;

      int newSquare = (p.square + diceValue).clamp(1, 49);

      // Apply snake
      if (BoardDefinition.snakes.containsKey(newSquare)) {
        newSquare = BoardDefinition.snakes[newSquare]!;
      }
      // Apply ladder
      else if (BoardDefinition.ladders.containsKey(newSquare)) {
        newSquare = BoardDefinition.ladders[newSquare]!;
      }

      return p.copyWith(square: newSquare);
    }).toList();

    // Advance turn to the next player
    final playerIds = positions.map((p) => p.playerId).toList();
    final currentIndex = playerIds.indexOf(currentTurnPlayerId);
    final nextIndex = (currentIndex + 1) % playerIds.length;
    final nextPlayerId = playerIds[nextIndex];

    return copyWith(
      positions: updatedPositions,
      currentTurnPlayerId: nextPlayerId,
      lastDiceValue: diceValue,
      shotsTakenByCurrentPlayer: 0,
    );
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
    );
  }

  static GameState initial(List<PlayerPosition> players) => GameState(
        positions: players,
        currentTurnPlayerId: players.isNotEmpty ? players.first.playerId : '',
        lastDiceValue: 0,
        shotsTakenByCurrentPlayer: 0,
        isStarted: true,
      );
}
