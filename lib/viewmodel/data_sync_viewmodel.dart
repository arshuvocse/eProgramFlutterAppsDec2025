import 'package:flutter/foundation.dart';

import '../data/database_helper.dart';
import '../data/repository.dart';

class SyncItem {
  final String title;
  final bool synced;

  const SyncItem(this.title, this.synced);
}

class DataSyncViewModel extends ChangeNotifier {
  final DataRepository _repo = DataRepository();
  final DatabaseHelper _db = DatabaseHelper();

  bool _loading = false;
  String? _errorMessage;
  DateTime? _lastSync;
  bool _syncCompleted = false;
  List<SyncItem> _items = const [
    SyncItem('Programs', false),
    SyncItem('Provider Groups', false),
    SyncItem('Provider Doctor Types', false),
    SyncItem('Academic Qualifications', false),
    SyncItem('Professional Qualifications', false),
    SyncItem('Divisions', false),
    SyncItem('Districts', false),
    SyncItem('Thanas', false),
    SyncItem('Divisional Offices', false),
    SyncItem('Regional Offices', false),
    SyncItem('Area Offices', false),
  ];

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSync => _lastSync;
  bool get syncCompleted => _syncCompleted;
  List<SyncItem> get items => _items;

  Future<void> init() async {
    await _loadStatus();
    await syncSeedData();
  }

  Future<void> syncSeedData() async {
    _loading = true;
    _errorMessage = null;
    _syncCompleted = false;
    notifyListeners();

    try {
      await _repo.syncSeedData();
      _lastSync = DateTime.now();
      _syncCompleted = true;
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Seed data sync failed. Please try again.';
    } finally {
      await _loadStatus(notify: false);
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadStatus({bool notify = true}) async {
    try {
      final counts = await _db.getSeedDataCounts();
      _items = [
        SyncItem('Programs', (counts['tblProgram'] ?? 0) > 0),
        SyncItem('Provider Groups', (counts['tblProviderGroup'] ?? 0) > 0),
        SyncItem('Provider Doctor Types', (counts['tblProviderDoctorType'] ?? 0) > 0),
        SyncItem('Academic Qualifications', (counts['tblAcademicQualification'] ?? 0) > 0),
        SyncItem(
          'Professional Qualifications',
          (counts['tblProfessionalQualification'] ?? 0) > 0,
        ),
        SyncItem('Divisions', (counts['tblDivision'] ?? 0) > 0),
        SyncItem('Districts', (counts['tblDistrict'] ?? 0) > 0),
        SyncItem('Thanas', (counts['tblThana'] ?? 0) > 0),
        SyncItem(
          'Divisional Offices',
          (counts['tblDivisionalOffice'] ?? 0) > 0,
        ),
        SyncItem(
          'Regional Offices',
          (counts['tblRegionalOffice'] ?? 0) > 0,
        ),
        SyncItem('Area Offices', (counts['tblAreaOffice'] ?? 0) > 0),
      ];
    } catch (_) {
      _items = const [
        SyncItem('Programs', false),
        SyncItem('Provider Groups', false),
        SyncItem('Provider Doctor Types', false),
        SyncItem('Academic Qualifications', false),
        SyncItem('Professional Qualifications', false),
        SyncItem('Divisions', false),
        SyncItem('Districts', false),
        SyncItem('Thanas', false),
        SyncItem('Divisional Offices', false),
        SyncItem('Regional Offices', false),
        SyncItem('Area Offices', false),
      ];
    }
    if (notify) {
      notifyListeners();
    }
  }
}
