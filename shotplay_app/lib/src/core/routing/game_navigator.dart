import 'package:flutter/material.dart';

import '../../domain/entities/room_player.dart';
import '../../domain/entities/room_session.dart';
import 'app_routes.dart';
import 'game_navigation_args.dart';
import 'game_route_resolver.dart';

/// Pushes the correct game screen for a room using centralized routing.
class GameNavigator {
  GameNavigator._();

  static void pushReplacementGame({
    required BuildContext context,
    required RoomSession room,
    required List<RoomPlayer> players,
    required bool isAdmin,
    bool isReconnect = false,
    Map<String, dynamic>? persistedGameState,
    Map<String, dynamic>? impostorInfo,
    String? impostorPhase,
  }) {
    final resolution = isReconnect
        ? GameRouteResolver.resolveReconnect(room)
        : GameRouteResolver.resolveLobbyStart(room);

    debugPrint('[NAVIGATION] Opening ${resolution.screenLabel}');

    final args = GameNavigationArgs(
      room: room,
      players: players,
      isAdmin: isAdmin,
      isReconnect: isReconnect,
      persistedGameState: persistedGameState,
      impostorInfo: impostorInfo,
      impostorPhase: impostorPhase,
    );

    Navigator.of(context).pushReplacementNamed(
      resolution.routeName,
      arguments: args.toMap(),
    );
  }

  static void pushGame({
    required BuildContext context,
    required RoomSession room,
    required List<RoomPlayer> players,
    required bool isAdmin,
    bool isReconnect = false,
    Map<String, dynamic>? persistedGameState,
    Map<String, dynamic>? impostorInfo,
    String? impostorPhase,
  }) {
    final resolution = isReconnect
        ? GameRouteResolver.resolveReconnect(room)
        : GameRouteResolver.resolveLobbyStart(room);

    debugPrint('[NAVIGATION] Opening ${resolution.screenLabel}');

    final args = GameNavigationArgs(
      room: room,
      players: players,
      isAdmin: isAdmin,
      isReconnect: isReconnect,
      persistedGameState: persistedGameState,
      impostorInfo: impostorInfo,
      impostorPhase: impostorPhase,
    );

    Navigator.of(context).pushNamed(
      resolution.routeName,
      arguments: args.toMap(),
    );
  }

  /// Impostor role reveal → gameplay phase transition.
  static void pushImpostorPlayPhase({
    required BuildContext context,
    required RoomSession room,
    required List<RoomPlayer> players,
    required bool isAdmin,
    bool isReconnect = false,
    Map<String, dynamic>? persistedGameState,
    required Map<String, dynamic> impostorInfo,
  }) {
    debugPrint('[NAVIGATION] Opening ImpostorGameScreen (play phase)');
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.impostorGame,
      arguments: GameNavigationArgs(
        room: room,
        players: players,
        isAdmin: isAdmin,
        isReconnect: isReconnect,
        persistedGameState: persistedGameState,
        impostorInfo: impostorInfo,
        impostorPhase: 'play',
      ).toMap(),
    );
  }
}
