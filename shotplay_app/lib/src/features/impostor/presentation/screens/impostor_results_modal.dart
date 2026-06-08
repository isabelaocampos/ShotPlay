import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final subtitle = impostorWon 
        ? "El impostor engañó a todos. Era ${impostorPlayer.username}."
        : "¡El impostor fue descubierto! Era ${impostorPlayer.username}.";

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
                    final voterName = roomPlayers.firstWhere((p) => p.userId == entry.key, orElse: () => impostorPlayer).username;
                    final targetName = roomPlayers.firstWhere((p) => p.userId == entry.value, orElse: () => impostorPlayer).username;
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
              if (isHost)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: backgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    context.read<ImpostorBloc>().add(const RestartImpostorGame());
                    // Cerramos todo y volvemos al lobby (el non-host volverá porque escucha el evento impostorGameRestarted)
                    Navigator.of(context).popUntil((route) => route.settings.name == '/home' || route.isFirst);
                  },
                  child: const Text('Jugar Otra Vez', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                )
              else
                const Text(
                  'Esperando a que el anfitrión inicie otra partida...',
                  style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
