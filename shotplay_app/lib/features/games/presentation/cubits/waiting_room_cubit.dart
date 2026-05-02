import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/room_player.dart';
import '../../domain/repositories/game_repository.dart';

part 'waiting_room_state.dart';

class WaitingRoomCubit extends Cubit<WaitingRoomState> {
  final GameRepository _repository;
  StreamSubscription<List<RoomPlayer>>? _subscription;

  WaitingRoomCubit(this._repository) : super(const WaitingRoomState.initial());

  void watchPlayers(String roomId) {
    emit(state.copyWith(status: WaitingRoomStatus.loading));
    _subscription?.cancel();
    _subscription = _repository.watchRoomPlayers(roomId).listen(
      (players) {
        final sorted = [...players]
          ..sort((a, b) {
            if (a.isHost != b.isHost) return a.isHost ? -1 : 1;
            return a.username.compareTo(b.username);
          });
        emit(state.copyWith(
          status: WaitingRoomStatus.waiting,
          players: sorted,
        ));
      },
      onError: (_) {
        emit(state.copyWith(
          status: WaitingRoomStatus.error,
          errorMessage:
              'No pudimos sincronizar los jugadores. Verifica tu conexión.',
        ));
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
