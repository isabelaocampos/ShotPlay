import 'package:shotplay_app/src/features/auth/domain/repository/auth_repo.dart';

class LoginUsecase {
  final AuthRepo _authRepo;

  const LoginUsecase(this._authRepo);

  Future<void> execute(String email, String password) async {
    await _authRepo.login(email, password);
  }
}
