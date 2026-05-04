import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shotplay_app/src/features/ingresar_codigo/data/repository/ingresar_codigo_repository_impl.dart';
import 'package:shotplay_app/src/features/ingresar_codigo/domain/model/ingresar_codigo_user.dart';
import 'package:shotplay_app/src/features/ingresar_codigo/domain/usecases/get_ingresar_codigo_user_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class IngresarCodigoEvent {
  const IngresarCodigoEvent();
}

class IngresarCodigoLoadRequested extends IngresarCodigoEvent {
  final String userId;
  const IngresarCodigoLoadRequested(this.userId);
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class IngresarCodigoState {
  const IngresarCodigoState();
}

class IngresarCodigoInitial extends IngresarCodigoState {
  const IngresarCodigoInitial();
}

class IngresarCodigoLoading extends IngresarCodigoState {
  const IngresarCodigoLoading();
}

class IngresarCodigoLoaded extends IngresarCodigoState {
  final IngresarCodigoUser user;
  const IngresarCodigoLoaded(this.user);
}

class IngresarCodigoError extends IngresarCodigoState {
  final String message;
  const IngresarCodigoError(this.message);
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class IngresarCodigoBloc extends Bloc<IngresarCodigoEvent, IngresarCodigoState> {
  final GetIngresarCodigoUserUsecase _getUser;

  IngresarCodigoBloc()
      : _getUser = GetIngresarCodigoUserUsecase(IngresarCodigoRepositoryImpl()),
        super(const IngresarCodigoInitial()) {
    on<IngresarCodigoLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    IngresarCodigoLoadRequested event,
    Emitter<IngresarCodigoState> emit,
  ) async {
    emit(const IngresarCodigoLoading());
    try {
      IngresarCodigoUser? user = await _getUser.execute(event.userId);

      // If no profile row or empty username, build from the auth session (same
      // resolution order as the previous UI: metadata username → email local).
      if (user == null) {
        final authUser = Supabase.instance.client.auth.currentUser;
        if (authUser != null) {
          final fromMeta = authUser.userMetadata?['username'] as String?;
          final fromEmail = authUser.email?.split('@').first;
          final resolved =
              (fromMeta != null && fromMeta.isNotEmpty) ? fromMeta : (fromEmail ?? 'Usuario');
          user = IngresarCodigoUser(username: resolved);
        }
      }

      if (user != null) {
        emit(IngresarCodigoLoaded(user));
      } else {
        emit(const IngresarCodigoError('No se encontró el usuario.'));
      }
    } catch (e) {
      emit(IngresarCodigoError('Error al cargar el usuario: ${e.toString()}'));
    }
  }
}
