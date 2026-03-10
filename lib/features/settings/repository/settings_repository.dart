import 'package:namora/services/cache/cache_service.dart';
import 'package:namora/services/cache/cache_keys.dart';
import 'package:namora/services/cache/favorites_service.dart';

class SettingsRepository {
  SettingsRepository({required CacheService cache, required FavoritesService favorites})
      : _cache = cache,
        _favorites = favorites;
  final CacheService _cache;
  final FavoritesService _favorites;

  bool get isDarkMode => _cache.getBool(CacheKeys.isDarkMode) ?? false;
  int get favoritesCount => _favorites.count;
}
