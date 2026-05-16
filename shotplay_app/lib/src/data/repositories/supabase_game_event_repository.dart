import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/game_event_repository.dart';

/// Transport-only broadcast envelope name. Game event types live in the payload.
const String _kEnvelopeEvent = 'envelope';

const Duration _kSubscribeTimeout = Duration(seconds: 10);

class SupabaseGameEventRepository implements GameEventRepository {
  SupabaseGameEventRepository(this._client);

  final SupabaseClient _client;

  RealtimeChannel? _channel;
  StreamController<Map<String, dynamic>>? _eventController;
  String? _connectedRoomCode;

  @override
  Future<void> connect(String roomCode) async {
    if (_connectedRoomCode == roomCode && _channel != null) {
      return;
    }

    await disconnect();

    debugPrint('[PUBSUB] Connecting to channel room:$roomCode');
    final controller = StreamController<Map<String, dynamic>>.broadcast();
    final subscribeCompleter = Completer<void>();

    final channel = _client.channel(
      'room:$roomCode',
      opts: const RealtimeChannelConfig(self: true),
    );

    channel
        .onBroadcast(
          event: _kEnvelopeEvent,
          callback: (payload) {
            if (controller.isClosed) return;
            debugPrint('[PUBSUB] Event received: $payload');
            controller.add(Map<String, dynamic>.from(payload));
          },
        )
        .subscribe((status, error) {
          switch (status) {
            case RealtimeSubscribeStatus.subscribed:
              if (!subscribeCompleter.isCompleted) {
                subscribeCompleter.complete();
              }
            case RealtimeSubscribeStatus.channelError:
            case RealtimeSubscribeStatus.timedOut:
              if (!subscribeCompleter.isCompleted) {
                subscribeCompleter.completeError(
                  GameEventRepositoryException(
                    error?.toString() ??
                        'No se pudo suscribir al canal de la sala.',
                  ),
                );
              }
            case RealtimeSubscribeStatus.closed:
              break;
          }
        });

    try {
      await subscribeCompleter.future.timeout(
        _kSubscribeTimeout,
        onTimeout: () => throw GameEventRepositoryException(
          'Tiempo de espera agotado al conectar al canal de la sala.',
        ),
      );
    } catch (e) {
      await _client.removeChannel(channel);
      await controller.close();
      rethrow;
    }

    _channel = channel;
    _eventController = controller;
    _connectedRoomCode = roomCode;
    debugPrint('[PUBSUB] Subscription success for room:$roomCode');
  }

  @override
  Future<void> emitEvent(Map<String, dynamic> event) async {
    final channel = _channel;
    if (channel == null || _connectedRoomCode == null) {
      throw GameEventNotConnectedException();
    }

    try {
      await channel.sendBroadcastMessage(
        event: _kEnvelopeEvent,
        payload: event,
      );
    } catch (e) {
      throw GameEventRepositoryException(
        'No se pudo enviar el evento: $e',
      );
    }
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
    debugPrint('[PUBSUB] Disconnecting from room: $_connectedRoomCode');
    final channel = _channel;
    final controller = _eventController;

    _channel = null;
    _eventController = null;
    _connectedRoomCode = null;

    if (channel != null) {
      await _client.removeChannel(channel);
    }
    await controller?.close();
  }
}
