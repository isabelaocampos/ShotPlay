import '../entities/lobby_settings.dart';

/// Validates lobby configuration before persisting or starting a match.
class LobbySettingsValidator {
  LobbySettingsValidator._();

  /// Maximum impostors allowed for [playerCount] connected players.
  static int maxImpostorCount(int playerCount) {
    if (playerCount <= 1) return 0;
    return playerCount - 1;
  }

  static String? validateImpostorCount({
    required int impostorCount,
    required int playerCount,
  }) {
    if (playerCount < 2) {
      return 'Se necesitan al menos 2 jugadores para iniciar.';
    }

    if (impostorCount < ImpostorLobbySettings.minImpostorCount) {
      return 'Debe haber al menos 1 impostor.';
    }

    if (impostorCount >= playerCount) {
      return 'Los impostores deben ser menos que el total de jugadores.';
    }

    return null;
  }
}
