import 'package:flutter/material.dart';

import '../../../../core/routing/game_mode.dart';
import '../../../../core/routing/game_route_resolver.dart';
import '../../../../domain/entities/room_player.dart';
import '../../../../domain/entities/room_session.dart';
import '../../../game_board/ui/screens/game_board_screen.dart';
import 'impostor_reveal_screen.dart';

/// Entry point for El Impostor multiplayer sessions.
///
/// Routes internally to role reveal (fresh start) or gameplay (reconnect).
class ImpostorGameScreen extends StatelessWidget {
  const ImpostorGameScreen({
    super.key,
    required this.room,
    required this.players,
    required this.isAdmin,
    this.isReconnect = false,
    this.persistedGameState,
    this.impostorInfo,
    this.phase,
  });

  final RoomSession room;
  final List<RoomPlayer> players;
  final bool isAdmin;
  final bool isReconnect;
  final Map<String, dynamic>? persistedGameState;
  final Map<String, dynamic>? impostorInfo;

  /// `reveal` = role assignment, `play` = question/voting phase.
  final String? phase;

  static bool hasActiveGameplay(Map<String, dynamic>? state) {
    if (state == null || state.isEmpty) return false;
    return state.containsKey('questionPhase') ||
        state.containsKey('positions') ||
        state['appEventType'] == 'game.start';
  }

  String _resolvePhase() {
    if (phase == 'play') return 'play';
    if (phase == 'reveal') return 'reveal';
    if (isReconnect && hasActiveGameplay(persistedGameState)) {
      debugPrint('[GAME_ROUTER] Reconnect — skipping reveal (active gameplay)');
      return 'play';
    }
    debugPrint('[GAME_ROUTER] Starting impostor reveal phase');
    return 'reveal';
  }

  @override
  Widget build(BuildContext context) {
    final mode = GameRouteResolver.resolveMode(room.gameId);
    assert(
      mode == GameMode.impostor,
      'ImpostorGameScreen opened for non-impostor room (game_id=${room.gameId})',
    );

    if (_resolvePhase() == 'play') {
      return GameBoardScreen(
        room: room,
        players: players,
        isAdmin: isAdmin,
        isReconnect: isReconnect,
        persistedGameState: persistedGameState,
        impostorInfo: impostorInfo,
      );
    }

    return ImpostorRevealScreen(
      room: room,
      players: players,
      isAdmin: isAdmin,
      isReconnect: isReconnect,
      persistedGameState: persistedGameState,
    );
  }
}
