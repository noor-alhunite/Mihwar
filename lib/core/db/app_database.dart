import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('msar.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // جدول الحاويات
    await db.execute('''
      CREATE TABLE bins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        zone_type TEXT NOT NULL DEFAULT 'residential',
        area_name TEXT NOT NULL DEFAULT 'Zarqa - Al Karama',
        assigned_driver_id TEXT
      )
    ''');

    // جدول زيارات السائق للحاويات (التاريخ + الحالة)
    await db.execute('''
      CREATE TABLE bin_visits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bin_id INTEGER NOT NULL,
        status TEXT NOT NULL, -- empty, half, full, broken
        visited_at TEXT NOT NULL,
        driver_id TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        FOREIGN KEY (bin_id) REFERENCES bins (id)
      )
    ''');

    // جدول إحصائيات الديزل (قبل / بعد)
    await db.execute('''
      CREATE TABLE diesel_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mode TEXT NOT NULL, -- before / after
        period TEXT NOT NULL, -- daily / weekly / monthly / yearly
        value REAL NOT NULL
      )
    ''');

    await _createSupportingTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _safeAddColumn(
        db,
        table: 'bins',
        columnDef: "zone_type TEXT NOT NULL DEFAULT 'residential'",
      );
      await _safeAddColumn(
        db,
        table: 'bins',
        columnDef: "area_name TEXT NOT NULL DEFAULT 'Zarqa - Al Karama'",
      );
      await _safeAddColumn(
        db,
        table: 'bin_visits',
        columnDef: 'latitude REAL',
      );
      await _safeAddColumn(
        db,
        table: 'bin_visits',
        columnDef: 'longitude REAL',
      );
      await _createSupportingTables(db);
    }
    if (oldVersion < 3) {
      await _safeAddColumn(
        db,
        table: 'bins',
        columnDef: 'assigned_driver_id TEXT',
      );
      await _createDriverLocationPointsTable(db);
    }
    if (oldVersion < 4) {
      await _safeAddColumn(
        db,
        table: 'road_segments',
        columnDef: 'polyline_points_json TEXT',
      );
    }
  }

  Future<void> _createSupportingTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS seed_state (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS planned_stops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        route_date TEXT NOT NULL,
        driver_id TEXT NOT NULL,
        bin_id INTEGER NOT NULL,
        stop_order INTEGER NOT NULL,
        is_priority INTEGER NOT NULL DEFAULT 0,
        UNIQUE(route_date, driver_id, bin_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS road_segments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        from_bin_id INTEGER NOT NULL,
        to_bin_id INTEGER NOT NULL,
        distance_km REAL NOT NULL,
        road_type TEXT NOT NULL,
        polyline_points_json TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS driver_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        route_date TEXT NOT NULL,
        driver_id TEXT NOT NULL,
        bin_id INTEGER,
        event_type TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await _createDriverLocationPointsTable(db);
  }

  Future<void> _createDriverLocationPointsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS driver_location_points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        route_date TEXT NOT NULL,
        driver_id TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        recorded_at TEXT NOT NULL,
        meters_from_planned_path REAL
      )
    ''');
  }

  Future<void> _safeAddColumn(
    Database db, {
    required String table,
    required String columnDef,
  }) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $columnDef');
    } catch (_) {
      // Intentionally ignored: column may already exist.
    }
  }

  // ===== أمثلة دوال مساعدة (نوسعها لاحقًا) =====

  Future<int> insertBin(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('bins', data);
  }

  Future<int> insertVisit(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('bin_visits', data);
  }

  Future<int> insertDieselStat(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('diesel_stats', data);
  }

  Future<List<Map<String, dynamic>>> getDieselStats(String mode) async {
    final db = await database;
    return db.query(
      'diesel_stats',
      where: 'mode = ?',
      whereArgs: [mode],
    );
  }
}
