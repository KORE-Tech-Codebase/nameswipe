import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:nameswipe/core/constants/app_constants.dart';
import 'package:nameswipe/utils/logger/app_logger.dart';

class DatabaseService {
  DatabaseService._();

  static DatabaseService? _instance;
  static Database? _database;

  static DatabaseService get instance {
    assert(_instance != null, 'DatabaseService has not been initialized.');
    return _instance!;
  }

  static Future<void> init() async {
    _instance = DatabaseService._();
    await _instance!._initDatabase();
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path;
    if (kIsWeb) {
      path = AppConstants.dbName;
    } else {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, AppConstants.dbName);
    }

    _database = await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE names (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gender TEXT NOT NULL,
        origin TEXT NOT NULL DEFAULT '',
        meaning TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL,
        UNIQUE(name, category)
      )
    ''');
    await db.execute('CREATE INDEX idx_names_category ON names(category)');
    await db.execute('CREATE INDEX idx_names_gender ON names(gender)');
    await db.execute(
        'CREATE INDEX idx_names_name ON names(name COLLATE NOCASE)');
    await db.execute(
        'CREATE INDEX idx_names_category_gender ON names(category, gender)');

    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gender TEXT NOT NULL,
        origin TEXT NOT NULL DEFAULT '',
        meaning TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL,
        favorited_at TEXT NOT NULL DEFAULT (datetime('now')),
        notes TEXT,
        UNIQUE(name, category)
      )
    ''');

    await db.execute('''
      CREATE TABLE swipe_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        action TEXT NOT NULL,
        swiped_at TEXT NOT NULL DEFAULT (datetime('now')),
        UNIQUE(name, category)
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_status (
        category TEXT PRIMARY KEY,
        last_page INTEGER NOT NULL DEFAULT 0,
        total_pages INTEGER NOT NULL DEFAULT 0,
        total_names INTEGER NOT NULL DEFAULT 0,
        synced_names INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT,
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE origins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        origin TEXT NOT NULL,
        count INTEGER NOT NULL DEFAULT 0,
        UNIQUE(category, origin)
      )
    ''');

    AppLogger.info('Database created (v$version)', tag: 'DatabaseService');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.info(
      'Database upgraded from v$oldVersion to v$newVersion',
      tag: 'DatabaseService',
    );
  }

  // ============================================================
  // Names operations
  // ============================================================

  Future<int> insertName(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('names', data,
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> insertNamesBatch(List<Map<String, dynamic>> names) async {
    final db = await database;
    final b = db.batch();
    for (final name in names) {
      b.insert('names', name, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await b.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getUnswipedNames({
    int limit = 20,
    String? category,
    String? gender,
    List<String>? categories,
    List<String>? origins,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (category != null) {
      conditions.add('n.category = ?');
      args.add(category);
    }
    if (categories != null && categories.isNotEmpty) {
      final placeholders = categories.map((_) => '?').join(',');
      conditions.add('n.category IN ($placeholders)');
      args.addAll(categories);
    }
    if (gender != null) {
      conditions.add('n.gender = ?');
      args.add(gender);
    }
    if (origins != null && origins.isNotEmpty) {
      final placeholders = origins.map((_) => '?').join(',');
      conditions.add('n.origin IN ($placeholders)');
      args.addAll(origins);
    }

    final whereClause = conditions.isNotEmpty
        ? 'AND ${conditions.join(' AND ')}'
        : '';

    args.add(limit);

    return db.rawQuery('''
      SELECT n.* FROM names n
      LEFT JOIN swipe_history sh ON n.name = sh.name AND n.category = sh.category
      WHERE sh.id IS NULL
      $whereClause
      ORDER BY RANDOM()
      LIMIT ?
    ''', args);
  }

  Future<void> recordSwipe(
      String name, String category, String action) async {
    final db = await database;
    await db.insert(
      'swipe_history',
      {
        'name': name,
        'category': category,
        'action': action,
        'swiped_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============================================================
  // Favorites operations
  // ============================================================

  Future<int> addFavorite(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('favorites', data,
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> removeFavorite(String name, String category) async {
    final db = await database;
    return db.delete('favorites',
        where: 'name = ? AND category = ?', whereArgs: [name, category]);
  }

  Future<bool> isFavorite(String name, String category) async {
    final db = await database;
    final result = await db.query('favorites',
        where: 'name = ? AND category = ?',
        whereArgs: [name, category],
        limit: 1);
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getFavorites({
    String? gender,
    String? orderBy,
  }) async {
    final db = await database;
    String? where;
    List<dynamic>? whereArgs;
    if (gender != null) {
      where = 'gender = ?';
      whereArgs = [gender];
    }
    return db.query('favorites',
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy ?? 'favorited_at DESC');
  }

  Future<int> getFavoritesCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM favorites');
    return result.first['count'] as int? ?? 0;
  }

  // ============================================================
  // Search operations
  // ============================================================

  Future<List<Map<String, dynamic>>> searchNames({
    required String query,
    String? gender,
    List<String>? categories,
    List<String>? origins,
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    final conditions = <String>['(name LIKE ? OR meaning LIKE ?)'];
    final args = <dynamic>['%$query%', '%$query%'];

    if (gender != null) {
      conditions.add('gender = ?');
      args.add(gender);
    }
    if (categories != null && categories.isNotEmpty) {
      final placeholders = categories.map((_) => '?').join(',');
      conditions.add('category IN ($placeholders)');
      args.addAll(categories);
    }
    if (origins != null && origins.isNotEmpty) {
      final placeholders = origins.map((_) => '?').join(',');
      conditions.add('origin IN ($placeholders)');
      args.addAll(origins);
    }

    args.addAll([limit, offset]);

    return db.rawQuery('''
      SELECT * FROM names
      WHERE ${conditions.join(' AND ')}
      ORDER BY name COLLATE NOCASE ASC
      LIMIT ? OFFSET ?
    ''', args);
  }

  // ============================================================
  // Sync operations
  // ============================================================

  Future<List<Map<String, dynamic>>> getSyncStatuses() async {
    final db = await database;
    return db.query('sync_status');
  }

  Future<Map<String, dynamic>?> getSyncStatus(String category) async {
    final db = await database;
    final result = await db.query('sync_status',
        where: 'category = ?', whereArgs: [category], limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> upsertSyncStatus(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('sync_status', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ============================================================
  // Origins operations
  // ============================================================

  Future<List<Map<String, dynamic>>> getOrigins({String? category}) async {
    final db = await database;
    if (category != null) {
      return db.query('origins',
          where: 'category = ?',
          whereArgs: [category],
          orderBy: 'origin ASC');
    }
    return db.rawQuery(
        'SELECT origin, SUM(count) as count FROM origins GROUP BY origin ORDER BY origin ASC');
  }

  Future<void> upsertOrigin(
      String category, String origin, int count) async {
    final db = await database;
    await db.insert(
      'origins',
      {'category': category, 'origin': origin, 'count': count},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============================================================
  // Stats
  // ============================================================

  Future<int> getTotalNameCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM names');
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getSwipeHistoryCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM swipe_history');
    return result.first['count'] as int? ?? 0;
  }

  Future<void> clearSwipeHistory() async {
    final db = await database;
    await db.delete('swipe_history');
  }

  Future<List<Map<String, dynamic>>> getDistinctCategories() async {
    final db = await database;
    return db
        .rawQuery('SELECT DISTINCT category FROM names ORDER BY category');
  }

  Future<List<Map<String, dynamic>>> getDistinctOrigins() async {
    final db = await database;
    return db.rawQuery(
        "SELECT DISTINCT origin FROM names WHERE origin != '' ORDER BY origin");
  }

  // ============================================================
  // Database management
  // ============================================================

  Future<void> deleteDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, AppConstants.dbName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
    AppLogger.info('Database deleted', tag: 'DatabaseService');
  }
}
