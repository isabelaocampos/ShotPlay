import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shotplay_app/src/core/constants/game_event_types.dart';
import 'package:shotplay_app/src/domain/repositories/game_event_repository.dart';
import 'package:shotplay_app/src/features/impostor/domain/entities/impostor_entities.dart';
import 'package:shotplay_app/src/features/impostor/domain/usecases/generate_roles_use_case.dart';
import 'package:shotplay_app/src/features/impostor/domain/usecases/emit_impostor_roles_usecase.dart';
import 'impostor_event.dart';
import 'impostor_state.dart';

class ImpostorBloc extends Bloc<ImpostorEvent, ImpostorState> {
  final GenerateRolesUseCase _generateRolesUseCase;
  final EmitImpostorRolesUseCase _emitRolesUseCase;
  final GameEventRepository _gameEventRepository;
  final String _currentUserId; // ID del usuario local (Supabase Auth)

  StreamSubscription? _eventSubscription;

  ImpostorBloc({
    required GenerateRolesUseCase generateRolesUseCase,
    required EmitImpostorRolesUseCase emitRolesUseCase,
    required GameEventRepository gameEventRepository,
    required String currentUserId,
  })  : _generateRolesUseCase = generateRolesUseCase,
        _emitRolesUseCase = emitRolesUseCase,
        _gameEventRepository = gameEventRepository,
        _currentUserId = currentUserId,
        super(ImpostorInitial()) {
    
    on<StartRoleDistribution>(_onStartDistribution);
    on<OnImpostorDataReceived>(_onDataReceived);

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
  ) {
    final List? players = event.payload['players'];
    if (players == null) return;

    // FILTRADO DE SEGURIDAD: Buscar solo mi información
    final myData = players.firstWhere(
      (p) => p['playerId'] == _currentUserId,
      orElse: () => null,
    );

    if (myData != null) {
      emit(ImpostorRoleAssigned(
        role: myData['role'] == PlayerRole.impostor.name 
            ? PlayerRole.impostor 
            : PlayerRole.civil,
        word: myData['word'], 
        hint: myData['hint'] ?? '',
        category: myData['category'] ?? '',
      ));
    } else {
      emit(const ImpostorError("No se encontró información para tu usuario en esta partida."));
    }
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    return super.close();
  }
}