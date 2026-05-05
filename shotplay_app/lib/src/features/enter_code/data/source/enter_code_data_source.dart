import 'package:shotplay_app/src/features/enter_code/domain/model/enter_code_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnterCodeDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<EnterCodeUser?> getEnterCodeUser(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    final username = data['username'] as String?;
    if (username == null || username.isEmpty) return null;
    return EnterCodeUser(username: username);
  }
}
