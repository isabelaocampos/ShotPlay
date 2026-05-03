import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'core/navigation/main_screen.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'domain/entities/game_option.dart';
import 'domain/entities/room_session.dart';
import 'domain/repositories/game_repository.dart';
import 'domain/repositories/room_repository.dart';
import 'features/auth/ui/screens/welcome_screen.dart';
import 'features/create_room/presentation/create_room_controller.dart';
import 'features/create_room/presentation/create_room_screen.dart';
import 'features/game_catalog/presentation/game_catalog_controller.dart';
import 'features/game_catalog/presentation/game_catalog_screen.dart';
import 'features/game_details/presentation/game_details_screen.dart';
import 'features/login/ui/bloc/login_bloc.dart';
import 'features/login/ui/screens/login_screen.dart';
import 'features/signup/ui/bloc/signup_bloc.dart';
import 'features/signup/ui/screens/signup_screen.dart';
import 'features/waiting_room/presentation/waiting_room_screen.dart';

class ShotPlayApp extends StatelessWidget {
  const ShotPlayApp({
    super.key,
    required this.roomRepository,
    required this.gameRepository,
    required this.currentAdminId,
  });

  final RoomRepository roomRepository;
  final GameRepository gameRepository;
  final String currentAdminId;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<RoomRepository>.value(value: roomRepository),
        Provider<GameRepository>.value(value: gameRepository),
        ChangeNotifierProvider<GameCatalogController>(
          create: (_) => GameCatalogController(gameRepository: gameRepository),
        ),
        ChangeNotifierProvider<CreateRoomController>(
          create: (_) => CreateRoomController(
            roomRepository: roomRepository,
            currentAdminId: currentAdminId,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ShotPlay',
        theme: AppTheme.dark,
        initialRoute: AppRoutes.welcome,
        routes: {
          AppRoutes.welcome: (_) => const WelcomeScreen(),
          AppRoutes.login: (_) => BlocProvider(
                create: (_) => LoginBloc(),
                child: LoginScreen(),
              ),
          AppRoutes.signup: (_) => BlocProvider(
                create: (_) => SignupBloc(),
                child: const SignupScreen(),
              ),
          AppRoutes.home: (_) => const MainScreen(),
          AppRoutes.gameCatalog: (_) => const GameCatalogScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.gameDetails) {
            final game = settings.arguments as GameOption?;
            return MaterialPageRoute<void>(
              builder: (_) => GameDetailsScreen(initialGame: game),
            );
          }

          if (settings.name == AppRoutes.configureRoom) {
            final game =
                settings.arguments as GameOption? ?? defaultGameOptions.first;
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
