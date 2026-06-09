import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shotplay_app/src/core/routing/app_routes.dart';
import 'package:shotplay_app/src/core/routing/game_navigator.dart';
import 'package:shotplay_app/src/core/utils/supabase_safe.dart';
import 'package:shotplay_app/src/domain/entities/room_player.dart';
import 'package:shotplay_app/src/domain/entities/room_session.dart';
import 'package:shotplay_app/src/domain/repositories/game_event_repository.dart';
import 'package:shotplay_app/src/features/impostor/domain/entities/impostor_entities.dart';
import 'package:shotplay_app/src/features/impostor/domain/repositories/impostor_word_repository_impl.dart';
import 'package:shotplay_app/src/features/impostor/domain/usecases/emit_impostor_roles_usecase.dart';
import 'package:shotplay_app/src/features/impostor/domain/usecases/generate_roles_use_case.dart';
import 'package:shotplay_app/src/features/impostor/presentation/impostor_bloc.dart';
import 'package:shotplay_app/src/features/impostor/presentation/impostor_event.dart';
import 'package:shotplay_app/src/features/impostor/presentation/impostor_state.dart';
import 'package:shotplay_app/src/features/impostor/data/repositories/impostor_vote_repository_impl.dart';
import 'package:shotplay_app/src/features/impostor/domain/usecases/emit_impostor_vote_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImpostorRevealScreen extends StatefulWidget {
  const ImpostorRevealScreen({
    super.key,
    required this.room,
    required this.players,
    required this.isAdmin,
    this.isReconnect = false,
    this.persistedGameState,
  });

  final RoomSession room;
  final List<RoomPlayer> players;
  final bool isAdmin;
  final bool isReconnect;
  final Map<String, dynamic>? persistedGameState;

  @override
  State<ImpostorRevealScreen> createState() => _ImpostorRevealScreenState();
}

class _ImpostorRevealScreenState extends State<ImpostorRevealScreen> {
  late final ImpostorBloc _bloc;
  bool _readyToContinue = false;
  bool _distributionTriggered = false;
  bool _navigated = false;
  bool _revealRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_distributionTriggered) return;

    final gameEvents = context.read<GameEventRepository>();
    final currentUserId = safeCurrentUserId() ?? '';
    final voteRepo = ImpostorVoteRepositoryImpl(supabase: Supabase.instance.client);
    final emitVoteUseCase = EmitImpostorVoteUseCase(voteRepo);

    _bloc = ImpostorBloc(
      generateRolesUseCase: GenerateRolesUseCase(ImpostorWordRepositoryImpl()),
      emitRolesUseCase: EmitImpostorRolesUseCase(gameEvents),
      gameEventRepository: gameEvents,
      voteRepository: voteRepo,
      emitVoteUseCase: emitVoteUseCase,
      currentUserId: currentUserId,
      roomId: widget.room.idRoom.toString(),
    );
    _distributionTriggered = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      if (widget.isReconnect) {
        _navigated = true;
        // Intentar recuperar el rol local
        _recoverLocalRole().then((info) {
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.gameBoard,
            arguments: <String, dynamic>{
              'room': widget.room,
              'players': widget.players,
              'isAdmin': widget.isAdmin,
              'isReconnect': widget.isReconnect,
              'persistedGameState': widget.persistedGameState,
              'impostorInfo': info,
            },
          );
        });
        return;
      }

      if (widget.isAdmin && !_revealRequested) {
        _revealRequested = true;
        _bloc.add(
          StartRoleDistribution(
            playerIds: widget.players.map((player) => player.userId).toList(),
            impostorCount: widget.room.lobbySettings.impostor.impostorCount,
          ),
        );
        debugPrint(
          '[IMPOSTOR] Distributing roles with '
          '${widget.room.lobbySettings.impostor.impostorCount} impostor(s)',
        );
      }
    });
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<Map<String, dynamic>> _recoverLocalRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('impostor_role_${widget.room.idRoom}');
      if (data != null) {
        return jsonDecode(data);
      }
    } catch (e) {
      // Ignore
    }
    return {
      'role': 'civil',
      'word': '???',
      'hint': 'Reconectado sin datos',
      'category': 'Desconocida',
    };
  }

  void _continueToBoard(ImpostorRoleAssigned state) {
    if (_navigated) return;
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      GameNavigator.pushImpostorPlayPhase(
        context: context,
        room: widget.room,
        players: widget.players,
        isAdmin: widget.isAdmin,
        isReconnect: widget.isReconnect,
        persistedGameState: widget.persistedGameState,
        impostorInfo: <String, dynamic>{
          'role': state.role.name,
          'word': state.word,
          'hint': state.hint,
          'category': state.category,
          'globalImpostorId': state.globalImpostorId,
        },
      );
    });
  }

  // Evitar que el usuario retroceda a la sala de espera una vez que el juego comenzó
  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<ImpostorBloc, ImpostorState>(
        listener: (context, state) {
          if (state is ImpostorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final roleState = state is ImpostorRoleAssigned ? state : null;
          final isImpostor = roleState?.role == PlayerRole.impostor;
          final hasRole = roleState != null;
          final showCardFace = _readyToContinue && hasRole;

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) => _onWillPop(),
            child: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFF180B28), Color(0xFF09070F)],
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      const _GlowAccent(
                        alignment: Alignment.topRight,
                        color: Color(0xFFF01FFF),
                      ),
                      const _GlowAccent(
                        alignment: Alignment.bottomLeft,
                        color: Color(0xFF07FCFE),
                      ),
                      Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF12101A).withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(0xFF07FCFE).withValues(alpha: 0.24),
                                    ),
                                  ),
                                  child: const Text(
                                    'MODO IMPOSTOR',
                                    style: TextStyle(
                                      color: Color(0xFFCBD5E1),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Tarjeta secreta de revelación',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    height: 1.05,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _readyToContinue
                                      ? 'Tu identidad ya está visible. Revisa la información y continúa cuando estés listo.'
                                      : 'Pulsa para revelar tu rol.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFCBD5E1),
                                    fontSize: 14,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                GestureDetector(
                                  onTap: hasRole ? () => setState(() => _readyToContinue = true) : null,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 260),
                                    curve: Curves.easeOutCubic,
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: showCardFace
                                            ? [
                                                const Color(0xFF21162E),
                                                const Color(0xFF0E0A15),
                                              ]
                                            : [
                                                const Color(0xFF130C1E),
                                                const Color(0xFF08060D),
                                              ],
                                      ),
                                      border: Border.all(
                                        color: showCardFace
                                            ? (isImpostor
                                                ? const Color(0xFFF01FFF).withValues(alpha: 0.5)
                                                : const Color(0xFF07FCFE).withValues(alpha: 0.45))
                                            : const Color(0xFF07FCFE).withValues(alpha: 0.22),
                                        width: 1.4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFF01FFF).withValues(alpha: showCardFace ? 0.18 : 0.08),
                                          blurRadius: 26,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 240),
                                      child: showCardFace
                                          ? _RevealedCard(
                                              key: const ValueKey<String>('revelada'),
                                              state: roleState,
                                            )
                                          : _HiddenCard(
                                              key: const ValueKey<String>('oculta'),
                                              state: state,
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: showCardFace ? () => _continueToBoard(roleState) : null,
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: const Color(0xFFF01FFF),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text(
                                      'Estoy listo',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _readyToContinue
                                      ? 'La siguiente pantalla mostrará el estado de la ronda.'
                                      : 'Primero revela tu carta; después podrás avanzar.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (state is ImpostorLoading)
                        const Positioned.fill(
                          child: ColoredBox(
                            color: Color(0xAA05040A),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HiddenCard extends StatelessWidget {
  const _HiddenCard({super.key, required this.state});

  final ImpostorState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey<String>('oculta-contenido'),
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 220),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF130C1E).withValues(alpha: 0.95),
                  const Color(0xFF09070F).withValues(alpha: 0.98),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF07FCFE).withValues(alpha: 0.16),
              ),
            ),
            child: Stack(
              children: [
                const _CircuitLine(top: 24, left: 20, width: 120),
                const _CircuitLine(top: 64, right: 18, width: 140),
                const _CircuitLine(top: 146, left: 36, width: 160),
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF07FCFE), Color(0xFFF01FFF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF07FCFE).withValues(alpha: 0.28),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.visibility_off_rounded,
                      color: Colors.white,
                      size: 54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pulsa para revelar tu rol',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'La carta se abrirá para mostrar tu información secreta.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          if (state is ImpostorLoading)
            const Text(
              'Distribuyendo roles...',
              style: TextStyle(
                color: Color(0xFF07FCFE),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _RevealedCard extends StatelessWidget {
  const _RevealedCard({super.key, required this.state});

  final ImpostorRoleAssigned state;

  @override
  Widget build(BuildContext context) {
    final isImpostor = state.role == PlayerRole.impostor;
    return Column(
      key: const ValueKey<String>('revelada-contenido'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 220),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isImpostor
                  ? [
                      const Color(0xFF2A1037),
                      const Color(0xFF0D0814),
                    ]
                  : [
                      const Color(0xFF0D2034),
                      const Color(0xFF081019),
                    ],
            ),
            border: Border.all(
              color: isImpostor
                  ? const Color(0xFFF01FFF).withValues(alpha: 0.50)
                  : const Color(0xFF07FCFE).withValues(alpha: 0.46),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isImpostor
                            ? const Color(0xFFF01FFF).withValues(alpha: 0.16)
                            : const Color(0xFF07FCFE).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isImpostor ? 'IMPOSTOR' : 'CIVIL',
                        style: TextStyle(
                          color: isImpostor
                              ? const Color(0xFFF9A8D4)
                              : const Color(0xFF99F6E4),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.lock_open_rounded,
                      color: Color(0xFFF8FAFC),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isImpostor ? 'Tu objetivo es confundir al grupo.' : 'Tu objetivo es descubrir al impostor.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                if (isImpostor) ...[
                  _InfoLine(
                    label: 'Categoría secreta',
                    value: state.category,
                  ),
                  const SizedBox(height: 10),
                  _InfoLine(
                    label: 'Pista',
                    value: state.hint,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No se muestra la palabra secreta al impostor.',
                    style: TextStyle(
                      color: Color(0xFFF9A8D4),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ] else ...[
                  _InfoLine(
                    label: 'Palabra secreta',
                    value: state.word ?? 'Sin palabra disponible',
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isImpostor
              ? 'Recuérdala bien: la categoría y la pista serán tu única referencia.'
              : 'Comparte la palabra con cuidado y mantén la discusión fluida.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowAccent extends StatelessWidget {
  const _GlowAccent({required this.alignment, required this.color});

  final Alignment alignment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          margin: const EdgeInsets.all(24),
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: 0.26), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircuitLine extends StatelessWidget {
  const _CircuitLine({this.top, this.left, this.right, required this.width});

  final double? top;
  final double? left;
  final double? right;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Container(
        width: width,
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFF07FCFE).withValues(alpha: 0.35),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
