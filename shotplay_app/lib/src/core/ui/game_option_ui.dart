import 'package:flutter/material.dart';

import '../../domain/entities/game_option.dart';

/// Presentation-layer extension that adds Flutter-specific UI properties
/// (icon, colors) to the domain [GameOption] entity.
extension GameOptionUI on GameOption {
  IconData get icon {
    switch (id) {
      case 'snakes_ladders':
        return Icons.view_module_rounded;
      case 'impostor':
        return Icons.groups_rounded;
      default:
        return Icons.gamepad_rounded;
    }
  }

  Color get accentColor {
    switch (id) {
      case 'snakes_ladders':
        return const Color(0xFF4CD7C0);
      case 'impostor':
        return const Color(0xFF8E7BFF);
      default:
        return const Color(0xFF7F0DF2);
    }
  }

  Color get secondaryColor {
    switch (id) {
      case 'snakes_ladders':
        return const Color(0xFFF9A03F);
      case 'impostor':
        return const Color(0xFF4BC6FF);
      default:
        return const Color(0xFF7F0DF2);
    }
  }
}
