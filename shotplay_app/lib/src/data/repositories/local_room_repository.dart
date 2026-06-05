import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/constants/room_code_constants.dart';
import '../../domain/constants/participation_statuses.dart';
import '../../domain/entities/room_entry_destination.dart';
import '../../domain/entities/room_entry_result.dart';
import '../../domain/entities/room_lifecycle_status.dart';
import '../../domain/entities/room_player.dart';
import '../../domain/entities/room_session.dart';
import '../../domain/repositories/game_session_repository.dart';
import '../../domain/repositories/room_repository.dart';

class LocalRoomRepository implements RoomRepository {
  LocalRoomRepository(this._gameSession);

  final GameSessionRepository _gameSession;

  static int _nextRoomId = 1;
  static final Map<String, RoomSession> _rooms = <String, RoomSession>{};
  static final Map<String, List<RoomPlayer>> _players =
      <String, List<RoomPlayer>>{};
  static final Map<String, StreamController<List<RoomPlayer>>> _controllers =
      <String, StreamController<List<RoomPlayer>>>{};
  static final Map<int, RoomLifecycleStatus> _roomStatuses =
      <int, RoomLifecycleStatus>{};

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

    const localAdminId = 'local-admin';
    final idRoom = _nextRoomId++;

    final room = RoomSession(
      idRoom: idRoom,
      roomCode: normalizedCode,
      adminId: localAdminId,
      gameId: gameId,
      maxPlayers: maxPlayers,
      roomName: roomName,
      isPrivate: isPrivate,
      status: RoomLifecycleStatus.waiting,
    );

    _rooms[normalizedCode] = room;
    _roomStatuses[idRoom] = RoomLifecycleStatus.waiting;
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
  Future<RoomEntryResult> enterRoom({
    required String roomCode,
    int? expectedGameId,
  }) async {
    final normalizedCode = RoomCodeConstants.normalize(roomCode);
    if (!RoomCodeConstants.isValid(normalizedCode)) {
      throw RoomRepositoryException('El código debe tener 6 caracteres.');
    }

    final room = _rooms[normalizedCode];
    if (room == null) {
      throw RoomNotFoundException();
    }

    if (expectedGameId != null && room.gameId != expectedGameId) {
      throw RoomGameMismatchException();
    }

    final status = _roomStatuses[room.idRoom] ?? RoomLifecycleStatus.waiting;
    if (status == RoomLifecycleStatus.finished) {
      throw RoomFinishedException();
    }

    const joinerId = 'local-guest';
    final players = _players.putIfAbsent(normalizedCode, () => <RoomPlayer>[]);
    var isReconnect = false;

    final existingIndex =
        players.indexWhere((player) => player.userId == joinerId);

    if (existingIndex >= 0) {
      isReconnect = true;
      final existing = players[existingIndex];
      players[existingIndex] = RoomPlayer(
        id: existing.id,
        roomCode: existing.roomCode,
        userId: existing.userId,
        username: existing.username,
        isHost: existing.isHost,
        isReady: true,
        participationStatus: ParticipationStatuses.active,
      );
    } else {
      if (players.length >= room.maxPlayers) {
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
    }

    _emit(normalizedCode);

    final session = RoomSession(
      idRoom: room.idRoom,
      roomCode: room.roomCode,
      adminId: room.adminId,
      gameId: room.gameId,
      maxPlayers: room.maxPlayers,
      roomName: room.roomName,
      isPrivate: room.isPrivate,
      status: status,
    );

    final persisted = status == RoomLifecycleStatus.inProgress
        ? await _gameSession.fetchState(room.idRoom)
        : null;

    return RoomEntryResult(
      room: session,
      destination: status == RoomLifecycleStatus.inProgress
          ? RoomEntryDestination.gameBoard
          : RoomEntryDestination.waitingRoom,
      players: List<RoomPlayer>.unmodifiable(players),
      isReconnect: isReconnect,
      persistedGameState: persisted,
    );
  }

  @override
  Future<List<RoomPlayer>> fetchRoomPlayers(String roomCode) async {
    final normalizedCode = RoomCodeConstants.normalize(roomCode);
    final players = _players[normalizedCode] ?? const <RoomPlayer>[];
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
    for (final entry in _players.entries) {
      final room = _rooms[entry.key];
      if (room?.idRoom != roomId) continue;

      entry.value.removeWhere((p) => p.userId == 'local-guest');
      _emit(entry.key);
      return;
    }
  }

  @override
  Future<void> closeRoom(int roomId) async {
    final entry =
        _rooms.entries.where((e) => e.value.idRoom == roomId).firstOrNull;
    if (entry == null) return;

    final normalizedCode = entry.key;
    _rooms.remove(normalizedCode);
    _players.remove(normalizedCode);
    _roomStatuses.remove(roomId);
    await _controllers[normalizedCode]?.close();
    _controllers.remove(normalizedCode);
  }

  @override
  Future<void> updateRoomStatus(int roomId, RoomLifecycleStatus status) async {
    _roomStatuses[roomId] = status;
    for (final entry in _rooms.entries) {
      if (entry.value.idRoom == roomId) {
        _rooms[entry.key] = RoomSession(
          idRoom: entry.value.idRoom,
          roomCode: entry.value.roomCode,
          adminId: entry.value.adminId,
          gameId: entry.value.gameId,
          maxPlayers: entry.value.maxPlayers,
          roomName: entry.value.roomName,
          isPrivate: entry.value.isPrivate,
          status: status,
        );
        break;
      }
    }
    debugPrint('[ROOM] Status updated (local) to ${status.toDb()}');
  }

  @override
  Future<void> markParticipationActive(int roomId) async {
    _updateGuestStatus(roomId, ParticipationStatuses.active);
  }

  @override
  Future<void> markParticipationDisconnected(int roomId) async {
    _updateGuestStatus(roomId, ParticipationStatuses.disconnected);
  }

  void _updateGuestStatus(int roomId, String status) {
    for (final entry in _players.entries) {
      final room = _rooms[entry.key];
      if (room?.idRoom != roomId) continue;

      final index = entry.value.indexWhere((p) => p.userId == 'local-guest');
      if (index < 0) return;

      final player = entry.value[index];
      entry.value[index] = RoomPlayer(
        id: player.id,
        roomCode: player.roomCode,
        userId: player.userId,
        username: player.username,
        isHost: player.isHost,
        isReady: status == ParticipationStatuses.active,
        participationStatus: status,
      );
      _emit(entry.key);
      return;
    }
  }

  void _emit(String roomCode) {
    final normalizedCode = RoomCodeConstants.normalize(roomCode);
    final controller = _controllers[normalizedCode];
    if (controller == null || controller.isClosed) return;
    controller.add(
      List<RoomPlayer>.unmodifiable(
        _players[normalizedCode] ?? const <RoomPlayer>[],
      ),
    );
  }
}
