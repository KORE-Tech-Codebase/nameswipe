abstract final class AppConstants {
  // API
  static const String apiBaseUrl = 'https://comm-app-data-api.vercel.app/api/v1/names-app';
  static const String apiKey = 'rehan-komail-comm-app-api-service';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 100;
  static const int defaultFirstPage = 1;

  // Swipe
  static const int swipeBatchSize = 20;
  static const int swipePreloadThreshold = 5;
  static const int swipeCategoriesPerFetch = 4;

  // Search
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);

  // App Info
  static const String appName = 'NameSwipe';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Swipe to find the perfect baby name';

  // Bundled Data
  static const String bundledNamesAsset = 'assets/data/names_bundled.json';

  // Categories
  static const List<String> categories = [
    'african', 'celtic', 'christian', 'east_asian', 'english',
    'european', 'french', 'german', 'greek', 'hindu',
    'italian', 'jewish', 'latin', 'muslim', 'scandinavian',
    'slavic', 'spanish', 'turkish', 'other',
  ];

  static String categoryDisplayName(String category) {
    switch (category) {
      case 'east_asian':
        return 'East Asian';
      default:
        return category[0].toUpperCase() + category.substring(1);
    }
  }
}
