import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';
import 'src/core/config/env.dart';

/// Application entry point.
///
/// Responsibilities here are intentionally narrow: initialize external
/// services (environment variables, Supabase) and hand control to
/// [ShotPlayApp]. Routing, theming, and DI live in [ShotPlayApp].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(const ShotPlayApp());
}
