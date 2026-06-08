import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../../data/models/impostor_word_model.dart';
import '../entities/impostor_entities.dart';
import 'impostor_word_repository.dart';

class ImpostorWordRepositoryImpl implements ImpostorWordRepository {
	ImpostorWordRepositoryImpl({this.assetPath = 'assets/impostor/words.json'});

	final String assetPath;
	List<CategoryEntity>? _cachedCategories;

	@override
	Future<List<CategoryEntity>> getCategories() async {
		if (_cachedCategories != null) return _cachedCategories!;

		final rawJson = await rootBundle.loadString(assetPath);
		final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
		final categories =
				((decoded['categories'] as List<dynamic>?) ?? const <dynamic>[])
						.map(
							(item) => CategoryModel.fromJson(
								Map<String, dynamic>.from(item as Map),
							),
						)
						.toList();

		if (categories.isEmpty) {
			throw StateError('No hay categorías disponibles para el modo Impostor.');
		}

		_cachedCategories = categories;
		return categories;
	}

	@override
	Future<CategoryEntity> getRandomCategory() async {
		final categories = await getCategories();
		return categories[Random().nextInt(categories.length)];
	}
}
