import '../constants/participation_statuses.dart';

class RoomPlayer {
  const RoomPlayer({
    required this.id,
    required this.roomCode,
    required this.userId,
    required this.username,
    required this.isHost,
    required this.isReady,
    this.avatarUrl,
    this.participationStatus = ParticipationStatuses.active,
  });

  final String id;
  final String roomCode;
  final String userId;
  final String username;
  final bool isHost;
  final bool isReady;
  final String? avatarUrl;
  final String participationStatus;

  bool get isConnected =>
      ParticipationStatuses.isConnected(participationStatus);

  String get statusLabel {
    if (isHost) return 'Anfitrión';
    if (participationStatus == ParticipationStatuses.disconnected) {
      return 'Desconectado';
    }
    if (isReady) return 'Listo para jugar';
    return 'Conectado';
  }
}
