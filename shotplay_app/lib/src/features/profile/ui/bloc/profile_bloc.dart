import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shotplay_app/src/features/profile/data/repository/profile_repository_impl.dart';
import 'package:shotplay_app/src/features/profile/domain/model/profile.dart';
import 'package:shotplay_app/src/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  ProfileBloc()
      : _getProfile = GetProfileUsecase(ProfileRepositoryImpl()),
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      Profile? profile = await _getProfile.execute(event.userId);

      // If no profile row exists yet, build a fallback from auth session data.
      // The username is stored in userMetadata during signup (key: 'username').
      if (profile == null) {
        final authUser = Supabase.instance.client.auth.currentUser;
        if (authUser != null) {
          final metadataUsername =
              authUser.userMetadata?['username'] as String?;
          profile = Profile(
            id: authUser.id,
            username: metadataUsername?.trim().isNotEmpty == true
                ? metadataUsername!
                : authUser.email?.split('@').first ?? 'Usuario',
            email: authUser.email ?? '',
            role: 'player',
          );
        }
      }

      if (profile != null) {
        // If viewing our own profile, ensure email comes from the auth session
        final authUser = Supabase.instance.client.auth.currentUser;
        if (authUser != null && authUser.id == event.userId) {
          profile = Profile(
            id: profile.id,
            username: profile.username,
            email: authUser.email ?? profile.email,
            role: profile.role,
            gamesPlayed: profile.gamesPlayed,
          );
        }
        emit(ProfileLoaded(profile));
      } else {
        emit(const ProfileError('No se encontró el perfil del usuario.'));
      }
    } catch (e) {
      emit(ProfileError('Error al cargar el perfil: ${e.toString()}'));
    }
  }
}
