import 'package:shotplay_app/src/features/profile/domain/model/profile.dart';
import 'package:shotplay_app/src/features/profile/domain/repository/profile_repository.dart';

class GetProfileUsecase {
  final ProfileRepository _repository;

  const GetProfileUsecase(this._repository);

  Future<Profile?> execute(String userId) {
    return _repository.getProfile(userId);
  }
}
