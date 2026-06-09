import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/room_player.dart';
import '../impostor_bloc.dart';
import '../impostor_event.dart';
import '../impostor_state.dart';
import 'impostor_results_modal.dart';

import '../../../../domain/repositories/game_event_repository.dart';
import '../../../../core/utils/supabase_safe.dart';
import '../../domain/repositories/impostor_word_repository_impl.dart';
import '../../domain/usecases/emit_impostor_roles_usecase.dart';
import '../../domain/usecases/emit_impostor_vote_usecase.dart';
import '../../domain/usecases/generate_roles_use_case.dart';
import '../../data/repositories/impostor_vote_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImpostorVotingScreen extends StatelessWidget {
  final List<RoomPlayer> roomPlayers;

  const ImpostorVotingScreen({super.key, required this.roomPlayers});

  static Route route({
    required List<RoomPlayer> roomPlayers,
    required List<String> alivePlayerIds,
    required String roomId,
    required String impostorId,
  }) {
    return MaterialPageRoute(
      builder: (context) {
        final gameEvents = context.read<GameEventRepository>();
        final currentUserId = safeCurrentUserId() ?? '';
        final voteRepo = ImpostorVoteRepositoryImpl(supabase: Supabase.instance.client);
        final emitVoteUseCase = EmitImpostorVoteUseCase(voteRepo);

        return BlocProvider(
          create: (context) => ImpostorBloc(
            generateRolesUseCase: GenerateRolesUseCase(ImpostorWordRepositoryImpl()),
            emitRolesUseCase: EmitImpostorRolesUseCase(gameEvents),
            gameEventRepository: gameEvents,
            voteRepository: voteRepo,
            emitVoteUseCase: emitVoteUseCase,
            currentUserId: currentUserId,
            roomId: roomId,
          )..add(StartVotingPhase(
              alivePlayerIds: alivePlayerIds,
              impostorId: impostorId,
            )),
          child: ImpostorVotingScreen(roomPlayers: roomPlayers),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImpostorBloc, ImpostorState>(
      listener: (context, state) {
        if (state is ImpostorError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
          );
        } else if (state is ImpostorGameOverState) {
          // Mostrar el modal de resultados
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => BlocProvider.value(
              value: context.read<ImpostorBloc>(),
              child: ImpostorResultsModal(
                impostorWon: state.impostorWon,
                impostorId: state.impostorId,
                roomPlayers: roomPlayers,
                voteMap: state.voteMap,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ImpostorLoading || state is ImpostorInitial) {
          return const Scaffold(
            backgroundColor: Color(0xFF1A1A1A),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ImpostorError) {
          return Scaffold(
            backgroundColor: const Color(0xFF1A1A1A),
            appBar: AppBar(title: const Text('Error', style: TextStyle(color: Colors.white)), backgroundColor: Colors.black),
            body: Center(child: Text(state.message, style: const TextStyle(color: Colors.white))),
          );
        }

        // Si llegamos aquí, asumimos que estamos en VotingState o GameOverState (manteniendo la vista de fondo)
        final votingState = state is ImpostorVotingState ? state : null;
        
        final currentUserId = context.read<ImpostorBloc>().currentUserId;
        
        // Verificar si el usuario actual ya votó
        final hasVoted = votingState?.votes.any((vote) => vote.voterId == currentUserId) ?? true;

        // Excluir al jugador local (auto-voto no permitido)
        final votablePlayers = roomPlayers.where((p) {
          final isAlive = votingState?.alivePlayerIds.contains(p.userId) ?? false;
          return isAlive && p.userId != currentUserId;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Fase de Votación', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.black87,
            automaticallyImplyLeading: false,
          ),
          backgroundColor: const Color(0xFF1A1A1A),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  '¿Quién crees que es el impostor?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (hasVoted) ...[
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.purple),
                          SizedBox(height: 16),
                          Text(
                            'Esperando a los demás...',
                            style: TextStyle(color: Colors.white70, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  )
                ] else ...[
                  if (votablePlayers.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No hay otros jugadores vivos para votar.',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: votablePlayers.length,
                        itemBuilder: (context, index) {
                          final player = votablePlayers[index];
                          return _PlayerVoteCard(
                            player: player,
                            onVote: () {
                              context.read<ImpostorBloc>().add(SubmitVote(player.userId));
                            },
                          );
                        },
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlayerVoteCard extends StatelessWidget {
  final RoomPlayer player;
  final VoidCallback onVote;

  const _PlayerVoteCard({
    required this.player,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    String formatName(String name) => name.contains('@') ? name.split('@')[0] : name;
    final displayName = formatName(player.username);
    
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text('Confirmar voto', style: TextStyle(color: Colors.white)),
            content: Text(
              '¿Estás seguro de que deseas votar por $displayName?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () {
                  Navigator.pop(ctx);
                  onVote();
                },
                child: const Text('Votar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      child: Card(
        color: Colors.grey[850],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[700],
              backgroundImage: player.avatarUrl != null ? NetworkImage(player.avatarUrl!) : null,
              child: player.avatarUrl == null
                  ? Text(
                      displayName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
