/// Constantes de tipos de eventos del canal realtime compartidas entre features.
/// Viven en core para que waiting_room y game_board puedan importarlas
/// sin crear dependencias cruzadas entre features.
class GameEventTypes {
  GameEventTypes._();

  // ── Lobby ──────────────────────────────────────────────────────
  /// Pide a todos los clientes refrescar la lista de participantes.
  static const String lobbySync = 'lobby.sync';
  /// Avisa que el admin cerró la sala, forzando la salida.
  static const String lobbyClosed = 'lobby.closed';

  /// Un jugador perdió conexión temporalmente.
  static const String playerDisconnected = 'lobby.player_disconnected';

  /// Un jugador volvió a conectarse.
  static const String playerReconnected = 'lobby.player_reconnected';

  /// El host actualizó la configuración del lobby.
  static const String lobbySettingsUpdated = 'lobby.settings_updated';

  /// El admin distribuyó los roles del Modo Impostor.
  static const String impostorRolesAssigned = 'impostor.roles_assigned';
  /// El jugador confirmó la pantalla de revelación.
  static const String impostorRevealConfirmed = 'impostor.reveal_confirmed';

  /// La fase de preguntas cambió y el temporizador se sincronizó.
  static const String impostorQuestionPhaseUpdated = 'impostor.question_phase_updated';

  /// El host reinicia la sala al terminar el modo impostor.
  static const String impostorGameRestarted = 'impostor.game_restarted';
  
  /// El host inicia la siguiente ronda del modo impostor.
  static const String impostorGameNextRound = 'impostor.game_next_round';
  
  // ── Game board ─────────────────────────────────────────────────
  /// El admin inició la partida; payload contiene el GameState inicial.
  static const String gameStart = 'game.start';

  /// Jugador tiró el dado — sync incremental antes de resolver el turno.
  static const String diceRolled = 'game.dice_rolled';

  /// Turno resuelto; payload contiene el GameState autoritativo final.
  static const String diceRoll = 'game.dice_roll';

  /// Alias semántico para fin de turno (mismo wire que [diceRoll]).
  static const String turnCompleted = 'game.dice_roll';

  /// Sync general del tablero.
  static const String gameSync = 'game.sync';

  /// Un jugador alcanzó la casilla 49; payload: winnerId, winnerUsername.
  static const String gameVictory = 'game.victory';
}