import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/constants/room_code_constants.dart';
import '../../domain/entities/room_player.dart';
import '../../domain/entities/room_session.dart';
import '../../domain/repositories/room_repository.dart';

class LocalRoomRepository implements RoomRepository {
  const LocalRoomRepository();

  static int _nextRoomId = 1;
  static final Map<String, RoomSession> _rooms = <String, RoomSession>{};
  static final Map<String, List<RoomPlayer>> _players =
      <String, List<RoomPlayer>>{};
  static final Map<String, StreamController<List<RoomPlayer>>> _controllers =
      <String, StreamController<List<RoomPlayer>>>{};

  @override
  Future<RoomSession> createRoom({
    required String roomCode,
    required int gameId,
    required int maxPlayers,
    required bool isPrivate,
    required String roomName,
  }) async {
    final normalizedCode = RoomCodeConstants.normalize(roomCode);

    if (_rooms.containsKey(normalizedCode)) {
      throw RoomCodeCollisionException();
    }

    final localAdminId = 'local-admin-$normalizedCode';

    final room = RoomSession(
      idRoom: _nextRoomId++,
      roomCode: normalizedCode,
      adminId: localAdminId,
      gameId: gameId,
      maxPlayers: maxPlayers,
      roomName: roomName,
      isPrivate: isPrivate,
    );

    _rooms[normalizedCode] = room;
    _players[normalizedCode] = <RoomPlayer>[
      RoomPlayer(
        id: '$normalizedCode-host',
        roomCode: normalizedCode,
        userId: localAdminId,
        username: 'Anfitrión',
        isHost: true,
        isReady: true,
      ),
    ];
    _emit(normalizedCode);

    await Future<void>.delayed(const Duration(milliseconds: 550));
    return room;
  }

  @override
  Future<RoomSession> joinRoom({
    required String roomCode,
    int? expectedGameId,
  }) async {
    final normalizedCode = RoomCodeConstants.normalize(roomCode);
    if (!RoomCodeConstants.isValid(normalizedCode)) {
      throw RoomRepositoryException('El código debe tener 6 caracteres.');
    }

    final room = _rooms[normalizedCode];
    if (room == null) {
      debugPrint('[ROOM] Room not found (local): $normalizedCode');
      throw RoomNotFoundException();
    }

    if (expectedGameId != null && room.gameId != expectedGameId) {
      throw RoomGameMismatchException();
    }

    final players = _players.putIfAbsent(normalizedCode, () => <RoomPlayer>[]);
    const joinerId = 'local-guest';
    final alreadyJoined =
        players.any((player) => player.userId == joinerId);

    if (alreadyJoined) {
      debugPrint('[ROOM] User already in room (local): $normalizedCode');
      return room;
    }

    if (players.length >= room.maxPlayers) {
      debugPrint('[ROOM] Room full (local): $normalizedCode');
      throw RoomFullException();
    }

    players.add(
      RoomPlayer(
        id: '$normalizedCode-$joinerId',
        roomCode: normalizedCode,
        userId: joinerId,
        username: 'Invitado',
        isHost: false,
        isReady: true,
      ),
    );
    _emit(normalizedCode);

    debugPrint('[ROOM] Joined room successfully (local): $normalizedCode');
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return room;
  }

  @override
  Future<List<RoomPlayer>> fetchRoomPlayers(String roomCode) async {
    final normalizedCode = RoomCodeConstants.normalize(roomCode);
    final players = _players[normalizedCode] ?? const <RoomPlayer>[];
    debugPrint(
      '[PARTICIPANTS] Fetched ${players.length} player(s) (local) for $normalizedCode',
    );
    return List<RoomPlayer>.unmodifiable(players);
  }

  @override
  Stream<List<RoomPlayer>> watchRoomPlayers(String roomCode) {
    final normalizedCode = RoomCodeConstants.normalize(roomCode);
    final controller = _controllers.putIfAbsent(
      normalizedCode,
      () => StreamController<List<RoomPlayer>>.broadcast(),
    );

    scheduleMicrotask(() {
      controller.add(
        List<RoomPlayer>.unmodifiable(
          _players[normalizedCode] ?? const <RoomPlayer>[],
        ),
      );
    });

    return controller.stream;
  }

  @override
  Future<void> leaveRoom(int roomId) async {
    final entry = _rooms.entries.where((e) => e.value.idRoom == roomId).firstOrNull;
    if (entry == null) return;
    
    final normalizedCode = entry.key;
    final players = _players[normalizedCode] ?? [];
    
    // Simulate current user leaving (removing the guest)
    players.removeWhere((p) => p.userId == 'local-guest');
    _emit(normalizedCode);
  }

  @override
  Future<void> closeRoom(int roomId) async {
    final entry = _rooms.entries.where((e) => e.value.idRoom == roomId).firstOrNull;
    if (entry == null) return;
    
    final normalizedCode = entry.key;
    _rooms.remove(normalizedCode);
    _players.remove(normalizedCode);
    _controllers[normalizedCode]?.close();
    _controllers.remove(normalizedCode);
  }

  void _emit(String roomCode) {
    final normalizedCode = RoomCodeConstants.normalize(roomCode);
    final controller = _controllers[normalizedCode];
    if (controller == null || controller.isClosed) return;
    final snapshot = List<RoomPlayer>.unmodifiable(
      _players[normalizedCode] ?? const <RoomPlayer>[],
    );
    debugPrint(
      '[PARTICIPANTS] Local stream emit: ${snapshot.length} player(s)',
    );
    controller.add(snapshot);
  }
}
