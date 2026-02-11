import 'package:nameswipe/services/cache/cache_service.dart';
import 'package:nameswipe/services/cache/cache_keys.dart';
import 'package:nameswipe/services/cache/database_service.dart';

class SettingsRepository {
  SettingsRepository({required CacheService cache, required DatabaseService db})
      : _cache = cache,
        _db = db;
  final CacheService _cache;
  final DatabaseService _db;

  bool get isDarkMode => _cache.getBool(CacheKeys.isDarkMode) ?? false;

  Future<int> getTotalNames() => _db.getTotalNameCount();
  Future<int> getSwipeCount() => _db.getSwipeHistoryCount();
  Future<int> getFavoritesCount() => _db.getFavoritesCount();

  Future<void> clearSwipeHistory() => _db.clearSwipeHistory();
}
