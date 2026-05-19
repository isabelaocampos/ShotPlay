class TrapState {
  const TrapState({
    required this.square,
    required this.ownerPlayerId,
    required this.ownerUsername,
  });

  final int square;
  final String ownerPlayerId;
  final String ownerUsername;

  Map<String, dynamic> toJson() => {
        'square': square,
        'ownerPlayerId': ownerPlayerId,
        'ownerUsername': ownerUsername,
      };

  factory TrapState.fromJson(Map<String, dynamic> json) {
    return TrapState(
      square: (json['square'] as num).toInt(),
      ownerPlayerId: json['ownerPlayerId'] as String? ?? '',
      ownerUsername: json['ownerUsername'] as String? ?? '',
    );
  }
}