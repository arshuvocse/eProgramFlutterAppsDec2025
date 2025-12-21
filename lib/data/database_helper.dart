
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
      version: 14,
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
        userCode TEXT,
        roleTypeId INTEGER,
        isApprove INTEGER,
        isForward INTEGER,
        versionName TEXT,
        supervisorId INTEGER,
        areaOfficeId INTEGER,
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
        providerId INTEGER,
        programId INTEGER,
        programName TEXT,
        providerCode TEXT NOT NULL UNIQUE,
        providerName TEXT,
        mobileNo TEXT,
        nid TEXT,
        email TEXT,
        networkId TEXT,
        providerTypeId INTEGER,
        empType TEXT,
        gender TEXT,
        dateOfBirth TEXT,
        presentAddress TEXT,
        division TEXT,
        district TEXT,
        upazila TEXT,
        unionName TEXT,
        divisionId INTEGER,
        districtId INTEGER,
        upazilaId INTEGER,
        unionId INTEGER,
        wardOrMarket TEXT,
        remarks TEXT
      )
    ''');

    // Checklist visit header
    await db.execute('''
      CREATE TABLE tblChecklistVisit(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        provider_code TEXT NOT NULL,
        provider_id INTEGER,
        is_draft INTEGER DEFAULT 0,
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

    await db.execute('''
      CREATE TABLE tblDashboardTile(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        field_name TEXT,
        field_bg_color TEXT,
        field_icon TEXT,
        field_count INTEGER,
        field_value TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tblDivision(
        divisionId INTEGER PRIMARY KEY,
        divisionName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tblDistrict(
        districtId INTEGER PRIMARY KEY,
        divisionId INTEGER,
        districtName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tblThana(
        thanaId INTEGER PRIMARY KEY,
        districtId INTEGER,
        thanaName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tblDivisionalOffice(
        divisionalOfficeId INTEGER PRIMARY KEY,
        divisionalOfficeName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tblRegionalOffice(
        regionalOfficeId INTEGER PRIMARY KEY,
        divisionalOfficeId INTEGER,
        regionalOfficeName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tblAreaOffice(
        areaOfficeId INTEGER PRIMARY KEY,
        regionalOfficeId INTEGER,
        areaOfficeName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tblProgram(
        programId INTEGER PRIMARY KEY,
        programCode TEXT,
        programName TEXT,
        programShortName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tblProviderGroup(
        providerGroupId INTEGER PRIMARY KEY,
        groupName TEXT,
        groupType TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tblProviderDoctorType(
        doctorTypeId INTEGER PRIMARY KEY,
        doctorTypeName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tblAcademicQualification(
        qualificationId INTEGER PRIMARY KEY,
        qualificationName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tblProfessionalQualification(
        qualificationId INTEGER PRIMARY KEY,
        qualificationName TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblProvider(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          providerId INTEGER,
          programId INTEGER,
          programName TEXT,
          providerCode TEXT NOT NULL UNIQUE,
          providerName TEXT,
          mobileNo TEXT,
          nid TEXT,
          email TEXT,
          networkId TEXT,
          providerTypeId INTEGER,
          empType TEXT,
          gender TEXT,
          dateOfBirth TEXT,
          presentAddress TEXT,
          division TEXT,
          district TEXT,
          upazila TEXT,
          unionName TEXT,
          divisionId INTEGER,
          districtId INTEGER,
          upazilaId INTEGER,
          unionId INTEGER,
          wardOrMarket TEXT,
          remarks TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblChecklistVisit(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          provider_code TEXT NOT NULL,
          provider_id INTEGER,
          is_draft INTEGER DEFAULT 0,
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

    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblDashboardTile(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          field_name TEXT,
          field_bg_color TEXT,
          field_icon TEXT,
          field_count INTEGER,
          field_value TEXT,
          updated_at TEXT
        )
      ''');
    }

    if (oldVersion < 6) {
      // Add new login payload fields to user cache.
      const columns = <String>[
        'userCode TEXT',
        'roleTypeId INTEGER',
        'isApprove INTEGER',
        'isForward INTEGER',
        'versionName TEXT',
        'supervisorId INTEGER',
        'areaOfficeId INTEGER',
      ];

      for (final col in columns) {
        try {
          await db.execute('ALTER TABLE tblUser ADD COLUMN $col');
        } catch (_) {
          // Ignore if column already exists.
        }
      }
    }

    if (oldVersion < 7) {
      // Recreate provider table with expanded schema.
      await db.execute('DROP TABLE IF EXISTS tblProvider');
      await db.execute('''
        CREATE TABLE tblProvider(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          providerId INTEGER,
          programId INTEGER,
          programName TEXT,
          providerCode TEXT NOT NULL UNIQUE,
          providerName TEXT,
          mobileNo TEXT,
          nid TEXT,
          email TEXT,
          networkId TEXT,
          providerTypeId INTEGER,
          empType TEXT,
          gender TEXT,
          dateOfBirth TEXT,
          presentAddress TEXT,
          division TEXT,
          district TEXT,
          upazila TEXT,
          unionName TEXT,
          divisionId INTEGER,
          districtId INTEGER,
          upazilaId INTEGER,
          unionId INTEGER,
          wardOrMarket TEXT,
          remarks TEXT
        )
      ''');
    }

    if (oldVersion < 8) {
      try {
        await db.execute(
          'ALTER TABLE tblChecklistVisit ADD COLUMN provider_id INTEGER',
        );
      } catch (_) {
        // Ignore if column already exists.
      }
      try {
        await db.execute(
          'ALTER TABLE tblChecklistVisit ADD COLUMN is_draft INTEGER DEFAULT 0',
        );
        await db.execute(
          'UPDATE tblChecklistVisit SET is_draft = 0 WHERE is_draft IS NULL',
        );
      } catch (_) {
        // Ignore if column already exists.
      }
    }

    if (oldVersion < 9) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblDivision(
          divisionId INTEGER PRIMARY KEY,
          divisionName TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblDistrict(
          districtId INTEGER PRIMARY KEY,
          divisionId INTEGER,
          districtName TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblThana(
          thanaId INTEGER PRIMARY KEY,
          districtId INTEGER,
          thanaName TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblDivisionalOffice(
          divisionalOfficeId INTEGER PRIMARY KEY,
          divisionalOfficeName TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblRegionalOffice(
          regionalOfficeId INTEGER PRIMARY KEY,
          divisionalOfficeId INTEGER,
          regionalOfficeName TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblAreaOffice(
          areaOfficeId INTEGER PRIMARY KEY,
          regionalOfficeId INTEGER,
          areaOfficeName TEXT
        )
      ''');
    }

    if (oldVersion < 10) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblProgram(
          programId INTEGER PRIMARY KEY,
          programCode TEXT,
          programName TEXT,
          programShortName TEXT
        )
      ''');
    }

    if (oldVersion < 11) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblProviderGroup(
          providerGroupId INTEGER PRIMARY KEY,
          groupName TEXT,
          groupType TEXT
        )
      ''');
    }

    if (oldVersion < 12) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblProviderDoctorType(
          doctorTypeId INTEGER PRIMARY KEY,
          doctorTypeName TEXT
        )
      ''');
    }

    if (oldVersion < 13) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblAcademicQualification(
          qualificationId INTEGER PRIMARY KEY,
          qualificationName TEXT
        )
      ''');
    }

    if (oldVersion < 14) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tblProfessionalQualification(
          qualificationId INTEGER PRIMARY KEY,
          qualificationName TEXT
        )
      ''');
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
        'userCode': user.userCode,
        'roleTypeId': user.roleTypeId,
        'isApprove': user.isApprove ? 1 : 0,
        'isForward': user.isForward ? 1 : 0,
        'versionName': user.versionName,
        'supervisorId': user.supervisorId,
        'areaOfficeId': user.areaOfficeId,
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

  Future<int?> getUserId() async {
    final db = await database;
    final result = await db.query('tblUser', columns: ['userId'], limit: 1);
    if (result.isEmpty) return null;
    final value = result.first['userId'];
    if (value is int) return value;
    return int.tryParse('$value');
  }

  Future<User?> getCachedUser() async {
    final db = await database;
    final result = await db.query('tblUser', limit: 1);
    if (result.isEmpty) return null;
    return User.fromJson(result.first);
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

  Future<void> cacheDashboardTiles(List<Map<String, dynamic>> tiles) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('tblDashboardTile');
      for (final tile in tiles) {
        await txn.insert(
          'tblDashboardTile',
          {
            'field_name': tile['field_name'] ?? tile['fieldName'] ?? '',
            'field_bg_color': tile['field_bg_color'] ?? tile['fieldBgColor'] ?? '',
            'field_icon': tile['field_icon'] ?? tile['fieldIcon'] ?? '',
            'field_count': tile['field_count'] ?? tile['fieldCount'] ?? 0,
            'field_value': tile['field_value'] ?? tile['fieldValue'] ?? '',
            'updated_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Map<String, dynamic>>> getCachedDashboardTiles() async {
    final db = await database;
    return db.query(
      'tblDashboardTile',
      orderBy: 'id ASC',
    );
  }

  Future<void> cacheSeedData({
    required List<Map<String, dynamic>> divisions,
    required List<Map<String, dynamic>> districts,
    required List<Map<String, dynamic>> thanas,
    required List<Map<String, dynamic>> divisionalOffices,
    required List<Map<String, dynamic>> regionalOffices,
    required List<Map<String, dynamic>> areaOffices,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('tblDivision');
      await txn.delete('tblDistrict');
      await txn.delete('tblThana');
      await txn.delete('tblDivisionalOffice');
      await txn.delete('tblRegionalOffice');
      await txn.delete('tblAreaOffice');

      final batch = txn.batch();
      for (final row in divisions) {
        batch.insert(
          'tblDivision',
          {
            'divisionId': row['divisionId'],
            'divisionName': row['divisionName'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (final row in districts) {
        batch.insert(
          'tblDistrict',
          {
            'districtId': row['districtId'],
            'divisionId': row['divisionId'],
            'districtName': row['districtName'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (final row in thanas) {
        batch.insert(
          'tblThana',
          {
            'thanaId': row['thanaId'],
            'districtId': row['districtId'],
            'thanaName': row['thanaName'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (final row in divisionalOffices) {
        batch.insert(
          'tblDivisionalOffice',
          {
            'divisionalOfficeId': row['divisionalOfficeId'],
            'divisionalOfficeName': row['divisionalOfficeName'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (final row in regionalOffices) {
        batch.insert(
          'tblRegionalOffice',
          {
            'regionalOfficeId': row['regionalOfficeId'],
            'divisionalOfficeId': row['divisionalOfficeId'],
            'regionalOfficeName': row['regionalOfficeName'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (final row in areaOffices) {
        batch.insert(
          'tblAreaOffice',
          {
            'areaOfficeId': row['areaOfficeId'],
            'regionalOfficeId': row['regionalOfficeId'],
            'areaOfficeName': row['areaOfficeName'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<Map<String, int>> getSeedDataCounts() async {
    final db = await database;
    final tables = <String>[
      'tblProgram',
      'tblProviderGroup',
      'tblProviderDoctorType',
      'tblAcademicQualification',
      'tblProfessionalQualification',
      'tblDivision',
      'tblDistrict',
      'tblThana',
      'tblDivisionalOffice',
      'tblRegionalOffice',
      'tblAreaOffice',
    ];
    final counts = <String, int>{};
    for (final table in tables) {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
      counts[table] = Sqflite.firstIntValue(result) ?? 0;
    }
    return counts;
  }

  Future<void> cachePrograms(List<Map<String, dynamic>> programs) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('tblProgram');
      for (final program in programs) {
        await txn.insert(
          'tblProgram',
          {
            'programId': program['programId'] ?? 0,
            'programCode': program['programCode'] ?? '',
            'programName': program['programName'] ?? '',
            'programShortName': program['programShortName'] ?? '',
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> cacheProviderGroups(List<Map<String, dynamic>> groups) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('tblProviderGroup');
      for (final group in groups) {
        await txn.insert(
          'tblProviderGroup',
          {
            'providerGroupId': group['providerGroupId'] ?? 0,
            'groupName': group['groupName'] ?? '',
            'groupType': group['groupType'] ?? '',
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> cacheProviderDoctorTypes(List<Map<String, dynamic>> doctorTypes) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('tblProviderDoctorType');
      for (final doc in doctorTypes) {
        await txn.insert(
          'tblProviderDoctorType',
          {
            'doctorTypeId': doc['doctorTypeId'] ?? 0,
            'doctorTypeName': doc['doctorTypeName'] ?? '',
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> cacheAcademicQualifications(List<Map<String, dynamic>> qualifications) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('tblAcademicQualification');
      for (final qual in qualifications) {
        await txn.insert(
          'tblAcademicQualification',
          {
            'qualificationId': qual['qualificationId'] ?? 0,
            'qualificationName': qual['qualificationName'] ?? '',
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> cacheProfessionalQualifications(List<Map<String, dynamic>> qualifications) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('tblProfessionalQualification');
      for (final qual in qualifications) {
        await txn.insert(
          'tblProfessionalQualification',
          {
            'qualificationId': qual['qualificationId'] ?? 0,
            'qualificationName': qual['qualificationName'] ?? '',
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
