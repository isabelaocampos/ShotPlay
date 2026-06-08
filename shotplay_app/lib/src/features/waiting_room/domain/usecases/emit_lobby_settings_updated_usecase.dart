import 'package:flutter/foundation.dart';
import 'package:shotplay_app/src/domain/entities/lobby_settings.dart';
import 'package:shotplay_app/src/domain/repositories/game_event_repository.dart';
import 'package:shotplay_app/src/features/waiting_room/domain/lobby_event_types.dart';

class EmitLobbySettingsUpdatedUsecase {
  const EmitLobbySettingsUpdatedUsecase(this._repository);

  final GameEventRepository _repository;

  Future<void> execute(LobbySettings settings) async {
    debugPrint('[PUBSUB] Broadcasting lobby settings update');
    await _repository.emitEvent(<String, dynamic>{
      'appEventType': LobbyEventTypes.settingsUpdated,
      'payload': settings.toJson(),
    });
  }
}
