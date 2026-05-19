import '../enums/special_cell_type.dart';
import 'challenge_card.dart';
import 'trap_state.dart';

class SpecialCellEffect {
  const SpecialCellEffect({
    required this.type,
    this.shots = 0,
    this.card,
    this.targetPlayerId,
    this.trapState,
    this.description = '',
  });

  final SpecialCellType type;
  final int shots;
  final ChallengeCard? card;
  final String? targetPlayerId;
  final TrapState? trapState;
  final String description;

  bool get needsSelection =>
      type == SpecialCellType.splitShots ||
      type == SpecialCellType.giveShots ||
      type == SpecialCellType.mostLikelyTo;
}