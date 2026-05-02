import 'dart:async';

import '../../domain/entities/room_player.dart';
import '../../domain/entities/room_session.dart';
import '../../domain/repositories/room_repository.dart';

class LocalRoomRepository implements RoomRepository {
  const LocalRoomRepository();

  static final Map<String, RoomSession> _rooms = <String, RoomSession>{};
  static final Map<String, List<RoomPlayer>> _players =
      <String, List<RoomPlayer>>{};
  static final Map<String, StreamController<List<RoomPlayer>>> _controllers =
      <String, StreamController<List<RoomPlayer>>>{};

  @override
  Future<RoomSession> createRoom({
    required String roomCode,
    required String adminId,
    required String gameId,
    required int maxPlayers,
    required bool isPrivate,
    required String roomName,
  }) async {
    if (_rooms.containsKey(roomCode)) {
      throw RoomCodeCollisionException();
    }

    final room = RoomSession(
      roomCode: roomCode,
      adminId: adminId,
      gameId: gameId,
      maxPlayers: maxPlayers,
      status: 'waiting',
      createdAt: DateTime.now().toUtc(),
      roomName: roomName,
      isPrivate: isPrivate,
    );

    _rooms[roomCode] = room;
    _players[roomCode] = <RoomPlayer>[
      RoomPlayer(
        id: '$roomCode-host',
        roomCode: roomCode,
        userId: adminId,
        username: 'Anfitrión',
        isHost: true,
        isReady: true,
      ),
    ];
    _emit(roomCode);

    await Future<void>.delayed(const Duration(milliseconds: 550));
    return room;
  }

  @override
  Stream<List<RoomPlayer>> watchRoomPlayers(String roomCode) {
    final controller = _controllers.putIfAbsent(
      roomCode,
      () => StreamController<List<RoomPlayer>>.broadcast(),
    );

    scheduleMicrotask(() {
      controller.add(List.unmodifiable(_players[roomCode] ?? const []));
    });

    return controller.stream;
  }

  void _emit(String roomCode) {
    final controller = _controllers[roomCode];
    if (controller == null || controller.isClosed) return;
    controller.add(List.unmodifiable(_players[roomCode] ?? const []));
  }
}
