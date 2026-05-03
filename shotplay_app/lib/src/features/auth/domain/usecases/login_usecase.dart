import 'package:shotplay_app/src/features/auth/data/repo/auth_repo_impl.dart';
import 'package:shotplay_app/src/features/auth/domain/repo/auth_repo.dart';

class LoginUsecase {
  final AuthRepo _authRepo = AuthRepoImpl();

  Future<void> execute(String email, String password) async {
    await _authRepo.login(email, password);
  }
}
