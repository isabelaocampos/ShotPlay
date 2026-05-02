import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shotplay_app/src/core/navigation/main_screen.dart';
import 'package:shotplay_app/src/core/config/env.dart';
import 'package:shotplay_app/src/features/auth/ui/screens/welcome_screen.dart';
import 'package:shotplay_app/src/features/login/ui/bloc/login_bloc.dart';
import 'package:shotplay_app/src/features/login/ui/screens/login_screen.dart';
import 'package:shotplay_app/src/features/signup/ui/bloc/signup_bloc.dart';
import 'package:shotplay_app/src/features/signup/ui/screens/signup_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) =>
            BlocProvider(create: (_) => LoginBloc(), child: LoginScreen()),
        '/signup': (_) =>
            BlocProvider(create: (_) => SignupBloc(), child: SignupScreen()),
        '/home': (_) => const MainScreen(),
      },
    );
  }
}
