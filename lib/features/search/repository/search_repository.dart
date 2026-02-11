import 'package:nameswipe/models/name_model.dart';
import 'package:nameswipe/services/cache/database_service.dart';

class SearchRepository {
  SearchRepository({required DatabaseService db}) : _db = db;
  final DatabaseService _db;

  Future<List<NameModel>> search({
    required String query,
    String? gender,
    List<String>? categories,
    List<String>? origins,
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = await _db.searchNames(
      query: query,
      gender: gender,
      categories: categories,
      origins: origins,
      limit: limit,
      offset: offset,
    );
    return rows.map((r) => NameModel.fromJson(r)).toList();
  }

  Future<List<String>> getAvailableCategories() async {
    final rows = await _db.getDistinctCategories();
    return rows.map((r) => r['category'] as String).toList();
  }

  Future<List<String>> getAvailableOrigins() async {
    final rows = await _db.getDistinctOrigins();
    return rows.map((r) => r['origin'] as String).toList();
  }
}
