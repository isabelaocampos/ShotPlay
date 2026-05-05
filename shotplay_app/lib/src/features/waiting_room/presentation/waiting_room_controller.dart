import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../domain/entities/room_player.dart';
import '../../../domain/repositories/room_repository.dart';
import '../domain/usecases/watch_room_players_usecase.dart';

enum WaitingRoomStatus { initial, loading, waiting, error }

class WaitingRoomController extends ChangeNotifier {
  WaitingRoomController({required RoomRepository roomRepository})
      : _watchPlayersUsecase = WatchRoomPlayersUsecase(roomRepository);

  final WatchRoomPlayersUsecase _watchPlayersUsecase;
  StreamSubscription<List<RoomPlayer>>? _subscription;

  WaitingRoomStatus _status = WaitingRoomStatus.initial;
  List<RoomPlayer> _players = const <RoomPlayer>[];
  String? _errorMessage;

  WaitingRoomStatus get status => _status;
  List<RoomPlayer> get players => _players;
  String? get errorMessage => _errorMessage;

  void watchPlayers(String roomCode) {
    _status = WaitingRoomStatus.loading;
    _errorMessage = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _watchPlayersUsecase.execute(roomCode).listen(
      (incoming) {
        final sorted = <RoomPlayer>[...incoming]..sort((a, b) {
            if (a.isHost != b.isHost) return a.isHost ? -1 : 1;
            return a.username.compareTo(b.username);
          });
        _players = sorted;
        _status = WaitingRoomStatus.waiting;
        notifyListeners();
      },
      onError: (_) {
        _errorMessage = 'No pudimos sincronizar los jugadores.';
        _status = WaitingRoomStatus.error;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
