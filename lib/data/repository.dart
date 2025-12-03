import 'package:sqflite/sqflite.dart';

import '../model/provider_model.dart';
import 'database_helper.dart';

class DataRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<ProviderModel>> getProviders() async {
    final db = await _dbHelper.database;
    final rows = await db.query('tblProvider', orderBy: 'name ASC');
    return rows.map((e) => ProviderModel.fromMap(e)).toList();
  }

  Future<int> getProvidersCount() async {
    final db = await _dbHelper.database;
    final res = await db.rawQuery('SELECT COUNT(*) as c FROM tblProvider');
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<void> insertProviders(List<ProviderModel> list) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final p in list) {
      batch.insert('tblProvider', p.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  Future<void> seedProvidersIfEmpty() async {
    final count = await getProvidersCount();
    if (count > 0) return;
    await insertProviders(const [
      ProviderModel(
        name: 'Provider A',
        code: 'ABC123',
        category: 'Green Star',
        type: 'Retailer',
        phone: '+880 12 3456 7890',
      ),
      ProviderModel(
        name: 'Provider B',
        code: 'DEF456',
        category: 'Blue Star',
        type: 'Retailer',
        phone: '+880 12 1234 5678',
      ),
      ProviderModel(
        name: 'Provider C',
        code: 'GHI789',
        category: 'Green Star',
        type: 'Retailer',
        phone: '+880 19 8765 4321',
      ),
      ProviderModel(
        name: 'Provider D',
        code: 'JKL012',
        category: 'Silver',
        type: 'Wholesaler',
        phone: '+880 17 1111 2222',
      ),
    ]);
  }

  Future<int> createChecklistVisit({required String providerCode, DateTime? createdAt}) async {
    final db = await _dbHelper.database;
    return db.insert('tblChecklistVisit', {
      'provider_code': providerCode,
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

  Future<void> saveChecklist({required String providerCode, required Map<int, String> answers}) async {
    final visitId = await createChecklistVisit(providerCode: providerCode);
    await insertChecklistAnswers(visitId, answers);
  }
}

