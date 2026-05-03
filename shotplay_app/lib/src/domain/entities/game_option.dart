import 'package:flutter/material.dart';

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
    required this.icon,
    required this.accentColor,
    required this.secondaryColor,
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
  final IconData icon;
  final Color accentColor;
  final Color secondaryColor;

  String get playersLabel => '$minPlayers-$maxPlayers personas';

  String get durationLabel => '~$durationMinutes min';
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
    id: 'never_have_i_ever',
    gameDbId: 1,
    title: 'Never Have I Ever',
    subtitle: 'Un clásico emocionante reinventado para ShotPlay.',
    description:
        'Sube por las escaleras para alcanzar la gloria o deslízate por las serpientes en este juego de azar y estrategia ligera.',
    badge: 'POPULAR',
    minPlayers: 2,
    maxPlayers: 4,
    durationMinutes: 15,
    icon: Icons.local_bar_rounded,
    accentColor: Color(0xFFFF6B8B),
    secondaryColor: Color(0xFFF9A03F),
  ),
  GameOption(
    id: 'truth_or_dare',
    gameDbId: 2,
    title: 'Truth or Dare',
    subtitle: 'Retos rápidos para grupos que quieren empezar ya.',
    description:
        'Ideal para partidas cortas, con acciones rápidas y preguntas que hacen avanzar la noche sin pausas largas.',
    badge: 'NUEVO',
    minPlayers: 3,
    maxPlayers: 8,
    durationMinutes: 20,
    icon: Icons.auto_awesome_rounded,
    accentColor: Color(0xFF8E7BFF),
    secondaryColor: Color(0xFF4BC6FF),
  ),
  GameOption(
    id: 'roulette',
    gameDbId: 3,
    title: 'Shot Roulette',
    subtitle: 'Rondas impredecibles y decisiones al instante.',
    description:
        'Un modo veloz para grupos grandes: la ruleta decide, el grupo responde y cada turno cambia el ritmo.',
    badge: 'RÁPIDO',
    minPlayers: 2,
    maxPlayers: 10,
    durationMinutes: 10,
    icon: Icons.casino_rounded,
    accentColor: Color(0xFF4CD7C0),
    secondaryColor: Color(0xFFB56BFF),
  ),
];