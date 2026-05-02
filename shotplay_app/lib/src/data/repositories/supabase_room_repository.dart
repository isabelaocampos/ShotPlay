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
      final response = await _client.from('rooms').insert(<String, dynamic>{
        'room_code': roomCode,
        'admin_id': adminId,
        'game_id': gameId,
        'max_players': maxPlayers,
        'status': 'waiting',
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'room_name': roomName,
        'is_private': isPrivate,
      }).select().single();

      final session = RoomSession.fromMap(response);

      await _client.from('room_players').insert(<String, dynamic>{
        'room_code': roomCode,
        'user_id': adminId,
        'username': _resolveCurrentUsername(adminId),
        'is_host': true,
        'is_ready': true,
      });

      return session;
    } on PostgrestException catch (error) {
      final isDuplicate = error.code == '23505' ||
          error.message.toLowerCase().contains('duplicate');

      if (isDuplicate) {
        throw RoomCodeCollisionException();
      }

      throw RoomRepositoryException(
        error.message.isNotEmpty ? error.message : 'No se pudo crear la sala.',
      );
    } catch (error) {
      throw RoomRepositoryException('No se pudo crear la sala.');
    }
  }

  @override
  Stream<List<RoomPlayer>> watchRoomPlayers(String roomCode) {
    return _client
        .from('room_players')
        .stream(primaryKey: <String>['id'])
        .eq('room_code', roomCode)
        .map((rows) => rows.map(RoomPlayer.fromMap).toList(growable: false));
  }

  String _resolveCurrentUsername(String adminId) {
    final user = _client.auth.currentUser;
    final metadataName = user?.userMetadata?['username'] as String?;
    if (metadataName != null && metadataName.isNotEmpty) return metadataName;

    final email = user?.email;
    if (email != null && email.contains('@')) return email.split('@').first;

    return 'Anfitrión';
  }
}
