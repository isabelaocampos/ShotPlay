import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shotplay_app/src/features/auth/domain/usecases/login_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class LoginEvent {}

class LoginSubmitEvent extends LoginEvent {
  final String email;
  final String password;
  LoginSubmitEvent({required this.email, required this.password});
}

abstract class LoginState {}

class LoginInitialState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginSuccessState extends LoginState {}

class LoginFailState extends LoginState {
  final String message;
  LoginFailState(this.message);
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUsecase _loginUsecase = LoginUsecase();

  LoginBloc() : super(LoginInitialState()) {
    on<LoginSubmitEvent>((event, emit) async {
      emit(LoginLoadingState());
      try {
        await _loginUsecase.execute(event.email, event.password);
        emit(LoginSuccessState());
      } catch (e) {
        emit(LoginFailState(_mapAuthError(e)));
      }
    });
  }

  String _mapAuthError(Object error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid credentials') ||
          msg.contains('email not confirmed') && msg.contains('password')) {
        return 'Correo o contraseña incorrectos.';
      }
      if (msg.contains('email not confirmed')) {
        return 'Debes confirmar tu correo electrónico antes de iniciar sesión.';
      }
      if (msg.contains('too many requests') || msg.contains('rate limit')) {
        return 'Demasiados intentos. Espera un momento e inténtalo de nuevo.';
      }
      // Fallback: use Supabase's message directly (it's usually readable)
      return error.message;
    }
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}
