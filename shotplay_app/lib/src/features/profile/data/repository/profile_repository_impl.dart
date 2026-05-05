import 'package:shotplay_app/src/features/profile/data/source/profile_data_source.dart';
import 'package:shotplay_app/src/features/profile/domain/model/profile.dart';
import 'package:shotplay_app/src/features/profile/domain/repository/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  final ProfileDataSource _source = ProfileDataSource();

  @override
  Future<void> saveProfile(Profile profile) async {
    await _source.saveProfile(profile);
  }

  @override
  Future<Profile?> getProfile(String userId) async {
    final dbProfile = await _source.getProfile(userId);
    final authUser = Supabase.instance.client.auth.currentUser;

    if (dbProfile == null) {
      // Build a fallback from the auth session when the profiles row
      // doesn't exist yet (e.g. right after signup before the DB write).
      if (authUser == null) return null;
      final metadataUsername =
          authUser.userMetadata?['username'] as String?;
      return Profile(
        id: authUser.id,
        username: metadataUsername?.trim().isNotEmpty == true
            ? metadataUsername!
            : authUser.email?.split('@').first ?? 'Usuario',
        email: authUser.email ?? '',
        role: 'player',
      );
    }

    // Enrich with the auth email when viewing our own profile,
    // since email lives in auth.users, not in the profiles table.
    if (authUser != null && authUser.id == userId) {
      return Profile(
        id: dbProfile.id,
        username: dbProfile.username,
        email: authUser.email ?? dbProfile.email,
        role: dbProfile.role,
        gamesPlayed: dbProfile.gamesPlayed,
      );
    }

    return dbProfile;
  }
}

