/// Identifies which multiplayer game mode a room is configured for.
enum GameMode {
  snakesLadders('snakes_ladders', 'SnakesGameScreen'),
  impostor('impostor', 'ImpostorGameScreen'),
  unknown('unknown', 'UnknownGameScreen');

  const GameMode(this.catalogId, this.screenLabel);

  /// Matches [GameOption.id] in the catalog.
  final String catalogId;

  /// Human-readable screen name for navigation logs.
  final String screenLabel;
}
