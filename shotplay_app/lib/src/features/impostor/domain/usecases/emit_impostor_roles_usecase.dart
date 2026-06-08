import '../../../../core/constants/game_event_types.dart';
import '../../../../domain/repositories/game_event_repository.dart';
import '../entities/impostor_entities.dart';

/// Emite la lista de roles asignados a través del canal de Supabase.
/// Lo ejecuta el Host una vez que GenerateRolesUseCase termina.
class EmitImpostorRolesUseCase {
  const EmitImpostorRolesUseCase(this._repository);

  final GameEventRepository _repository;

  Future<void> execute(List<AssignedRole> roles) {
    return _repository.emitEvent(<String, dynamic>{
      'appEventType': GameEventTypes.impostorRolesAssigned,
      'players': roles.map((r) => r.toJson()).toList(),
    });
  }
}