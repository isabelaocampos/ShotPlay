import 'package:shotplay_app/src/domain/entities/lobby_settings.dart';
import 'package:shotplay_app/src/domain/repositories/room_repository.dart';

class FetchLobbySettingsUsecase {
  const FetchLobbySettingsUsecase(this._repository);

  final RoomRepository _repository;

  Future<LobbySettings> execute(int roomId) =>
      _repository.fetchLobbySettings(roomId);
}
