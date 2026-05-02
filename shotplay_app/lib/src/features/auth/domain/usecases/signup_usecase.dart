import 'package:shotplay_app/src/features/auth/data/repo/auth_repo_impl.dart';
import 'package:shotplay_app/src/features/auth/domain/repo/auth_repo.dart';

class SignupUsecase {
  final AuthRepo _authRepo = AuthRepoImpl();

  Future<void> execute(
    String username,
    String email,
    String password,
    String birthdateIso,
  ) async {
    await _authRepo.signup(
      email,
      password,
      data: {
        'username': username,
        'birth_date': birthdateIso,
      },
    );
  }
}
