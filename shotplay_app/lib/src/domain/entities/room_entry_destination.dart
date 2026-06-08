enum RoomEntryDestination {
  waitingRoom,
  snakesGame,
  impostorGame,
  roomFinished;

  /// Whether the shared realtime channel must be connected before navigation.
  bool get requiresRealtimeChannel =>
      this == snakesGame || this == impostorGame;
}
