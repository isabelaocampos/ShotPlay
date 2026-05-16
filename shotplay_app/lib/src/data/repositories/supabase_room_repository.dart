import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/room_code_constants.dart';
import '../../domain/entities/room_player.dart';
import '../../domain/entities/room_session.dart';
import '../../domain/repositories/room_repository.dart';

class SupabaseRoomRepository implements RoomRepository {
  SupabaseRoomRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<RoomSession> createRoom({
    required String roomCode,
    required int gameId,
    required int maxPlayers,
    required bool isPrivate,
    required String roomName,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw NotAuthenticatedException();
    }
    final adminId = user.id;

    try {
      final response = await _client
          .from('room')
          .insert(<String, dynamic>{
            'room_code': roomCode,
            'admin_id': adminId,
            'game_id': gameId,
            'custom_max_players': maxPlayers,
          })
          .select()
          .single();

      final session = RoomSession(
        idRoom: (response['id_room'] as num).toInt(),
        roomCode: response['room_code'] as String,
        adminId: response['admin_id'] as String,
        gameId: (response['game_id'] as num).toInt(),
        maxPlayers: (response['custom_max_players'] as num?)?.toInt()
            ?? maxPlayers,
        roomName: roomName,
        isPrivate: isPrivate,
      );

      await _client.from('participation').insert(<String, dynamic>{
        'user_id': adminId,
        'room_id': session.idRoom,
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
    }
  }

  @override
  Future<RoomSession> joinRoom({
    required String roomCode,
    int? expectedGameId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw NotAuthenticatedException();
    }

    final normalizedCode = RoomCodeConstants.normalize(roomCode);
    if (!RoomCodeConstants.isValid(normalizedCode)) {
      throw RoomRepositoryException('El código debe tener 6 caracteres.');
    }

    debugPrint('[ROOM] Joining room with code: $normalizedCode');

    try {
      final roomData = await _client
          .from('room')
          .select()
          .eq('room_code', normalizedCode)
          .maybeSingle();

      if (roomData == null) {
        debugPrint('[ROOM] Room not found: $normalizedCode');
        throw RoomNotFoundException();
      }

      final session = RoomSession.fromMap(roomData);

      if (expectedGameId != null && session.gameId != expectedGameId) {
        debugPrint(
          '[ROOM] Game mismatch: expected $expectedGameId, '
          'found ${session.gameId}',
        );
        throw RoomGameMismatchException();
      }

      final existingParticipation = await _client
          .from('participation')
          .select('id_participation')
          .eq('room_id', session.idRoom)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingParticipation != null) {
        debugPrint('[ROOM] User already in room: $normalizedCode');
        return session;
      }

      final activeRows = await _client
          .from('participation')
          .select('id_participation')
          .eq('room_id', session.idRoom);

      final playerCount = (activeRows as List).length;
      if (playerCount >= session.maxPlayers) {
        debugPrint('[ROOM] Room full: $normalizedCode ($playerCount players)');
        throw RoomFullException();
      }

      await _client.from('participation').insert(<String, dynamic>{
        'user_id': user.id,
        'room_id': session.idRoom,
        'status': 'active',
        'joined_at': DateTime.now().toUtc().toIso8601String(),
      });

      debugPrint('[PARTICIPANTS] User joined room $normalizedCode: ${user.id}');
      return session;
    } on RoomNotFoundException {
      rethrow;
    } on RoomFullException {
      rethrow;
    } on RoomGameMismatchException {
      rethrow;
    } on PostgrestException catch (error) {
      throw RoomRepositoryException(
        error.message.isNotEmpty
            ? error.message
            : 'No se pudo unir a la sala.',
      );
    }
  }

  @override
  Future<List<RoomPlayer>> fetchRoomPlayers(String roomCode) async {
    final normalizedCode = RoomCodeConstants.normalize(roomCode);
    final roomData = await _client
        .from('room')
        .select('id_room, admin_id')
        .eq('room_code', normalizedCode)
        .single();

    final roomId = (roomData['id_room'] as num).toInt();
    final adminId = roomData['admin_id'] as String;

    final players = await _loadPlayersForRoom(
      roomId: roomId,
      adminId: adminId,
      roomCode: normalizedCode,
    );

    debugPrint(
      '[PARTICIPANTS] Fetched ${players.length} player(s) for $normalizedCode',
    );
    return players;
  }

  @override
  Stream<List<RoomPlayer>> watchRoomPlayers(String roomCode) async* {
    final normalizedCode = RoomCodeConstants.normalize(roomCode);
    final roomData = await _client
        .from('room')
        .select('id_room, admin_id')
        .eq('room_code', normalizedCode)
        .single();

    final roomId = (roomData['id_room'] as num).toInt();
    final adminId = roomData['admin_id'] as String;

    debugPrint('[PARTICIPANTS] Postgres stream subscribed for room $normalizedCode');

    yield* _client
        .from('participation')
        .stream(primaryKey: <String>['id_participation'])
        .eq('room_id', roomId)
        .asyncMap((rows) async {
          debugPrint(
            '[PARTICIPANTS] Postgres stream event: ${rows.length} row(s)',
          );
          return _loadPlayersFromParticipationRows(
            rows: rows,
            adminId: adminId,
            roomCode: normalizedCode,
          );
        });
  }

  Future<List<RoomPlayer>> _loadPlayersForRoom({
    required int roomId,
    required String adminId,
    required String roomCode,
  }) async {
    final rows = await _client
        .from('participation')
        .select('id_participation, user_id, status')
        .eq('room_id', roomId);

    return _loadPlayersFromParticipationRows(
      rows: (rows as List).cast<Map<String, dynamic>>(),
      adminId: adminId,
      roomCode: roomCode,
    );
  }

  Future<List<RoomPlayer>> _loadPlayersFromParticipationRows({
    required List<Map<String, dynamic>> rows,
    required String adminId,
    required String roomCode,
  }) async {
    if (rows.isEmpty) return <RoomPlayer>[];

    final userIds = rows
        .map((row) => row['user_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    final usernameOf = await _resolveUsernames(userIds);

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
  }

  Future<Map<String, String>> _resolveUsernames(List<String> userIds) async {
    if (userIds.isEmpty) return <String, String>{};

    try {
      final profileRows = await _client
          .from('profiles')
          .select('id, username')
          .inFilter('id', userIds);

      final resolved = <String, String>{
        for (final profile
            in (profileRows as List).cast<Map<String, dynamic>>())
          profile['id'] as String: (profile['username'] as String?) ?? 'Jugador',
      };

      if (resolved.length < userIds.length) {
        debugPrint(
          '[PARTICIPANTS] Partial profile visibility: '
          '${resolved.length}/${userIds.length} — check profiles RLS policy',
        );
      }

      return resolved;
    } catch (e) {
      debugPrint('[PARTICIPANTS] Profile batch fetch failed: $e');
      return <String, String>{};
    }
  }
}
