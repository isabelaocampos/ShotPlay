abstract class AuthRepo {
  Future<String> signup(
    String email,
    String pass, {
    required Map<String, dynamic> data,
  });
  Future<void> login(String email, String pass);
}
