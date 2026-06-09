import 'package:shotplay_app/src/core/constants/game_event_types.dart';

/// Re-exporta la constante compartida para no romper imports existentes.
class LobbyEventTypes {
  LobbyEventTypes._();

  static const String sync = GameEventTypes.lobbySync;
  static const String closed = GameEventTypes.lobbyClosed;
  static const String settingsUpdated = GameEventTypes.lobbySettingsUpdated;
}