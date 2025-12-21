import 'package:flutter/foundation.dart';

import '../data/database_helper.dart';
import '../data/repository.dart';
import '../model/provider_model.dart';

class ProvidersViewModel extends ChangeNotifier {
  final DataRepository _repo = DataRepository();
  final DatabaseHelper _db = DatabaseHelper();

  List<ProviderModel> _all = const [];

  String _chip = 'All';
  String _query = '';
  bool _loading = false;
  String? _error;

  String get chip => _chip;
  String get query => _query;
  bool get loading => _loading;
  String? get error => _error;
  List<String> get filters {
    final set = _all.map((p) => p.programName).where((e) => e.isNotEmpty).toSet().toList()
      ..sort();
    return ['All', ...set];
  }

  List<ProviderModel> get providers {
    final q = _query.toLowerCase();
    return _all.where((p) {
      final category = p.programName;
      final okChip = _chip == 'All' ? true : category == _chip;
      final okQuery = q.isEmpty ||
          p.providerName.toLowerCase().contains(q) ||
          p.providerCode.toLowerCase().contains(q) ||
          category.toLowerCase().contains(q);
      return okChip && okQuery;
    }).toList();
  }

  Future<void> init() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final userId = await _db.getUserId();
    if (userId == null || userId <= 0) {
      _error = 'Please login to load providers.';
      _all = await _repo.getProviders();
      _loading = false;
      notifyListeners();
      return;
    }

    try {
      _all = await _repo.syncProviders(userId: userId);
      _error = null;
    } catch (e) {
      _error = 'Unable to refresh providers. Showing cached list.';
      _all = await _repo.getProviders();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setChip(String value) {
    _chip = value;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> refresh() async {
    final userId = await _db.getUserId();
    if (userId == null || userId <= 0) return;
    try {
      _loading = true;
      notifyListeners();
      _all = await _repo.syncProviders(userId: userId);
      _error = null;
    } catch (_) {
      _error = 'Refresh failed. Showing cached list.';
      _all = await _repo.getProviders();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
