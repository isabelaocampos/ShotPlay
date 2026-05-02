import 'package:shotplay_app/src/features/profile/domain/model/profile.dart';

abstract class ProfileRepository {
  Future<void> saveProfile(Profile profile);
}
