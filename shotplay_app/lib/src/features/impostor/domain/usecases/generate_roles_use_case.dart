import 'dart:math';
import '../entities/impostor_entities.dart';
import '../repositories/impostor_word_repository.dart';

class GenerateRolesUseCase {
  final ImpostorWordRepository repository;

  GenerateRolesUseCase(this.repository);

  Future<List<AssignedRole>> execute({
    required List<String> playerIds,
    required int impostorCount,
  }) async {
    if (impostorCount >= playerIds.length) {
      throw Exception("Too many impostors for the number of players");
    }

    // 1. Obtener palabra aleatoria
    final category = await repository.getRandomCategory();
    final wordObj = category.words[Random().nextInt(category.words.length)];

    // 2. Seleccionar índices para impostores
    final random = Random();
    final impostorIndices = <int>{};
    while (impostorIndices.length < impostorCount) {
      impostorIndices.add(random.nextInt(playerIds.length));
    }

    // 3. Generar lista de roles
    final List<AssignedRole> results = [];
    for (int i = 0; i < playerIds.length; i++) {
      final isImpostor = impostorIndices.contains(i);
      
      results.add(AssignedRole(
        playerId: playerIds[i],
        role: isImpostor ? PlayerRole.impostor : PlayerRole.civil,
        // Regla de oro: El impostor nunca recibe la palabra
        word: isImpostor ? null : wordObj.word,
        hint: wordObj.hint,
        category: category.name,
      ));
    }

    return results;
  }
}
