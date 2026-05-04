import 'package:shotplay_app/src/features/ingresar_codigo/domain/model/ingresar_codigo_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IngresarCodigoDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<IngresarCodigoUser?> getIngresarCodigoUser(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    final username = data['username'] as String?;
    if (username == null || username.isEmpty) return null;
    return IngresarCodigoUser(username: username);
  }
}
