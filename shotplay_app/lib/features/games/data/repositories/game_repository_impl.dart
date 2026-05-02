import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/game.dart';
import '../../domain/entities/game_room.dart';
import '../../domain/entities/room_player.dart';
import '../../domain/repositories/game_repository.dart';
import '../models/game_model.dart';
import '../models/game_room_model.dart';
import '../models/room_player_model.dart';

class GameRepositoryImpl implements GameRepository {
  final SupabaseClient _supabase;

  GameRepositoryImpl(this._supabase);

  @override
  Future<List<Game>> getAvailableGames() async {
    final response = await _supabase
        .from('games')
        .select()
        .eq('is_available', true)
        .order('is_popular', ascending: false);
    return (response as List)
        .map((json) => GameModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GameRoom> createRoom({
    required String gameId,
    required String roomName,
    required int maxPlayers,
    required bool isPrivate,
    required bool hintsEnabled,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const _UnauthenticatedException();
    }

    final roomCode = await _generateUniqueRoomCode();
    final inserted = await _supabase
        .from('game_rooms')
        .insert({
          'game_id': gameId,
          'room_name': roomName,
          'room_code': roomCode,
          'host_user_id': user.id,
          'max_players': maxPlayers,
          'current_players': 1,
          'is_private': isPrivate,
          'hints_enabled': hintsEnabled,
          'status': 'waiting',
        })
        .select()
        .single();
    final room = GameRoomModel.fromJson(inserted);

    final username = (user.userMetadata?['username'] as String?) ??
        user.email?.split('@').first ??
        'Anfitrión';

    await _supabase.from('room_players').insert({
      'room_id': room.id,
      'user_id': user.id,
      'username': username,
      'is_host': true,
      'is_ready': true,
    });

    return room;
  }

  @override
  Future<bool> validatePlayerCount({
    required String gameId,
    required int playerCount,
  }) async {
    final game = await _supabase
        .from('games')
        .select('min_players, max_players')
        .eq('id', gameId)
        .single();
    final min = (game['min_players'] as num).toInt();
    final max = (game['max_players'] as num).toInt();
    return playerCount >= min && playerCount <= max;
  }

  @override
  Stream<List<RoomPlayer>> watchRoomPlayers(String roomId) {
    return _supabase
        .from('room_players')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .map((data) => data
            .map((json) => RoomPlayerModel.fromJson(json))
            .toList());
  }

  Future<String> _generateUniqueRoomCode() async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    for (var attempt = 0; attempt < 10; attempt++) {
      final code = List.generate(
        6,
        (_) => chars[rng.nextInt(chars.length)],
      ).join();
      final existing = await _supabase
          .from('game_rooms')
          .select('id')
          .eq('room_code', code)
          .maybeSingle();
      if (existing == null) return code;
    }
    throw Exception('No se pudo generar un código de sala único.');
  }
}

class _UnauthenticatedException implements Exception {
  const _UnauthenticatedException();

  @override
  String toString() => 'Debes iniciar sesión para crear una sala.';
}
