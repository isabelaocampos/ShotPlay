import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_routes.dart';
import 'domain/entities/game_option.dart';
import 'domain/repositories/room_repository.dart';
import 'features/create_room/presentation/create_room_controller.dart';
import 'features/create_room/presentation/create_room_screen.dart';
import 'features/game_details/presentation/game_details_screen.dart';
import 'features/waiting_room/presentation/waiting_room_screen.dart';
import 'domain/entities/room_session.dart';

class ShotPlayApp extends StatelessWidget {
  const ShotPlayApp({
    super.key,
    required this.roomRepository,
    required this.currentAdminId,
  });

  final RoomRepository roomRepository;
  final String currentAdminId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateRoomController(
        roomRepository: roomRepository,
        currentAdminId: currentAdminId,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ShotPlay',
        theme: ShotPlayTheme.dark,
        initialRoute: AppRoutes.gameDetails,
        routes: <String, WidgetBuilder>{
          AppRoutes.gameDetails: (_) => const GameDetailsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.configureRoom) {
            final game = settings.arguments as GameOption? ?? defaultGameOptions.first;

            return MaterialPageRoute<void>(
              builder: (_) => CreateRoomScreen(selectedGame: game),
            );
          }

          if (settings.name == AppRoutes.waitingRoom) {
            final room = settings.arguments as RoomSession;

            return MaterialPageRoute<void>(
              builder: (_) => WaitingRoomScreen(
                room: room,
                isAdmin: room.adminId == currentAdminId,
              ),
            );
          }

          return null;
        },
      ),
    );
  }
}