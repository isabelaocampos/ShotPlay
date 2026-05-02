import 'package:shotplay_app/src/features/profile/data/source/profile_data_source.dart';
import 'package:shotplay_app/src/features/profile/domain/model/profile.dart';
import 'package:shotplay_app/src/features/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  final ProfileDataSource _source = ProfileDataSource();

  @override
  Future<void> saveProfile(Profile profile) async {
    await _source.saveProfile(profile);
  }
}
