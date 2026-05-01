class Profile {
  final String id;
  final String username;
  final String role;

  Profile({required this.id, required this.username, this.role = 'player'});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
    };
  }
}
