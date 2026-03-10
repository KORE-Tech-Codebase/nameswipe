import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:namora/core/constants/app_constants.dart';
import 'package:namora/models/name_model.dart';
import 'package:namora/services/network/api_service.dart';
import 'package:namora/utils/logger/app_logger.dart';

class SearchRepository {
  SearchRepository({required NamesApiService api}) : _api = api;
  final NamesApiService _api;

  Future<List<NameModel>> search({
    required String query,
    String? gender,
    List<String>? categories,
  }) async {
    try {
      return await _searchApi(query: query, gender: gender, categories: categories);
    } catch (e) {
      AppLogger.error('API search failed, using bundled fallback', tag: 'SearchRepo', error: e);
      return _searchBundled(query: query, gender: gender, categories: categories);
    }
  }

  Future<List<NameModel>> _searchApi({
    required String query,
    String? gender,
    List<String>? categories,
  }) async {
    final cats = categories?.isNotEmpty == true
        ? categories!
        : AppConstants.categories;

    // Search across selected categories in parallel
    final futures = cats.map((cat) => _api.getNames(
      category: cat,
      page: 1,
      pageSize: 50,
      gender: gender,
      search: query,
    ));

    final results = await Future.wait(futures, eagerError: false);

    final allNames = <NameModel>[];
    for (final result in results) {
      allNames.addAll(result.names);
    }

    // Sort alphabetically
    allNames.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return allNames.take(50).toList();
  }

  Future<List<NameModel>> _searchBundled({
    required String query,
    String? gender,
    List<String>? categories,
  }) async {
    final jsonStr = await rootBundle.loadString(AppConstants.bundledNamesAsset);
    final List<dynamic> data = jsonDecode(jsonStr) as List<dynamic>;
    final lowerQuery = query.toLowerCase();

    var names = data
        .map((e) => NameModel.fromJson(e as Map<String, dynamic>))
        .where((n) =>
            n.name.toLowerCase().contains(lowerQuery) ||
            n.meaning.toLowerCase().contains(lowerQuery))
        .toList();

    if (gender != null) {
      names = names.where((n) => n.gender == gender).toList();
    }
    if (categories != null && categories.isNotEmpty) {
      names = names.where((n) => categories.contains(n.category)).toList();
    }

    names.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return names.take(50).toList();
  }
}
