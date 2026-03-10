import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namora/services/cache/cache_keys.dart';
import 'package:namora/services/cache/cache_service.dart';
import 'package:namora/services/cache/favorites_service.dart';
import 'package:namora/services/network/dio_client.dart';
import 'package:namora/services/network/api_service.dart';

// Service Providers
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final apiServiceProvider = Provider<NamesApiService>((ref) {
  return NamesApiService(dioClient: ref.watch(dioClientProvider));
});

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService.instance;
});

final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  return FavoritesService();
});

// Cross-screen favorites refresh trigger
final favoritesRefreshProvider = StateProvider<int>((ref) => 0);

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
