class AppRoutes {
  AppRoutes._();

  // Auth flow
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';

  // Game flow
  static const String gameCatalog = '/';
  static const String gameDetails = '/game-details';
  static const String configureRoom = '/configure-room';
  static const String waitingRoom = '/waiting-room';

  /// Per-game entry routes (use [GameRouteResolver] to pick the right one).
  static const String snakesGame = '/snakes-game';
  static const String impostorGame = '/impostor-game';

  /// Impostor role-reveal phase (also reachable for next-round restarts).
  static const String impostorReveal = '/impostor-reveal';

  /// Internal gameplay route used by impostor post-reveal transitions.
  /// Prefer [snakesGame] / [impostorGame] for external navigation.
  static const String gameBoard = '/game-board';
}
