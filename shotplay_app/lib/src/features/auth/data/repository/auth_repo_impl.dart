import 'package:shotplay_app/src/features/auth/data/source/auth_data_source.dart';
import 'package:shotplay_app/src/features/auth/domain/repository/auth_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepoImpl extends AuthRepo {
  final AuthDataSource _source = AuthDataSource();

  @override
  Future<void> login(String email, String password) async {
    await _source.login(email, password);
  }

  @override
  Future<String> signup(
    String email,
    String password, {
    required Map<String, dynamic> data,
  }) async {
    final AuthResponse response = await _source.signup(
      email,
      password,
      data: data,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('No se pudo crear la cuenta.');
    }
    return user.id;
  }
}
