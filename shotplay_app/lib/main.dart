import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shotplay_app/src/core/navigation/main_screen.dart';
import 'package:shotplay_app/src/features/auth/ui/screens/welcome_screen.dart';
import 'package:shotplay_app/src/features/login/ui/bloc/login_bloc.dart';
import 'package:shotplay_app/src/features/login/ui/screens/login_screen.dart';
import 'package:shotplay_app/src/features/signup/ui/bloc/signup_bloc.dart';
import 'package:shotplay_app/src/features/signup/ui/screens/signup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String kSupabaseUrl = 'https://zpwpbqmhzdhtuvblznog.supabase.co';
const String kSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpwd3BicW1oemRodHV2Ymx6bm9nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxODM3NjAsImV4cCI6MjA5Mjc1OTc2MH0.bYbFjLA3X4udwn70qmjibyLP8VOA0TdAl46XoXgLQUU';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: kSupabaseUrl,
    anonKey: kSupabaseAnonKey,
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
