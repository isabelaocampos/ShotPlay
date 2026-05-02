import 'package:flutter/material.dart';

class GameOption {
  const GameOption({
    required this.id,
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

const defaultGameOptions = <GameOption>[
  GameOption(
    id: 'never_have_i_ever',
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