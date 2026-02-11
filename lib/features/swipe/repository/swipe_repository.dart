import 'package:nameswipe/models/name_model.dart';
import 'package:nameswipe/models/filter_model.dart';
import 'package:nameswipe/services/cache/database_service.dart';

class SwipeRepository {
  SwipeRepository({required DatabaseService db}) : _db = db;
  final DatabaseService _db;

  Future<List<NameModel>> getNextBatch({
    int limit = 20,
    FilterModel? filter,
  }) async {
    final rows = await _db.getUnswipedNames(
      limit: limit,
      gender: filter?.gender,
      categories: filter?.categories.isNotEmpty == true
          ? filter!.categories.toList()
          : null,
      origins: filter?.origins.isNotEmpty == true
          ? filter!.origins.toList()
          : null,
    );
    return rows.map((r) => NameModel.fromJson(r)).toList();
  }

  Future<void> recordSwipe(NameModel name, bool isFavorite) async {
    await _db.recordSwipe(
      name.name,
      name.category,
      isFavorite ? 'favorite' : 'skip',
    );
    if (isFavorite) {
      await _db.addFavorite({
        'name': name.name,
        'gender': name.gender,
        'origin': name.origin,
        'meaning': name.meaning,
        'category': name.category,
        'favorited_at': DateTime.now().toIso8601String(),
      });
    }
  }
}
