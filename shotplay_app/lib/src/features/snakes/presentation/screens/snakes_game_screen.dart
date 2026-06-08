import 'package:flutter/material.dart';

import '../../../../domain/entities/room_player.dart';
import '../../../../domain/entities/room_session.dart';
import '../../../game_board/ui/screens/game_board_screen.dart';

/// Entry point for Escaleras y Serpientes multiplayer sessions.
class SnakesGameScreen extends StatelessWidget {
  const SnakesGameScreen({
    super.key,
    required this.room,
    required this.players,
    required this.isAdmin,
    this.isReconnect = false,
    this.persistedGameState,
  });

  final RoomSession room;
  final List<RoomPlayer> players;
  final bool isAdmin;
  final bool isReconnect;
  final Map<String, dynamic>? persistedGameState;

  @override
  Widget build(BuildContext context) {
    return GameBoardScreen(
      room: room,
      players: players,
      isAdmin: isAdmin,
      isReconnect: isReconnect,
      persistedGameState: persistedGameState,
    );
  }
}
