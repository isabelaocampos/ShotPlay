abstract class ImpostorEvent {
  const ImpostorEvent();
}

/// Evento para que el Host inicie el sorteo.
class StartRoleDistribution extends ImpostorEvent {
  final List<String> playerIds;
  final int impostorCount;

  const StartRoleDistribution({
    required this.playerIds,
    this.impostorCount = 1,
  });
}

/// Evento interno disparado cuando llega el broadcast de Supabase.
class OnImpostorDataReceived extends ImpostorEvent {
  final Map<String, dynamic> payload;
// Movido a presentation/bloc/
  const OnImpostorDataReceived(this.payload);
}