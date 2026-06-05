import 'room_entry_destination.dart';
import 'room_player.dart';
import 'room_session.dart';

class RoomEntryResult {
  const RoomEntryResult({
    required this.room,
    required this.destination,
    required this.players,
    required this.isReconnect,
    this.persistedGameState,
  });

  final RoomSession room;
  final RoomEntryDestination destination;
  final List<RoomPlayer> players;
  final bool isReconnect;

  /// Last persisted snapshot from Supabase (generic JSON). Game layers parse it.
  final Map<String, dynamic>? persistedGameState;
}
