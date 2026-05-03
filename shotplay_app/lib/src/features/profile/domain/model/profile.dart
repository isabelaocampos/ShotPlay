/// Represents a user profile stored in the `profiles` table.
///
/// Only fields that are reliably persisted and readable from the backend
/// are included. Derived or computed stats (goals, victories) are omitted
/// until a proper tracking mechanism exists on the server.
class Profile {
  final String id;
  final String username;
  final String email;
  final String role;
  final int gamesPlayed;

  const Profile({
    required this.id,
    required this.username,
    required this.email,
    this.role = 'player',
    this.gamesPlayed = 0,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'player',
      gamesPlayed: json['games_played'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    // Only include columns that exist in the 'profiles' table schema.
    // 'email' lives in auth.users, not here.
    // 'games_played' is not yet tracked in the schema.
    return {
      'id': id,
      'username': username,
      'role': role,
    };
  }
}
