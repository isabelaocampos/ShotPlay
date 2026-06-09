import 'package:flutter/foundation.dart';
import 'package:shotplay_app/src/domain/repositories/game_event_repository.dart';
import 'package:shotplay_app/src/features/waiting_room/domain/usecases/connect_room_game_events_usecase.dart';

/// Ensures the shared realtime channel is connected before gameplay listeners start.
class EnsureRoomChannelConnectedUsecase {
  const EnsureRoomChannelConnectedUsecase(
    this._connect,
    this._gameEvents,
  );

  final ConnectRoomGameEventsUsecase _connect;
  final GameEventRepository _gameEvents;

  Future<void> execute(String roomCode) async {
    if (_gameEvents.isConnected &&
        _gameEvents.connectedRoomCode == roomCode) {
      debugPrint('[PUBSUB] Already connected to room: $roomCode');
      return;
    }

    debugPrint('[PUBSUB] Connecting to room: $roomCode');
    await _connect.execute(roomCode);

    if (!_gameEvents.isConnected) {
      throw GameEventNotConnectedException();
    }

    debugPrint('[PUBSUB] Connected successfully to room: $roomCode');
  }
}
