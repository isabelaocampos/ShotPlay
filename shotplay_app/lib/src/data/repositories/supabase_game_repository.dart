import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/game_option.dart';
import '../../domain/repositories/game_repository.dart';

class SupabaseGameRepository implements GameRepository {
  SupabaseGameRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<GameOption>> getAvailableGames() async {
    try {
      final response = await _client
          .from('games')
          .select()
          .eq('is_available', true)
          .order('is_popular', ascending: false);

      final rows = (response as List).cast<Map<String, dynamic>>();
      return rows.map(_mapRowToGameOption).toList(growable: false);
    } on PostgrestException catch (error) {
      throw GameRepositoryException(
        error.message.isNotEmpty
            ? error.message
            : 'No pudimos cargar el catálogo de juegos.',
      );
    } catch (_) {
      throw GameRepositoryException(
        'No pudimos cargar el catálogo de juegos.',
      );
    }
  }

  GameOption _mapRowToGameOption(Map<String, dynamic> row) {
    final id = row['id'] as String;
    final fallback = defaultGameOptions.firstWhere(
      (option) => option.id == id,
      orElse: () => defaultGameOptions.first,
    );

    return GameOption(
      id: id,
      title: (row['name'] as String?) ?? fallback.title,
      subtitle: (row['category'] as String?) ?? fallback.subtitle,
      description: (row['description'] as String?) ?? fallback.description,
      badge: (row['is_popular'] as bool? ?? false) ? 'POPULAR' : fallback.badge,
      minPlayers: (row['min_players'] as num?)?.toInt() ?? fallback.minPlayers,
      maxPlayers: (row['max_players'] as num?)?.toInt() ?? fallback.maxPlayers,
      durationMinutes:
          (row['duration_minutes'] as num?)?.toInt() ?? fallback.durationMinutes,
      icon: fallback.icon,
      accentColor: fallback.accentColor,
      secondaryColor: fallback.secondaryColor,
    );
  }
}
