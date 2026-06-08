import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shotplay_app/src/core/constants/game_event_types.dart';
import 'package:shotplay_app/src/domain/repositories/game_event_repository.dart';
import 'package:shotplay_app/src/features/impostor/domain/entities/impostor_entities.dart';
import 'package:shotplay_app/src/features/impostor/domain/usecases/generate_roles_use_case.dart';
import 'package:shotplay_app/src/features/impostor/domain/usecases/emit_impostor_roles_usecase.dart';
import 'package:shotplay_app/src/features/impostor/domain/usecases/emit_impostor_vote_usecase.dart';
import 'package:shotplay_app/src/features/impostor/domain/repositories/impostor_vote_repository.dart';
import 'impostor_event.dart';
import 'impostor_state.dart';

class ImpostorBloc extends Bloc<ImpostorEvent, ImpostorState> {
  final GenerateRolesUseCase _generateRolesUseCase;
  final EmitImpostorRolesUseCase _emitRolesUseCase;
  final GameEventRepository _gameEventRepository;
  final ImpostorVoteRepository _voteRepository;
  final EmitImpostorVoteUseCase _emitVoteUseCase;
  final String _currentUserId; // ID del usuario local (Supabase Auth)
  final String _roomId;

  String get currentUserId => _currentUserId;

  StreamSubscription? _eventSubscription;
  StreamSubscription? _votesSubscription;

  // Variables para mantener estado local durante la votación
  List<String> _alivePlayerIds = [];
  String _impostorId = '';

  ImpostorBloc({
    required GenerateRolesUseCase generateRolesUseCase,
    required EmitImpostorRolesUseCase emitRolesUseCase,
    required GameEventRepository gameEventRepository,
    required ImpostorVoteRepository voteRepository,
    required EmitImpostorVoteUseCase emitVoteUseCase,
    required String currentUserId,
    required String roomId,
  })  : _generateRolesUseCase = generateRolesUseCase,
        _emitRolesUseCase = emitRolesUseCase,
        _gameEventRepository = gameEventRepository,
        _voteRepository = voteRepository,
        _emitVoteUseCase = emitVoteUseCase,
        _currentUserId = currentUserId,
        _roomId = roomId,
        super(ImpostorInitial()) {
    
    on<StartRoleDistribution>(_onStartDistribution);
    on<OnImpostorDataReceived>(_onDataReceived);
    on<SubmitVote>(_onSubmitVote);
    on<OnVotesUpdated>(_onVotesUpdated);
    on<RestartImpostorGame>(_onRestartGame);
    on<NextRoundImpostorGame>(_onNextRoundGame);
    on<StartVotingPhase>(_onStartVotingPhase);

    // Iniciar la escucha de eventos en tiempo real inmediatamente
    _listenToRealtimeEvents();
  }

  void _listenToRealtimeEvents() {
    _eventSubscription = _gameEventRepository.listenToEvents().listen((event) {
      if (event['appEventType'] == GameEventTypes.impostorRolesAssigned) {
        add(OnImpostorDataReceived(event));
      }
    });
  }

  Future<void> _onStartDistribution(
    StartRoleDistribution event,
    Emitter<ImpostorState> emit,
  ) async {
    try {
      emit(ImpostorLoading());

      // 0. Limpiar votos anteriores de esta sala
      await _voteRepository.clearVotes(_roomId);

      // 1. Lógica de negocio: Generar roles
      final roles = await _generateRolesUseCase.execute(
        playerIds: event.playerIds,
        impostorCount: event.impostorCount,
      );

      // 2. Infraestructura: Emitir por Supabase
      await _emitRolesUseCase.execute(roles);
      
      // El estado cambiará cuando llegue el broadcast a través de _onDataReceived
    } catch (e) {
      emit(ImpostorError("Error al distribuir roles: ${e.toString()}"));
    }
  }

  void _onDataReceived(
    OnImpostorDataReceived event,
    Emitter<ImpostorState> emit,
  ) async {
    final List? players = event.payload['players'];
    if (players == null) return;

    // FILTRADO DE SEGURIDAD: Buscar solo mi información
    final myData = players.firstWhere(
      (p) => p['playerId'] == _currentUserId,
      orElse: () => null,
    );

    // Buscar quién es el impostor global
    final globalImpostor = players.firstWhere(
      (p) => p['role'] == PlayerRole.impostor.name,
      orElse: () => players.first,
    );

    if (myData != null) {
      final state = ImpostorRoleAssigned(
        role: myData['role'] == PlayerRole.impostor.name 
            ? PlayerRole.impostor 
            : PlayerRole.civil,
        word: myData['word'], 
        hint: myData['hint'] ?? '',
        category: myData['category'] ?? '',
        globalImpostorId: globalImpostor['playerId'],
      );
      
      // Guardar en almacenamiento local para reconexiones
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('impostor_role_$_roomId', jsonEncode({
          'role': state.role.name,
          'word': state.word,
          'hint': state.hint,
          'category': state.category,
        }));
      } catch (e) {
        // Ignorar error de guardado
      }
      
      emit(state);
    } else {
      emit(const ImpostorError("No se encontró información para tu usuario en esta partida."));
    }
  }

  void _onStartVotingPhase(
    StartVotingPhase event,
    Emitter<ImpostorState> emit,
  ) {
    _alivePlayerIds = event.alivePlayerIds;
    _impostorId = event.impostorId;
    
    // Iniciar escucha del stream de votos
    _votesSubscription?.cancel();
    _votesSubscription = _voteRepository.watchVotes(_roomId).listen((votes) {
      if (!isClosed) {
        add(OnVotesUpdated(votes));
      }
    });

    emit(ImpostorVotingState(
      votes: const [],
      alivePlayerIds: _alivePlayerIds,
      impostorId: _impostorId,
    ));
  }

  Future<void> _onSubmitVote(
    SubmitVote event,
    Emitter<ImpostorState> emit,
  ) async {
    try {
      final vote = ImpostorVote(voterId: _currentUserId, targetId: event.targetPlayerId);
      await _emitVoteUseCase.execute(_roomId, vote);
      // El estado se actualizará vía el stream OnVotesUpdated
    } catch (e) {
      if (!isClosed) {
        emit(ImpostorError("Error al emitir voto: ${e.toString()}"));
      }
    }
  }

  void _onVotesUpdated(
    OnVotesUpdated event,
    Emitter<ImpostorState> emit,
  ) {
    final votes = event.votes;
    
    if (votes.length >= _alivePlayerIds.length) {
      // Todos han votado, calcular veredicto
      final verdict = calculateVerdict(votes, _impostorId);
      if (!isClosed) {
        emit(ImpostorGameOverState(
          impostorWon: verdict.impostorWon,
          impostorId: verdict.impostorId,
          voteMap: verdict.voteMap,
        ));
      }
      _votesSubscription?.cancel();
    } else {
      // Aún faltan votos
      if (!isClosed) {
        emit(ImpostorVotingState(
          votes: votes,
          alivePlayerIds: _alivePlayerIds,
          impostorId: _impostorId,
        ));
      }
    }
  }

  Future<void> _onRestartGame(
    RestartImpostorGame event,
    Emitter<ImpostorState> emit,
  ) async {
    try {
      await _gameEventRepository.emitEvent({
        'appEventType': GameEventTypes.impostorGameRestarted,
        'roomId': _roomId,
        'payload': {},
      });
    } catch (e) {
      if (!isClosed) {
        emit(ImpostorError("Error al reiniciar juego: ${e.toString()}"));
      }
    }
  }

  Future<void> _onNextRoundGame(
    NextRoundImpostorGame event,
    Emitter<ImpostorState> emit,
  ) async {
    try {
      await _gameEventRepository.emitEvent({
        'appEventType': GameEventTypes.impostorGameNextRound,
        'roomId': _roomId,
        'payload': {},
      });
    } catch (e) {
      if (!isClosed) {
        emit(ImpostorError("Error al iniciar siguiente ronda: ${e.toString()}"));
      }
    }
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    _votesSubscription?.cancel();
    return super.close();
  }
}