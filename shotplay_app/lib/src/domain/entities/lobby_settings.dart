/// Generic lobby configuration persisted on [RoomSession].
///
/// Game-specific blocks live under named keys (e.g. `impostor`) so future
/// games can add their own sections without schema changes.
class LobbySettings {
  const LobbySettings({
    this.impostor = const ImpostorLobbySettings(),
  });

  final ImpostorLobbySettings impostor;

  static const LobbySettings empty = LobbySettings();

  /// Default settings when a room is created for [gameId].
  static LobbySettings forGame(int gameId) {
    if (gameId == 2) {
      return const LobbySettings(
        impostor: ImpostorLobbySettings(),
      );
    }
    return empty;
  }

  factory LobbySettings.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return empty;
    }

    final impostorRaw = json['impostor'];
    return LobbySettings(
      impostor: impostorRaw is Map<String, dynamic>
          ? ImpostorLobbySettings.fromJson(impostorRaw)
          : const ImpostorLobbySettings(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'impostor': impostor.toJson(),
      };

  LobbySettings copyWith({ImpostorLobbySettings? impostor}) {
    return LobbySettings(
      impostor: impostor ?? this.impostor,
    );
  }

  LobbySettings withImpostorCount(int count) {
    return copyWith(
      impostor: impostor.copyWith(impostorCount: count),
    );
  }
}

class ImpostorLobbySettings {
  const ImpostorLobbySettings({this.impostorCount = defaultImpostorCount});

  static const int defaultImpostorCount = 1;
  static const int minImpostorCount = 1;

  final int impostorCount;

  bool get isDefault => impostorCount == defaultImpostorCount;

  factory ImpostorLobbySettings.fromJson(Map<String, dynamic> json) {
    return ImpostorLobbySettings(
      impostorCount: (json['impostorCount'] as num?)?.toInt() ??
          defaultImpostorCount,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'impostorCount': impostorCount,
      };

  ImpostorLobbySettings copyWith({int? impostorCount}) {
    return ImpostorLobbySettings(
      impostorCount: impostorCount ?? this.impostorCount,
    );
  }
}
