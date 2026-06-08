enum PlayerRole { civil, impostor }

class WordEntity {
  final String word;
  final String hint;

  const WordEntity({required this.word, required this.hint});
}

class CategoryEntity {
  final String name;
  final List<WordEntity> words;

  const CategoryEntity({required this.name, required this.words});
}

class AssignedRole {
  final String playerId;
  final PlayerRole role;
  final String? word; // Null para impostores
  final String hint;
  final String category;

  AssignedRole({
    required this.playerId,
    required this.role,
    this.word,
    required this.hint,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    "playerId": playerId,
    "role": role.name,
    "word": word,
    "hint": hint,
    "category": category,
  };
}
