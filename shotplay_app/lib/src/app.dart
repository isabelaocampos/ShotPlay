import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/navigation/main_screen.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'domain/entities/game_option.dart';
import 'domain/entities/room_session.dart';
import 'domain/repositories/game_repository.dart';
import 'domain/repositories/room_repository.dart';
import 'features/auth/data/repository/auth_repo_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/signup_usecase.dart';
import 'features/auth/ui/screens/welcome_screen.dart';
import 'features/create_room/presentation/create_room_controller.dart';
import 'features/create_room/presentation/create_room_screen.dart';
import 'features/game_catalog/presentation/game_catalog_controller.dart';
import 'features/game_details/presentation/game_details_screen.dart';
import 'features/login/ui/bloc/login_bloc.dart';
import 'features/login/ui/screens/login_screen.dart';
import 'features/profile/data/repository/profile_repository_impl.dart';
import 'features/profile/domain/repository/profile_repository.dart';
import 'features/signup/ui/bloc/signup_bloc.dart';
import 'features/signup/ui/screens/signup_screen.dart';
import 'features/waiting_room/presentation/waiting_room_screen.dart';

class ShotPlayApp extends StatelessWidget {
  const ShotPlayApp({
    super.key,
    required this.roomRepository,
    required this.gameRepository,
  });

  final RoomRepository roomRepository;
  final GameRepository gameRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<RoomRepository>.value(value: roomRepository),
        Provider<ProfileRepository>(create: (_) => ProfileRepositoryImpl()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ShotPlay',
        theme: AppTheme.dark,
        initialRoute: AppRoutes.welcome,
        routes: {
          AppRoutes.welcome: (_) => const WelcomeScreen(),
          AppRoutes.login: (_) => BlocProvider(
                create: (_) => LoginBloc(
                  LoginUsecase(AuthRepoImpl()),
                ),
                child: LoginScreen(),
              ),
          AppRoutes.signup: (_) => BlocProvider(
                create: (_) => SignupBloc(
                  SignupUsecase(AuthRepoImpl(), ProfileRepositoryImpl()),
                ),
                child: const SignupScreen(),
              ),
          AppRoutes.home: (_) => ChangeNotifierProvider(
                create: (_) =>
                    GameCatalogController(gameRepository: gameRepository),
                child: const MainScreen(),
              ),
          AppRoutes.gameCatalog: (_) => ChangeNotifierProvider(
                create: (_) =>
                    GameCatalogController(gameRepository: gameRepository),
                child: const MainScreen(),
              ),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.gameDetails:
              final game = settings.arguments as GameOption;
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => GameDetailsScreen(initialGame: game),
              );
            case AppRoutes.configureRoom:
              final game = settings.arguments as GameOption;
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => ChangeNotifierProvider(
                  create: (_) =>
                      CreateRoomController(roomRepository: roomRepository),
                  child: CreateRoomScreen(selectedGame: game),
                ),
              );
            case AppRoutes.waitingRoom:
              final room = settings.arguments as RoomSession;
              final currentUserId =
                  Supabase.instance.client.auth.currentUser?.id;
              final isAdmin =
                  currentUserId != null && currentUserId == room.adminId;
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => WaitingRoomScreen(room: room, isAdmin: isAdmin),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
