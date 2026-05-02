import 'package:go_router/go_router.dart';

import '../../features/games/domain/entities/game.dart';
import '../../features/games/domain/entities/game_room.dart';
import '../../features/games/presentation/screens/configure_game_screen.dart';
import '../../features/games/presentation/screens/game_catalog_screen.dart';
import '../../features/games/presentation/screens/game_detail_screen.dart';
import '../../features/games/presentation/screens/waiting_room_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'catalog',
      builder: (context, state) => const GameCatalogScreen(),
    ),
    GoRoute(
      path: '/games/:id',
      name: 'gameDetail',
      builder: (context, state) {
        final game = state.extra as Game;
        return GameDetailScreen(game: game);
      },
    ),
    GoRoute(
      path: '/games/:id/configure',
      name: 'configureGame',
      builder: (context, state) {
        final game = state.extra as Game;
        return ConfigureGameScreen(game: game);
      },
    ),
    GoRoute(
      path: '/rooms/:roomId',
      name: 'waitingRoom',
      builder: (context, state) {
        final room = state.extra as GameRoom;
        return WaitingRoomScreen(room: room);
      },
    ),
  ],
);
