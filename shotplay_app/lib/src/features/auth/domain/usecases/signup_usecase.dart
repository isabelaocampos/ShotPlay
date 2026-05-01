import 'package:shotplay_app/src/features/auth/data/repo/auth_repo_impl.dart';
import 'package:shotplay_app/src/features/auth/domain/repo/auth_repo.dart';
import 'package:shotplay_app/src/features/profile/data/repository/profile_repository_impl.dart';
import 'package:shotplay_app/src/features/profile/domain/model/profile.dart';
import 'package:shotplay_app/src/features/profile/domain/repository/profile_repository.dart';

class SignupUsecase {
  final AuthRepo _authRepo = AuthRepoImpl();
  final ProfileRepository _profileRepo = ProfileRepositoryImpl();

  Future<void> execute(String username, String email, String password) async {
    final String id = await _authRepo.signup(email, password);
    await _profileRepo.saveProfile(Profile(id: id, username: username));
  }
}
