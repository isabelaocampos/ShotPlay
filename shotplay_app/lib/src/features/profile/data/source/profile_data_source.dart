import 'package:shotplay_app/src/features/profile/domain/model/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> saveProfile(Profile profile) async {
    await _client.from('profiles').insert(profile.toJson());
  }

  Future<Profile?> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return Profile.fromJson(data);
  }
}

