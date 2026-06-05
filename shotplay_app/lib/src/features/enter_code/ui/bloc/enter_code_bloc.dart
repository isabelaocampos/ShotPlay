import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shotplay_app/src/domain/entities/room_entry_destination.dart';
import 'package:shotplay_app/src/domain/entities/room_entry_result.dart';
import 'package:shotplay_app/src/domain/repositories/room_repository.dart';
import 'package:shotplay_app/src/domain/repositories/game_event_repository.dart';
import 'package:shotplay_app/src/features/session/domain/usecases/ensure_room_channel_connected_usecase.dart';
import 'package:shotplay_app/src/features/enter_code/domain/model/enter_code_user.dart';
import 'package:shotplay_app/src/features/enter_code/domain/usecases/get_enter_code_user_usecase.dart';
import 'package:shotplay_app/src/features/enter_code/domain/usecases/join_room_usecase.dart';

// ── Events ──────────────────────────────────────────────────────────────────

abstract class EnterCodeEvent {
  const EnterCodeEvent();
}

class EnterCodeLoadRequested extends EnterCodeEvent {
  const EnterCodeLoadRequested(this.userId);
  final String userId;
}

class EnterCodeJoinRequested extends EnterCodeEvent {
  const EnterCodeJoinRequested({
    required this.roomCode,
    this.expectedGameId,
  });

  final String roomCode;
  final int? expectedGameId;
}

// ── States ──────────────────────────────────────────────────────────────────

abstract class EnterCodeState {
  const EnterCodeState();
}

class EnterCodeInitial extends EnterCodeState {
  const EnterCodeInitial();
}

class EnterCodeLoading extends EnterCodeState {
  const EnterCodeLoading();
}

class EnterCodeLoaded extends EnterCodeState {
  const EnterCodeLoaded(this.user);
  final EnterCodeUser user;
}

class EnterCodeJoining extends EnterCodeState {
  const EnterCodeJoining(this.user);
  final EnterCodeUser user;
}

class EnterCodeJoinSuccess extends EnterCodeState {
  const EnterCodeJoinSuccess(this.result);
  final RoomEntryResult result;
}

class EnterCodeError extends EnterCodeState {
  const EnterCodeError(this.message);
  final String message;
}

// ── Bloc ────────────────────────────────────────────────────────────────────

class EnterCodeBloc extends Bloc<EnterCodeEvent, EnterCodeState> {
  EnterCodeBloc({
    required GetEnterCodeUserUsecase getUser,
    required JoinRoomUsecase joinRoom,
    required EnsureRoomChannelConnectedUsecase ensureChannelConnected,
  })  : _getUser = getUser,
        _joinRoom = joinRoom,
        _ensureChannelConnected = ensureChannelConnected,
        super(const EnterCodeInitial()) {
    on<EnterCodeLoadRequested>(_onLoadRequested);
    on<EnterCodeJoinRequested>(_onJoinRequested);
  }

  final GetEnterCodeUserUsecase _getUser;
  final JoinRoomUsecase _joinRoom;
  final EnsureRoomChannelConnectedUsecase _ensureChannelConnected;

  EnterCodeUser? _cachedUser;

  Future<void> _onLoadRequested(
    EnterCodeLoadRequested event,
    Emitter<EnterCodeState> emit,
  ) async {
    emit(const EnterCodeLoading());
    try {
      final user = await _getUser.execute(event.userId);
      if (user != null) {
        _cachedUser = user;
        emit(EnterCodeLoaded(user));
      } else {
        emit(const EnterCodeError('No se encontró el usuario.'));
      }
    } catch (e) {
      emit(EnterCodeError('Error al cargar el usuario: ${e.toString()}'));
    }
  }

  Future<void> _onJoinRequested(
    EnterCodeJoinRequested event,
    Emitter<EnterCodeState> emit,
  ) async {
    final user = _cachedUser;
    if (user == null) {
      emit(const EnterCodeError('Debes iniciar sesión para unirte a una sala.'));
      return;
    }

    debugPrint('[ROOM] Submit join room code: ${event.roomCode}');
    emit(EnterCodeJoining(user));

    try {
      final result = await _joinRoom.execute(
        roomCode: event.roomCode,
        expectedGameId: event.expectedGameId,
      );

      if (result.destination == RoomEntryDestination.gameBoard) {
        debugPrint('[RECONNECT] Room status=in_progress');
        await _ensureChannelConnected.execute(result.room.roomCode);
      }

      debugPrint(
        '[NAVIGATION] Join success → ${result.destination} '
        '(${result.room.roomCode}) reconnect=${result.isReconnect}',
      );
      emit(EnterCodeJoinSuccess(result));
    } on NotAuthenticatedException {
      emit(const EnterCodeError('Debes iniciar sesión para unirte a una sala.'));
    } on RoomNotFoundException catch (e) {
      emit(EnterCodeError(e.toString()));
    } on RoomFullException catch (e) {
      emit(EnterCodeError(e.toString()));
    } on RoomGameMismatchException catch (e) {
      emit(EnterCodeError(e.toString()));
    } on RoomFinishedException catch (e) {
      emit(EnterCodeError(e.toString()));
    } on RoomRepositoryException catch (e) {
      emit(EnterCodeError(e.toString()));
    } on GameEventNotConnectedException {
      emit(const EnterCodeError(
        'No pudimos conectar al canal en tiempo real. Intenta de nuevo.',
      ));
    } on GameEventRepositoryException catch (e) {
      emit(EnterCodeError(e.toString()));
    } catch (e) {
      debugPrint('[ROOM] Join failed: $e');
      emit(EnterCodeError('No se pudo unir a la sala. Intenta de nuevo.'));
    }
  }
}
