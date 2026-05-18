import '../../../../core/constants/game_event_types.dart';
import '../../../../domain/repositories/game_event_repository.dart';

/// Emite el evento game.start por el canal de la sala.
/// Lo llama el admin; todos los clientes suscritos lo reciben
/// y navegan automáticamente al tablero.
class EmitGameStartUsecase {
  const EmitGameStartUsecase(this._repository);

  final GameEventRepository _repository;

  Future<void> execute() => _repository.emitEvent(<String, dynamic>{
        'type': GameEventTypes.gameStart,
      });
}
