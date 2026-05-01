import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDataSource {
  Future<AuthResponse> signup(String email, String password) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }
}
