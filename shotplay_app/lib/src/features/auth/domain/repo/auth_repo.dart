abstract class AuthRepo {
  Future<String> signup(String email, String pass);
  Future<void> login(String email, String pass);
}
