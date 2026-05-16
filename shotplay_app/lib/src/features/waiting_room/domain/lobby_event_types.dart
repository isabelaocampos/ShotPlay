/// Lobby-specific event [type] values sent through [GameEventRepository].
///
/// Kept in the waiting-room feature so the generic transport layer stays
/// game-agnostic.
class LobbyEventTypes {
  LobbyEventTypes._();

  /// Ask all clients in the room to refresh the participant list from the DB.
  static const String sync = 'lobby.sync';
}
