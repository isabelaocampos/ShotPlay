import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/navigation/main_screen.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/ui/screens/welcome_screen.dart';
import 'features/login/ui/bloc/login_bloc.dart';
import 'features/login/ui/screens/login_screen.dart';
import 'features/signup/ui/bloc/signup_bloc.dart';
import 'features/signup/ui/screens/signup_screen.dart';

/// Root widget of the application.
///
/// Owns the [MaterialApp] configuration: theme, initial route, and the
/// route map. Business-logic providers (BLoCs) are scoped to their
/// corresponding route so that they are only alive while the screen is
/// visible, keeping memory usage minimal.
class ShotPlayApp extends StatelessWidget {
  const ShotPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      },
    );
  }
}
