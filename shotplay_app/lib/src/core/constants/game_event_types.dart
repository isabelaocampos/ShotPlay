/// Constantes de tipos de eventos del canal realtime compartidas entre features.
/// Viven en core para que waiting_room y game_board puedan importarlas
/// sin crear dependencias cruzadas entre features.
class GameEventTypes {
  GameEventTypes._();

  // ── Lobby ──────────────────────────────────────────────────────
  /// Pide a todos los clientes refrescar la lista de participantes.
  static const String lobbySync = 'lobby.sync';

  // ── Game board ─────────────────────────────────────────────────
  /// El admin inició la partida; payload contiene el GameState inicial.
  static const String gameStart = 'game.start';

  /// Un jugador tiró el dado; payload contiene el nuevo GameState.
  static const String diceRoll = 'game.dice_roll';

  /// Sync general del tablero.
  static const String gameSync = 'game.sync';
}