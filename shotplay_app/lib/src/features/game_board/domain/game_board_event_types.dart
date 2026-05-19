import 'package:shotplay_app/src/core/constants/game_event_types.dart';


/// Re-exporta las constantes compartidas para no romper imports existentes.
class GameBoardEventTypes {
  GameBoardEventTypes._();

  static const String gameStart = GameEventTypes.gameStart;
  static const String diceRoll = GameEventTypes.diceRoll;
  static const String sync = GameEventTypes.gameSync;
  static const String gameVictory = GameEventTypes.gameVictory;
}