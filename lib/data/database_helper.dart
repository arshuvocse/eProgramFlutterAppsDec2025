
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tblUser(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT,
        password TEXT
      )
    ''');

    // Providers
    await db.execute('''
      CREATE TABLE tblProvider(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        category TEXT,
        type TEXT,
        phone TEXT
      )
    ''');

    // Checklist visit header
    await db.execute('''
      CREATE TABLE tblChecklistVisit(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        provider_code TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Checklist answers (1..n)
    await db.execute('''
      CREATE TABLE tblChecklistAnswer(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visit_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,
        answer TEXT,
        FOREIGN KEY (visit_id) REFERENCES tblChecklistVisit(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tblLocationQueue(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        emp_info_id INTEGER,
        lat_value TEXT,
        long_value TEXT,
        address_name TEXT,
        time_value TEXT,
        track_date TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblProvider(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          code TEXT NOT NULL UNIQUE,
          category TEXT,
          type TEXT,
          phone TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblChecklistVisit(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          provider_code TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblChecklistAnswer(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          visit_id INTEGER NOT NULL,
          question_id INTEGER NOT NULL,
          answer TEXT,
          FOREIGN KEY (visit_id) REFERENCES tblChecklistVisit(id) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblLocationQueue(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          emp_info_id INTEGER,
          lat_value TEXT,
          long_value TEXT,
          address_name TEXT,
          time_value TEXT,
          track_date TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    }
  }

  Future<void> saveUser(User user) async {
    final db = await database;
    final emailOrUsername = (user.email).isNotEmpty ? user.email : user.username;
    // Ensure only one active session record exists
    await db.delete('tblUser');
    await db.insert(
      'tblUser',
      {'email': emailOrUsername, 'password': user.password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> hasUser() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM tblUser');
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  Future<void> clearUser() async {
    final db = await database;
    await db.delete('tblUser');
  }

  Future<void> insertOfflineLocation({
    required int empInfoId,
    required String latValue,
    required String longValue,
    required String addressName,
    required String timeValue,
    required String trackDate,
  }) async {
    final db = await database;
    await db.insert(
      'tblLocationQueue',
      {
        'emp_info_id': empInfoId,
        'lat_value': latValue,
        'long_value': longValue,
        'address_name': addressName,
        'time_value': timeValue,
        'track_date': trackDate,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getOfflineLocations({int limit = 50}) async {
    final db = await database;
    return db.query(
      'tblLocationQueue',
      orderBy: 'id ASC',
      limit: limit,
    );
  }

  Future<void> deleteOfflineLocation(int id) async {
    final db = await database;
    await db.delete('tblLocationQueue', where: 'id = ?', whereArgs: [id]);
  }
}
