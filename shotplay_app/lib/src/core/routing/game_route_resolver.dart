import 'package:flutter/foundation.dart';

import '../../domain/entities/game_option.dart';
import '../../domain/entities/room_entry_destination.dart';
import '../../domain/entities/room_session.dart';
import 'app_routes.dart';
import 'game_mode.dart';

/// Result of resolving which route/screen a room should open.
class GameRouteResolution {
  const GameRouteResolution({
    required this.mode,
    required this.routeName,
    required this.destination,
  });

  final GameMode mode;
  final String routeName;
  final RoomEntryDestination destination;

  String get screenLabel => mode.screenLabel;
}

/// Central routing for multiplayer game modes.
///
/// All navigation decisions based on [RoomSession.gameId] should go through
/// this resolver — never scatter `if (game == …)` across UI widgets.
class GameRouteResolver {
  GameRouteResolver._();

  static const Map<int, GameMode> _dbIdToMode = <int, GameMode>{
    1: GameMode.snakesLadders,
    2: GameMode.impostor,
  };

  /// Resolves [gameId] to a [GameMode], logging mismatches.
  static GameMode resolveMode(int gameId) {
    final mode = _dbIdToMode[gameId];
    if (mode != null) {
      debugPrint('[GAME_MODE] Resolved: ${mode.catalogId} (game_id=$gameId)');
      return mode;
    }

    final fromCatalog = _tryCatalogLookup(gameId);
    if (fromCatalog != null) {
      debugPrint(
        '[GAME_MODE] Resolved via catalog: ${fromCatalog.catalogId} '
        '(game_id=$gameId)',
      );
      return fromCatalog;
    }

    debugPrint(
      '[GAME_MODE] Unknown game_id=$gameId — defaulting to snakes_ladders. '
      'Verify room.game_id matches catalog gameDbId values.',
    );
    return GameMode.snakesLadders;
  }

  static GameMode? _tryCatalogLookup(int gameId) {
    for (final game in defaultGameOptions) {
      if (game.gameDbId == gameId) {
        switch (game.id) {
          case 'snakes_ladders':
            return GameMode.snakesLadders;
          case 'impostor':
            return GameMode.impostor;
        }
      }
    }
    return null;
  }

  /// Lobby → active game (waiting room start, game.start event).
  static GameRouteResolution resolveLobbyStart(RoomSession room) {
    debugPrint('[GAME_ROUTER] Resolving game screen for lobby start');
    return _resolve(room, context: 'lobby');
  }

  /// Reconnect / enter-code when room is already in progress.
  static GameRouteResolution resolveReconnect(RoomSession room) {
    debugPrint('[GAME_ROUTER] Resolving game screen for reconnect');
    return _resolve(room, context: 'reconnect');
  }

  /// Maps an in-progress room to [RoomEntryDestination] for join results.
  static RoomEntryDestination activeGameDestination(RoomSession room) {
    return resolveReconnect(room).destination;
  }

  static GameRouteResolution _resolve(
    RoomSession room, {
    required String context,
  }) {
    final mode = resolveMode(room.gameId);

    switch (mode) {
      case GameMode.snakesLadders:
        debugPrint(
          '[GAME_ROUTER] $context → ${mode.screenLabel} '
          '(route=${AppRoutes.snakesGame})',
        );
        return const GameRouteResolution(
          mode: GameMode.snakesLadders,
          routeName: AppRoutes.snakesGame,
          destination: RoomEntryDestination.snakesGame,
        );
      case GameMode.impostor:
        debugPrint(
          '[GAME_ROUTER] $context → ${mode.screenLabel} '
          '(route=${AppRoutes.impostorGame})',
        );
        return const GameRouteResolution(
          mode: GameMode.impostor,
          routeName: AppRoutes.impostorGame,
          destination: RoomEntryDestination.impostorGame,
        );
      case GameMode.unknown:
        debugPrint('[GAME_ROUTER] $context → fallback SnakesGameScreen');
        return const GameRouteResolution(
          mode: GameMode.snakesLadders,
          routeName: AppRoutes.snakesGame,
          destination: RoomEntryDestination.snakesGame,
        );
    }
  }
}
