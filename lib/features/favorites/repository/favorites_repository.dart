import 'package:nameswipe/models/favorite_model.dart';
import 'package:nameswipe/services/cache/database_service.dart';

class FavoritesRepository {
  FavoritesRepository({required DatabaseService db}) : _db = db;
  final DatabaseService _db;

  Future<List<FavoriteModel>> getFavorites({
    String? gender,
    String? orderBy,
  }) async {
    final rows = await _db.getFavorites(gender: gender, orderBy: orderBy);
    return rows.map((r) => FavoriteModel.fromJson(r)).toList();
  }

  Future<void> removeFavorite(String name, String category) async {
    await _db.removeFavorite(name, category);
  }

  Future<bool> isFavorite(String name, String category) async {
    return _db.isFavorite(name, category);
  }

  Future<void> addFavorite(FavoriteModel fav) async {
    await _db.addFavorite(fav.toJson());
  }

  Future<int> getCount() async {
    return _db.getFavoritesCount();
  }
}
