import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/room_player.dart';
import '../../domain/entities/room_session.dart';
import '../../domain/repositories/room_repository.dart';

class SupabaseRoomRepository implements RoomRepository {
  SupabaseRoomRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<RoomSession> createRoom({
    required String roomCode,
    required String adminId,
    required String gameId,
    required int maxPlayers,
    required bool isPrivate,
    required String roomName,
  }) async {
    try {
      // Only insert columns that exist in the actual schema:
      // id_room, room_code, admin_id, game_id, custom_max_players
      // Missing from schema: status, created_at, room_name, is_private
      final response = await _client.from('room').insert(<String, dynamic>{
        'room_code': roomCode,
        'admin_id': adminId,
        'game_id': gameId,
        'custom_max_players': maxPlayers,
      }).select().single();

      final session = RoomSession.fromMap(response);

      // id_room is int4 — use the raw response value directly to avoid
      // String→int round-trip issues when inserting into participation.
      final roomId = response['id_room'];

      await _client.from('participation').insert(<String, dynamic>{
        'user_id': adminId,
        'room_id': roomId,
        'status': 'active',
        'joined_at': DateTime.now().toUtc().toIso8601String(),
      });

      return session;
    } on PostgrestException catch (error) {
      final isDuplicate = error.code == '23505' ||
          error.message.toLowerCase().contains('duplicate');

      if (isDuplicate) throw RoomCodeCollisionException();

      throw RoomRepositoryException(
        error.message.isNotEmpty ? error.message : 'No se pudo crear la sala.',
      );
    } catch (_) {
      throw RoomRepositoryException('No se pudo crear la sala.');
    }
  }

  @override
  Stream<List<RoomPlayer>> watchRoomPlayers(String roomCode) async* {
    final roomData = await _client
        .from('room')
        .select('id_room, admin_id')
        .eq('room_code', roomCode)
        .single();

    // id_room is int4 — convert to String for comparison later
    final roomId = roomData['id_room'];
    final adminId = roomData['admin_id'] as String;

    yield* _client
        .from('participation')
        .stream(primaryKey: <String>['id_participation'])
        .eq('room_id', roomId)
        .asyncMap((rows) async {
          if (rows.isEmpty) return <RoomPlayer>[];

          final userIds =
              rows.map((r) => r['user_id'] as String).toList();

          final profileRows = await _client
              .from('profiles')
              .select('id, username')
              .inFilter('id', userIds);

          final usernameOf = <String, String>{
            for (final p
                in (profileRows as List).cast<Map<String, dynamic>>())
              p['id'] as String: (p['username'] as String?) ?? 'Jugador',
          };

          return rows.map((row) {
            final userId = (row['user_id'] as String?) ?? '';
            return RoomPlayer(
              id: row['id_participation']?.toString() ?? '',
              roomCode: roomCode,
              userId: userId,
              username: usernameOf[userId] ?? 'Jugador',
              isHost: userId == adminId,
              isReady: (row['status'] as String?) == 'active',
            );
          }).toList();
        });
  }
}
