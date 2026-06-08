import 'package:shotplay_app/src/features/impostor/domain/entities/impostor_entities.dart';

abstract class ImpostorState {
  const ImpostorState();
}

class ImpostorInitial extends ImpostorState {}

class ImpostorLoading extends ImpostorState {}

class ImpostorRoleAssigned extends ImpostorState {
  final PlayerRole role;
  final String? word; // Será null si es impostor
  final String hint;
  final String category;

  const ImpostorRoleAssigned({
    required this.role,
    this.word,
    required this.hint,
    required this.category,
  });
}

class ImpostorError extends ImpostorState {
  final String message;
  const ImpostorError(this.message);
}