import 'package:shotplay_app/src/features/profile/domain/model/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDataSource {
  Future<void> saveProfile(Profile profile) async {
    await Supabase.instance.client.from('profiles').insert(profile.toJson());
  }
}
