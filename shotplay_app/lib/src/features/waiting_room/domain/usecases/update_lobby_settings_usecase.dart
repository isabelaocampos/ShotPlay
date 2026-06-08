import 'package:shotplay_app/src/domain/entities/lobby_settings.dart';
import 'package:shotplay_app/src/domain/repositories/room_repository.dart';

class UpdateLobbySettingsUsecase {
  const UpdateLobbySettingsUsecase(this._repository);

  final RoomRepository _repository;

  Future<void> execute(int roomId, LobbySettings settings) =>
      _repository.updateLobbySettings(roomId, settings);
}
