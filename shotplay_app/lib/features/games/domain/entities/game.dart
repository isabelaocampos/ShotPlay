class Game {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String category;
  final int minPlayers;
  final int maxPlayers;
  final int durationMinutes;
  final bool isPopular;
  final bool isAvailable;
  final double rating;

  const Game({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.category,
    required this.minPlayers,
    required this.maxPlayers,
    required this.durationMinutes,
    required this.isPopular,
    required this.isAvailable,
    required this.rating,
  });

  String get playersLabel => minPlayers == maxPlayers
      ? '$minPlayers JUGADORES'
      : '$minPlayers-$maxPlayers JUGADORES';
}
