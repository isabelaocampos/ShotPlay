import 'package:equatable/equatable.dart';

/// Value object representing the outcome of a dice roll.
class DiceResult extends Equatable {
  const DiceResult(this.value);

  final int value;

  /// Ensure dice value is strictly between 1 and 6.
  bool get isValid => value >= 1 && value <= 6;

  @override
  List<Object?> get props => [value];
}
