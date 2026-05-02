import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';
import 'src/data/repositories/local_room_repository.dart';
import 'src/data/repositories/supabase_room_repository.dart';
import 'src/domain/repositories/room_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = await _buildAppDependencies();
  runApp(
    ShotPlayApp(
      roomRepository: dependencies.roomRepository,
      currentAdminId: dependencies.currentAdminId,
    ),
  );
}

Future<_AppDependencies> _buildAppDependencies() async {
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

    return _AppDependencies(
      roomRepository: SupabaseRoomRepository(Supabase.instance.client),
      currentAdminId:
          Supabase.instance.client.auth.currentUser?.id ?? 'demo-admin',
    );
  }

  return const _AppDependencies(
    roomRepository: LocalRoomRepository(),
    currentAdminId: 'demo-admin',
  );
}

class _AppDependencies {
  const _AppDependencies({
    required this.roomRepository,
    required this.currentAdminId,
  });

  final RoomRepository roomRepository;
  final String currentAdminId;
}
