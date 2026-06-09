import 'dart:async';



import 'package:flutter/foundation.dart';



import '../../../core/constants/game_event_types.dart';

import '../../../core/routing/game_mode.dart';

import '../../../core/routing/game_route_resolver.dart';

import '../../../domain/entities/lobby_settings.dart';

import '../../../domain/entities/room_player.dart';

import '../../../domain/entities/room_lifecycle_status.dart';

import '../../../domain/lobby/lobby_settings_validator.dart';

import '../../../domain/repositories/room_repository.dart';

import '../../session/domain/usecases/update_room_status_usecase.dart';

import '../domain/lobby_event_types.dart';

import '../domain/usecases/connect_room_game_events_usecase.dart';

import '../domain/usecases/disconnect_room_game_events_usecase.dart';

import '../domain/usecases/emit_game_start_usecase.dart';

import '../domain/usecases/emit_lobby_settings_updated_usecase.dart';

import '../domain/usecases/emit_lobby_sync_usecase.dart';

import '../domain/usecases/fetch_lobby_settings_usecase.dart';

import '../domain/usecases/fetch_room_players_usecase.dart';

import '../domain/usecases/update_lobby_settings_usecase.dart';

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

    required FetchLobbySettingsUsecase fetchLobbySettings,

    required UpdateLobbySettingsUsecase updateLobbySettings,

    required EmitLobbySyncUsecase emitLobbySync,

    required EmitLobbySettingsUpdatedUsecase emitLobbySettingsUpdated,

    required EmitGameStartUsecase emitGameStart,

    required LeaveRoomUsecase leaveRoom,

    required CloseRoomUsecase closeRoom,

    required EmitRoomClosedUsecase emitRoomClosed,

    required UpdateRoomStatusUsecase updateRoomStatus,

  })  : _watchPlayersUsecase = WatchRoomPlayersUsecase(roomRepository),

        _fetchRoomPlayers = fetchRoomPlayers,

        _fetchLobbySettings = fetchLobbySettings,

        _updateLobbySettings = updateLobbySettings,

        _connectGameEvents = connectGameEvents,

        _disconnectGameEvents = disconnectGameEvents,

        _watchGameEvents = watchGameEvents,

        _emitLobbySync = emitLobbySync,

        _emitLobbySettingsUpdated = emitLobbySettingsUpdated,

        _emitGameStart = emitGameStart,

        _leaveRoom = leaveRoom,

        _closeRoom = closeRoom,

        _emitRoomClosed = emitRoomClosed,

        _updateRoomStatus = updateRoomStatus;



  final WatchRoomPlayersUsecase _watchPlayersUsecase;

  final FetchRoomPlayersUsecase _fetchRoomPlayers;

  final FetchLobbySettingsUsecase _fetchLobbySettings;

  final UpdateLobbySettingsUsecase _updateLobbySettings;

  final ConnectRoomGameEventsUsecase _connectGameEvents;

  final DisconnectRoomGameEventsUsecase _disconnectGameEvents;

  final WatchGameEventsUsecase _watchGameEvents;

  final EmitLobbySyncUsecase _emitLobbySync;

  final EmitLobbySettingsUpdatedUsecase _emitLobbySettingsUpdated;

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

  int? _gameId;



  WaitingRoomStatus _status = WaitingRoomStatus.initial;

  List<RoomPlayer> _players = const <RoomPlayer>[];

  LobbySettings _lobbySettings = LobbySettings.empty;

  String? _errorMessage;

  String? _settingsError;

  bool _isUpdatingSettings = false;

  bool _gameStarted = false;

  bool _roomClosedByAdmin = false;

  bool _navigatingToBoard = false;



  WaitingRoomStatus get status => _status;

  List<RoomPlayer> get players => _players;

  LobbySettings get lobbySettings => _lobbySettings;

  String? get errorMessage => _errorMessage;

  String? get settingsError => _settingsError;

  bool get isUpdatingSettings => _isUpdatingSettings;

  bool get gameStarted => _gameStarted;

  bool get roomClosedByAdmin => _roomClosedByAdmin;



  GameMode get gameMode =>

      GameRouteResolver.resolveMode(_gameId ?? 0);



  bool get canStartGame =>

      _players.length >= 2 && _validateSettingsForStart() == null;



  // ── Public actions ──────────────────────────────────────────────



  void markAsNavigatingToBoard() {

    _navigatingToBoard = true;

  }



  /// Host updates impostor count. Persists to DB and broadcasts to lobby.

  Future<bool> updateImpostorCount(int count) async {

    final roomId = _roomId;

    if (roomId == null || gameMode != GameMode.impostor) return false;



    final validationError = LobbySettingsValidator.validateImpostorCount(

      impostorCount: count,

      playerCount: _players.length,

    );

    if (validationError != null) {

      _settingsError = validationError;

      notifyListeners();

      return false;

    }



    _isUpdatingSettings = true;

    _settingsError = null;

    notifyListeners();



    try {

      final updated = _lobbySettings.withImpostorCount(count);

      await _updateLobbySettings.execute(roomId, updated);

      _lobbySettings = updated;

      await _emitLobbySettingsUpdated.execute(updated);



      debugPrint('[LOBBY_SETTINGS] Host changed impostor count: $count');

      debugPrint('[IMPOSTOR] Lobby impostor count set to $count');

      debugPrint('[ROOM_SYNC] Settings synchronized successfully');

      return true;

    } catch (e) {

      debugPrint('[LOBBY_SETTINGS] Update failed: $e');

      _settingsError = 'No pudimos guardar la configuración.';

      return false;

    } finally {

      _isUpdatingSettings = false;

      notifyListeners();

    }

  }



  Future<void> emitGameStart() async {

    final roomId = _roomId;

    if (roomId == null) return;



    final validationError = _validateSettingsForStart();

    if (validationError != null) {

      _settingsError = validationError;

      debugPrint('[LOBBY_SETTINGS] Cannot start — $validationError');

      notifyListeners();

      return;

    }



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



  Future<void> closeRoom(int roomId) async {

    try {

      _status = WaitingRoomStatus.loading;

      notifyListeners();

      await _emitRoomClosed.execute();

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

    required int gameId,

    LobbySettings initialSettings = LobbySettings.empty,

    RoomLifecycleStatus roomStatus = RoomLifecycleStatus.waiting,

  }) async {

    _roomCode = roomCode;

    _roomId = roomId;

    _gameId = gameId;

    _lobbySettings = initialSettings;



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

    await _refreshLobbySettings();

    _subscribeToPostgresStream(roomCode);



    try {

      await _emitLobbySync.execute();

      debugPrint('[LOBBY] Broadcast lobby.sync for $roomCode');

    } catch (e) {

      debugPrint('[LOBBY] Could not emit lobby.sync: $e');

    }

  }



  String? _validateSettingsForStart() {

    if (gameMode != GameMode.impostor) return null;



    return LobbySettingsValidator.validateImpostorCount(

      impostorCount: _lobbySettings.impostor.impostorCount,

      playerCount: _players.length,

    );

  }



  void _clampImpostorCountIfNeeded() {

    if (gameMode != GameMode.impostor) return;



    final maxCount = LobbySettingsValidator.maxImpostorCount(_players.length);

    if (maxCount < ImpostorLobbySettings.minImpostorCount) return;



    final current = _lobbySettings.impostor.impostorCount;

    if (current <= maxCount) return;



    _lobbySettings = _lobbySettings.withImpostorCount(maxCount);

    debugPrint(

      '[LOBBY_SETTINGS] Clamped impostor count to $maxCount '

      '(player count changed)',

    );

  }



  Future<void> _refreshLobbySettings() async {

    final roomId = _roomId;

    if (roomId == null) return;



    try {

      _lobbySettings = await _fetchLobbySettings.execute(roomId);

      _clampImpostorCountIfNeeded();

      debugPrint(

        '[ROOM_SYNC] Settings loaded — '

        'impostors=${_lobbySettings.impostor.impostorCount}',

      );

      notifyListeners();

    } catch (e) {

      debugPrint('[ROOM_SYNC] Failed to load lobby settings: $e');

    }

  }



  void _applyLobbySettings(Map<String, dynamic> payload) {

    _lobbySettings = LobbySettings.fromJson(payload);

    _clampImpostorCountIfNeeded();

    _settingsError = _validateSettingsForStart();

    debugPrint(

      '[ROOM_SYNC] Settings synchronized successfully — '

      'impostors=${_lobbySettings.impostor.impostorCount}',

    );

    notifyListeners();

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



    if (type == LobbyEventTypes.settingsUpdated) {

      final payload = event['payload'];

      if (payload is Map<String, dynamic>) {

        _applyLobbySettings(payload);

      } else {

        unawaited(_refreshLobbySettings());

      }

      return;

    }



    if (type == GameEventTypes.playerDisconnected ||

        type == GameEventTypes.playerReconnected ||

        type == LobbyEventTypes.sync) {

      final roomCode = _roomCode;

      if (roomCode == null) return;

      debugPrint('[LOBBY] Participant refresh triggered by $type');

      _scheduleRefresh(roomCode);

      if (type == GameEventTypes.playerReconnected ||
          type == LobbyEventTypes.sync) {
        unawaited(_refreshLobbySettings());
      }

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

    _clampImpostorCountIfNeeded();

    _settingsError = _validateSettingsForStart();

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

