import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'aquarium.db');
    print("Initializing database at path: $path"); // Debug log
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fishCount INTEGER,
        fishSpeed REAL,
        fishColor TEXT
      )
    ''');
    print("Settings table created"); // Debug log
  }

  Future<void> saveSettings(int fishCount, double fishSpeed, String fishColor) async {
    final db = await database;

    try {
      // Check if there's already a settings row
      final existingSettings = await db.query('settings');
      print("Existing settings: $existingSettings"); // Debug log

      if (existingSettings.isNotEmpty) {
        // If the settings row exists, update it
        await db.update(
          'settings',
          {
            'fishCount': fishCount,
            'fishSpeed': fishSpeed,
            'fishColor': fishColor,
          },
          where: 'id = ?', 
          whereArgs: [existingSettings.first['id']],
        );
        print("Settings updated"); // Debug log
      } else {
        // If no settings row exists, insert a new one
        await db.insert('settings', {
          'fishCount': fishCount,
          'fishSpeed': fishSpeed,
          'fishColor': fishColor,
        });
        print("Settings inserted"); // Debug log
      }
    } catch (e) {
      print("Error saving settings: $e"); // Debug log
    }
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final db = await database;
    final settings = await db.query('settings', limit: 1); // Fetch only the first row
    print("Loading settings: $settings"); // Debug log

    if (settings.isNotEmpty) {
      return {
        'fishCount': settings.first['fishCount'],
        'fishSpeed': settings.first['fishSpeed'],
        'fishColor': settings.first['fishColor'],
      };
    } else {
      print("No settings found"); // Debug log
      return {}; // No settings found
    }
  }
}

