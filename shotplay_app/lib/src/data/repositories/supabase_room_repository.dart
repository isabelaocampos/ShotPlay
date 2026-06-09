import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/room_code_constants.dart';
import '../../domain/constants/participation_statuses.dart';
import '../../core/routing/game_route_resolver.dart';
import '../../domain/entities/lobby_settings.dart';
import '../../domain/entities/room_entry_destination.dart';
import '../../domain/entities/room_entry_result.dart';
import '../../domain/entities/room_lifecycle_status.dart';
import '../../domain/entities/room_player.dart';
import '../../domain/entities/room_session.dart';
import '../../domain/repositories/game_session_repository.dart';
import '../../domain/repositories/room_repository.dart';

class SupabaseRoomRepository implements RoomRepository {
  SupabaseRoomRepository(this._client, this._gameSession);

  final SupabaseClient _client;
  final GameSessionRepository _gameSession;

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

    final initialSettings = LobbySettings.forGame(gameId);

    try {
      final response = await _client
          .from('room')
          .insert(<String, dynamic>{
            'room_code': roomCode,
            'admin_id': adminId,
            'game_id': gameId,
            'custom_max_players': maxPlayers,
            'status': RoomLifecycleStatus.waiting.toDb(),
            'lobby_settings': initialSettings.toJson(),
          })
          .select()
          .single();

      final persistedGameId = (response['game_id'] as num).toInt();
      debugPrint(
        '[ROOM] Created ${response['room_code']} game_id=$persistedGameId',
      );

      final session = RoomSession(
        idRoom: (response['id_room'] as num).toInt(),
        roomCode: response['room_code'] as String,
        adminId: response['admin_id'] as String,
        gameId: persistedGameId,
        maxPlayers: (response['custom_max_players'] as num?)?.toInt()
            ?? maxPlayers,
        roomName: roomName,
        isPrivate: isPrivate,
        status: RoomLifecycleStatus.fromDb(response['status'] as String?),
        lobbySettings: LobbySettings.fromJson(
          response['lobby_settings'] as Map<String, dynamic>?,
        ),
      );

      await _client.from('participation').insert(<String, dynamic>{
        'user_id': adminId,
        'room_id': session.idRoom,
        'status': ParticipationStatuses.active,
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
  Future<RoomEntryResult> enterRoom({
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

    debugPrint('[RECONNECT] Entering room: $normalizedCode');

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
        throw RoomGameMismatchException();
      }

      if (session.status == RoomLifecycleStatus.finished) {
        throw RoomFinishedException();
      }

      var isReconnect = false;

      final existingParticipation = await _client
          .from('participation')
          .select('id_participation, status')
          .eq('room_id', session.idRoom)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingParticipation != null) {
        isReconnect = true;
        final previousStatus = existingParticipation['status'] as String?;
        debugPrint(
          '[RECONNECT] Existing participation found (status=$previousStatus)',
        );

        await _client
            .from('participation')
            .update(<String, dynamic>{
              'status': ParticipationStatuses.active,
              'joined_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('room_id', session.idRoom)
            .eq('user_id', user.id);
      } else {
        final rows = await _client
            .from('participation')
            .select('status')
            .eq('room_id', session.idRoom);

        final occupied = (rows as List).where((row) {
          final status = row['status'] as String?;
          return ParticipationStatuses.occupiesSlot(status);
        }).length;

        if (occupied >= session.maxPlayers) {
          throw RoomFullException();
        }

        await _client.from('participation').insert(<String, dynamic>{
          'user_id': user.id,
          'room_id': session.idRoom,
          'status': ParticipationStatuses.active,
          'joined_at': DateTime.now().toUtc().toIso8601String(),
        });

        debugPrint('[PARTICIPANTS] New participant joined $normalizedCode');
      }

      final players = await fetchRoomPlayers(normalizedCode);
      final persistedGameState = session.status == RoomLifecycleStatus.inProgress
          ? await _gameSession.fetchState(session.idRoom)
          : null;

      final destination = _resolveDestination(
        session: session,
        isReconnect: isReconnect,
      );

      debugPrint(
        '[RECONNECT] Destination=$destination reconnect=$isReconnect '
        'players=${players.length}',
      );

      return RoomEntryResult(
        room: session,
        destination: destination,
        players: players,
        isReconnect: isReconnect,
        persistedGameState: persistedGameState,
      );
    } on RoomNotFoundException {
      rethrow;
    } on RoomFullException {
      rethrow;
    } on RoomGameMismatchException {
      rethrow;
    } on RoomFinishedException {
      rethrow;
    } on PostgrestException catch (error) {
      throw RoomRepositoryException(
        error.message.isNotEmpty
            ? error.message
            : 'No se pudo unir a la sala.',
      );
    }
  }

  RoomEntryDestination _resolveDestination({
    required RoomSession session,
    required bool isReconnect,
  }) {
    switch (session.status) {
      case RoomLifecycleStatus.waiting:
        return RoomEntryDestination.waitingRoom;
      case RoomLifecycleStatus.inProgress:
        return GameRouteResolver.activeGameDestination(session);
      case RoomLifecycleStatus.finished:
        return RoomEntryDestination.roomFinished;
    }
  }

  @override
  Future<void> leaveRoom(int roomId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw NotAuthenticatedException();

    try {
      await _client
          .from('participation')
          .update(<String, dynamic>{'status': ParticipationStatuses.left})
          .eq('room_id', roomId)
          .eq('user_id', user.id);
      debugPrint('[ROOM] User ${user.id} left room $roomId');
    } catch (error) {
      throw RoomRepositoryException('No se pudo salir de la sala: $error');
    }
  }

  @override
  Future<void> closeRoom(int roomId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw NotAuthenticatedException();

    try {
      await _client.from('room').delete().eq('id_room', roomId);
      debugPrint('[ROOM] User ${user.id} closed room $roomId');
    } catch (error) {
      throw RoomRepositoryException('No se pudo cerrar la sala: $error');
    }
  }

  @override
  Future<void> updateRoomStatus(int roomId, RoomLifecycleStatus status) async {
    try {
      await _client.from('room').update(<String, dynamic>{
        'status': status.toDb(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id_room', roomId);
      debugPrint('[ROOM] Status updated to ${status.toDb()} for room $roomId');
    } catch (e) {
      throw RoomRepositoryException('No se pudo actualizar el estado: $e');
    }
  }

  @override
  Future<void> markParticipationActive(int roomId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      await _client
          .from('participation')
          .update(<String, dynamic>{'status': ParticipationStatuses.active})
          .eq('room_id', roomId)
          .eq('user_id', user.id);
      debugPrint('[LIFECYCLE] Marked active in room $roomId');
    } catch (e) {
      debugPrint('[LIFECYCLE] markParticipationActive failed: $e');
    }
  }

  @override
  Future<void> markParticipationDisconnected(int roomId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      await _client
          .from('participation')
          .update(<String, dynamic>{
            'status': ParticipationStatuses.disconnected,
          })
          .eq('room_id', roomId)
          .eq('user_id', user.id)
          .neq('status', ParticipationStatuses.left);
      debugPrint('[LIFECYCLE] Marked disconnected in room $roomId');
    } catch (e) {
      debugPrint('[LIFECYCLE] markParticipationDisconnected failed: $e');
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

    debugPrint(
      '[PARTICIPANTS] Postgres stream subscribed for room $normalizedCode',
    );

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
        .eq('room_id', roomId)
        .neq('status', ParticipationStatuses.left);

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
      final status = row['status'] as String? ?? ParticipationStatuses.active;
      return RoomPlayer(
        id: row['id_participation']?.toString() ?? '',
        roomCode: roomCode,
        userId: userId,
        username: usernameOf[userId] ?? 'Jugador',
        isHost: userId == adminId,
        isReady: status == ParticipationStatuses.active,
        avatarUrl: _resolveAvatarUrl(row),
        participationStatus: status,
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
          '${resolved.length}/${userIds.length}',
        );
      }

      return resolved;
    } catch (e) {
      debugPrint('[PARTICIPANTS] Profile batch fetch failed: $e');
      return <String, String>{};
    }
  }

  @override
  Future<LobbySettings> fetchLobbySettings(int roomId) async {
    try {
      final row = await _client
          .from('room')
          .select('lobby_settings')
          .eq('id_room', roomId)
          .maybeSingle();

      if (row == null) {
        return LobbySettings.empty;
      }

      return LobbySettings.fromJson(
        row['lobby_settings'] as Map<String, dynamic>?,
      );
    } on PostgrestException catch (error) {
      throw RoomRepositoryException(
        error.message.isNotEmpty
            ? error.message
            : 'No se pudieron cargar los ajustes del lobby.',
      );
    }
  }

  @override
  Future<void> updateLobbySettings(int roomId, LobbySettings settings) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw NotAuthenticatedException();
    }

    try {
      await _client
          .from('room')
          .update(<String, dynamic>{
            'lobby_settings': settings.toJson(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id_room', roomId)
          .eq('admin_id', user.id)
          .eq('status', RoomLifecycleStatus.waiting.toDb());

      debugPrint('[ROOM] Lobby settings updated for room $roomId');
    } on PostgrestException catch (error) {
      throw RoomRepositoryException(
        error.message.isNotEmpty
            ? error.message
            : 'No se pudieron guardar los ajustes del lobby.',
      );
    }
  }

  String? _resolveAvatarUrl(Map<String, dynamic> row) {
    for (final key in const [
      'avatar_url',
      'image_url',
      'photo_url',
      'profile_image_url',
      'avatar',
      'picture',
      'image',
    ]) {
      final value = row[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}
