import 'package:equatable/equatable.dart';

/// Value object representing whose turn it is currently.
class PlayerTurn extends Equatable {
  const PlayerTurn(this.playerId);

  final String playerId;

  @override
  List<Object?> get props => [playerId];
}
