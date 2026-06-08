import '../entities/impostor_entities.dart';

abstract class ImpostorWordRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<CategoryEntity> getRandomCategory();
}
