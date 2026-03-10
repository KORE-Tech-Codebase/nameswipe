import 'package:dio/dio.dart';
import 'package:namora/models/name_model.dart';
import 'package:namora/models/category_model.dart';
import 'package:namora/services/network/dio_client.dart';
import 'package:namora/utils/logger/app_logger.dart';

class NamesApiService {
  NamesApiService({required DioClient dioClient}) : _dioClient = dioClient;

  final DioClient _dioClient;

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>('/');
      final data = response.data;
      if (data != null && data['success'] == true) {
        final list = data['data'] as List<dynamic>;
        return list
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch categories', tag: 'API', error: e);
      rethrow;
    }
  }

  Future<({List<NameModel> names, int total, int totalPages})> getNames({
    required String category,
    int page = 1,
    int pageSize = 100,
    String? gender,
    String? origin,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (gender != null) queryParams['filter[gender]'] = gender;
      if (origin != null) queryParams['filter[origin]'] = origin;
      if (search != null) queryParams['search'] = search;

      final response = await _dioClient.get<Map<String, dynamic>>(
        '/$category',
        queryParameters: queryParams,
      );
      final data = response.data;
      if (data != null && data['success'] == true) {
        final list = data['data'] as List<dynamic>;
        final meta = data['meta'] as Map<String, dynamic>?;
        final names = list.map((e) {
          final map = Map<String, dynamic>.from(e as Map);
          map['category'] = category;
          return NameModel.fromJson(map);
        }).toList();
        return (
          names: names,
          total: meta?['total'] as int? ?? 0,
          totalPages: meta?['totalPages'] as int? ?? 0,
        );
      }
      return (names: <NameModel>[], total: 0, totalPages: 0);
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch names for $category',
          tag: 'API', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCategoryStats(String category) async {
    try {
      final response =
          await _dioClient.get<Map<String, dynamic>>('/$category/stats');
      final data = response.data;
      if (data != null && data['success'] == true) {
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch stats for $category',
          tag: 'API', error: e);
      rethrow;
    }
  }
}
