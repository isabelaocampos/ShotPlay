import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shotplay_app/src/features/auth/domain/usecases/login_usecase.dart';

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
        emit(LoginFailState(e.toString()));
      }
    });
  }
}
