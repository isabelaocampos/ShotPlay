import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/game_option.dart';
import '../../domain/repositories/game_repository.dart';

class SupabaseGameRepository implements GameRepository {
  SupabaseGameRepository(this._client);

  // ignore: unused_field
  final SupabaseClient _client;

  /// The available game catalog is defined statically in the app.
  /// There is no 'games' table in the schema — game types are identified
  /// by the integer 'game_id' (int4) column in the 'room' table, which
  /// must match GameOption.gameDbId.
  @override
  Future<List<GameOption>> getAvailableGames() async {
    return defaultGameOptions;
  }
}
