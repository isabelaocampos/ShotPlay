import '../../core/resources/app_images.dart';

class GameOption {
  const GameOption({
    required this.id,
    required this.gameDbId,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.badge,
    required this.minPlayers,
    required this.maxPlayers,
    required this.durationMinutes,
    required this.imagePath,
  });

  final String id;
  // Maps to room.game_id (int4) in Supabase. These integers MUST match the
  // primary keys of whatever 'game' lookup rows exist in the database.
  // If your DB has no game lookup table yet, ensure room.game_id is nullable
  // or remove the column from the insert in SupabaseRoomRepository.
  final int gameDbId;
  final String title;
  final String subtitle;
  final String description;
  final String badge;
  final int minPlayers;
  final int maxPlayers;
  final int durationMinutes;
  final String imagePath;

  String get playersLabel => '$minPlayers-$maxPlayers personas';

  String get durationLabel => '~$durationMinutes min';

  String get heroImagePath {
    switch (id) {
      case 'snakes_ladders':
        return AppImages.headlinerEscalera;
      case 'impostor':
        return AppImages.headlinerImpostor;
      default:
        return imagePath;
    }
  }
}

GameOption gameOptionFromId(String id) {
  return defaultGameOptions.firstWhere(
    (game) => game.id == id,
    orElse: () => defaultGameOptions.first,
  );
}

GameOption gameOptionFromDbId(int gameDbId) {
  return defaultGameOptions.firstWhere(
    (game) => game.gameDbId == gameDbId,
    orElse: () => defaultGameOptions.first,
  );
}

const defaultGameOptions = <GameOption>[
  GameOption(
    id: 'snakes_ladders',
    gameDbId: 1,
    title: 'Escaleras y Serpientes',
    subtitle: 'El tablero social para subir, caer y volver a intentar.',
    description:
        'Avanza por el tablero, evita las serpientes y aprovecha cada escalera para llegar primero a la meta.',
    badge: 'TABLERO',
    minPlayers: 2,
    maxPlayers: 6,
    durationMinutes: 20,
    imagePath: AppImages.snakesLadders,
  ),
  GameOption(
    id: 'impostor',
    gameDbId: 2,
    title: 'El Impostor',
    subtitle: 'Descubre quién está ocultando su identidad.',
    description:
        'Discusión, sospechas y pistas ocultas para un grupo que quiere retarse a descubrir al impostor.',
    badge: 'SOCIAL',
    minPlayers: 5,
    maxPlayers: 10,
    durationMinutes: 15,
    imagePath: AppImages.impostor,
  ),
];