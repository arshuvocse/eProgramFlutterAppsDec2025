
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
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tblUser(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        empInfoId INTEGER,
        userName TEXT,
        empMasterCode TEXT,
        userType TEXT,
        loginName TEXT,
        password TEXT,
        userEmail TEXT,
        roleType TEXT,
        empRole TEXT,
        desigName TEXT,
        email TEXT
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

    if (oldVersion < 4) {
      await db.execute("ALTER TABLE tblUser ADD COLUMN userId INTEGER");
      await db.execute("ALTER TABLE tblUser ADD COLUMN empInfoId INTEGER");
      await db.execute("ALTER TABLE tblUser ADD COLUMN userName TEXT");
      await db.execute("ALTER TABLE tblUser ADD COLUMN empMasterCode TEXT");
      await db.execute("ALTER TABLE tblUser ADD COLUMN userType TEXT");
      await db.execute("ALTER TABLE tblUser ADD COLUMN loginName TEXT");
      await db.execute("ALTER TABLE tblUser ADD COLUMN userEmail TEXT");
      await db.execute("ALTER TABLE tblUser ADD COLUMN roleType TEXT");
      await db.execute("ALTER TABLE tblUser ADD COLUMN empRole TEXT");
      await db.execute("ALTER TABLE tblUser ADD COLUMN desigName TEXT");
    }
  }

  Future<void> saveUser(User user) async {
    final db = await database;
    await db.delete('tblUser');
    await db.insert(
      'tblUser',
      {
        'userId': user.userId,
        'empInfoId': user.empInfoId,
        'userName': user.userName,
        'empMasterCode': user.empMasterCode,
        'userType': user.userType,
        'loginName': user.loginName,
        'password': user.password,
        'userEmail': user.userEmail,
        'roleType': user.roleType,
        'empRole': user.empRole,
        'desigName': user.desigName,
        // Keep legacy email column populated for older reads
        'email': user.userEmail,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int?> getEmpInfoId() async {
    final db = await database;
    final result = await db.query('tblUser', columns: ['empInfoId'], limit: 1);
    if (result.isEmpty) return null;
    final value = result.first['empInfoId'];
    if (value is int) return value;
    return int.tryParse('$value');
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
