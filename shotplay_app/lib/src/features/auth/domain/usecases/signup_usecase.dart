import 'package:shotplay_app/src/features/auth/domain/repository/auth_repo.dart';
import 'package:shotplay_app/src/features/profile/domain/model/profile.dart';
import 'package:shotplay_app/src/features/profile/domain/repository/profile_repository.dart';

class SignupUsecase {
  final AuthRepo _authRepo;
  final ProfileRepository _profileRepo;

  const SignupUsecase(this._authRepo, this._profileRepo);

  Future<void> execute(
    String username,
    String email,
    String password,
    String birthdateIso,
  ) async {
    final String id = await _authRepo.signup(
      email,
      password,
      data: {
        'username': username,
        'birth_date': birthdateIso,
      },
    );
    
    await _profileRepo.saveProfile(
      Profile(id: id, username: username, email: email),
    );
  }
}
