import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import '../config/api_config.dart';
import '../model/provider_model.dart';
import 'database_helper.dart';

class DataRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<ProviderModel>> getProviders() async {
    final db = await _dbHelper.database;
    final rows = await db.query('tblProvider', orderBy: 'providerName ASC');
    return rows.map((e) => ProviderModel.fromMap(e)).toList();
  }

  Future<void> replaceProviders(List<ProviderModel> list) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete('tblProvider');
      for (final p in list) {
        await txn.insert(
          'tblProvider',
          p.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<ProviderModel>> fetchProvidersFromApi(int userId) async {
    final uri = Uri.parse(ApiConfig.providerList)
        .replace(queryParameters: {'UserId': userId.toString()});
    final res = await http.get(uri).timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) {
      throw Exception('Provider fetch failed (${res.statusCode})');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw Exception('Unexpected provider response');
    }
    final list = decoded.whereType<Map<String, dynamic>>().map((m) {
      return ProviderModel.fromMap({
        ...m,
        'dateOfBirth': (m['dateOfBirth'] ?? '').toString(),
      });
    }).toList();
    return list;
  }

  Future<List<ProviderModel>> syncProviders({required int userId}) async {
    final remote = await fetchProvidersFromApi(userId);
    await replaceProviders(remote);
    return remote;
  }

  Future<Map<String, dynamic>> fetchSeedData({int seedId = 4}) async {
    final uri = Uri.parse(ApiConfig.seedData(seedId));
    final res = await http.get(
      uri,
      headers: const {'accept': 'text/plain'},
    ).timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) {
      throw Exception('Seed data fetch failed (${res.statusCode})');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected seed data response');
    }
    return decoded;
  }

  Future<void> syncSeedData({int seedId = 4}) async {
    final payload = await fetchSeedData(seedId: seedId);
    final divisions = _listOfMaps(payload['division']).map((m) {
      return {
        'divisionId': _asInt(m['divisionId']),
        'divisionName': _asString(m['divisionName']),
      };
    }).toList();
    final districts = _listOfMaps(payload['district']).map((m) {
      return {
        'districtId': _asInt(m['districtId']),
        'divisionId': _asInt(m['divisionId']),
        'districtName': _asString(m['districtName']),
      };
    }).toList();
    final thanas = _listOfMaps(payload['thana']).map((m) {
      return {
        'thanaId': _asInt(m['thanaId']),
        'districtId': _asInt(m['districtId']),
        'thanaName': _asString(m['thanaName']),
      };
    }).toList();
    final divisionalOffices = _listOfMaps(payload['divisionalOffice']).map((m) {
      return {
        'divisionalOfficeId': _asInt(m['divisionalOfficeId']),
        'divisionalOfficeName': _asString(m['divisionalOfficeName']),
      };
    }).toList();
    final regionalOffices = _listOfMaps(payload['regionalOffice']).map((m) {
      return {
        'regionalOfficeId': _asInt(m['regionalOfficeId']),
        'divisionalOfficeId': _asInt(m['divisionalOfficeId']),
        'regionalOfficeName': _asString(m['regionalOfficeName']),
      };
    }).toList();
    final areaOffices = _listOfMaps(payload['areaOffice']).map((m) {
      return {
        'areaOfficeId': _asInt(m['areaOfficeId']),
        'regionalOfficeId': _asInt(m['regionalOfficeId']),
        'areaOfficeName': _asString(m['areaOfficeName']),
      };
    }).toList();

    await _dbHelper.cacheSeedData(
      divisions: divisions,
      districts: districts,
      thanas: thanas,
      divisionalOffices: divisionalOffices,
      regionalOffices: regionalOffices,
      areaOffices: areaOffices,
    );
    await syncPrograms();
    await syncProviderGroups();
    await syncProviderDoctorTypes();
    await syncAcademicQualifications();
    await syncProfessionalQualifications();
  }

  Future<List<Map<String, dynamic>>> fetchProgramsFromApi() async {
    final uri = Uri.parse(ApiConfig.seedDataPrograms);
    final res = await http.get(
      uri,
      headers: const {'accept': 'text/plain'},
    ).timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) {
      throw Exception('Program fetch failed (${res.statusCode})');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw Exception('Unexpected program response');
    }
    return decoded.whereType<Map<String, dynamic>>().map((m) {
      return {
        'programId': _asInt(m['programId']),
        'programCode': _asString(m['programCode']),
        'programName': _asString(m['programName']),
        'programShortName': _asString(m['programShortName']),
      };
    }).toList();
  }

  Future<void> syncPrograms() async {
    final programs = await fetchProgramsFromApi();
    await _dbHelper.cachePrograms(programs);
  }

  Future<List<Map<String, dynamic>>> fetchProviderGroupsFromApi() async {
    final uri = Uri.parse(ApiConfig.seedDataProviderGroups);
    final res = await http.get(
      uri,
      headers: const {'accept': 'text/plain'},
    ).timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) {
      throw Exception('Provider group fetch failed (${res.statusCode})');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw Exception('Unexpected provider group response');
    }
    return decoded.whereType<Map<String, dynamic>>().map((m) {
      return {
        'providerGroupId': _asInt(m['providerGroupId']),
        'groupName': _asString(m['groupName']),
        'groupType': _asString(m['groupType']),
      };
    }).toList();
  }

  Future<void> syncProviderGroups() async {
    final groups = await fetchProviderGroupsFromApi();
    await _dbHelper.cacheProviderGroups(groups);
  }

  Future<List<Map<String, dynamic>>> fetchProviderDoctorTypesFromApi() async {
    final uri = Uri.parse(ApiConfig.seedDataProviderDoctorTypes);
    final res = await http.get(
      uri,
      headers: const {'accept': 'text/plain'},
    ).timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) {
      throw Exception('Provider doctor type fetch failed (${res.statusCode})');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw Exception('Unexpected provider doctor type response');
    }
    return decoded.whereType<Map<String, dynamic>>().map((m) {
      return {
        'doctorTypeId': _asInt(m['doctorTypeId']),
        'doctorTypeName': _asString(m['doctorTypeName']),
      };
    }).toList();
  }

  Future<void> syncProviderDoctorTypes() async {
    final doctorTypes = await fetchProviderDoctorTypesFromApi();
    await _dbHelper.cacheProviderDoctorTypes(doctorTypes);
  }

  Future<List<Map<String, dynamic>>> fetchAcademicQualificationsFromApi() async {
    final uri = Uri.parse(ApiConfig.seedDataAcademicQualifications);
    final res = await http.get(
      uri,
      headers: const {'accept': 'text/plain'},
    ).timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) {
      throw Exception('Academic qualification fetch failed (${res.statusCode})');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw Exception('Unexpected academic qualification response');
    }
    return decoded.whereType<Map<String, dynamic>>().map((m) {
      return {
        'qualificationId': _asInt(m['qualificationId']),
        'qualificationName': _asString(m['qualificationName']),
      };
    }).toList();
  }

  Future<void> syncAcademicQualifications() async {
    final qualifications = await fetchAcademicQualificationsFromApi();
    await _dbHelper.cacheAcademicQualifications(qualifications);
  }

  Future<List<Map<String, dynamic>>> fetchProfessionalQualificationsFromApi() async {
    final uri = Uri.parse(ApiConfig.seedDataProfessionalQualifications);
    final res = await http.get(
      uri,
      headers: const {'accept': 'text/plain'},
    ).timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) {
      throw Exception('Professional qualification fetch failed (${res.statusCode})');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw Exception('Unexpected professional qualification response');
    }
    return decoded.whereType<Map<String, dynamic>>().map((m) {
      return {
        'qualificationId': _asInt(m['qualificationId']),
        'qualificationName': _asString(m['qualificationName']),
      };
    }).toList();
  }

  Future<void> syncProfessionalQualifications() async {
    final qualifications = await fetchProfessionalQualificationsFromApi();
    await _dbHelper.cacheProfessionalQualifications(qualifications);
  }

  Future<int> createChecklistVisit({
    required String providerCode,
    required int providerId,
    bool isDraft = false,
    DateTime? createdAt,
  }) async {
    final db = await _dbHelper.database;
    return db.insert('tblChecklistVisit', {
      'provider_code': providerCode,
      'provider_id': providerId,
      'is_draft': isDraft ? 1 : 0,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    });
  }

  Future<void> insertChecklistAnswers(int visitId, Map<int, String> answers) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    answers.forEach((qid, ans) {
      batch.insert('tblChecklistAnswer', {
        'visit_id': visitId,
        'question_id': qid,
        'answer': ans,
      });
    });
    await batch.commit(noResult: true);
  }

  Future<void> saveChecklist({
    required String providerCode,
    required int providerId,
    required Map<int, String> answers,
    bool isDraft = false,
  }) async {
    final visitId = await createChecklistVisit(
      providerCode: providerCode,
      providerId: providerId,
      isDraft: isDraft,
    );
    await insertChecklistAnswers(visitId, answers);
  }

  List<Map<String, dynamic>> _listOfMaps(dynamic value) {
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }

  String _asString(dynamic value) => (value ?? '').toString();
}
