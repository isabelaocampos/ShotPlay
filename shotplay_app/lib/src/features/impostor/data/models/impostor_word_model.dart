import '../../domain/entities/impostor_entities.dart';

class WordModel extends WordEntity {
  WordModel({required super.word, required super.hint});

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      word: json['word'] as String,
      hint: json['hint'] as String,
    );
  }
}

class CategoryModel extends CategoryEntity {
  CategoryModel({required super.name, required List<WordModel> super.words});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json['name'] as String,
      words: (json['words'] as List)
          .map((w) => WordModel.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }
}
