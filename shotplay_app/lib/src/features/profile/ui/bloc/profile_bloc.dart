import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shotplay_app/src/features/profile/domain/model/profile.dart';
import 'package:shotplay_app/src/features/profile/domain/usecases/get_profile_usecase.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class ProfileEvent {
  const ProfileEvent();
}

class ProfileLoadRequested extends ProfileEvent {
  final String userId;
  const ProfileLoadRequested(this.userId);
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final Profile profile;
  const ProfileLoaded(this.profile);
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUsecase _getProfile;

  ProfileBloc(this._getProfile) : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final profile = await _getProfile.execute(event.userId);
      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(const ProfileError('No se encontró el perfil del usuario.'));
      }
    } catch (e) {
      emit(ProfileError('Error al cargar el perfil: ${e.toString()}'));
    }
  }
}
