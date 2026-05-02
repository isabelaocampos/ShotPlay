import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/game.dart';
import '../../domain/entities/game_room.dart';
import '../../domain/repositories/game_repository.dart';

part 'configure_game_state.dart';

class ConfigureGameCubit extends Cubit<ConfigureGameState> {
  final GameRepository _repository;
  final Game game;

  ConfigureGameCubit(this._repository, this.game)
      : super(ConfigureGameState.initial(game));

  void increment() {
    if (state.playerCount < game.maxPlayers) {
      emit(state.copyWith(playerCount: state.playerCount + 1));
    }
  }

  void decrement() {
    if (state.playerCount > game.minPlayers) {
      emit(state.copyWith(playerCount: state.playerCount - 1));
    }
  }

  void toggleHints() => emit(state.copyWith(hintsEnabled: !state.hintsEnabled));

  void togglePrivate() => emit(state.copyWith(isPrivate: !state.isPrivate));

  Future<void> createRoom(String roomName) async {
    final trimmed = roomName.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(
        status: ConfigureGameStatus.error,
        errorMessage: 'Ingresa un nombre para la sala.',
      ));
      return;
    }

    final isValid = await _repository.validatePlayerCount(
      gameId: game.id,
      playerCount: state.playerCount,
    );
    if (!isValid) {
      emit(state.copyWith(
        status: ConfigureGameStatus.error,
        errorMessage:
            'El número de jugadores no es compatible con ${game.name}.',
      ));
      return;
    }

    emit(state.copyWith(
      status: ConfigureGameStatus.creating,
      errorMessage: null,
    ));
    try {
      final room = await _repository.createRoom(
        gameId: game.id,
        roomName: trimmed,
        maxPlayers: state.playerCount,
        isPrivate: state.isPrivate,
        hintsEnabled: state.hintsEnabled,
      );
      emit(state.copyWith(
        status: ConfigureGameStatus.created,
        createdRoom: room,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ConfigureGameStatus.error,
        errorMessage: e is Exception
            ? e.toString().replaceFirst('Exception: ', '')
            : 'No pudimos crear la sala. Inténtalo de nuevo.',
      ));
    }
  }

  void clearError() {
    emit(state.copyWith(
      status: ConfigureGameStatus.idle,
      errorMessage: null,
    ));
  }
}
