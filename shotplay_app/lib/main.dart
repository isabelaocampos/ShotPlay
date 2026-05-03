import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';
import 'src/data/repositories/local_game_repository.dart';
import 'src/data/repositories/local_room_repository.dart';
import 'src/data/repositories/supabase_game_repository.dart';
import 'src/data/repositories/supabase_room_repository.dart';
import 'src/domain/repositories/game_repository.dart';
import 'src/domain/repositories/room_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Silence font-download failures when the device/emulator is offline.
  // google_fonts falls back to system fonts automatically.
  GoogleFonts.config.allowRuntimeFetching = true;
  FlutterError.onError = (details) {
    final msg = details.exception.toString();
    if (msg.contains('fonts.gstatic.com') || msg.contains('Failed host lookup')) {
      return;
    }
    FlutterError.presentError(details);
  };

  // Load .env when bundled as an asset (dev / CI). Ignored if not present.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Not bundled — fall back to --dart-define values below.
  }

  final dependencies = await _buildAppDependencies();

  runZonedGuarded(
    () => runApp(
      ShotPlayApp(
        roomRepository: dependencies.roomRepository,
        gameRepository: dependencies.gameRepository,
        currentAdminId: dependencies.currentAdminId,
      ),
    ),
    (error, stack) {
      final msg = error.toString();
      if (msg.contains('fonts.gstatic.com') || msg.contains('Failed host lookup')) {
        return;
      }
      // ignore: avoid_print
      print('Uncaught error: $error\n$stack');
    },
  );
}

Future<_AppDependencies> _buildAppDependencies() async {
  // Prefer .env file; fall back to compile-time --dart-define.
  final supabaseUrl = dotenv.env['SUPABASE_URL']?.isNotEmpty == true
      ? dotenv.env['SUPABASE_URL']!
      : const String.fromEnvironment('SUPABASE_URL');
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']?.isNotEmpty == true
      ? dotenv.env['SUPABASE_ANON_KEY']!
      : const String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    final client = Supabase.instance.client;

    return _AppDependencies(
      roomRepository: SupabaseRoomRepository(client),
      gameRepository: SupabaseGameRepository(client),
      currentAdminId: client.auth.currentUser?.id ?? 'demo-admin',
    );
  }

  return const _AppDependencies(
    roomRepository: LocalRoomRepository(),
    gameRepository: LocalGameRepository(),
    currentAdminId: 'demo-admin',
  );
}

class _AppDependencies {
  const _AppDependencies({
    required this.roomRepository,
    required this.gameRepository,
    required this.currentAdminId,
  });

  final RoomRepository roomRepository;
  final GameRepository gameRepository;
  final String currentAdminId;
}
