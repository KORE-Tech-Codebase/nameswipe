import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nameswipe/services/cache/cache_keys.dart';
import 'package:nameswipe/services/cache/cache_service.dart';
import 'package:nameswipe/services/cache/database_service.dart';
import 'package:nameswipe/services/network/dio_client.dart';
import 'package:nameswipe/services/network/api_service.dart';

// Service Providers
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final apiServiceProvider = Provider<NamesApiService>((ref) {
  return NamesApiService(dioClient: ref.watch(dioClientProvider));
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService.instance;
});

// Theme Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier(ref.watch(cacheServiceProvider));
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier(this._cacheService)
      : super(_cacheService.getBool(CacheKeys.isDarkMode) ?? false);

  final CacheService _cacheService;

  void toggle() {
    state = !state;
    _cacheService.setBool(CacheKeys.isDarkMode, state);
  }

  void setDarkMode(bool value) {
    state = value;
    _cacheService.setBool(CacheKeys.isDarkMode, value);
  }
}
