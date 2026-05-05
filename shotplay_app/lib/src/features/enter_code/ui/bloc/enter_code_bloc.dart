import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shotplay_app/src/features/enter_code/domain/model/enter_code_user.dart';
import 'package:shotplay_app/src/features/enter_code/domain/usecases/get_enter_code_user_usecase.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class EnterCodeEvent {
  const EnterCodeEvent();
}

class EnterCodeLoadRequested extends EnterCodeEvent {
  final String userId;
  const EnterCodeLoadRequested(this.userId);
}

// ─── States ───────────────────────────────────────────────────────────────────

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
  final EnterCodeUser user;
  const EnterCodeLoaded(this.user);
}

class EnterCodeError extends EnterCodeState {
  final String message;
  const EnterCodeError(this.message);
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class EnterCodeBloc extends Bloc<EnterCodeEvent, EnterCodeState> {
  final GetEnterCodeUserUsecase _getUser;

  EnterCodeBloc(this._getUser) : super(const EnterCodeInitial()) {
    on<EnterCodeLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    EnterCodeLoadRequested event,
    Emitter<EnterCodeState> emit,
  ) async {
    emit(const EnterCodeLoading());
    try {
      final user = await _getUser.execute(event.userId);
      if (user != null) {
        emit(EnterCodeLoaded(user));
      } else {
        emit(const EnterCodeError('No se encontró el usuario.'));
      }
    } catch (e) {
      emit(EnterCodeError('Error al cargar el usuario: ${e.toString()}'));
    }
  }
}
