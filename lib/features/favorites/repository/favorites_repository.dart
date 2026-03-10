import 'package:nameswipe/models/favorite_model.dart';
import 'package:nameswipe/services/cache/favorites_service.dart';

class FavoritesRepository {
  FavoritesRepository({required FavoritesService favoritesService})
      : _favService = favoritesService;
  final FavoritesService _favService;

  List<FavoriteModel> getFavorites({
    String? gender,
    String? sortBy,
  }) {
    var favs = _favService.getAllFavorites();

    // Filter by gender
    if (gender != null) {
      favs = favs.where((f) => f.gender == gender).toList();
    }

    // Sort
    switch (sortBy) {
      case 'oldest':
        favs.sort((a, b) => a.favoritedAt.compareTo(b.favoritedAt));
      case 'az':
        favs.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case 'za':
        favs.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      default: // newest
        favs.sort((a, b) => b.favoritedAt.compareTo(a.favoritedAt));
    }

    return favs;
  }

  Future<void> removeFavorite(String name, String category) async {
    await _favService.removeFavorite(name, category);
  }

  bool isFavorite(String name, String category) {
    return _favService.isFavorite(name, category);
  }

  Future<void> addFavorite(FavoriteModel fav) async {
    await _favService.addFavorite(fav);
  }

  int get count => _favService.count;
}
