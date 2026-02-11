import 'package:nameswipe/core/constants/app_constants.dart';
import 'package:nameswipe/models/sync_status_model.dart';
import 'package:nameswipe/services/cache/database_service.dart';
import 'package:nameswipe/services/network/api_service.dart';
import 'package:nameswipe/utils/logger/app_logger.dart';

class SyncRepository {
  SyncRepository({required DatabaseService db, required NamesApiService api})
      : _db = db,
        _api = api;
  final DatabaseService _db;
  final NamesApiService _api;

  Future<List<SyncStatusModel>> getSyncStatuses() async {
    final rows = await _db.getSyncStatuses();
    return rows.map((r) => SyncStatusModel.fromJson(r)).toList();
  }

  Future<void> syncCategory(String category, {void Function(SyncStatusModel)? onProgress}) async {
    try {
      // Get current status
      var statusRow = await _db.getSyncStatus(category);
      int lastPage = statusRow?['last_page'] as int? ?? 0;
      int nextPage = lastPage + 1;

      // Fetch first page to know total
      final result = await _api.getNames(
        category: category,
        page: nextPage,
        pageSize: AppConstants.syncBatchSize,
      );

      if (result.names.isEmpty) return;

      // Insert names
      await _db.insertNamesBatch(result.names.map((n) => n.toJson()).toList());

      // Update sync status
      final statusData = {
        'category': category,
        'last_page': nextPage,
        'total_pages': result.totalPages,
        'total_names': result.total,
        'synced_names': (statusRow?['synced_names'] as int? ?? 0) + result.names.length,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (nextPage >= result.totalPages) {
        statusData['completed_at'] = DateTime.now().toIso8601String();
      }

      await _db.upsertSyncStatus(statusData);

      final status = SyncStatusModel.fromJson(statusData);
      onProgress?.call(status);

      // Continue syncing if not done
      if (nextPage < result.totalPages) {
        await Future.delayed(AppConstants.syncDelay);
        await syncCategory(category, onProgress: onProgress);
      }
    } catch (e) {
      AppLogger.error('Sync failed for $category', tag: 'Sync', error: e);
    }
  }
}
