import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../domain/entities/room_player.dart';
import '../impostor_bloc.dart';
import '../impostor_event.dart';

class ImpostorResultsModal extends StatelessWidget {
  final bool impostorWon;
  final String impostorId;
  final List<RoomPlayer> roomPlayers;
  final Map<String, String> voteMap;

  const ImpostorResultsModal({
    super.key,
    required this.impostorWon,
    required this.impostorId,
    required this.roomPlayers,
    required this.voteMap,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<ImpostorBloc>().currentUserId;
    
    final impostorPlayer = roomPlayers.firstWhere(
      (p) => p.userId == impostorId,
      orElse: () => const RoomPlayer(
        id: '',
        roomCode: '',
        userId: '',
        username: 'Desconocido',
        isHost: false,
        isReady: false,
      ),
    );

    final localPlayer = roomPlayers.firstWhere(
      (p) => p.userId == currentUserId,
      orElse: () => const RoomPlayer(
        id: '',
        roomCode: '',
        userId: '',
        username: '',
        isHost: false,
        isReady: false,
      ),
    );

    final isHost = localPlayer.isHost;
    final backgroundColor = impostorWon ? Colors.red[900]! : Colors.teal[900]!;
    final title = impostorWon ? "¡Victoria del Impostor!" : "¡Victoria Civil!";
    
    String formatName(String name) => name.contains('@') ? name.split('@')[0] : name;
    
    final impostorName = formatName(impostorPlayer.username);
    final subtitle = impostorWon 
        ? "El impostor engañó a todos. Era $impostorName."
        : "¡El impostor fue descubierto! Era $impostorName.";

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                impostorWon ? Icons.sentiment_very_dissatisfied : Icons.sentiment_very_satisfied,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Detalles de la votación
              const Text(
                'Resultados de los Votos',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 150),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: voteMap.entries.length,
                  itemBuilder: (ctx, index) {
                    final entry = voteMap.entries.elementAt(index);
                    final voterRaw = roomPlayers.firstWhere((p) => p.userId == entry.key, orElse: () => impostorPlayer).username;
                    final targetRaw = roomPlayers.firstWhere((p) => p.userId == entry.value, orElse: () => impostorPlayer).username;
                    
                    final voterName = formatName(voterRaw);
                    final targetName = formatName(targetRaw);
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '$voterName votó por $targetName',
                        style: const TextStyle(color: Colors.white60, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              if (isHost) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: backgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    context.read<ImpostorBloc>().add(const NextRoundImpostorGame());
                    // Cerramos el modal. La navegación la hace GameBoardScreen.
                    Navigator.of(context).pop();
                  },
                  child: const Text('Siguiente Ronda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    context.read<ImpostorBloc>().add(const RestartImpostorGame());
                    // Esperar un momento para asegurar que el evento se envíe antes de desmontar el Bloc
                    await Future.delayed(const Duration(milliseconds: 300));
                    if (!context.mounted) return;
                    Navigator.of(context).popUntil((route) => route.settings.name == AppRoutes.waitingRoom || route.isFirst);
                  },
                  child: const Text('Abandonar y Cerrar Partida', style: TextStyle(color: Colors.white70)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.settings.name == AppRoutes.waitingRoom || route.isFirst);
                  },
                  child: const Text('Solo Abandonar', style: TextStyle(color: Colors.white70)),
                ),
              ] else ...[
                const Text(
                  'Esperando a que el anfitrión inicie otra ronda...',
                  style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.settings.name == AppRoutes.waitingRoom || route.isFirst);
                  },
                  child: const Text('Salir al Lobby', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
