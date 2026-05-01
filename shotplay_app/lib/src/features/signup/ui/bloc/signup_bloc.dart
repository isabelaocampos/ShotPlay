import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shotplay_app/src/features/auth/domain/usecases/signup_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SignupEvent {}

class SignupSubmitEvent extends SignupEvent {
  final String username;
  final String email;
  final String password;

  SignupSubmitEvent({
    required this.username,
    required this.email,
    required this.password,
  });
}

abstract class SignupState {}

class SignupIdleState extends SignupState {}

class SignupSuccessState extends SignupState {}

class SignupFailState extends SignupState {
  final String message;
  SignupFailState({required this.message});
}

class SignupLoadingState extends SignupState {}

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SignupUsecase _usecase = SignupUsecase();

  SignupBloc() : super(SignupIdleState()) {
    on<SignupSubmitEvent>(_signup);
  }

  Future<void> _signup(
    SignupSubmitEvent event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoadingState());
    try {
      await _usecase.execute(event.username, event.email, event.password);
      emit(SignupSuccessState());
    } catch (e) {
      emit(SignupFailState(message: _mapSignupError(e)));
    }
  }

  String _mapSignupError(Object error) {
    if (error is AuthException) {
      return error.message;
    }
    if (error is PostgrestException) {
      final message = error.message.toLowerCase();
      if (message.contains('duplicate') ||
          message.contains('unique') ||
          message.contains('username')) {
        return 'El nombre de usuario ya esta en uso.';
      }
      return error.message;
    }
    return 'Ocurrio un error. Intenta de nuevo.';
  }
}
