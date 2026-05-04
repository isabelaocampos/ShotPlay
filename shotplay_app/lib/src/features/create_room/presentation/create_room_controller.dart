import 'package:flutter/foundation.dart';

import '../../../core/utils/room_code_generator.dart';
import '../../../domain/entities/game_option.dart';
import '../../../domain/entities/room_session.dart';
import '../../../domain/repositories/room_repository.dart';

class CreateRoomController extends ChangeNotifier {
  CreateRoomController({required RoomRepository roomRepository})
      : _roomRepository = roomRepository;

  final RoomRepository _roomRepository;

  GameOption? _selectedGame;
  int _maxPlayers = 6;
  bool _isPrivateRoom = false;
  bool _isFastMode = false;
  bool _isLoading = false;
  String? _errorMessage;
  RoomSession? _createdRoom;
  bool _isInitialized = false;

  List<GameOption> get availableGames => defaultGameOptions;
  GameOption get selectedGame => _selectedGame ?? defaultGameOptions.first;
  int get maxPlayers => _maxPlayers;
  bool get isPrivateRoom => _isPrivateRoom;
  bool get isFastMode => _isFastMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RoomSession? get createdRoom => _createdRoom;

  void initialize(GameOption initialGame) {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;
    _applySelectedGame(initialGame);
  }

  void clearCreatedRoom() {
    _createdRoom = null;
  }

  void clearErrorMessage() {
    _errorMessage = null;
  }

  void selectGame(GameOption game) {
    if (_selectedGame?.gameDbId == game.gameDbId) {
      return;
    }

    _applySelectedGame(game);
  }

  void updateMaxPlayers(int value) {
    final currentGame = selectedGame;
    final clamped = value.clamp(currentGame.minPlayers, currentGame.maxPlayers);
    if (clamped != value) {
      _errorMessage =
          'Para ${currentGame.title}, elige entre ${currentGame.minPlayers} y ${currentGame.maxPlayers} jugadores.';
    }
    _maxPlayers = clamped;
    notifyListeners();
  }

  void updatePrivateRoom(bool value) {
    _isPrivateRoom = value;
    notifyListeners();
  }

  void updateFastMode(bool value) {
    _isFastMode = value;
    notifyListeners();
  }

  Future<RoomSession?> createRoom({required String roomName}) async {
    if (_isLoading) {
      return _createdRoom;
    }

    final sanitizedName = roomName.trim();
    if (sanitizedName.isEmpty) {
      _errorMessage = 'Escribe un nombre para la sala.';
      notifyListeners();
      return null;
    }

    _setLoading(true);

    try {
      for (var attempt = 0; attempt < 5; attempt++) {
        final roomCode = RoomCodeGenerator.generate();

        try {
          final room = await _roomRepository.createRoom(
            roomCode: roomCode,
            gameId: selectedGame.gameDbId,
            maxPlayers: _maxPlayers,
            isPrivate: _isPrivateRoom,
            roomName: sanitizedName,
          );

          _createdRoom = room;
          _errorMessage = null;
          _setLoading(false);
          return room;
        } on RoomCodeCollisionException {
          continue;
        }
      }

      throw RoomRepositoryException('No se pudo generar un código único.');
    } on NotAuthenticatedException {
      _errorMessage = 'Inicia sesión para crear una sala.';
      _setLoading(false);
      return null;
    } on RoomRepositoryException catch (error) {
      _errorMessage = error.message;
      _setLoading(false);
      return null;
    } catch (_) {
      _errorMessage = 'No se pudo crear la sala. Inténtalo de nuevo.';
      _setLoading(false);
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _applySelectedGame(GameOption game) {
    _selectedGame = game;
    _maxPlayers = _maxPlayers.clamp(game.minPlayers, game.maxPlayers);
    notifyListeners();
  }
}
