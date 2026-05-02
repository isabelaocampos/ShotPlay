import '../../domain/entities/game.dart';

class GameModel extends Game {
  const GameModel({
    required super.id,
    required super.name,
    required super.description,
    super.imageUrl,
    required super.category,
    required super.minPlayers,
    required super.maxPlayers,
    required super.durationMinutes,
    required super.isPopular,
    required super.isAvailable,
    required super.rating,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: (json['description'] ?? '') as String,
      imageUrl: json['image_url'] as String?,
      category: (json['category'] ?? 'JUEGO DE MESA') as String,
      minPlayers: (json['min_players'] as num).toInt(),
      maxPlayers: (json['max_players'] as num).toInt(),
      durationMinutes: ((json['duration_minutes'] ?? 0) as num).toInt(),
      isPopular: (json['is_popular'] ?? false) as bool,
      isAvailable: (json['is_available'] ?? true) as bool,
      rating: ((json['rating'] ?? 0) as num).toDouble(),
    );
  }
}
