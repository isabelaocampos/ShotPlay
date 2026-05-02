part of 'waiting_room_cubit.dart';

enum WaitingRoomStatus { initial, loading, waiting, starting, error }

class WaitingRoomState {
  final WaitingRoomStatus status;
  final List<RoomPlayer> players;
  final String? errorMessage;

  const WaitingRoomState({
    required this.status,
    required this.players,
    this.errorMessage,
  });

  const WaitingRoomState.initial()
      : status = WaitingRoomStatus.initial,
        players = const [],
        errorMessage = null;

  WaitingRoomState copyWith({
    WaitingRoomStatus? status,
    List<RoomPlayer>? players,
    String? errorMessage,
  }) {
    return WaitingRoomState(
      status: status ?? this.status,
      players: players ?? this.players,
      errorMessage: errorMessage,
    );
  }
}
