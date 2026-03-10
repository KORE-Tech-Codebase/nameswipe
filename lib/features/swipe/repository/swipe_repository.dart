import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:namora/core/constants/app_constants.dart';
import 'package:namora/models/name_model.dart';
import 'package:namora/models/filter_model.dart';
import 'package:namora/services/network/api_service.dart';
import 'package:namora/utils/logger/app_logger.dart';

class SwipeRepository {
  SwipeRepository({required NamesApiService api}) : _api = api;
  final NamesApiService _api;
  final _random = Random();

  // In-memory categories cache
  List<String>? _categoriesCache;

  // Session dedup — tracks names already shown
  final Set<String> _seenNames = {};

  Future<List<NameModel>> getNextBatch({FilterModel? filter}) async {
    try {
      return await _fetchFromApi(filter: filter);
    } catch (e) {
      AppLogger.error('API fetch failed, using bundled fallback', tag: 'SwipeRepo', error: e);
      return _fetchFromBundled(filter: filter);
    }
  }

  Future<List<NameModel>> _fetchFromApi({FilterModel? filter}) async {
    final categories = filter?.categories.isNotEmpty == true
        ? filter!.categories.toList()
        : await _getRandomCategories(AppConstants.swipeCategoriesPerFetch);

    // Fetch from multiple categories in parallel
    final futures = categories.map((cat) {
      final randomPage = _random.nextInt(5) + 1; // random page 1-5
      return _api.getNames(
        category: cat,
        page: randomPage,
        pageSize: AppConstants.swipeBatchSize,
        gender: filter?.gender,
      );
    });

    final results = await Future.wait(futures, eagerError: false);

    final allNames = <NameModel>[];
    for (final result in results) {
      allNames.addAll(result.names);
    }

    // Shuffle to mix categories
    allNames.shuffle(_random);

    // Dedup against already-seen names this session
    final fresh = allNames.where((n) => !_seenNames.contains('${n.name}_${n.category}')).toList();

    return fresh.take(AppConstants.swipeBatchSize).toList();
  }

  Future<List<NameModel>> _fetchFromBundled({FilterModel? filter}) async {
    try {
      final jsonStr = await rootBundle.loadString(AppConstants.bundledNamesAsset);
      final List<dynamic> data = jsonDecode(jsonStr) as List<dynamic>;

      var names = data.map((e) => NameModel.fromJson(e as Map<String, dynamic>)).toList();

      // Apply filters
      if (filter != null) {
        if (filter.gender != null) {
          names = names.where((n) => n.gender == filter.gender).toList();
        }
        if (filter.categories.isNotEmpty) {
          names = names.where((n) => filter.categories.contains(n.category)).toList();
        }
      }

      // Remove already-seen
      names = names.where((n) => !_seenNames.contains('${n.name}_${n.category}')).toList();

      names.shuffle(_random);
      return names.take(AppConstants.swipeBatchSize).toList();
    } catch (e) {
      AppLogger.error('Bundled fallback also failed', tag: 'SwipeRepo', error: e);
      return [];
    }
  }

  Future<List<String>> _getRandomCategories(int count) async {
    _categoriesCache ??= List.from(AppConstants.categories);
    final shuffled = List<String>.from(_categoriesCache!)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  void markSeen(NameModel name) {
    _seenNames.add('${name.name}_${name.category}');
  }

  void clearSeen() {
    _seenNames.clear();
  }

  int get seenCount => _seenNames.length;
}
