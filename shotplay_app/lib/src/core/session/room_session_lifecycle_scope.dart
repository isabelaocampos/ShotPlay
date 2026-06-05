import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/repositories/game_event_repository.dart';
import '../../domain/repositories/room_repository.dart';
import '../constants/game_event_types.dart';

/// Observes app lifecycle for the active multiplayer room and updates
/// participation status without coupling UI widgets to Supabase details.
class RoomSessionLifecycleScope extends StatefulWidget {
  const RoomSessionLifecycleScope({
    super.key,
    required this.roomId,
    required this.roomCode,
    required this.child,
  });

  final int roomId;
  final String roomCode;
  final Widget child;

  @override
  State<RoomSessionLifecycleScope> createState() =>
      _RoomSessionLifecycleScopeState();
}

class _RoomSessionLifecycleScopeState extends State<RoomSessionLifecycleScope>
    with WidgetsBindingObserver {
  RoomRepository? _roomRepository;
  GameEventRepository? _gameEvents;
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint(
      '[LIFECYCLE] Scope started for room ${widget.roomCode}',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _roomRepository = context.read<RoomRepository>();
    _gameEvents = context.read<GameEventRepository>();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_lastLifecycleState == state) return;
    _lastLifecycleState = state;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        unawaited(_handleDisconnect());
      case AppLifecycleState.resumed:
        unawaited(_handleReconnect());
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> _handleDisconnect() async {
    final repo = _roomRepository;
    if (repo == null) return;

    debugPrint('[LIFECYCLE] Disconnect detected for ${widget.roomCode}');
    await repo.markParticipationDisconnected(widget.roomId);

    try {
      await _gameEvents?.emitEvent(<String, dynamic>{
        'appEventType': GameEventTypes.playerDisconnected,
        'payload': <String, dynamic>{'roomCode': widget.roomCode},
      });
    } catch (e) {
      debugPrint('[PUBSUB] playerDisconnected emit failed: $e');
    }
  }

  Future<void> _handleReconnect() async {
    final repo = _roomRepository;
    if (repo == null) return;

    debugPrint('[RECONNECT] App resumed for ${widget.roomCode}');
    await repo.markParticipationActive(widget.roomId);

    try {
      await _gameEvents?.connect(widget.roomCode);
      await _gameEvents?.emitEvent(<String, dynamic>{
        'appEventType': GameEventTypes.playerReconnected,
        'payload': <String, dynamic>{'roomCode': widget.roomCode},
      });
      await _gameEvents?.emitEvent(<String, dynamic>{
        'appEventType': GameEventTypes.lobbySync,
        'payload': <String, dynamic>{},
      });
    } catch (e) {
      debugPrint('[RECONNECT] Resume handshake failed: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('[LIFECYCLE] Scope disposed for ${widget.roomCode}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
