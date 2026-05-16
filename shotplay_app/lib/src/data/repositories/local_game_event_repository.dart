import 'dart:async';

import '../../domain/repositories/game_event_repository.dart';

/// In-memory pub/sub for local development when Supabase is not configured.
class LocalGameEventRepository implements GameEventRepository {
  LocalGameEventRepository();

  static final Map<String, StreamController<Map<String, dynamic>>> _hubs =
      <String, StreamController<Map<String, dynamic>>>{};

  String? _connectedRoomCode;
  StreamController<Map<String, dynamic>>? _eventController;

  @override
  Future<void> connect(String roomCode) async {
    if (_connectedRoomCode == roomCode && _eventController != null) {
      return;
    }

    await disconnect();

    _connectedRoomCode = roomCode;
    _eventController = _hubs.putIfAbsent(
      roomCode,
      () => StreamController<Map<String, dynamic>>.broadcast(),
    );
  }

  @override
  Future<void> emitEvent(Map<String, dynamic> event) async {
    if (_connectedRoomCode == null || _eventController == null) {
      throw GameEventNotConnectedException();
    }

    final hub = _hubs[_connectedRoomCode];
    if (hub == null || hub.isClosed) {
      throw GameEventNotConnectedException();
    }

    hub.add(Map<String, dynamic>.from(event));
  }

  @override
  Stream<Map<String, dynamic>> listenToEvents() {
    final controller = _eventController;
    if (controller == null || _connectedRoomCode == null) {
      throw GameEventNotConnectedException();
    }
    return controller.stream;
  }

  @override
  Future<void> disconnect() async {
    final roomCode = _connectedRoomCode;
    _connectedRoomCode = null;
    _eventController = null;

    if (roomCode == null) return;

    final hub = _hubs.remove(roomCode);
    await hub?.close();
  }
}
