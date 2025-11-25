// lib/services/alert_database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/space_weather_data.dart';

class AlertDatabaseService {
  static Database? _database;
  static const String _tableName = 'alerts';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'space_weather_alerts.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        product_id TEXT,
        type TEXT,
        level TEXT,
        message TEXT,
        issued_time TEXT,
        expires_time TEXT,
        kp_index REAL,
        affected_areas TEXT,
        created_at TEXT
      )
    ''');
  }

  // Save alerts to database
  static Future<void> saveAlerts(List<SpaceAlert> alerts) async {
    final db = await database;
    final batch = db.batch();

    for (final alert in alerts) {
      // Convert affected areas to JSON string
      final affectedAreasJson = alert.affectedAreas
          .map((area) => '${area.latitude},${area.longitude},${area.locationName}')
          .join('|');

      batch.insert(
        _tableName,
        {
          'id': alert.id,
          'product_id': alert.id,
          'type': alert.type,
          'level': alert.level,
          'message': alert.message,
          'issued_time': alert.issuedTime.toIso8601String(),
          'expires_time': alert.expiresTime?.toIso8601String(),
          'kp_index': alert.kpIndex,
          'affected_areas': affectedAreasJson,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    print('💾 Saved ${alerts.length} alerts to database');
  }

  // Get all alerts from database
  static Future<List<SpaceAlert>> getAllAlerts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'issued_time DESC',
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      
      // Parse affected areas
      final affectedAreasStr = map['affected_areas'] as String? ?? '';
      final List<GeoCoordinate> affectedAreas = [];
      
      if (affectedAreasStr.isNotEmpty) {
        final areas = affectedAreasStr.split('|');
        for (final area in areas) {
          final parts = area.split(',');
          if (parts.length >= 3) {
            affectedAreas.add(GeoCoordinate(
              latitude: double.tryParse(parts[0]) ?? 0.0,
              longitude: double.tryParse(parts[1]) ?? 0.0,
              locationName: parts[2],
            ));
          }
        }
      }

      return SpaceAlert(
        id: map['id'] as String,
        type: map['type'] as String,
        level: map['level'] as String,
        message: map['message'] as String,
        issuedTime: DateTime.parse(map['issued_time'] as String),
        expiresTime: map['expires_time'] != null
            ? DateTime.parse(map['expires_time'] as String)
            : null,
        kpIndex: map['kp_index'] as double?,
        affectedAreas: affectedAreas,
      );
    });
  }

  // Get alert IDs from database
  static Future<Set<String>> getStoredAlertIds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      columns: ['id'],
    );

    return maps.map((map) => map['id'] as String).toSet();
  }

  // Clear old alerts (older than 7 days)
  static Future<void> clearOldAlerts() async {
    final db = await database;
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    
    await db.delete(
      _tableName,
      where: 'issued_time < ?',
      whereArgs: [sevenDaysAgo.toIso8601String()],
    );
    
    print('🧹 Cleared old alerts from database');
  }

  // Get alert count
  static Future<int> getAlertCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}








