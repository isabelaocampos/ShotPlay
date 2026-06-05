import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/constants/game_event_types.dart';
import '../../../domain/entities/room_player.dart';
import '../../../domain/entities/room_lifecycle_status.dart';
import '../../../domain/repositories/game_event_repository.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../session/domain/usecases/update_room_status_usecase.dart';
import '../domain/lobby_event_types.dart';
import '../domain/usecases/connect_room_game_events_usecase.dart';
import '../domain/usecases/disconnect_room_game_events_usecase.dart';
import '../domain/usecases/emit_game_start_usecase.dart';
import '../domain/usecases/emit_lobby_sync_usecase.dart';
import '../domain/usecases/fetch_room_players_usecase.dart';
import '../domain/usecases/watch_game_events_usecase.dart';
import '../domain/usecases/watch_room_players_usecase.dart';
import '../domain/usecases/leave_room_usecase.dart';
import '../domain/usecases/close_room_usecase.dart';
import '../domain/usecases/emit_room_closed_usecase.dart';

enum WaitingRoomStatus { initial, loading, waiting, error }

class WaitingRoomController extends ChangeNotifier {
  WaitingRoomController({
    required RoomRepository roomRepository,
    required ConnectRoomGameEventsUsecase connectGameEvents,
    required DisconnectRoomGameEventsUsecase disconnectGameEvents,
    required WatchGameEventsUsecase watchGameEvents,
    required FetchRoomPlayersUsecase fetchRoomPlayers,
    required EmitLobbySyncUsecase emitLobbySync,
    required EmitGameStartUsecase emitGameStart,
    required LeaveRoomUsecase leaveRoom,
    required CloseRoomUsecase closeRoom,
    required EmitRoomClosedUsecase emitRoomClosed,
    required UpdateRoomStatusUsecase updateRoomStatus,
  })  : _watchPlayersUsecase = WatchRoomPlayersUsecase(roomRepository),
        _fetchRoomPlayers = fetchRoomPlayers,
        _connectGameEvents = connectGameEvents,
        _disconnectGameEvents = disconnectGameEvents,
        _watchGameEvents = watchGameEvents,
        _emitLobbySync = emitLobbySync,
        _emitGameStart = emitGameStart,
        _leaveRoom = leaveRoom,
        _closeRoom = closeRoom,
        _emitRoomClosed = emitRoomClosed,
        _updateRoomStatus = updateRoomStatus;

  final WatchRoomPlayersUsecase _watchPlayersUsecase;
  final FetchRoomPlayersUsecase _fetchRoomPlayers;
  final ConnectRoomGameEventsUsecase _connectGameEvents;
  final DisconnectRoomGameEventsUsecase _disconnectGameEvents;
  final WatchGameEventsUsecase _watchGameEvents;
  final EmitLobbySyncUsecase _emitLobbySync;
  final EmitGameStartUsecase _emitGameStart;
  final LeaveRoomUsecase _leaveRoom;
  final CloseRoomUsecase _closeRoom;
  final EmitRoomClosedUsecase _emitRoomClosed;
  final UpdateRoomStatusUsecase _updateRoomStatus;

  StreamSubscription<List<RoomPlayer>>? _playersSubscription;
  StreamSubscription<Map<String, dynamic>>? _eventsSubscription;
  Timer? _refreshDebounce;
  String? _roomCode;
  int? _roomId;

  WaitingRoomStatus _status = WaitingRoomStatus.initial;
  List<RoomPlayer> _players = const <RoomPlayer>[];
  String? _errorMessage;
  bool _gameStarted = false;
  bool _roomClosedByAdmin = false;
  bool _navigatingToBoard = false;

  WaitingRoomStatus get status => _status;
  List<RoomPlayer> get players => _players;
  String? get errorMessage => _errorMessage;
  bool get gameStarted => _gameStarted;
  bool get roomClosedByAdmin => _roomClosedByAdmin;

  // ── Public actions ──────────────────────────────────────────────

  /// Previene que el canal de realtime se desconecte si destruimos
  /// esta pantalla para ir al tablero de juego (reutilizaremos la conexión).
  void markAsNavigatingToBoard() {
    _navigatingToBoard = true;
  }

  /// El admin llama a esto. Emite game.start por el canal Supabase
  /// para que TODOS los jugadores suscritos naveguen al tablero.
  Future<void> emitGameStart() async {
    final roomId = _roomId;
    if (roomId == null) return;

    try {
      await _updateRoomStatus.execute(
        roomId,
        RoomLifecycleStatus.inProgress,
      );
      await _emitGameStart.execute();
      debugPrint('[LOBBY] game.start emitido correctamente');
    } catch (e) {
      debugPrint('[LOBBY] Error emitiendo game.start: $e');
    }
  }

  /// Called by non-admin players to leave the room.
  Future<void> leaveRoom(int roomId) async {
    try {
      _status = WaitingRoomStatus.loading;
      notifyListeners();
      await _leaveRoom.execute(roomId);
    } catch (e) {
      debugPrint('[LOBBY] Error al salir de la sala: $e');
      _errorMessage = 'No pudimos sacarte de la sala.';
      _status = WaitingRoomStatus.error;
      notifyListeners();
      rethrow;
    }
  }

  /// Called by the admin to close the room for everyone.
  Future<void> closeRoom(int roomId) async {
    try {
      _status = WaitingRoomStatus.loading;
      notifyListeners();
      await _emitRoomClosed.execute();
      // Pequeño delay de gracia asegurar propagación por socket
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await _closeRoom.execute(roomId);
      _roomClosedByAdmin = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[LOBBY] Error al cerrar la sala: $e');
      _errorMessage = 'No pudimos cerrar la sala.';
      _status = WaitingRoomStatus.error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> start({
    required String roomCode,
    required int roomId,
    RoomLifecycleStatus roomStatus = RoomLifecycleStatus.waiting,
  }) async {
    _roomCode = roomCode;
    _roomId = roomId;

    if (roomStatus == RoomLifecycleStatus.inProgress) {
      debugPrint('[RECONNECT] Room already in progress — redirecting to board');
      _gameStarted = true;
      notifyListeners();
      return;
    }
    _status = WaitingRoomStatus.loading;
    _errorMessage = null;
    notifyListeners();

    debugPrint('[LOBBY] Starting waiting room for $roomCode');

    await _connectPubSub(roomCode);
    await _refreshPlayers(roomCode);
    _subscribeToPostgresStream(roomCode);

    try {
      await _emitLobbySync.execute();
      debugPrint('[LOBBY] Broadcast lobby.sync for $roomCode');
    } catch (e) {
      debugPrint('[LOBBY] Could not emit lobby.sync: $e');
    }
  }

  Future<void> _connectPubSub(String roomCode) async {
    try {
      debugPrint('[PUBSUB] Connecting to channel for room: $roomCode');
      await _connectGameEvents.execute(roomCode);
      debugPrint('[PUBSUB] Subscription success for room: $roomCode');

      await _eventsSubscription?.cancel();
      _eventsSubscription = _watchGameEvents.execute().listen(
        _onLobbyEvent,
        onError: (Object error) {
          debugPrint('[PUBSUB] Stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('[PUBSUB] Connection failed: $e');
      _errorMessage = 'No pudimos conectar al canal en tiempo real.';
      _status = WaitingRoomStatus.error;
      notifyListeners();
    }
  }

  void _onLobbyEvent(Map<String, dynamic> event) {
    debugPrint('[PUBSUB] Event received: $event');

    final type = event['appEventType'] as String?;

    // El admin inició la partida — todos navegan al tablero
    if (type == GameEventTypes.gameStart) {
      debugPrint('[LOBBY] game.start received — navigating to board');
      _gameStarted = true;
      notifyListeners();
      return;
    }

    if (type == LobbyEventTypes.closed) {
      debugPrint('[LOBBY] lobby.closed received — exiting room');
      _roomClosedByAdmin = true;
      notifyListeners();
      return;
    }

    if (type == GameEventTypes.playerDisconnected ||
        type == GameEventTypes.playerReconnected ||
        type == LobbyEventTypes.sync) {
      final roomCode = _roomCode;
      if (roomCode == null) return;
      debugPrint('[LOBBY] Participant refresh triggered by $type');
      _scheduleRefresh(roomCode);
      return;
    }
  }

  void _subscribeToPostgresStream(String roomCode) {
    _playersSubscription?.cancel();
    _playersSubscription = _watchPlayersUsecase.execute(roomCode).listen(
      (incoming) {
        debugPrint(
          '[PARTICIPANTS] Postgres stream delivered ${incoming.length} player(s)',
        );
        _applyPlayers(incoming);
      },
      onError: (Object error) {
        debugPrint('[PARTICIPANTS] Postgres stream error: $error');
        _errorMessage = 'No pudimos sincronizar los jugadores.';
        _status = WaitingRoomStatus.error;
        notifyListeners();
      },
    );
  }

  void _scheduleRefresh(String roomCode) {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(
      const Duration(milliseconds: 250),
      () => unawaited(_refreshPlayers(roomCode)),
    );
  }

  Future<void> _refreshPlayers(String roomCode) async {
    try {
      debugPrint('[PARTICIPANTS] Refreshing lobby for $roomCode');
      final incoming = await _fetchRoomPlayers.execute(roomCode);
      _applyPlayers(incoming);
    } catch (e) {
      debugPrint('[PARTICIPANTS] Refresh failed: $e');
      _errorMessage = 'No pudimos cargar los jugadores.';
      _status = WaitingRoomStatus.error;
      notifyListeners();
    }
  }

  void _applyPlayers(List<RoomPlayer> incoming) {
    final sorted = <RoomPlayer>[...incoming]..sort((a, b) {
        if (a.isHost != b.isHost) return a.isHost ? -1 : 1;
        return a.username.compareTo(b.username);
      });
    _players = sorted;
    _status = WaitingRoomStatus.waiting;
    debugPrint(
      '[LOBBY] UI updated — ${sorted.length} player(s): '
      '${sorted.map((p) => p.username).join(', ')}',
    );
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('[LOBBY] Disposing waiting room controller');
    _refreshDebounce?.cancel();
    _playersSubscription?.cancel();
    _eventsSubscription?.cancel();
    if (!_navigatingToBoard) {
      debugPrint('[LOBBY] Not navigating to board, disconnecting pubsub');
      unawaited(_disconnectGameEvents.execute());
    } else {
      debugPrint('[LOBBY] Keeping pubsub connection alive for board');
    }
    super.dispose();
  }
}
