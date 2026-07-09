import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/database/database_providers.dart';
import 'package:spendly/core/database/mappers.dart';
import 'package:spendly/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:spendly/features/categories/domain/entities/category_entity.dart';
import 'package:spendly/features/categories/domain/repositories/categories_repository.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  CategoriesRepositoryImpl(this._ref);

  final Ref _ref;

  @override
  Future<void> add(CategoryEntity category) async {
    await _ref
        .read(appDatabaseProvider)
        .upsertCategory(categoryToCompanion(category));
    await _ref
        .read(activityRepositoryProvider)
        .recordEvent(
          kind: 'category',
          title: 'Added category',
          description:
              '${category.name} was added as an ${category.type.name} category.',
        );
  }

  @override
  Future<void> seedDefaultsIfNeeded() async {
    await _ref.read(appDatabaseProvider).seedDefaultCategoriesIfNeeded();
  }

  @override
  Future<void> softDelete(String categoryId) async {
    await _ref.read(appDatabaseProvider).softDeleteCategory(categoryId);
    await _ref
        .read(activityRepositoryProvider)
        .recordEvent(
          kind: 'category',
          title: 'Deleted category',
          description: 'A category was removed from active lists.',
        );
  }

  @override
  Future<void> update(CategoryEntity category) async {
    await _ref
        .read(appDatabaseProvider)
        .upsertCategory(categoryToCompanion(category));
    await _ref
        .read(activityRepositoryProvider)
        .recordEvent(
          kind: 'category',
          title: 'Updated category',
          description: '${category.name} category details were updated.',
        );
  }

  @override
  Stream<List<CategoryEntity>> watchAll() {
    return _ref
        .read(appDatabaseProvider)
        .watchCategories()
        .map(
          (rows) => rows
              .where((row) => row.id != 'cat_goal_transfer')
              .map((row) => row.toEntity())
              .toList(growable: false),
        );
  }

  @override
  Stream<List<CategoryEntity>> watchByType(String type) {
    return _ref
        .read(appDatabaseProvider)
        .watchCategories(type: type)
        .map(
          (rows) => rows
              .where((row) => row.id != 'cat_goal_transfer')
              .map((row) => row.toEntity())
              .toList(growable: false),
        );
  }
}

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepositoryImpl(ref);
});
