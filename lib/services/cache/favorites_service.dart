import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:namora/models/favorite_model.dart';

class FavoritesService {
  Box<String> get _box => Hive.box<String>('favorites');

  String _key(String name, String category) => '${name}_$category';

  Future<void> addFavorite(FavoriteModel fav) async {
    await _box.put(_key(fav.name, fav.category), jsonEncode(fav.toJson()));
  }

  Future<void> removeFavorite(String name, String category) async {
    await _box.delete(_key(name, category));
  }

  bool isFavorite(String name, String category) {
    return _box.containsKey(_key(name, category));
  }

  List<FavoriteModel> getAllFavorites() {
    return _box.values.map((jsonStr) {
      return FavoriteModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    }).toList();
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  int get count => _box.length;
}
